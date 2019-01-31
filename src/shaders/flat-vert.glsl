#version 300 es
precision highp float;

// The vertex shader used to render the background of the scene

uniform mat4 u_Model;
uniform mat4 u_ViewProj;

in vec4 vs_Pos;
out vec3 fs_Pos;

void main() {
  fs_Pos = vs_Pos.xyz;
  vec4 modelposition = vec4(vs_Pos.x, vs_Pos.y, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  gl_Position = vs_Pos;
}
