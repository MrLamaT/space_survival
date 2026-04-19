extends Node3D

@export var light = true
@export var emergency_light = false
@export var unlocked = false
@export var key_card = ""

func _ready() -> void:
	if !light:
		$Light.queue_free()
	else:
		if emergency_light:
				$Light.update_torch_color(Color("ff0000ff"))
	if !unlocked:
		if key_card == "":
			$detect/CollisionShape3D.disabled = true
		$StaticBody3D/CollisionShape3DDoor.disabled = false

func lightOn():
	if has_node("Light"):
		$Light.update_torch_color(Color("f3f1c5"))

func unlocking():
	BlockSpawn(false)
	unlocked = true
	$detect/CollisionShape3D.disabled = false

func _on_detect_body_entered(_body: Node3D) -> void:
	var world = Global.get_world(Global.game_settings.word)
	if unlocked or (key_card in world["equipment"]):
		$AnimationPlayer.play("open")
		$AudioStreamPlayer3D.play()
		$StaticBody3D/CollisionShape3DDoor.set_deferred("disabled", true)

func _on_detect_body_exited(_body: Node3D) -> void:
	var world = Global.get_world(Global.game_settings.word)
	if unlocked or (key_card in world["equipment"]):
		$AnimationPlayer.play_backwards("open", -1)
		$AudioStreamPlayer3D.play()

func BlockSpawn(check):
	$SpriteBlock.visible = check
