extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Impulse/Impulse_projectile.tscn"
	)
