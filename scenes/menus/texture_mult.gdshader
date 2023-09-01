shader_type canvas_item;
uniform sampler2D texture_mult : hint_default_white;
void fragment() {
	COLOR = texture(TEXTURE,UV);
	COLOR *= texture(texture_mult,UV);
	// Place fragment code here.
}
