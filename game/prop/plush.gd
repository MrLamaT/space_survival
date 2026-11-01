extends RigidBody3D

@export var skin = "random"

func _ready() -> void:
	if skin == "fox_white":
		return
	if skin == "fox_black":
		$Node3D/head/MeshInstance3D.atlas_texture = preload("res://assets/skin_npc/fox_black.png")
		$Node3D/hand1/MeshInstance3D.atlas_texture = preload("res://assets/skin_npc/fox_black.png")
		$Node3D/hand2/MeshInstance3D.atlas_texture = preload("res://assets/skin_npc/fox_black.png")
		$Node3D/body/MeshInstance3D.atlas_texture = preload("res://assets/skin_npc/fox_black.png")
		$Node3D/legs1/MeshInstance3D.atlas_texture = preload("res://assets/skin_npc/fox_black.png")
		$Node3D/legs2/MeshInstance3D.atlas_texture = preload("res://assets/skin_npc/fox_black.png")
		return
