local spriteRenderer = getRenderer();

local UIUtils = {};

---comment
--- @param start number
--- @param stop number
--- @param value number
---
--- @return number
function UIUtils.lerp(start, stop, value)
    return start * (1 - value) + stop * value;
end

--- @param x number
---
--- @return number
function UIUtils.easeOutQuad(x)
    return 1.0 - (1.0 - x) * (1.0 - x);
end

--- @param x number
---
--- @return number
function UIUtils.easeInQuad(x)
    return x * x;
end

--- Draws a texture quad on the screen with both coordinate control for vertex positions and color control for each
--- vertex.
---
--- @param texture Texture|nil The texture to draw. (Set to nil to draw a solid color)
--- @param x_tl number The top-left X coordinate on the screen.
--- @param y_tl number The top-left Y coordinate on the screen.
--- @param x_tr number The top-right X coordinate on the screen.
--- @param y_tr number The top-right Y coordinate on the screen.
--- @param x_br number The bottom-right X coordinate on the screen.
--- @param y_br number The bottom-right Y coordinate on the screen.
--- @param x_bl number The bottom-left X coordinate on the screen.
--- @param y_bl number The bottom-left Y coordinate on the screen.
--- @param r_tl number The float value for the red color channel on the top-left. (0.0 -> 1.0)
--- @param g_tl number The float value for the green color channel on the top-left. (0.0 -> 1.0)
--- @param b_tl number The float value for the blue color channel on the top-left. (0.0 -> 1.0)
--- @param a_tl number The float value for the alpha color channel on the top-left. (0.0 -> 1.0)
--- @param r_tr number The float value for the red color channel on the top-right. (0.0 -> 1.0)
--- @param g_tr number The float value for the green color channel on the top-right. (0.0 -> 1.0)
--- @param b_tr number The float value for the blue color channel on the top-right. (0.0 -> 1.0)
--- @param a_tr number The float value for the alpha color channel on the top-right. (0.0 -> 1.0)
--- @param r_br number The float value for the red color channel on the bottom-right. (0.0 -> 1.0)
--- @param g_br number The float value for the green color channel on the bottom-right. (0.0 -> 1.0)
--- @param b_br number The float value for the blue color channel on the bottom-right. (0.0 -> 1.0)
--- @param a_br number The float value for the alpha color channel on the bottom-right. (0.0 -> 1.0)
--- @param r_bl number The float value for the red color channel on the bottom-left. (0.0 -> 1.0)
--- @param g_bl number The float value for the green color channel on the bottom-left. (0.0 -> 1.0)
--- @param b_bl number The float value for the blue color channel on the bottom-left. (0.0 -> 1.0)
--- @param a_bl number The float value for the alpha color channel on the bottom-left. (0.0 -> 1.0)
function UIUtils.drawTexQuadGradient(
    texture,
    x_tl, y_tl,
    x_tr, y_tr,
    x_br, y_br,
    x_bl, y_bl,
    r_tl, g_tl, b_tl, a_tl,
    r_tr, g_tr, b_tr, a_tr,
    r_br, g_br, b_br, a_br,
    r_bl, g_bl, b_bl, a_bl
)
    spriteRenderer:render(
        texture,
        x_tl, y_tl,
        x_tr, y_tr,
        x_br, y_br,
        x_bl, y_bl,
        r_tl, g_tl, b_tl, a_tl,
        r_tr, g_tr, b_tr, a_tr,
        r_br, g_br, b_br, a_br,
        r_bl, g_bl, b_bl, a_bl,
        nil
    );
end

--- Draws a texture quad on the screen with color control for each vertex on a square.
---
--- @param texture Texture|nil The texture to draw. (Set to nil to draw a solid color)
--- @param x number The top-left X coordinate on the screen.
--- @param y number The top-left Y coordinate on the screen.
--- @param width number The width of the square.
--- @param height number The height of the square.
--- @param r_tl number The float value for the red color channel on the top-left. (0.0 -> 1.0)
--- @param g_tl number The float value for the green color channel on the top-left. (0.0 -> 1.0)
--- @param b_tl number The float value for the blue color channel on the top-left. (0.0 -> 1.0)
--- @param a_tl number The float value for the alpha color channel on the top-left. (0.0 -> 1.0)
--- @param r_tr number The float value for the red color channel on the top-right. (0.0 -> 1.0)
--- @param g_tr number The float value for the green color channel on the top-right. (0.0 -> 1.0)
--- @param b_tr number The float value for the blue color channel on the top-right. (0.0 -> 1.0)
--- @param a_tr number The float value for the alpha color channel on the top-right. (0.0 -> 1.0)
--- @param r_br number The float value for the red color channel on the bottom-right. (0.0 -> 1.0)
--- @param g_br number The float value for the green color channel on the bottom-right. (0.0 -> 1.0)
--- @param b_br number The float value for the blue color channel on the bottom-right. (0.0 -> 1.0)
--- @param a_br number The float value for the alpha color channel on the bottom-right. (0.0 -> 1.0)
--- @param r_bl number The float value for the red color channel on the bottom-left. (0.0 -> 1.0)
--- @param g_bl number The float value for the green color channel on the bottom-left. (0.0 -> 1.0)
--- @param b_bl number The float value for the blue color channel on the bottom-left. (0.0 -> 1.0)
--- @param a_bl number The float value for the alpha color channel on the bottom-left. (0.0 -> 1.0)
function UIUtils.drawSquareGradient(
    texture,
    x,
    y,
    width,
    height,
    r_tl, g_tl, b_tl, a_tl,
    r_tr, g_tr, b_tr, a_tr,
    r_br, g_br, b_br, a_br,
    r_bl, g_bl, b_bl, a_bl
)
    local x1, y1 = x, y;
    local x2, y2 = x + width, y + height;

    UIUtils.drawTexQuadGradient(
        texture,
        x1, y1,
        x2, y1,
        x2, y2,
        x1, y2,
        r_tl, g_tl, b_tl, a_tl,
        r_tr, g_tr, b_tr, a_tr,
        r_br, g_br, b_br, a_br,
        r_bl, g_bl, b_bl, a_bl
    );
end

return UIUtils;
