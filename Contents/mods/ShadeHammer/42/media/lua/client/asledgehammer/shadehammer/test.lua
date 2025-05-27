local LuaFont = require 'asledgehammer/shadehammer/LuaFont';

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

--- @param lines string[]
---
--- @return BMFontInfo, BMFontCommon, BMFontPage[], table<number, BMFontChar>, table<number, table<number, BMFontKerning>>
local function parseBMFont(lines)
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

local modInfo = getModInfoByID('\\shadehammer');
print('modInfo', modInfo);
if modInfo then
    local path = 'media/fonts/codeLarge.fnt';

    local font = LuaFont('CodeLarge', path);

    print(tostring(font));
end
