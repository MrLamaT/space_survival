shader_type spatial;
render_mode blend_mix, cull_disabled;

// Параметры шейдера
uniform sampler2D space_texture : source_color;
uniform float parallax_strength : hint_range(0.0, 0.5) = 0.1;
uniform float speed_multiplier : hint_range(0.0, 5.0) = 1.0;
uniform vec3 wing_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

// Входные данные вершинного шейдера
varying vec3 world_pos;
varying vec3 view_dir;

void vertex() {
	// Передаём мировые координаты вершины во фрагментный шейдер
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Передаём направление на камеру
	vec3 camera_pos = CAMERA_POSITION_WORLD;
	view_dir = normalize(camera_pos - world_pos);
}

void fragment() {
	// Получаем координаты экрана для привязки текстуры к камере
	vec2 screen_uv = SCREEN_UV;
	
	// Добавляем смещение на основе параллакса
	// Эффект "текстура следует за камерой"
	vec2 parallax_offset = view_dir.xy * parallax_strength;
	
	// Вращаем текстуру вместе с камерой для лучшего эффекта
	vec2 uv = screen_uv + parallax_offset;
	
	// Добавляем небольшое движение времени для динамики космоса
	float time_offset = TIME * speed_multiplier * 0.05;
	uv += vec2(time_offset * 0.1, time_offset * 0.05);
	
	// Сэмплируем текстуру космоса
	vec4 tex_color = texture(space_texture, uv);
	
	// Применяем цвет и яркость
	vec3 final_color = tex_color.rgb * wing_color * brightness;
	
	// Немного добавляем свечения на основе угла обзора
	float fresnel = pow(1.0 - abs(dot(view_dir, NORMAL)), 2.0);
	final_color += vec3(0.5, 0.3, 0.8) * fresnel * 0.3;
	
	// Итоговый цвет с альфа-каналом для прозрачности
	ALBEDO = final_color;
	ALPHA = tex_color.a * alpha;
	
	// Добавляем небольшое свечение (эмиссию) для звёздного эффекта
	EMISSION = final_color * 0.3;
	
	// Настройки прозрачности
	ALPHA_HASH_SCALE = 1.0;
}