extends Area3D

@export var Level: int = 0

var is_active: bool = true
var player_trapped: bool = false
var respawn_timer: float = 0.0
var respawn_delay: float = 60.0  
var trapped_player: Node3D = null

func _ready():
	if Level == 1:
		$Node3D/Sprite3D.texture = preload("res://chapter2/assets/Trap/trap_traps.png")
		if !Global.game_settings["ModTraps"]:
			queue_free()

func _process(delta):
	if not is_active and respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_trap()

func trigger_interaction():
	if is_active and player_trapped and trapped_player:
		free_player()
	disarm_trap()

func free_player():
	if trapped_player:
		trapped_player.set_movement_enabled(true)
		if trapped_player.has_method("play_blood_animation"):
			trapped_player.play_blood_animation()
		player_trapped = false
		trapped_player = null

func disarm_trap():
	is_active = false
	player_trapped = false
	visible = false
	set_collision_layer_value(4, false)  
	set_collision_mask_value(1, false)
	$CollisionShape3D.disabled = true
	respawn_timer = respawn_delay

func respawn_trap():
	is_active = true
	visible = true
	set_collision_layer_value(4, true) 
	set_collision_mask_value(1, true)
	$CollisionShape3D.disabled = false

func trap_player(player: Node3D):
	if not is_active or player_trapped:
		return
	player_trapped = true
	trapped_player = player
	var targets = get_tree().get_nodes_in_group("enemy_targets1")
	if targets.size() > 0:
		var current_target = targets[0]
		current_target.global_position = global_position
		current_target.timeStart()
	
	if player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)
	
	if player.has_method("show_blood_overlay"):
		player.show_blood_overlay()

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if is_active and body.is_in_group("player") and not player_trapped:
		$AudioStreamPlayer3D.play()
		trap_player(body)
