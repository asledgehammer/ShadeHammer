-- local SideMenu = require 'test42/SideMenu';

-- Events.OnGameStart.Add(function()
    
--     local o = SideMenu:new('third-right');

--     Events.OnKeyPressed.Add(function(key)
--         if key == Keyboard.KEY_0 then
--             if not o.open and not o.opening then
--                 o:show();
--             else
--                 o:hide();
--             end
--         elseif key == Keyboard.KEY_9 then
--             if o.mode == 'half-left' then
--                 o.mode = 'half-right';
--             elseif o.mode == 'half-right' then
--                 o.mode = 'third-left';
--             elseif o.mode == 'third-left' then
--                 o.mode = 'third-right';
--             elseif o.mode == 'third-right' then
--                 o.mode = 'half-left';
--             end
--             print(o.mode);
--         end
--     end);
    
--     o:addToUIManager();
--     print('Added SideMenu!');
-- end);
