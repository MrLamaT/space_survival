extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Delete/Delete_projectile.tscn"
	)
	muzzle_flash_enabled = false
	shooting_sound_enabled = false
