extends Node3D

var speed: float = 50.0
var direction: Vector3 = Vector3.ZERO
var damage: int = 10
var lifetime: float = 3.0
var timer: float = 0.0

func shoot(dir: Vector3, spd: float):
	direction = dir
	speed = spd

func _physics_process(delta):
	if direction != Vector3.ZERO:
		global_translate(direction * speed * delta)
	
	timer += delta
	if timer >= lifetime:
		queue_free()
	
	# Проверка столкновений
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = from + direction * speed * delta * 2
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent().get_node("Player")]  # исключаем игрока
	query.collision_mask = 4 | 16  # настраивайте маску по необходимости
	
	var result = space_state.intersect_ray(query)
	if result:
		on_hit(result.collider)
		queue_free()

func on_hit(collider: Object):
	# Эффекты попадания
	print(collider)
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
