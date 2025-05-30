local class = require 'asledgehammer/util/class';

--- @class CSSSelector
--- @field text string
local CSSSelector = class(
--- (Constructor)
--- 
--- @param o CSSSelector
--- @param text string
    function(o, text)
        o.text = text:trim();
    end
);

return CSSSelector;