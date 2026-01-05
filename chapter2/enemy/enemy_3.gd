extends CharacterBody3D

@export var item_preset: int = 0
@onready var vision_area: Area3D = $VisionArea
@onready var sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

var player: Node3D = null
var has_attacked: bool = false

# Настройки исчезновения
var fade_out_speed: float = 2.0
var is_fading: bool = false

func _ready():
	if item_preset != 0 and item_preset != Global.game_settings["preset"]:
		queue_free()
		return
	if !Global.game_settings["debugging"]:
		$test.queue_free()
	else:
		$test.visible = true
	# Инициализация
	sprite_3d.play("idle")

func _physics_process(delta):
	if is_fading:
		sprite_3d.modulate.a = max(0, sprite_3d.modulate.a - fade_out_speed * delta)
		if sprite_3d.modulate.a <= 0:
			queue_free()

func attack_player():
	if has_attacked:
		return
	has_attacked = true
	sprite_3d.play("attack")
	if player and player.has_method("look_at_point"):
		player.look_at_point(global_position)
		player.screem()
	await get_tree().create_timer(0.5).timeout
	is_fading = true

func _on_vision_area_body_entered(body):
	if body.is_in_group("player") and not has_attacked:
		player = body
		attack_player()
