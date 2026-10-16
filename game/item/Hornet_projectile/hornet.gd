extends Node3D

@onready var bullet_scene = preload("res://game/item/Hornet_projectile/Hornet_projectile.tscn")

func fire(cam: Camera3D, world_parent: Node, _is_alt: bool = false) -> void:
	var spawn = $BulletSpawn
	var bullet
	bullet = bullet_scene.instantiate()
	_show_muzzle_flash(spawn)
	world_parent.add_child(bullet)
	bullet.global_transform = spawn.global_transform
	var dir := -cam.global_transform.basis.z.normalized()
	if bullet.has_method("shoot"):
		bullet.shoot(dir, 35.0)
	if has_node("shootingSound"):
		var shooting_sound = get_node("shootingSound")
		shooting_sound.pitch_scale = randf_range(1.4, 1.6)
		shooting_sound.play()
	if has_node("shootingSound2") and randf() < 0.25:
		var shooting_sound2 = get_node("shootingSound2")
		shooting_sound2.pitch_scale = randf_range(1.4, 1.6)
		shooting_sound2.play()

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
