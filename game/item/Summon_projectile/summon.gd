extends Node3D

@onready var bullet_scene = preload("res://game/item/Summon_projectile/Summon_projectile.tscn")

func fire(cam: Camera3D, world_parent: Node, is_alt: bool = false) -> void:
	var spawn = $BulletSpawn
	var bullet
	if is_alt:
		var player = get_tree().get_first_node_in_group("player")
		player.openUI("spawn")
		return
	else:
		bullet = bullet_scene.instantiate()
	world_parent.add_child(bullet)
	bullet.global_transform = spawn.global_transform
	var dir := -cam.global_transform.basis.z.normalized()
	if bullet.has_method("shoot"):
		bullet.shoot(dir, 0.0)
