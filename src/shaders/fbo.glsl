#define NUM_OCTAVES 4

uniform sampler2D tDiffuse;
uniform sampler2D tPrev;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;

// https://github.com/yiwenl/glsl-fbm/blob/master/2d.glsl
float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

float fbm(vec2 x) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

void main() {
  vec4 color = texture2D(tDiffuse, vUv); // mose movement
  vec4 prev = texture2D(tPrev, vUv); // previous frame

  float disp = fbm(vUv * 22.);
  gl_FragColor = color + prev * 0.9;
  gl_FragColor = vec4(disp, 0., 0., 1.);
}
