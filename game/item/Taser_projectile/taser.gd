extends Node3D

@onready var bullet_scene = preload("res://game/item/Taser_projectile/Taser_projectile.tscn")
@onready var Alt_bullet_scene = preload("res://game/item/Taser_projectile/AltTaser_projectile.tscn")

func fire(cam: Camera3D, world_parent: Node, is_alt: bool = false) -> void:
	var spawn = $BulletSpawn
	var bullet
	if is_alt:
		bullet = Alt_bullet_scene.instantiate()
	else:
		bullet = bullet_scene.instantiate()
	_show_muzzle_flash(spawn)
	world_parent.add_child(bullet)
	bullet.global_transform = spawn.global_transform
	var dir := -cam.global_transform.basis.z.normalized()
	if bullet.has_method("shoot"):
		bullet.shoot(dir, 0.0)
	if has_node("shootingSound"):
		var shooting_sound = get_node("shootingSound")
		shooting_sound.pitch_scale = randf_range(1.4, 1.6)
		shooting_sound.play()

func _show_muzzle_flash(bullet_spawn: Node3D):
	if bullet_spawn.has_node("flash"):
		var flash = bullet_spawn.get_node("flash")
		flash.visible = true
		flash.rotation.z = randi_range(0, 90)
		flash.scale = Vector3(4, 4, 4)
		await get_tree().create_timer(0.033).timeout
		flash.scale = Vector3(2, 2, 2)
		await get_tree().create_timer(0.066).timeout
		flash.visible = false
