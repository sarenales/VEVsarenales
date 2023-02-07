#version 120

uniform mat4 modelToCameraMatrix; // M
uniform mat4 cameraToClipMatrix;  // P

attribute vec3 v_position;

varying vec4 f_color;

void main() {

	f_color = vec4(0,1,0,1);
	gl_Position = cameraToClipMatrix * modelToCameraMatrix *(v_position, 1); // ahora a sistema ref camara y con click
}
