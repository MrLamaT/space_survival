extends Node3D

var mouseLight = false

func _input(event):
	if event.is_action_pressed("UI_click"):
		if mouseLight:
			$Light2.switching()

func _on_on_animation_finished(_anim_name: StringName) -> void:
	$Light2.On()
	await get_tree().create_timer(1.5).timeout
	$menu.get_node("AnimationPlayer").play("intro")

func _on_area_light_mouse_entered() -> void:
	mouseLight = true
	print(true)

func _on_area_light_mouse_exited() -> void:
	mouseLight = false
	print(false)

func skip_all_animations():
	if $On.has_animation("OnSystem"):
		$On.advance($On.get_animation("OnSystem").length)
	_on_on_animation_finished("OnSystem")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().create_timer(6).timeout
	$Camera3D/load.visible = true
	$Camera3D/load.intro()
