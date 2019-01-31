#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Time;
uniform mat4 u_ViewProj;

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float random (vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // cubic falloff
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

// 2D fractal brownian motion
float fbm (vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 st = fs_Pos.xy + vec2(vec4(u_PlanePos.x * 0.01, u_PlanePos.y * 0.001, 1.0, 1.0) * u_ViewProj);
    // st += st * abs(sin(u_time*0.1)*3.0);
    vec4 color = vec4(0.0);

    vec2 q = vec2(0.);
    q.x = fbm( st + 0.00 * u_Time);
    q.y = fbm( st + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( st + 1.0*q + vec2(1.7,9.2)+ 0.0015 * u_Time );
    r.y = fbm( st + 1.0*q + vec2(8.3,2.8)+ 0.00126 * u_Time);

    float f = fbm(st+r);

    color = mix(vec4(120.0 / 255.0, 40.0 / 255.0, 20.0 / 255.0, 0.8),
                vec4(0.666667,0.666667,0.498039, 1.0),
                clamp((f*f)*4.0,0.0,1.0));

    color = mix(color,
                vec4(0,0,0.164706, 0.15),
                clamp(length(q),0.0,1.0));

    color = mix(color,
                vec4(0.0,0.0,0.0, 0.15),
                clamp(length(r.x),0.0,1.0));

    out_Col = (f*f*f+.6*f*f+.5*f)*color;
}