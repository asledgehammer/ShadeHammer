local tu = require 'asledgehammer/util/tableutils';

--- @param modID string
--- @param uri string
---
--- @return string | nil
local function readModFile(modID, uri)
    local reader = getModFileReader(modID, uri, false);

    -- A nil reader indicates a bad path or a missing file.
    if not reader then
        return nil;
    end

    ---------------------------------
    -- Read the contents of the file.
    local data = '';
    local line = reader:readLine();
    while line ~= nil do
        data = data .. line .. '\n';
        line = reader:readLine();
    end
    reader:close();
    ---------------------------------

    return data;
end

Events.OnGameBoot.Add(function()
    local xml2lua = require 'asledgehammer/io/xml/xml2lua';
    print(string.format('xml2lua v%s', xml2lua._VERSION));

    local handler = require 'asledgehammer/io/xml/xmlhandler/tree';


    local modID = 'shadehammer';
    local URI = 'media/ui/html/test.html';
    local xml = readModFile('\\' .. modID, URI);

    if not xml then
        print(string.format('File not found: modID = %s, URI = %s', modID, URI))
        return;
    end

    local parser = xml2lua.parser(handler);
    parser:parse(xml);

    print('XML: ');
    print(tu.tableToString(handler.root));
end);
