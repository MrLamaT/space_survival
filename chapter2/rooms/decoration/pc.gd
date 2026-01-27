extends Area3D

@export var nameUI:String = ""

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	if nameUI != "":
		player.openUI(nameUI)
	else:
		print(player)

func _on_mouse_entered() -> void:
	$monitor.visible = true

func _on_mouse_exited() -> void:
	$monitor.visible = false
