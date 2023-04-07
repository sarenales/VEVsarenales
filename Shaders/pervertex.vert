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
	
	// ESTO NO ES VERDAD... EL FACTOR ESPECULAR ES SOLAMENTE POW(R.V, m)

	// i = (n*l)*(r*v)^m 
	float i;

	vec3 r;

	// PUEDES QUITAR PARENTESIS... r = 2.0*dot(n,l)*n-l;

	r = normalize(2.0*dot(n,l)*n-l);

	// TIENES QUE NORMALIZAR R

	// ESTO NO ES LO QUE TIENES QUE CALCULAR.. LO QUE TIENES QUE CALCULAR ES 
	// POW(R.V, m) SIEMPRE Y CUANDO LA BASE DE LA POTENCIA... R.V (dot) SEA MAYOR QUE CERO
	if (dot(r,v) > 0.0)
		i = pow(dot(r,v),m);

	return max(i,0.0);
}

float atenuacion_factor(int i, float d){
	// E = I*F(d)
	// f(d) = 1/ (c + l*d + q*d^2)
	float f,E;
	f = 1.0;
	f = (theLights[i].attenuation.x + theLights[i].attenuation.y*d + theLights[i].attenuation.z*d*d);
	if (f != 0.0)
		E = 1.0/f;
	else
		E = 1.0;
	return E;
}

void main() {
	
	vec3 L,N,V;
	vec4 posEye4,A,normalEye4,n4;
	vec3 i_difuso, i_especular;
	float M,d,cspot,base;	
	
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
			L = normalize(- theLights[i].position.xyz );
			i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse;	

			// FALTA MULTIPLICAR POR LAMBERTFACTOR()

			i_especular += lambertFactor(N,L)*specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular;
			
		}else{
		//si  es posicional o spotlight
			// vector que va desde el vertice a la posicion de la luz y lo normalizare


/// AQUI FALTA SABER SI ES POSICIONAL O NO, CALCULAR LA ATENUACION Y CALCULAR SI ESTA DENTRO DEL CONO SI ES SPOTLIGHT


			A = (theLights[i].position - posEye4 );
			L = normalize(A.xyz);
			// si es posicional
			if (theLights[i].position.w == 1.0){
				// d distancia del vertice a la luz
				d = length(A.xyz);
				i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse*atenuacion_factor(i,d);		
				i_especular += lambertFactor(N,L)*specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular;
			}
			else{
				// spotlight
				if (dot(L,theLights[i].spotDir) > theLights[i].cosCutOff){
					// dentro del cono
					base = dot(L,theLights[i].spotDir);
					if (base != 0.0){
						cspot = pow(base,theLights[i].exponent);
						i_difuso += lambertFactor(N,L)*theMaterial.diffuse*theLights[i].diffuse*cspot;
						i_especular += lambertFactor(N,L)*specular_factor(N,L,V, M)*theMaterial.specular*theLights[i].specular*cspot;
					}
					
				}

			}
			
			
		}
		
	}
	f_color += (vec4 (i_difuso, 1.0)) + (vec4 (i_especular, 1.0));
	gl_Position = modelToClipMatrix * vec4(v_position, 1.0);
}
