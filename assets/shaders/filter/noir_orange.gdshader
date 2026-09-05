shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;

// Целевой цвет (в формате RGB, но мы будем сравнивать только его оттенок)
uniform vec3 target_color : source_color = vec3(1.0, 0.0, 0.0);
// Чувствительность по оттенку (0.0 - только точный цвет, 1.0 - все цвета)
uniform float hue_threshold : hint_range(0.0, 1.0) = 0.15;
// Смягчение краёв
uniform float softness : hint_range(0.0, 0.5) = 0.05;
// Минимальная насыщенность (чтобы не сохранять серые цвета)
uniform float min_saturation : hint_range(0.0, 1.0) = 0.1;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

// Функция конвертации RGB в HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    
    // Получаем HSV цвета на экране
    vec3 hsv = rgb2hsv(color.rgb);
    
    // Получаем HSV целевого цвета
    vec3 target_hsv = rgb2hsv(target_color);
    
    // Вычисляем разницу по оттенку (Hue) - учитываем, что hue цикличен (0-360 градусов)
    float hue_diff = abs(hsv.x - target_hsv.x);
    // Обрабатываем циклический переход (например, если hue=0.9 и target=0.1, разница должна быть 0.2, а не 0.8)
    hue_diff = min(hue_diff, 1.0 - hue_diff);
    
    // Создаём маску: 1.0 - оставляем цвет, 0.0 - делаем серым
    float mask = 1.0 - smoothstep(hue_threshold - softness, hue_threshold + softness, hue_diff);
    
    // Дополнительно: не сохраняем слишком бледные/серые цвета
    float saturation_mask = step(min_saturation, hsv.y);
    mask *= saturation_mask;
    
    // Переводим в серый
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 gray_color = vec3(gray);
    
    // Смешиваем
    ALBEDO = mix(gray_color, color.rgb, mask);
}