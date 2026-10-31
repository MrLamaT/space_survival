extends Node3D

var bullet_scene: PackedScene
var alt_bullet_scene: PackedScene

var projectile_speed: float = 0.0
var muzzle_flash_enabled: bool = true
var shooting_sound_enabled: bool = true
var second_sound_chance: float = 0.0

var _flash_tween: Tween

func fire(
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	_fire_projectile(
		_get_bullet_scene(is_alt),
		cam,
		world_parent,
		is_alt
	)

# выбор сцены снаряда.
func _get_bullet_scene(is_alt: bool) -> PackedScene:
	if is_alt and alt_bullet_scene != null:
		return alt_bullet_scene
	return bullet_scene

func _fire_projectile(
	scene: PackedScene,
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	if scene == null:
		push_warning("%s: не задана сцена снаряда." % name)
		return
	if not is_instance_valid(cam) or not is_instance_valid(world_parent):
		return
	var spawn := get_node_or_null("BulletSpawn") as Node3D
	if spawn == null:
		push_warning("%s: отсутствует узел BulletSpawn." % name)
		return
	var bullet := scene.instantiate() as Node3D
	if bullet == null:
		push_error("%s: корень сцены снаряда должен быть Node3D." % name)
		return
	_configure_bullet(bullet, is_alt)
	world_parent.add_child(bullet)
	bullet.global_transform = spawn.global_transform
	var direction := -cam.global_transform.basis.z.normalized()
	if bullet.has_method("shoot"):
		bullet.call("shoot", direction, projectile_speed)
	if muzzle_flash_enabled:
		_show_muzzle_flash(spawn)
	if shooting_sound_enabled:
		_play_sound("shootingSound")
		if second_sound_chance > 0.0 and randf() < second_sound_chance:
			_play_sound("shootingSound2")

# оружием с особыми параметрами снаряда.
func _configure_bullet(_bullet: Node3D, _is_alt: bool) -> void:
	pass

func _play_sound(node_path: NodePath) -> void:
	var sound := get_node_or_null(node_path)
	if sound is AudioStreamPlayer2D:
		sound.pitch_scale = randf_range(1.4, 1.6)
		sound.play()

func _show_muzzle_flash(spawn: Node3D) -> void:
	var flash := spawn.get_node_or_null("flash") as Node3D
	if flash == null:
		return
	if _flash_tween != null:
		_flash_tween.kill()
	flash.visible = true
	flash.rotation_degrees.z = randf_range(0.0, 90.0)
	flash.scale = Vector3(4.0, 4.0, 4.0)
	_flash_tween = create_tween()
	_flash_tween.tween_interval(0.033)
	_flash_tween.tween_property(
		flash, "scale", Vector3(2.0, 2.0, 2.0), 0.0
	)
	_flash_tween.tween_interval(0.066)
	_flash_tween.tween_property(flash, "visible", false, 0.0)
