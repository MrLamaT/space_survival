extends "res://game/item/BaseWeapon.gd"

const PELLET_SCENE := preload(
	"res://game/item/Breaker/Breaker_projectile.tscn"
)

var pellet_count: int = 10
var pellet_speed: float = 35.0
var spread_degrees: float = 30.0

func fire(
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	if is_alt:
		return
	if not is_instance_valid(cam):
		return
	if not is_instance_valid(world_parent):
		return
	var spawn := get_node_or_null("BulletSpawn") as Node3D
	if spawn == null:
		return
	var aim_basis := cam.global_transform.basis.orthonormalized()
	for i in range(pellet_count):
		var pellet := PELLET_SCENE.instantiate()
		world_parent.add_child(pellet)
		pellet.global_position = spawn.global_position
		pellet.shoot(
			_spread_direction(aim_basis),
			pellet_speed
		)
	_show_muzzle_flash(spawn)
	_play_sound("shootingSound")

func _spread_direction(aim_basis: Basis) -> Vector3:
	var half_angle := deg_to_rad(spread_degrees * 0.5)
	var cos_theta := lerpf(cos(half_angle), 1.0, randf())
	var sin_theta := sqrt(maxf(0.0, 1.0 - cos_theta * cos_theta))
	var angle := randf() * TAU

	var local_direction := Vector3(
		cos(angle) * sin_theta,
		sin(angle) * sin_theta,
		-cos_theta
	)
	return (aim_basis * local_direction).normalized()
