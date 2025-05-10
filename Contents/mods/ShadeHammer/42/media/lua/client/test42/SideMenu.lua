require 'ISUI/ISUIElement';
local ModelRenderer = require 'test42/ModelRenderer';
local UIUtils = require 'test42/UIUtils';
local CameraUtils = require 'asledgehammer/util/CameraUtils';
local TextureUtils = require 'asledgehammer/util/TextureUtils';
local ShadeHammer = require 'asledgehammer/ShadeHammer';
local Reflect = require 'Reflect';

--- @alias SideMenuMode 'half-left'|'half-right'|'third-left'|'third-right'

local core = getCore();
local debugChunkState = DebugChunkState.checkInstance();

--- @class SideMenu: ISUIElement
--- @field mode SideMenuMode
--- @field shader LuaShader
--- @field modelScene ModelRenderer
--- @field show fun(self)
--- @field hide fun(self)
--- @field new fun(self, mode: SideMenuMode): SideMenu
SideMenu = ISUIElement:derive('SideMenu');

function SideMenu:show()
    self.closed = false;
    self.closing = false;
    if self.lerp < 1 then
        self.opening = true;
        self.open = false;
    else
        self.open = true;
        self.opening = false;
    end
end

function SideMenu:hide()
    self.open = false;
    self.opening = false;
    if self.lerp > 0 then
        self.closing = true;
        self.closed = false;
    else
        self.closed = true;
        self.closing = false;
    end
end

--- MARK: Update

function SideMenu:updateTick()
    self:updateLerp();
    self:updateCamera();

    local sw = core:getScreenWidth();
    local sh = core:getScreenHeight();
    local sw2 = Math.round(sw / 2);
    local sw3 = Math.round(sw / 3);

    local x, y, width, height = 0, 0, sw, sh;
    if self.mode == 'half-left' then
        x = 0;
        width = sw2;
    elseif self.mode == 'half-right' then
        x = sw2;
        width = sw2;
    elseif self.mode == 'third-left' then
        x = 0;
        width = sw3;
    elseif self.mode == 'third-right' then
        x = sw3 * 2;
        width = sw3;
    end

    if self.x ~= x then
        self.x = x;
        self.javaObject:setX(x);
    end
    if self.y ~= y then
        self.y = y;
        self.javaObject:setY(y);
    end
    if self.width ~= width then
        self.width = width;
        self.javaObject:setWidth(width);
    end
    if self.height ~= height then
        self.height = height;
        self.javaObject:setHeight(height);
    end

    self.modelScene:setX((self.width / 2) - (self.modelScene.width / 2));
    self.modelScene:setY((self.width / 2) - (self.modelScene.height / 2));
    self.modelScene:updateTick();
end

function SideMenu:updateCamera()
    -- Calculate the animated lerp value. (Smoother rendering)
    local lerp = self.lerp;
    if self.closing then
        lerp = UIUtils.easeInQuad(lerp);
    elseif self.opening then
        lerp = UIUtils.easeOutQuad(lerp);
    end

    -- Calculate the placement of the camera, calculating its position and offset.
    local zoom = CameraUtils.calculateCurrentZoom();
    local sw = core:getScreenWidth();
    local dx, dy = 0, 0;
    if self.mode == 'half-left' then
        dx, dy = CameraUtils.toIsoPlayerRelative((sw / 4.0) * zoom * lerp, 0);
    elseif self.mode == 'half-right' then
        dx, dy = CameraUtils.toIsoPlayerRelative((-sw / 4.0) * zoom * lerp, 0);
    elseif self.mode == 'third-left' then
        dx, dy = CameraUtils.toIsoPlayerRelative((sw / 6.0) * zoom * lerp, 0);
    elseif self.mode == 'third-right' then
        dx, dy = CameraUtils.toIsoPlayerRelative((-sw / 6.0) * zoom * lerp, 0);
    end

    -- Use the debugging state to gain access to the camera-drag functionality, offseting the camera.
    -- NOTE: The offset is relative to the camera.
    debugChunkState:fromLua2('dragCamera', dx, dy);
end

