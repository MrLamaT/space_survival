extends RigidBody3D

@export var jump_force: float = 8.5  # Сила прыжка

var target_compression: float = 0.0
var player_in_zone: bool = false
var player_ref: CharacterBody3D = null

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_top_detection_entered(body):
	if body is CharacterBody3D:
		_activate_spring(body)
		if body.is_in_group("player"):
			body.force_stand_up()

func _on_body_exited(body):
	if body == player_ref:
		player_ref = null
		player_in_zone = false

func _activate_spring(body: CharacterBody3D):
	audio_player.play()
	var jump_velocity = jump_force
	body.velocity.y = jump_velocity
	var horizontal_force = Vector3(
		randf_range(-2.0, 2.0),
		0,
		randf_range(-2.0, 2.0)
	) * 0.5
	body.velocity += horizontal_force
	player_ref = body
	player_in_zone = true
