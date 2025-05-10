#version 430 core

#include "util/instancing"
#include "util/skinning"

layout (location = 0) in vec4 vertex;
layout (location = 1) in vec4 normal;
layout (location = 2) in vec4 boneWeights;
layout (location = 3) in vec4 boneIndices;
layout (location = 4) in vec2 uv;

//DECLARE_SKINNING(2, 3) // weights, indices

out vec3 vertColour;
out vec3 vertNormal;
out vec2 texCoords;

uniform mat4 ModelViewProjection;

DECLARE_INSTANCING_VERT

BEGIN_INSTANCING

vec3 LightDirection[5];

vec3 LightColour[5];

mat4 MatrixPalette[60];

// unused, skinning bone matrices are in world space
// kept to be compatible with static version
mat4 transform;
mat4 mvp;

vec2 UVScale;
float targetDepth;
float DepthBias;

vec3 TintColour;
float HighResDepthMultiplier; // 0.5 when drawing models to double-sized chunk textures

vec3 AmbientColour;
float Alpha;

float LightingAmount;
float HueChange;
bool FlipNormal;	// is model inside out?

END_INSTANCING

uniform int UIOutline = 0;
uniform float UIOutlineValue = 0.95;

void main()
{
	COPY_INSTANCE_ID

	GET_INSTANCED_STRUCT(inst)

	float positionW = 1.0;
	if (UIOutline != 0) {
		positionW = UIOutlineValue;
	}

	vec4 position = vec4(vertex.xyz, positionW);
	vec4 normal = vec4(normal.xyz, 0.0);

	mat4 skinMatrix = mat4(0.0);
	if(boneWeights.x > 0.0)
	    skinMatrix += inst.MatrixPalette[int(boneIndices.x)] * boneWeights.x;
	if(boneWeights.y > 0.0)
	    skinMatrix += inst.MatrixPalette[int(boneIndices.y)] * boneWeights.y;
	if(boneWeights.z > 0.0)
	    skinMatrix += inst.MatrixPalette[int(boneIndices.z)] * boneWeights.z;
	if(boneWeights.w > 0.0)
	    skinMatrix += inst.MatrixPalette[int(boneIndices.w)] * boneWeights.w;

	if (inst.FlipNormal)
		normal = -normal;

	//CALC_SKIN_MATRIX(skinMatrix);
    normal = skinMatrix * normal;

	vertColour = vec3(1.0);
	vertNormal = normal.xyz;
	texCoords = uv * inst.UVScale * inst.textureSize / TextureDimensions;

	position = inst.mvp * inst.transform * skinMatrix * position;

	vec4 origin = inst.mvp * inst.transform * vec4(0, 0, 0, 1);
	position.z += (origin.z - position.z) * inst.HighResDepthMultiplier;
    position.z += inst.targetDepth * 2.0 - 1.0;

	gl_Position = position;
}
