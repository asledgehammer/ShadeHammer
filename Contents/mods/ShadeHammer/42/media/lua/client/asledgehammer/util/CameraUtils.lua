local core = getCore();

--- comment
--- @param screenX number
--- @param screenY number
--- @return number
--- @return number
local function toIsoPlayerRelative(screenX, screenY)
    local player = getPlayer();
    local var3 = screenX;
    local var4 = screenY;
    local floor = player:getZ();
    local var5 = (var3 + 2.0 * var4) / (64.0 * 2.0 --[[ Core.getTileScale()--]]);
    local var6 = (var3 - 2.0 * var4) / (-64.0 * 2.0 --[[ Core.getTileScale()--]]);
    var5 = var5 + (3.0 * floor);
    var6 = var6 + (3.0 * floor);
    return var5, var6;
end

local function calculateCurrentZoom()
    local zoom = core:getZoom(0);
    local nextZoom = core:getNextZoom(0, 0);
    local var6 = 0.004 * GameTime.getInstance():getMultiplier() / GameTime.getInstance():getTrueMultiplier() * 1.5;
    if not core:getAutoZoom(0) then var6 = var6 * 5.0 end
    if zoom < nextZoom then
        zoom = zoom + var6;
        if zoom > nextZoom then zoom = nextZoom end
    elseif zoom > nextZoom then
        zoom = zoom - var6;
        if zoom < nextZoom then zoom = nextZoom end
    end
    return zoom;
end

return {
    calculateCurrentZoom = calculateCurrentZoom,
    toIsoPlayerRelative = toIsoPlayerRelative,
};
