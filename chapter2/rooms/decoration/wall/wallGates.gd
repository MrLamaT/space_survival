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
	$StaticBody3D/CollisionShape3DDoor.set_deferred("disabled", unlocked)
	if unlocked:
		$AnimationPlayer.play("open")

func lightOn():
	if has_node("Light"):
		$Light.update_torch_color(Color("f3f1c5"))

func blocking():
	if unlocked:
		$AnimationPlayer.play_backwards("open", -1)
	$SpriteBlock.visible = true
	$StaticBody3D/CollisionShape3DDoor.set_deferred("disabled", false)
	unlocked = false

func unlocking():
	$AnimationPlayer.play("open")
	$SpriteBlock.visible = false
	$StaticBody3D/CollisionShape3DDoor.set_deferred("disabled", true)
	$AudioStreamPlayer3D.play()
	unlocked = true
