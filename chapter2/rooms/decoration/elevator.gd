extends StaticBody3D

@export var elevator_id: String = "main_floor"
@export var destination_floors = {
	"0": "basement",
	"1": "main_floor", 
	"2": "attic"
}
var IsTeleporting = false
@onready var teleport_cube: TeleportCube = $TeleportCube

func handle_interaction(object_name: String):
	match object_name:
		"0", "1", "2":
			if !IsTeleporting:
				IsTeleporting = true
				if $wall3/Door.disabled:
					$AnimationPlayer.play("close")
				animate_button(object_name)
				if elevator_id == destination_floors.get(object_name, ""):
					IsTeleporting = false
					return
				teleport_to_floor(object_name)
		"open":
			animate_button(object_name)
			if !$wall3/Door.disabled:
				$AnimationPlayer.play("open")
			else:
				$AnimationPlayer.play("close")

func animate_button(button_name: String):
	match button_name:
		"0":
			$board/MeshInstance3D6.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D6.position.y = 0.589
		"1":
			$board/MeshInstance3D5.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D5.position.y = 0.589
		"2":
			$board/MeshInstance3D4.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D4.position.y = 0.589
		"open":
			$board2/MeshInstance3D5.position.y = 0.349
			$board3/MeshInstance3D5.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board2/MeshInstance3D5.position.y = 0.589
			$board3/MeshInstance3D5.position.y = 0.589

func teleport_to_floor(floor_number: String):
	var target_elevator_id = destination_floors[floor_number]
	var target_elevator = find_elevator_by_id(target_elevator_id)
	if not target_elevator:
		print("Ошибка: лифт с ID '", target_elevator_id, "' не найден!")
		IsTeleporting = false
		return
	var target_cube: TeleportCube = target_elevator.get_node_or_null("TeleportCube")
	if not target_cube:
		print("Ошибка: TeleportCube не найден в лифте ", target_elevator_id)
		IsTeleporting = false
		return
	await get_tree().create_timer(1).timeout
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("AnimationPlayPlayer"):
		player.AnimationPlayPlayer("BlackOut")
		await get_tree().create_timer(0.25).timeout
	if teleport_cube and target_cube:
		teleport_cube.save_contents()
		target_cube.teleport_contents()
		print("Телепортация к лифту: ", target_elevator_id)
	else:
		print("Ошибка: кубы телепортации не найдены")
	IsTeleporting = false
		
func find_elevator_by_id(target_id: String) -> StaticBody3D:
	var elevators = get_tree().get_nodes_in_group("elevators")
	for elevator in elevators:
		if elevator.elevator_id == target_id:
			return elevator
	return null

func save_elevator_contents():
	if teleport_cube:
		teleport_cube.save_contents()
		print("Содержимое лифта ", elevator_id, " сохранено")

func teleport_to_this_elevator():
	if teleport_cube:
		teleport_cube.teleport_contents()
		print("Телепортация в лифт ", elevator_id)
