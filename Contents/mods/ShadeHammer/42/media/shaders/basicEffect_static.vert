#version 330

layout (location = 0) in vec4 vertex;
layout (location = 1) in vec4 normal;
layout (location = 2) in vec2 uv;

out vec3 vertColour;
out vec3 vertNormal;
out vec2 texCoords;

uniform mat4 ModelViewProjection;
uniform mat4 transform;
uniform float targetDepth = 0.5;
uniform float DepthBias;

uniform vec2 UVScale;
uniform float HighResDepthMultiplier = 0.0; // 0.5 when drawing models to double-sized chunk textures
uniform float FinalScale = 1.0;


/* UI Transforms */
uniform int UI = 0;
uniform vec3 UIPosition = vec3(0.0, 0.0, 0.0);
uniform vec3 UIRotation = vec3(0.0, 0.0, 0.0);
uniform vec3 UIRotationPivot = vec3(0.0, 0.0, 0.0);
uniform vec3 UIScale = vec3(1.0, 1.0, 1.0);

/* UI Outline Transforms */
uniform int UIOutline = 0;
uniform vec3 UIOutlineScale = vec3(1.05, 1.05, 1.05);

void ui() {
	mat3 rotMatX = mat3(
		1.0,               0.0,                0.0,
		0.0, cos(UIRotation.x), -sin(UIRotation.x),
		0.0, sin(UIRotation.x),  cos(UIRotation.x)
	);

	mat3 rotMatY = mat3(
		 cos(UIRotation.y), 0.0, sin(UIRotation.y),
		               0.0, 1.0,               0.0,
		-sin(UIRotation.y), 0.0, cos(UIRotation.y)
	);

	mat3 rotMatZ = mat3(
		cos(UIRotation.z), -sin(UIRotation.z), 0.0,
		sin(UIRotation.z),  cos(UIRotation.z), 0.0,
		              0.0,                0.0, 1.0
	);

	vec3 vertex3 = vertex.xyz - UIRotationPivot;
	if (UIOutline != 0) {
		vertex3 *= UIOutlineScale;
		// vertex3 = vertex.xyz - UIRotationPivot;
		// vertex3 *= vec3(1.5, 1.05, 1.5);
	}
	vec3 rotPos = rotMatX * rotMatY * rotMatZ * vertex3 * UIScale;
	rotPos += UIRotationPivot + UIPosition;
	vec4 position = vec4(rotPos, 1.0);
	vec4 normal = vec4(normal.xyz, 0);

	texCoords = uv.st * UVScale.xy;

	vertNormal = (transform * normal).xyz;
	vertColour = vec3(1,1,1);

	vec4 positionScaled = transform * position;
	positionScaled.xyz *= FinalScale;
	
	vec4 o = ModelViewProjection * positionScaled;

	vec4 origin = ModelViewProjection * vec4(0, 0, 0, 1);
	o.z += (origin.z - o.z) * HighResDepthMultiplier;

	float clip = ((o.z+1.0) / 2.0); // -1,+1 -> 0,2 -> 0,1
	clip += targetDepth - 0.5;
	o.z = (clip*2)-1; // 0-1 -> 0-2 -> -1,+1

	gl_Position = o;
}

void main()
{

	if (UI != 0) {
		ui();
		return;
	}

	vec3 rotPos = vertex.xyz;
	vec4 position = vec4(rotPos, 1.0);

	vec4 normal = vec4(normal.xyz, 0);

	texCoords = uv.st * UVScale.xy;

	vertNormal = (transform * normal).xyz;
	vertColour = vec3(1,1,1);

	vec4 positionScaled = transform * position;
	positionScaled.xyz *= FinalScale;
	vec4 o = ModelViewProjection * positionScaled;
	vec4 origin = ModelViewProjection * vec4(0, 0, 0, 1);
	o.z += (origin.z - o.z) * HighResDepthMultiplier;
	float clip = ((o.z+1.0) / 2.0); // -1,+1 -> 0,2 -> 0,1
	clip += targetDepth - 0.5;
	o.z = (clip*2)-1; // 0-1 -> 0-2 -> -1,+1
	gl_Position = o;
}
