uniform sampler2D tDiffuse;
uniform sampler2D tPrev;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;

void main() {
  vec4 color = texture2D(tDiffuse, vUv);
  vec4 prev = texture2D(tPrev, vUv);
  gl_FragColor = color + prev * 0.9;
}
