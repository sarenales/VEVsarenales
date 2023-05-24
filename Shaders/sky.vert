#version 120

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

attribute vec3 v_position;
// utilizamos la position para las coordenadas

// 

varying vec3 f_texCoord; // Note: texture coordinates is vec3




void main() {

	f_texCoord = vec3(v_position.xy, -v_position.z);
	
	gl_Position = modelToClipMatrix * vec4(v_position, 1.0);
}
