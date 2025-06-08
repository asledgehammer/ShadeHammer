local class = require 'asledgehammer/util/class';

--- @alias ValueUnit 'px'|'%'|'vw'|'vh' https://developer.mozilla.org/en-US/docs/Web/CSS/length#mm
--- @alias RelativeUnitValue number|nil Calculated unit values. If nil, the origin has an invalid or missing unit.

--- @class UnitValue https://developer.mozilla.org/en-US/docs/Web/CSS/length#mm
---
--- @field unit ValueUnit? The unit to calculate.
--- @field value number?
local UnitValue = class(
--- @param o UnitValue
--- @param unit ValueUnit
--- @param value number
    function(o, value, unit)
        o.value = value;
        o.unit = unit;
    end
);

--- @param context any
---
--- @return RelativeUnitValue relativeValue
function UnitValue:resolve(context)
    -- Simulate erroneous CSS rules by providing 0.
    if not self.unit then return nil end

    -- TODO: Write calc code.

    return 0;
end

return UnitValue;
