extends "res://game/rooms/BaseMaps.gd"

func _ready() -> void:
	super._ready()
	$Player.openUI("simulation_intro")
