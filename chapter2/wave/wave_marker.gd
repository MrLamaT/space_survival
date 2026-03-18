extends Marker3D

@export var enemy = "phantom"

func _ready() -> void:
	$Sprite3D.visible = false

func spawn(type):
	$AnimationPlayer.play("teleport")
	if enemy == "phantom":
		var enemy_scene = preload("res://chapter2/enemy/phantom.tscn")
		var enemy_instance = enemy_scene.instantiate()
		var area = get_parent()
		var navigation_region = area.get_parent()
		if navigation_region is NavigationRegion3D:
			navigation_region.add_child(enemy_instance)
			enemy_instance.global_position = global_position
			if type == "key":
				enemy_instance.add_to_group("enemy_wale")
