extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Taser/Taser_projectile.tscn"
	)

func _configure_bullet(bullet: Node3D, is_alt: bool) -> void:
	if is_alt:
		bullet.set("_pierce_left", 50)
		bullet.set("damage", 50)
		bullet.set("color", Color("ff0004"))
