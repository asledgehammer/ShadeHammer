--- @class CSSRuleProperties
---
--- @field inherited boolean https://www.w3.org/TR/css-cascade/#inherited-property
--- @field initial string|nil (If nil then the rules must define it) https://www.w3.org/TR/css-cascade/#initial-values

--- @type table<string,CSSRuleProperties>
local RuleProperties = {};

--- @param values table<string,CSSRuleProperties>
local function setRuleProperties(values)
    for name, value in pairs(values) do
        RuleProperties[name] = value;
    end
end

setRuleProperties({

    -- MARK: - border-color

    -- https://www.w3.org/TR/CSS2/box.html#propdef-border-top-color
    borderTopColor = {
        inherited = false,
        initial = 'reference:color', -- (The value of the 'color' property)
    },
    borderRightColor = {
        inherited = false,
        initial = 'reference:color', -- (The value of the 'color' property)
    },
    borderBottomColor = {
        inherited = false,
        initial = 'reference:color', -- (The value of the 'color' property)
    },
    borderLeftColor = {
        inherited = false,
        initial = 'reference:color', -- (The value of the 'color' property)
    },
    borderColor = {
        inherited = false,
        initial = nil, -- (The value of the 'color' property)
    },

    -- MARK: - border-style

    -- https://www.w3.org/TR/CSS2/box.html#propdef-border-top-style
    borderTopStyle = {
        inherited = false,
        initial = 'none'
    },
    borderRightStyle = {
        inherited = false,
        initial = 'none'
    },
    borderBottomStyle = {
        inherited = false,
        initial = 'none'
    },
    borderLeftStyle = {
        inherited = false,
        initial = 'none'
    },
    borderStyle = {
        inherited = false,
        initial = nil
    },

    -- MARK: - border-top

    -- https://www.w3.org/TR/CSS2/box.html#propdef-border-top
    borderTop = {
        inherited = false,
        initial = nil
    },
    borderRight = {
        inherited = false,
        initial = nil
    },
    borderBottom = {
        inherited = false,
        initial = nil
    },
    borderLeft = {
        inherited = false,
        initial = nil
    },
    border = {
        inherited = false,
        initial = nil
    },

    -- MARK: - border-top

    -- https://www.w3.org/TR/CSS2/box.html#propdef-border-top-width
    borderTopWidth = {
        inherited = false,
        initial = 'medium'
    },
    borderRightWidth = {
        inherited = false,
        initial = 'medium'
    },
    borderBottomWidth = {
        inherited = false,
        initial = 'medium'
    },
    borderLeftWidth = {
        inherited = false,
        initial = 'medium'
    },
    borderWidth = {
        inherited = false,
        initial = nil
    },

    -- MARK: - bottom

    -- https://www.w3.org/TR/CSS2/visuren.html#propdef-bottom
    bottom = {
        inherited = false,
        initial = 'auto'
    },

    -- MARK: - box-sizing

    -- https://drafts.csswg.org/css-ui-3/#box-sizing
    boxSizing = {
        inherited = false,
        initial = 'content-box'
    },

    -- MARK: - caret-color

    -- https://drafts.csswg.org/css-ui-3/#caret-color
    caretColor = {
        inherited = true,
        initial = 'auto'
    },

    -- MARK: - cursor

    -- https://drafts.csswg.org/css-ui-3/#cursor
    cursor = {
        inherited = true,
        initial = 'auto'
    },

    -- MARK: - display

    -- https://www.w3.org/TR/CSS2/visuren.html#propdef-display
    display = {
        inherited = false,
        initial = 'inline'
    },

    -- MARK: - left

    -- https://www.w3.org/TR/CSS2/visuren.html#propdef-left
    left = {
        inherited = false,
        initial = 'auto'
    },

    -- MARK: - margin

    -- https://www.w3.org/TR/CSS2/box.html#value-def-margin-width
    marginTop = {
        inherited = false,
        initial = '0'
    },
    marginBottom = {
        inherited = false,
        initial = '0'
    },
    marginRight = {
        inherited = false,
        initial = '0'
    },
    marginLeft = {
        inherited = false,
        initial = '0'
    },
    margin = {
        inherited = false,
        initial = nil
    },

    -- MARK: - outline

    -- https://drafts.csswg.org/css-ui-3/#outline
    outline = {
        inherited = false,
        initial = nil
    },
    -- https://drafts.csswg.org/css-ui-3/#outline-color
    outlineColor = {
        inherited = false,
        initial = 'invert'
    },
    -- https://drafts.csswg.org/css-ui-3/#outline-offset
    outlineOffset = {
        inherited = false,
        initial = '0',
    },
    -- https://drafts.csswg.org/css-ui-3/#outline-style
    outlineStyle = {
        inherited = false,
        initial = 'none'
    },
    -- https://drafts.csswg.org/css-ui-3/#outline-width
    outlineWidth = {
        inherited = false,
        initial = 'medium'
    },

    -- MARK: - padding

    -- https://www.w3.org/TR/CSS2/box.html#propdef-padding-top
    paddingTop = {
        inherited = false,
        initial = '0'
    },
    paddingBottom = {
        inherited = false,
        initial = '0'
    },
    paddingRight = {
        inherited = false,
        initial = '0'
    },
    paddingLeft = {
        inherited = false,
        initial = '0'
    },
    padding = {
        inherited = false,
        initial = nil
    },

    -- MARK: - position

    -- https://www.w3.org/TR/CSS2/visuren.html#propdef-position
    position = {
        inherited = false,
        initial = 'static',
    },

    -- MARK: - resize

    -- https://drafts.csswg.org/css-ui-3/#resize
    resize = {
        inherited = false,
        initial = 'none'
    },

    -- MARK: - right

    -- https://www.w3.org/TR/CSS2/visuren.html#propdef-right
    right = {
        inherited = false,
        initial = 'auto'
    },

    -- MARK: - text-overflow

    -- https://drafts.csswg.org/css-ui-3/#text-overflow
    textOverflow = {
        inherited = false,
        initial = 'clip'
    },

    -- MARK: - top

    -- https://www.w3.org/TR/CSS2/visuren.html#propdef-top
    top = {
        inherited = false,
        initial = 'auto'
    },

});

setRuleProperties(RuleProperties);

return RuleProperties;
