extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_label: Label3D = $hp

var is_dying: bool = false
var death_timer: float = 0.0
var DEATH_DELAY: float = 1
var death_rotation: float = 0.0

# Настройки движения
var SPEED: float = 6
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0

var is_dead: bool = false
var health: int = 100000

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * 5

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	update_health_label()
	await get_tree().create_timer(2).timeout
	get_tree().get_first_node_in_group("player").look_at_point($body.global_position)

func _physics_process(delta):
	if is_dead:
		return
	if is_dying:
		if not is_on_floor():
			velocity.y -= gravity * delta
		if is_on_floor():
			is_dead = true
			queue_free()
			return
		death_timer += delta
		var progress = min(death_timer / DEATH_DELAY, 1.0)
		death_rotation = progress * 90.0
		rotation_degrees.x = death_rotation
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		return

func die():
	if is_dying or is_dead:
		return
	is_dying = true
	death_timer = 0.0
	death_rotation = 0.0
	$body/AnimationPlayer.stop()
	$body/AnimationPlayer.play("RESET")
	$sparkDead.emitting = true
	$shock.pitch_scale = randf_range(0.9, 1.1)
	$shock.play()
	velocity = Vector3.ZERO

func take_damage(damage):
	health -= damage
	update_health_label()
	if health <= 0:
		$sparkDead.emitting = true
		die()

func update_health_label():
	if health_label:
		health_label.text = str(health) + " HP"
		if health <= 5:
			health_label.modulate = Color(1, 0.3, 0.3) 
		elif health <= 10:
			health_label.modulate = Color(1, 0.8, 0.3)
		else:
			health_label.modulate = Color(1, 1, 1)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fly":
		queue_free()
