extends Node2D

var texture_cache = {}
var world = Global.get_world(Global.game_settings.word)

func recipe(required_resources, required_label, required_description):
	$Panel/Label.text = required_label
	$Panel/Label2.text = required_description
	var inventory = world["inventory"]
	var resource_nodes = {
		"Credits": $Panel/VBoxContainer/Credits,
		"Sercilist": $Panel/VBoxContainer/Sercilist,
		"Dark Sercilist": $Panel/VBoxContainer/DarkSercilist
	}
	for resource_name in resource_nodes.keys():
		var node = resource_nodes[resource_name]
		var required_amount = required_resources.get(resource_name, 0)
		var label = node.get_node("Label") 
		if required_amount > 0:
			node.visible = true
			label.text = str(required_amount)
			if inventory.has(resource_name) and inventory[resource_name] >= required_amount:
				label.modulate = Color.WHITE
			else:
				label.modulate = Color.RED
		else:
			node.visible = false