function SideMenu:updateLerp()
    if self.opening then
        self.lerp = self.lerp + 0.08;
        if self.lerp >= 1 then
            self.lerp = 1;
            self.opening = false;
            self.open = true;
            self.closed = false;
            self.closing = false;
        end
    elseif self.closing then
        self.lerp = self.lerp - 0.08;
        if self.lerp <= 0 then
            self.lerp = 0;
            self.closing = false;
            self.closed = false;
            self.open = false;
            self.opening = false;
        end
    else
        if self.open then
            self.lerp = 1;
        else
            self.lerp = 0;
        end
    end
    self.modelScene.alpha = self.lerp;
end

--- MARK: Render

function SideMenu:prerender()
    self:renderBackground();
end

local function fillArcGradient(x, y, radiusInner, radiusOuter, start, stop, resolution, colInner, colOuter)
    local coordsOuter = {};
    local coordsInner = {};
    for step = 0, resolution - 1 do
        local theta = UIUtils.lerp(start, stop, step / resolution);
        table.insert(coordsInner, {
            x = x + (Math.cos(theta) * radiusInner),
            y = y + (Math.sin(theta) * radiusInner)
        });
        table.insert(coordsOuter, {
            x = x + (Math.cos(theta) * radiusOuter),
            y = y + (Math.sin(theta) * radiusOuter)
        });
    end
    for step = 1, resolution do
        local stepLast = step - 1;
        if stepLast == 0 then stepLast = resolution end
        UIUtils.drawTexQuadGradient(nil,
            coordsInner[step].x, coordsInner[step].y,
            coordsInner[stepLast].x, coordsInner[stepLast].y,
            coordsOuter[stepLast].x, coordsOuter[stepLast].y,
            coordsOuter[step].x, coordsOuter[step].y,
            colInner.r, colInner.g, colInner.b, colInner.a,
            colInner.r, colInner.g, colInner.b, colInner.a,
            colOuter.r, colOuter.g, colOuter.b, colOuter.a,
            colOuter.r, colOuter.g, colOuter.b, colOuter.a
        );
    end
end

function SideMenu:renderBackground()
    --- Make sure that the shader is compiled and ready to use.
    if not self.shader.loaded or not self.shader.valid then return end

    self.shader:update();

    -- Calculate the animated lerp value. (Smoother rendering)
    local alpha = self.lerp;
    if self.closing then
        alpha = UIUtils.easeInQuad(alpha);
    elseif self.opening then
        alpha = UIUtils.easeOutQuad(alpha);
    end

    -- BEGIN UI control.
    self.shader:enable();
    self.shader:setUniforms({
        UIFadeHalfLeft = 0,
        UIFadeHalfRight = 0,
        UIFadeThirdLeft = 0,
        UIFadeThirdRight = 0,
        UIColor = {1.0, 1.0, 1.0, alpha}, -- Set color & alpha.
    });

    --- @type Texture
    local fbo = TextureUtils.getFBOTexture();
    local fboSubTex = fbo:split(self.x, self.y, self.width, self.height);
    fboSubTex:rendershader2(
        self.x, self.y, self.width, self.height,
        self.x, self.y, self.width, self.height,
        1.0, 1.0, 1.0, alpha
    );

    self.shader:disable();

    local yOffset = self.height / 3.0;

    UIUtils.drawTexQuadGradient(
        nil,
        self.x, self.y + (self.height / 2) - yOffset,
        self.x + self.width, self.y + (self.height / 2) - yOffset,
        self.x + self.width, self.y + self.height,
        self.x, self.y + self.height,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0.66 * alpha,
        0, 0, 0, 0.66 * alpha
    );

    if self.mode == 'third-right' then
        UIUtils.drawTexQuadGradient(
            nil,
            self.x - 24, self.y,
            self.x, self.y,
            self.x, self.y + self.height,
            self.x - 24, self.y + self.height,
            0, 0, 0, 0,
            0, 0, 0, 0.5 * alpha,
            0, 0, 0, 0.5 * alpha,
            0, 0, 0, 0
        );

        local borderColor = { r = 0.88, g = 0.88, b = 0.88, a = 1 * alpha };

        -- Left border
        UIUtils.drawTexQuadGradient(
            nil,
            self.x, self.y,
            self.x + 1, self.y,
            self.x + 1, self.y + self.height,
            self.x, self.y + self.height,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a
        );

        -- Right border
        UIUtils.drawTexQuadGradient(
            nil,
            self.x + self.width, self.y,
            self.x + self.width - 1, self.y,
            self.x + self.width - 1, self.y + self.height,
            self.x + self.width, self.y + self.height,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a
        );

        -- Top border
        UIUtils.drawTexQuadGradient(
            nil,
            self.x, self.y,
            self.x + self.width, self.y,
            self.x + self.width, self.y + 1,
            self.x, self.y + 1,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a
        );

        -- Bottom border
        UIUtils.drawTexQuadGradient(
            nil,
            self.x, self.y + self.height - 1,
            self.x + self.width, self.y + self.height - 1,
            self.x + self.width, self.y + self.height,
            self.x, self.y + self.height,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a,
            borderColor.r, borderColor.g, borderColor.b, borderColor.a
        );
    end

    local innerX = self.x + (self.width / 2);
    local innerY = self.y + (self.width / 2);
    local resolution = 16;
    local colOuter = { r = 0.0, g = 0.0, b = 0.0, a = 0.0 };
    local colInner = { r = 0.0, g = 0.0, b = 0.0, a = 0.6 * alpha };

    fillArcGradient(innerX, innerY, 0, 64, 0, Math.PI * 2, resolution, colInner, colInner);
    fillArcGradient(innerX, innerY, 64, 192, 0, Math.PI * 2, resolution, colInner, colOuter);
