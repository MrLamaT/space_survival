extends Area3D

@export var on = true

func _ready() -> void:
	if !on:
		$MeshInstance3D10/MeshInstance3D11.visible = false

func On():
	$MeshInstance3D10/MeshInstance3D11.visible = true

func switching():
	$MeshInstance3D10/MeshInstance3D11.visible = !$MeshInstance3D10/MeshInstance3D11.visible
