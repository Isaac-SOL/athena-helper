shader_type canvas_item;

uniform float time_factor = 1.5;
uniform float repetitions = 4.0;

void fragment() {
	vec2 uv = vec2(UV.x, mod(UV.y * repetitions - TIME * time_factor, 1.0));
	COLOR = texture(TEXTURE, uv);
}
