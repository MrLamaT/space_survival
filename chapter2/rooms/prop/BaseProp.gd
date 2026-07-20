extends Node

@export var kill_height: float = 1000.0
@export var kill_group: String = "prop"
@export var check_interval: float = 0.1 

var timer: float = 0.0

func _physics_process(delta):
	timer += delta
	if timer < check_interval:
		return
	timer = 0.0
	var props = get_tree().get_nodes_in_group(kill_group)
	for prop in props:
		if abs(prop.global_position.y) > kill_height:
			print("KillZona - ", prop.name, " (удалён)")
			prop.queue_free()
