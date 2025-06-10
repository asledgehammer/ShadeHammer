local class = require 'asledgehammer/util/class';
local UnitValue = require 'asledgehammer/shadehammer/ui/UnitValue';
local CSSParser = require 'asledgehammer/shadehammer/css/Parse';

local function debugf(msg, ...)
    DebugLog.log(DebugType.Lua, string.format(msg, ...));
end

local function tokenize(str)
    local tokens = {};
    for token in string.gmatch(str, '[^%s]+') do table.insert(tokens, token) end
    return tokens;
end

--- @class CSSStyleContext This class rasterizes stylesheet value(s) into numeric values to compose in the render tree context.
---
--- @field display CSSDisplayValue
--- @field padding { top: UnitValue, right: UnitValue, bottom: UnitValue, left: UnitValue }
--- @field margin { top: UnitValue, right: UnitValue, bottom: UnitValue, left: UnitValue }
local CSSStyleContext = class(
--- @param o CSSStyleContext
    function(o)
        o.display = 'none';
        o.margin = {
            top = UnitValue.ZERO,
            right = UnitValue.ZERO,
            bottom = UnitValue.ZERO,
            left = UnitValue.ZERO
        };
        o.padding = {
            top = UnitValue.ZERO,
            left = UnitValue.ZERO,
            bottom = UnitValue.ZERO,
            right = UnitValue.ZERO
        };
    end
);

-- Temp locals for calculating

--- @type string[]
local tokens;

--- @type number
local len;

--- @type UnitValue, UnitValue, UnitValue
local width, widthMin, widthMax;

--- @type UnitValue, UnitValue, UnitValue
local height, heightMin, heightMax;

--- @type UnitValue, UnitValue, UnitValue, UnitValue
local top, right, bottom, left;

--- @type UnitValueParseResult, UnitValueParseResult, UnitValueParseResult, UnitValueParseResult
local result1, result2, result3, result4;

--- @type UnitValue, UnitValue, UnitValue, UnitValue
local uv1, uv2, uv3, uv4;

-- MARK: Offset

function CSSStyleContext:applyPosition(style)
    -- TODO: Implement.

    top = UnitValue.ZERO;
    right = UnitValue.ZERO;
    bottom = UnitValue.ZERO;
    left = UnitValue.ZERO;



end

-- MARK: Width

--- @param style CSSStyleSet
function CSSStyleContext:applyWidth(style)
    width = UnitValue.AUTO;
    widthMin = UnitValue.AUTO;
    widthMax = UnitValue.AUTO;

    -- width --
    if style.width then
        if type(style.width) ~= 'string' then
            debugf('Invalid CSS Format: width: %s (ignoring..)', style.width);
        else
            result1 = CSSParser.tryParseUnitValue(style.width);
            if result1.error then
                debugf('Invalid CSS Format: width: %s (ignoring..)', style.width);
            else
                width = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- widthMin --
    if style.widthMin then
        if type(style.widthMin) ~= 'string' then
            debugf('Invalid CSS Format: width-min: %s (ignoring..)', style.widthMin);
        else
            result1 = CSSParser.tryParseUnitValue(style.widthMin);
            if result1.error then
                debugf('Invalid CSS Format: width-min: %s (ignoring..)', style.widthMin);
            else
                widthMin = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- widthMax --
    if style.widthMax then
        if type(style.widthMax) ~= 'string' then
            debugf('Invalid CSS Format: width-max: %s (ignoring..)', style.widthMax);
        else
            result1 = CSSParser.tryParseUnitValue(style.widthMax);
            if result1.error then
                debugf('Invalid CSS Format: width-max: %s (ignoring..)', style.widthMax);
            else
                widthMax = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- Apply rules.
    self.width = width;
    self.widthMin = widthMin;
    self.widthMax = widthMax;
end

-- MARK: Height

--- @param style CSSStyleSet
function CSSStyleContext:applyHeight(style)
    -- TODO: Implement.
    height = UnitValue.AUTO;
    heightMin = UnitValue.AUTO;
    heightMax = UnitValue.AUTO;

    -- height --
    if style.height then
        if type(style.height) ~= 'string' then
            debugf('Invalid CSS Format: height: %s (ignoring..)', style.height);
        else
            result1 = CSSParser.tryParseUnitValue(style.height);
            if result1.error then
                debugf('Invalid CSS Format: height: %s (ignoring..)', style.height);
            else
                height = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- heightMin --
    if style.heightMin then
        if type(style.heightMin) ~= 'string' then
            debugf('Invalid CSS Format: height-min: %s (ignoring..)', style.heightMin);
        else
            result1 = CSSParser.tryParseUnitValue(style.heightMin);
            if result1.error then
                debugf('Invalid CSS Format: height-min: %s (ignoring..)', style.heightMin);
            else
                heightMin = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- heightMax --
    if style.heightMax then
        if type(style.heightMax) ~= 'string' then
            debugf('Invalid CSS Format: height-max: %s (ignoring..)', style.heightMax);
        else
            result1 = CSSParser.tryParseUnitValue(style.heightMax);
            if result1.error then
                debugf('Invalid CSS Format: height-max: %s (ignoring..)', style.heightMax);
            else
                heightMax = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- Apply rules.
    self.height = height;
    self.heightMin = heightMin;
    self.heightMax = heightMax;
