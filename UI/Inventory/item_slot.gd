extends TextureRect

@export var item_name: String = "schematic"
@export var icon: Texture2D

func _ready():
	texture = icon
	var world_data = Global.get_world(Global.game_settings.word)
	if world_data["inventory"].has(item_name):
		$CountLabel.text = str(int(world_data["inventory"][item_name]))
	else:
		visible = false 
	tooltip_text = item_name

func _on_mouse_entered():
	if item_name != "":
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_mouse_exited():
	if item_name != "":
		modulate = Color(1.0, 1.0, 1.0, 1.0)
