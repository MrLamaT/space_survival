extends StaticBody3D

func _ready():
	var material_paths = [
		"res://assets/material/backrooms_wall1.tres",
		"res://assets/material/backrooms_wall2.tres",
		"res://assets/material/backrooms_wall3.tres",
		"res://assets/material/backrooms_wall4.tres"
	]
	var random_index = randi() % material_paths.size()
	var selected_path = material_paths[random_index]
	var material = load(selected_path)
	$MeshInstance3D.set_surface_override_material(0, material)
