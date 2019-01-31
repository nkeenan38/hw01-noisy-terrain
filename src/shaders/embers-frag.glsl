#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting
uniform float u_Time;
uniform vec2 u_PlanePos;
uniform mat4 u_ViewProj;

in vec3 fs_Pos;

out vec4 out_Col;

vec3 random( vec3 p ) {
    return sin(vec3(dot(p,vec3(127.1,311.7,165.7)), 
    					  dot(p,vec3(269.5,183.3,113.2)), 
    					  dot(p,vec3(119.5,653.7,113.5))));
}

// embers are drawn using an animated voroni diagram
// only the centers are drawn with color, the rest is transparent
void main() {
	// starting position is the point on the square, with a slight influence from the plane position
    vec3 st = vec3(fs_Pos.x + u_PlanePos.x / 500.0, fs_Pos.y, fs_Pos.z + u_PlanePos.y / 500.0);
    vec3 color = vec3(.0);

    // Scale
    st *= 3.;

    // Tile the space
    vec3 i_st = floor(st);
    vec3 f_st = fract(st);

    float m_dist = 1.;  // minimun distance

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
        	for (int z= -1; z <= 1; z++)
        	{
	            // Neighbor place in the grid
	            vec3 neighbor = vec3(float(x), float(y), float(z));

	            // Random position from current + neighbor place in the grid
	            vec3 point = random(i_st + neighbor);

				// Animate the point
	            point = 0.5 + 0.5*sin(u_Time / 300.0 + 6.2831*point);

				// Vector between the pixel and the point
	            vec3 diff = neighbor + point - f_st;

	            // Distance to the point
	            float dist = length(diff);

	            // Keep the closer distance
	            m_dist = min(m_dist, dist);
        	}
        }
    }

    // Draw cell center
    color += vec3(255.0 / 255.0, 75.0 / 255.0, 35.0 / 255.0) * (1.-step(.015, m_dist));

    if (color == vec3(0.0))
    {
    	out_Col = vec4(0.0);
    }
    else
    {
    	out_Col = vec4(color,1.0);
    }
}