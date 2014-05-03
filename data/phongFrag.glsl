#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec3 vertNormal;
varying vec3 vertLightDir;

in vec4 colorV;

void main() {  
  float intensity;
  vec4 color;
  intensity = max(0.04, dot(vertLightDir, vertNormal))*10;

  color = vec4(intensity*colorV.r, intensity*colorV.g, intensity*colorV.b, 1.0);

  gl_FragColor = color;  
}