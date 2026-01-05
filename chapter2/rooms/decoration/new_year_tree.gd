extends Sprite3D

func _ready() -> void:
	var now = Time.get_datetime_dict_from_system()
	var month = now["month"]
	var day = now["day"]
	var event = false
	
	if (month == 12 and day >= 10) or (month == 1 and day <= 10):
		event = true
	
	if !event:
		queue_free()
