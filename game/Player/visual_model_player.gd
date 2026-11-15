extends RigidBody3D

const SKIN_TEXTURES = {
	"fox_white": null,
	"fox_black": preload("res://assets/skin_npc/fox_black.png"),
	"fox_home": preload("res://assets/skin_npc/fox_home.png"),
	"fox_knight": preload("res://assets/skin_npc/fox_knight.png"),
	"fox_snow": preload("res://assets/skin_npc/fox_snow.png"),
	"fox_prisoner": preload("res://assets/skin_npc/fox_prisoner.png"),
	"fox_phantom": preload("res://assets/skin_npc/fox_phantom.png"),
	"destroyercik": preload("res://assets/skin_npc/destroyercik.png"),
}

const MESH_PATHS = [
	^"Node3D/head/MeshInstance3D",
	^"Node3D/hand1/MeshInstance3D",
	^"Node3D/hand2/MeshInstance3D",
	^"Node3D/body/MeshInstance3D",
	^"Node3D/legs1/MeshInstance3D",
	^"Node3D/legs2/MeshInstance3D",
]

@export var skin: String = "random"

func _ready() -> void:
	var selected_skin := skin
	if selected_skin == "random":
		selected_skin = SKIN_TEXTURES.keys().pick_random()
	var texture: Texture2D = SKIN_TEXTURES.get(selected_skin)
	if texture == null:
		return
	for mesh_path in MESH_PATHS:
		get_node(mesh_path).set("atlas_texture", texture)
	if not selected_skin.begins_with("fox"):
		$Node3D/head/MeshInstance3D2.queue_free()
