shader_type canvas_item;
uniform vec2 offset_r;
uniform vec2 offset_g;
uniform vec2 offset_b;
void fragment() {
	COLOR.r = texture(TEXTURE,UV + offset_r).r;
	COLOR.g = texture(TEXTURE,UV).g;
	COLOR.b = texture(TEXTURE,UV - offset_b).b;
}
