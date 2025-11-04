--- @alias RGBA_255 {type: 'rgba_255', r: number, g: number, b: number, a: number}
--- @alias RGB_255 {type: 'rgb_255', r: number, g: number, b: number}
--- @alias RGBA_1 {type: 'rgba_1', r: number, g: number, b: number, a: number}
--- @alias RGB_1 {type: 'rgb_1', r: number, g: number, b: number}
--- @alias HEX_3 {type: 'hex_3', value: string}
--- @alias HEX_6 {type: 'hex_6', value: string}
--- @alias HSL {type: 'hsl', h: number, s: number, l: number}

-- MARK: - Utils

--- @param val number
--- @param min number
--- @param max number
---
--- @return number clampedVal
local function clamp(val, min, max)
    -- Param type check --
    if type(val) ~= 'number' then
        error(string.format('the value given is not a number. (type = %s, value = %s)', type(val), tostring(val)), 2);
    elseif type(min) ~= 'number' then
        error(
            string.format('the minimum clamp value given is not a number. (type = %s, value = %s)',
                type(min),
                tostring(min)
            ),
            2
        );
    elseif type(max) ~= 'number' then
        error(
            string.format('the maximum clamp value given is not a number. (type = %s, value = %s)',
                type(max),
                tostring(max)
            ),
            2
        );
    end

    -- Value type check --
    if max < min then
        error(string.format('min clamp value is greater than max clamp value. (min = %d, max = %d)', min, max), 2);
    elseif max == min then
        return min;
    else
        if val < min then val = min end
        if val > max then val = max end
        return val;
    end
end

-- MARK: - Temp Vars

--- @type number, number, number, number, number, number, number
local r, g, b, h, s, l, d;
--- @type number, number
local min, max;
--- @type number, number
local temp, temp2;

--- @class Color
local Color = {};

-- MARK: - Functions

--- @param rgb RGB_255
---
--- @return RGB_1 rgb_1
function Color.RGB_255_to_RGB_1(rgb)
    -- Check parameter.
    if type(rgb) ~= 'table' then
        error(string.format('Invalid color. (type = %s)', type(rgb)), 2);
    elseif rgb.type ~= 'rgb_255' then
        error(string.format('Invalid color type: %s', tostring(rgb.type)), 2);
    end

    return {
        type = 'rgb_1',
        r = rgb.r / 255.0,
        g = rgb.g / 255.0,
        b = rgb.b / 255.0
    };
end

--- @param rgb RGB_1
function Color.RGB_1_to_HSL(rgb)
    r = rgb.r;
    g = rgb.g;
    b = rgb.b;
    max = Math.max(r, Math.max(g, b));
    min = Math.min(r, Math.min(g, b));
    temp = (max + min) / 2.0;
    h = temp;
    s = temp;
    l = temp;
    if (max == min) then
        h = 0;
        s = 0;
    else
        d = max - min;
        if l > 0.5 then
            s = d / (2 - max - min);
        else
            s = d / (max + min);
        end
        if max == r then
            if g < b then
                temp2 = 6;
            else
                temp2 = 0;
            end
            h = (g - b) / d + temp2;
        elseif max == g then
            h = (b - r) / d + 2;
        elseif max == b then
            h = (r - g) / d + 4;
        end
        h = h / 6;
    end
    return {
        type = 'hsl',
        h = Math.round(h * 360.0),
        s = Math.round(s * 100.0),
        l = Math.round(l * 100.0)
    };
end

--- @param rgb RGB_255
--- @return table
function Color.RGB_255_to_HSL(rgb)
    return Color.RGB_1_to_HSL(Color.RGB_255_to_RGB_1(rgb));
end

local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p;
end

--- @param hsl HSL
---
--- @return rgb RGB_1
function Color.HSL_TO_RGB_1(hsl)
    h = h / 360.0;
    s = s / 100.0;
    l = l / 100.0;
    if s == 0 then
        r = l;
        g = l;
        b = l;
    else
        local q, p;
        if l < 0.5 then
            q = l * (1 + s);
        else
            q = l + s - l * s;
        end
        p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end
    return {
        type = 'rgb_1',
        r = Math.round(r * 255),
        g = Math.round(g * 255),
        b = Math.round(b * 255)
    };
end

return {
    RGB_255_to_HSL = RGB_255_to_HSL
};
