extends Node3D

func _ready() -> void:
	$NavigationRegion3D/portal/TeleportCube.teleport_contents()
