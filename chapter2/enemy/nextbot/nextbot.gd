extends "res://chapter2/enemy/BaseEnemy.gd"

var is_chasing_player: bool = false
var ATTACK_DISTANCE: float = 3.0 
var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

func _ready():
	super._ready()
	if player:
		start_chasing_player()

func _disable_combat_states():
	is_chasing_player = false

func _get_boss_id() -> String:
	return "nextbot"

func _process_enemy_behavior(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if not is_chasing_player:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		return
	if player:
		navigation_agent.target_position = player.global_position
		if can_attack_player():
			attack_player()
		move_with_navigation(player.global_position, delta)
	move_and_slide()

func can_attack_player() -> bool:
	if not player:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func start_chasing_player():
	is_chasing_player = true

func stop_chasing_player():
	is_chasing_player = false

func attack_player():
	if not can_attack_player() or is_dead:
		return
	if attack_cooldown <= 0:
		if player:
			$hit.pitch_scale = randf_range(4, 6)
			$hit.play()
			if player.has_method("HP"):
				player.HP(100000)
			if player.has_method("take_damage"):
				player.take_damage(100000)
			take_damage(100000)
			attack_cooldown = ATTACK_COOLDOWN_TIME

func die():
	if is_dying or is_dead:
		return
	super.die()
	is_chasing_player = false
