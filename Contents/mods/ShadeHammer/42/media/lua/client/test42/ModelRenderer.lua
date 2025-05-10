--- @alias UI3DSceneView 'Left'|'Right'|'Top'|'Bottom'|'Front'|'Back'|'UserDefined'

local Reflect = require 'Reflect';
local UIUtils = require 'test42/UIUtils';
local ShadeHammer = require 'asledgehammer/ShadeHammer';
local ModelOrientation = require 'test42/ModelOrientation';

local zeroVector = Vector3f.new();
local PI = Math.PI;
local PIDiv180 = PI / 180.0;
local zero3f = { 0.0, 0.0, 0.0 };
local one3f = { 1.0, 1.0, 1.0 };
local resetColorForceValue = { 1.0, 1.0, 1.0, 1.0 };

--- @MARK: Internal

--- @class ModelRendererInternal : ISUIElement
--- @field velocity Vector3f
--- @field isometric boolean
--- @field background boolean
--- @field backgroundColor { r: number, g: number, b: number, a: number }
--- @field borderColor { r: number, g: number, b: number, a: number }
--- @field zoom number
--- @field shader LuaShader
--- @field modelName string
--- @field outline boolean
--- @field alpha number
--- @field orientation ModelOrientation
--- @field parent ModelRenderer
local ModelRendererInternal = ISUIElement:derive('UIModelOrbitInternal');

function ModelRendererInternal:instantiate()
    self.javaObject = UI3DScene.new(self);
    self.javaObject:setX(self.x);
    self.javaObject:setY(self.y);
    self.javaObject:setWidth(self.width);
    self.javaObject:setHeight(self.height);
    self.javaObject:setAnchorLeft(self.anchorLeft);
    self.javaObject:setAnchorRight(self.anchorRight);
    self.javaObject:setAnchorTop(self.anchorTop);
    self.javaObject:setAnchorBottom(self.anchorBottom);
    self.javaObject:setConsumeMouseEvents(false);
    self.javaObject:fromLua1('setMaxZoom', 20);
    self.javaObject:fromLua1('setDrawGrid', false);
    self.javaObject:fromLua1('setDrawGridAxes', false);
    self.javaObject:fromLua1('setDrawGridPlane', false);
    self.javaObject:fromLua2('createModel', self.modelName, self.modelName);
    self.javaObject:fromLua2('setModelScript', self.modelName, self.modelName);
    self:setView('UserDefined');
    self:createChildren();
    Reflect.printJavaFields(self.javaObject);
end

function ModelRendererInternal:renderBackground()
    if self.background then
        self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r,
            self.backgroundColor.g, self.backgroundColor.b)
        self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r,
            self.borderColor.g, self.borderColor.b)
    end
end

function ModelRendererInternal:applyShader()
    self.shader:enable();

    local uniforms = {
        UI = 1,
        UIPosition = self.orientation.position,
        UIRotationPivot = self.orientation.rotationPivot,
        UIRotation = {
            -self.rotation:x() * PIDiv180,
            -self.rotation:y() * PIDiv180,
            -self.rotation:z() * PIDiv180
        },
    };

    if self.outline then
        uniforms.UIOutline = 1;
        uniforms.UIColorForce = 1;
        local light = 1.0 * (self.alpha * 1.2);
        uniforms.UIColorForceValue = { light, light, light, self.alpha };
        uniforms.UIOutlineScale = self.orientation.outlineScale;
        uniforms.AlphaForce = 1.0;
    else
        uniforms.UIOutline = 0;
        uniforms.UIColorForce = 0;
        uniforms.UIColorForceValue = { 1.0, 1.0, 1.0, self.alpha };
        uniforms.UIOutlineScale = one3f;
        uniforms.AlphaForce = self.alpha;
    end

    self.shader:setUniforms(uniforms);
    self.shader:disable();
end

function ModelRendererInternal:resetScene()
    self.javaObject:fromLua1('setGizmoVisible', 'none');
    self.javaObject:fromLua1('setGizmoOrigin', 'none');
    self.javaObject:fromLua1('setGizmoPos', zeroVector);
    self.javaObject:fromLua1('setGizmoRotate', zeroVector);
    self.javaObject:fromLua0('clearAABBs');
    self.javaObject:fromLua0('clearAxes');
    self.javaObject:fromLua1('setSelectedAttachment', nil);
end

function ModelRendererInternal:prerender()
    self:updateViewport();
    self:resetScene();
    self:renderBackground();
    self:applyShader();
end