end

-- MARK: Margin

--- @param style CSSStyleSet
function CSSStyleContext:applyMargin(style)
    top = UnitValue.ZERO;
    bottom = UnitValue.ZERO;
    left = UnitValue.ZERO;
    right = UnitValue.ZERO;

    -- Parse & assign implicit rules first.
    if style.margin then
        tokens = tokenize(style.margin);
        len = #tokens;
        if len == 1 then -- [marginTop & marginBottom & marginLeft & marginRight] [1]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            if result1.error then
                debugf('Invalid CSS Format: margin: %s (ignoring..)', style.margin);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                top = uv1;
                right = uv1;
                bottom = uv1;
                left = uv1;
            end
        elseif len == 2 then -- [marginTop & marginBottom, marginLeft & marginRight] [2]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            result2 = CSSParser.tryParseUnitValue(tokens[2]);
            if result1.error or result2.error then
                debugf('Invalid CSS Format: margin: %s (ignoring..)', style.margin);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                uv2 = UnitValue(result2.value, result2.unit);
                top = uv1;
                right = uv2;
                bottom = uv1;
                left = uv2;
            end
        elseif len == 3 then -- [marginTop, marginLeft & marginRight, marginBottom] [3]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            result2 = CSSParser.tryParseUnitValue(tokens[2]);
            result3 = CSSParser.tryParseUnitValue(tokens[3]);
            if result1.error or result2.error or result3.error then
                debugf('Invalid CSS Format: margin: %s (ignoring..)', style.margin);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                uv2 = UnitValue(result2.value, result2.unit);
                uv3 = UnitValue(result3.value, result3.unit);
                top = uv1;
                right = uv2;
                bottom = uv3;
                left = uv2;
            end
        elseif len == 4 then -- [paddingTop, paddingRight, paddingBottom, paddingLeft] [4]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            result2 = CSSParser.tryParseUnitValue(tokens[2]);
            result3 = CSSParser.tryParseUnitValue(tokens[3]);
            result4 = CSSParser.tryParseUnitValue(tokens[4]);
            if result1.error or result2.error or result3.error or result4.error then
                debugf('Invalid CSS Format: margin: %s (ignoring..)', style.margin);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                uv2 = UnitValue(result2.value, result2.unit);
                uv3 = UnitValue(result3.value, result3.unit);
                uv4 = UnitValue(result4.value, result4.unit);
                top = uv1;
                right = uv2;
                bottom = uv3;
                left = uv4;
            end
        else
            debugf('Invalid CSS Format: margin: %s (ignoring..)', style.margin);
        end
    end

    -- marginTop (explicit)
    if style.marginTop then
        if type(style.marginTop) ~= 'string' then
            debugf('Invalid CSS value format: marginTop: %s (ignoring..)', style.marginTop);
        else
            result1 = CSSParser.tryParseUnitValue(style.marginTop);
            if result1.error then
                debugf('Invalid CSS Format: marginTop: %s (ignoring..)', style.marginTop);
            else
                top = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- marginRight (explicit)
    if style.marginRight then
        if type(style.marginRight) ~= 'string' then
            debugf('Invalid CSS value format: marginRight: %s (ignoring..)', style.marginRight);
        else
            result1 = CSSParser.tryParseUnitValue(style.marginRight);
            if result1.error then
                debugf('Invalid CSS Format: marginRight: %s (ignoring..)', style.marginRight);
            else
                right = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- marginBottom (explicit)
    if style.marginBottom then
        if type(style.marginBottom) ~= 'string' then
            debugf('Invalid CSS value format: marginBottom: %s (ignoring..)', style.marginBottom);
        else
            result1 = CSSParser.tryParseUnitValue(style.marginBottom);
            if result1.error then
                debugf('Invalid CSS Format: marginBottom: %s (ignoring..)', style.marginBottom);
            else
                bottom = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- marginLeft (explicit)
    if style.marginLeft then
        if type(style.marginLeft) ~= 'string' then
            debugf('Invalid CSS value format: marginLeft: %s (ignoring..)', style.marginLeft);
        else
            result1 = CSSParser.tryParseUnitValue(style.marginLeft);
            if result1.error then
                debugf('Invalid CSS Format: marginLeft: %s (ignoring..)', style.marginLeft);
            else
                left = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- Apply explicit rules.
    self.margin = {
        top = top,
        right = right,
        bottom = bottom,
        left = left
    };
