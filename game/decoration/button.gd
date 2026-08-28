extends Area3D

@export var interaction_name: String = "" 
@export var handler_node: NodePath 
@export var handler_method: String = "handle_interaction"
var check = false 

func _ready():
	if interaction_name == "":
		push_warning("InteractableObject at %s has no interaction name set!" % global_position)
	if handler_node.is_empty():
		push_warning("InteractableObject at %s has no handler node set!" % global_position)

func trigger_interaction():
	if check == false:
		check = true
		$MeshInstance3D.position = Vector3(0.01, 0.0, 0.0)
		var target_node = get_node(handler_node)
		if target_node and target_node.has_method(handler_method):
			target_node.call(handler_method, interaction_name)
		else:
			push_error("Handler node or method not found for interaction: %s" % interaction_name)
		await get_tree().create_timer(1.0).timeout
		$MeshInstance3D.position = Vector3(-0.03, 0.0, 0.0)
		check = false

func _on_mouse_entered() -> void:
	$MeshInstance3D/OmniLight3D.visible = true

func _on_mouse_exited() -> void:
	$MeshInstance3D/OmniLight3D.visible = false
