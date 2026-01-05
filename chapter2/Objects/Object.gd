extends StaticBody3D

@onready var model: MeshInstance3D = $Model
@onready var colision_shape: CollisionShape3D = $CollisionShape3D
@onready var clipping_hitbox: Area3D = $ClippingHitBox
@onready var floatin_hitbox: Area3D = $FloatinHitBox

var red_material: Material = load("res://chapter2/Objects/Red.tres")
var blue_material: Material = load("res://chapter2/Objects/Blue.tres")
var can_place = true

func _process(_delta: float) -> void:
	if clipping_hitbox:
		model.transparency = 0.6
		can_place = clipping_hitbox.get_overlapping_bodies().is_empty() and not floatin_hitbox.get_overlapping_bodies().is_empty()
		if can_place:
			model.material_overlay = blue_material
		else:
			model.material_overlay = red_material
			
func place():
	clipping_hitbox.queue_free()
	floatin_hitbox.queue_free()
	model.material_overlay = null
	model.transparency = 0.0
	colision_shape.disabled = false

func destroy():
	queue_free()
