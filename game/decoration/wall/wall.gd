extends Node3D

@export var light = true
@export var emergency_light = false
@export var glass = false

func _ready() -> void:
	if !light and has_node("Light"):
		$Light.queue_free()
	else:
		if emergency_light:
			$Light.update_torch_color(Color("ff0000ff"))
	if glass:
		var glass_mat = load("res://assets/material/glass.tres")
		$StaticBody3D/wall/box.material = glass_mat
		$StaticBody3D/wall/box.size = Vector3(4.9, 2.5, 1.0)
