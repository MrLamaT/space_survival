extends Node
class_name WeaponSystem

@export var player: CharacterBody3D
@export var hand_position: Node3D
@export var cam: Camera3D

var current_weapon: Node3D = null
var current_weapon_name: String = ""
var is_reloading: bool = false
var fire_rate: float = 0.2
var last_fire_time: float = 0.0
var bullet_speed: float = 50.0
var stamina_cost_per_shot: float = 8.0
var min_energy_to_shoot: float = 5.0

var is_alt_shooting: bool = false
var last_alt_fire_time: float = 0.0

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
		"scene": preload("res://game/item/Knife_projectile/Knife_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Knife_projectile/Knife.tscn"),
		"fire_rate": 0.75,
		"bullet_speed": 0.0,
		"energy_cost": 2.0,
		"shoot_animation": "shoot",
		"visible_node": "Knife",
		"pitch_scale": [1.4, 1.6]
	},
	"Taser": {
		"scene": preload("res://game/item/Taser_projectile/Taser_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Taser_projectile/Taser.tscn"),
		"fire_rate": 0.65,
		"bullet_speed": 0.0,
		"energy_cost": 20.0,
		"shoot_animation": "shoot",
		"visible_node": "Taser",
		"pitch_scale": [1.4, 1.6],
		"alt": {
			"scene": preload("res://game/item/Taser_projectile/AltTaser_projectile.tscn"),
			"fire_rate": 0.65,
			"bullet_speed": 0.0,
			"energy_cost": 100.0,
			"shoot_animation": "shoot",
			"pitch_scale": [1.4, 1.6]
		}
	},
	"Hornet": {
		"scene": preload("res://game/item/Hornet_projectile/Hornet_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Hornet_projectile/Hornet.tscn"),
		"fire_rate": 0.06,
		"bullet_speed": 35.0,
		"energy_cost": 1.5,
		"reload_animation": "r",
		"visible_node": "Hornet",
		"pitch_scale": [1.4, 1.6],
		"alt": {
			"scene": preload("res://game/item/Knife_projectile/Knife_projectile.tscn"),
			"fire_rate": 0.75,
			"bullet_speed": 50.0,
			"energy_cost": 4.0,
			"shoot_animation": "magnet",
			"pitch_scale": [1.2, 1.4]
		}
	},
	"Move": {
		"scene": preload("res://game/item/Move_projectile/Move_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Move_projectile/Move.tscn"),
		"fire_rate": 0.5,
		"bullet_speed": 0.0,
		"energy_cost": 0.0,
		"shoot_animation": "shoot",
		"visible_node": "Move",
		"alt": {
			"scene": preload("res://game/item/Move_projectile/AltMove_projectile.tscn"),
			"fire_rate": 0.5,
			"bullet_speed": 0.0,
			"energy_cost": 0.0,
			"shoot_animation": "shoot"
		}
	},
	"Delete": {
		"scene": preload("res://game/item/Delete_projectile/Delete_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Delete_projectile/Delete.tscn"),
		"fire_rate": 0.25,
		"bullet_speed": 0.0,
		"energy_cost": 0.0,
		"visible_node": "Delete"
	},
	"Summon": {
		"scene": preload("res://game/item/Summon_projectile/Summon_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Summon_projectile/Summon.tscn"),
		"fire_rate": 0.25,
		"bullet_speed": 0.0,
		"energy_cost": 0.0,
		"visible_node": "Summon",
		"alt": {
			"UI": "spawn"
		}
	},
	"Block": {
		"scene": preload("res://game/item/Block_projectile/Block_projectile.tscn"),
		"weapon_scene": preload("res://game/item/Block_projectile/Block.tscn"),
		"fire_rate": 0.25,
		"bullet_speed": 0.0,
		"energy_cost": 0.0,
		"shoot_animation": "shoot",
		"visible_node": "Block",
		"alt": {
			"scene": preload("res://game/item/Delete_projectile/Delete_projectile.tscn"),
			"fire_rate": 0.25,
			"bullet_speed": 0.0,
			"energy_cost": 0.0,
			"shoot_animation": "shoot"
		}
	},
	"Aggro Swapping": {
		"scene": preload("res://game/item/AggroSwapping_projectile/AggroSwapping_projectile.tscn"),
		"weapon_scene": preload("res://game/item/AggroSwapping_projectile/AggroSwapping.tscn"),
		"fire_rate": 0.2,
		"bullet_speed": 50.0,
		"energy_cost": 8.0,
		"shoot_animation": "shoot",
		"visible_node": "AggroSwapping",
		"pitch_scale": [1.4, 1.6],
		"alt": {
			"UI": "aggression"
		}
	},
}

var weapon_scroll_cooldown: float = 0.0
var weapon_scroll_delay: float = 0.15
var current_weapon_slot: int = 1

