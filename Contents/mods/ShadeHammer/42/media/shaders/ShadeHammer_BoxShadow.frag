#version 330
#extension GL_ARB_explicit_uniform_location : enable

uniform float screenWidth;
uniform float screenHeight;
uniform vec4 screenInfo;

uniform sampler2D DIFFUSE;

uniform vec4 UIRectangle;
uniform vec4 UIColor;

in mat4 transform;
in vec4 vColor;
in vec2 vUV;

// blend two color by alpha
vec4 blend(vec4 src, vec4 append) {
	return vec4(src.rgb * (1.0 - append.a) + append.rgb * append.a, 1.0 - (1.0 - src.a) * (1.0 - append.a));
}

// approximation to the gaussian integral [x, infty)
float gi(float x) {
	float i6 = 1.0 / 6.0;
	float i4 = 1.0 / 4.0;
	float i3 = 1.0 / 3.0;

	if (x > 1.5)
		return 0.0;
	if (x < -1.5)
		return 1.0;

	float x2 = x * x;
	float x3 = x2 * x;

	if (x > 0.5)
		return .5625 - (x3 * i6 - 3. * x2 * i4 + 1.125 * x);
	if (x > -0.5)
		return 0.5 - (0.75 * x - x3 * i3);
	return 0.4375 + (-x3 * i6 - 3. * x2 * i4 - 1.125 * x);
}

// create a line shadow mask
float lineShadow(vec2 border, float pos, float sigma) {
	float t = (border.y - border.x) / sigma;

	float pos1 = ((border.x - pos) / sigma) * 1.5;
	float pos2 = ((pos - border.y) / sigma) * 1.5;

	return 1.0 - abs(gi(pos1) - gi(pos2));
}

// create a rect shadow by two line shadow
float rectShadow(vec4 rect, vec2 point, float sigma) {

	float lineV = lineShadow(vec2(rect.x, rect.x + rect.z), point.x, sigma);
	float lineH = lineShadow(vec2(rect.y, rect.y + rect.w), point.y, sigma);

	return lineV * lineH;
}

// draw shadow
vec4 drawRectShadow(vec2 pos, vec4 rect, vec4 color, float sigma) {
	vec4 result = color;

	float shadowMask = rectShadow(rect, pos, sigma);

	result.a *= shadowMask;

	return result;
}

// check a point in a rect
float insideBox(vec2 v, vec4 pRect) {
	vec2 s = step(pRect.xy, v) - step(pRect.zw, v);
	return s.x * s.y;
}

// draw rect
vec4 drawRect(vec2 pos, vec4 rect, vec4 color) {
	vec4 result = color;

	result.a *= insideBox(pos, vec4(rect.xy, rect.xy + rect.zw));
	return result;
}

vec3 hsv2rgb(in vec3 c) {
	vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);

	rgb = rgb * rgb * (3.0 - 2.0 * rgb); // cubic smoothing	

	return c.z * mix(vec3(1.0), rgb, c.y);
}

void main() {
	gl_FragColor = vec4(1,1,0,1);
}
