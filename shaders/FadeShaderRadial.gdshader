shader_type canvas_item;

uniform vec4 first_color : source_color = vec4(1.0);
uniform vec4 second_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float pos_x : hint_range(0.0, 1.0) = 0.5;
uniform float pos_y : hint_range(0.0, 1.0) = 0.5;
uniform float size : hint_range(0.1, 1.0) = 0.5;

void fragment() {
	vec4 texColor = texture(TEXTURE, UV);
	float dist = length(UV - vec2(pos_x,pos_y)) / size;
	vec4 fade = mix(first_color, second_color, dist);
	COLOR = texColor; 
	COLOR.a = fade.a;
}