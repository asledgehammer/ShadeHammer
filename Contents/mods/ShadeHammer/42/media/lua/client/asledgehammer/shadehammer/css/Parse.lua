local function trim(s)
    return string.gsub(s, '^%s*(.-)%s*$', '%1');
end

local Parse = {};

--- @class UnitValueParseResult
--- @field error string? If non-nil, the parse failed.
--- @field unit string?
--- @field value number?

-- MARK: Function

--- @param str string
---
--- @return UnitValueParseResult
function Parse.tryParseUnitValue(str)
    --- @type number|nil, number|nil
    local s_start, s_end;

    --- @type number|nil, number|nil
    local u_start, u_end;

    --- @type number|nil, number|nil
    local v_start, v_end;

    --- @type string|nil
    local unit = nil;

    --- @type number|nil
    local value = nil;

    --- @type string|nil
    local error = nil;

    -- Pre-clean leading and trailing whitespace.
    str = trim(str);

    -- Exception to the format rule for zeroed values.
    if str == '0' then
        return { error = nil, unit = 'zero', value = '0' };
    end

    s_start, s_end = string.find(str, '%s*');
    if s_end ~= 0 then
        --- We found whitespace in the value itself, which is illegal.
        error = string.format('CSS PropertyValue contains spaces: %s', str);
    end

    -- Try-parse unit.
    if not error then
        u_start, u_end = string.find(str, '%a+', 1); -- Letter(s)
        if u_start and u_end then
            unit = string.sub(str, u_start, u_end);
        else
            error = string.format('CSS PropertyValue contains no unit: %s', str);
        end
    end

    -- Try-parse numeric value.
    if not error then
        v_start, v_end = string.find(str, '-?%d*%.*%d*', 1);

        -- Check to make sure the unit or non-numerical garbage proceeds the value itself. If so, this is illegal.
        if v_start > u_start then
            error = string.format('CSS PropertyValue defines unit or contains leading non-numeric characters: %s', str);
        end

        -- Parse the numerical value.
        if not error then
            if v_start and v_end then
                value = tonumber(string.sub(str, v_start, v_end));
            else
                error = string.format('CSS PropertyValue contains no value: %s', str);
            end
        end

        -- Check cast to ensure validity.
        if not error and value == nil then
            error = string.format('CSS PropertyValue contains non-numeric value: %s', str);
        end
    end

    return { error = error, unit = unit, value = value };
end

return Parse;
