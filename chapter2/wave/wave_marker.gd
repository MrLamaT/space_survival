extends Marker3D

@export var enemy = "phantom"
@export var numberWave = 0
@export var is_boss = false
@export var aura = 0
var enemy_scene

func _ready() -> void:
	$Sprite3D.queue_free()

func spawn(type):
	if enemy == "phantom":
		enemy_scene = preload("res://chapter2/enemy/phantom.tscn")
	if enemy == "giantStingray":
		enemy_scene = preload("res://chapter2/enemy/giantStingray.tscn")
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.is_boss = is_boss
	enemy_instance.aura = aura
	var area = get_parent()
	var navigation_region = area.get_parent()
	if navigation_region is NavigationRegion3D:
		navigation_region.add_child(enemy_instance)
		enemy_instance.global_position = global_position
		if type == "key":
			enemy_instance.add_to_group("enemy_wave")
	var portal_scene = preload("res://chapter2/wave/WavePortal.tscn")
	var portal_instance = portal_scene.instantiate()
	if navigation_region is NavigationRegion3D:
		navigation_region.add_child(portal_instance)
		portal_instance.global_position = global_position
