extends Node
class_name WeaponSystem

@export var player: CharacterBody3D
@export var hand_position: Node3D
@export var cam: Camera3D

var current_weapon: Node3D = null
var current_weapon_name: String = ""
var fire_rate: float = 0.2
var last_fire_time: float = 0.0
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
		"weapon_scene": preload("res://game/item/Knife_projectile/Knife.tscn"),
		"fire_rate": 0.75,
		"energy_cost": 10.0,
		"shoot_animation": "shoot",
		"visible_node": "Knife",
		"node_fire_method": "fire",
	},
	"Taser": {
		"weapon_scene": preload("res://game/item/Taser_projectile/Taser.tscn"),
		"fire_rate": 0.65,
		"energy_cost": 20.0,
		"shoot_animation": "shoot",
		"visible_node": "Taser",
		"node_fire_method": "fire",
		"alt": {
			"fire_rate": 0.65,
			"energy_cost": 100.0,
			"shoot_animation": "shoot",
			"node_fire_method": "fire"
		}
	},
	"Hornet": {
		"weapon_scene": preload("res://game/item/Hornet_projectile/Hornet.tscn"),
		"fire_rate": 0.06,
		"energy_cost": 1.5,
		"reload_animation": "r",
		"visible_node": "Hornet",
		"node_fire_method": "fire"
	},
	"Impulse": {
		"weapon_scene": preload("res://game/item/Impulse_projectile/Impulse.tscn"),
		"fire_rate": 0.65,
		"energy_cost": 45.0,
		"shoot_animation": "shoot",
		"visible_node": "Impulse",
		"node_fire_method": "fire"
	},
	"Move": {
		"weapon_scene": preload("res://game/item/Move_projectile/Move.tscn"),
		"fire_rate": 0.5,
		"shoot_animation": "shoot",
		"visible_node": "Move",
		"node_fire_method": "fire",
		"alt": {
			"fire_rate": 0.5,
			"shoot_animation": "shoot",
			"node_fire_method": "fire",
		}
	},
	"Delete": {
		"weapon_scene": preload("res://game/item/Delete_projectile/Delete.tscn"),
		"fire_rate": 0.25,
		"visible_node": "Delete",
		"node_fire_method": "fire"
	},
	"Summon": {
		"weapon_scene": preload("res://game/item/Summon_projectile/Summon.tscn"),
		"fire_rate": 0.25,
		"visible_node": "Summon",
		"node_fire_method": "fire",
		"alt": {
			"node_fire_method": "fire"
		}
	},
	"Block": {
		"weapon_scene": preload("res://game/item/Block_projectile/Block.tscn"),
		"fire_rate": 0.25,
		"shoot_animation": "shoot",
		"visible_node": "Block",
		"node_fire_method": "fire",
		"alt": {
			"fire_rate": 0.25,
			"shoot_animation": "shoot",
			"node_fire_method": "fire"
		}
	},
	"Aggro Swapping": {
		"weapon_scene": preload("res://game/item/AggroSwapping_projectile/TechnicalTool.tscn"),
		"fire_rate": 0.65,
		"energy_cost": 20.0,
		"shoot_animation": "shoot",
		"visible_node": "TechnicalTool",
		"node_fire_method": "fireAggro",
		"alt": {
			"node_fire_method": "fireAggro",
		}
	},
	"Freeze Modify": {
		"weapon_scene": preload("res://game/item/AggroSwapping_projectile/TechnicalTool.tscn"),
		"fire_rate": 0.65,
		"energy_cost": 20.0,
		"shoot_animation": "shoot",
		"visible_node": "TechnicalTool",
		"node_fire_method": "fireFreeze",
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
	if Global.IsDying or Global.game_settings["UI"]:
		return
	if player and not player.movement_enabled:
		return
	if Input.is_action_just_pressed("NextWeapon"):
		_switch_to_next_weapon()
	if Input.is_action_just_pressed("PreviousWeapon"):
		_switch_to_previous_weapon()
	for slot in range(1, 9):
		if Input.is_action_just_pressed("+" + str(slot)):
			_switch_to_slot(slot)
			break

func _switch_to_next_weapon():
	if weapon_scroll_cooldown <= 0:
		if player:
			player.object_holder.release(false)
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
			player.object_holder.release(false)
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
		player.object_holder.release(false)
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
	if not player.movement_enabled or Global.IsDying:
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
	
	var check_pool = player.alt_energy if is_alt else player.energy
	if data_to_use.has("energy_cost"):
		if check_pool < data_to_use["energy_cost"] + 5.0:
			if data_to_use.has("reload_animation") and data_to_use["reload_animation"] != "":
				if current_weapon and current_weapon.has_node("AnimationPlayer"):
					current_weapon.get_node("AnimationPlayer").play(data_to_use["reload_animation"])
		
	if data_to_use.has("node_fire_method") and current_weapon:
		var method_name: String = data_to_use.get("node_fire_method", "fire")
		if current_weapon.has_method(method_name):
			current_weapon.call(method_name, cam, player.get_parent(), is_alt)
		else:
			push_warning("Weapon node '%s' has no method '%s'" % [current_weapon.name, method_name])

	if is_alt:
		last_alt_fire_time = current_time
	else:
		last_fire_time = current_time

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
