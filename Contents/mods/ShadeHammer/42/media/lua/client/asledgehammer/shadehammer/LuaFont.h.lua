--- @meta

---[[
--- @author asledgehammer, JabDoesThings 2025
---]]

--- @class LuaFontDefinition: ObjectDefinition
local LuaFontDefinition = {};

--- @param name string
--- @param file string
function LuaFontDefinition.new(name, file) end

--- @class LuaFont: Object
local LuaFont = {};

--- @return string
function LuaFont:getName() end

--- @return string
function LuaFont:getFile() end
