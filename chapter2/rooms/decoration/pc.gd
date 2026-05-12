extends Area3D

@export var nameUI:String = ""
@export var messages:int = 1
@export var notificationVar:bool = false

func _ready() -> void:
	if nameUI == "":
		remove_from_group("interactive_objects")
	else:
		if notificationVar:
			$Sprite3D.visible = true
		else:
			$Sprite3D.visible = false

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	if nameUI != "":
		if nameUI == "messages":
			player.openMessage(messages)
		elif nameUI == "hacking":
			player.openHack(get_parent())
		else:
			player.openUI(nameUI)

func _on_mouse_entered() -> void:
	if nameUI != "":
		$monitor.visible = true
		$Sprite3D.visible = false

func _on_mouse_exited() -> void:
	$monitor.visible = false
	if notificationVar:
		$Sprite3D.visible = true
