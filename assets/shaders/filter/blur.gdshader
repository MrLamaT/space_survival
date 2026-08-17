shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform float blur_strength : hint_range(0.0, 10.0) = 2.0;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec2 texel = 1.0 / vec2(textureSize(screen_texture, 0));
    float s = blur_strength * 0.5;
    
    vec3 sum = vec3(0.0);
    float count = 0.0;
    
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * texel * s;
            sum += texture(screen_texture, SCREEN_UV + offset).rgb;
            count += 1.0;
        }
    }
    
    ALBEDO = sum / count;
}