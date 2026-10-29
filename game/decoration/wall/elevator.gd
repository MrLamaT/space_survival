extends Node3D

enum Floor { BOTTOM = 0, MOVING = 1, TOP = 2 }

var elevator_floor: int = Floor.BOTTOM
var is_moving: bool = false
var doors_open_at: int = Floor.BOTTOM  

func handle_interaction(object_name: String) -> void:
	if is_moving:
		return
	match object_name:
		"up":        _try_move(Floor.TOP, "up")
		"down":      _try_move(Floor.BOTTOM, "down")
		"call_up":   _try_move(Floor.TOP, "up")
		"call_down": _try_move(Floor.BOTTOM, "down")
		_:
			push_warning("Unknown elevator command: %s" % object_name)

func _try_move(target_floor: int, anim_name: String) -> void:
	if elevator_floor == target_floor:
		_open_doors(target_floor) 
		return
	is_moving = true
	_close_doors(elevator_floor)
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play(anim_name)

func _close_doors(floor_index: int) -> void:
	if doors_open_at != floor_index:
		return 
	match floor_index:
		Floor.BOTTOM: $wallGates.blocking()
		Floor.TOP:    $wallGates2.blocking()
	doors_open_at = -1

func _open_doors(floor_index: int) -> void:
	if doors_open_at == floor_index:
		return 
	match floor_index:
		Floor.BOTTOM: $wallGates.unlocking()
		Floor.TOP:    $wallGates2.unlocking()
	doors_open_at = floor_index

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"up":
			elevator_floor = Floor.TOP
			_open_doors(Floor.TOP)
		"down":
			elevator_floor = Floor.BOTTOM
			_open_doors(Floor.BOTTOM)
		_:
			return
	is_moving = false
