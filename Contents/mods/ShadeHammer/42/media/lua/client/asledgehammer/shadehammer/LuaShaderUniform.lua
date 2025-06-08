require 'ISBaseObject';

local renderer = getRenderer();

--- @alias ShaderUniformType 'integer'|'float'|'vec2'|'vec3'|'vec4'|'sampler2D' The available uniform types that Project Zomboid's SpriteRenderer API supports.
--- @alias LuaVector2f {x: number, y: number}
--- @alias LuaVector3f {x: number, y: number, z: number}
--- @alias LuaVector4f {x: number, y: number, z: number, w: number}

--- @class LuaShaderUniform
--- @field shader LuaShader
--- @field name string
--- @field DIFFUSE_TEXTURE_SLOT number
--- @field DEPTH_TEXTURE_SLOT number
--- @field loc number
--- @field debug boolean
--- @field __type ShaderUniformType
--- @field __index LuaShaderUniform
LuaShaderUniform = ISBaseObject:derive('LuaShaderUniform');

LuaShaderUniform.DIFFUSE_TEXTURE_SLOT = 0;
LuaShaderUniform.DEPTH_TEXTURE_SLOT = 1;

--- @param arg1 any
---
--- @return string message
function LuaShaderUniform:createUnknownArg1ErrorMessage(arg1)
    return string.format(
        'arg1 is an unknown type for shader uniform %s %s.%s (type = %s, value = %s)',
        self.__type,
        self.shader.name,
        self.name,
        type(arg1),
        tostring(arg1)
    );
end

--- @param name string The name of the parameter.
---
--- @return string message
function LuaShaderUniform:createNilArgErrorMessage(name)
    return string.format(
        '%s is nil for shader uniform %s %s.%s',
        name,
        self.__type,
        self.shader.name,
        self.name
    );
end

--- @param arg any
--- @param name string
--- @param expectedType string
---
--- @return string message
function LuaShaderUniform:createArgTypeErrorMessage(arg, name, expectedType)
    return string.format(
        '%s is not of type %s for shader uniform %s %s.%s. {type = %s, value = %s}',
        name,
        expectedType,
        self.__type,
        self.shader.name,
        self.name,
        tostring(arg)
    );
end

--- @param table LuaVector2f
---
--- @return string message
function LuaShaderUniform:create2fTableErrorMessage(table)
    return string.format(
        'x or y is nil for shader uniform %s %s.%s {x = %.2f, y = %.2f}',
        self.__type,
        self.shader.name,
        self.name,
        table.x, table.y
    );
end

--- @param array number[]
---
--- @return string message
function LuaShaderUniform:create2fArrayErrorMessage(array)
    return string.format(
        'x or y is nil for shader uniform %s %s.%s [%.2f, %.2f]',
        self.__type,
        self.shader.name,
        self.name,
        array[1], array[2]
    );
end

--- @param table LuaVector3f
---
--- @return string message
function LuaShaderUniform:create3fTableErrorMessage(table)
    return string.format(
        'x, y, or z is nil for shader uniform %s %s.%s {x = %.2f, y = %.2f, z = %.2f}',
        self.__type,
        self.shader.name,
        self.name,
        table.x, table.y, table.z
    );
end

--- @param array number[]
---
--- @return string message
function LuaShaderUniform:create3fArrayErrorMessage(array)
    return string.format(
        'x, y, or z is nil for shader uniform %s %s.%s [%.2f, %.2f, %.2f]',
        self.__type,
        self.shader.name,
        self.name,
        array[1], array[2], array[3]
    );
end

--- @param table LuaVector4f
---
--- @return string message
function LuaShaderUniform:create4fTableErrorMessage(table)
    return string.format(
        'x, y, z, or w is nil for shader uniform %s %s.%s {x = %.2f, y = %.2f, z = %.2f, w = %.2f}',
        self.__type,
        self.shader.name,
        self.name,
        table.x, table.y, table.z, table.w
    );
end

--- @param array number[]
---
--- @return string message
function LuaShaderUniform:create4fArrayErrorMessage(array)
    return string.format(
        'x, y, z, or w is nil for shader uniform %s %s.%s [%.2f, %.2f, %.2f, %.2f]',
        self.__type,
        self.shader.name,
        self.name,
        array[1], array[2], array[3], array[4]
    );
end

function LuaShaderUniform:createNotUniformTypeErrorMessage(usedType)
    return string.format(
        'shader uniform %s %s.%s cannot be assigned using %s.',
        self.__type,
        self.shader.name,
        self.name,
        usedType
    );
end

--- @param color SHColor
function LuaShaderUniform:setRGBA(color)
    if self.__type == 'vec4' then
        self:set4f(color.r, color.g, color.b, color.a);
    elseif self.__type == 'vec3' then
        self:set3f(color.r, color.g, color.b);
    end
