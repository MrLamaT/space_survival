extends StaticBody3D

@export var size_laser = 7.5
@export var period = 0
@export var damage = 100

func _ready() -> void:
	$Area3D.scale.x = size_laser
	if period != 0:
		$Area3D/Timer.wait_time = period
		$Area3D/Timer.start()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and visible:
		body.HP(damage)

func _on_timer_timeout() -> void:
	$Area3D/CollisionShape3D.disabled = $Area3D.visible
	$Area3D.visible = !$Area3D.visible
