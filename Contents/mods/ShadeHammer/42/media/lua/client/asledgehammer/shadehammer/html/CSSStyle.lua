local class = require 'asledgehammer/util/class';

--- @class CSSStyle
--- @field rules table<string, string>
local CSSStyle = class(
--- (Constructor)
---
--- @param o CSSStyle
--- @param selector CSSSelector
    function(o, selector)
        o.rules = {};
        o.selector = selector;
    end
);

--- @param property string
--- 
--- @return boolean
function CSSStyle:has(property)
    return self.rules[property] ~= nil;
end

--- @param property string
--- 
--- @return string
function CSSStyle:get(property)
    return self.rules[property];
end

--- @param property string
--- @param value string
function CSSStyle:set(property, value)
    self.rules[property] = value;
end

--- @param property string
function CSSStyle:unset(property)
    self.rules[property] = nil;
end

return CSSStyle;
