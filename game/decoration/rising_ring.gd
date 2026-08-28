extends StaticBody3D
@export var linked_nodes: Array[Node] = []
var included = false

func on():
	if !included:
		$AnimationPlayer.play("ring")
		$start.play("start")
		included = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		for node in linked_nodes:
			if node and node.has_method("on"):
				node.on()
