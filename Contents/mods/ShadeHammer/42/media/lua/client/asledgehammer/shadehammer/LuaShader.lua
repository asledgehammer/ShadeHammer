require 'ISBaseObject';
require 'asledgehammer/shadehammer/ShaderUniform';

-- UTILS --
local Reflect = require 'Reflect';

-- CONSTANTS --
local core = getCore();
local renderer = getRenderer();
local cameras = Array.new(IsoCamera.cameras);
local camera0 = cameras:get(0);

--- @type LuaShader | nil
---
--- Keeps track of globally active shader.
local __enabled_shader = nil;

--- @class LuaShader: ISBaseObject
--- @field uniforms table<string, LuaShaderUniform>
--- @field __index LuaShader
--- @field javaObject any
--- @field program any
--- @field name string
--- @field id number
--- @field timer number
--- @field loaded boolean
--- @field valid boolean
--- @field enabled boolean
LuaShader = ISBaseObject:derive('LuaShader');

function LuaShader:load()
    self.loaded = false;
    self.program = Reflect.getJavaFieldValue(self.javaObject, 'm_shaderProgram');
    self.id = Reflect.getJavaFieldValue(self.program, 'm_shaderID');
    self.uniforms = {};

    --- @type HashMap<string, any>
    local uniforms = Reflect.getJavaFieldValue(self.program, 'uniformsByName');
    local u_keys = ArrayList.new(uniforms:keySet());
    for i = 0, u_keys:size() - 1 do
        local u_key = u_keys:get(i);
        local uJavaObject = uniforms:get(u_key);
        if uJavaObject ~= nil then
            local fields = Reflect.getJavaFieldValues(uJavaObject, { 'loc', 'type' });
            local type = 'integer'; -- 5124
            if fields.type == 35678 then
                type = 'sampler2D';
            elseif fields.type == 5126 then
                type = 'float';
            elseif fields.type == 35664 then
                type = 'vec2';
            elseif fields.type == 35665 then
                type = 'vec3';
            elseif fields.type == 35666 then
                type = 'vec4';
            end
            self.uniforms[u_key] = LuaShaderUniform:new(self, u_key, fields.loc, type);
        end
    end
    self.loaded = true;
    self.valid = self.id ~= 0;
    pcall(function() self:onLoad() end);
end

function LuaShader:reload()
    if not isDebugEnabled() then
        print('WARNING: Cannot recompile shader "' .. tostring(self.name) .. '". (Not in debug mode)');
        return;
    end

    --- @type any
    local compile = Reflect.getJavaMethod(self.javaObject, 'compileLater');
    if not compile then
        print('WARNING: Shader compileLater() method-patch not installed. Cannot reload shader "' ..
            tostring(self.name) .. '".');
        return;
    end

    -- Set as unloaded until recompiled.
    self.id = 0;
    self.valid = false;
    self.loaded = false;

    compile:setAccessible(true);
    compile:invoke(self.javaObject);
end

function LuaShader:update()
    if not self.loaded or not self.valid then return end

    local uniforms = self.uniforms;

    -- Update Screen.
    if uniforms.screenWidth then
        uniforms.screenWidth:set(core:getScreenWidth());
    end
    if uniforms.screenHeight then
        uniforms.screenHeight:set(core:getScreenHeight());
    end
    if uniforms.screenInfo then
        local fields = Reflect.getJavaFieldValues(camera0, { 'RightClickX', 'RightClickY' });
        uniforms.screenInfo:set(
            IsoCamera.getOffscreenWidth(0),
            IsoCamera.getOffscreenHeight(0),
            fields.RightClickX,
            fields.RightClickY
        );
    end

    -- Update timer.
    if uniforms.timer then
        self.timer = self.timer + 1;
        uniforms.timer:set(self.timer);
    end
    pcall(function() self:onUpdate() end);
end

function LuaShader:enable()
    if not self.valid or self.enabled then return end

    -- Disable active shader if called before or while not disabling it.
    if __enabled_shader ~= nil then
        __enabled_shader:disable();
        __enabled_shader = nil;
    end

    renderer:StartShader(self.id, 0);
    self.enabled = true;
    __enabled_shader = self;
    pcall(function() self:onEnable() end);
end

function LuaShader:disable()
    if not self.valid or not self.enabled then return end
    self.enabled = false;
    renderer:EndShader();
    __enabled_shader = nil;
    pcall(function() self:onDisable() end);
end

--- Shorthand safety function for setting uniform values. If the uniform doesn't exist, false is returned.
---
--- NOTE: If the uniform doesn't exist on the compiled shader, nothing will happen.
---
--- @param name string
--- @param arg1 LuaVector4f|Vector3f|LuaVector3f|Vector2f|LuaVector2f|Texture|number[]|number
--- @param arg2? number
--- @param arg3? number
--- @param arg4? number
---
--- @return boolean existsAndSet True if the uniform exists and is set.
function LuaShader:setUniform(name, arg1, arg2, arg3, arg4)
    if not self.valid or not self.enabled then return false end

    -- if self.name == 'ShadeHammer' then
    --     print(string.format('%s:setUniform(%s, %s %s %s %s)', self.name, name, tostring(arg1), tostring(arg2), tostring(arg3), tostring(arg4)));
    -- end
    if not self.uniforms[name] then return false end

    local uniform = self.uniforms[name];
    local result = pcall(function()
        uniform:set(arg1, arg2, arg3, arg4);
    end);

    return result;