end

--- @param flag boolean | number
function LuaShaderUniform:setBoolean(flag)
    local temp = 0;
    if flag then temp = 1 end
    self:set1i(temp);
end

--- @param arg1 Texture | number
--- @param arg2? number
function LuaShaderUniform:setTexture(arg1, arg2)
    --- @type number, number
    local textureID, textureSlot;
    if type(arg1) == 'number' then
        textureID = arg1;
    elseif instanceof(arg1, 'Texture') then
        --- @cast arg1 Texture
        textureID = arg1:getID();
    else
        error(self:createUnknownArg1ErrorMessage(arg1), 2);
    end

    -- If the texture-slot argument is provided, make sure it's a valid number.
    if arg2 ~= nil and type(arg2) ~= 'number' then
        error(self:createArgTypeErrorMessage(arg2, 'arg2', 'number'), 2);
    end
    textureSlot = arg2 or LuaShaderUniform.DIFFUSE_TEXTURE_SLOT;

    -- Call internal API to bind texture ID and set the texture slot of the uniform.
    renderer:glBind(textureID);
    renderer:ShaderUpdate1i(self.shader.id, self.loc, textureSlot);
end

--- @param arg1 number
function LuaShaderUniform:set1i(arg1)
    if self.__type ~= 'integer' and self.__type ~= 'sampler2D' then
        error(self:createNotUniformTypeErrorMessage('sampler2D|int'), 2);
    end

    -- Check if the argument is nil.
    if arg1 == nil then
        error(self:createNilArgErrorMessage('arg1'), 2);
    end

    -- Make sure the argument is a number.
    if type(arg1) ~= 'number' then
        error(self:createArgTypeErrorMessage(arg, 'arg1', 'number'), 2);
    end

    -- Call internal API to set value.
    renderer:ShaderUpdate1i(self.shader.id, self.loc, arg1);
    if self.debug then
        print(string.format('%s => %s.ShaderUpdate1i(value=%i)',
            self.shader.name,
            self.name,
            arg1
        ));
    end
end

--- @param arg1 number
function LuaShaderUniform:set1f(arg1)
    -- Check if the argument is nil.
    if arg1 == nil then
        error(self:createNilArgErrorMessage('arg1'), 2);
    end

    if self.__type ~= 'float' then
        error(self:createNotUniformTypeErrorMessage('float'), 2);
    end

    -- Make sure the argument is a number.
    if type(arg1) ~= 'number' then
        error(self:createArgTypeErrorMessage(arg, 'arg1', 'number'), 2);
    end

    -- Call internal API to set value.
    renderer:ShaderUpdate1f(self.shader.id, self.loc, arg1);
    if self.debug then
        print(string.format('%s => %s.ShaderUpdate1f(value=%.2f)',
            self.shader.name,
            self.name,
            arg1
        ));
    end
end

--- @param arg1 LuaVector4f | LuaVector3f | LuaVector2f | number[] | number
--- @param arg2? number
function LuaShaderUniform:set2f(arg1, arg2)
    -- Check if first argument is nil.
    if arg1 == nil then
        error(self:createNilArgErrorMessage('arg1'), 2);
    end

    if self.__type ~= 'vec2' then
        error(self:createNotUniformTypeErrorMessage('vec2'), 2);
    end

    --- @type number, number
    local x, y;

    if type(arg1) == 'number' then
        if arg2 == nil then
            error(self:createNilArgErrorMessage('arg2'), 2);
        end

        x, y = arg1, arg2;

        -- Make sure that all values are numbers.
        if type(x) ~= 'number' then
            error(self:createArgTypeErrorMessage(x, 'arg1', 'number'), 2);
        elseif type(y) ~= 'number' then
            error(self:createArgTypeErrorMessage(y, 'arg2', 'number'), 2);
        end
    elseif type(arg1) == 'table' then
        --- @cast arg1 table
        if arg1.x then
            --- @cast arg1 LuaVector2f
            x, y = arg1.x, arg1.y;

            -- Check if any value is nil.
            if x == nil or y == nil then
                error(self:create2fTableErrorMessage(arg1), 2);
            end

            -- Make sure that all values are numbers.
            if type(x) ~= 'number' then
                error(self:createArgTypeErrorMessage(x, 'arg1.x', 'number'), 2);
            elseif type(y) ~= 'number' then
                error(self:createArgTypeErrorMessage(y, 'arg1.y', 'number'), 2);
            end
        else
            x, y = arg1[1], arg1[2];

            -- Check if any value is nil.
            if x == nil or y == nil then
                error(self:create2fArrayErrorMessage(arg1), 2);
            end

            -- Make sure that all values are numbers.
            if type(x) ~= 'number' then
                error(self:createArgTypeErrorMessage(x, 'arg1[1]', 'number'), 2);
            elseif type(y) ~= 'number' then
                error(self:createArgTypeErrorMessage(y, 'arg1[2]', 'number'), 2);
            end
        end
    else
        error(self:createUnknownArg1ErrorMessage(arg1), 2);
    end

    -- Call internal API to set value.
    renderer:ShaderUpdate2f(self.shader.id, self.loc, x, y);
    if self.debug then
        print(string.format('%s => %s.ShaderUpdate2f(x=%.2f, y=%.2f)',
            self.shader.name,
            self.name,
            x, y
        ));
    end
