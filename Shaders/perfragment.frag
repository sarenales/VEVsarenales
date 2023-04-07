#version 120

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient; // Scene ambient light

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

uniform sampler2D texture0;

varying vec3 f_position;      // camera space
varying vec3 f_viewDirection; // camera space
varying vec3 f_normal;        // camera space
varying vec2 f_texCoord;



float lambertFactor(in vec3 N,in vec3 L){ // funcion
	float NoL;
	
	NoL = dot(N,L);
	return max(NoL,0.0);
}

float specular_factor(const vec3 n, const vec3 l, const vec3 v, float m){
	
	//  POW(R.V, m)
	float i;
	vec3 r;

	r = normalize(2.0*dot(n,l)*n-l);
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

    vec3 L,N,V,A,normalEye,posEye,i_difuso,i_especular;
    float M,d,cspot,base;

    i_difuso = vec3(0.0);
    i_especular = vec3(0.0);

	gl_FragColor = vec4(1.0);

    // posicion de la luz en el espacio de la camara
    posEye = f_position;
    // direccion de la luz en el espacio de la camara
    V = normalize(f_viewDirection);
    // vector normal en el espacio de la camara
    normalEye = normalize(f_normal); 

    // calculo de la componente difusa
    M = theMaterial.shininess;

    for(int i=0; i<active_lights_n;i++){
        // si es direccional
        if(theLights[i].position.w == 0.0){
            L = normalize(-theLights[i].position.xyz);
            i_difuso += lambertFactor(normalEye,L)*theLights[i].diffuse*theMaterial.diffuse;
            i_especular += lambertFactor(normalEye,L)*specular_factor(normalEye,L,V,M)*theLights[i].specular*theMaterial.specular;

        }
        else{
            // si es posicional o spotlight
            A = (theLights[i].position.xyz - posEye);
            L = normalize(A);
            if(theLights[i].position.w == 1.0){
                // si es posicional
                d = length(A);
                i_difuso += lambertFactor(normalEye,L)*theLights[i].diffuse*theMaterial.diffuse*atenuacion_factor(i,d);
                i_especular += lambertFactor(normalEye,L)*specular_factor(normalEye,L,V,M)*theLights[i].specular*theMaterial.specular*atenuacion_factor(i,d);
            }
            else{
                // si es spotlight
                if(dot(L,theLights[i].spotDir) > theLights[i].cosCutOff){
                    base = dot(L,theLights[i].spotDir);
                    if (base != 0.0)  {
                        cspot = pow(base,theLights[i].exponent);                    
                        i_difuso += lambertFactor(normalEye,L)*theLights[i].diffuse*theMaterial.diffuse*atenuacion_factor(i,d)*base;
                        i_especular += lambertFactor(normalEye,L)*specular_factor(normalEye,L,V,M)*theLights[i].specular*theMaterial.specular*atenuacion_factor(i,d)*base;
                    }
                }
            }
        }
    }
    gl_FragColor = vec4(i_difuso + i_especular + scene_ambient*theMaterial.diffuse,1.0);
}
