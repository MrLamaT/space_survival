extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_area: Area3D = $VisionArea

var current_target: Node3D = null
var player: Node3D = null
var is_chasing_player: bool = false

# Настройки движения
var SPEED: float = 3.5
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0

# Дистанция атаки
var ATTACK_DISTANCE: float = 2.0 

var previous_position: Vector3
var movement_direction: Vector3
var spawnpoint: Vector3

var is_dead: bool = false
var health: int = 100

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	player = get_tree().get_first_node_in_group("player")
	previous_position = global_position
	current_target = null

func _physics_process(delta):
	if is_dead:
		return
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
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		if direction.length() > 0.1:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
		var target_velocity = direction * SPEED
		velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	movement_direction = global_position - previous_position
	previous_position = global_position
	move_and_slide()

func can_attack_player() -> bool:
	if not player or Global.game_settings["GodMod"]:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func lose_player():
	is_chasing_player = false

func start_chasing_player():
	current_target = player
	is_chasing_player = true

func stop_chasing_player():
	is_chasing_player = false
	current_target = null

func attack_player():
	if not can_attack_player() or is_dead:
		return
	if attack_cooldown <= 0:
		if player and player.has_method("HP"):
			player.look_at_point(global_position)
			player.HP(10)
			attack_cooldown = ATTACK_COOLDOWN_TIME

func die():
	is_dead = true
	queue_free()

func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		start_chasing_player()
		
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()
	else:
		pass
