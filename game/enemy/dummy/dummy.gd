extends "res://game/enemy/BaseEnemy.gd"

var is_chasing_player: bool = false
var last_animation_state: String = ""

var ATTACK_DISTANCE: float = 2.0 
var KNOCKBACK_FORCE: float = 50.0  # Сила отталкивания
var is_attacking: bool = false

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

# --- Накопительный урон для Label3D ---
var accumulated_damage: int = 0
var damage_reset_timer: float = 0.0
const DAMAGE_RESET_TIME: float = 5.0

func _ready():
	super._ready()
	if randi_range(1, 2) == 1:
		$body/head.visible = true
		$body/head2.visible = false
	else:
		$body/head.visible = false
		$body/head2.visible = true
	if randi_range(1, 2) == 1:
		$body/body.visible = true
		$body/body2.visible = false
	else:
		$body/body.visible = false
		$body/body2.visible = true
	shatter_parts = [
		$body/head,
		$body/body,
		$body/hand1,
		$body/hand2,
		$body/legs1,
		$body/legs2
	]
	if player:
		start_chasing_player()

func _disable_combat_states():
	is_chasing_player = false
	is_attacking = false

func _get_boss_id() -> String:
	return "dummy"

func _process_enemy_watch(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func _process_enemy_behavior(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	# --- Таймер сброса накопленного урона ---
	if damage_reset_timer > 0.0:
		damage_reset_timer -= delta
		if damage_reset_timer <= 0.0:
			accumulated_damage = 0
			_update_damage_label()
	if not is_chasing_player:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		return
	if player:
		if is_attacking:
			move_and_slide()
			return
		if last_animation_state != "move_mode":
			$body/run.play("run")
			$body/AnimationPlayer.play("RESET")
			last_animation_state = "move_mode"
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
	if attack_cooldown <= 0 and not is_attacking:
		if player:
			is_attacking = true
			$hit.pitch_scale = randf_range(4, 6)
			$body/AnimationPlayer.play("attack")
			if player.has_method("HP"):
				player.HP(40)
			if player.has_method("take_damage"):
				player.take_damage(40)
			if player is CharacterBody3D:
				var knockback_direction = (player.global_position - global_position).normalized()
				player.velocity.x = knockback_direction.x * KNOCKBACK_FORCE
				player.velocity.z = knockback_direction.z * KNOCKBACK_FORCE
				player.velocity.y = KNOCKBACK_FORCE * 0.1
			attack_cooldown = ATTACK_COOLDOWN_TIME
			await get_tree().create_timer(0.5).timeout
			is_attacking = false

func take_damage(damage: int):
	super.take_damage(damage)
	accumulated_damage += damage
	damage_reset_timer = DAMAGE_RESET_TIME
	_update_damage_label()

func _update_damage_label():
	if has_node("Label3D"):
		$Label3D.text = str(accumulated_damage)
