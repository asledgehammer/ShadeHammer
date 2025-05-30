local class = require 'asledgehammer/util/class';

--- @class RenderStyle
--- @field rules table<string, string>
local RenderStyle = class(
--- (Constructor)
---
--- @param o RenderStyle
    function(o)
        o.rules = {};
    end
);

--- @param property string
--- 
--- @return boolean
function RenderStyle:has(property)
    return self.rules[property] ~= nil;
end

--- @param property string
--- 
--- @return string
function RenderStyle:get(property)
    return self.rules[property];
end

--- @param property string
--- @param value string
function RenderStyle:set(property, value)
    self.rules[property] = value;
end

--- @param property string
function RenderStyle:unset(property)
    self.rules[property] = nil;
end

return RenderStyle;
