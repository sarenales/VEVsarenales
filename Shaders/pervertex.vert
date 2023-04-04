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


float lambertFactor(in vec3 N,in vec3 L){ // funcion
	float NoL;
	
	NoL = dot(N,L);
	
	return max(NoL,0.0);
}

float specular_factor(const vec3 n, const vec3 l, const vec3 v, float m){
	
	// i = (n*l)*(r*v)^m 
	float i;

	vec3 r;

	r = (2*(dot(n,l)*n))-l;
	i = dot(dot(n,l),pow(dot(r,v),m));
	return max(i,0.0);
}

void main() {
	
	vec3 L,N,V;
	vec4 posEye4,A,normalEye4,n4;
	vec3 i_difuso, i_especular;
	float M;	
	
	f_color = vec4(scene_ambient, 1.0);
	f_texCoord = v_texCoord;	
	
	// pasar la posicion del vertice del sistema de coordenadas del modelo al sistema del modelo de la camara
	posEye4 = modelToCameraMatrix*vec4(v_position,1.0) ; // el vertice en el sistema de ref de la camara (punto)
	V = normalize(posEye4.xyz);
	
	
	// pasar la normal del vertice del sistema de coordenadas del modelo al sistema del modelo de la camara
	normalEye4 = modelToCameraMatrix*vec4(v_position,0.0) ; // vector
	N = normalize(-normalEye4.xyz);

	M = theMaterial.shininess;
	
	//FOR para todas las luces
	for(int i=0; i<active_lights_n;i++){

		// si es direccional
		if (theLights[i].position.w == 0){
			L = normalize(- theLights[i].position.xyz );
			i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse;				
			i_especular += specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular;
			
		}else{
		//si  es posicional o spotlight
			// vector que va desde el vertice a la posicion de la luz y lo normalizare
			A = (theLights[i].position - posEye4 );
			L = normalize(A.xyz);
			i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse;				
			i_especular += specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular;
			
		}
		
	}
	f_color += (vec4 (i_difuso, 1.0)) + (vec4 (i_especular, 1.0));
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
}
