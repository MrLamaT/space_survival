extends CharacterBody2D

@export var speed: int = 300
var current_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false
@onready var sprite: Sprite2D = $Sprite2D
@onready var panel: Panel = get_parent()
func _physics_process(_delta):
	if not is_moving:
		handle_input()
		return
	var input_dir = Input.get_vector("+a", "+d", "+w", "+s")
	if input_dir != Vector2.ZERO:
		current_direction = input_dir
		update_sprite_rotation(current_direction)
	velocity = current_direction * speed
	move_and_slide()
	check_boundaries()
	if not is_moving and input_dir != Vector2.ZERO:
		is_moving = true

func handle_input():
	var input_dir = Input.get_vector("+a", "+d", "+w", "+s")
	if input_dir != Vector2.ZERO and not is_moving:
		current_direction = input_dir
		update_sprite_rotation(current_direction)
		is_moving = true

func update_sprite_rotation(direction: Vector2):
	if direction == Vector2.ZERO:
		return
	var angle = direction.angle() + deg_to_rad(270)
	sprite.rotation = angle
	
func check_boundaries():
	var panel_rect = panel.get_global_rect()
	var player_pos = global_position
	if player_pos.x < panel_rect.position.x:
		global_position.x = panel_rect.position.x + panel_rect.size.x
	elif player_pos.x > panel_rect.position.x + panel_rect.size.x:
		global_position.x = panel_rect.position.x
	if player_pos.y < panel_rect.position.y:
		global_position.y = panel_rect.position.y + panel_rect.size.y
	elif player_pos.y > panel_rect.position.y + panel_rect.size.y:
		global_position.y = panel_rect.position.y
