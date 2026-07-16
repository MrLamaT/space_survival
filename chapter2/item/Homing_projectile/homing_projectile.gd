extends Node3D

var speed: float = 50.0
var direction: Vector3 = Vector3.ZERO
var damage: int = 12
var lifetime: float = 3.0
var timer: float = 0.0

var homing_strength: float = 2.0
var player_reference: Node3D = null

func shoot(dir: Vector3, spd: float):
	direction = dir.normalized()
	speed = spd
	player_reference = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if direction != Vector3.ZERO:
		if player_reference and is_instance_valid(player_reference):
			var player_pos = player_reference.global_position
			var bullet_pos = global_position
			var to_player = Vector3(
				player_pos.x - bullet_pos.x,
				0.0,  
				player_pos.z - bullet_pos.z
			).normalized()
			direction = direction.lerp(to_player, homing_strength * delta).normalized()
		global_translate(direction * speed * delta)
	
	timer += delta
	if timer >= lifetime:
		queue_free()

func on_hit(collider: Object):
	# Эффекты попадания
	if collider.has_method("HP"):
		collider.HP(damage)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("HP"):
		body.HP(damage)
	queue_free()
