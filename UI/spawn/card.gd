extends Control

@export var text = ""
@export var img: Texture
@export var color_img: Color = Color("ffffffff")
@export var type = ""
@export var target_node: Node = null
@export var price: int = 0

func _ready() -> void:
	$Panel/Label.text = text
	$Panel/card.texture = img
	$Panel/card.modulate = color_img
	
	if price > 0:
		var world_data = Global.get_world(Global.game_settings.word)
		var found_count = 0
		for i in range(1, price + 1):
			var key = str(text) + "_" + str(i)
			if world_data.inventory.has(key):
				found_count += 1
		if found_count < price:
			$Panel/price.visible = true
			$Panel/price.text = str(found_count)  + " / " + str(price)

func _on_button_pressed() -> void:
	if $Panel/price.visible:
		$AnimationPlayer.play("block")
		return
	target_node.handle_card_pressed(type, text, color_img)
