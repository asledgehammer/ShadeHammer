local cool = require 'cool';

local builder = cool.builder;
local import = builder.import;
local class = builder.class;
local constructor = builder.constructor;
local parameters = builder.parameters;
local field = builder.field;
local properties = builder.properties;
local get = builder.get;

local private = builder.private;
local public = builder.public;
local final = builder.final;

local BMFontInfo = import 'asledgehammer.shadehammer.BMFontInfo';

--- @type LuaFontDefinition
local LuaFont = class 'LuaFont' (final) {

    field 'name' (private, final) {
        properties {
            type = 'string'
        },
        get {}
    },

    field 'file' (private, final) {
        properties {
            type = 'string'
        },
        get {}
    },

    field 'info' (private, final) {
        properties {
            type = BMFontInfo
        },
    },

    field 'common' (private, final) {

    },

    field 'pages' (private, final) {

    },

    constructor {
        parameters {
            { name = 'name', type = 'string' },
            { name = 'file', type = 'string' }
        },
        function(self, name, file)
            self.name = name;
            self.file = file;
        end
    }


};

return LuaFont;
