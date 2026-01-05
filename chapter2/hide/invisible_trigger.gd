extends Area3D

@export var can_stand_up: bool = true 
@export var can_throw_item: bool = true 

func _ready():
	$MeshInstance3D.visible = false
	visible = false
	monitoring = true
	monitorable = false

func _on_body_entered(body):
	if body.is_in_group("player"):  
		Global.game_settings["HidePlayer"] = true
		if not can_stand_up:
			Global.game_settings["CanStandUp"] = false
		if not can_throw_item:
			Global.game_settings["CanThrowItem"] = false
		print("HidePlayer установлен в true")

func _on_body_exited(body):
	if body.is_in_group("player"):
		if !Global.game_settings["GodMod"]:
			Global.game_settings["HidePlayer"] = false
			print("HidePlayer установлен в false")
		Global.game_settings["CanStandUp"] = true
		Global.game_settings["CanThrowItem"] = true
		body.force_stand_up()

func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	pass # Replace with function body.
