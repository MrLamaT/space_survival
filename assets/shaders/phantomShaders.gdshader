shader_type spatial;
render_mode blend_mix, cull_back, unshaded, alpha_to_coverage;

// Параметры текстуры
uniform sampler2D texture_main : source_color;
uniform vec2 texture_scale_main = vec2(2.0, 2.0);
uniform float texture_speed_main = 0.5;

// Параметры перелива (полностью прозрачный <-> фиолетовый)
uniform float iridescence_intensity : hint_range(0.0, 1.0) = 0.6;
uniform float iridescence_speed = 1.2;
uniform float iridescence_scale = 4.0;

// Параметры свечения следа
uniform float trail_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float trail_persistence = 2.0;

// Вспомогательные переменные для следа
uniform vec3 trail_position = vec3(0.0);
uniform float trail_time = 0.0;

// Функция для плавного перехода прозрачности
float alpha_pulse(vec3 uv, float time) {
    // Используем синус от времени + координат
    float t1 = sin(uv.x * iridescence_scale * 0.8 + time) * 0.5 + 0.5;
    float t2 = cos(uv.y * iridescence_scale * 0.6 + time * 0.8) * 0.5 + 0.5;
    float t3 = sin(uv.z * iridescence_scale * 0.7 + time * 0.6) * 0.5 + 0.5;
    
    // Комбинируем
    float t = (t1 + t2 + t3) / 3.0;
    
    // Плавная кривая для более интересного перехода
    return sin(t * 3.14159) * 0.8 + 0.2;
}

void fragment() {
    float time = TIME * texture_speed_main;
    float iri_time = TIME * iridescence_speed;
    
    // Координаты UV
    vec2 uv_main = UV * texture_scale_main + vec2(time, time * 0.7);
    
    // Основная текстура
    vec4 main_color = texture(texture_main, uv_main);
    
    // Эффект прозрачности
    vec3 world_uv = (VERTEX + vec3(time, time * 0.5, time * 0.3)) * 0.5;
    float alpha_factor = alpha_pulse(world_uv, iri_time);
    
    // Фиолетовый цвет
    vec3 purple_color = vec3(0.8, 0.2, 1.0);
    
    // Смешиваем текстуру с фиолетовым
    vec3 final_color = mix(main_color.rgb, purple_color, alpha_factor * iridescence_intensity);
    
    // Эффект следа
    float dist_to_trail = length(VERTEX - trail_position);
    float trail_effect = exp(-dist_to_trail * trail_persistence);
    trail_effect *= sin(trail_time * 8.0) * 0.5 + 0.5;
    trail_effect = clamp(trail_effect * trail_intensity, 0.0, 0.8);
    
    // Добавляем свечение следа
    final_color += vec3(1.0, 0.6, 0.2) * trail_effect;
    
    // Прозрачность: 0.0 = полностью прозрачный, 1.0 = полностью видимый
    float alpha = clamp(alpha_factor * 1.2, 0.0, 1.0);
    
    ALBEDO = final_color;
    ALPHA = alpha;
    
    EMISSION = vec3(0.8, 0.3, 0.1) * trail_effect * 1.5;
    METALLIC = 0.1;
    ROUGHNESS = 0.4;
}