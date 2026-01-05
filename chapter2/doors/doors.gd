extends Area3D

@export var interaction_name: String = "" 
@export var handler_node: NodePath 
@export var handler_method: String = "handle_interaction" 
enum InteractionMode {TELEPORT, CHANGE_SCENE}
@export var interaction_mode: InteractionMode = InteractionMode.TELEPORT
@export var teleport_target_position: Vector3 = Vector3.ZERO
@export var target_scene_path: String = ""
@export var TextNumber: String = ""
var closed = true

func _ready() -> void:
	if not TextNumber:
		$MeshInstance3D/Label3D.visible = false
	else:
		$MeshInstance3D/Label3D.text = TextNumber

func trigger_interaction():
	if not handler_node.is_empty():
		var target_node = get_node(handler_node)
		if target_node and target_node.has_method(handler_method):
			target_node.call(handler_method, interaction_name)
		else:
			push_error("Handler node or method not found for interaction: %s" % interaction_name)
	match interaction_mode:
		InteractionMode.TELEPORT:
			teleport_player()
			
		InteractionMode.CHANGE_SCENE:
			change_scene()

func teleport_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if closed:
			closed = false
			player.AnimationPlayPlayer("BlackOut")
			await get_tree().create_timer(0.25).timeout
			player.global_position = teleport_target_position
			closed = true
	else:
		push_error("Player not found for teleportation")

func change_scene():
	if target_scene_path != "" and ResourceLoader.exists(target_scene_path):
		await get_tree().process_frame
		SceneManager.load_scene_with_loading(target_scene_path)
	else:
		push_error("Invalid scene path: %s" % target_scene_path)

func _on_mouse_entered() -> void:
	$DoorE.visible = true


func _on_mouse_exited() -> void:
	$DoorE.visible = false
