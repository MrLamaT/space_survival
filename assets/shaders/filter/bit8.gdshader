shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform float levels : hint_range(2.0, 32.0) = 8.0;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    vec3 quantized = floor(color.rgb * levels) / levels;
    ALBEDO = quantized;
}