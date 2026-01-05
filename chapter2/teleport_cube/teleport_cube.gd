extends Area3D

class_name TeleportCube

func save_contents():
	Global.saved_portal_data.clear()
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player") or body.is_in_group("item"):
			var relative_position = self.global_transform.affine_inverse() * body.global_position
			var relative_rotation = body.global_rotation - self.global_rotation
			Global.saved_portal_data[body.get_instance_id()] = {
				"object": body,
				"relative_position": relative_position,
				"relative_rotation": relative_rotation
			}
	print("Сохранено объектов: ", Global.saved_portal_data.size())

func teleport_contents():
	if Global.saved_portal_data.is_empty():
		print("Нет данных для телепортации")
		return
	print("Телепортируем объекты...")
	for instance_id in Global.saved_portal_data.keys():
		var data = Global.saved_portal_data[instance_id]
		var object = data["object"]
		if is_instance_valid(object):
			var new_position = self.global_transform * data["relative_position"]
			var new_rotation = self.global_rotation + data["relative_rotation"]
			object.global_position = new_position
			object.global_rotation = new_rotation
			print("Телепортирован: ", object.name)
	Global.saved_portal_data.clear()

func execute_save_and_teleport_to(target_cube: TeleportCube):
	save_contents()
	if target_cube:
		target_cube.teleport_contents()
	else:
		print("Ошибка: целевой куб не указан")
