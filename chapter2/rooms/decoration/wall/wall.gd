extends Node3D

@export var light = true
@export var emergency_light = false
@export var glass = false
@export var mother_ship = false

func _ready() -> void:
	if !light and has_node("Light"):
		$Light.queue_free()
	else:
		if emergency_light:
			if mother_ship:
				var world = Global.get_world(Global.game_settings.word)
				if world["build"]["light"] <= 0:
					$Light.update_torch_color(Color("ff0000ff"))
			else:
				$Light.update_torch_color(Color("ff0000ff"))
	if glass:
		var glass_mat: StandardMaterial3D
		glass_mat = StandardMaterial3D.new()
		glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glass_mat.alpha_scissor_threshold = 0.1
		glass_mat.metallic = 0.3
		glass_mat.albedo_color = Color("009dfe19")
		glass_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		$StaticBody3D/wall/box.material = glass_mat
		$StaticBody3D/wall/box.size = Vector3(4.9, 2.5, 1.0)

func lightOn():
	if has_node("Light"):
		$Light.update_torch_color(Color("f3f1c5"))
