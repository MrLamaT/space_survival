extends Area3D

@export var new_min_y = false
var using = false

func _ready() -> void:
	$Label3D.queue_free()
	$MeshInstance3D.queue_free()
	$MeshInstance3D2.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !using:
		Global.game_settings["checkpoint"] = global_position
		if new_min_y:
			Global.game_settings["min_y"] = global_position.y - 5
		using = true
