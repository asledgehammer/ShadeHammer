#version 330
#extension GL_ARB_explicit_uniform_location : enable

const float PI = 3.14159265359;     // PI
const float PI2 = 6.28318530718;    // PI * 2
const float PID2 = PI / 2.0;        // PI / 2
const float PID4 = PI / 4.0;        // PI / 4
const float PID8 = PI / 8.0;        // PI / 8

uniform float screenWidth;
uniform float screenHeight;
uniform vec2 TextureSize;
uniform vec4 screenInfo;

uniform vec4 UIColor;
uniform sampler2D DIFFUSE;
uniform int UITexture = 0;

uniform vec4 borderColorT;
uniform vec4 borderColorL;
uniform vec4 borderColorB;
uniform vec4 borderColorR;
uniform int borderSizeT;
uniform int borderSizeL;
uniform int borderSizeB;
uniform int borderSizeR;
uniform int borderRadiusTL;
uniform int borderRadiusTR;
uniform int borderRadiusBR;
uniform int borderRadiusBL;

uniform int bUseAntiAliasingInner = 0;
uniform int bUseAntiAliasingOuter = 1;

uniform int bBorder = 0;

/**
 * 4 pixels padding for anti-aliasing.
 */
const int RENDER_PADDING = 4;

uniform vec4 dim;

in vec4 vColor;
in vec2 vUV;
in vec2 localUV;
in vec2 localPosition;

vec4 sampleClamp2edge(sampler2D texture, vec2 uv) {
	vec2 cuv = vec2(clamp(uv.x, 0.00001, 0.99999), clamp(uv.y, 0.00001, 0.99999));
	return texture2D(texture, cuv);
}

float roundedBoxSDF(vec2 center, vec2 size, float radius) {
	return length(max(abs(center) - size + radius, 0.0)) - radius;
}

float doThing(vec2 pixel, vec2 size, float radius, float softness) {
	float distance = roundedBoxSDF(pixel - (size / 2.0), size / 2.0, radius);
	return 1.0 - smoothstep(0.0, min(softness, 1.0) * 1.8, distance);
}

