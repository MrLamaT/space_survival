extends Node2D

var score = 0
var password_code = ""
var current_input = ""
var can_input = false 
@onready var password_display = $password/password
@onready var buttons = [
	$password/Button1, $password/Button2, $password/Button3, $password/Button4,
	$password/Button5, $password/Button6, $password/Button7, $password/Button8, $password/Button9
]
@export var node_hack: Node3D

func _ready() -> void:
	randomize()
	connect_buttons()

func connect_buttons() -> void:
	for i in range(buttons.size()):
		var button = buttons[i]
		var digit = i + 1
		button.pressed.connect(_on_button_pressed.bind(digit))

func _on_button_pressed(digit: int) -> void:
	if not can_input:
		return
	if current_input.length() < 4:
		current_input += str(digit)
		update_password_display()
		if current_input.length() == 4:
			check_password()

func update_password_display() -> void:
	var display_text = ""
	for i in range(4):
		if i < current_input.length():
			display_text += str(current_input[i])
		else:
			display_text += "_"
	password_display.text = display_text
	
func check_password() -> void:
	if current_input == password_code:
		print("правильно")
		node_hack.on(true)
		node_hack.get_node("PC1")["nameUI"] = ""
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.game_settings["UI"] = false
		queue_free()
	else:
		print("не правильно")
		password_display.modulate = Color(1.0, 0.0, 0.0, 1.0)  
		await get_tree().create_timer(1.0).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.game_settings["UI"] = false
		queue_free()  

func generate_and_show_password() -> void:
	await get_tree().create_timer(0.2).timeout
	password_code = ""
	for i in range(4):
		password_code += str(randi_range(1, 9))
	print("Сгенерирован код: ", password_code) 
	for digit_char in password_code:
		var digit = int(digit_char)
		var button = buttons[digit - 1]  
		button.modulate = Color(1.0, 0.0, 0.0, 1.0)
		await get_tree().create_timer(0.3).timeout
		button.modulate = Color(0.0, 1.0, 0.0, 1.0)
		await get_tree().create_timer(0.2).timeout
	can_input = true

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	generate_and_show_password()
