extends Area3D

@export var weapon: String = "Taser" #название оружия
@export var slot: int = 1 #слот куда оружие будет сохранено 
@export var img: Texture2D #текстура оружия
var task = false
var hand_item: Node3D
const HAND_ITEM_SCENE = preload("res://game/item/hand_item.tscn")

func _ready() -> void:
	hand_item = HAND_ITEM_SCENE.instantiate()
	hand_item.position = Vector3(0.0, 0.8, 0.0)
	hand_item.scale = Vector3(1.5, 1.5, 1.5)
	hand_item.texture = img
	add_child(hand_item)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !task:
		hand_item.queue_free()
		var world = Global.get_world(Global.game_settings.word)
		world["weapon"][slot - 1] = weapon
		var weapon_system = body.weapon_system
		weapon_system.weapon_slots[slot] = weapon
		weapon_system.equip_weapon(weapon_system.weapon_slots.get(slot, ""))
		task = true
		Global.save(Global.game_settings["word"])
