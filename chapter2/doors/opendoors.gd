extends Area3D

@onready var D1 = $D1
@onready var D1Body1 = $D1/StaticBody3D/Door1
@onready var D1Body2 = $D1/StaticBody3D/Door2
@onready var D1BodyCollision = $D1/StaticBody3D/CollisionShape3D
@onready var audio_player = $AudioStreamPlayer
@onready var audio_player2 = $AudioStreamPlayer2
@export var is_exclusive_to_enemy: bool = false 
@export var need_key: bool = false 
@export var keyD: String = "vase" 
@export var enemy_open_delay: float = 1.0
var open = false

func _ready() -> void:
	if is_exclusive_to_enemy:
		remove_from_group("interactive_objects")

func trigger_interaction():
	if need_key and Global.game_settings["Item"] != keyD:
		return
	need_key = false
	D1BodyCollision.set_deferred("disabled", true)
	D1.set_deferred("disabled", true)
	audio_player.pitch_scale = randf_range(0.7, 0.9)
	audio_player.volume_db = randf_range(-23.0, -20.0)
	audio_player2.pitch_scale = randf_range(0.7, 0.9)
	audio_player2.volume_db = randf_range(-23.0, -20.0)
	if open:
		$AnimationPlayer.play("close")
		audio_player2.play()
	else:
		$AnimationPlayer.play("open")
		audio_player.play()
	open = !open

func _on_mouse_entered() -> void:
	if need_key and Global.game_settings["Item"] != keyD:
		$D1/Label3D.visible = true
		$D1/DoorENot.visible = true
	else:
		$D1/DoorE.visible = true
		$D1/DoorE2.visible = true

func _on_mouse_exited() -> void:
	$D1/DoorE.visible = false
	$D1/DoorE2.visible = false
	$D1/Label3D.visible = false
	$D1/DoorENot.visible = false

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	D1BodyCollision.set_deferred("disabled", false)
	D1.set_deferred("disabled", false)

func _on_enemy_open_body_entered(body: Node3D) -> void:
	if !open:
		body.apply_shock(1.0)
		await get_tree().create_timer(1).timeout
	if !open:
		call_deferred("trigger_interaction")

func _on_enemy_open_body_exited(_body: Node3D) -> void:
	if open and is_exclusive_to_enemy:
		call_deferred("trigger_interaction")
