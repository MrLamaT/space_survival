extends Area3D

@export var nameUI:String = ""
@export var messages:int = 1
var notificationVar = false

func notificationOn(check):
	notificationVar = check
	if check:
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
	else:
		print(player)

func _on_mouse_entered() -> void:
	$monitor.visible = true
	$Sprite3D.visible = false

func _on_mouse_exited() -> void:
	$monitor.visible = false
	if notificationVar:
		$Sprite3D.visible = true
