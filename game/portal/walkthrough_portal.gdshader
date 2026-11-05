shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D portal_texture : source_color, filter_linear, repeat_disable;

void fragment() {
    ALBEDO = texture(portal_texture, SCREEN_UV).rgb;
}