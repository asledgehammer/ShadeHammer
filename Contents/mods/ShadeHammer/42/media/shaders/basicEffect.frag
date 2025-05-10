#version 120

varying vec3 vertColour; 
varying vec3 vertNormal;
varying vec2 texCoords;

uniform sampler2D Texture;
uniform float Alpha;
uniform float LightingAmount;

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
uniform float HueChange;

uniform float AlphaForce = 0.5;

uniform int UI = 0;
uniform int UIColorForce = 0;
uniform vec4 UIColorForceValue = vec4(1.0, 1.0, 1.0, 1.0); 

#include "util/math"
#include "util/hueShift"

float edgeDetection(float z) {
  float dx = dFdx(z);
  float dy = dFdy(z);
  float gradientMagnitude = length(vec2(dx, dy));

  // Threshold for edge detection
  if (gradientMagnitude > 0.01) {
    return 1.0; // Edge
  } else {
    return 0.0; // No edge
  }
}

void main() {

	if (UI != 0) {

		if (!gl_FrontFacing) {
			discard;
			return;
		}

		// float zDepth = gl_FragCoord.z / gl_FragCoord.w;
		// if (abs(zDepth) < 0.5) {
		// 	gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
		// 	return;
		// }

	}

	if (UIColorForce != 0) {
		gl_FragColor = UIColorForceValue;
		return;
	}

	vec3 normal = normalize(vertNormal);
	vec4 texSample = texture2D(Texture, texCoords);

	if(texSample.w < 0.01) {
	    discard;
	}

	vec3 col = texSample.xyz;

    float dotprod;
    if (HueChange != 0.0) {
        col = hueShift(col, HueChange);
    }

	const float QuantiseLevels = 8.0;
	vec3 lighting = vec3(0.0);

	dotprod = max(dot(normal, normalize(Light0Direction)), 0.0);
	lighting += Light0Colour * dotprod;
	dotprod = max(dot(normal, normalize(Light1Direction)), 0.0);
	lighting += Light1Colour * dotprod;
	dotprod = max(dot(normal, normalize(Light2Direction)), 0.0);
	lighting += Light2Colour * dotprod;
	dotprod = max(dot(normal, normalize(Light3Direction)), 0.0);
	lighting += Light3Colour * dotprod;
	dotprod = max(dot(normal, normalize(Light4Direction)), 0.0);
	lighting += Light4Colour * dotprod;

	lighting += AmbientColour;
	lighting.x = min(lighting.x, 1.0);
	lighting.y = min(lighting.y, 1.0);
	lighting.z = min(lighting.z, 1.0);

	vec3 tintColour = TintColour;
	col = vec3(col.x * tintColour.x * lighting.x, col.y * tintColour.y * lighting.y, col.z * tintColour.z * lighting.z);

	if (UI != 0) {
		gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	}

    vec4 fragCol = vec4(Alpha * col * vertColour, Alpha * texSample.w);
	gl_FragColor = fragCol;
	gl_FragColor.a *= AlphaForce;
}
