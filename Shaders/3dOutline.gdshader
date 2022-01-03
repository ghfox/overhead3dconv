shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 color : hint_color = vec4(0.0);
uniform bool enable = false;

void vertex() {
	if(enable)
	{
		VERTEX += NORMAL*0.1;
	}
}

void fragment() {
	if(enable)
	{
		ALBEDO = color.rgb;
	}
	else
	{
		ALPHA = 0.0;
	}
}