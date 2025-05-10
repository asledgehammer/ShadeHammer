#version 330
#extension GL_ARB_explicit_uniform_location : enable

uniform float screenWidth;
uniform float screenHeight;
uniform float timer;
uniform vec2 TextureSize;
uniform float Zoom;
uniform vec4 screenInfo;

uniform vec4 UIColor = vec4(1.0, 0.0, 1.0, 1.0);
uniform sampler2D DIFFUSE;

// Fade stuff
uniform int UIFadeHalfLeft   = 0;
uniform int UIFadeHalfRight  = 0;
uniform int UIFadeThirdLeft  = 0;
uniform int UIFadeThirdRight = 0;

uniform float u_saturation = 0.2;

float saturation = u_saturation;

in vec4 vColor;
in vec2 vUV;

float width = screenWidth;
float height = screenHeight;

const vec3 AvgLumin = vec3(0.4, 0.4, 0.4);

//blur options:
const float blur_pi = 6.28318530718; 	// Pi times 2
const float blur_directions = 32.0; 	// def. 16.0 - higher number is more slow
const float blur_quality = 3.0; 		// def. 3.0 - higher number is more slow
const float blur_size = 12.0; 			// def. 8.0

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

	return mix(
		mix(sample3, sample2, sx),
		mix(sample1, sample0, sx),
		sy);
}

vec4 sampleClamp2edge(sampler2D texture, vec2 uv) {
	vec2 cuv = vec2(
		clamp(uv.x, 0.00001, 0.99999),
		clamp(uv.y, 0.00001, 0.99999)
	);
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
	vec2 g00 = vec2(gx.x,gy.x);
	vec2 g10 = vec2(gx.y,gy.y);
	vec2 g01 = vec2(gx.z,gy.z);
	vec2 g11 = vec2(gx.w,gy.w);
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

float easeOutQuad(float x) {
    return 1.0 - (1.0 - x) * (1.0 - x);
}

float easeInQuad(float x) {
    return x * x;
}

void main() {
	vec2 uv = vUV.st;
	float fade_alpha = 1.0;
	if (UIFadeHalfLeft != 0) {
		fade_alpha = clamp((1.0 - easeInQuad(uv.x + 0.54)) * 4.0, 0.0, 1.0);
	} else if (UIFadeHalfRight != 0) {
		fade_alpha = clamp(easeOutQuad(uv.x - 0.48) * 4.0, 0.0, 1.0);
	} else if (UIFadeThirdLeft != 0) {
		fade_alpha = clamp((1.0 - easeInQuad(uv.x + 0.7)) * 8.0, 0.0, 1.0);
	} else if (UIFadeThirdRight != 0) {
		fade_alpha = clamp(easeOutQuad(uv.x - 0.64) * 8.0, 0.0, 1.0);
	}
	
	vec4 pixel4 = sampleClamp2edge(DIFFUSE, uv);


	float n = rand(uv * 20) * 0.06;
	vec2 noiseUV = uv * 250;
	noiseUV.x *= screenWidth / screenHeight;
	float pn = cnoise(noiseUV) * 0.01625;
	float mul = 0.8;
	vec3 pixel3 = blur(clamp(pixel4.rgb - pn, 0.0, 1.0), 1.0, 96.0, 64.0) * mul;

	vec4 result = vec4(pixel3 * 1.0 - (pn + n), 1.0);
	float luminance = (result.r + result.g + result.b) / 3.0;
	vec4 resultBW = vec4(luminance, luminance, luminance, result.a);

	gl_FragColor = mix(resultBW, result, saturation);
	gl_FragColor.r *= UIColor.r;
	gl_FragColor.g *= UIColor.g;
	gl_FragColor.b *= UIColor.b;
	gl_FragColor.a *= UIColor.a * fade_alpha * 0.95;

	// gl_FragColor = vec4(pn,pn,pn,1);
}