end

--- @param arg1 LuaVector4f | LuaVector3f | number[] | number
--- @param arg2? number
--- @param arg3? number
function LuaShaderUniform:set3f(arg1, arg2, arg3)
    -- Check if first argument is nil.
    if arg1 == nil then
        error(self:createNilArgErrorMessage('arg1'), 2);
    end

    if self.__type ~= 'vec3' then
        error(self:createNotUniformTypeErrorMessage('vec2'), 2);
    end

    --- @type number, number, number
    local x, y, z;

    if type(arg1) == 'number' then
        if arg2 == nil then
            error(self:createNilArgErrorMessage('arg2'), 2);
        elseif arg3 == nil then
            error(self:createNilArgErrorMessage('arg3'), 2);
        end

        x, y, z = arg1, arg2, arg3;

        -- Make sure that all values are numbers.
        if type(x) ~= 'number' then
            error(self:createArgTypeErrorMessage(x, 'arg1', 'number'), 2);
        elseif type(y) ~= 'number' then
            error(self:createArgTypeErrorMessage(y, 'arg2', 'number'), 2);
        elseif type(z) ~= 'number' then
            error(self:createArgTypeErrorMessage(z, 'arg3', 'number'), 2);
        end
    elseif type(arg1) == 'table' then
        --- @cast arg1 table
        if arg1.x then
            --- @cast arg1 LuaVector3f
            x, y, z = arg1.x, arg1.y, arg1.z;

            -- Check if any value is nil.
            if x == nil or y == nil or z == nil then
                error(self:create3fTableErrorMessage(arg1), 2);
            end

            -- Make sure that all values are numbers.
            if type(x) ~= 'number' then
                error(self:createArgTypeErrorMessage(x, 'arg1.x', 'number'), 2);
            elseif type(y) ~= 'number' then
                error(self:createArgTypeErrorMessage(y, 'arg1.y', 'number'), 2);
            elseif type(z) ~= 'number' then
                error(self:createArgTypeErrorMessage(z, 'arg1.z', 'number'), 2);
            end
        else
            x, y, z = arg1[1], arg1[2], arg1[3];

            -- Check if any value is nil.
            if x == nil or y == nil or z == nil then
                error(self:create3fArrayErrorMessage(arg1), 2);
            end

            -- Make sure that all values are numbers.
            if type(x) ~= 'number' then
                error(self:createArgTypeErrorMessage(x, 'arg1[1]', 'number'), 2);
            elseif type(y) ~= 'number' then
                error(self:createArgTypeErrorMessage(y, 'arg1[2]', 'number'), 2);
            elseif type(z) ~= 'number' then
                error(self:createArgTypeErrorMessage(z, 'arg1[3]', 'number'), 2);
            end
        end
    else
        error(self:createUnknownArg1ErrorMessage(arg1), 2);
    end

    -- Call internal API to set value.
    renderer:ShaderUpdate3f(self.shader.id, self.loc, x, y, z);
    if self.debug then
        print(string.format('%s => %s.ShaderUpdate3f(x=%.2f, y=%.2f, z=%.2f)',
            self.shader.name,
            self.name,
            x, y, z
        ));
    end
end

