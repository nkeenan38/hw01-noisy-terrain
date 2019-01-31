#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting
uniform float u_Time;
uniform vec2 u_PlanePos;
uniform mat4 u_ViewProj;

in vec3 fs_Pos;

out vec4 out_Col;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void main() {
    out_Col = vec4(80.0 / 255.0, 60.0 / 255.0, 60.0 / 255.0, 1.0);
}