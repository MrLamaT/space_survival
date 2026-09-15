extends MeshInstance3D

const rarity_gray: float = 0.01 

func _ready():
	randomize()
	apply_random_color()

func apply_random_color():
	material_override = StandardMaterial3D.new()
	material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var rand = randf()
	if rand < rarity_gray:
		material_override.albedo_color = Color.GRAY
		return
	var colors = [
		Color.RED,
		Color.BLUE,
		Color.GREEN,
		Color.YELLOW
	]
	var random_index = randi() % colors.size()
	material_override.albedo_color = colors[random_index]

func refresh_color():
	apply_random_color()
