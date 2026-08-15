extends Marker3D

@onready var beam_animation: AnimationPlayer = $AnimationPlayer

var bullet_scene = load("res://chapter2/item/beam_projectile/Beam_projectile.tscn")
var is_charging: bool = false
var is_shooting: bool = false
var charge_duration: float = 5.0

func _ready():
	if beam_animation:
		beam_animation.stop()

func start_charge():
	if beam_animation:
		beam_animation.play("beam")
	is_charging = true
	is_shooting = false

func shoot():
	is_shooting = true
	is_charging = false
	if beam_animation:
		beam_animation.play("RESET")
	var bullet_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = global_position

func reset():
	is_charging = false
	is_shooting = false
	if beam_animation:
		beam_animation.stop()

func is_charging_active() -> bool:
	return is_charging

func is_shooting_active() -> bool:
	return is_shooting

func set_charge_duration(duration: float):
	charge_duration = duration
