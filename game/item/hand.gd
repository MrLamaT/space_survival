extends Node3D

func _ready() -> void:
	create_custom_material()

func create_custom_material() -> void:
	var costume_textures = {
		"Classic": preload("res://assets/skin_npc/fox_black.png"),
		"Home": preload("res://assets/skin_npc/fox_home.png"),
		"Knight": preload("res://assets/skin_npc/fox_knight.png"),
		"Phantom": "res://assets/skin_npc/fox_phantom.png",
		"Snow": preload("res://assets/skin_npc/fox_snow.png"),
		"White": preload("res://assets/skin_npc/fox_white.png"),
		"Prisoner": preload("res://assets/skin_npc/fox_prisoner.png")
	}
	var world = Global.get_world(Global.game_settings.world)
	var costume_key = world.get("costumes", "Classic")
	$MeshInstance3D2.atlas_texture = costume_textures.get(costume_key, preload("res://assets/skin_npc/fox_black.png"))
	$MeshInstance3D.atlas_texture = costume_textures.get(costume_key, preload("res://assets/skin_npc/fox_black.png"))