end

function LuaShader:setUniforms(uniforms)
    if not self.valid or not self.enabled then return false end

    for name, values in pairs(uniforms) do
        local uniform = self.uniforms[name];
        if uniform ~= nil then
            if uniform.__type == 'integer' then
                self:setUniform(name, values);
            elseif uniform.__type == 'float' then
                self:setUniform(name, values);
            elseif uniform.__type == 'vec2' then
                if type(values) == 'table' then
                    if values.x ~= nil then
                        --- @cast values LuaVector2f
                        self:setUniform(name, values.x, values.y);
                    else
                        self:setUniform(name, values[1], values[2]);
                    end
                elseif type(values) == 'userdata' then
                    self:setUniform(name, values:x(), values:y());
                else
                    self:setUniform(name, values);
                end
            elseif uniform.__type == 'vec3' then
                if type(values) == 'table' then
                    if values.x ~= nil then
                        --- @cast values LuaVector3f
                        self:setUniform(name, values.x, values.y, values.z);
                    elseif values.x ~= nil then
                        --- @cast values SHColor
                        self:setUniform(name, values.r, values.g, values.b);
                    else
                        self:setUniform(name, values[1], values[2], values[3]);
                    end
                elseif type(values) == 'userdata' then
                    self:setUniform(name, values:x(), values:y(), values:z());
                else
                    self:setUniform(name, values);
                end
            elseif uniform.__type == 'vec4' then
                if type(values) == 'table' then
                    if values.x ~= nil then
                        --- @cast values LuaVector4f
                        self:setUniform(name, values.x, values.y, values.z, values.w);
                    elseif values.x ~= nil then
                        --- @cast values SHColor
                        self:setUniform(name, values.r, values.g, values.b, values.a);
                    else
                        self:setUniform(name, values[1], values[2], values[3], values[4]);
                    end
                elseif type(values) == 'userdata' then
                    self:setUniform(name, values:x(), values:y(), values:z(), values:w());
                else
                    self:setUniform(name, values);
                end
            elseif uniform.__type == 'sampler2D' then
                if type(values) == 'number' then
                    self:setUniform(name, values, 0);
                elseif instanceof(values, 'Texture') then
                    self:setUniform(name, values, 0);
                elseif type(values) == 'table' then
                    --- @type number
                    ---
                    --- Expects a integer for the value.
                    local textureID = values.id;
                    --- @type number|nil
                    ---
                    --- Expects a integer for the value.
                    local textureSlot = values.slot;

                    self:setUniform(name, textureID, textureSlot);
                end
            end
        end
    end
end

--- @param mat mat4
function LuaShader:applyTransform(mat)
    if not self.valid or not self.enabled then return false end

    local t1 = self.uniforms.transform1;
    local t2 = self.uniforms.transform2;
    local t3 = self.uniforms.transform3;
    local t4 = self.uniforms.transform4;
    if t1 and t2 and t3 and t4 then
        t1:set4f(mat.m00, mat.m01, mat.m02, mat.m03);
        t2:set4f(mat.m10, mat.m11, mat.m12, mat.m13);
        t3:set4f(mat.m20, mat.m21, mat.m22, mat.m23);
        t4:set4f(mat.m30, mat.m31, mat.m32, mat.m33);
    end
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
function LuaShader:applyDimension(x, y, width, height)
    if not self.valid or not self.enabled then return false end

    if self.uniforms.dim then
        self.uniforms.dim:set4f(x, y, width, height);
    end
end

--- @param javaObject any
--- @param name string
---
--- @return LuaShader
function LuaShader:new(javaObject, name)
    local o = ISBaseObject:new();
    setmetatable(o, self);
    self.__index = self;

    --- @cast o LuaShader
    o.javaObject = javaObject;
    o.name = name;
    o.uniforms = {};
    o.enabled = false;
    o.loaded = false;
    o.valid = false;
    o.timer = 0;

    o:load();

    -- (Requires Java patch to execute)
    if isDebugEnabled() then
        LuaEventManager.AddEvent('OnShaderCompile');
        Events.OnShaderCompile.Add(
        --- @param shaderName string
            function(shaderName)
                if shaderName == o.name then o:load() end
            end);
    end
    return o;
end

function LuaShader:__tostring()
    local s = 'LuaShader "%s" {\n%s\n}';
    local b = '';
    for k, v in pairs(self.uniforms) do
        if b == '' then
            b = b .. string.format('\t%s: %s (location = %i)', k, v.__type, v.loc);
        else
            b = b .. string.format(',\n\t%s: %s (location = %i)', k, v.__type, v.loc);
        end
    end
    return string.format(s, self.name, b);
end

function LuaShader:onLoad() end

function LuaShader:onEnable() end

function LuaShader:onDisable() end

function LuaShader:onUpdate() end

return LuaShader;
