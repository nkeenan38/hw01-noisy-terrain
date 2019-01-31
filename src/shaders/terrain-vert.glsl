#version 300 es


uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Time;
uniform float u_TerrainScale;
uniform float u_TerrainSharpness;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out float fs_Sine;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

float random3( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(420.69, 19.42))) * 65537.65537);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

vec2 baseCoord(vec2 p)
{
	float x = floor(p.x / u_TerrainScale) * u_TerrainScale;
	float z = floor(p.y / u_TerrainScale) * u_TerrainScale;
	return vec2(x, z);
}

vec2 anchorPoint(vec2 p, vec2 seed)
{
	return baseCoord(p) + random2(baseCoord(p), seed) * u_TerrainScale;
}

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

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

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

#define SPEED 150.0

float getHeight(vec2 p, vec2 seed) 
{
	// make p a lower coordinate of the grid
	vec2 center = baseCoord(p);
	float minDistance = 1000000.0f;
	vec2 closestCoord;
	for (float i = -u_TerrainScale; i <= u_TerrainScale; i += u_TerrainScale)
	{
		for (float j = -u_TerrainScale; j <= u_TerrainScale; j += u_TerrainScale)
		{
			vec2 tmp = anchorPoint(vec2(center.x + i, center.y + j), seed);
			float dist = distance(p, tmp) + random1(vec2(center.x + i, center.y + j), seed) * 2.0 + random3(tmp, seed);
			if (dist < minDistance)
			{
				minDistance = dist;
				closestCoord = tmp;
			}
		}
	}

	// add fractal brownian motion to give roughness to the surface
	vec2 q = vec2(0.);
    q.x = fbm( closestCoord + 0.00 * u_Time);
    q.y = fbm( closestCoord + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( closestCoord + 1.0*q + vec2(1.7,9.2)+ 0.0015 * u_Time );
    r.y = fbm( closestCoord + 1.0*q + vec2(8.3,2.8)+ 0.00126 * u_Time);

    float f = fbm(closestCoord + p);

    // height is mostly determined by the anchor point but also features a dropoff given distance from the anchor point and fractal brownian motion
	float height = pow(random1(closestCoord, seed), 3.0f) * u_TerrainScale + pow(random1(random2(closestCoord, seed), seed), 3.0f) * u_TerrainScale
		   	+ sin(u_Time / SPEED * random1(closestCoord, seed)) + cos(u_Time / SPEED * fbm(closestCoord)) * fbm(closestCoord + u_Time / (SPEED * 10.0))
		   	- minDistance * u_TerrainSharpness;
    return height * 0.666 + f * 1.333;
}

void main()
{
  vec2 seed = vec2(3.14159, 6.5537f);
  fs_Pos = vs_Pos.xyz;
  // fs_Sine = (sin((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1));
  float height = getHeight(u_PlanePos.xy + vs_Pos.xz, seed);
  fs_Sine = height / (u_TerrainScale * 2.0);
  // vec4 modelposition = vec4(vs_Pos.x, fs_Sine * 2.0, vs_Pos.z, 1.0);
  vec4 modelposition = vec4(vs_Pos.x, height, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  gl_Position = u_ViewProj * modelposition;
}
