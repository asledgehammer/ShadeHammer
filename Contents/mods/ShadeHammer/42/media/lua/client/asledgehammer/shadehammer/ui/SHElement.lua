local class = require 'asledgehammer/util/class';

local LuaFont = require 'asledgehammer/shadehammer/LuaFont';
local LuaFontRender = require 'asledgehammer/shadehammer/LuaFontRender';

local BoxShadow = require 'asledgehammer/shadehammer/ui/BoxShadow';

--- @type LuaFont
local font = LuaFont('CodeLarge', 'media/fonts/codeLarge.fnt');

-- Vector library --
local vector = require 'asledgehammer/math/vector';
local vec3 = vector.vec3;
local vec4 = vector.vec4;
local mat4 = vector.mat4;

-- Axes for axis-aligned transforms.
local ROTATION_X_AXIS = vec3(1.0, 0.0, 0.0);
local ROTATION_Y_AXIS = vec3(0.0, 1.0, 0.0);
local ROTATION_Z_AXIS = vec3(0.0, 0.0, 1.0);

-- Premade objects for calculating faster.
--- @type vec4, vec4
local point_1, point_2 = vec4(), vec4();

-- Internal render API that we abuse.
local renderer = getRenderer();

-- -------------- --

--- @type table<string,SHElement>
local elements = {};

Events.OnTickEvenPaused.Add(function(tick)
    for k, v in pairs(elements) do
        --- @cast v SHElement
        v:updateTick(tick);
    end
end);

--- @alias SHColor {r: number, g: number, b: number, a: number}


-- Shader library --
local ShadeHammer = require 'asledgehammer/ShadeHammer';
-- -------------- --

--- @class SHBorder
---
--- @field size number?
--- @field sizeT number?
--- @field sizeL number?
--- @field sizeB number?
--- @field sizeR number?
---
--- @field radius number?
--- @field radiusTL number?
--- @field radiusTR number?
--- @field radiusBR number?
--- @field radiusBL number?
---
--- @field color SHColor?
--- @field colorT SHColor?
--- @field colorL SHColor?
--- @field colorB SHColor?
--- @field colorR SHColor?
local SHBorder = class(
    function(o)
        -- Size
        o.size     = nil;
        o.sizeT    = nil;
        o.sizeL    = nil;
        o.sizeB    = nil;
        o.sizeR    = nil;

        -- Radius
        o.radius   = nil;
        o.radiusTL = nil;
        o.radiusTR = nil;
        o.radiusBR = nil;
        o.radiusBL = nil;

        -- Color
        o.color    = nil;
        o.colorT   = nil;
        o.colorL   = nil;
        o.colorB   = nil;
        o.colorR   = nil;
    end
);

--- @param shader LuaShader
function SHBorder:apply(shader)
    if not shader.valid or not shader.enabled then return end

    local size = self.size or 0;
    local sizeT = self.sizeT or size;
    local sizeL = self.sizeL or size;
    local sizeB = self.sizeB or size;
    local sizeR = self.sizeR or size;

    local borderRadius = self.radius or 0;
    local borderRadiusTL = self.radiusTL or borderRadius;
    local borderRadiusTR = self.radiusTR or borderRadius;
    local borderRadiusBR = self.radiusBR or borderRadius;
    local borderRadiusBL = self.radiusBL or borderRadius;

    local borderColor = { 0, 0, 0, 1 };
    if self.color then
        borderColor = { self.color.r, self.color.g, self.color.b, self.color.a };
    end

    local borderColorT = borderColor;
    if self.colorT then
        borderColorT = { self.colorT.r, self.colorT.g, self.colorT.b, self.colorT.a };
    end

    local borderColorL = borderColor;
    if self.colorL then
        borderColorL = { self.colorL.r, self.colorL.g, self.colorL.b, self.colorL.a };
    end

    local borderColorB = borderColor;
    if self.colorB then
        borderColorB = { self.colorB.r, self.colorB.g, self.colorB.b, self.colorB.a };
    end

    local borderColorR = borderColor;
    if self.colorR then
        borderColorR = { self.colorR.r, self.colorR.g, self.colorR.b, self.colorR.a };
    end

    shader:setUniforms({
        -- Size
        borderSizeT    = sizeT,
        borderSizeL    = sizeL,
        borderSizeB    = sizeB,
        borderSizeR    = sizeR,

        -- Radius
        borderRadiusTL = borderRadiusTL,
        borderRadiusTR = borderRadiusTR,
        borderRadiusBR = borderRadiusBR,
        borderRadiusBL = borderRadiusBL,

        -- Color
        borderColorT   = borderColorT,
        borderColorL   = borderColorL,
        borderColorB   = borderColorB,
        borderColorR   = borderColorR
    });
