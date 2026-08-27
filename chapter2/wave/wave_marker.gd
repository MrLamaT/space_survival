extends Marker3D

@export var enemy = "phantom"
@export var numberWave = 0
@export var is_boss = false
@export var aura = 0
@export var enemyTags: String = "player"
const ENEMIES = {
	"phantom": "res://chapter2/enemy/phantom/phantom.tscn",
	"giant stingray": "res://chapter2/enemy/giantStingray/giantStingray.tscn",
	"stingray": "res://chapter2/enemy/stingray/stingray.tscn",
	"infantryman": "res://chapter2/enemy/infantryman/infantryman.tscn",
	"destroyercik": "res://chapter2/enemy/destroyercik/destroyercik.tscn",
	"spark": "res://chapter2/enemy/cockroach/cockroach.tscn",
	"nextbot": "res://chapter2/enemy/nextbot/nextbot.tscn",
	"shooter": "res://chapter2/enemy/shooter/shooter.tscn",
	"cleaner": "res://chapter2/enemy/cleaner/cleaner.tscn",
	"observer 1": "res://chapter2/enemy/observer1/observer1.tscn",
	"siren head": "res://chapter2/enemy/siren_head/siren_head.tscn",
	"SCP": "res://chapter2/enemy/scp/scp.tscn"
}
const RANDOM_ENEMIES_BY_AURA = {
	0: ["phantom", "stingray"],
	1: ["spark", "infantryman"]
}
const PROPS = {
	"barrel": "res://chapter2/prop/barrel.tscn",
	"bed": "res://chapter2/prop/bed.tscn",
	"sofa 1": "res://chapter2/prop/sofa.tscn",
	"sofa 2": "res://chapter2/prop/sofa2.tscn",
	"storage box": "res://chapter2/prop/storageBox.tscn",
	"toilet": "res://chapter2/prop/toilet.tscn",
	"balloon": "res://chapter2/prop/balloon.tscn",
	"workbench": "res://chapter2/prop/workbench.tscn",
	"spring": "res://chapter2/prop/spring.tscn",
	"tree1": "res://chapter2/prop/tree.tscn",
	"tree2": "res://chapter2/prop/tree2.tscn",
	"sanitary fungus 1": "res://chapter2/prop/HpBoost.tscn",
	"sanitary fungus 2": "res://chapter2/prop/HpBoostCitadel.tscn",
	"ERROR": "res://chapter2/prop/error.tscn",
	"watermelon": "res://chapter2/prop/watermelon.tscn",
	"music box": "res://chapter2/prop/column.tscn",
	"light ball": "res://chapter2/prop/lightball.tscn",
	"beach ball": "res://chapter2/prop/beachball.tscn"
}
var scene

func _ready() -> void:
	$Sprite3D.queue_free()

func spawn(type):
	var final_aura = 0
	if enemy != "random":
		final_aura = aura
		if Global.get_world(Global.game_settings.word)["mode"] == 2:
			if randf() < 0.1:
				final_aura = aura + 1
	else:
		var available_enemies = get_random_enemies_by_aura(aura)
		enemy = available_enemies[randi() % available_enemies.size()]
	if ENEMIES.has(enemy): 
		scene = load(ENEMIES[enemy])
	if PROPS.has(enemy): 
		scene = load(PROPS[enemy])
	if scene == null:
		scene = load(PROPS["ERROR"])
	var instance = scene.instantiate()
	if ENEMIES.has(enemy):
		instance.is_boss = is_boss
		instance.aura = final_aura
		instance.enemyTags = enemyTags
	get_tree().root.add_child(instance)
	instance.global_position = global_position
	if type == "key":
		instance.add_to_group("enemy_wave")
	var portal_scene = preload("res://chapter2/wave/WavePortal.tscn")
	var portal_instance = portal_scene.instantiate()
	get_tree().root.add_child(portal_instance)
	portal_instance.global_position = global_position
	queue_free()

func get_random_enemies_by_aura(aura_level: int) -> Array:
	if RANDOM_ENEMIES_BY_AURA.has(aura_level):
		return RANDOM_ENEMIES_BY_AURA[aura_level]
	var all_enemies = []
	for level in RANDOM_ENEMIES_BY_AURA.values():
		all_enemies.append_array(level)
	return all_enemies.duplicate()
