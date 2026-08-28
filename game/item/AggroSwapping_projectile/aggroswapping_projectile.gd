extends Node3D

var speed: float = 50.0
var direction: Vector3 = Vector3.ZERO
var damage: int = 10
var lifetime: float = 3.0
var timer: float = 0.0

func shoot(dir: Vector3, spd: float):
	direction = dir
	speed = spd

func _physics_process(delta):
	if direction != Vector3.ZERO:
		global_translate(direction * speed * delta)
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get("enemyTags"):
		print(body.get("enemyTags"))
		body["enemyTags"] = "phantom"
		body["player"] = null
	queue_free()
