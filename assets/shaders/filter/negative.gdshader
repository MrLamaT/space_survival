shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    ALBEDO = 1.0 - color.rgb;
}