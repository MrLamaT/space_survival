extends Node

var world = Global.get_world(Global.game_settings.word)

@export var env_scene: PackedScene
@export var gravity: int = 1
@export var portal: Node3D
@export var weapons: Array[String] = ["Vibro Spike", "Taser", "Hornet", "inv", "inv"]
@export var player_checkpoint: bool = false
@export var player_min_y_checkpoint: float = -5.0
@export var plank_color: Color = Color("4b3017")
@export var earth_color: Color = Color("323f18")
@export var stone_color: Color = Color("666666ff")
@export var water_color: Color = Color("0cc6cc")

func _ready() -> void:
	if env_scene:
		var env_instance = env_scene.instantiate()
		add_child(env_instance)
	if gravity == 0:
		$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	if portal:
		portal.teleport_contents()
	for slot_index in range(weapons.size()):
		var weapon_key = weapons[slot_index]
		if weapon_key != "":
			var slot_number = slot_index + 1 
			if weapon_key == "inv":
				$Player.weapon_system.weapon_slots[slot_number] = world["weapon"][slot_index]
			else:
				$Player.weapon_system.weapon_slots[slot_number] = weapon_key
	if weapons.size() > 0:
		$Player.weapon_system.equip_weapon($Player.weapon_system.weapon_slots.get(1, ""))
	if player_checkpoint:
		Global.game_settings["checkpoint"] = $Player.global_position
	Global.game_settings["min_y"] = player_min_y_checkpoint
	var plank = preload("res://assets/material/plank.tres")
	plank.albedo_color = plank_color
	var earth = preload("res://assets/material/earth.tres")
	earth.albedo_color = earth_color
	var stone = preload("res://assets/material/stone.tres")
	stone.albedo_color = stone_color
	var water = preload("res://assets/material/water.tres")
	water.albedo_color = water_color
