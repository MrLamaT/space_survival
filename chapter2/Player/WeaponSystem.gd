extends Node
class_name WeaponSystem

@export var player: CharacterBody3D
@export var hand_position: Node3D
@export var bullet_spawn_point: Node3D
@export var raycast: RayCast3D
@export var cam: Camera3D

var current_weapon: Node3D = null
var current_weapon_name: String = ""
var is_reloading: bool = false
var fire_rate: float = 0.2
var last_fire_time: float = 0.0
var bullet_speed: float = 50.0
var stamina_cost_per_shot: float = 8.0
var min_stamina_to_shoot: float = 5.0

var weapon_slots: Dictionary = {
	1: "",
	2: "",
	3: "",
	4: "",
	5: "",
	6: "",
	7: "",
	8: ""
}

var weapons: Dictionary = {
	"Vibro Spike": {
		"scene": preload("res://chapter2/item/Knife_projectile/Knife_projectile.tscn"),
		"weapon_scene": preload("res://chapter2/item/Knife_projectile/Knife.tscn"),
		"fire_rate": 0.75,
		"bullet_speed": 0.0,
		"stamina_cost": 2.0,
		"shoot_animation": "shoot",
		"visible_node": "Knife",
		"pitch_scale": [1.4, 1.6]
	},
	"Taser": {
		"scene": preload("res://chapter2/item/Taser_projectile/Taser_projectile.tscn"),
		"weapon_scene": preload("res://chapter2/item/Taser_projectile/Taser.tscn"),
		"fire_rate": 0.2,
		"bullet_speed": 50.0,
		"stamina_cost": 8.0,
		"reload_animation": "r",
		"visible_node": "Taser",
		"pitch_scale": [1.4, 1.6]
	},
	"Hornet": {
		"scene": preload("res://chapter2/item/Hornet_projectile/Hornet_projectile.tscn"),
		"weapon_scene": preload("res://chapter2/item/Hornet_projectile/Hornet.tscn"),
		"fire_rate": 0.06,
		"bullet_speed": 35.0,
		"stamina_cost": 1.5,
		"reload_animation": "r",
		"visible_node": "Hornet",
		"pitch_scale": [1.4, 1.6]
	},
	"Move": {
		"scene": preload("res://chapter2/item/Move_projectile/Move_projectile.tscn"),
		"weapon_scene": preload("res://chapter2/item/Move_projectile/Move.tscn"),
		"fire_rate": 0.5,
		"bullet_speed": 0.0,
		"stamina_cost": 0.0,
		"shoot_animation": "shoot",
		"visible_node": "Move"
	},
	"Delete": {
		"scene": preload("res://chapter2/item/Delete_projectile/Delete_projectile.tscn"),
		"weapon_scene": preload("res://chapter2/item/Delete_projectile/Delete.tscn"),
		"fire_rate": 0.5,
		"bullet_speed": 0.0,
		"stamina_cost": 0.0,
		"visible_node": "Delete"
	},
	"Summon": {
		"scene": preload("res://chapter2/item/Summon_projectile/Summon_projectile.tscn"),
		"weapon_scene": preload("res://chapter2/item/Summon_projectile/Summon.tscn"),
		"fire_rate": 0.5,
		"bullet_speed": 0.0,
		"stamina_cost": 0.0,
		"visible_node": "Summon"
	}
}

func _ready():
	if not player:
		player = get_parent()

func equip_weapon(weapon_name: String):
	if current_weapon:
		current_weapon.visible = false
	
	current_weapon_name = weapon_name
	if weapon_name == "" or not weapons.has(weapon_name):
		current_weapon = null
		return
	
	var weapon_data = weapons[weapon_name]
	if hand_position.has_node(weapon_data["visible_node"]):
		current_weapon = hand_position.get_node(weapon_data["visible_node"])
		current_weapon.visible = true
		if current_weapon.has_node("AnimationPlayer"):
			current_weapon.get_node("AnimationPlayer").play("take")
	else:
		var weapon_scene = weapon_data.get("weapon_scene")
		if weapon_scene:
			current_weapon = weapon_scene.instantiate()
			current_weapon.name = weapon_data["visible_node"]
			hand_position.add_child(current_weapon)
			current_weapon.visible = true
			if current_weapon.has_node("AnimationPlayer"):
				current_weapon.get_node("AnimationPlayer").play("take")

