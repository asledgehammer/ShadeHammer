--- @meta

---[[
--- @author asledgehammer, JabDoesThings 2025
---]]

--- @class BMFontInfoDefinition: ObjectDefinition
local BMFontInfoDefinition = {};

--- @param face string This is the name of the true type font.
--- @param size number The size of the true type font.
--- @param bold number|boolean The font is bold.
--- @param italic number|boolean The font is italic.
--- @param charset string The name of the OEM charset used (when not unicode).
--- @param unicode number|boolean Set to 1 if it is the unicode charset.
--- @param stretchH number The font height stretch in percentage. 100% means no stretch.
--- @param smooth number|boolean Set to 1 if smoothing was turned on.
--- @param antialiased number|boolean The supersampling level used. 1 means no supersampling was used.
--- @param padding number[] The padding for each character (up, right, down, left).
--- @param spacing number[] The spacing for each character (horizontal, vertical).
--- @param outline number The outline thickness for the characters.
function BMFontInfoDefinition.new(self, face, size, bold, italic, charset,
                                  unicode, stretchH, smooth, antialiased, padding, spacing, outline)
end

--- @class BMFontInfo: Object
---
--- @field face string This is the name of the true type font.
--- @field size number The size of the true type font.
--- @field bold boolean The font is bold.
--- @field italic boolean The font is italic.
--- @field charset string The name of the OEM charset used (when not unicode).
--- @field unicode boolean Set to 1 if it is the unicode charset.
--- @field stretchH number The font height stretch in percentage. 100% means no stretch.
--- @field smooth boolean Set to 1 if smoothing was turned on.
--- @field antialiased boolean The supersampling level used. 1 means no supersampling was used.
--- @field padding number[] The padding for each character (up, right, down, left).
--- @field spacing number[] The spacing for each character (horizontal, vertical).
--- @field outline number The outline thickness for the characters.
local BMFontInfo = {};

--- @return string
function BMFontInfo:getFace() end

--- @return number
function BMFontInfo:getSize() end

--- @return boolean
function BMFontInfo:isBold() end

--- @return boolean
function BMFontInfo:isItalic() end

--- @return string
function BMFontInfo:getCharset() end

--- @return boolean
function BMFontInfo:isUnicode() end

--- @return number
function BMFontInfo:getStretchH() end

--- @return boolean
function BMFontInfo:isSmooth() end

--- @return boolean
function BMFontInfo:isAntiAliased() end

--- @return string[]
function BMFontInfo:getPadding() end

--- @return string[]
function BMFontInfo:getSpacing() end

--- @return number
function BMFontInfo:getOutline() end
