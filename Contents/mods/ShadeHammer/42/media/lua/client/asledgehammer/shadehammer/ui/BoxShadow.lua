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

local COLOR_TRANSPARENT = { r = 0, g = 0, b = 0, a = 0 };

--- @class BoxShadow
--- @field element SHElement The element to draw under.
--- @field offset vec2
--- @field spread number
--- @field blur number
--- @field inset boolean
--- @field color SHColor?
--- @field shader LuaShader
local BoxShadow = class(
--- @param o BoxShadow
--- @param inset? boolean
--- @param offsetX? number
--- @param offsetY? number
--- @param blur? number
--- @param spread? number
--- @param color? SHColor
    function(o, inset, offsetX, offsetY, blur, spread, color)
        -- Default Parameters --
        inset = inset or false;
        offsetX = offsetX or 0;
        offsetY = offsetY or 0;
        blur = blur or 0;
        spread = spread or 0;
        color = color or nil;
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

    -- Spread inset by one pixel so that there's no bleeding of the backgroundColor on the edges.
    if self.inset then
        x1 = x1 - 4;
        y1 = y1 - 4;
        x2 = x2 + 8;
        y2 = y2 + 8;
    end

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

--- @param element SHElement
function BoxShadow:render(element)
    local shader = self.shader;

    -- Can only render as a shader.
    if not shader or not shader.valid then return end

    -- if self.inset then print('render()') end;

    local bWidth = element.size.width
        + (element.border.sizeL or element.border.size or 0)
        + (element.border.sizeR or element.border.size or 0);
    local bHeight = element.size.height
        + (element.border.sizeT or element.border.size or 0)
        + (element.border.sizeB or element.border.size or 0);

    local x1 = (-element.rotationPivot.x * bWidth);
    local y1 = (-element.rotationPivot.y * bHeight);

    -- Add the boxShadow offset.
    x1 = (x1 + self.offset.x);
    y1 = (y1 + self.offset.y);

    local x2 = x1 + bWidth;
    local y2 = y1 + bHeight;

    x1 = x1 - 1;
    y1 = y1 - 1;
    x2 = x2 + 2;
    y2 = y2 + 2;

    local tlx, tly, trx, try, brx, bry, blx, bly = element:rotateQuad2D(x1, y1, x2, y1, x2, y2, x1, y2);

    shader:enable();
    element.border:apply(element, shader);
    shader:applyDimension(x1, y1, x2, y2);
    shader:applyTransform(element.mat);

    if shader.uniforms.UIColor then
        shader.uniforms.UIColor:setRGBA( self.color or self.element.backgroundColor or COLOR_TRANSPARENT);
    end
    if shader.uniforms.UITexture then
        shader.uniforms.UITexture:setTexture(0);
    end
    if shader.uniforms.blur then
        shader.uniforms.blur:set1i(self.blur or 0);
    end
    if shader.uniforms.bInset then
        shader.uniforms.bInset:setBoolean(self.inset or false);
    end
    if shader.uniforms.spread then
        shader.uniforms.spread:set1i(self.spread or 0);
    end

    renderer:render(
        nil, -- Texture
        tlx, tly,
        trx, try,
        brx, bry,
        blx, bly,
        x1, y1, 0, 0,
        x2, y1, 0, 0,
        x2, y2, 0, 0,
        x1, y2, 0, 0,
        nil -- RGBA
    );

    element.border:reset(shader);
    shader:disable();
end

_G.BoxShadow = BoxShadow;
return BoxShadow;
