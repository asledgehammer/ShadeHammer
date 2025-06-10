-- https://drafts.csswg.org/css-ui-3/


--- @alias CSSPositionValue 'static'|'relative'|'fixed'|'absolute'|'sticky' https://www.w3schools.com/css/css_positioning.asp
--- @alias CSSGlobalValue 'inherit'|'initial'|'revert'|'revert-layer'|'unset'
--- @alias CSSDisplayValue 'block'|'inline'|'inline-block'|'flex'|'inline-flex'|'grid'|'inline-grid'|'flow-root'|'none'|'contents'|'block flex'|'block flow'|'block flow-root'|'block grid'|'inline flex'|'inline flow'|'inline flow-root'|'inline grid'|'table'|'table-row'|'list-item'|CSSGlobalValue https://developer.mozilla.org/en-US/docs/Web/CSS/display

--- @class UnitValueParseResult
--- @field error string? If non-nil, the parse failed.
--- @field unit string?
--- @field value number?

--- @alias CursorValue 'auto'|'default'|'none'|'context-menu'|'help'|'pointer'|'progress'|'wait'|'cell'|'crosshair'|'text'|'vertical-text'|'alias'|'copy'|'move'|'no-drop'|'not-allowed'|'grab'|'grabbing'|'e-resize'|'n-resize'|'ne-resize'|'nw-resize'|'s-resize'|'se-resize'|'sw-resize'|'w-resize'|'ew-resize'|'ns-resize'|'nesw-resize'|'nwse-resize'|'col-resize'|'row-resize'|'all-scroll'|'zoom-in'|'zoom-out' https://drafts.csswg.org/css-ui-3/#cursor 
--- @alias BoxSizingValue 'content'|'border-box' https://drafts.csswg.org/css-ui-3/#box-sizing
--- @alias ResizeValue 'none'|'both'|'horizontal'|'vertical' https://drafts.csswg.org/css-ui-3/#resize
--- @alias TextOverflowValue 'clip'|'ellipsis' https://drafts.csswg.org/css-ui-3/#text-overflow