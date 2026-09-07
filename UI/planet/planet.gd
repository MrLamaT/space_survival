extends Node2D

var world = Global.get_world(Global.game_settings.word)
var page = 1
var current_page_node = null

var page_data = {
	0: {
		"id_text": "Stage 0: Simulation",
		"sprite_texture": null,
		"node_name": "HBoxContainer0"
	},
	1: {
		"id_text": "Stage 1: RoP-856",
		"sprite_texture": preload("res://assets/icon/planet/planet1.png"),
		"node_name": "HBoxContainer1"
	}
}

func _ready() -> void:
	page = int(world["stage"])
	hide_all_pages()
	pageUpdate()

func hide_all_pages() -> void:
	for child in $Panel.get_children():
		if child.name.begins_with("HBoxContainer"):
			child.visible = false

func _on_label_button_pressed(id: String) -> void:
	var max_page = get_max_page()
	var min_page = get_min_page()
	match id:
		"previous":
			if page - 1 >= min_page:
				page -= 1
		"next":
			if page + 1 <= max_page:
				page += 1
	pageUpdate()

func get_max_page() -> int:
	var max_page = -1
	for key in page_data.keys():
		if key > max_page:
			max_page = key
	return max_page

func get_min_page() -> int:
	var min_page = 999
	for key in page_data.keys():
		if key < min_page:
			min_page = key
	return min_page

func pageUpdate():
	hide_all_pages()
	if page_data.has(page):
		var target_node_name = page_data[page]["node_name"]
		var target_container = $Panel.get_node_or_null(target_node_name)
		if target_container:
			target_container.visible = true
			current_page_node = target_container
	else:
		var last_page = get_max_page()
		if last_page != -1:
			page = last_page
			var target_node_name = page_data[page]["node_name"]
			var target_container = $Panel.get_node_or_null(target_node_name)
			if target_container:
				target_container.visible = true
				current_page_node = target_container
	update_page_elements()

func update_page_elements():
	if page_data.has(page):
		$Panel/Id.text = page_data[page]["id_text"]
		$Sprite2D.texture = page_data[page]["sprite_texture"]
	else:
		$Panel/Id.text = "Page " + str(page)
		$Sprite2D.texture = null

func teleport(res):
	SceneManager.load_scene_with_loading(res)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()
