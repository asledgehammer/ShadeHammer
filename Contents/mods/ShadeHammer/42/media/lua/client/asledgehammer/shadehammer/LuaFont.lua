local class = require 'asledgehammer/util/class';

-- MARK: Documentation

--- @class BMFontInfo This tag holds information on how the font was generated.
--- @field face string This is the name of the true type font.
--- @field size number The size of the true type font.
--- @field bold number The font is bold.
--- @field italic number The font is italic.
--- @field charset string The name of the OEM charset used (when not unicode).
--- @field unicode number Set to 1 if it is the unicode charset.
--- @field stretchH number The font height stretch in percentage. 100% means no stretch.
--- @field smooth number Set to 1 if smoothing was turned on.
--- @field aa number The supersampling level used. 1 means no supersampling was used.
--- @field padding {top: number, right: number, bottom: number, left: number} The padding for each character (up, right, down, left).
--- @field spacing {horizontal: number, vertical: number} The spacing for each character (horizontal, vertical).
--- @field outline number The outline thickness for the characters.

--- @class BMFontCommon This tag holds information common to all characters.
--- @field lineHeight number This is the distance in pixels between each line of text.
--- @field base number The number of pixels from the absolute top of the line to the base of the characters.
--- @field scaleW number The width of the texture, normally used to scale the x pos of the character image.
--- @field scaleH number The height of the texture, normally used to scale the y pos of the character image.
--- @field pages number The number of texture pages included in the font.
--- @field packed number Set to 1 if the monochrome characters have been packed into each of the texture channels. In this case alphaChnl describes what is stored in each channel.
--- @field alphaChnl number Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
--- @field redChnl number Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
--- @field greenChnl number Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.
--- @field blueChnl number Set to 0 if the channel holds the glyph data, 1 if it holds the outline, 2 if it holds the glyph and the outline, 3 if its set to zero, and 4 if its set to one.

--- @class BMFontPage This tag gives the name of a texture file. There is one for each page in the font.
--- @field id number The page id.
--- @field file string

--- @class BMFontChar This tag describes on character in the font. There is one for each included character in the font.
--- @field id number The character id.
--- @field x number The left position of the character image in the texture.
--- @field y number The top position of the character image in the texture.
--- @field width number The width of the character image in the texture.
--- @field height number The height of the character image in the texture.
--- @field xoffset number How much the current position should be offset when copying the image from the texture to the screen.
--- @field yoffset number How much the current position should be offset when copying the image from the texture to the screen.
--- @field xadvance number How much the current position should be advanced after drawing the character.
--- @field page number The texture page where the character image is found.
--- @field chnl number 	The texture channel where the character image is found. (1 = blue, 2 = green, 4 = red, 8 = alpha, 15 = all channels)

--- @class BMFontKerning The kerning information is used to adjust the distance between certain characters, e.g. some characters should be placed closer to each other than others.
--- @field first number The first character id.
--- @field second number The second character id.
--- @field amount number How much the x position should be adjusted when drawing the second character immediately following the first.

-- MARK: Utility

--- @param file string The path to the file.
---
--- @return string[]|nil lines If the file is not found, nil is returned.
local readFileAsLines = function(file)
    --- @type BufferedReader | nil
    local reader = getModFileReader('\\shadehammer', file, false);

    if reader then
        local lines = {};
        local line = reader:readLine();
        while line do
            table.insert(lines, line);
            line = reader:readLine();
        end
        return lines;
    end
    return nil;
end

local tokenize = function(line)
    local tokens = {};
    for token in line:gmatch("%w+=%w+") do
        local a = string.split(token, '=');
        -- for i,v in ipairs(a) do print(i, v) end
        tokens[a[1]] = a[2];
    end
    return tokens;
end

--- @param line string
---
--- @return table
local parse = function(line)
    line = string.sub(line, 5);
    local tokens = tokenize(line);
    return tokens;
end

-- MARK: LuaFont

--- @class LuaFont
--- @field name string The name of the font.
--- @field file string The path to the font file.
--- @field info BMFontInfo
--- @field common BMFontCommon
--- @field pages table<number, BMFontPage>
--- @field chars table<number, BMFontChar>
--- @field kernings table<number, BMFontKerning>
local LuaFont;

LuaFont = class(
--- @param o LuaFont
--- @param name string
--- @param file string
    function(o, name, file)
        o.name = name;
        o.file = file;

        -- Read the font file.
        local lines = readFileAsLines(file);
        if not lines then
            error(string.format('Failed to load Font: %s (File not found: %s)', name, file), 2);
        end

        -- Parse the font file.
        o.info, o.common, o.pages, o.chars, o.kernings = LuaFont.parse(lines);
    end);

--- @return string
function LuaFont:__tostring()

    local charCount = 0;
    for k,v in pairs(self.chars) do
        charCount = charCount + 1;
    end

    return string.format('LuaFont = { name = %s, file = %s chars = %s }', self.name, self.file, charCount);
end

--- @param lines string[]
---
--- @return BMFontInfo, BMFontCommon, BMFontPage[], table<number, BMFontChar>, table<number, table<number, BMFontKerning>>
function LuaFont.parse(lines)
    --- @type BMFontInfo
    local info;

    --- @type BMFontCommon
    local common;

    --- @type BMFontPage[]
    local pages = {};

    --- @type table<number, BMFontChar>
    local chars = {};

    --- @type table<number, table<number, BMFontKerning>>
    local kernings = {};

    for _, line in ipairs(lines) do
        line = string.trim(line);
        if string.find(line, 'info', 1, true) == 1 then
            info = parse(line);
        elseif string.find(line, 'common', 1, true) == 1 then
            common = parse(line);
        elseif string.find(line, 'page', 1, true) == 1 then
            local page = parse(line);
            pages[page.id] = parse(line);
        elseif string.find(line, 'chars', 1, true) == 1 then -- Ignore.
        elseif string.find(line, 'char', 1, true) == 1 then
            local char = parse(line);
            chars[char.id] = char;
        elseif string.find(line, 'char', 1, true) == 1 then
            local kerning = parse(line);
            local kerningChar = kernings[kerning.first];
            if not kerningChar then
                kerningChar = {};
                kerning[kerning.first] = kerningChar;
            end
            kerningChar[kerning.second] = kerning;
        end
    end

    return info, common, pages, chars, kernings;
end

return LuaFont;
