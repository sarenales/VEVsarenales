#version 120

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient;  // rgb

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
} theLights[4];     // MG_MAX_LIGHTS

uniform struct material_t {
	vec3  diffuse;
	vec3  specular;
	float alpha;
	float shininess;
} theMaterial;

attribute vec3 v_position; // Model space
attribute vec3 v_normal;   // Model space
attribute vec2 v_texCoord;

varying vec4 f_color;
varying vec2 f_texCoord;

void main() {

	vec3 L;
	vect4 posEye4,A,normalEye4;
	
	// pasar la posicion del vertice del sistema de coordenadas del modelo al sistema del modelo de la camara
	
	posEye4 = modelToCameraMatrix*vec4(v_position,1.0) ; // es un punto
	
	

	// pasar la normal del vertice del sistema de coordenadas del modelo al sistema del modelo de la camara
	
	normalEye4 = modelToCameraMatrix*vec4(v_position,0.0) ; // es un punto
	vec3 normalEye = normalize(normalEye4.xyz);
		
	//FOR para todas las luces
	for(int i=0; i<active_lights_n;i++){
	
	}
		// si es direccional
		if (theLights[i].position.w == 0){
			L = normalize(- theLights[i].position.xyz );// vector de 4
			
			
		}else{
		//si  es posiciona o spotlight
			// vector que va desde el vertice a la posicion de la luz y lo normalizare
			A = (theLights[i].position - posEye4 );
			L = normalize(A.xyz);
		}
	}
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
}
