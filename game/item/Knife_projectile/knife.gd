extends Node3D

@onready var bullet_scene = preload("res://game/item/Knife_projectile/Knife_projectile.tscn")

func fire(cam: Camera3D, world_parent: Node, _is_alt: bool = false) -> void:
	var spawn = $BulletSpawn
	var bullet
	bullet = bullet_scene.instantiate()
	world_parent.add_child(bullet)
	bullet.global_transform = spawn.global_transform
	var dir := -cam.global_transform.basis.z.normalized()
	if bullet.has_method("shoot"):
		bullet.shoot(dir, 0.0)
	if has_node("shootingSound"):
		var shooting_sound = get_node("shootingSound")
		shooting_sound.pitch_scale = randf_range(1.4, 1.6)
		shooting_sound.play()
