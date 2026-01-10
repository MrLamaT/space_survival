extends Control

@export var text: String = "":
 set(value):
  text = value
  _update_label()

@export var direction_A_and_D: String = "":
 set(value):
  direction_A_and_D = value
  _update_button()

@export var target_node: NodePath = "": 
 set(value):
  target_node = value

@export var button_id: String = "":  
 set(value):
  button_id = value

func _ready():
 _update_label()
 _update_button()

func newLabel(NEWtext):
 text = NEWtext
 _update_label()
 _update_button()

func _update_label():
 if not is_inside_tree() or not has_node("Sprite2D/Label"):
  return
 var label_text = text
 if direction_A_and_D == "A":
  label_text = "  " + label_text
 $Sprite2D/Label.text = label_text

func _update_button():
 if not is_inside_tree() or not has_node("Sprite2D"):
  return
 if direction_A_and_D == "A":
  $Sprite2D.texture = preload("res://UI/LabelButton/button_previous.png")
 else:
  $Sprite2D.texture = preload("res://UI/LabelButton/button_next.png")
 _update_label()

func _on_button_pressed():
 if not is_inside_tree():
  return
 var target = get_node(target_node)
 if target.has_method("_on_label_button_pressed"):
  target._on_label_button_pressed(button_id)
 else:
  push_error("Target node doesn't have '_on_label_button_pressed' method!")

func _on_button_mouse_entered() -> void:
 modulate = Color("#faff68")

func _on_button_mouse_exited() -> void:
 modulate = Color("ffffffff") 
