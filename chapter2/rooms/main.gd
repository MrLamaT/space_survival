extends Node3D

var mouseLight = false

func _input(event):
	if event.is_action_pressed("UI_click"):
		if mouseLight:
			$Light2.switching()

func _ready() -> void:
	$AnimationPlayer.play("light")
	$On.play("OnSystem")
	$fans.play()

func _on_on_animation_finished(_anim_name: StringName) -> void:
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
