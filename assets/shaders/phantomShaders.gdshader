shader_type spatial;
render_mode blend_mix, cull_back, unshaded, alpha_to_coverage;

// Параметры текстуры
uniform sampler2D texture_main : source_color;
uniform vec2 texture_scale_main = vec2(2.0, 2.0);
uniform float texture_speed_main = 0.5;

// Параметры перелива
uniform float iridescence_intensity : hint_range(0.0, 1.0) = 0.6;
uniform float iridescence_speed = 1.2;

// Параметры следа
uniform float trail_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float trail_persistence = 2.0;

// Вспомогательные переменные для следа
uniform vec3 trail_position = vec3(0.0);
uniform float trail_time = 0.0;

void fragment() {
    float time = TIME * texture_speed_main;
    float iri_time = TIME * iridescence_speed;
    
    // Оптимизированная работа с UV
    vec2 uv_main = UV * texture_scale_main + vec2(time, time * 0.7);
    vec4 main_color = texture(texture_main, uv_main);
    
    // Оптимизированный расчет альфа-пульсации (меньше вычислений)
    vec3 world_uv = VERTEX + vec3(time, time * 0.5, time * 0.3);
    float t1 = sin(world_uv.x * 3.2 + iri_time) * 0.5 + 0.5;
    float t2 = cos(world_uv.y * 2.4 + iri_time * 0.8) * 0.5 + 0.5;
    float t3 = sin(world_uv.z * 2.8 + iri_time * 0.6) * 0.5 + 0.5;
    
    float alpha_factor = (t1 + t2 + t3) * 0.3333; // /3 заменено на *0.3333
    alpha_factor = sin(alpha_factor * 3.14159) * 0.8 + 0.2;
    
    // Оптимизированный микс цвета
    vec3 purple_color = vec3(0.8, 0.2, 1.0);
    float mix_factor = alpha_factor * iridescence_intensity;
    vec3 final_color = mix(main_color.rgb, purple_color, mix_factor);
    
    // Оптимизированный расчет следа
    vec3 diff = VERTEX - trail_position;
    float dist_to_trail = dot(diff, diff); // Используем квадрат расстояния
    float trail_effect = exp(-dist_to_trail * trail_persistence);
    trail_effect *= sin(trail_time * 8.0) * 0.5 + 0.5;
    trail_effect = min(trail_effect * trail_intensity, 0.8); // clamp заменен на min
    
    // Добавляем свечение следа
    final_color += vec3(1.0, 0.6, 0.2) * trail_effect;
    
    // Альфа
    float alpha = min(alpha_factor * 1.2, 1.0);
    
    ALBEDO = final_color;
    ALPHA = alpha;
    EMISSION = vec3(0.8, 0.3, 0.1) * trail_effect * 1.5;
    METALLIC = 0.1;
    ROUGHNESS = 0.4;
}