#version 330
#extension GL_ARB_explicit_uniform_location : enable

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

uniform vec4 dim;

in vec4 vColor;
in vec2 vUV;

in vec2 localUV;
in vec2 localPosition;

//blur options:
const float blur_pi = 6.28318530718; 	// Pi times 2
const float blur_directions = 32.0; 	// def. 16.0 - higher number is more slow

float fade(in float t) {
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

vec4 cubic(float v) {
	vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
	vec4 s = n * n * n;
	float x = s.x;
	float y = s.y - 4.0 * s.x;
	float z = s.z - 4.0 * s.y + 6.0 * s.x;
	float w = 6.0 - x - y - z;
	return vec4(x, y, z, w) * (1.0 / 6.0);
}

vec4 textureBicubic(sampler2D sampler, vec2 texCoords) {
	vec2 texSize = TextureSize;
	vec2 invTexSize = 1.0 / texSize;

	texCoords = texCoords * texSize - 0.5;

	vec2 fxy = fract(texCoords);
	texCoords -= fxy;

	vec4 xcubic = cubic(fxy.x);
	vec4 ycubic = cubic(fxy.y);

	vec4 c = texCoords.xxyy + vec2(-0.5, +1.5).xyxy;

	vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
	vec4 offset = c + vec4(xcubic.yw, ycubic.yw) / s;

	offset *= invTexSize.xxyy;

	vec4 sample0 = texture2D(sampler, offset.xz);
	vec4 sample1 = texture2D(sampler, offset.yz);
	vec4 sample2 = texture2D(sampler, offset.xw);
	vec4 sample3 = texture2D(sampler, offset.yw);

	float sx = s.x / (s.x + s.y);
	float sy = s.z / (s.z + s.w);

	return mix(mix(sample3, sample2, sx), mix(sample1, sample0, sx), sy);
}

vec4 sampleClamp2edge(sampler2D texture, vec2 uv) {
	vec2 cuv = vec2(clamp(uv.x, 0.00001, 0.99999), clamp(uv.y, 0.00001, 0.99999));
	return texture2D(texture, cuv);
}

//blur outer regions SearchMode
vec3 blur(in vec3 col, in float alpha, in float radius, in float quality) {
	vec2 rad = radius / screenInfo.xy;
	vec2 uv = vUV.st;
	vec3 c = sampleClamp2edge(DIFFUSE, uv).rgb;
	vec2 uv2;

	for (float d = 0.0; d < blur_pi; d += blur_pi / blur_directions) {
		for (float i = 1.0 / quality; i <= 1.01; i += 1.0 / quality) {

			uv2 = uv + vec2(cos(d), sin(d)) * rad * i;
			uv2 = clamp(uv2, 0.000001, 0.999999);

			c += texture2D(DIFFUSE, uv2).rgb;
		}
	}

	c /= (quality * (blur_directions + 1));
	c = clamp(c, 0.000001, 0.999999);
	return (col * (1.0 - alpha)) + (c * alpha);
}

float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

const float PI = 3.14159265359; 	// Pi
const float PI2 = 6.28318530718; 	// Pi times 2
const float PID2 = PI / 2.0; 	// Pi div 2
const float PID4 = PI / 4.0; 	// Pi div 4
const float PID8 = PI / 8.0; 	// Pi div 4

float noise(vec2 p, float freq) {
	float unit = screenWidth / freq;
	vec2 ij = floor(p / unit);
	vec2 xy = mod(p, unit) / unit;
	xy = 0.5 * (1.0 - cos(PI * xy));
	float a = rand((ij + vec2(0.0, 0.0)));
	float b = rand((ij + vec2(1.0, 0.0)));
	float c = rand((ij + vec2(0.0, 1.0)));
	float d = rand((ij + vec2(1.0, 1.0)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

//	Classic Perlin 2D Noise 
//	by Stefan Gustavson (https://github.com/stegu/webgl-noise)
//
vec2 fade(vec2 t) {
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float permute(float x) {
	return mod289(((x * 34.0) + 1.0) * x);
}

// Permutation polynomial (ring size 289 = 17*17)
vec3 permute(vec3 x) {
	return mod289(((x * 34.0) + 10.0) * x);
}

// Permutation polynomial: (34x^2 + 6x) mod 289
vec4 permute(vec4 x) {
	return mod289((34.0 * x + 10.0) * x);
}

float cnoise(vec2 P) {
	vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
	vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
	Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
	vec4 ix = Pi.xzxz;
	vec4 iy = Pi.yyww;
	vec4 fx = Pf.xzxz;
	vec4 fy = Pf.yyww;
	vec4 i = permute(permute(ix) + iy);
	vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
	vec4 gy = abs(gx) - 0.5;
	vec4 tx = floor(gx + 0.5);
	gx = gx - tx;
	vec2 g00 = vec2(gx.x, gy.x);
	vec2 g10 = vec2(gx.y, gy.y);
	vec2 g01 = vec2(gx.z, gy.z);
	vec2 g11 = vec2(gx.w, gy.w);
	vec4 norm = 1.79284291400159 - 0.85373472095314 *
		vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
	g00 *= norm.x;
	g01 *= norm.y;
	g10 *= norm.z;
	g11 *= norm.w;
	float n00 = dot(g00, vec2(fx.x, fy.x));
	float n10 = dot(g10, vec2(fx.y, fy.y));
	float n01 = dot(g01, vec2(fx.z, fy.z));
	float n11 = dot(g11, vec2(fx.w, fy.w));
	vec2 fade_xy = fade(Pf.xy);
	vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
	float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
	return 2.3 * n_xy;
}

vec2 angleDirection = vec2(1.0, 0.0); // Positive x-axis
float getAngleFromCorner(vec2 center, vec2 pixel) {
	vec2 pixelFromCenter = pixel - center;
	return acos(dot(normalize(pixelFromCenter), angleDirection));
}

float roundedBoxSDF(vec2 center, vec2 size, float radius) {
	return length(max(abs(center) - size + radius, 0.0)) - radius;
}

float doThing(vec2 pixel, vec2 size, float radius, float softness) {
	if (softness == 0) {
		float distance = roundedBoxSDF(pixel - (size / 2.0), size / 2.0, 0);
		return 1.0 - smoothstep(0.0, min(radius, 1.0), distance);
	} else {
		float distance = roundedBoxSDF(pixel - (size / 2.0), size / 2.0, radius);
		return 1.0 - smoothstep(0.0, min(radius * softness, 1.0) * 2.0, distance);
	}
}

void main() {

	vec4 col;
	if (UITexture != 0) {
		col = sampleClamp2edge(DIFFUSE, vUV.st) * UIColor;
		gl_FragColor = col;
		return;
	} else {
		col = UIColor;
	}

	float bSizeT = borderSizeT != 0.0 ? borderSizeT : 0.0;
	float bSizeL = borderSizeT != 0.0 ? borderSizeL : 0.0;
	float bSizeB = borderSizeT != 0.0 ? borderSizeB : 0.0;
	float bSizeR = borderSizeT != 0.0 ? borderSizeR : 0.0;

	vec2 size = vec2(round(dim.z - dim.x), round(dim.w - dim.y));
	vec2 pixel = vec2(round(localUV.x * size.x), round(localUV.y * size.y));

	vec2 sizeBase = size - round(vec2(bSizeL + bSizeR, bSizeT + bSizeB));
	vec2 pixelBase = round(pixel - vec2(bSizeL, bSizeT));

	vec4 baseColor;
	vec4 borderColor = vec4(1, 1, 0, 1);

	float temp = (borderRadiusTL * 2.0) + ((borderSizeT + borderSizeL) / 2);
	vec2 bTL = vec2(temp, temp);
	vec2 bTR = vec2(size.x - ((borderRadiusTR * 2.0) + ((borderSizeT + borderSizeR) / 2)), (borderRadiusTL * 2.0) + ((borderSizeT + borderSizeL) / 2));
	vec2 bBL = vec2((borderRadiusBL * 2.0) + ((borderSizeB + borderSizeL) / 2), size.y - ((borderRadiusBL * 2.0) + ((borderSizeB + borderSizeL) / 2)));
	vec2 bBR = vec2(size.x - ((borderRadiusBR * 2.0) + ((borderSizeB + borderSizeR) / 2)), size.y - ((borderRadiusBR * 2.0) + ((borderSizeB + borderSizeR) / 2)));

	if (pixel.y < bTL.y) {
		if (pixel.x < bTL.x) { // Top-Left
			vec2 diff = normalize(pixel - bTL);
			float angle = atan(diff.y, diff.x);
			if (angle > PID4 * -3) { // Top-Left-Top
				borderColor = borderColorT;
			} else { // Top-Left-Left
				borderColor = borderColorL;
			}
		} else if (pixel.x > bTR.x) { // Top-Right
			borderColor = vec4(1, 1, 0.5, 1);
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
	} else if (pixel.y > bBL.y) { // Bottom
		if (pixel.x < bBL.x) { // Bottom-Left
			vec2 diff = normalize(pixel - bBL);
			float angle = atan(diff.y, diff.x);
			if (angle > PID4 * 3) {
				borderColor = borderColorL;
			} else {
				borderColor = borderColorB;
			}
		} else if (pixel.x > bBR.x) { // Top-Right
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
	} else if (pixel.x < borderSizeL) {
		borderColor = borderColorL;
	} else if (pixel.x > size.x - borderSizeR) {
		borderColor = borderColorR;
	} else {
		borderColor = borderColorB;
	}

	float borderRadiusInnerTL = max(borderRadiusTL - round((bSizeT + bSizeL) / 2.0), 0);
	float borderRadiusInnerTR = max(borderRadiusTR - round((bSizeT + bSizeR) / 2.0), 0);
	float borderRadiusInnerBL = max(borderRadiusBL - round((bSizeB + bSizeL) / 2.0), 0);
	float borderRadiusInnerBR = max(borderRadiusBR - round((bSizeB + bSizeR) / 2.0), 0);

	if (localUV.x < 0.5) {
		if (localUV.y < 0.5) {

			vec2 diff = normalize(pixel - vec2(borderRadiusTL, borderRadiusTL));
			float angle = atan(diff.y, diff.x);

			float smoothnessAngle = 0.0;
			if (pixel.x < borderRadiusTL - 1 && pixel.y < borderRadiusTL - 1) {
				smoothnessAngle = min(abs(cos(angle)), abs(sin(angle)));
				smoothnessAngle *= smoothnessAngle;
			}

			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerTL, smoothnessAngle);
			float alphaBorder = doThing(pixel, size, borderRadiusTL, smoothnessAngle);
			vec4 quadColor = vec4(col.rgb, alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
			baseColor.a = max(alpha, alphaBorder);
		} else {

			vec2 diff = normalize(pixel - vec2(borderRadiusBL, borderRadiusBL));
			float angle = atan(diff.y, diff.x);

			// float angle = getAngleFromCorner(vec2(borderRadiusTL, borderRadiusTL), pixel);
			float smoothnessAngle = 0.0;
			if (pixel.x < borderRadiusBL - 1 && pixel.y >= (size.y - borderRadiusBL) + 1) {
				smoothnessAngle = min(abs(cos(angle)), abs(sin(angle)));
				smoothnessAngle *= smoothnessAngle;
			}

			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerBL, smoothnessAngle);
			float alphaBorder = doThing(pixel, size, borderRadiusBL, smoothnessAngle);
			vec4 quadColor = vec4(col.rgb, alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
			baseColor.a = max(alpha, alphaBorder);
		}
	} else {
		if (localUV.y < 0.5) {

			vec2 diff = normalize(pixel - vec2(borderRadiusTR, borderRadiusTR));
			float angle = atan(diff.y, diff.x);

			float smoothnessAngle = 0.0;
			if (pixel.x >= (size.x - borderRadiusTR) + 1 && pixel.y < borderRadiusTR - 1) {
				smoothnessAngle = min(abs(cos(angle)), abs(sin(angle)));
				smoothnessAngle *= smoothnessAngle;
			}

			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerTR, smoothnessAngle);
			float alphaBorder = doThing(pixel, size, borderRadiusTR, smoothnessAngle);
			vec4 quadColor = vec4(col.rgb, alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
			baseColor.a = max(alpha, alphaBorder);
		} else {

			vec2 diff = normalize(pixel - vec2(borderRadiusBR, borderRadiusBR));
			float angle = atan(diff.y, diff.x);

			float smoothnessAngle = 0.0;
			if (pixel.x >= (size.x - borderRadiusTR) + 1 && pixel.y >= (size.y - borderRadiusBR) + 1) {
				smoothnessAngle = min(abs(cos(angle)), abs(sin(angle)));
				smoothnessAngle *= smoothnessAngle;
			}

			float alpha = doThing(pixelBase, sizeBase, borderRadiusInnerBR, smoothnessAngle);
			float alphaBorder = doThing(pixel, size, borderRadiusTR, smoothnessAngle);
			vec4 quadColor = vec4(col.rgb, alpha);
			vec4 quadColor2 = vec4(borderColor.rgb, borderColor.a * alphaBorder);
			baseColor = mix(quadColor2, quadColor, alpha);
			baseColor.a = max(alpha, alphaBorder);
		}
	}

	gl_FragColor = baseColor;
}
