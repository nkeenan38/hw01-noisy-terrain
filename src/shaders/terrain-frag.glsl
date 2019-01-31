#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 blend(vec3 x, vec3 y, float a)
{
	return x * pow(1.0 - a, 3.0) + y * pow(a, 3.0);
}

// blends the color so that its a bright red nearer the lava and brown further away, i.e. hotter vs colder
void main()
{
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    vec3 color = blend(vec3(160.0 / 255.0, 20.0 / 255.0, 20.0 / 255.0), vec3(80.0 / 255.0, 60.0 / 255.0, 40.0 / 255.0), fs_Sine);
    // out_Col = vec4(mix(color, vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);
    out_Col = vec4(mix(color, vec3(80.0 / 255.0, 60.0 / 255.0, 60.0 / 255.0), t), 1.0);
}

