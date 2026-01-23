extends Node3D

var mouseLight = false
var skip = false

func _input(event):
	
	if event.is_action_pressed("UI_click"):
		if mouseLight:
			$Light2.switching()
	if event.is_action_pressed("ui_cancel"):
		if !skip:
			skip = true
			skip_all_animations()

func _ready() -> void:
	$AnimationPlayer.play("light")
	$On.play("OnSystem")
	$fans.play()

func _on_on_animation_finished(_anim_name: StringName) -> void:
	skip = true
	$Light2.On()
	await get_tree().create_timer(1.5).timeout
	$menu.On()

func _on_fans_finished() -> void:
	$fans.play()

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
