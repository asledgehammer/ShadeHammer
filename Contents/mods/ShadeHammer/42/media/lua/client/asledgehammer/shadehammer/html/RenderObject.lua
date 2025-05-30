local class = require 'asledgehammer/util/class';

--- @class RenderObject
--- @field uuid string
--- @field node SHElement
--- @field init fun(o: RenderObject, node: SHElement)
local RenderObject = class(
--- (Constructor)
---
--- @param o RenderObject
--- @param node SHElement
    function(o, node)
        o.uuid = getRandomUUID();
        o.node = node;
    end
);

--- @param node SHElement
--- @param style RenderStyle
function RenderObject.createObject(node, style)
    if style.display == 'none' then
        
    end
end

--- @class RenderInline: RenderObject
local RenderInline = class(
    RenderObject,
    --- (Constructor)
    --- 
    --- @param o RenderInline
    --- @param node SHElement
    function(o, node)
        RenderObject.init(o, node);
    end
);

--- @class RenderBlock: RenderObject
local RenderBlock = class(
    RenderObject,
    --- (Constructor)
    ---
    --- @param o RenderBlock
    --- @param node SHElement
    function(o, node)
        RenderObject.init(o, node);
    end
);

--- @class RenderInlineBlock: RenderObject
local RenderInlineBlock = class(
    RenderObject,
    --- (Constructor)
    ---
    --- @param o RenderInlineBlock
    --- @param node SHElement
    function(o, node)
        RenderObject.init(o, node);
    end
);

return {
    RenderObject = RenderObject,
    RenderInline = RenderInline,
    RenderBlock = RenderBlock,
    RenderInlineBlock = RenderInlineBlock,
};
