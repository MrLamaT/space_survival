extends Label3D

@export var CustText: String = ""
@export var setting = false

func _ready() -> void:
	if setting:
		if Global.game_settings["gui_settings"][CustText]:
			text = CustText + " [ON]"
		else:
			text = CustText + " [OFF]"
	else:
		text = CustText

func _on_area_3d_mouse_entered() -> void:
	modulate = Color("#faff68")
	var parent_scene = get_parent().get_parent()
	if parent_scene and parent_scene.has_method("on_label_hovered"):
		parent_scene.on_label_hovered(CustText)

func _on_area_3d_mouse_exited() -> void:
	modulate = Color("ffffffff")
	var parent_scene = get_parent().get_parent()
	if parent_scene and parent_scene.has_method("on_label_hovered"):
		parent_scene.on_label_hovered("")