end

--- @param shader LuaShader
function SHBorder:reset(shader)
    if not shader.valid or not shader.enabled then return end

    local color = { 0, 0, 0, 0 };

    shader:setUniforms({
        -- Size
        borderSizeT = 0,
        borderSizeL = 0,
        borderSizeB = 0,
        borderSizeR = 0,

        -- Radius
        borderRadiusTL = 0,
        borderRadiusTR = 0,
        borderRadiusBR = 0,
        borderRadiusBL = 0,

        -- Color
        borderColorT = color,
        borderColorL = color,
        borderColorB = color,
        borderColorR = color
    });
end

--- @class SHElement
--- @field uuid string
--- @field parent SHElement | nil
--- @field children SHElement[]
--- @field size {width: number, height: number}
--- @field shader LuaShader | nil
--- @field java UIElement
---
--- @field position vec3
--- @field rotation vec3
--- @field rotationPivot vec3
--- @field scale vec3
--- @field mat mat4
--- @field lmat mat4
--- @field border SHBorder
---
--- @field boxShadow BoxShadow?
---
--- @field background boolean
--- @field backgroundColor { r: number, g: number, b: number, a: number }
---
--- DEBUG
--- @field textRender LuaFontRender
--- @field text string
---
--- @field onInit fun()
local SHElement = class(function(o, x, y, width, height)
    o.uuid = getRandomUUID();
    o.visible = true;
    o.size = { width = width, height = height };
    o.parent = nil;
    o.children = {};
    o.shader = ShadeHammer.getOrLoadSkinnedShader('ShadeHammer');
    o.position = vec3(x, y, 0);
    o.rotation = vec3(0, 0, 0);
    o.rotationPivot = vec3(0.5, 0.5, 0.5);
    o.scale = vec3(1);

    o.color = { r = 0, g = 0, b = 0, a = 1 };

    o.backgroundColor = { r = 1, g = 1, b = 1, a = 1 };
    o.background = true;

    o.border = SHBorder();
    o.boxShadow = nil;

    o.posMat = mat4(1);
    o.rotMat = mat4(1);
    o.scaMat = mat4(1);
    o.mat = mat4(1);
    o.lmat = mat4(1);
end);

function SHElement:listen()
    elements[self.uuid] = self;
end

function SHElement:unlisten()
    elements[self.uuid] = nil;
end

--- Initializes the element, instantiating the UIElement `self.java` instance and then firing `self.onInit()`.
function SHElement:init()
    -- Use rawget and rawset because of the metafunction ensuring this fires.
    local java = rawget(self, 'java');

    -- Only initialize if the java instance isn't created.
    if java then return end

    java = UIElement.new(self);
    java:setX(self.position.x);
    java:setY(self.position.y);
    java:setWidth(self.size.width);
    java:setHeight(self.size.height);

    rawset(self, 'java', java);

    if self.onInit then self.onInit() end
end

-- Left empty because UI update methods are slow.
function SHElement:update() end

function SHElement:updateTransform()
    -- Local Transform Matrix
    self.lmat:setIdentitySelf();
    self.lmat:translateSelf(self.position);
    self.lmat:rotateSelf(Math.toRadians(self.rotation.x), ROTATION_X_AXIS);
    self.lmat:rotateSelf(Math.toRadians(self.rotation.y), ROTATION_Y_AXIS);
    self.lmat:rotateSelf(Math.toRadians(self.rotation.z), ROTATION_Z_AXIS);
    self.lmat:scaleSelf(self.scale);

    -- Global Transform Matrix
    if self.parent then
        mat4.mul(self.parent.mat, self.lmat, self.mat);
    else
        mat4.clone(self.lmat, self.mat);
    end