func _ready():
	if not player:
		player = get_parent()
	equip_weapon(weapon_slots.get(current_weapon_slot, ""))

func _process(delta):
	if weapon_scroll_cooldown > 0:
		weapon_scroll_cooldown -= delta
	handle_weapon_input()

func handle_weapon_input():
	if Global.game_settings["IsDying"] or Global.game_settings["UI"]:
		return
	if player and not player.movement_enabled:
		return
	if Input.is_action_just_pressed("NextWeapon"):
		_switch_to_next_weapon()
	if Input.is_action_just_pressed("PreviousWeapon"):
		_switch_to_previous_weapon()
	if Input.is_action_just_pressed("+1"):
		_switch_to_slot(1)
	if Input.is_action_just_pressed("+2"):
		_switch_to_slot(2)
	if Input.is_action_just_pressed("+3"):
		_switch_to_slot(3)
	if Input.is_action_just_pressed("+4"):
		_switch_to_slot(4)
	if Input.is_action_just_pressed("+5"):
		_switch_to_slot(5)
	if Input.is_action_just_pressed("+6"):
		_switch_to_slot(6)
	if Input.is_action_just_pressed("+7"):
		_switch_to_slot(7)
	if Input.is_action_just_pressed("+8"):
		_switch_to_slot(8)

func _switch_to_next_weapon():
	if weapon_scroll_cooldown <= 0:
		if player:
			player.release_build()
		var start_slot = current_weapon_slot
		var next_slot = start_slot
		for i in range(1, 9):
			var test_slot = start_slot + i
			if test_slot > 8:
				test_slot = test_slot - 8
			if weapon_slots.get(test_slot, "") != "":
				next_slot = test_slot
				_switch_to_slot(next_slot)
				weapon_scroll_cooldown = weapon_scroll_delay
				return
		print("No next weapon found, staying on current")

func _switch_to_previous_weapon():
	if weapon_scroll_cooldown <= 0:
		if player:
			player.release_build()
		var start_slot = current_weapon_slot
		for i in range(1, 9):
			var test_slot = start_slot - i
			if test_slot < 1:
				test_slot = test_slot + 8
			if weapon_slots.get(test_slot, "") != "":
				_switch_to_slot(test_slot)
				weapon_scroll_cooldown = weapon_scroll_delay
				return
		print("No prev weapon found, staying on current")

func _switch_to_slot(slot: int):
	if slot < 1 or slot > 8:
		return
	if player:
		player.release_build()
	var weapon_name = weapon_slots.get(slot, "")
	if weapon_name == "":
		return
	current_weapon_slot = slot
	equip_weapon(weapon_name)

func equip_weapon(weapon_name: String):
	if current_weapon and weapon_name != "" and (weapons.has(weapon_name) or weapon_name == "None"):
		current_weapon.visible = false
	current_weapon_name = weapon_name
	if weapon_name == "" or not weapons.has(weapon_name):
		return
	var weapon_data = weapons[weapon_name]
	if hand_position.has_node(weapon_data["visible_node"]):
		current_weapon = hand_position.get_node(weapon_data["visible_node"])
		current_weapon.visible = true
		if current_weapon.has_node("AnimationPlayer"):
			current_weapon.get_node("AnimationPlayer").play("take")
	else:
		_cleanup_dead_weapons()
		var weapon_scene = weapon_data.get("weapon_scene")
		if weapon_scene:
			for child in hand_position.get_children():
				child.visible = false
			current_weapon = weapon_scene.instantiate()
			current_weapon.name = weapon_data["visible_node"]
			hand_position.add_child(current_weapon)
			current_weapon.visible = true
			if current_weapon.has_node("AnimationPlayer"):
				current_weapon.get_node("AnimationPlayer").play("take")

func _cleanup_dead_weapons():
	var active_weapon_names = []
	for slot in range(1, 9):
		var weapon_name = weapon_slots.get(slot, "")
		if weapon_name != "":
			active_weapon_names.append(weapon_name)
	var children_to_remove = []
	for child in hand_position.get_children():
		var is_weapon = false
		var weapon_name = ""
		for key in weapons.keys():
			var weapon_data = weapons[key]
			if weapon_data.has("visible_node") and weapon_data["visible_node"] == child.name:
				is_weapon = true
				weapon_name = key
				break
		if is_weapon and weapon_name not in active_weapon_names:
			if child == current_weapon:
				current_weapon = null
			children_to_remove.append(child)
	for child in children_to_remove:
		child.queue_free()
		print("Removed dead weapon: ", child.name)


