local reflect = require 'Reflect';

local x = function(foo)
    print(tostring(foo) .. 'bar')
    for i = 1, 10 do
        foo = 'foo';
    end
end

Events.OnGameBoot.Add(function()
    pcall(function()
        print('### TEST API ###');
        -- local xPrototype = reflect.getJavaFieldValue(x, 'prototype');
        -- local xLines = reflect.getJavaFieldValue(xPrototype, 'lines');

        -- DebugLog.log(DebugType.Lua, xLines);
        -- local pzal = PZArrayList.new(Integer.class, 16);
        -- pzal:addAll(xLines);

        -- local vec = Vector3f.new(xLines);
        -- print(vec);

        -- ObjectDebuggerLua.Log(xLines);
    end);
    -- local startLine = getFirstLineOfClosure(x);
    -- local lastLine = getLastLineOfClosure(x);
    -- local file = getFilenameOfClosure(x);
    -- print(string.format('file: "%s", startLine: %i, lastLine: %i', file, startLine, lastLine));
end);
