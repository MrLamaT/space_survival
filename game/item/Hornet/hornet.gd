extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Hornet/Hornet_projectile.tscn"
	)
	projectile_speed = 35.0
	second_sound_chance = 0.25
