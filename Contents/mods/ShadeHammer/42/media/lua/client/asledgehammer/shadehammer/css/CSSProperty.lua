local CSSProperty = {};

--- @class BorderWidth
--- @field THIN number
--- @field MEDIUM number
--- @field THICK number
local BorderWidth = {
    THIN = 1,
    MEDIUM = 2,
    THICK = 3
};

--- @class FontSize
--- @field XX_SMALL number
--- @field X_SMALL number
--- @field SMALLER number
--- @field SMALL number
--- @field MEDIUM number
--- @field LARGE number
--- @field X_LARGE number
--- @field XX_LARGE number
local FontSize = {
    XX_SMALL = 1,
    X_SMALL = 2,
    SMALLER = 3,
    SMALL = 4,
    MEDIUM = 5,
    LARGE = 6,
    LARGER = 7,
    X_LARGE = 8,
    XX_LARGE = 9,
};

CSSProperty.BorderWidth = BorderWidth;
CSSProperty.FontSize = FontSize;

return CSSProperty;