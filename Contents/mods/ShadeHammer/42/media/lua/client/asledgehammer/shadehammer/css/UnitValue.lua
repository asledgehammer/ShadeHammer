local class = require 'asledgehammer/util/class';

--- @alias ValueUnit 'zero'|'auto'|'inherit'|'px'|'%'|'vw'|'vh' https://developer.mozilla.org/en-US/docs/Web/CSS/length#mm
--- @alias RelativeUnitValue number|nil Calculated unit values. If nil, the origin has an invalid or missing unit.

--- @class UnitValue https://developer.mozilla.org/en-US/docs/Web/CSS/length#mm
---
--- [Static Constants]
--- @field ZERO UnitValue
--- @field AUTO UnitValue
--- @field INHERIT UnitValue
--- 
--- @field type 'UnitValue'
--- @field unit ValueUnit? The unit to calculate.
--- @field value number?
--- @field readOnly boolean
local UnitValue = class(
--- @param o UnitValue
--- @param unit ValueUnit
--- @param value number
--- @param readOnly boolean?
    function(o, value, unit, readOnly)
        o.type = 'UnitValue';
        o.value = value;
        o.unit = unit;
        o.readOnly = readOnly or false;
    end
);

-- STATIC VALUES --
UnitValue.ZERO = UnitValue(0, 'zero', true);
UnitValue.AUTO = UnitValue(0, 'auto', true);
UnitValue.INHERIT = UnitValue(0, 'inherit', true);

--- @param context any
---
--- @return RelativeUnitValue relativeValue
function UnitValue:resolve(context)
    -- Simulate erroneous CSS rules by providing 0.
    if not self.unit then return nil end

    -- TODO: Write calc code.

    return 0;
end

-- MARK: metatable

local mt = getmetatable(UnitValue);

function mt.__eq(a, b)
    if b == nil then
        return false;
    elseif b.type ~= 'UnitValue' then
        return false;
    else
        return a.unit == b.unit and a.value == b.value;
    end
end

function mt.__newindex(tbl, field, value)
    -- Check to make sure that the readOnly state is set.
    local readOnly = rawget(tbl, 'readOnly');
    if readOnly then
        error(string.format('Object is readonly: %s', rawget(tbl, '__tostring')()), 2);
    end

    -- Natural value assignment.
    rawset(tbl, field, value);
end

setmetatable(UnitValue, mt);

return UnitValue;
