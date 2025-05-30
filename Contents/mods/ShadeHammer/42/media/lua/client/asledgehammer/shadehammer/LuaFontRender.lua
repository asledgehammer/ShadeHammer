local class = require 'asledgehammer/util/class';

-- Vector library --
local vector = require 'asledgehammer/math/vector';
local vec4 = vector.vec4;
local mat4 = vector.mat4;

local renderer = getRenderer();

--- @class LuaFontRenderQuad
--- @field texture Texture
--- @field x1 number
--- @field y1 number
--- @field x2 number
--- @field y2 number
--- @field x3 number?
--- @field y3 number?
--- @field x4 number?
--- @field y4 number?
--- @field r number
--- @field g number
--- @field b number
--- @field a number
--- @field type '2D'|'3D'

--- @class LuaFontRender
--- @field source LuaFontRender?
--- @field type 'LuaFontRender'
--- @field text string
--- @field chars LuaFontRenderQuad[]
--- @field width number
--- @field height number
--- @field mat mat4?
--- @field chromaKey {r: number, g: number, b: number}
local LuaFontRender = class(
--- @param o LuaFontRender
--- @param text string
--- @param width number
--- @param height number
--- @param chars LuaFontRenderQuad[]
    function(o, text, chars, width, height)
        o.type = 'LuaFontRender';
        o.text = text;
        o.chars = chars;
        o.width = width;
        o.height = height;
        o.chromaKey = { r = 0, g = 0, b = 0 };
    end
);

--- @param mat mat4
--- @return boolean
function LuaFontRender:isChanged(mat)
    return self.mat ~= mat;
end

--- @type vec4, vec4, vec4, vec4, vec4, vec4, vec4, vec4
local p1, p2, p3, p4, p5, p6, p7, p8 = vec4(), vec4(), vec4(), vec4(), vec4(), vec4(), vec4(), vec4();

--- @param mat mat4
function LuaFontRender:transform(mat)
    --- @type LuaFontRender, LuaFontRenderQuad[]
    local render, charsSource;

    if self.source then
        charsSource = self.source.chars;
        render = LuaFontRender(self.source.text, {}, self.source.width, self.source.height);
        render.source = self.source;
    else
        charsSource = self.chars;
        render = LuaFontRender(self.text, {}, self.width, self.height);
        render.source = self;
    end

    render.mat = mat4.clone(mat);

    for i = 1, #charsSource do
        local char = charsSource[i];

        p1:set(char.x1, char.y1, 0, 1);
        p2:set(char.x2, char.y1, 0, 1);
        p3:set(char.x2, char.y2, 0, 1);
        p4:set(char.x1, char.y2, 0, 1);

        mat4.transform(mat, p1, p5);
        mat4.transform(mat, p2, p6);
        mat4.transform(mat, p3, p7);
        mat4.transform(mat, p4, p8);

        --- @type LuaFontRenderQuad
        local charTransformed = {
            type = '3D',
            texture = char.texture,
            x1 = p5.x,
            y1 = p5.y,
            x2 = p6.x,
            y2 = p6.y,
            x3 = p7.x,
            y3 = p7.y,
            x4 = p8.x,
            y4 = p8.y,
            r = char.r,
            g = char.g,
            b = char.b,
            a = char.a
        };

        table.insert(render.chars, charTransformed);
    end

    return render;
end

function LuaFontRender:render()
    for i = 1, #self.chars do
        local char = self.chars[i];

        if char.type == '2D' then
            renderer:render(
                char.texture,
                -- Screen position
                char.x1, char.y1,
                char.x2, char.y1,
                char.x2, char.y2,
                char.x1, char.y2,

                -- Point-color(s)
                char.r, char.g, char.b, char.a,

                nil
            );
        else -- 3D
            renderer:render(
                char.texture,
                -- Screen position
                char.x1, char.y1,
                char.x2, char.y2,
                char.x3, char.y3,
                char.x4, char.y4,

                -- Point-color(s)
                char.r, char.g, char.b, char.a,

                nil
            );
        end
    end
end

return LuaFontRender;
