extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Summon/Summon_projectile.tscn"
	)
	muzzle_flash_enabled = false
	shooting_sound_enabled = false

func fire(
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	if is_alt:
		var player := get_tree().get_first_node_in_group("player")
		if is_instance_valid(player) and player.has_method("openUI"):
			player.call("openUI", "spawn")
		return
	super.fire(cam, world_parent, false)
