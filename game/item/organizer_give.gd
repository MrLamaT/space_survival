extends Area3D

@export var weapon: String = "Taser"
@export var slot: int = 1
@export var img: Texture
var task = false
var hand_item: Node3D

func _ready() -> void:
	var hand_item_scene = load("res://game/item/hand_item.tscn")
	hand_item = hand_item_scene.instantiate()
	hand_item.position = Vector3(0.0, 0.8, 0.0)
	hand_item.scale = Vector3(1.5, 1.5, 1.5)
	hand_item.texture = img
	add_child(hand_item)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !task:
		hand_item.queue_free()
		var world = Global.get_world(Global.game_settings.word)
		world["weapon"][slot - 1] = weapon
		body.weapon_system.weapon_slots[slot] = weapon
		body.weapon_system.equip_weapon(body.weapon_system.weapon_slots.get(slot, ""))
		task = true
