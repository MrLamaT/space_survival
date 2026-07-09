extends Area3D

var using = false

func _ready() -> void:
	$Label3D.queue_free()
	$MeshInstance3D.queue_free()
	$MeshInstance3D2.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !using:
		Global.game_settings["checkpoint"] = global_position
		using = true
