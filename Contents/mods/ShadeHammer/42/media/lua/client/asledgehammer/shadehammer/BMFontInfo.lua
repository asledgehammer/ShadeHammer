---[[
--- @author asledgehammer, JabDoesThings 2025
---]]

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

--- @type BMFontInfoDefinition
local BMFontInfo = class 'BMFontInfo' (public) {

    field 'face' (private, final) {
        properties {
            type = 'string'
        },
        get {}
    },

    field 'size' (private, final) {
        properties {
            type = 'number'
        },
        get {}
    },

    field 'bold' (private, final) {
        properties {
            type = 'boolean'
        },
        get {}
    },

    field 'italic' (private, final) {
        properties {
            type = 'boolean'
        },
        get {}
    },

    field 'charset' (private, final) {
        properties {
            type = 'string'
        },
        get {}
    },

    field 'unicode' (private, final) {
        properties {
            type = 'boolean'
        },
        get {}
    },

    field 'stretchH' (private, final) {
        properties {
            type = 'number'
        },
        get {}
    },

    field 'smooth' (private, final) {
        properties {
            type = 'boolean'
        },
        get {}
    },

    field 'antialiased' (private, final) {
        properties {
            type = 'boolean'
        },
        get 'isAntiAliased' {}
    },

    field 'padding' (private, final) {
        properties {
            type = 'table'
        },
        get {}
    },

    field 'spacing' (private, final) {
        properties {
            type = 'table'
        },
        get {}
    },

    field 'outline' (private, final) {
        properties {
            type = 'number'
        },
        get {}
    },

    constructor(public) {
        parameters {
            { name = 'face',        type = 'string' },
            { name = 'size',        type = 'number' },
            { name = 'bold',        types = { 'number', 'boolean' } },
            { name = 'italic',      types = { 'number', 'boolean' } },
            { name = 'charset',     type = 'string' },
            { name = 'unicode',     types = { 'number', 'boolean' } },
            { name = 'stretchH',    type = 'number' },
            { name = 'smooth',      types = { 'number', 'boolean' } },
            { name = 'antialiased', types = { 'number', 'boolean' } },
            { name = 'padding',     type = 'table' },
            { name = 'spacing',     type = 'table' },
            { name = 'outline',     type = 'number' }
        },

        --- @param self BMFontInfo
        --- @param face string
        --- @param size number
        --- @param bold number|boolean
        --- @param italic number|boolean
        --- @param charset string
        --- @param unicode number|boolean
        --- @param stretchH number
        --- @param smooth number|boolean
        --- @param antialiased number|boolean
        --- @param padding string[]
        --- @param spacing string[]
        --- @param outline number
        function(self,
                 face,
                 size,
                 bold,
                 italic,
                 charset,
                 unicode,
                 stretchH,
                 smooth,
                 antialiased,
                 padding,
                 spacing,
                 outline)
            self.face = face;
            self.size = size;
            self.bold = bold == true or bold == 1;
            self.italic = italic == true or italic == 1;
            self.charset = charset;
            self.unicode = unicode == true or unicode == 1;
            self.stretchH = stretchH;
            self.smooth = smooth == true or smooth == 1;
            self.antialiased = antialiased == true or antialiased == 1;
            self.padding = padding;
            self.spacing = spacing;
            self.outline = outline;
        end
    }

};

return BMFontInfo;
