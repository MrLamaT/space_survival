shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;

// Сила эффекта (0.0 - без изменений, 1.0 - максимальный подъём теней)
uniform float intensity : hint_range(0.0, 25.0) = 0.7;

// Порог яркости, ниже которого начинаем поднимать (0.0 - 1.0)
uniform float shadow_threshold : hint_range(0.0, 25.0) = 0.3;

// Смягчение перехода между тенями и светами
uniform float softness : hint_range(0.01, 25.0) = 0.15;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    vec3 rgb = color.rgb;
    
    // Вычисляем яркость пикселя
    float brightness = dot(rgb, vec3(0.299, 0.587, 0.114));
    
    // Создаём маску для теней (где яркость ниже порога)
    float shadow_mask = 1.0 - smoothstep(shadow_threshold - softness, 
                                         shadow_threshold + softness, 
                                         brightness);
    
    // Поднимаем яркость теней (гамма-коррекция)
    // Используем нелинейное увеличение: чем темнее, тем сильнее поднимаем
    float lift = 1.0 + (0.5 - brightness) * intensity * 2.0;
    lift = max(lift, 1.0); // не делаем светлые участки темнее
    
    // Применяем подъём только к теням
    vec3 brightened = rgb * lift;
    
    // Смешиваем с оригиналом через маску
    ALBEDO = mix(rgb, brightened, shadow_mask * intensity);
}