end

--- MARK: Constructor

function SideMenu:instantiate()
    self.javaObject = UIElement.new(self);
    self.javaObject:setX(self.x);
    self.javaObject:setY(self.y);
    self.javaObject:setHeight(self.height);
    self.javaObject:setWidth(self.width);
    self.javaObject:setAnchorLeft(self.anchorLeft);
    self.javaObject:setAnchorRight(self.anchorRight);
    self.javaObject:setAnchorTop(self.anchorTop);
    self.javaObject:setAnchorBottom(self.anchorBottom);
    self.javaObject:setWantKeyEvents(self.wantKeyEvents or false);
    self.javaObject:setWantExtraMouseEvents(self.wantExtraMouseEvents or false);
    self.javaObject:setForceCursorVisible(self.forceCursorVisible or false);
    self:backMost();
    self:createChildren();
end

--- @param mode SideMenuMode
---
--- @return SideMenu instance
function SideMenu:new(mode)
    local sw = core:getScreenWidth();
    local sh = core:getScreenHeight();
    local sw2 = Math.round(sw / 2);
    local sw3 = Math.round(sw / 3);

    local x, y, width, height;
    if mode == 'half-left' then
        x = 0;
        width = sw2;
    elseif mode == 'half-right' then
        x = sw2;
        width = sw2;
    elseif mode == 'third-left' then
        x = 0;
        width = sw3;
    elseif mode == 'third-right' then
        x = sw3 * 2;
        width = sw3;
    end
    y = 0;
    height = sh;

    --- @type SideMenu
    local o = ISUIElement:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.mode = mode;
    o.lerp = 0.0;
    o.open = false;
    o.opening = false;
    o.closed = true;
    o.closing = false;
    o.shader = ShadeHammer.getOrLoadSkinnedShader('FrostedGlass');

    local modelPos = Vector3f.new(0.0, -0.25, 0.0);
    local modelName = 'FireAxe'; --'BaseballBat'; -- 'Vehicles_Wheel';

    o.modelScene = ModelRenderer:new((o.width / 2) - 256, (o.width / 2) - 256, 512, 512, modelName);
    o.modelScene.zoom = 14;
    o.modelScene.zoomMax = 16;
    o.modelScene.zoomMin = 12;
    o.modelScene.zoomable = true;
    o.modelScene.position = modelPos;
    o:addChild(o.modelScene);

    -- NOTE: Update the menu through the game's update loop because updates to UI are too slow to allow smooth animations.
    Events.OnTick.Add(function()
        o:updateTick();
    end);

    return o;
end

return SideMenu;
