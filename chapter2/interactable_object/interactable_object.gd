extends Area3D

@export var interaction_name: String = "" 
@export var handler_node: NodePath 
@export var handler_method: String = "handle_interaction" 
@export var use_billboard_sprite: bool = false 
@export var sprite_texture: Texture2D
@export var sprite_label: String = ""

@onready var billboard_sprite: Sprite3D = $Node3D/Sprite3D
@onready var billboard_label: Label3D = $Node3D/Label3D

func _ready():
	if !Global.game_settings["debugging"]:
		$test.queue_free()
	else:
		$test.visible = true
	$MeshInstance3D.visible = false
	if billboard_sprite:
		$Node3D.visible = true
		billboard_sprite.texture = sprite_texture
		$AnimationPlayer.play("movement")
		billboard_label.text = sprite_label
	if interaction_name == "":
		push_warning("InteractableObject at %s has no interaction name set!" % global_position)
	if handler_node.is_empty():
		push_warning("InteractableObject at %s has no handler node set!" % global_position)

func trigger_interaction():
	var target_node = get_node(handler_node)
	if target_node and target_node.has_method(handler_method):
		target_node.call(handler_method, interaction_name)
	else:
		push_error("Handler node or method not found for interaction: %s" % interaction_name)

func _on_mouse_entered() -> void:
	if billboard_sprite:
		$AnimationPlayer.pause()
		billboard_sprite.scale = Vector3(2.5, 2.5, 2.5)
		billboard_label.visible = true

func _on_mouse_exited() -> void:
	if billboard_sprite:
		$AnimationPlayer.play()
		billboard_sprite.scale = Vector3(2, 2, 2)
		billboard_label.visible = false
