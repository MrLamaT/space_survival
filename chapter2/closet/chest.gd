extends Area3D

@export var chest: String

func _ready() -> void:
	var world_data = Global.get_world(Global.game_settings.word)
	if not world_data.inventory.has(chest):
		world_data.inventory[chest] = []

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.open_inventory(chest, "storage", 4, 1)

func _on_mouse_entered() -> void:
	$Sprite3D.modulate = Color("ffffffff")
	$Sprite3D.shaded = false
	$Sprite3D/OmniLight3D.visible = true

func _on_mouse_exited() -> void:
	$Sprite3D.modulate = Color("402923")
	$Sprite3D.shaded = true
	$Sprite3D/OmniLight3D.visible = false
