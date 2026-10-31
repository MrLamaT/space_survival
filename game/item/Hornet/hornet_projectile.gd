extends Node3D

var speed: float = 50.0
var direction: Vector3 = Vector3.ZERO
var damage: int = 3
var lifetime: float = 3.0
var timer: float = 0.0

var hit_delay: float = 2.0 
var hit_timer: float = 0.0
var is_hit: bool = false
var target_body: Node3D = null  

var orbit_radius: float = 1.0  
var orbit_speed: float = 10.0  
var orbit_angle: float = 0.0 
var orbit_height: float = 0.5
var vertical_oscillation: float = 0.3 

var last_velocity: Vector3 = Vector3.ZERO
var is_flying_away: bool = false

func shoot(dir: Vector3, spd: float):
	var random_deviation = Vector3(
		randf_range(-0.02, 0.02),
		randf_range(-0.02, 0.02),
		randf_range(-0.02, 0.02)
	)
	direction = (dir + random_deviation).normalized()
	speed = spd

func _physics_process(delta):
	if is_flying_away:
		if last_velocity != Vector3.ZERO:
			global_translate(last_velocity * delta)
		hit_timer += delta
		if hit_timer >= hit_delay:
			queue_free()
		return
	if is_hit and (target_body == null or not is_instance_valid(target_body)):
		start_flying_away()
		return
	if is_hit and target_body != null:
		hit_timer += delta
		orbit_angle += orbit_speed * delta
		var target_pos = target_body.global_position
		var offset_x = cos(orbit_angle) * orbit_radius
		var offset_z = sin(orbit_angle) * orbit_radius
		var offset_y = sin(orbit_angle * 1.5) * vertical_oscillation + orbit_height
		var old_pos = global_position
		global_position = target_pos + Vector3(offset_x, offset_y, offset_z)
		last_velocity = (global_position - old_pos) / delta
		if hit_timer >= hit_delay:
			queue_free()
		return
	if direction != Vector3.ZERO:
		global_translate(direction * speed * delta)
	timer += delta
	if timer >= lifetime:
		queue_free()

func start_flying_away():
	if is_flying_away:
		return
	is_flying_away = true
	hit_timer = 0.0
	if last_velocity == Vector3.ZERO or last_velocity.length() < 0.1:
		if target_body != null and is_instance_valid(target_body):
			var dir_from_target = (global_position - target_body.global_position).normalized()
			last_velocity = dir_from_target * speed * 0.5
		else:
			last_velocity = Vector3(randf_range(-1, 1), randf_range(-0.5, 0.5), randf_range(-1, 1)).normalized() * 10.0
	target_body = null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		is_hit = true
		speed = 0.0
		target_body = body
		orbit_angle = randf_range(0, TAU)
		global_position = body.global_position + Vector3(0, 2.0, 0)
