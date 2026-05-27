shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Параметры портала
uniform vec4 portal_color : source_color = vec4(0.6235, 0.0, 0.6235, 1.0); // #9f009f
uniform float distortion_strength : hint_range(0.0, 0.5) = 0.15;
uniform float spin_speed : hint_range(0.0, 5.0) = 1.5;
uniform float tunnel_depth : hint_range(1.0, 10.0) = 4.0;
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.2;

// Визуальные эффекты
uniform float ripple_frequency : hint_range(1.0, 20.0) = 8.0;
uniform float ripple_speed : hint_range(0.0, 5.0) = 2.0;
uniform float edge_glow_width : hint_range(0.0, 0.5) = 0.15;

// Шум для органичности
uniform float noise_scale : hint_range(0.0, 10.0) = 4.0;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.2;

// Искажение окружения
uniform float environment_distortion : hint_range(0.0, 0.3) = 0.08;
uniform float distortion_radius : hint_range(0.5, 2.0) = 1.2;

// Семплёр для искажения сцены
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Вершинный шейдер для небольшой пульсации
void vertex() {
    float pulse = sin(TIME * 3.0) * 0.02;
    VERTEX += NORMAL * pulse;
}

// Фрагментный шейдер
void fragment() {
    // Нормализованные координаты сферы (UV)
    vec2 uv = UV;
    
    // Центрируем UV (0,0 в центре)
    vec2 centered_uv = uv * 2.0 - 1.0;
    float radius = length(centered_uv);
    
    // Создаём туннельный эффект
    float angle = atan(centered_uv.y, centered_uv.x);
    float spiral = angle + TIME * spin_speed;
    
    // Радиальная пульсация
    float radial_pulse = sin(radius * ripple_frequency - TIME * ripple_speed) * 0.3;
    
    // Глубина туннеля
    float depth_factor = pow(radius, tunnel_depth);
    
    // Основной цвет портала с градиентом
    vec3 base_color = portal_color.rgb;
    
    // Спиральные полосы
    float spiral_pattern = sin(spiral * 6.0 - radius * 15.0);
    spiral_pattern = clamp(spiral_pattern * 0.8 + 0.5, 0.0, 1.0);
    
    // Радиальные волны
    float radial_waves = sin(radius * ripple_frequency * 2.0 - TIME * ripple_speed * 1.5);
    radial_waves = (radial_waves + 1.0) * 0.5;
    
    // Шум для текстуры
    vec2 noise_uv = uv * noise_scale;
    noise_uv.x += TIME * 0.5;
    noise_uv.y += TIME * 0.3;
    float noise_val = sin(noise_uv.x * 3.14159) * cos(noise_uv.y * 3.14159);
    noise_val = noise_val * noise_strength;
    
    // Комбинируем цвета
    vec3 color = base_color;
    color += base_color * spiral_pattern * 0.6;
    color += vec3(0.8, 0.2, 0.8) * radial_waves * 0.4;
    color += vec3(1.0, 0.5, 1.0) * radial_pulse * 0.5;
    color += vec3(0.5, 0.0, 0.5) * noise_val;
    
    // Свечение по краям (градиент от центра)
    float edge_glow = smoothstep(0.7, 0.95, radius) * edge_glow_width * 2.0;
    edge_glow += (1.0 - radius) * 0.8;
    color += vec3(1.0, 0.3, 1.0) * edge_glow * glow_intensity;
    
    // Центральная яркая точка
    float core_glow = (1.0 - smoothstep(0.0, 0.2, radius)) * 0.8;
    color += vec3(1.0, 0.6, 1.0) * core_glow;
    
    // Интенсивность зависит от радиуса (темнее к краям)
    float intensity = 1.0 - smoothstep(0.5, 1.0, radius) * 0.5;
    color *= intensity;
    
    // Альфа-канал для полупрозрачности краёв
    float alpha = 1.0 - smoothstep(0.8, 0.98, radius);
    alpha = clamp(alpha + 0.3, 0.3, 0.95);
    
    // === ИСКАЖЕНИЕ ПРОСТРАНСТВА ВОКРУГ ===
    vec2 screen_uv = SCREEN_UV;
    
    // Создаём искажение на основе радиуса и угла
    float distortion_rad = radius / distortion_radius;
    float distortion_amount = environment_distortion * (1.0 - smoothstep(0.0, 1.0, distortion_rad));
    
    // Вращающееся искажение
    float distortion_angle = angle * 3.0 - TIME * 2.0;
    vec2 distortion_offset = vec2(cos(distortion_angle), sin(distortion_angle)) * distortion_amount;
    
    // Радиальное искажение (линза)
    distortion_offset += (centered_uv / (radius + 0.1)) * distortion_amount * 0.5;
    
    // Добавляем пульсирующее искажение
    float pulse_distort = sin(TIME * 8.0) * distortion_amount * 0.3;
    distortion_offset += vec2(centered_uv.y, centered_uv.x) * pulse_distort;
    
    // Искажаем UV экрана
    vec2 distorted_uv = screen_uv + distortion_offset;
    
    // Захватываем искажённую сцену
    vec3 distorted_scene = textureLod(screen_texture, distorted_uv, 0.0).rgb;
    
    // Эффект "рыбьего глаза" на краях портала
    float fish_eye = 1.0 + (radius * radius) * 0.2;
    distorted_scene *= fish_eye;
    
    // Смешиваем цвет портала с искажённой сценой
    // В центре портал, по краям - искажённая сцена
    float blend_factor = smoothstep(0.2, 0.7, radius);
    blend_factor = clamp(blend_factor + radial_pulse * 0.2, 0.0, 1.0);
    
    vec3 final_color = mix(color, distorted_scene, blend_factor);
    
    // Добавляем свечение поверх сцены
    final_color = mix(final_color, color, alpha * 0.6);
    
    // Инвертируем альфа для эффекта (делаем центр более непрозрачным)
    ALPHA = 1.0 - smoothstep(0.0, 0.9, radius) * 0.7;
    
    // Финальный цвет с усилением яркости
    ALBEDO = final_color;
    EMISSION = color * (0.3 + glow_intensity * 0.4);
    ROUGHNESS = 0.2;
    METALLIC = 0.8;
}