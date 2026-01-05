extends Node

var loading_screen: PackedScene
var current_loading_screen: Control = null
var current_scene: Node = null

func _ready():
	loading_screen = preload("res://chapter2/load/LoadingScreen.tscn")
	current_scene = get_tree().current_scene

func load_scene_with_loading(scene_path: String):
	show_loading_screen()
	
	ResourceLoader.load_threaded_request(scene_path)
	
	await check_loading_progress(scene_path)

func show_loading_screen():
	current_loading_screen = loading_screen.instantiate()
	get_tree().root.add_child(current_loading_screen)
	current_loading_screen.z_index = 1000

func hide_loading_screen():
	if current_loading_screen:
		current_loading_screen.queue_free()
		current_loading_screen = null

func check_loading_progress(scene_path: String):
	var progress = []
	
	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(scene_path)
			switch_to_scene(scene)
			break
		elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if current_loading_screen:
				current_loading_screen.update_progress(progress[0] * 100)
			await get_tree().create_timer(0.05).timeout
		else:
			print("Ошибка загрузки сцены: ", status)
			hide_loading_screen()
			break

func switch_to_scene(scene: PackedScene):
	var new_scene = scene.instantiate()
	
	var root = get_tree().root
	
	if current_scene:
		root.remove_child(current_scene)
		current_scene.queue_free()
	
	root.add_child(new_scene)
	current_scene = new_scene

	get_tree().current_scene = new_scene
	
	hide_loading_screen()
