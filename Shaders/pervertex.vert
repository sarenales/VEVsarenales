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
	float i = 0.0;
	vec3 h = normalize(l+v);
	float d = max(dot(n,h),0.0);
	if (d>0.0)
		i = pow(d,4*m);
	return i;
}

float atenuacion_factor(int i, float d){
	// E = I*F(d)
	// f(d) = 1/ (c + l*d + q*d^2)
	float f,E;
	f = (theLights[i].attenuation.x + theLights[i].attenuation.y*d + theLights[i].attenuation.z*d*d);
	if (f != 0.0)
		E = 1.0/f;
	else
		E = 1.0;
	return E;
}

void main() {
	
	vec3 L,N,V;
	vec4 posEye4,A,normalEye4;
	vec3 i_difuso, i_especular;
	float M,d,cspot, cosAlpha;	
	
	cosAlpha = 0.0;
	cspot = 0.0;
	
	i_difuso = vec3(0.0);
	i_especular = vec3(0.0);
	
	f_color = vec4(scene_ambient, 1.0);
	f_texCoord = v_texCoord;	
	
	// pasar la posicion del vertice del sistema de coordenadas del modelo al sistema del modelo de la camara
	posEye4 = modelToCameraMatrix*vec4(v_position,1.0) ; // el vertice en el sistema de ref de la camara (punto)
	V = normalize(-posEye4.xyz);
	
	// pasar la normal del vertice del sistema de coordenadas del modelo al sistema del modelo de la camara

	normalEye4 = modelToCameraMatrix*vec4(v_normal,0.0) ; // vector
	N = normalize(normalEye4.xyz);

	M = theMaterial.shininess;
	
	//FOR para todas las luces
	for(int i=0; i<active_lights_n;i++){

		// si es direccional
		if (theLights[i].position.w == 0.0){
			// vecctor opuesto a la direccion que viaja
			L = normalize(- theLights[i].position.xyz );
			
			i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse;	
			i_especular += lambertFactor(N,L)*specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular;
			
		}else{
		//si  es posicional o spotlight
			// vector que va desde el objeto a la posicion de la luz y lo normalizare
			A = (theLights[i].position - posEye4 ); // para luego la atenuacion
			L = normalize(A.xyz); 	// vector que va del vertice a la luz
			
			// si es posicional
			if (theLights[i].cosCutOff == 0.0){
				// d distancia del objto a la luz
				d = length(A.xyz);
				i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse*atenuacion_factor(i,d);		
				i_especular += lambertFactor(N,L)*specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular*atenuacion_factor(i,d);
			}
			else{
				// spotlight
				// ojo con los cosenos
				cosAlpha = dot(-L,theLights[i].spotDir);
				if (cosAlpha > theLights[i].cosCutOff){
				// dentro del cono
					if(cosAlpha > 0.0){ 	// comprobamos que la base no es 0
						cspot = pow(cosAlpha,theLights[i].exponent);
						i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse*cspot;
						i_especular += lambertFactor(N,L)*specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular*cspot;
					}
				}
			}			
		}
	}
	f_color += (vec4 (i_difuso, 1.0)) + (vec4 (i_especular, 1.0));
	gl_Position = modelToClipMatrix * vec4(v_position, 1.0); // solo para los vertexshaders
}
