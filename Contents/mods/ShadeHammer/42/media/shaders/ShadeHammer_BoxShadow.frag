#version 330
#extension GL_ARB_explicit_uniform_location : enable

uniform vec4 UIColor;
uniform sampler2D DIFFUSE;
uniform int UITexture = 0;

uniform int borderRadiusTL;
uniform int borderRadiusTR;
uniform int borderRadiusBR;
uniform int borderRadiusBL;

uniform vec4 dim;

in vec4 vColor;
in vec2 vUV;
in vec2 localUV;
in vec2 localPosition;

uniform int bInset;
uniform int blur;
uniform int spread;

vec4 sampleClamp2edge(sampler2D texture, vec2 uv) {
	vec2 cuv = vec2(clamp(uv.x, 0.00001, 0.99999), clamp(uv.y, 0.00001, 0.99999));
	return texture2D(texture, cuv);
}

float roundedBoxSDF(vec2 center, vec2 size, float radius) {
	return length(max(abs(center) - size + radius, 0.0)) - radius;
}

float doThing(vec2 pixel, vec2 size, float radius, float softness) {
	highp float distance = roundedBoxSDF(pixel - (size / 2.0), size / 2.0, radius);
	highp float result = smoothstep(0.0, softness, distance);
	// if (bInset == 0) {
	result = 1.0 - result;
	// }
	return result;
}

vec4 getBaseColor() {
	if (UITexture != 0) {
		return sampleClamp2edge(DIFFUSE, vUV.st) * UIColor;
	} else {
		return UIColor;
	}
}

highp float getShapeAlpha(float radius, float softness) {
	highp vec2 size = vec2((dim.z - dim.x), (dim.w - dim.y));
	highp vec2 pixel = vec2((localUV.x * size.x), (localUV.y * size.y));
	pixel -= 1;
	size -= 2;
	highp float distance = roundedBoxSDF(pixel - (size / 2.0), size / 2.0, radius);
	return 1.0 - smoothstep(0.0, softness, distance);
}

void outset() {
	// if (bInset != 0) {
	// 	gl_FragColor = vec4(0,1,0,1);
	// 	return;
	// }

	vec4 col = getBaseColor();

	highp vec2 size = vec2((dim.z - dim.x), (dim.w - dim.y));
	highp vec2 pixel = vec2((localUV.x * size.x), (localUV.y * size.y));

	// Outer-padding adjustments
	size -= blur * 2;
	pixel -= blur;

	// The left side.
	if (localUV.x < 0.5) {
		// The top-left corner.
		if (localUV.y < 0.5) {
			highp float alphaBorder = doThing(pixel, size, borderRadiusTL, blur);
			col = vec4(col.rgb, col.a * alphaBorder);
		}
		// The bottom-left corner.
		else {
			highp float alphaBorder = doThing(pixel, size, borderRadiusBL, blur);
			col = vec4(col.rgb, col.a * alphaBorder);
		}
	} 
	// The right side.
	else {
		// The top-right corner.
		if (localUV.y < 0.5) {
			highp float alphaBorder = doThing(pixel, size, borderRadiusTR, blur);
			col = vec4(col.rgb, col.a * alphaBorder);
		}
		// The bottom-right corner.
		else {
			highp float alphaBorder = doThing(pixel, size, borderRadiusBR, blur);
			col = vec4(col.rgb, col.a * alphaBorder);
		}
	}

	// Set the result corner.
	gl_FragColor = col;
}

void inset() {
	vec4 col = getBaseColor();
	// gl_FragColor = col;
	// return;


	float compound = (blur + spread);
	vec2 size = vec2((dim.z - dim.x), (dim.w - dim.y));
	vec2 pixel = vec2((localUV.x * size.x), (localUV.y * size.y));

	pixel -= compound;
	size -= compound * 2;

	vec2 center = (size / 2);
	
	// The left side.
	if (pixel.x < center.x) {
		// The top-left corner.
		if (pixel.y < center.y) {
			float alphaBorder = doThing(pixel, size, max(0, borderRadiusTL - compound), blur + spread);
			highp float shapeAlpha = getShapeAlpha(borderRadiusTL, 1);
			col = vec4(col.rgb, alphaBorder);
			col.a = (1.0 - col.a) * UIColor.a;
			col.a *= shapeAlpha;
		}
		// The bottom-left corner.
		else {
			float alphaBorder = doThing(pixel, size, max(0, borderRadiusBL - compound), blur + spread);
			highp float shapeAlpha = getShapeAlpha(borderRadiusBL, 1);
			col = vec4(col.rgb, alphaBorder);
			col.a = (1.0 - col.a) * UIColor.a;
			col.a *= shapeAlpha;
		}
	} 
	// The right side.
	else {
		// The top-right corner.
		if (pixel.y < center.y) {
			float alphaBorder = doThing(pixel, size, max(0, borderRadiusTR - compound), blur + spread);
			highp float shapeAlpha = getShapeAlpha(borderRadiusTR, 1);
			col = vec4(col.rgb, alphaBorder);
			col.a = (1.0 - col.a) * UIColor.a;
			col.a *= shapeAlpha;
		}
		// The bottom-right corner.
		else {
			float alphaBorder = doThing(pixel, size, max(0, borderRadiusBR - compound), blur + spread);
			highp float shapeAlpha = getShapeAlpha(borderRadiusBR, 1);
			col = vec4(col.rgb, alphaBorder);
			col.a = (1.0 - col.a) * UIColor.a;
			col.a *= shapeAlpha;
		}
	}

	gl_FragColor = col;
}

void main() {
	if (bInset != 0) {
		inset();
	} else {
		outset();
	}
}
