extends Area3D

## Основные параметры пружины
@export var jump_force: float = 8.5  # Сила прыжка
@export var cooldown_time: float = 5.0  # Время перезарядки

# Внутренние переменные
var is_on_cooldown: bool = false
var target_compression: float = 0.0
var player_in_zone: bool = false
var player_ref: CharacterBody3D = null

# Ссылки на ноды
@onready var visual_node: MeshInstance3D = $MeshInstance3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_top_detection_entered(body):
	if body is CharacterBody3D and not is_on_cooldown:
		_activate_spring(body)

func _on_body_exited(body):
	if body == player_ref:
		player_ref = null
		player_in_zone = false

func _activate_spring(body: CharacterBody3D):
	if is_on_cooldown:
		return
	audio_player.play()
	$Expectation.visible = false
	$Cooldown.visible = true
	var jump_velocity = jump_force
	body.velocity.y = jump_velocity
	var horizontal_force = Vector3(
		randf_range(-2.0, 2.0),
		0,
		randf_range(-2.0, 2.0)
	) * 0.5
	body.velocity += horizontal_force
	is_on_cooldown = true
	player_ref = body
	player_in_zone = true
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("cooldown")
	await get_tree().create_timer(cooldown_time).timeout
	$AnimationPlayer.stop()
	$AnimationPlayer.play("RESET")
	target_compression = 0.0
	is_on_cooldown = false
	#if cooldown_sound:
		#_play_sound(cooldown_sound)
