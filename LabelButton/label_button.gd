extends Control

@export var text: String = "":
 set(value):
  text = value
  _update_label()

@export var direction_A_and_D: String = "":
 set(value):
  direction_A_and_D = value
  _update_button()

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
  $Sprite2D.texture = preload("res://LabelButton/button_previous.png")
 else:
  $Sprite2D.texture = preload("res://LabelButton/button_next.png")
  
 _update_label()