end

function SHElement:updateChildren(tick)
    if #self.children ~= 0 then
        for _, child in ipairs(self.children) do
            child:updateTick(tick);
        end
    end
end

--- @param tick number
function SHElement:updateTick(tick)
    self:updateTransform();

    if self.boxShadow then
        self.boxShadow:update(self);
    end

    self:onUpdate();
    self:updateChildren(tick);
end

function SHElement:onUpdate() end

function SHElement:prerender()
    local shader = self.shader;

    -- Cannot render without the shader.
    if not shader then return end

    self:onPreRender();
end

function SHElement:render()
    local shader = self.shader;

    -- Cannot render without the shader.
    if not shader then return end

    self:onRender();
end

function SHElement:onPreRender()
    if self.boxShadow then
        self.boxShadow:render();
    end
    self:renderBackground();
end

--- @param inset? boolean
--- @param offsetX? number
--- @param offsetY? number
--- @param blur? number
--- @param spread? number
--- @param color? {r: number, g: number, b: number, a: number}
function SHElement:createBoxShadow(inset, offsetX, offsetY, blur, spread, color)
    inset = inset or false;
    offsetX = offsetX or 0;
    offsetY = offsetY or 0;
    blur = blur or 0;
    spread = spread or 0;
    color = color or { r = 0, g = 0, b = 0, a = 1 };
    self.boxShadow = BoxShadow(inset, offsetX, offsetY, blur, spread, color);
end

function SHElement:renderBackground()
    local shader = self.shader;

    if not shader then return end

    local color = self.backgroundColor;
    local x1 = -self.rotationPivot.x * self.size.width;
    local y1 = -self.rotationPivot.y * self.size.height;
    local x2, y2 = x1 + self.size.width, y1 + self.size.height;

    local tlx, tly, trx, try, brx, bry, blx, bly = self:rotateQuad2D(x1, y1, x2, y1, x2, y2, x1, y2);

    shader:enable();
    self.border:apply(shader);
    shader:applyDimension(x1, y1, x2, y2);
    shader:applyTransform(self.mat);

    shader:setUniforms({
        UIColor = { color.r, color.g, color.b, color.a },
        UITexture = 0
    });

    renderer:render(
        nil, -- Texture
        tlx, tly,
        trx, try,
        brx, bry,
        blx, bly,
        x1, y1, 0, 0,
        x2, y1, 0, 0,
        x2, y2, 0, 0,
        x1, y2, 0, 0,
        nil -- RGBA
    );

    self.border:reset(shader);
    shader:disable();
end

function SHElement:onRender() end

--- @param child SHElement
function SHElement:addChild(child)
    child:setParent(self);
end

--- @param child SHElement
function SHElement:removeChild(child)
    child:setParent(nil);
end

function SHElement:empty()
    for _, child in ipairs(self.children) do
        self:removeChild(child);
    end
end

--- Sets the parent of the element.
---
--- **NOTE**: If the element is added to the screen, it'll be removed and set as a child of the parent.
---
--- @param parent SHElement | nil
function SHElement:setParent(parent)
    -- if parent == self.parent then return end

    local java, parentOld = self.java, self.parent;
    if parentOld then
        -- Remove self from the old parent.
        local newChildren = {};
        for i = 1, #parentOld.children do
            local next = newChildren[i];
            if next ~= self then table.insert(newChildren, next) end
        end
        parentOld.children = newChildren;
        -- Remove Java class child.
        parentOld.java:RemoveChild(java);
        -- --------------------------------

        java:setParent(nil);
        self.parent = nil;
    end

    self.parent = parent;
    if parent ~= nil then
        --- Add to the new parent.
        table.insert(parent.children, self);
        parent.java:AddChild(java);
    end
end

--- Adds the element to the screen.
---
--- **NOTE**: If the element has a parent, that parent-link is removed.
function SHElement:addToScreen()
    UIManager.AddUI(self.java);
end

--- @param x number
--- @param y number
---
--- @return number x
--- @return number y
function SHElement:transformPoint2D(x, y)
    point_1:set(x, y, 0, 1);
    local tp = mat4.transform(self.mat, point_1, point_2);
    return tp.x, tp.y;
end

