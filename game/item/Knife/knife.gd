extends "res://game/item/BaseWeapon.gd"

const BOOMERANG_SCENE := preload("res://game/item/Knife/Knife_boomerang.tscn")

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Knife/Knife_projectile.tscn"
	)
	muzzle_flash_enabled = false

func throw_spike(cam: Camera3D, world_parent: Node, _is_alt: bool) -> void:
	if not is_instance_valid(cam) or not is_instance_valid(world_parent):
		return
	var spawn := $BulletSpawn as Marker3D
	var boomerang := BOOMERANG_SCENE.instantiate()
	world_parent.add_child(boomerang)
	boomerang.call("launch", cam, spawn.global_position)
	_play_sound("shootingSound")