func shoot():
	if Global.game_settings["UI"]:
		return
	if not current_weapon:
		return
	if not player.movement_enabled or Global.game_settings["IsDying"]:
		return
	if player.stamina < min_stamina_to_shoot:
		return
	
	var weapon_data = weapons[current_weapon_name]
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_fire_time < weapon_data["fire_rate"]:
		return
	
	player.stamina = max(0, player.stamina - weapon_data["stamina_cost"])
	player.can_regenerate = false
	player.regen_timer = 0.0
	player.update_stamina_display()
	
	if weapon_data.has("shoot_animation") and weapon_data["shoot_animation"] != "":
		if current_weapon and current_weapon.has_node("AnimationPlayer"):
			current_weapon.get_node("AnimationPlayer").play(weapon_data["shoot_animation"])
	
	is_reloading = false
	if player.stamina < weapon_data["stamina_cost"] + 5.0 and !is_reloading:
		is_reloading = true
		if weapon_data.has("reload_animation") and weapon_data["reload_animation"] != "":
			if current_weapon and current_weapon.has_node("AnimationPlayer"):
				current_weapon.get_node("AnimationPlayer").play(weapon_data["reload_animation"])
	
	var bullet = weapon_data["scene"].instantiate()
	player.get_parent().add_child(bullet)
	bullet.global_transform = bullet_spawn_point.global_transform
	
	var shoot_direction = -cam.global_transform.basis.z.normalized()
	if raycast and raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		shoot_direction = (hit_point - bullet_spawn_point.global_position).normalized()
	
	if bullet.has_method("shoot"):
		bullet.shoot(shoot_direction, weapon_data["bullet_speed"])
	elif bullet.has_method("apply_central_impulse") and bullet is RigidBody3D:
		bullet.apply_central_impulse(shoot_direction * weapon_data["bullet_speed"])
	elif bullet.has_method("set_velocity") and bullet is CharacterBody3D:
		bullet.velocity = shoot_direction * weapon_data["bullet_speed"]
	
	last_fire_time = current_time
	if current_weapon and current_weapon.has_node("shootingSound"):
		var shooting_sound = current_weapon.get_node("shootingSound")
		var pitch_range = weapon_data.get("pitch_scale", [1.4, 1.6])
		shooting_sound.pitch_scale = randf_range(pitch_range[0], pitch_range[1])
		shooting_sound.play()
	if current_weapon and current_weapon.has_node("shootingSound2") and randf() < 0.25:
		var shooting_sound2 = current_weapon.get_node("shootingSound2")
		var pitch_range = weapon_data.get("pitch_scale", [1.4, 1.6])
		shooting_sound2.pitch_scale = randf_range(pitch_range[0], pitch_range[1])
		shooting_sound2.play()
	add_recoil()

func add_recoil():
	var recoil_up = randf_range(1.0, 2.0) * 0.01
	cam.rotate_x(recoil_up)
	var camera_x_rotation = cam.rotation.x
	if camera_x_rotation < deg_to_rad(-89):
		cam.rotation.x = deg_to_rad(-89)
	elif camera_x_rotation > deg_to_rad(89):
		cam.rotation.x = deg_to_rad(89)

func has_weapon_in_slot(slot: int) -> bool:
	return weapon_slots.get(slot, "") != ""

func get_weapon_in_slot(slot: int) -> String:
	return weapon_slots.get(slot, "")

func set_weapon_in_slot(slot: int, weapon_name: String):
	weapon_slots[slot] = weapon_name
