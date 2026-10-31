extends Node3D

@export var _pierce_left: int = 2 
@export var damage: int = 10
@export var color: Color = Color("00d9ff")

func _ready() -> void:
	$OmniLight3D.light_color = color
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	$Node3D/MeshInstance3D.material_override = material
	var overlay := StandardMaterial3D.new()
	overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	overlay.albedo_color = color.darkened(0.6)
	$Node3D/MeshInstance3D2.material_overlay = overlay

func shoot(dir: Vector3, _spd: float):
	if dir.length() < 0.01:
		return
	var up_vector = Vector3.UP
	if abs(dir.normalized().dot(Vector3.UP)) > 0.99:
		up_vector = Vector3.FORWARD
	look_at(global_position + dir.normalized(), up_vector)
	rotate_object_local(Vector3.UP, -PI / 2)

@onready var ray_cast = $RayCast3D

func _physics_process(_delta: float) -> void:
	if _pierce_left <= 0:
		queue_free()
		return
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		return
	var collider = ray_cast.get_collider()
	if collider == null or not is_instance_valid(collider) or collider.is_queued_for_deletion():
		return
	if not collider.has_method("take_damage"):
		return
	collider.take_damage(damage)
	_pierce_left -= 1
	if _pierce_left <= 0:
		queue_free()
		return
	ray_cast.add_exception(collider)
	ray_cast.force_raycast_update()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free() 
