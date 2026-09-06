shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform int grid_size = 4; // Меньше квадратов = больше размер (4x4 = 16 больших квадратов)
uniform float seed : hint_range(0.0, 100.0) = 0.0; // Меняйте вручную для разных паттернов

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

// Псевдо-случайная функция
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Функция для получения случайной позиции ячейки
vec2 get_swapped_cell(vec2 cell_index, float seed_val) {
    float grid_size_f = float(grid_size);
    float total_cells = grid_size_f * grid_size_f;
    
    // Генерируем случайный индекс для этой ячейки
    float random_val = hash(cell_index + vec2(seed_val, seed_val * 2.0));
    float random_index = floor(random_val * total_cells);
    
    // Преобразуем случайный индекс обратно в координаты ячейки
    float new_x = floor(mod(random_index, grid_size_f));
    float new_y = floor(random_index / grid_size_f);
    
    return vec2(new_x, new_y);
}

void fragment() {
    float grid_size_f = float(grid_size);
    
    // Определяем текущую ячейку
    vec2 cell_index = floor(SCREEN_UV * grid_size_f);
    
    // Получаем случайную ячейку для замены
    vec2 swapped_cell = get_swapped_cell(cell_index, seed);
    
    // Вычисляем UV внутри текущей ячейки
    vec2 local_uv = fract(SCREEN_UV * grid_size_f);
    
    // Вычисляем финальный UV из случайной ячейки
    vec2 final_uv = (swapped_cell + local_uv) / grid_size_f;
    
    // Берем цвет из случайной ячейки
    vec4 color = texture(screen_texture, final_uv);
    
    ALBEDO = color.rgb;
}