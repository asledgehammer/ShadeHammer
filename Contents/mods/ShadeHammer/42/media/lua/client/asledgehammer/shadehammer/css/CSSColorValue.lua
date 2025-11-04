local class = require 'asledgehammer/util/class';

--- @class CSSColorValue
---
--- @field color RGBA_1
--- @field readOnly boolean
local CSSColorValue = class(
--- Constructor.
---
--- @param o CSSColorValue
--- @param color RGBA_255|RGBA_1|HEX_3|HEX_6
--- @param readOnly boolean?
    function(o, color, readOnly)
        if color.type == 'rgba_255' then
            o.color = {
                r = (color.r or 0.0) / 255.0,
                g = (color.g or 0.0) / 255.0,
                b = (color.b or 0.0) / 255.0,
                a = (color.a or 255.0) / 255.0,
            };
        elseif color.type == 'rgba_1' then
            o.color = {
                r = color.r or 0.0,
                g = color.g or 0.0,
                b = color.b or 0.0,
                a = color.a or 1.0,
            };
        elseif color.type == 'hex_3' then

        elseif color.type == 'hex_6' then

        end

        o.readOnly = readOnly or false;
        return o.readOnly;
    end
);

-- MARK: Static Colors

CSSColorValue.WHITE = CSSColorValue('#fff', true);
CSSColorValue.BLACK = CSSColorValue('#000', true);
CSSColorValue.GRAY = CSSColorValue('#808080', true);
CSSColorValue.GREY = CSSColorValue.GRAY; -- (Spelling Alias)
CSSColorValue.SILVER = CSSColorValue('#c0c0c0', true);
CSSColorValue.TEAL = CSSColorValue('#008080', true);
CSSColorValue.AQUA = CSSColorValue('#00ffff', true);
CSSColorValue.BLUE = CSSColorValue('#00F', true);
CSSColorValue.NAVY = CSSColorValue('#000080', true);
CSSColorValue.GREEN = CSSColorValue('#008000', true);
CSSColorValue.LIME = CSSColorValue('#00ff00', true);
CSSColorValue.FUCHSIA = CSSColorValue('#ff00ff', true);
CSSColorValue.PURPLE = CSSColorValue('#800080', true);
CSSColorValue.OLIVE = CSSColorValue('#808000', true);
CSSColorValue.YELLOW = CSSColorValue('#ff0', true);
CSSColorValue.ORANGE = CSSColorValue('#ffa500', true);
CSSColorValue.RED = CSSColorValue('#f00', true);
CSSColorValue.MAROON = CSSColorValue('#800000', true);

return CSSColorValue;