void main() {

	// Grab the current color context.
	vec4 col;
	if (UITexture != 0) {
		col = sampleClamp2edge(DIFFUSE, vUV.st) * UIColor;
		gl_FragColor = col;
		// TODO: Implement rounding features with textured backgrounds.
		return;
	} else {
		col = UIColor;
	}

	float softnessInner = bUseAntiAliasingInner == 1 || bBorder == 1 ? 0.5 : 0.0;
	float softnessOuter = bUseAntiAliasingOuter == 1 || bBorder == 1 ? 0.5 : 0.0;

	float bSizeT = borderSizeT;
	float bSizeL = borderSizeL;
	float bSizeB = borderSizeB;
	float bSizeR = borderSizeR;

	vec2 size = vec2((dim.z - dim.x), (dim.w - dim.y));
	vec2 pixel = vec2((localUV.x * size.x), (localUV.y * size.y));

	pixel -= 4;
	size -= 8;

	vec2 sizeBase = size - (vec2(bSizeL + bSizeR, bSizeT + bSizeB));
	vec2 pixelBase = (pixel - vec2(bSizeL, bSizeT));

	vec4 baseColor;
	vec4 borderColor = col;

	// Calculate the inside radii of the border using the average thickness of both sides.
	float borderRadiusInnerTL = max(borderRadiusTL - max(bSizeT, bSizeL), 0);
	float borderRadiusInnerTR = max(borderRadiusTR - max(bSizeT, bSizeR), 0);
	float borderRadiusInnerBL = max(borderRadiusBL - max(bSizeB, bSizeL), 0);
	float borderRadiusInnerBR = max(borderRadiusBR - max(bSizeB, bSizeR), 0);

	vec2 bTL = vec2(borderRadiusTL + ((borderSizeT + borderSizeL) / 2), borderRadiusTL + ((borderSizeT + borderSizeL) / 2));
	vec2 bTR = vec2(size.x - (borderRadiusTR + max(borderSizeT, borderSizeR)), borderRadiusTR + max(borderSizeT, borderSizeR));
	vec2 bBL = vec2(borderRadiusBL + ((borderSizeB + borderSizeL) / 2), size.y - (borderRadiusBL + ((borderSizeB + borderSizeL) / 2)));
	vec2 bBR = vec2(size.x - (borderRadiusBR + ((borderSizeB + borderSizeR) / 2)), size.y - (borderRadiusBR + ((borderSizeB + borderSizeR) / 2)));

	if (bBorder == 1) {
		col = vec4(0,0,0,0);
		// The top border region.
		if (pixel.y < bTL.y) {
			// The top-left border region.
			if (pixel.x < bTL.x) {
				vec2 diff = normalize(pixel - bTL);
				float angle = atan(diff.y, diff.x);
				if (angle > PID4 * -3) { // Top-Left-Top
					borderColor = borderColorT;
				} else { // Top-Left-Left
					borderColor = borderColorL;
				}
			} 

			// The top-right border region.
			else if (pixel.x > bTR.x) {
				vec2 diff = normalize(pixel - bTR);
				float angle = atan(diff.y, diff.x);

				if (angle > PID4 * -1) { // Top-Right-Right
					borderColor = borderColorR;
				} else { // Top-Right-Top
					borderColor = borderColorT;
				}
			} else { // Top
				borderColor = borderColorT;
			}
		} 
		// The bottom border region.
		else if (pixel.y > bBL.y) {
			// The bottom-left border region.
			if (pixel.x < bBL.x) {
				vec2 diff = normalize(pixel - bBL);
				float angle = atan(diff.y, diff.x);
				if (angle > PID4 * 3) {
					borderColor = borderColorL;
				} else {
					borderColor = borderColorB;
				}
			} 
			// The bottom-right border region.
			else if (pixel.x > bBR.x) {
				vec2 diff = normalize(pixel - bBR);
				float angle = atan(diff.y, diff.x);
				if (angle < PID4 * 1) {
					borderColor = borderColorR;
				} else {
					borderColor = borderColorB;
				}
			} else {
				borderColor = borderColorB;
			}
		} 
		// ONLY the left border region.
		else if (pixel.x < borderSizeL) {
			borderColor = borderColorL;
		} 
		// ONLY the right border region.
		else if (pixel.x > size.x - borderSizeR) {
			borderColor = borderColorR;
		} 
		// ERROR border region. (Shouldn't happen but is here)
		else {
		// TODO: figure out why inner-border region isn't calculated on round edges. Fill for now.
			borderColor = borderColorT;
		}
	}

	// The left side.
	if (localUV.x < 0.5) {
		// The top-left corner.
		if (localUV.y < 0.5) {
			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerTL, softnessInner);
			float alphaBorder = doThing(pixel, size, borderRadiusTL, softnessOuter);
			vec4 quadColor = vec4(col.rgb, col.a * alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
		} 
		// The bottom-left corner.
		else {
			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerBL, softnessInner);
			float alphaBorder = doThing(pixel, size, borderRadiusBL, softnessOuter);
			vec4 quadColor = vec4(col.rgb, col.a * alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
		}
	} 
	// The right side.
	else {
		// The top-right corner.
		if (localUV.y < 0.5) {
			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerTR, softnessInner);
			float alphaBorder = doThing(pixel, size, borderRadiusTR, softnessOuter);
			vec4 quadColor = vec4(col.rgb, col.a * alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
		} 
		// The bottom-right corner.
		else {
			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerBR, softnessInner);
			float alphaBorder = doThing(pixel, size, borderRadiusBR, softnessOuter);
			vec4 quadColor = vec4(col.rgb, col.a * alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
		}
	}

	// Set the result corner.
	gl_FragColor = baseColor;
}
