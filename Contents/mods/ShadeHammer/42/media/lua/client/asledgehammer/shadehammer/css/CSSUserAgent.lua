local CSSStyleSet = require 'asledgehammer/shadehammer/css/CSSStyleSet';
local CSSSelector = require 'asledgehammer/shadehammer/css/CSSSelector';

--- @type table<string,CSSStyleSet>
local UserAgent = {};

--- @param name string
--- @param rules table?
local function createUserAgent(name, rules)
    UserAgent[name] = CSSStyleSet({ CSSSelector(name) }, rules, true);
end

createUserAgent('a:link', {
    color = 'rgb(0, 0, 238)', -- (Internal value)
    cursor = 'auto',
    textDecoration = 'underline'
});
createUserAgent('a:visited', {
    color = 'rgb(85, 26, 139)', -- (Internal value)
    cursor = 'auto',
    textDecoration = 'underline'
});
createUserAgent('a:link:active', {
    color = 'rgb(255, 0, 0)', -- (Internal value)
});
createUserAgent('a:visited:active', {
    color = 'rgb(255, 0, 0)', -- (Internal value)
});
createUserAgent('abbr');
createUserAgent('address', {
    display = 'block',
    fontStyle = 'italic'
});
createUserAgent('area', { display = 'none' });
createUserAgent('article', { display = 'block' });
createUserAgent('aside', { display = 'block' });
createUserAgent('audio');
createUserAgent('b', { fontWeight = 'bold' });
createUserAgent('base');
createUserAgent('bdi');
createUserAgent('bdo', { unicodeBidi = 'bidi-override' });
createUserAgent('blockquote', {
    display = 'block',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '40px',
    marginRight = '40px',
});
createUserAgent('body', {
    display = 'block',
    margin = '8px'
});
createUserAgent('body:focus', { outline = 'none' });
createUserAgent('br');
createUserAgent('button');
createUserAgent('canvas');
createUserAgent('caption', {
    display = 'table-caption',
    textAlign = 'center'
});
createUserAgent('cite', { fontStyle = 'italic' });
createUserAgent('code', { fontFamily = 'monospace' });
createUserAgent('col', { display = 'table-column' });
createUserAgent('colgroup', { display = 'table-column-group' });
createUserAgent('datalist', { display = 'none' });
createUserAgent('dd', {
    display = 'block',
    marginLeft = '40px'
});
createUserAgent('del', { textDecoration = 'line-through' });
createUserAgent('details', { display = 'block' });
createUserAgent('dfn', { fontStyle = 'italic' });
createUserAgent('dialog');
createUserAgent('div', { display = 'block' });
createUserAgent('dl', {
    display = 'block',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '0',
    marginRight = '0'
});
createUserAgent('dt', { display = 'block' });
createUserAgent('em', { fontStyle = 'italic' });
createUserAgent('embed:focus', { outline = 'none' });
createUserAgent('fieldset', {
    display = 'block',
    marginLeft = '2px',
    marginRight = '2px',
    paddingTop = '0.35em',
    paddingBottom = '0.625em',
    paddingLeft = '0.75em',
    paddingRight = '0.75em',
    border = '2px groove' -- (Internal value)
});
createUserAgent('figcaption', { display = 'block' });
createUserAgent('figure', {
    display = 'block',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '40px',
    marginRight = '40px'
});
createUserAgent('footer', { display = 'block' });
createUserAgent('form', {
    display = 'block',
    marginTop = '0em'
});
createUserAgent('h1', {
    display = 'block',
    fontSize = '2em',
    marginTop = '0.67em',
    marginBottom = '0.67em',
    marginLeft = '0',
    marginRight = '0',
    fontWeight = 'bold'
});
createUserAgent('h2', {
    display = 'block',
    fontSize = '1.5em',
    marginTop = '0.83em',
    marginBottom = '0.83em',
    marginLeft = '0',
    marginRight = '0',
    fontWeight = 'bold'
});
createUserAgent('h3', {
    display = 'block',
    fontSize = '1.17em',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '0',
    marginRight = '0',
    fontWeight = 'bold'
});
createUserAgent('h4', {
    display = 'block',
    marginTop = '1.33em',
    marginBottom = '1.33em',
    marginLeft = '0',
    marginRight = '0',
    fontWeight = 'bold'
});
createUserAgent('h5', {
    display = 'block',
    fontSize = '.83em',
    marginTop = '1.67em',
    marginBottom = '1.67em',
    marginLeft = '0',
    marginRight = '0',
    fontWeight = 'bold'
});
createUserAgent('h6', {
    display = 'block',
    fontSize = '.67em',
    marginTop = '2.33em',
    marginBottom = '2.33em',
    marginLeft = '0',
    marginRight = '0',
    fontWeight = 'bold'
});
createUserAgent('head', { display = 'none' });
createUserAgent('header', { display = 'block' });
createUserAgent('hr', {
    display = 'block',
    marginTop = '0.5em',
    marginBottom = '0.5em',
    marginLeft = 'auto',
    marginRight = 'auto',
    borderStyle = 'inset',
    borderWidth = '1px'
});
createUserAgent('html', { display = 'block' });
createUserAgent('html:focus', { outline = 'none' });
createUserAgent('i', { fontStyle = 'italic' });
createUserAgent('iframe:focus', { outline = 'none' });
createUserAgent('iframe[seamless]', { display = 'block' });
createUserAgent('img', { display = 'inline-block' });
createUserAgent('input');
createUserAgent('ins', { textDecoration = 'underline' });
createUserAgent('kbd', { fontFamily = 'monospace' });
createUserAgent('label', { cursor = 'default' });
createUserAgent('legend', {
    display = 'block',
    paddingLeft = '2px',
    paddingRight = '2px',
    border = 'none'
});
createUserAgent('li', { display = 'list-item' });
createUserAgent('link', { display = 'none' });
createUserAgent('main');
createUserAgent('map', { display = 'inline' });
createUserAgent('mark', {
    backgroundColor = 'yellow',
    color = 'black'
});
createUserAgent('menu', {
    display = 'block',
    listStyleType = 'disc',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '0',
    marginRight = '0',
    paddingLeft = '40px'
});
createUserAgent('menuitem');
createUserAgent('meta');
createUserAgent('meter');
createUserAgent('nav', { display = 'block' });
createUserAgent('noscript');
createUserAgent('object:focus', { outline = 'none' });
createUserAgent('ol', {
    display = 'block',
    listStyleType = 'decimal',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '0',
    marginRight = '0',
    paddingLeft = '40px'
});
createUserAgent('optgroup');
createUserAgent('output', { display = 'inline' });
createUserAgent('p', {
    display = 'block',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '0',
    marginRight = '0'
});
createUserAgent('param', { display = 'none' });
createUserAgent('picture');
createUserAgent('pre', {
    display = 'block',
    fontFamily = 'monospace',
    whiteSpace = 'pre',
    margin = '1em 0',
});
createUserAgent('progress');
createUserAgent('q', { display = 'inline' });
createUserAgent('q::before', { content = 'open-quote' });
createUserAgent('q::after', { content = 'close-quote' });
createUserAgent('rp');
createUserAgent('rt', { lineHeight = 'normal' });
createUserAgent('ruby');
createUserAgent('s', { textDecoration = 'line-through' });
createUserAgent('samp', { fontFamily = 'monospace' });
createUserAgent('script', { display = 'none' });
createUserAgent('section', { display = 'block' });
createUserAgent('select');
createUserAgent('small', { fontSize = 'smaller' });
createUserAgent('source');
createUserAgent('span', { display = 'inline' });
createUserAgent('strike', { textDecoration = 'line-through' });
createUserAgent('strong', { fontWeight = 'bold' });
createUserAgent('style', { display = 'none' });
createUserAgent('sub', {
    verticalAlign = 'sub',
    fontSize = 'smaller'
});
createUserAgent('summary', { display = 'block' });
createUserAgent('sup', {
    verticalAlign = 'super',
    fontSize = 'smaller'
});
createUserAgent('table', {
    display = 'table',
    borderCollapse = 'separate',
    borderSpacing = '2px',
    borderColor = 'gray'
});
createUserAgent('tbody', {
    display = 'table-row-group',
    verticalAlign = 'middle',
    borderColor = 'inherit'
});
createUserAgent('td', {
    display = 'table-cell',
    verticalAlign = 'inherit'
});
createUserAgent('template');
createUserAgent('textarea');
createUserAgent('tfoot', {
    display = 'table-footer-group',
    verticalAlign = 'middle',
    borderColor = 'inherit'
});
createUserAgent('th', {
    display = 'table-cell',
    verticalAlign = 'inherit',
    fontWeight = 'bold',
    textAlign = 'center'
});
createUserAgent('thead', {
    display = 'table-header-group',
    verticalAlign = 'middle',
    borderColor = 'inherit'
});
createUserAgent('time');
createUserAgent('title', { display = 'none' });
createUserAgent('tr', {
    display = 'table-row',
    verticalAlign = 'inherit',
    borderColor = 'inherit'
});
createUserAgent('track');
createUserAgent('u', { textDecoration = 'underline' });
createUserAgent('ul', {
    display = 'block',
    listStyleType = 'disc',
    marginTop = '1em',
    marginBottom = '1em',
    marginLeft = '0',
    marginRight = '0',
    paddingLeft = '40px'
});
createUserAgent('var', { fontStyle = 'italic' });
createUserAgent('video');
createUserAgent('wbr');

return UserAgent;
