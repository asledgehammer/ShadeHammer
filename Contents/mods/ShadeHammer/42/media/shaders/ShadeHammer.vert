#version 330
#extension GL_ARB_explicit_uniform_location : enable

layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aUV;
layout (location = 2) in vec4 aColor;

uniform mat4 ModelViewProjection;
uniform vec4 dim;

out vec4 vColor;
out vec2 vUV;
out vec2 localPosition;
out vec2 localUV;

/**
 * 4 pixels padding for anti-aliasing.
 */
const int RENDER_PADDING = 4;

mat4 inverse(mat4 m) {
	float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2], a03 = m[0][3], a10 = m[1][0], a11 = m[1][1], a12 = m[1][2], a13 = m[1][3], a20 = m[2][0], a21 = m[2][1], a22 = m[2][2], a23 = m[2][3], a30 = m[3][0], a31 = m[3][1], a32 = m[3][2], a33 = m[3][3], b00 = a00 * a11 - a01 * a10, b01 = a00 * a12 - a02 * a10, b02 = a00 * a13 - a03 * a10, b03 = a01 * a12 - a02 * a11, b04 = a01 * a13 - a03 * a11, b05 = a02 * a13 - a03 * a12, b06 = a20 * a31 - a21 * a30, b07 = a20 * a32 - a22 * a30, b08 = a20 * a33 - a23 * a30, b09 = a21 * a32 - a22 * a31, b10 = a21 * a33 - a23 * a31, b11 = a22 * a33 - a23 * a32, det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

	return mat4(a11 * b11 - a12 * b10 + a13 * b09, a02 * b10 - a01 * b11 - a03 * b09, a31 * b05 - a32 * b04 + a33 * b03, a22 * b04 - a21 * b05 - a23 * b03, a12 * b08 - a10 * b11 - a13 * b07, a00 * b11 - a02 * b08 + a03 * b07, a32 * b02 - a30 * b05 - a33 * b01, a20 * b05 - a22 * b02 + a23 * b01, a10 * b10 - a11 * b08 + a13 * b06, a01 * b08 - a00 * b10 - a03 * b06, a30 * b04 - a31 * b02 + a33 * b00, a21 * b02 - a20 * b04 - a23 * b00, a11 * b07 - a10 * b09 - a12 * b06, a00 * b09 - a01 * b07 + a02 * b06, a31 * b01 - a30 * b03 - a32 * b00, a20 * b03 - a21 * b01 + a22 * b00) / det;
}

float lerp(float start, float stop, float value) {
	return start * (1 - value) + stop * value;
}

void main(void) {
	vec3 pos = vec3(aPos.x, aPos.y, 0);
	vec4 pos4 = vec4(pos, 1.0);

	gl_Position = ModelViewProjection * pos4;

	localPosition = aColor.xy;// - vec2(4, 4);
	localUV = vec2(clamp(lerp(dim.x, dim.z, localPosition.x), 0, 1), clamp(lerp(dim.y, dim.w, localPosition.y), 0, 1));
	// localUV -= vec2(4 / (dim.z - 4), 4 / (dim.w - 4));
	vColor = vec4(1, 1, 1, 1);
	vUV = aUV;
}
