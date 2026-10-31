extends "res://game/item/BaseWeapon.gd"

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/Move/Move_projectile.tscn"
	)
	muzzle_flash_enabled = false
	shooting_sound_enabled = false

func fire(
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	if is_alt:
		var player = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player):
			return
		var holder = player.object_holder
		if is_instance_valid(holder) and holder.held_object:
			holder.release(false)
		return
	super.fire(cam, world_parent, false)
