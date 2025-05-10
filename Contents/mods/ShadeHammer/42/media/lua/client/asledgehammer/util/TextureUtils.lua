local Reflect = require 'Reflect';
local core = getCore();

--- Returns the current FBOTexture object used to render the game. (One frame behind)
---
--- NOTE: FBOTextures are supposed to be upside-down. Render with all-points or sub-texturize before use.
---
--- @return Texture texture The FBOTexture instance.
local function getFBOTexture()
    local buffer = Reflect.getJavaFieldValue(core, 'OffscreenBuffer');
    local current = Reflect.getJavaFieldValue(buffer, 'Current');
    return Reflect.getJavaFieldValue(current, 'texture');
end

--- Returns the current FBOTexture object ID used to render the game. (One frame behind)
---
--- NOTE: FBOTextures are supposed to be upside-down. Render with all-points or sub-texturize before use.
---
--- @return number ID The OpenGL Texture ID context of the FBOTexture object used to render the game.
local function getFBOTextureID()
    local core = getCore();
    local buffer = Reflect.getJavaFieldValue(core, 'OffscreenBuffer');
    local current = Reflect.getJavaFieldValue(buffer, 'Current');
    return Reflect.getJavaFieldValue(current, 'id');
end

return {
    getFBOTexture = getFBOTexture,
    getFBOTextureID = getFBOTextureID,
};
