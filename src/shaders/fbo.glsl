uniform sampler2D tDiffuse;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;

void main() {
  vec4 color = texture2D(tDiffuse, vUv);
  gl_FragColor = color;
}
