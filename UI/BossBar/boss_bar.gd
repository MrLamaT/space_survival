extends CanvasLayer

@onready var health_over = $Control/HealthOver
@onready var health_under = $Control/HealthUnder
@onready var control = $Control
@onready var label = $Control/Label
var shake_strength: float = 5.0
var shake_duration: float = 0.3

func setup_boss(max_hp: int, boss_name: String):
	label.text = boss_name
	health_over.max_value = max_hp
	health_over.value = max_hp
	health_under.max_value = max_hp
	health_under.value = max_hp
	visible = true
	
func _on_health_changed(hew_hp: int):
	health_over.value = hew_hp
	shake_control()
	var tween = create_tween()
	tween.tween_property(health_under, "value", hew_hp, 0.6)\
		.set_delay(0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	if health_over.value <= 0:
		shake_control(true)
		var death_tween = create_tween()
		death_tween.tween_property(control, "modulate", Color(1, 1, 1, 0), 1.0)\
			.set_trans(Tween.TRANS_QUINT)\
			.set_ease(Tween.EASE_IN)
		await get_tree().create_timer(2).timeout
		visible = false
		control.modulate = Color(1, 1, 1, 1)

func shake_control(intense: bool = false):
	var original_pos = control.position
	var shake_power = shake_strength * (2.0 if intense else 1.0)
	var duration = shake_duration * (1.5 if intense else 1.0)
	var shake_tween = create_tween()
	for i in range(6):
		var random_offset = Vector2(
			randf_range(-shake_power, shake_power),
			randf_range(-shake_power, shake_power)
		)
		shake_tween.tween_property(control, "position", original_pos + random_offset, duration / 6.0)
	shake_tween.tween_property(control, "position", original_pos, duration / 6.0)

func flash_effect(intensity: float):
	var flash_color = Color(1, 1, 1, intensity * 0.5)
	control.modulate = flash_color
