shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform float distortion : hint_range(-0.5, 0.5) = 0.3;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV * 2.0 - 1.0;
    float radius = length(uv);
    float factor = 1.0 + distortion * radius * radius;
    vec2 distorted_uv = uv / factor;
    distorted_uv = distorted_uv * 0.5 + 0.5;
    
    // Проверка на выход за границы
    if (distorted_uv.x >= 0.0 && distorted_uv.x <= 1.0 && 
        distorted_uv.y >= 0.0 && distorted_uv.y <= 1.0) {
        ALBEDO = texture(screen_texture, distorted_uv).rgb;
    } else {
        ALBEDO = vec3(0.0); // чёрные края
    }
}