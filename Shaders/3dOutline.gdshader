shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 color : hint_color = vec4(0.0);

void vertex() {
		VERTEX += NORMAL*0.1;
}

void fragment() {
		ALBEDO = color.rgb;
}