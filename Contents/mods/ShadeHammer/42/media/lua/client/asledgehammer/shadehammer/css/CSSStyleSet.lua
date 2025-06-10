local class = require 'asledgehammer/util/class';
local CSSStyleContext = require 'asledgehammer/shadehammer/css/CSSStyleContext';

--- @class CSSStyleSet
---
--- @field dirtyFlags table<string,boolean>
--- @field selectors CSSSelector[]
---
--- [Position Rules]
--- @field top string?
--- @field right string?
--- @field bottom string?
--- @field left string?
---
--- [Width Rules]
--- @field width string?
--- @field widthMin string?
--- @field widthMax string?
---
--- [Height Rules]
--- @field height string?
--- @field heightMin string?
--- @field heightMax string?
---
--- [Padding Rules]
--- @field padding string?
--- @field paddingTop string?
--- @field paddingRight string?
--- @field paddingBottom string?
--- @field paddingLeft string?
---
--- [Margin Rules]
--- @field margin string?
--- @field marginTop string?
--- @field marginRight string?
--- @field marginBottom string?
--- @field marginLeft string?
---
--- @field readOnly boolean
---
--- [Display Rule]
--- @field display string?
---
--- @field context CSSStyleContext
local CSSStyleSet = class(
--- @param o CSSStyleSet
--- @param rules table<string, string>?
--- @param readOnly boolean?
    function(o, rules, readOnly)
        o.context = CSSStyleContext();
        o.dirtyFlags = {};
        o.padding = nil;

        -- Set value(s).
        if rules and type(rules) == 'table' then
            o:setRules(rules);
        end

        o.readOnly = readOnly or false;
    end
);

--- @param rules table<string, string>
function CSSStyleSet:setRules(rules)
    if rules and type(rules) == 'table' and #rules ~= 0 then
        for k, v in pairs(rules) do
            self[k] = v;
        end
    end
end

function CSSStyleSet:update()
    -- Position --
    if self.dirtyFlags['position'] then
        self.context:applyPosition(self);
        self.dirtyFlags['position'] = false;
    end
    -- Width --
    if self.dirtyFlags['width'] then
        self.context:applyWidth(self);
        self.dirtyFlags['width'] = false;
    end
    -- Height --
    if self.dirtyFlags['height'] then
        self.context:applyHeight(self);
        self.dirtyFlags['height'] = false;
    end
    -- Margin --
    if self.dirtyFlags['margin'] then
        self.context:applyMargin(self);
        self.dirtyFlags['margin'] = false;
    end
    -- Padding --
    if self.dirtyFlags['padding'] then
        self.context:applyPadding(self);
        self.dirtyFlags['padding'] = false;
    end
end

-- MARK: Metatable

local mt = getmetatable(CSSStyleSet);

--- @param tbl table
--- @param field string|number
--- @param value any
mt.__newindex = function(tbl, field, value)
    -- Check to see if the set is readOnly. --
    local readOnly = rawget(tbl, 'readOnly');
    if readOnly then
        error('CSSStyleSet is readonly.', 2);
    end
    -- ------------------------------------ --

    local valuePrev = rawget(table, field);

    -- Natural Code --
    rawset(table, field, value);

    -- Nothing's changed. Do not dirty-set anything.
    if valuePrev == value then return end

    -- Display Rule --
    if field == 'display' then
        tbl.dirtyFlags['display'] = true;
    end

    -- Position Rules --
    if field == 'position'
        or field == 'top'
        or field == 'right'
        or field == 'bottom'
        or field == 'left' then
        tbl.dirtyFlags['position'] = true;
    end

    -- Width Rules --
    if field == 'width'
        or field == 'widthMin'
        or field == 'widthMax' then
        tbl.dirtyFlags['width'] = true;
    end

    -- Height Rules --
    if field == 'height'
        or field == 'heightMin'
        or field == 'heightMax' then
        tbl.dirtyFlags['height'] = true;
    end

    -- Margin Rules --
    if field == 'margin'
        or field == 'marginTop'
        or field == 'marginRight'
        or field == 'marginBottom'
        or field == 'marginLeft' then
        tbl.dirtyFlags['margin'] = true;
    end

    -- Padding Rules --
    if field == 'padding'
        or field == 'paddingTop'
        or field == 'paddingRight'
        or field == 'paddingBottom'
        or field == 'paddingLeft' then
        tbl.dirtyFlags['padding'] = true;
    end
end;

setmetatable(CSSStyleSet, mt);

return CSSStyleSet;
