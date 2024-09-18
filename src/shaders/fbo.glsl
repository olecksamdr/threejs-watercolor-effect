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

// https://github.com/jamieowen/glsl-blend/blob/master/darken.glsl
float blendDarken(float base, float blend) {
	return min(blend,base);
}

vec3 blendDarken(vec3 base, vec3 blend) {
	return vec3(blendDarken(base.r,blend.r),blendDarken(base.g,blend.g),blendDarken(base.b,blend.b));
}

vec3 blendDarken(vec3 base, vec3 blend, float opacity) {
	return (blendDarken(base, blend) * opacity + base * (1.0 - opacity));
}


vec3 bgColor = vec3(1., 1., 1.);
void main() {
  vec4 color = texture2D(tDiffuse, vUv); // mose movement
  vec4 prev = texture2D(tPrev, vUv); // previous frame
  vec2 aspect = vec2(1., uResolution.y / uResolution.x);

  vec2 displacement = fbm(vUv * 22.) * aspect * 0.005;

  vec4 texel = texture2D(tPrev, vUv);
  vec4 texel2 = texture2D(tPrev, vec2(vUv.x + displacement.x, vUv.y));
  vec4 texel3 = texture2D(tPrev, vec2(vUv.x - displacement.x, vUv.y));
  vec4 texel4 = texture2D(tPrev, vec2(vUv.x, vUv.y + displacement.y));
  vec4 texel5 = texture2D(tPrev, vec2(vUv.x, vUv.y - displacement.y));

  vec3 watercolor = texel.rgb;
  watercolor = blendDarken(watercolor, texel2.rgb);
  watercolor = blendDarken(watercolor, texel3.rgb);
  watercolor = blendDarken(watercolor, texel4.rgb);
  watercolor = blendDarken(watercolor, texel5.rgb);

  gl_FragColor = color + prev * 0.9;
  gl_FragColor = vec4(displacement, 0., 1.);
  gl_FragColor = vec4(watercolor, 1.);
}