--- @param x number
--- @param y number
--- @param z number
---
--- @return number x
--- @return number y
--- @return number z
function SHElement:transformPoint3D(x, y, z)
    point_1:set(x, y, z, 1);
    mat4.transform(self.mat, point_1, point_2);
    return point_2.x, point_2.y, point_2.z;
end

---
--- @param tlx number
--- @param tly number
--- @param trx number
--- @param try number
--- @param brx number
--- @param bry number
--- @param blx number
--- @param bly number
---
--- @return number tlx
--- @return number tly
--- @return number trx
--- @return number try
--- @return number brx
--- @return number bry
--- @return number blx
--- @return number bly
function SHElement:rotateQuad2D(tlx, tly, trx, try, brx, bry, blx, bly)
    tlx, tly = self:transformPoint2D(tlx, tly);
    trx, try = self:transformPoint2D(trx, try);
    brx, bry = self:transformPoint2D(brx, bry);
    blx, bly = self:transformPoint2D(blx, bly);
    return tlx, tly, trx, try, brx, bry, blx, bly;
end

---
--- @param tlx number
--- @param tly number
--- @param tlz number
--- @param trx number
--- @param try number
--- @param trz number
--- @param brx number
--- @param bry number
--- @param brz number
--- @param blx number
--- @param bly number
--- @param blz number
---
--- @return number tlx
--- @return number tly
--- @return number tlz
--- @return number trx
--- @return number try
--- @return number trz
--- @return number brx
--- @return number bry
--- @return number brz
--- @return number blx
--- @return number bly
--- @return number blz
function SHElement:rotateQuad3D(tlx, tly, tlz, trx, try, trz, brx, bry, brz, blx, bly, blz)
    tlx, tly, tlz = self:transformPoint3D(tlx, tly, tlz);
    trx, try, trz = self:transformPoint3D(trx, try, trz);
    brx, bry, brz = self:transformPoint3D(brx, bry, brz);
    blx, bly, blz = self:transformPoint3D(blx, bly, blz);
    return tlx, tly, tlz, trx, try, trz, brx, bry, brz, blx, bly, blz;
end

-- MARK: metatable

local mt = getmetatable(SHElement);

mt.__index = function(t, key)
    -- Check and see if the Java object is present. If not, fire the `init()` function.
    if key == 'java' then
        local java = rawget(t, key);
        if java then return java end
        rawget(t, 'init')(t);
    end
    -- Return normal key-indexed value.
    return rawget(t, key);
end

setmetatable(SHElement, mt);

-- MARK: DEBUG CODE

Events.OnGameStart.Add(function()
    local parent = SHElement(400, 400, 256, 128);
    parent.backgroundColor.r = 1;
    parent.backgroundColor.g = 0;
    parent.backgroundColor.b = 0;

    parent.text = 'Hello, World!';
    parent.textRender = font:drawString(parent.text, 0, 0, {r = 1, g = 1, b = 1, a = 1});

    parent.onUpdate = function(self)
        -- self.rotation.z = self.rotation.z + 0.5;
        -- if self.rotation.z > 360 then
        --     self.rotation.z = self.rotation.z - 360;
        -- end
        if self.textRender:isChanged(self.mat) then
            self.textRender = self.textRender:transform(self.mat);
        end
    end

    parent.onRender = function(self)
        self.shader:enable();
        self.textRender:render(self.shader);
        self.shader:disable();
    end

    parent:createBoxShadow(false, 32, 32);

    local child = SHElement(200, 0, 64, 64);
    child.backgroundColor.r = 0;
    child.backgroundColor.g = 1;
    child.backgroundColor.b = 0;

    parent:addChild(child);
    parent:listen();
    parent:addToScreen();

    _G.debugElement = parent;


    local reloadShadersButton = ISButton:new(64, 64, 128, 32, 'Reload Shaders', nil, function()
        reloadShader('ShadeHammer');
        reloadShader('ShadeHammer_BoxShadow');
    end);
    reloadShadersButton:addToUIManager();

    local printShadersButton = ISButton:new(64, 80, 128, 32, 'Print Shaders', nil, function()
        ShadeHammer.printShaders();
    end);
    printShadersButton:addToUIManager();
end);
