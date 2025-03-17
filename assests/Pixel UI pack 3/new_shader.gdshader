shader_type canvas_item;

uniform float speed = 0.1;
uniform float density = 0.5;

void fragment() {
	vec2 uv_offset = UV + vec2(TIME * speed, 0.0); // Moves fog horizontally
	vec4 fog_color = texture(TEXTURE, uv_offset);
	fog_color.a *= density; // Adjust transparency for thickness
	COLOR = fog_color;
}
