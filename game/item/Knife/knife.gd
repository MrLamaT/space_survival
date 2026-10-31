extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Knife/Knife_projectile.tscn"
	)
	muzzle_flash_enabled = false
