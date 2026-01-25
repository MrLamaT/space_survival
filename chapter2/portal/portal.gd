extends StaticBody3D

var is_animating = false
var cubes = []

func _ready():
	cubes = [
		$Cube/MeshInstance3D,
		$Cube2/MeshInstance3D, 
		$Cube3/MeshInstance3D,
		$Cube4/MeshInstance3D
	]

func teleport():
	if is_animating:
		return
	is_animating  = true
	$AnimationPlayer2.play("downC")
	await get_tree().create_timer(2).timeout
	$AudioStreamPlayer3D.play()
	var tween1 = create_tween()
	tween1.tween_method(
		update_cube_colors.bind(Color.WHITE, Color("9f009f")),
		0.0, 1.0, 1.0
	)
	$AnimationPlayer.play("teleport")
	await tween1.finished
	var player = get_tree().get_first_node_in_group("player")
	player.get_node("head/Camera3D/Teleport").teleport()
	await get_tree().create_timer(2).timeout
	$AudioStreamPlayer3D2.play()
	await get_tree().create_timer(1).timeout
	print("бум")
	$TeleportCube.save_contents()
	if Global.saved_portal_data.size() > 0:
		SceneManager.load_scene_with_loading("res://chapter2/rooms/maps/test.tscn")
		return
	$AnimationPlayer.play("RESET")
	for i in range(20):
		set_cube_colors(Color.BLACK if i % 2 == 0 else Color("9f009f"))
		await get_tree().create_timer(0.5).timeout
	$AnimationPlayer2.play("downC", -1, -1.0, true)
	await get_tree().create_timer(2).timeout
	set_cube_colors(Color.WHITE)
	is_animating = false

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
