extends Area3D

@onready var light = $MeshInstance3D/OmniLight3D
@onready var mesh_instance = $MeshInstance3D
@export var burning_out: bool = false
@export var torch_color: Color = Color("f3f1c5")

var flicker_patterns = [
	[0.3, 0.7, 0.4, 0.8, 0.2],  # Паттерн 1: быстрое мерцание
	[0.8, 0.9, 0.1, 0.95, 0.85], # Паттерн 2: резкие провалы
	[0.5, 0.6, 0.55, 0.2, 0.65], # Паттерн 3: постепенное угасание
	[0.9, 0.3, 0.8, 0.4, 0.7],   # Паттерн 4: хаотичное мерцание
	[0.6, 0.1, 0.5, 0.9, 0.4]    # Паттерн 5: глубокие провалы
]

var current_pattern = 0
var pattern_index = 0
var flicker_timer = 0.0
var base_energy = 1.0
var base_material_color: Color

func _ready():
	base_energy = light.light_energy
	base_material_color = torch_color
	if mesh_instance.get_surface_override_material_count() == 0:
		var new_material = StandardMaterial3D.new()
		new_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
		new_material.albedo_color = base_material_color
		mesh_instance.set_surface_override_material(0, new_material)
	else:
		var existing_material = mesh_instance.get_surface_override_material(0)
		if existing_material != null:
			existing_material.albedo_color = base_material_color
		else:
			var new_material = StandardMaterial3D.new()
			new_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
			new_material.albedo_color = base_material_color
			mesh_instance.set_surface_override_material(0, new_material)
	light.light_color = base_material_color

func _process(delta):
	if burning_out:
		flicker_timer -= delta
		if flicker_timer <= 0:
			flicker_light()
			flicker_timer = 0.1  

func flicker_light():
	if pattern_index >= flicker_patterns[current_pattern].size():
		pattern_index = 0
		var new_pattern = current_pattern
		while new_pattern == current_pattern:
			new_pattern = randi() % flicker_patterns.size()
		current_pattern = new_pattern
	
	var intensity = flicker_patterns[current_pattern][pattern_index]
	light.light_energy = base_energy * intensity
	
	# Меняем цвет меша
	var mesh_material = mesh_instance.get_surface_override_material(0)
	if mesh_material != null:
		var color_multiplier = intensity * 0.8 + 0.2  
		mesh_material.albedo_color = base_material_color * color_multiplier
	pattern_index += 1

func set_burning_out(value: bool):
	burning_out = value
	if not burning_out:
		light.light_energy = base_energy
		light.light_color = base_material_color
		
		var mesh_material = mesh_instance.get_surface_override_material(0)
		if mesh_material != null:
			mesh_material.albedo_color = base_material_color
		
		pattern_index = 0

func update_torch_color(new_color: Color):
	torch_color = new_color
	base_material_color = new_color
	
	if not burning_out:
		light.light_color = base_material_color
		var mesh_material = mesh_instance.get_surface_override_material(0)
		if mesh_material != null:
			mesh_material.albedo_color = base_material_color
