extends Area3D

@export var can_stand_up: bool = true 

func _ready():
	$MeshInstance3D.visible = false
	visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):  
		if not can_stand_up:
			body.CanStandUp = false

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.CanStandUp = true
		body.force_stand_up()