--- @param arg1 LuaVector4f | number[] | number
--- @param arg2? number
--- @param arg3? number
--- @param arg4? number
function LuaShaderUniform:set4f(arg1, arg2, arg3, arg4)
    -- Check if first argument is nil.
    if arg1 == nil then
        error(self:createNilArgErrorMessage('arg1'), 2);
    end

    if self.__type ~= 'vec4' then
        error(self:createNotUniformTypeErrorMessage('vec4'), 2);
    end

    --- @type number, number, number, number
    local x, y, z, w;

    if type(arg1) == 'number' then
        if arg2 == nil then
            error(self:createNilArgErrorMessage('arg2'), 2);
        elseif arg3 == nil then
            error(self:createNilArgErrorMessage('arg3'), 2);
        elseif arg4 == nil then
            error(self:createNilArgErrorMessage('arg4'), 2);
        end

        x, y, z, w = arg1, arg2, arg3, arg4;

        -- Make sure that all values are numbers.
        if type(x) ~= 'number' then
            error(self:createArgTypeErrorMessage(x, 'arg1', 'number'), 2);
        elseif type(y) ~= 'number' then
            error(self:createArgTypeErrorMessage(y, 'arg2', 'number'), 2);
        elseif type(z) ~= 'number' then
            error(self:createArgTypeErrorMessage(z, 'arg3', 'number'), 2);
        elseif type(w) ~= 'number' then
            error(self:createArgTypeErrorMessage(w, 'arg4', 'number'), 2);
        end
    elseif type(arg1) == 'table' then
        --- @cast arg1 table
        if arg1.x then
            --- @cast arg1 LuaVector4f
            x, y, z, w = arg1.x, arg1.y, arg1.z, arg1.w;

            -- Check if any value is nil.
            if x == nil or y == nil or z == nil or w == nil then
                error(self:create4fTableErrorMessage(arg1), 2);
            end

            -- Make sure that all values are numbers.
            if type(x) ~= 'number' then
                error(self:createArgTypeErrorMessage(x, 'arg1.x', 'number'), 2);
            elseif type(y) ~= 'number' then
                error(self:createArgTypeErrorMessage(y, 'arg1.y', 'number'), 2);
            elseif type(z) ~= 'number' then
                error(self:createArgTypeErrorMessage(z, 'arg1.z', 'number'), 2);
            elseif type(w) ~= 'number' then
                error(self:createArgTypeErrorMessage(w, 'arg1.w', 'number'), 2);
            end
        else
            x, y, z, w = arg1[1], arg1[2], arg1[3], arg1[4];

            -- Check if any value is nil.
            if x == nil or y == nil or z == nil or w == nil then
                error(self:create4fArrayErrorMessage(arg1), 2);
            end

            -- Make sure that all values are numbers.
            if type(x) ~= 'number' then
                error(self:createArgTypeErrorMessage(x, 'arg1[1]', 'number'), 2);
            elseif type(y) ~= 'number' then
                error(self:createArgTypeErrorMessage(y, 'arg1[2]', 'number'), 2);
            elseif type(z) ~= 'number' then
                error(self:createArgTypeErrorMessage(z, 'arg1[3]', 'number'), 2);
            elseif type(w) ~= 'number' then
                error(self:createArgTypeErrorMessage(w, 'arg1[4]', 'number'), 2);
            end
        end
    else
        error(self:createUnknownArg1ErrorMessage(arg1), 2);
    end

    -- Call internal API to set value.
    renderer:ShaderUpdate4f(self.shader.id, self.loc, x, y, z, w);
    if self.debug then
        print(string.format('%s => %s.ShaderUpdate4f(x=%.2f, y=%.2f, z=%.2f, w=%.2f)',
            self.shader.name,
            self.name,
            x, y, z, w
        ));
    end
end

--- @param arg1 LuaVector4f | LuaVector3f | LuaVector2f | Texture | number[] | number
--- @param arg2? number
--- @param arg3? number
--- @param arg4? number
function LuaShaderUniform:set(arg1, arg2, arg3, arg4)
    -- print(string.format('%s.set(name=%s, type=%s, arg1=%s, arg2=%s, arg3=%s, arg4=%s)', self.shader.name, self.name,
    --     self.__type, tostring(arg1), tostring(arg2), tostring(arg3), tostring(arg4)));

    if arg1 == nil then
        error(self:createNilArgErrorMessage('arg1'), 2);
    end

    if self.__type == 'sampler2D' then
        self:setTexture(arg1, arg2);
    elseif self.__type == 'integer' then
        self:set1i(arg1);
    elseif self.__type == 'float' then
        self:set1f(arg1);
    elseif self.__type == 'vec2' then
        self:set2f(arg1, arg2);
    elseif self.__type == 'vec3' then
        self:set3f(arg1, arg2, arg3);
    elseif self.__type == 'vec4' then
        self:set4f(arg1, arg2, arg3, arg4);
    end
end

function LuaShaderUniform:__tostring()
    return tostring(self.__type) ..
        ' ' .. tostring(self.shader.name) .. '.' .. tostring(self.name) .. ' (location = ' .. tostring(self.loc) .. ')';
end

--- @param shader LuaShader
--- @param name string
--- @param loc number
--- @param type ShaderUniformType
---
--- @return LuaShaderUniform
function LuaShaderUniform:new(shader, name, loc, type)
    local o = ISBaseObject:new();
    setmetatable(o, self);
    self.__index = self;
    --- @cast o LuaShaderUniform
    o.shader = shader;
    o.name = name;
    o.loc = loc;
    o.__type = type;
    o.debug = false;
    return o;
end
