extends Node2D

var texture_cache = {}

func recipe(required_resources, required_label, required_description):
	$Panel/Label.text = required_label
	$Panel/Label2.text = required_description
	for i in range(1, 10):
		var control = get_node_or_null("Panel/Control%d" % i)
		if control:
			control.visible = false
	var world = Global.get_world(Global.game_settings.word)
	var player_has_resources = {}
	if world and world.has("inventory"):
		var inventory = world["inventory"]["inventory"]
		for resource in inventory:
			if resource in player_has_resources:
				player_has_resources[resource] += 1
			else:
				player_has_resources[resource] = 1
	var required_counts = {}
	for resource in required_resources:
		if resource in required_counts:
			required_counts[resource] += 1
		else:
			required_counts[resource] = 1
	for i in range(min(required_resources.size(), 9)):
		var control_path = "Panel/Control%d" % (i + 1)
		var control = get_node_or_null(control_path)
		if control:
			control.visible = true
			var resource = required_resources[i]
			var sprite = control.get_node("Sprite2D")
			var label = control.get_node("Label")
			var texture_path = "res://assets/item/%s.png" % resource
			var texture = texture_cache.get(texture_path)
			if not texture:
				texture = load(texture_path)
				if texture:
					texture_cache[texture_path] = texture
			if texture:
				sprite.texture = texture
			else:
				print("Текстура не найдена: ", texture_path)
				sprite.texture = null
			var has_enough = false
			if resource in player_has_resources:
				var count_so_far = 0
				for j in range(i + 1):
					if required_resources[j] == resource:
						count_so_far += 1
				has_enough = (player_has_resources[resource] >= count_so_far)
			if has_enough:
				label.add_theme_color_override("font_color", Color.WHITE)
			else:
				label.add_theme_color_override("font_color", Color.RED)
			label.text = resource
