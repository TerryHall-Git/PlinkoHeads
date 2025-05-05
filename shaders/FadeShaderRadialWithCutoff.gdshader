shader_type canvas_item;

uniform vec4 first_color : source_color = vec4(1.0);
uniform vec4 second_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float pos_x : hint_range(0.0, 1.0) = 0.5;
uniform float pos_y : hint_range(0.0, 1.0) = 0.5;
uniform float size : hint_range(0.1, 1.0) = 0.5;
uniform float cutoff : hint_range(0.0, 1.0) = 0.0; // 0.0 = smooth fade, 1.0 = strict cutoff
uniform float rotation_speed : hint_range(0.0, 10.0) = 1.0; // Speed of rotation
uniform float time : hint_range(0.0, 100.0) = 0.0; // Time passed (to be updated externally)

void fragment() {
    vec4 texColor = texture(TEXTURE, UV);
    vec2 center = vec2(pos_x, pos_y);
    float dist = length(UV - center) / size;

    // Apply cutoff logic
    float fade_factor = mix(dist, step(1.0, dist), cutoff);
    vec4 fade = mix(first_color, second_color, fade_factor);

    // Calculate dynamic rotation based on time
    float dynamic_rotation = time * rotation_speed;
    vec2 direction = UV - center;

    // Rotate the UV coordinates
    float cos_angle = cos(dynamic_rotation);
    float sin_angle = sin(dynamic_rotation);
    vec2 rotated_uv = vec2(
        direction.x * cos_angle - direction.y * sin_angle,
        direction.x * sin_angle + direction.y * cos_angle
    ) + center;

    // Sample the texture with rotated UVs
    texColor = texture(TEXTURE, rotated_uv);

    // Blend the texture with the fade color
    COLOR = texColor;
	COLOR.a = fade.a;
}