shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(0, 0, 0, 1);
uniform float outline_size = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (base.a > 0.0) {
		COLOR = base;
		return;
	}

	float alpha = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 offset = vec2(float(x), float(y)) * outline_size * TEXTURE_PIXEL_SIZE;
			alpha = max(alpha, texture(TEXTURE, UV + offset).a);
		}
	}

	COLOR = mix(vec4(0.0), outline_color, alpha);
}
