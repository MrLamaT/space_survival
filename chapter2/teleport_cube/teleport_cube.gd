extends Area3D

class_name TeleportCube

func save_contents():
	Global.saved_portal_data.clear()
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			var relative_position = self.global_transform.affine_inverse() * body.global_position
			Global.saved_portal_data = {
				"relative_position": relative_position
			}
		print("Сохранено: ", Global.saved_portal_data)
		return

func teleport_contents():
	if Global.saved_portal_data.is_empty():
		print("Нет данных для телепортации")
		return
	print("Телепортируем игрока...")
	var player = get_tree().get_first_node_in_group("player")
	var new_position = self.global_transform * Global.saved_portal_data["relative_position"]
	
	player.global_position = new_position
	print("Игрок телепортирован на: ", player.global_position)
	Global.saved_portal_data.clear()

func execute_save_and_teleport_to(target_cube: TeleportCube):
	save_contents()
	if target_cube:
		target_cube.teleport_contents()
	else:
		print("Ошибка: целевой куб не указан")
