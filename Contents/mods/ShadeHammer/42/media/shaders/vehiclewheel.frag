#version 330

varying vec3 vertColour; 
varying vec3 vertNormal;
varying vec2 texCoords;

uniform sampler2D Texture;

uniform vec3 TintColour;

uniform vec3 AmbientColour;
uniform vec3 Light0Direction;
uniform vec3 Light0Colour;
uniform vec3 Light1Direction;
uniform vec3 Light1Colour;
uniform vec3 Light2Direction;
uniform vec3 Light2Colour;
uniform vec3 Light3Direction;
uniform vec3 Light3Colour;
uniform vec3 Light4Direction;
uniform vec3 Light4Colour;

uniform float Alpha;
uniform float AlphaForce = 1.0;

uniform int UIColorForce = 0;
uniform vec4 UIColorForceValue = vec4(1.0, 1.0, 1.0, 1.0); 

#include "util/math"

//blur options:
const float blur_pi = 6.28318530718; 	// Pi times 2
const float blur_directions = 32.0; 	// def. 16.0 - higher number is more slow
const float blur_quality = 3.0; 		// def. 3.0 - higher number is more slow
const float blur_size = 12.0; 			// def. 8.0

vec4 sampleClamp2edge(sampler2D texture, vec2 uv) {
	vec2 cuv = vec2(
		clamp(uv.x, 0.00001, 0.99999),
		clamp(uv.y, 0.00001, 0.99999)
	);
	return texture2D(texture, cuv);
}

//blur outer regions SearchMode
vec3 blur(in vec3 col, in float alpha, in float radius, in float quality) {
    vec2 rad = vec2(radius, radius);
	vec2 uv = vec2(texCoords.x, texCoords.y);
	vec3 c = sampleClamp2edge(Texture, uv).rgb;
	vec2 uv2;
	for (float d = 0.0; d < blur_pi; d += blur_pi / blur_directions) {
		for (float i = 1.0 / quality; i <= 1.01; i += 1.0 / quality) {
			uv2 = uv + vec2(cos(d), sin(d)) * rad * i;
			uv2 = clamp(uv2, 0.000001, 0.999999);
			c += texture2D(Texture, uv2).rgb;
		}
	}
	c /= (quality * (blur_directions + 1));
	c = clamp(c, 0.000001, 0.999999);
	return (col * (1.0 - alpha)) + (c * alpha);
}

void main() {

	if (UIColorForce != 0) {
		gl_FragColor = UIColorForceValue;
		return;
	}

	vec3 normal = normalize(vertNormal);
	vec3 col = texture2D(Texture, texCoords).xyz;
	float dotprod;
	float pixelVal = (col.x + col.y + col.z) / 3.0;

	vec3 lighting = AmbientColour;
	dotprod = max(dot(normal, normalize(Light0Direction)), 0.0);
	quantise(dotprod, 3.0);
	lighting += Light0Colour * dotprod;

	dotprod = max(dot(normal, normalize(Light1Direction)), 0.0);
	quantise(dotprod, 3.0);
	lighting += Light1Colour * dotprod;

	dotprod = max(dot(normal, normalize(Light2Direction)), 0.0);
	quantise(dotprod, 3.0);
	lighting += Light2Colour * dotprod;

	dotprod = max(dot(normal, normalize(Light3Direction)), 0.0);
	quantise(dotprod, 3.0);
	lighting += Light3Colour * dotprod;

	dotprod = max(dot(normal, normalize(Light4Direction)), 0.0);
	quantise(dotprod, 3.0);
	lighting += Light4Colour * dotprod;

    vec3 TintColourNew = desaturate(TintColour, 0.3);
	lighting.x = clamp(lighting.x, 0.0, 1.0);
	lighting.y = clamp(lighting.y, 0.0, 1.0);
	lighting.z = clamp(lighting.z, 0.0, 1.0);

	col = vec3(col.x * lighting.x * TintColourNew.x, col.y * lighting.y * TintColourNew.y, col.z * lighting.z * TintColourNew.z);

	gl_FragColor = vec4(col.xyz, Alpha);
	gl_FragColor.a *= AlphaForce;
}
