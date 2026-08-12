extends Label

@export var title = ""
@export var cat_node: GridContainer 

func _ready() -> void:
	text = title
	if cat_node.visible:
		$Sprite2D.modulate = Color(0.0, 1.0, 0.0, 1.0)
	else:
		$Sprite2D.modulate = Color(1.0, 0.0, 0.0, 1.0)

func _on_button_pressed() -> void:
	cat_node.visible = !cat_node.visible
	_ready()
