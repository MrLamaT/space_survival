extends StaticBody3D

@export var skin = 0
@export var level = 0
@export var stade = 0
var world = Global.get_world(Global.game_settings.word)
var is_animating = false
var cubes = []

func _ready():
	if skin == 0:
		$Sprite3D.queue_free()
		$Sprite3D2.queue_free()
		$AnimationPlayer2.queue_free()
		$Cube/MeshInstance3D2.queue_free()
		$Cube2/MeshInstance3D2.queue_free()
		$Cube3/MeshInstance3D2.queue_free()
		$Cube4/MeshInstance3D2.queue_free()
	cubes = [
		$Cube/MeshInstance3D,
		$Cube2/MeshInstance3D, 
		$Cube3/MeshInstance3D,
		$Cube4/MeshInstance3D
	]

func casing(cont):
	if cont == 1:
		$AnimationPlayer2.play("downC")
	else:
		$AnimationPlayer2.play("downC", -1, -1.0, true)

func teleport(map):
	if is_animating:
		return
	is_animating  = true
	if skin != 0:
		casing(1)
		await get_tree().create_timer(2).timeout
	$AudioStreamPlayer3D.play()
	var tween1 = create_tween()
	tween1.tween_method(
		update_cube_colors.bind(Color.WHITE, Color("9f009f")),
		0.0, 1.0, 1.0
	)
	$AnimationPlayer.play("teleport")
	await tween1.finished
	if skin != 0:
		var player = get_tree().get_first_node_in_group("player")
		player.get_node("head/Camera3D/Teleport").teleport()
		await get_tree().create_timer(2).timeout
		$AudioStreamPlayer3D2.play()
		await get_tree().create_timer(1).timeout
		print("бум")
		$TeleportCube.save_contents()
		SceneManager.load_scene_with_loading(map)

func update_cube_colors(value: float, from_color: Color, to_color: Color):
	var color = from_color.lerp(to_color, value)
	set_cube_colors(color)

func set_cube_colors(color: Color):
	for cube in cubes:
		var mat = cube.get_surface_override_material(0)
		if not mat or not mat is StandardMaterial3D:
			mat = StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var new_mat = mat.duplicate()
		new_mat.albedo_color = color
		cube.set_surface_override_material(0, new_mat)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and skin == 1:
		$Label/AnimationPlayer.play("vis")
		if world["level"] <= level:
			world["level"] = level + 1
		if world["stage"] < stade:
			world["stage"] = stade
		body.save()
