#version 330
#extension GL_ARB_explicit_uniform_location : enable

layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aUV;
layout (location = 2) in vec4 aColor;

uniform mat4 ModelViewProjection;

// Mat4
layout (location = 80) uniform vec4 transform1 = vec4(1.0, 0.0, 0.0, 0.0);
layout (location = 81) uniform vec4 transform2 = vec4(0.0, 1.0, 0.0, 0.0);
layout (location = 82) uniform vec4 transform3 = vec4(0.0, 0.0, 1.0, 0.0);
layout (location = 83) uniform vec4 transform4 = vec4(0.0, 0.0, 0.0, 1.0);

// Hack to get all 4 transform vec4 to appear.
layout (location = 84) uniform bool userT3 = false;

out vec4 vColor;
out vec2 vUV;

void main(void) {

	// Hack to get all 4 transform vec4 to appear.
	if (userT3) {
		gl_Position = transform1 * transform2 * transform3 * transform4;
		return;
	}

	mat4 transform = mat4(1);
	transform[0][0] = transform1.x;
	transform[0][1] = transform1.y;
	transform[0][2] = transform1.z;
	transform[0][3] = transform1.w;
	transform[1][0] = transform2.x;
	transform[1][1] = transform2.y;
	transform[1][2] = transform2.z;
	transform[1][3] = transform2.w;
	transform[2][0] = transform3.x;
	transform[2][1] = transform3.y;
	transform[2][2] = transform3.z;
	transform[2][3] = transform3.w;
	transform[3][0] = transform4.x;
	transform[3][1] = transform4.y;
	transform[3][2] = transform4.z;
	transform[3][3] = transform4.w;

	vec3 pos = vec3(aPos.x, aPos.y, 0);
	vec4 pos4 = vec4(pos, 1.0);

	gl_Position = ModelViewProjection * pos4;
	

	vColor = aColor;
	vUV = aUV;
}
