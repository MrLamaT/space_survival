extends Node2D

var score = 0
@onready var panel: Panel = $game
@onready var player: CharacterBody2D = $game/CharacterBody2D
@onready var keys = [$game/key, $game/key2, $game/key3, $game/key4]

func _ready() -> void:
	randomize()
	place_objects_randomly()

func place_objects_randomly():
	var panel_position = panel.global_position
	var panel_size = panel.size
	var player_pos = Vector2(
		randf_range(panel_position.x, panel_position.x + panel_size.x),
		randf_range(panel_position.y, panel_position.y + panel_size.y)
	)
	player.global_position = player_pos
	for i in keys:
		var key_pos = Vector2(
			randf_range(panel_position.x, panel_position.x + panel_size.x),
			randf_range(panel_position.y, panel_position.y + panel_size.y)
		)
		i.global_position = key_pos

func key(IdKey):
	score += 1
	$game/Label.text = str(score) + " / 4"
	IdKey.queue_free()

func _on_key_body_entered(_body: Node2D) -> void:
	key($game/key)

func _on_key_2_body_entered(_body: Node2D) -> void:
	key($game/key2)

func _on_key_3_body_entered(_body: Node2D) -> void:
	key($game/key3)

func _on_key_4_body_entered(_body: Node2D) -> void:
	key($game/key4)
