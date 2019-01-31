#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Time;

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

// Value Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/lsf3WH
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // cubic falloff
    vec2 u = f*f*(3.0-2.0*f);

    // gradient noise
    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

float quinticBlend(float x)
{
	return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

vec3 randColor(vec2 p, vec2 seed)
{
	// vec2 st = vec2(p.x + quinticBlend(sin(u_Time / 1921.0f)) * noise(p + quinticBlend(sin(u_Time / 6557.0f))), p.y + quinticBlend(sin(u_Time / 4257.0f)) * noise(p + quinticBlend(cos(u_Time / 3133.0f))));
    vec2 st = p;
	float t = noise(st + u_Time / 180.0);
	// color is a mix of red and orange
	return mix(vec3(200.0 / 255.0, 0.0, 0.0), vec3(255.0 / 255.0, 160.0 / 255.0, 0.0 / 255.0), t);
}

void main()
{
	float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); 
	vec3 color = randColor(u_PlanePos.xy + fs_Pos.xz, vec2(3.1415, 6.557));
    out_Col = vec4(mix(color, vec3(80.0 / 255.0, 60.0 / 255.0, 60.0 / 255.0), t), 1.0);
}