func shoot(is_alt: bool = false):
	if Global.game_settings["UI"]:
		return
	if not current_weapon:
		return
	if current_weapon_name == "" or not weapons.has(current_weapon_name):
		return
	if not player.movement_enabled or Global.game_settings["IsDying"]:
		return
	var weapon_data = weapons[current_weapon_name]
	var alt_data = weapon_data.get("alt")
	if is_alt and alt_data == null:
		return
	var data_to_use = alt_data if is_alt else weapon_data
	var current_pool: float
	if is_alt:
		current_pool = player.alt_energy
	else:
		current_pool = player.energy
	if !player.infE:
		var required_energy = data_to_use.get("energy_cost", 0.0)
		if current_pool < required_energy:
			return
	if data_to_use.has("UI"):
		player.openUI(data_to_use["UI"])
		return
	if not data_to_use.has("scene"):
		return
	var current_time = Time.get_ticks_msec() / 1000.0
	if is_alt:
		if current_time - last_alt_fire_time < data_to_use.get("fire_rate", 0.2):
			return
	else:
		if current_time - last_fire_time < weapon_data["fire_rate"]:
			return
	
	if !player.infE:
		var cost = data_to_use.get("energy_cost", 0)
		if is_alt:
			player.alt_energy = max(0, player.alt_energy - cost)
			player.can_regenerate_alt_energy = false
			player.regen_alt_energy_timer = 0.0
		else:
			player.energy = max(0, player.energy - cost)
			player.can_regenerate_energy = false
			player.regen_energy_timer = 0.0
		player.update_energy_display()
	
	if data_to_use.has("shoot_animation") and data_to_use["shoot_animation"] != "":
		if current_weapon and current_weapon.has_node("AnimationPlayer"):
			current_weapon.get_node("AnimationPlayer").play(data_to_use["shoot_animation"])
	
	is_reloading = false
	var check_pool = player.alt_energy if is_alt else player.energy
	if check_pool < data_to_use["energy_cost"] + 5.0 and !is_reloading:
		is_reloading = true
		if data_to_use.has("reload_animation") and data_to_use["reload_animation"] != "":
			if current_weapon and current_weapon.has_node("AnimationPlayer"):
				current_weapon.get_node("AnimationPlayer").play(data_to_use["reload_animation"])
	
	var weapon_bullet_spawn = current_weapon.get_node("BulletSpawn")
	_show_muzzle_flash(weapon_bullet_spawn)
	var bullet = data_to_use["scene"].instantiate()
	player.get_parent().add_child(bullet)
	bullet.global_transform = weapon_bullet_spawn.global_transform
	
	var shoot_direction = -cam.global_transform.basis.z.normalized()
	
	if bullet.has_method("shoot"):
		bullet.shoot(shoot_direction, data_to_use.get("bullet_speed", 50.0))
	elif bullet.has_method("apply_central_impulse") and bullet is RigidBody3D:
		bullet.apply_central_impulse(shoot_direction * data_to_use.get("bullet_speed", 50.0))
	elif bullet.has_method("set_velocity") and bullet is CharacterBody3D:
		bullet.velocity = shoot_direction * data_to_use.get("bullet_speed", 50.0)
	
	if is_alt:
		last_alt_fire_time = current_time
	else:
		last_fire_time = current_time
	if current_weapon and current_weapon.has_node("shootingSound"):
		var shooting_sound = current_weapon.get_node("shootingSound")
		var pitch_range = data_to_use.get("pitch_scale", [1.4, 1.6]) 
		shooting_sound.pitch_scale = randf_range(pitch_range[0], pitch_range[1])
		shooting_sound.play()
	if current_weapon and current_weapon.has_node("shootingSound2") and randf() < 0.25:
		var shooting_sound2 = current_weapon.get_node("shootingSound2")
		var pitch_range = data_to_use.get("pitch_scale", [1.4, 1.6]) 
		shooting_sound2.pitch_scale = randf_range(pitch_range[0], pitch_range[1])
		shooting_sound2.play()

func _show_muzzle_flash(bullet_spawn: Node3D):
	if bullet_spawn.has_node("flash"):
		var flash = bullet_spawn.get_node("flash")
		flash.visible = true
		flash.rotation.z = randi_range(0, 90)
		flash.scale = Vector3(4, 4, 4)
		await get_tree().create_timer(0.033).timeout
		flash.scale = Vector3(2, 2, 2)
		await get_tree().create_timer(0.066).timeout
		flash.visible = false

func has_weapon_in_slot(slot: int) -> bool:
	return weapon_slots.get(slot, "") != ""

func get_weapon_in_slot(slot: int) -> String:
	return weapon_slots.get(slot, "")

func set_weapon_in_slot(slot: int, weapon_name: String):
	weapon_slots[slot] = weapon_name

func has_alt_weapon() -> bool:
	if current_weapon_name == "" or not weapons.has(current_weapon_name):
		return false
	return weapons[current_weapon_name].has("alt")
