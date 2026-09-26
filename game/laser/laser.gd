extends StaticBody3D

@export var size_laser: float = 7.5 # Размер лазера
@export var period: int = 0 # Период срабатывания лазера в секундах.
@export var damage: int = 100 # Урон

@onready var zone = $Area3D
@onready var collision = $Area3D/CollisionShape3D
@onready var timer = $Area3D/Timer

func _ready() -> void:
	zone.scale.x = size_laser
	if period > 0:
		timer.wait_time = period
		timer.start()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and visible:
		body.HP(damage)

func _on_timer_timeout() -> void:
	toggle()

func toggle():
	collision.disabled = zone.visible
	zone.visible = !zone.visible
