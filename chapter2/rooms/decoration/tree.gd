extends Sprite3D  

func _ready():
	randomize()
	set_random_texture()

func set_random_texture():
	var is_new_year_period = !Global.game_settings["ModSeason"]
	var texture_paths = []
	if is_new_year_period:
		texture_paths = [
			"res://assets/textures/bushesN.png",
			"res://assets/textures/tree1N.png", 
			"res://assets/textures/tree2N.png"
		]
	else:
		texture_paths = [
			"res://assets/textures/bushes.png",
			"res://assets/textures/tree1.png", 
			"res://assets/textures/tree2.png"
		]
	
	var random_index = randi() % texture_paths.size()
	
	var Rantexture = load(texture_paths[random_index])
	self.texture = Rantexture
