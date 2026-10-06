extends Node
class_name PlayerHealth

var player: CharacterBody3D
var health: float = 100.0
var damage_cooldown: float = 0.0
var damage_cooldown_duration: float = 1.0
var poison_damage: float = 0.0
var poison_duration: float = 0.0
var poison_tick_timer: float = 0.0
var poison_tick_interval: float = 1.0
var is_poisoned: bool = false

func setup(player_owner: CharacterBody3D) -> void:
	player = player_owner

func update(delta: float) -> void:
	if damage_cooldown > 0.0:
		damage_cooldown -= delta
	_process_poison(delta)
	_check_killzone()

func take_damage(amount: float) -> void:
	if not player or Global.game_settings["IsDying"] or damage_cooldown > 0.0:
		return
	if not player.GodMod:
		health -= amount
		damage_cooldown = damage_cooldown_duration
	player.blood_overlay.modulate = Color("830000BD") if amount > 0.0 else Color("E8D6C2FF")
	player.get_node("head/Camera3D/damage").play("damage")
	if health <= 0.0:
		player_death()
	health = minf(health, 100.0)

func apply_poison(amount: float) -> void:
	if not player or Global.game_settings["IsDying"] or player.GodMod:
		return
	poison_damage = amount
	poison_duration = 8.0
	poison_tick_timer = 0.0
	is_poisoned = true

func _process_poison(delta: float) -> void:
	if not is_poisoned or not player or Global.game_settings["IsDying"]:
		return
	if poison_duration > 0.0:
		poison_duration -= delta
		poison_tick_timer += delta
		if poison_tick_timer >= poison_tick_interval:
			poison_tick_timer = 0.0
			if not player.GodMod:
				health -= poison_damage
			player.blood_overlay.modulate = Color("4CAF50")
			player.get_node("head/Camera3D/damage").play("damage")
			if health <= 0.0:
				player_death()
				is_poisoned = false
	else:
		is_poisoned = false
		poison_damage = 0.0

func player_death() -> void:
	if Global.game_settings["IsDying"]:
		return
	Global.game_settings["IsDying"] = true
	player.object_holder.release(false)
	for enemy in player.get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("ResetHealth"):
			enemy.ResetHealth()
	player.get_node("screem").play()
	player.throw_camera_out()
	player.movement_enabled = false
	player.velocity = Vector3.ZERO
	player.is_running = false
	player.get_node("head/Camera3D/UI").visible = false
	player.get_node("hand_position").visible = false
	if player.world["mode"] != 2:
		await player.get_tree().create_timer(2.5).timeout
		player.get_node("screem").stop()
		health = 100.0
		respawn_player()
	else:
		Global.delete_world_save(Global.game_settings.word)
		SceneManager.load_scene_with_loading("res://game/rooms/main.tscn")

func respawn_player() -> void:
	Global.save(Global.game_settings["word"])
	player.global_position = Global.game_settings["checkpoint"]
	player.velocity = Vector3.ZERO
	Global.game_settings["IsDying"] = false
	player.movement_enabled = true
	player.get_node("head/Camera3D/UI").visible = true
	player.get_node("hand_position").visible = true
	player.cam.current = true
	is_poisoned = false
	poison_damage = 0.0
	poison_duration = 0.0
	poison_tick_timer = 0.0
	if is_instance_valid(player.thrown_camera):
		player.thrown_camera.queue_free()
		player.thrown_camera = null

func _check_killzone() -> void:
	if player and player.global_position.y < Global.game_settings["min_y"]:
		var new_health := health - health * 0.5
		if new_health < 1.0:
			new_health = 1.0
		take_damage(health - new_health)
		player.global_position = Global.game_settings["checkpoint"]
		player.velocity.y = 0.0