end

-- MARK: Padding

--- @param style CSSStyleSet
function CSSStyleContext:applyPadding(style)
    top = UnitValue.ZERO;
    bottom = UnitValue.ZERO;
    left = UnitValue.ZERO;
    right = UnitValue.ZERO;

    -- Parse & assign implicit rules first.
    if style.padding then
        tokens = tokenize(style.padding);
        len = #tokens;
        if len == 1 then -- [paddingTop & paddingBottom & paddingLeft & paddingRight] [1]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            if result1.error then
                debugf('Invalid CSS Format: padding: %s (ignoring..)', style.padding);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                top = uv1;
                right = uv1;
                bottom = uv1;
                left = uv1;
            end
        elseif len == 2 then -- [paddingTop & paddingBottom, paddingLeft & paddingRight] [2]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            result2 = CSSParser.tryParseUnitValue(tokens[2]);
            if result1.error or result2.error then
                debugf('Invalid CSS Format: padding: %s (ignoring..)', style.padding);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                uv2 = UnitValue(result2.value, result2.unit);
                top = uv1;
                right = uv2;
                bottom = uv1;
                left = uv2;
            end
        elseif len == 3 then -- [paddingTop, paddingLeft & paddingRight, paddingBottom] [3]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            result2 = CSSParser.tryParseUnitValue(tokens[2]);
            result3 = CSSParser.tryParseUnitValue(tokens[3]);
            if result1.error or result2.error or result3.error then
                debugf('Invalid CSS Format: padding: %s (ignoring..)', style.padding);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                uv2 = UnitValue(result2.value, result2.unit);
                uv3 = UnitValue(result3.value, result3.unit);
                top = uv1;
                right = uv2;
                bottom = uv3;
                left = uv2;
            end
        elseif len == 4 then -- [paddingTop, paddingRight, paddingBottom, paddingLeft] [4]
            result1 = CSSParser.tryParseUnitValue(tokens[1]);
            result2 = CSSParser.tryParseUnitValue(tokens[2]);
            result3 = CSSParser.tryParseUnitValue(tokens[3]);
            result4 = CSSParser.tryParseUnitValue(tokens[4]);
            if result1.error or result2.error or result3.error or result4.error then
                debugf('Invalid CSS Format: padding: %s (ignoring..)', style.padding);
            else
                uv1 = UnitValue(result1.value, result1.unit);
                uv2 = UnitValue(result2.value, result2.unit);
                uv3 = UnitValue(result3.value, result3.unit);
                uv4 = UnitValue(result4.value, result4.unit);
                top = uv1;
                right = uv2;
                bottom = uv3;
                left = uv4;
            end
        else
            debugf('Invalid CSS Format: padding: %s (ignoring..)', style.padding);
        end
    end

    -- paddingTop (explicit)
    if style.paddingTop then
        if type(style.paddingTop) ~= 'string' then
            debugf('Invalid CSS value format: paddingTop: %s (ignoring..)', style.paddingTop);
        else
            result1 = CSSParser.tryParseUnitValue(style.paddingTop);
            if result1.error then
                debugf('Invalid CSS Format: paddingTop: %s (ignoring..)', style.paddingTop);
            else
                top = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- paddingRight (explicit)
    if style.paddingRight then
        if type(style.paddingRight) ~= 'string' then
            debugf('Invalid CSS value format: paddingRight: %s (ignoring..)', style.paddingRight);
        else
            result1 = CSSParser.tryParseUnitValue(style.paddingRight);
            if result1.error then
                debugf('Invalid CSS Format: paddingRight: %s (ignoring..)', style.paddingRight);
            else
                right = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- paddingBottom (explicit)
    if style.paddingBottom then
        if type(style.paddingBottom) ~= 'string' then
            debugf('Invalid CSS value format: paddingBottom: %s (ignoring..)', style.paddingBottom);
        else
            result1 = CSSParser.tryParseUnitValue(style.paddingBottom);
            if result1.error then
                debugf('Invalid CSS Format: paddingBottom: %s (ignoring..)', style.paddingBottom);
            else
                bottom = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- paddingLeft (explicit)
    if style.paddingLeft then
        if type(style.paddingLeft) ~= 'string' then
            debugf('Invalid CSS value format: paddingLeft: %s (ignoring..)', style.paddingLeft);
        else
            result1 = CSSParser.tryParseUnitValue(style.paddingLeft);
            if result1.error then
                debugf('Invalid CSS Format: paddingLeft: %s (ignoring..)', style.paddingLeft);
            else
                left = UnitValue(result1.value, result1.unit);
            end
        end
    end

    -- Apply explicit rules.
    self.padding = {
        top = top,
        right = right,
        bottom = bottom,
        left = left
    };
end

return CSSStyleContext;
