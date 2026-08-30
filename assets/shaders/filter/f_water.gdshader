shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;

// Параметры эффекта (идеальный баланс)
uniform float distortion : hint_range(0.0, 0.02) = 0.006;
uniform float wave_amplitude : hint_range(0.0, 0.002) = 0.0006;
uniform float wave_speed : hint_range(0.0, 0.3) = 0.08;
uniform float wave_frequency : hint_range(0.0, 2.0) = 0.8;
uniform float time_scale : hint_range(0.0, 0.1) = 0.04;

// Цветовая гамма
uniform vec3 color_tint : source_color = vec3(0.1, 0.3, 0.6);
uniform float tint_intensity : hint_range(0.0, 0.1) = 0.04;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 uv_centered = uv * 2.0 - 1.0;
    
    // Очень мягкая волновая дисторсия
    float time = TIME * time_scale;
    float wave1 = sin(uv.y * wave_frequency + time * wave_speed) * wave_amplitude;
    float wave2 = cos(uv.x * wave_frequency * 0.7 + time * wave_speed * 1.3) * wave_amplitude * 0.6;
    
    vec2 wave_offset = vec2(wave1 + wave2 * 0.3, wave2 * 0.4 + wave1 * 0.2);
    
    // Очень мягкая радиальная дисторсия
    float radius = length(uv_centered);
    float factor = 1.0 + distortion * radius * radius * 0.5;
    vec2 distorted_uv = (uv_centered / factor) * 0.5 + 0.5;
    
    distorted_uv += wave_offset * 0.5;
    
    vec3 color = texture(screen_texture, distorted_uv).rgb;
    
    // Легкий цветовой оттенок
    color = mix(color, color * color_tint, tint_intensity);
    
    // Минимальный сдвиг в синеву
    color.r *= 0.95;
    color.g *= 0.97;
    color.b *= 1.02;
    
    ALBEDO = color;
}