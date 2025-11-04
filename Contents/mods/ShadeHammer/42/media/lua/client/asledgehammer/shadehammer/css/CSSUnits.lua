local CSSProperty = require 'asledgehammer/shadehammer/css/CSSProperty';
local BorderWidth = CSSProperty.BorderWidth;
local FontSize = CSSProperty.FontSize;

--- @class CSSUnits
--- @field dpi number CSS3 assumes fixed 96 DPI
--- @field mediumFont number 12pt
--- @field fontStep number
--- @field THIN_BORDER number
--- @field MEDIUM_BORDER number
--- @field THICK_BORDER number
local CSSUnits = {};

CSSUnits.dpi = 96;
CSSUnits.mediumFont = 12;
CSSUnits.fontStep = 1.2;
CSSUnits.THIN_BORDER = 1.0;
CSSUnits.MEDIUM_BORDER = 3.0;
CSSUnits.THICK_BORDER = 5.0;

--- Converts points to pixels according to the DPI set.
---
--- @param pt number
---
--- @return number pixels
function CSSUnits.pixels(pt)
    return pt * CSSUnits.dpi / 72.0;
end

--- Converts pixels to points according to the DPI set.
---
--- @param px number
---
--- @return number points
function CSSUnits.points(px)
    return px * 72.0 / CSSUnits.dpi;
end

--- Converts the font size given by an identifier to absolute length in pixels.
---
--- @param parent number Parent font size (taken as 1em)
--- @param value FontSize
function CSSUnits.convertFontSize(parent, value)
    local mediumFont = CSSUnits.mediumFont;
    local fontStep = CSSUnits.fontStep;
    local em = parent;
    local ret = em;
    if value == FontSize.MEDIUM then
        ret = mediumFont;
    elseif value == FontSize.SMALL then
        ret = mediumFont / fontStep;
    elseif value == CSSProperty.FontSize.X_SMALL then
        ret = mediumFont / fontStep / fontStep;
    elseif value == CSSProperty.FontSize.XX_SMALL then
        ret = mediumFont / fontStep / fontStep / fontStep;
    elseif value == CSSProperty.FontSize.LARGE then
        ret = mediumFont * fontStep;
    elseif value == CSSProperty.FontSize.X_LARGE then
        ret = mediumFont * fontStep * fontStep;
    elseif value == CSSProperty.FontSize.XX_LARGE then
        ret = mediumFont * fontStep * fontStep * fontStep;
    elseif value == CSSProperty.FontSize.SMALLER then
        ret = em / fontStep;
    elseif value == CSSProperty.FontSize.LARGER then
        ret = em * fontStep;
    end
    return ret;
end

---
--- Converts the border size given by an identifier to an absolute value.
--- @param width BorderWidth the border-width identifier
--- @return number result absolute length in pixels
function CSSUnits.convertBorderWidth(width)
    if width == BorderWidth.THIN then
        return CSSUnits.THIN_BORDER;
    elseif width == BorderWidth.MEDIUM then
        return CSSUnits.MEDIUM_BORDER;
    else
        return CSSUnits.THICK_BORDER;
    end
end

return CSSUnits;
