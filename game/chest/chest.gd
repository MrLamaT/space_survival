extends Area3D

@export var img: Texture
@export var global_key = ""
@export var id = 1

const REWARD_MODEL := preload("res://game/Player/visual_model_player.tscn")
const PREVIEW_SKINS := {
	"Classic": "fox_black",
	"Home": "fox_home",
	"Knight": "fox_knight",
	"Phantom": "fox_phantom",
	"Snow": "fox_snow",
	"White": "fox_white",
	"Prisoner": "fox_prisoner",
}
const REWARD_TURN_SPEED := 1.6

@onready var reward_preview: SubViewportContainer = $CanvasLayer/RewardPreview
@onready var reward_pivot: Node3D = $CanvasLayer/RewardPreview/Viewport/Pivot

var _secondary_color: Color

func _ready() -> void:
	_secondary_color = Color("616380").darkened(0.1)
	var world_data = Global.get_world(Global.game_settings.world)
	var key = str(global_key) + "_" + str(id)
	if world_data.inventory.has(key):
		$Sprite3D.modulate = _secondary_color
		$Sprite3D.shaded = true
		$AnimationPlayer.play("open")
		remove_from_group("interactive_objects")

func trigger_interaction():
	var world_data = Global.get_world(Global.game_settings.world)
	world_data.inventory.append(str(global_key) + "_" + str(id))
	_prepare_reward_model()
	$CanvasLayer/AnimationPlayer.play("obtaining")
	$Sprite3D.modulate = _secondary_color
	$Sprite3D.shaded = true
	$AnimationPlayer.play("open")
	remove_from_group("interactive_objects")
	Global.save(Global.game_settings["world"])

func _prepare_reward_model() -> void:
	if reward_pivot.get_child_count() > 0:
		return
	var model := REWARD_MODEL.instantiate() as RigidBody3D
	model.freeze = true
	model.collision_layer = 0
	model.collision_mask = 0
	var preview_skin: String = PREVIEW_SKINS.get(str(global_key), "fox_black")
	model.set("skin", preview_skin)
	reward_pivot.add_child(model)
