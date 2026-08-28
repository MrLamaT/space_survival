extends Node3D

@export var light = false

func _ready():
	if !light:
		$Light.queue_free()
	randomize()
	var random_angle = randf_range(-45.0, 45.0) 
	$chair.rotation_degrees.y = random_angle
