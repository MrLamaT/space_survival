extends Node3D

@export var light = true
@export var emergency_light = false
@export var unlocked = false

func _ready() -> void:
	if !light:
		$Light.queue_free()
	else:
		if emergency_light:
				$Light.update_torch_color(Color("ff0000ff"))
	if !unlocked:
		$StaticBody3D/CollisionShape3DDoor.disabled = false

func lightOn():
	if has_node("Light"):
		$Light.update_torch_color(Color("f3f1c5"))

func _on_detect_body_entered(_body: Node3D) -> void:
	if unlocked:
		$AnimationPlayer.play("open")
		$AudioStreamPlayer3D.play()
		$StaticBody3D/CollisionShape3DDoor.set_deferred("disabled", true)

func _on_detect_body_exited(_body: Node3D) -> void:
	if unlocked:
		$AnimationPlayer.play_backwards("open", -1)
		$AudioStreamPlayer3D.play()

func BlockSpawn(check):
	$SpriteBlock.visible = check
