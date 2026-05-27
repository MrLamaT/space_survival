extends Marker3D

@export var enemy = "phantom"
@export var numberWave = 0
@export var is_boss = false
@export var aura = 0
var enemy_scene

func _ready() -> void:
	$Sprite3D.queue_free()

func spawn(type):
	var enemies = {
		"phantom": "res://chapter2/enemy/phantom.tscn",
		"giantStingray": "res://chapter2/enemy/giantStingray.tscn",
		"infantryman": "res://chapter2/enemy/infantryman.tscn",
		"cockroach": "res://chapter2/enemy/cockroach.tscn",
		"nextbot": "res://chapter2/enemy/nextbot.tscn",
		"shooter": "res://chapter2/enemy/shooter.tscn",
		"cleaner": "res://chapter2/enemy/cleaner.tscn"
	}
	if not enemies.has(enemy):
		print("ERROR: Unknown enemy type: " + enemy)
		return
	var final_aura = aura
	if Global.get_world(Global.game_settings.word)["mode"] == 2:
		var rare_chance = 0.1
		if randf() < rare_chance:
			final_aura = aura + 1
	enemy_scene = load(enemies[enemy])
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.is_boss = is_boss
	enemy_instance.aura = final_aura
	var area = get_parent()
	var navigation_region = null
	if !(area is NavigationRegion3D):
		navigation_region = area.get_parent()
	else:
		navigation_region = area
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
