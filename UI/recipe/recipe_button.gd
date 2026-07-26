extends Control

@export var sprite_texture: Texture
@export var sprite_label: String = ""
@export var required_description: String = ""
@export var required_description_ru: String = ""
@onready var billboard_sprite: Sprite2D = $Sprite2D
@export var Credits: int = 0
@export var Sercilist: int = 0
@export var Dark_Sercilist: int = 0

var player: CharacterBody3D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if billboard_sprite:
		$Sprite2D.texture = sprite_texture
		visible = true

func check_and_consume_resources() -> bool:
	var world = Global.get_world(Global.game_settings.word)
	var inventory = world["inventory"]
	var has_enough = true
	if Credits > 0:
		if inventory.has("Credits") and inventory["Credits"] >= Credits:
			pass 
		else:
			has_enough = false
	if Sercilist > 0:
		if inventory.has("Sercilist") and inventory["Sercilist"] >= Sercilist:
			pass 
		else:
			has_enough = false
	if Dark_Sercilist > 0:
		if inventory.has("Dark Sercilist") and inventory["Dark Sercilist"] >= Dark_Sercilist:
			pass 
		else:
			has_enough = false
	if not has_enough:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("Недостаточно ресурсов!")
		else:
			player.warning("Not enough resources!")
		return false
	if Credits > 0:
		inventory["Credits"] -= Credits
	if Sercilist > 0:
		inventory["Sercilist"] -= Sercilist
	if Dark_Sercilist > 0:
		inventory["Dark Sercilist"] -= Dark_Sercilist
	return true

func _on_button_pressed() -> void:
	if $Sprite2D2.visible == true:
		return
	if !check_and_consume_resources():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.game_settings["UI"] = false
		get_parent().get_parent().get_parent().queue_free()
		return
	get_parent().get_parent().get_parent().create(sprite_label)

func _on_button_mouse_entered() -> void:
	if $Sprite2D2.visible == true:
		return
	var recipeMenu = get_parent().get_parent().get_parent().get_node("recipe")
	var mouse_pos = get_viewport().get_mouse_position()
	var menu_size = recipeMenu.get_node("Panel").size * 0.5
	var viewport_size = get_viewport().get_visible_rect().size
	var final_pos = mouse_pos
	var offset = Vector2(10, 10)
	if mouse_pos.x + menu_size.x + offset.x > viewport_size.x:
		final_pos.x = mouse_pos.x - menu_size.x - offset.x
	else:
		final_pos.x = mouse_pos.x + offset.x
	if mouse_pos.y + menu_size.y + offset.y > viewport_size.y:
		final_pos.y = mouse_pos.y - menu_size.y - offset.y
	else:
		final_pos.y = mouse_pos.y + offset.y
	final_pos.x = max(0, min(final_pos.x, viewport_size.x - menu_size.x))
	final_pos.y = max(0, min(final_pos.y, viewport_size.y - menu_size.y))
	recipeMenu.position = final_pos
	recipeMenu.visible = true
	recipeMenu.recipe({"Credits": Credits, "Sercilist": Sercilist, "Dark Sercilist": Dark_Sercilist}, sprite_label, required_description, required_description_ru)

func _on_button_mouse_exited() -> void:
	var recipeMenu = get_parent().get_parent().get_parent().get_node("recipe")
	recipeMenu.visible = false
