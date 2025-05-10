local Reflect = require 'Reflect';

local ShadeHammer = {};

local function info(message)
    print('ShadeHammer :: ' .. tostring(message));
end

ShadeHammer.PATH_WEATHER_SHADER = 'zombie.iso.weather.WeatherShader';
ShadeHammer.ScreenShader = nil;

--- @type HashMap<string, any>
ShadeHammer.mapOpenGLShaders = nil;

--- Returns the instance of a `zombie.core.opengl.Shader`.
---
--- @param path string E.G: `zombie.iso.weather.WeatherShader`
---
--- @return any instance The object instance of the shader. If `nil`, the shader is not loaded.
function ShadeHammer.getOpenGLShader(path)
    local values = ArrayList.new(ShadeHammer.mapOpenGLShaders:values());
    for i = 0, values:size() - 1 do
        local value = values:get(i);
        print(tostring(i) .. ': ' .. tostring(value))
        if value and string.find(tostring(value), path) then
            return value;
        end
    end
    info('Shader not loaded: ' .. path);
    return nil;
end

--- Returns the ID of a `zombie.core.opengl.Shader`.
---
--- @param path string E.G: `zombie.iso.weather.WeatherShader`
---
--- @return number ID The OpenGL context identity of the shader. If 0, the shader is not loaded and shouldn't be called.
function ShadeHammer.getOpenGLShaderID(path)
    local raw = tostring(ShadeHammer.mapOpenGLShaders);
    local start, stop = string.find(raw, '%d*=' .. tostring(path) .. '@');

    -- Shader is not loaded.
    if not start then
        info('Shader not loaded: ' .. path);
        return 0;
    end

    local sub = string.sub(raw, start, stop);
    start, stop = string.find(sub, '=', 1, true);
    sub = string.sub(sub, 1, start - 1);
    return tonumber(sub);
end

LuaEventManager.AddEvent('OnShaderMapLoaded');
-- Try to grab the shaders until it populates the IsoCell instance.
local attemptFetch;
attemptFetch = function()
    local shaders = Reflect.getJavaFieldValues(IsoCell.getInstance(), { 'm_floorRenderShader', 'm_wallRenderShader' });
    local m_floorRenderShader = shaders.m_floorRenderShader;
    local m_wallRenderShader = shaders.m_wallRenderShader;
    local entry = m_floorRenderShader or m_wallRenderShader;
    if not entry then return end
    ShadeHammer.mapOpenGLShaders = Reflect.getJavaFieldValue(entry, "ShaderMap");

    print("### SHADER MAP FETCHED ###");

    ShadeHammer.ScreenShader = {
        id = ShadeHammer.getOpenGLShaderID(ShadeHammer.PATH_WEATHER_SHADER),
        javaObject = ShadeHammer.getOpenGLShader(ShadeHammer.PATH_WEATHER_SHADER),
    };

    info('\n' ..
        'ScreenShader = {\n' ..
        '\tid = ' .. tostring(ShadeHammer.ScreenShader.id) .. ',\n' ..
        '\tjavaObject = ' .. tostring(ShadeHammer.ScreenShader.javaObject) .. ',\n' ..
        '}'
    );

    ShadeHammer.getOrLoadSkinnedShader('basicEffect');
    ShadeHammer.getOrLoadSkinnedShader('basicEffect_static');

    LuaEventManager.triggerEvent('OnShaderMapLoaded', ShadeHammer.mapOpenGLShaders);
    Events.OnTickEvenPaused.Remove(attemptFetch);
end;
Events.OnGameStart.Add(function()
    Events.OnTickEvenPaused.Add(attemptFetch);
end);

--- @type table<string, LuaShader>
ShadeHammer.shaders = {};

--- @param name string
function ShadeHammer.wrapSkinnedShader(name)
    local model = loadZomboidModel('Dummy_Shader_Model', 'Vehicles_Wheel', 'Vehicles/vehicle_wheel', name, false);
    local shader = Reflect.getJavaFieldValue(model, 'Effect');
    local shaderName = Reflect.getJavaFieldValue(shader, 'name');
    return LuaShader:new(shader, shaderName);
end

--- @param name string
---
--- @return LuaShader shader.
function ShadeHammer.getOrLoadSkinnedShader(name)
    if not ShadeHammer.shaders[name] then
        ShadeHammer.shaders[name] = ShadeHammer.wrapSkinnedShader(name);
    end
    return ShadeHammer.shaders[name];
end

--- Reloads shaders for debugging purposes only.
---
--- ! NOTE: If not in debug-mode, this function fails.
---
--- @param name string The name of the shader.
function ShadeHammer.reloadSkinnedShader(name)
    if not isDebugEnabled() then
        error('Cannot reload shader ' .. tostring(name) .. '. (Debug Mode not enabled)')
    end
    local shader = ShadeHammer.shaders[name];
    if not shader then
        print('WARNING: Shader not loaded or doesn\'t exist: ' .. tostring(name) .. '. Not reloading..');
    end
    shader:reload();
end

_G.reloadShader = ShadeHammer.reloadSkinnedShader;

Events.OnRenderTick.Add(function()
    for _, shader in pairs(ShadeHammer.shaders) do
        pcall(function() shader:update() end);
    end
end);

return ShadeHammer;
