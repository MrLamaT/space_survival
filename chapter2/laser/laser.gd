extends StaticBody3D

@export var size_laser = 7.5

func _ready() -> void:
	$Area3D.scale = Vector3(size_laser, 1.0, 1.0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.HP(100)
