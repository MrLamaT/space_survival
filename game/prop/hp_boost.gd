extends RigidBody3D

var _secondary_color: Color

@onready var icon1
@onready var icon2
@onready var Particles = $GPUParticles3D

func _ready() -> void:
	if has_node("Sprite3D2"):
		_secondary_color = Color("ffffffff").darkened(0.1)
		icon1 = $Sprite3D2
		icon2 = $Sprite3D3
		icon1.modulate = _secondary_color
		icon2.modulate = _secondary_color

func trigger_interaction():
	if Particles.emitting:
		Particles.emitting = false
		$AudioStreamPlayer3D.play()
		$Sprite3D.modulate = Color("808080")
		remove_from_group("interactive_objects")
		var player = get_tree().get_first_node_in_group("player")
		player.HP(-100)
		Global.game_settings["checkpoint"] = player.global_position

func _on_mouse_entered() -> void:
	if icon1:
		icon1.modulate = Color("ffffffff")
		icon1.shaded = false
		icon2.modulate = Color("ffffffff")
		icon2.shaded = false

func _on_mouse_exited() -> void:
	if icon1:
		icon1.modulate = _secondary_color
		icon1.shaded = true
		icon2.modulate = _secondary_color
		icon2.shaded = true