function ModelRendererInternal:updateViewport()
    local velocity = self.velocity;
    local vx, vy, vz = velocity:x(), velocity:y(), velocity:z();
    local cx, cy, cz = self.rotation:x(), self.rotation:y(), self.rotation:z();

    if self.isometric then
        cx = -30;
        cz = 0;
    end

    cx = cx + self.orientation.rotation:x() + vx;
    cy = cy + self.orientation.rotation:y() + vy;
    cz = cz + self.orientation.rotation:z() + vz;

    self.rotation = Vector3f.new(cx, cy, cz);
    self.javaObject:fromLua1('setZoom', self.zoom);
end

--- @param name UI3DSceneView
function ModelRendererInternal:setView(name)
    self.javaObject:fromLua1('setView', name);
end

--- @return UI3DSceneView view
function ModelRendererInternal:getView()
    return self.javaObject:fromLua0('getView');
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param modelName string
--- @param shader LuaShader
---
--- @return ModelRendererInternal newInstance
function ModelRendererInternal:new(x, y, width, height, modelName, shader)
    --- @type ModelRendererInternal
    local o = ISUIElement:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.shader = shader;
    o.zoom = 16;
    o.modelName = modelName;
    o.alpha = 1.0;
    o.backgroundColor = { r = 0.25, g = 0.25, b = 0.25, a = 1 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.rotation = Vector3f.new(0.0, 0.0, 0.0);
    o.wantExtraMouseEvents = false;
    o.outline = false;
    o.isometric = true;

    return o;
end

--- @MARK: ResetShader

--- @class ResetShaderInternal : ISUIElement
--- @field shader LuaShader
--- @field outline boolean
--- @field parent ModelRenderer
local ResetShaderInternal = ISUIElement:derive('ResetShaderInternal');

function ResetShaderInternal:instantiate()
    self.javaObject = UIElement.new(self);
    self.javaObject:setX(0);
    self.javaObject:setY(0);
    self.javaObject:setHeight(1);
    self.javaObject:setWidth(1);
    self.javaObject:setAnchorLeft(false);
    self.javaObject:setAnchorRight(false);
    self.javaObject:setAnchorTop(false);
    self.javaObject:setAnchorBottom(false);
    self.javaObject:setWantKeyEvents(false);
    self.javaObject:setWantExtraMouseEvents(false);
    self.javaObject:setForceCursorVisible(false);
    self.javaObject:setConsumeMouseEvents(false);
    self:createChildren();
end

function ResetShaderInternal:render()
    self.shader:enable();
    self.shader:setUniforms({
        UI = 0,
        UIPosition = zero3f,
        UIRotation = zero3f,
        UIRotationPivot = zero3f,
        AlphaForce = 1.0,
        UIOutline = 0,
        UIOutlineValue = 1.0,
        UIColorForce = 0.0,
        UIColorForceValue = resetColorForceValue
    });
    self.shader:disable();
end

--- @param parent ModelRenderer
--- @param shader LuaShader
---
--- @return ResetShaderInternal newInstance
function ResetShaderInternal:new(parent, shader)
    --- @type ResetShaderInternal
    local o = ISUIElement:new(0, 0, 1, 1);
    setmetatable(o, self);
    self.__index = self;
    o.shader = shader;
    o.outline = false;
    o.wantExtraMouseEvents = false;
    o.parent = parent;
    return o;
end

--- @MARK: ModelRenderer

--- @class ModelRenderer : ISUIElement
--- @field velocityMax number
--- @field velocityThreshold number
--- @field velocityThresholdMultiplier number
--- @field position Vector3f
--- @field zoomable boolean
--- @field zoom number
--- @field zoomMax number
--- @field zoomMin number
--- @field orientation ModelOrientation
--- @field __internal ModelRendererInternal The outline pass.
--- @field __internal2 ModelRendererInternal The diffuse pass.
--- @field __internal3 ResetShaderInternal The pass that resets the shader.
--- @field alpha number
ModelRenderer = ISUIElement:derive('ModelRenderer');

function ModelRenderer:updateVelocityFloat(value)
    -- Clamp.
    if value > self.velocityMax then
        value = self.velocityMax;
    elseif value < -self.velocityMax then
        value = -self.velocityMax;
    end
    -- Don't slow down if the user is pulling on the model.
    if self.mouseDown then return value end
    -- Slowdown
    if value > self.velocityThreshold then
        value = value * self.velocityThresholdMultiplier;
        if value < self.velocityThreshold then value = self.velocityThreshold end
    elseif value < -self.velocityThreshold then
        value = value * self.velocityThresholdMultiplier;
        if value > -self.velocityThreshold then value = -self.velocityThreshold end
    end
    return value;
end

function ModelRenderer:updateVelocity()
    local velocity = self.velocity;
    local vx, vy, vz = velocity:x(), velocity:y(), velocity:z();
    vx = self:updateVelocityFloat(vx);
    vy = self:updateVelocityFloat(vy);
    vz = self:updateVelocityFloat(vz);
    self.velocity = velocity:set(vx, vy, vz);
    self.__internal.velocity = self.velocity;
    self.__internal2.velocity = self.velocity;
end

function ModelRenderer:updateAlpha()
    local hoverLerp;
    if self.hover then
        self.hoverLerp = 1.0;
        hoverLerp = 1.0;
    else
        if self.hoverLerp > 0 then
            self.hoverLerp = self.hoverLerp - 0.1;
            if self.hoverLerp < 0 then self.hoverLerp = 0 end;
        end
        hoverLerp = UIUtils.easeOutQuad(self.hoverLerp);
    end
    self.__internal.alpha = Math.min(self.alpha * hoverLerp, 0.66);
    self.__internal2.alpha = self.alpha;
end

function ModelRenderer:updateZoom()
    self.__internal.zoom = self.zoom;
    self.__internal2.zoom = self.zoom;
end

function ModelRenderer:updateTick()
    self:updateVelocity();
    self:updateAlpha();
    self:updateZoom();
end

function ModelRenderer:applyMouseVelocity()
    local mx = getMouseX();
    local distX = mx - self.down.x;
    self.velocity = self.velocity:set(
        self.velocity:x(),
        self.velocity:y() + (distX / 48.0),
        self.velocity:z()
    );
end

function ModelRenderer:onMouseMove()
    self.hover = true;
    if self.mouseDown then
        self:applyMouseVelocity();
    end
end

function ModelRenderer:onMouseMoveOutside()
    if self.mouseDown then
        self:applyMouseVelocity();
    else
        self.hover = false;
    end
end

function ModelRenderer:onMouseDown()
    self.mouseDown = true;
    self.down = {
        x = getMouseX(),
        y = getMouseY()
    };
end

function ModelRenderer:onMouseUp()
    self.mouseDown = false;
end

function ModelRenderer:onMouseUpOutside()
    self.mouseDown = false;
end

function ModelRenderer:onMouseWheel(del)
    if not self.zoomable then return end
    self.zoom = self.zoom - del;
    if self.zoom > self.zoomMax then
        self.zoom = self.zoomMax;
    elseif self.zoom < self.zoomMin then
        self.zoom = self.zoomMin;
    end
    return true;
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param modelName string
---
--- @return ModelRenderer newInstance
function ModelRenderer:new(x, y, width, height, modelName)
    --- @type ModelRenderer
    local o = ISUIElement:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.zoomable = true;
    o.zoom = 16;
    o.zoomMin = 1;
    o.zoomMax = 20;
    o.alpha = 1.0;
    o.velocity = Vector3f.new(0.0, 1.0, 0.0);
    o.velocityThreshold = 1.0;
    o.velocityThresholdMultiplier = 0.96;
    o.velocityMax = 20.0;
    o.hover = false;
    o.hoverLerp = 0.0;

    o.orientation = ModelOrientation[modelName] or ModelOrientation.default;
    o.zoom = o.orientation.zoom;

    local modelScript = getScriptManager():getModelScript(modelName);
    local model = loadZomboidModel(
        modelScript:getName(),
        modelScript:getMeshName(),
        modelScript:getTextureName(),
        modelScript:getShaderName(),
        modelScript:isStatic()
    );

    local shader = Reflect.getJavaFieldValue(model, 'Effect');
    local shaderName = Reflect.getJavaFieldValue(shader, 'name');

    local luaShader = ShadeHammer.shaders[shaderName];
    if not luaShader then
        luaShader = LuaShader:new(shader, shaderName);
        ShadeHammer.shaders[shaderName] = luaShader;
    end

    o.__internal = ModelRendererInternal:new(0, 0, width, height, modelName, luaShader);
    o.__internal.outline = true;
    o.__internal.orientation = o.orientation;
    o.__internal:backMost();
    o.__internal2 = ModelRendererInternal:new(0, 0, width, height, modelName, luaShader);
    o.__internal2.orientation = o.orientation;
    o.__internal3 = ResetShaderInternal:new(o, luaShader);

    o:addChild(o.__internal);
    o:addChild(o.__internal2);
    o:addChild(o.__internal3);

    return o;
end

return ModelRenderer;
