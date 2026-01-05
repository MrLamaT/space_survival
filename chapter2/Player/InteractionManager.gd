class_name InteractionManager

var _player: CharacterBody3D
var _camera: Camera3D
var _crosshair: TextureRect
var _progress_bar: ProgressBar
var _hand_sprite: Sprite3D

var current_interactable: Node3D = null
var is_interacting: bool = false
var interaction_progress: float = 0.0
var interaction_time_required: float = 2.0
var interaction_target: Node3D = null

func _init(player: CharacterBody3D, camera: Camera3D, crosshair: TextureRect, progress_bar: ProgressBar, hand_sprite: Sprite3D):
	_player = player
	_camera = camera
	_crosshair = crosshair
	_progress_bar = progress_bar
	_hand_sprite = hand_sprite

func process_interaction_input():
	if Input.is_action_just_pressed("UI_click") and current_interactable and current_interactable.is_in_group("click_interact"):
		start_interaction()
	if Input.is_action_just_released("UI_click"):
		stop_interaction()
	if Input.is_action_just_pressed("+e") and current_interactable and not current_interactable.is_in_group("click_interact"):
		start_interaction()
	if Input.is_action_just_released("+e"):
		stop_interaction()

func update_interaction(delta: float):
	if is_interacting and interaction_target:
		interaction_progress += delta
		update_interaction_progress_bar()
		if interaction_progress >= interaction_time_required:
			complete_interaction()
	else:
		if interaction_progress > 0:
			interaction_progress = 0
			hide_interaction_progress_bar()

func check_interactable():
	var space_state = _player.get_world_3d().direct_space_state
	var from = _camera.global_position
	var to = from + _camera.global_transform.basis.z * -5 
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [_player] 
	query.collision_mask = 2 | 4 | 8 | 16
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	var found_interactable = null
	
	if result: 
		var collider = result.collider
		if collider and (collider is Area3D or collider is RigidBody3D or collider is CharacterBody3D):
			if collider.is_in_group("interactive_objects"):
				found_interactable = collider
	
	if found_interactable != current_interactable:
		if current_interactable:
			current_interactable._on_mouse_exited()
			stop_interaction()
		
		current_interactable = found_interactable
		if current_interactable:
			current_interactable._on_mouse_entered()
	
	_update_crosshair()

func start_interaction():
	if not current_interactable:
		return
	
	if current_interactable.is_in_group("item"):
		pick_up_item(current_interactable)
	elif current_interactable.is_in_group("progressive_interactive"):
		is_interacting = true
		interaction_target = current_interactable
		interaction_progress = 0.0
		show_interaction_progress_bar()
	else:
		current_interactable.trigger_interaction()

func stop_interaction():
	is_interacting = false
	interaction_target = null
	hide_interaction_progress_bar()

func complete_interaction():
	if interaction_target:
		interaction_target.trigger_interaction()
		is_interacting = false
		interaction_target = null
		hide_interaction_progress_bar()

func pick_up_item(item_node):
	if not is_instance_valid(item_node):
		return
	if Global.game_settings["Item"] != "":
		_player.drop_item()
	
	var texture_path = item_node.item_texture.resource_path
	var item_name = texture_path.get_file().get_basename()
	Global.game_settings["Item"] = item_name
	_hand_sprite.texture = item_node.item_texture
	item_node.queue_free()
	current_interactable = null
	_handle_item_pickup(item_name)

func _handle_item_pickup(item_name: String):
	match item_name:
		"shotgun":
			_player.get_node("head/Camera3D/shoot").visible = true
		"NailGun":
			_player.get_node("head/Camera3D/shoot").visible = true
			_player.get_node("head/Camera3D/shoot2").visible = true
			_player.get_node("head/Camera3D/shoot2").text = "%01d/8" % [Global.game_settings["nails_cartridge"]]
		"taser":
			_player.get_node("head/Camera3D/shoot").visible = true
			_player.get_node("head/Camera3D/shoot2").visible = true
			_player.get_node("head/Camera3D/shoot2").text = "%01d/2" % [Global.game_settings["shock_cartridge"]]
		_:
			print("Подобран предмет: ", item_name)

func _update_crosshair():
	if current_interactable and not current_interactable.is_in_group("click_interact"):
		_crosshair.texture = preload("res://assets/crosshair2.png")
		_player.get_node("head/Camera3D/Use").visible = true
	else:
		_crosshair.texture = preload("res://assets/crosshair1.png")
		_player.get_node("head/Camera3D/Use").visible = false

func update_interaction_progress_bar():
	var progress_percent = interaction_progress / interaction_time_required
	_progress_bar.value = progress_percent * 100

func show_interaction_progress_bar():
	_progress_bar.visible = true

func hide_interaction_progress_bar():
	_progress_bar.visible = false

func clear_current_interactable():
	if current_interactable:
		current_interactable._on_mouse_exited()
		current_interactable = null
	_update_crosshair()
