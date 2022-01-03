shader_type spatial;
render_mode unshaded, cull_front;

uniform bool enable = true;
uniform vec4 color : hint_color = vec4(0.0);

void vertex() {
	if (enable) {
		VERTEX += NORMAL*0.1;
	}
}

void fragment() {
	if (enable) {
		ALBEDO = color.rgb;
	}
}