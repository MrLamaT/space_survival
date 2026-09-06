shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;

// Сила смещения каналов
uniform float shift_strength : hint_range(0.0, 0.05) = 0.005;
// Направление смещения (угол в радианах)
uniform float shift_angle : hint_range(0.0, 6.283) = 0.0;
// Смешивание с оригиналом (0 - только оригинал, 1 - только эффект)
uniform float blend : hint_range(0.0, 1.0) = 1.0;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    // Вычисляем вектор смещения
    vec2 shift_vec = vec2(cos(shift_angle), sin(shift_angle)) * shift_strength;
    
    // Смещаем каждый цветовой канал
    vec2 uv_r = SCREEN_UV + shift_vec;
    vec2 uv_g = SCREEN_UV;
    vec2 uv_b = SCREEN_UV - shift_vec;
    
    // Забираем цвета из смещенных позиций
    float r = texture(screen_texture, uv_r).r;
    float g = texture(screen_texture, uv_g).g;
    float b = texture(screen_texture, uv_b).b;
    
    // Собираем итоговый цвет
    vec3 shifted_color = vec3(r, g, b);
    
    // Оригинальный цвет
    vec3 original_color = texture(screen_texture, SCREEN_UV).rgb;
    
    // Смешиваем оригинал с эффектом
    vec3 final_color = mix(original_color, shifted_color, blend);
    
    ALBEDO = final_color;
}