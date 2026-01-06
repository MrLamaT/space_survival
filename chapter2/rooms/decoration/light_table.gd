extends Area3D

func On():
	$MeshInstance3D10/MeshInstance3D11.visible = true

func switching():
	$MeshInstance3D10/MeshInstance3D11.visible = !$MeshInstance3D10/MeshInstance3D11.visible
