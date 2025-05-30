local class = require 'asledgehammer/util/class';
local JSON = require 'asledgehammer/util/json';

local LuaFontRender = require 'asledgehammer/shadehammer/LuaFontRender';

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
--- @field padding number[] The padding for each character (up, right, down, left).
--- @field spacing number[] The spacing for each character (horizontal, vertical).
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
--- @field texture Texture
--- @field textureID number

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
--- @field texture Texture The sub-texture of the page.

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
    --- Strings
    for token in line:gmatch('%w+="[^"]*"') do
        local a = string.split(token, '=');

        --- @type string
        local val = a[2];
        val = string.sub(val, 2, string.len(val) - 1);

        tokens[a[1]] = val;
    end

    --- Numbers
    for token in line:gmatch('%w+=[^%s^"]+') do
        local a = string.split(token, '=');

        --- @type string
        local valString = a[2];

        if string.find(valString, ',', 1, true) then
            local array = string.split(valString, ',');
            --- @type number[]
            local array2 = {};
            for _, v in ipairs(array) do
                table.insert(array2, tonumber(string.trim(v)));
            end

            -- local s = '';
            -- for _,v in ipairs(array2) do
            --     if s == '' then
            --         s = tostring(v);
            --     else
            --         s = s .. ', ' .. tostring(v);
            --     end
            -- end
            -- s = a[1] .. ' = [' .. s .. ']';
            -- print(s);

            tokens[a[1]] = array2;
        else
            local num = tonumber(valString);
            if num == nil then
                error(string.format('Invalid number: %s', valString));
            end
            tokens[a[1]] = num;
        end
    end

    return tokens;
end

--- @param line string
---
--- @return table
local parseSection = function(line)
    line = string.sub(line, 5);
    local tokens = tokenize(line);
    return tokens;
end

--- @param lines string[]
---
--- @return BMFontInfo, BMFontCommon, BMFontPage[], table<number, BMFontChar>, table<number, table<number, BMFontKerning>>
local parse = function(lines)
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
            info = parseSection(line);
        elseif string.find(line, 'common', 1, true) == 1 then
            common = parseSection(line);
        elseif string.find(line, 'page', 1, true) == 1 then
            local page = parseSection(line);
            pages[page.id] = parseSection(line);
        elseif string.find(line, 'chars', 1, true) == 1 then -- Ignore.
        elseif string.find(line, 'char', 1, true) == 1 then
            local char = parseSection(line);
            chars[string.char(char.id)] = char;
        elseif string.find(line, 'char', 1, true) == 1 then
            local kerning = parseSection(line);
            local kerningChar = kernings[kerning.first];
            if not kerningChar then
                kerningChar = {};
                kerning[string.char(kerning.first)] = kerningChar;
            end
            kerningChar[string.char(kerning.second)] = kerning;
        end
    end

    return info, common, pages, chars, kernings;
end

-- MARK: LuaFont

--- @class LuaFont
--- @field type 'LuaFont'
--- @field name string The name of the font.
--- @field file string The path to the font file.
--- @field info BMFontInfo
--- @field common BMFontCommon
--- @field pages table<number, BMFontPage>
--- @field chars table<number, BMFontChar>
--- @field kernings table<number, BMFontKerning>
local LuaFont = class(
--- @param o LuaFont
--- @param name string
--- @param file string
    function(o, name, file)
        o.type = 'LuaFont';
        o.name = name;
        o.file = file;

        -- Read the font file.
        local lines = readFileAsLines(file);
        if not lines then
            error(string.format('Failed to load Font: %s (File not found: %s)', name, file), 2);
        end

        -- Parse the font file.
        o.info, o.common, o.pages, o.chars, o.kernings = parse(lines);

        local path = string.gsub(o.file, '\\', '/');
        local pathSplit = string.split(path, '/');
        local pathRebuilt = '';
        for i = 1, #pathSplit - 1 do
            if pathRebuilt == '' then
                pathRebuilt = pathSplit[i];
            else
                pathRebuilt = pathRebuilt .. '/' .. pathSplit[i];
            end
        end
        for k, page in pairs(o.pages) do
            local texPath = pathRebuilt .. '/' .. page.file;
            page.texture = getTexture(texPath);
            if not page.texture then
                error(string.format('LuaFont %s :: Failed to grab texture for page %k: %s', o.name, k, texPath), 2);
            end
            page.textureID = page.texture:getID();
        end

        for k, char in pairs(o.chars) do
            local page = o.pages[char.page];
            local pageTex = page.texture;
            char.texture = pageTex:split(char.x, char.y, char.width, char.height);
        end
    end);

--- @param text string
--- @param x number
--- @param y number
---
--- @return LuaFontRender
function LuaFont:drawString(text, x, y)
    local chars = {};
    local width = 0;
    local height = 0;

    --- The padding for each character.
    local padTop, padRight, padBottom, padLeft =
        self.info.padding[1],
        self.info.padding[2],
        self.info.padding[3],
        self.info.padding[4];

    local startX, startY = x, y;
    local currX, currY = x, y;
    local lineHeight = self.common.lineHeight;
    local base = self.common;

    for i = 1, #text do
        -- Grab the current and next character to calculate.

        --- @type string The current character.
        local curr = string.sub(text, i, i);

        --- @type BMFontChar | nil
        local currDef = self.chars[curr];

        -- Make sure that the character definition exists so that we can actually draw the character.
        if currDef then
            local cx, cy = currX + currDef.xoffset, currY + currDef.yoffset;
            --- @type LuaFontRenderQuad
            local char = {
                type = '2D',
                texture = currDef.texture,
                x1 = cx,
                y1 = cy,
                x2 = cx + currDef.width,
                y2 = cy + currDef.height,
                r = 1,
                g = 1,
                b = 1,
                a = 1
            };

            table.insert(chars, char);

            --- @type string | nil The next character. (If exists)
            local next = string.sub(text, i + 1, i + 1);

            -- Grab kerning data for the two characters. (If exists)
            local kernOffset = 0;
            if next and self.kernings[curr] then
                local kern = self.kernings[curr][next];
                if kern then kernOffset = kern.amount end
            end

            -- Transform the position to the end of the character for the next.
            currX = currX + currDef.xadvance + kernOffset;
        end
    end

    return LuaFontRender(text, chars, currX - startX, lineHeight);
end

--- @return string
function LuaFont:__tostring()
    return string.format('LuaFont = %s', JSON.stringify(self.info));
end

return LuaFont;
