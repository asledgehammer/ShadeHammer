local class = require 'asledgehammer/util/class';

--- @class SHRenderContext
--- 
--- @field top number
--- @field left number
--- @field bottom number
--- @field right number
--- @field width number
--- @field height number
local SHRenderContext = class(
    function(o)
        o.top = 0;
        o.left = 0;
        o.bottom = 0;
        o.right = 0;
        o.width = 0;
        o.height = 0;
    end
)

-- TODO: Write calc methods.

return SHRenderContext;
