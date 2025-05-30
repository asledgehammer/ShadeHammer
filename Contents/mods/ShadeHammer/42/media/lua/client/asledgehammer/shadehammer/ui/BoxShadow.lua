local class = require 'asledgehammer/util/class';

-- Vector Library --
local vector = require 'asledgehammer/math/vector';
local vec3 = vector.vec3;
local vec4 = vector.vec4;
local mat4 = vector.mat4;

-- ShadeHammer Library --
local ShadeHammer = require 'asledgehammer/ShadeHammer';

--- @type LuaShader
local shader = ShadeHammer.getOrLoadSkinnedShader('ShadeHammer_BoxShadow');

--- @class BoxShadow
--- @field element SHElement The element to draw under.
--- @field offset vec2
--- @field spread number
--- @field blur number
--- @field inset boolean
--- @field color {r: number, g: number, b: number, a: number}
--- @field shader LuaShader
local BoxShadow = class(
--- @param o BoxShadow
--- @param inset? boolean
--- @param offsetX? number
--- @param offsetY? number
--- @param blur? number
--- @param spread? number
--- @param color? {r: number, g: number, b: number, a: number}
    function(o, inset, offsetX, offsetY, blur, spread, color)
        -- Default Parameters --
        inset = inset or false;
        offsetX = offsetX or 0;
        offsetY = offsetY or 0;
        blur = blur or 0;
        spread = spread or 0;
        color = color or { r = 0, g = 0, b = 0, a = 1 };
        -- ------------------ --

        o.offset = vec2(offsetX, offsetY);
        o.blur = blur;
        o.spread = spread;
        o.inset = inset;
        o.color = color;
        o.shader = shader;
    end
);

--- @param element SHElement
function BoxShadow:update(element)
    if self:isChanged(element) then
        self:transform(element);
    end
end

--- @param element SHElement
function BoxShadow:isChanged(element)
    return self.mat ~= element.mat;
end

--- @param element SHElement
function BoxShadow:transform(element)
    local mat, size = element.mat, element.size;
    local x1 = self.offset.x - (element.rotationPivot.x * size.width);
    local y1 = self.offset.y - (element.rotationPivot.y * size.height);
    local x2, y2 = x1 + size.width, y1 + size.height;

    local point1 = vec4(x1, y1, 0, 1);
    local point2 = vec4(x2, y1, 0, 1);
    local point3 = vec4(x2, y2, 0, 1);
    local point4 = vec4(x1, y2, 0, 1);

    self.p1 = mat4.transform(mat, point1);
    self.p2 = mat4.transform(mat, point2);
    self.p3 = mat4.transform(mat, point3);
    self.p4 = mat4.transform(mat, point4);

    self.mat = mat4.clone(mat);
end

local renderer = getRenderer();

function BoxShadow:render()
    local shader = self.shader;

    -- Can only render as a shader.
    if not shader then return end

    shader:enable();

    local inset = 0;
    if self.inset then inset = 1 end

    shader:setUniforms({
        offset = self.offset,
        inset = inset,
        blur = self.blur,
        spread = self.spread
    });

    local p1, p2, p3, p4 = self.p1, self.p2, self.p3, self.p4;

    renderer:render(
        nil,
        p1.x, p1.y,
        p2.x, p2.y,
        p3.x, p3.y,
        p4.x, p4.y,
        1, 1, 1, 1,
        1, 1, 1, 1,
        1, 1, 1, 1,
        1, 1, 1, 1,
        nil
    );

    shader:disable();
end

_G.BoxShadow = BoxShadow;
return BoxShadow;
