local class = require 'asledgehammer/util/class';
local UnitValue = require 'asledgehammer/shadehammer/ui/UnitValue';
local CSSParser = require 'asledgehammer/shadehammer/css/Parse';

--- @class AxesDefinition
---
--- @field topBottom UnitValue
--- @field leftRight UnitValue

--- @class EdgeDefinition
---
--- @field top UnitValue
--- @field left UnitValue
--- @field bottom UnitValue
--- @field right UnitValue

--- @class SHStyleSet
---
--- @field padding EdgeDefinition|AxesDefinition|UnitValue?
local SHStyleSet = class(function(o)

end);

-- MARK: Metatable

local mt = getmetatable(SHStyleSet);

--- Handles metafunction tranformation of string value(s) for padding.
---
--- @param tbl table
--- @param value any
local function setPadding(tbl, value)

end

--- @param tbl table 
--- @param value string all-sides
local function setPadding1(tbl, value)
    local result = CSSParser.tryParseUnitValue(value);
    if result.error then error(result.error, 2) end
    rawset(tbl, 'padding', UnitValue(result.value, result.unit));
end

--- @param tbl table
--- @param values string[] [top-bottom, left-right]
local function setPadding2(tbl, values)

end

--- @param tbl table
--- @param values string[] [top, left-right, bottom]
local function setPadding2(tbl, values)

end

--- @param tbl table
--- @param values string[] [top, right, bottom, left]
local function setPadding4(tbl, values)

end

--- @param tbl table
--- @param field string|number
--- @param value any
mt.__newindex = function(tbl, field, value)
    -- Padding Code --
    if field == 'padding' then
        setPadding(tbl, value);
        return;
    end

    -- Natural Code --
    rawset(table, field, value);
end;

setmetatable(SHStyleSet, mt);

return SHStyleSet;
