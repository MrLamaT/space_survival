shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Параметры цвета и свечения
uniform vec4 neon_color : source_color = vec4(0.0, 1.0, 0.5, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float core_width : hint_range(0.0, 1.0) = 0.3;

// Параметры полупрозрачного слоя
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.5, 0.6);
uniform float glow_width : hint_range(0.0, 2.0) = 0.8;
uniform float glow_falloff : hint_range(0.5, 4.0) = 2.0;

// Эффекты
uniform float noise_strength : hint_range(0.0, 0.5) = 0.1;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

// Текстурные координаты (для цилиндрических лазеров)
uniform sampler2D uv_texture : hint_default_white;
uniform bool use_uv_texture = false;

// Переменные для вершинного шейдера
varying float v_uv_x;
varying vec3 v_view_dir;

void vertex() {
	// Передаём UV координату для эффектов
	v_uv_x = UV.x;
	
	// Вычисляем направление камеры для эффекта свечения
	vec3 vertex_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_view_dir = normalize(-vertex_pos);
}

void fragment() {
	// Определяем позицию на меше (используем UV или текстурные координаты)
	float pos = use_uv_texture ? texture(uv_texture, UV).r : v_uv_x;
	
	// Создаём пульсацию
	float pulse = sin(TIME * pulse_speed) * 0.15 + 0.85;
	
	// Шум для мерцания
	float noise_val = sin(pos * 50.0 + TIME * 10.0) * noise_strength;
	noise_val += sin(pos * 120.0 - TIME * 15.0) * noise_strength * 0.5;
	
	// --- ЯДРО (непрозрачный слой) ---
	// Создаём градиент от центра к краям (используем UV.y для цилиндрических мешей)
	float core_mask = 1.0 - abs(UV.y - 0.5) * 2.0;
	core_mask = smoothstep(0.0, core_width, core_mask);
	core_mask = clamp(core_mask + noise_val, 0.0, 1.0);
	
	vec3 core_color = neon_color.rgb;
	float core_alpha = core_mask * neon_color.a;
	
	// --- СВЕЧЕНИЕ (полупрозрачный слой) ---
	float glow_mask = 1.0 - abs(UV.y - 0.5) * 2.0;
	glow_mask = smoothstep(0.0, glow_width, glow_mask);
	glow_mask = pow(glow_mask, glow_falloff);
	
	// Добавляем дополнительное свечение по краям UV.x (для длинных лазеров)
	float edge_glow = 1.0 - abs(pos * 2.0 - 1.0);
	edge_glow = pow(edge_glow, 2.0) * 0.5;
	glow_mask = max(glow_mask, edge_glow);
	
	// Применяем пульсацию и шум
	glow_mask = glow_mask * pulse + noise_val * 0.3;
	glow_mask = clamp(glow_mask, 0.0, 1.0);
	
	vec3 glow_color_final = glow_color.rgb * glow_intensity;
	float glow_alpha = glow_mask * glow_color.a;
	
	// --- КОМПОЗИЦИЯ ---
	// Смешиваем свечение и ядро
	vec3 final_color = core_color * core_alpha + glow_color_final * glow_alpha;
	float final_alpha = clamp(core_alpha + glow_alpha, 0.0, 1.0);
	
	ALBEDO = final_color;
	ALPHA = final_alpha;
	
	// Эмиссия для настоящего свечения (бонусный эффект)
	EMISSION = glow_color_final * glow_alpha * 1.5 + core_color * core_alpha;
	
	// Настройки материала
	METALLIC = 0.0;
	ROUGHNESS = 0.3;
}