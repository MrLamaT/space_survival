extends "res://game/item/BaseWeapon.gd"

const ToolProjectile = preload(
	"res://game/item/TechnicalTool/technical_tool_projectile.gd"
)

func _init() -> void:
	bullet_scene = preload(
		"res://game/item/TechnicalTool/TechnicalTool_projectile.tscn"
	)

func _configure_bullet(bullet: Node3D, is_alt: bool) -> void:
	if is_alt:
		bullet.set("mode", ToolProjectile.Mode.FREEZE)
	else:
		bullet.set("mode", ToolProjectile.Mode.AGGRO)

func fire(
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	if is_alt:
		var player := get_tree().get_first_node_in_group("player")
		if is_instance_valid(player) and player.has_method("openUI"):
			player.call("openUI", "aggression")
		return
	_fire_projectile(bullet_scene, cam, world_parent, false)

func fireAggro(
	cam: Camera3D,
	world_parent: Node,
	is_alt: bool = false
) -> void:
	fire(cam, world_parent, is_alt)

func fireFreeze(
	cam: Camera3D,
	world_parent: Node,
	_is_alt: bool = false
) -> void:
	_fire_projectile(bullet_scene, cam, world_parent, true)
