extends Marker3D

@export var enemy = "phantom"
@export var numberWave = 0
@export var is_boss = false
@export var aura = 0
@export var enemyTags: String = "player"
const ENEMIES = {
	"phantom": "res://game/enemy/phantom/phantom.tscn",
	"giant stingray": "res://game/enemy/giantStingray/giantStingray.tscn",
	"stingray": "res://game/enemy/stingray/stingray.tscn",
	"infantryman": "res://game/enemy/infantryman/infantryman.tscn",
	"destroyercik": "res://game/enemy/destroyercik/destroyercik.tscn",
	"spark": "res://game/enemy/cockroach/cockroach.tscn",
	"nextbot": "res://game/enemy/nextbot/nextbot.tscn",
	"shooter": "res://game/enemy/shooter/shooter.tscn",
	"cleaner": "res://game/enemy/cleaner/cleaner.tscn",
	"observer 1": "res://game/enemy/observer1/observer1.tscn",
	"siren head": "res://game/enemy/siren_head/siren_head.tscn",
	"SCP": "res://game/enemy/scp/scp.tscn"
}
const RANDOM_ENEMIES_BY_AURA = {
	0: ["phantom", "stingray"],
	1: ["spark", "infantryman"]
}
const PROPS = {
	"barrel": "res://game/prop/barrel.tscn",
	"bed": "res://game/prop/bed.tscn",
	"sofa 1": "res://game/prop/sofa.tscn",
	"sofa 2": "res://game/prop/sofa2.tscn",
	"storage box": "res://game/prop/storageBox.tscn",
	"toilet": "res://game/prop/toilet.tscn",
	"balloon": "res://game/prop/balloon.tscn",
	"workbench": "res://game/prop/workbench.tscn",
	"spring": "res://game/prop/spring.tscn",
	"tree1": "res://game/prop/tree.tscn",
	"tree2": "res://game/prop/tree2.tscn",
	"tree3": "res://game/prop/tree3.tscn",
	"tree4": "res://game/prop/tree4.tscn",
	"tree5": "res://game/prop/tree5.tscn",
	"sanitary fungus 1": "res://game/prop/HpBoost.tscn",
	"sanitary fungus 2": "res://game/prop/HpBoostCitadel.tscn",
	"ERROR": "res://game/prop/error.tscn",
	"watermelon": "res://game/prop/watermelon.tscn",
	"music box": "res://game/prop/column.tscn",
	"light ball": "res://game/prop/lightball.tscn",
	"beach ball": "res://game/prop/beachball.tscn"
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
	var portal_scene = preload("res://game/wave/WavePortal.tscn")
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
