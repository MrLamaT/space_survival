extends "res://game/wave/BaseWave.gd"

@export var ImpenetrableField: Node3D

const BOOM_SCENE = preload(
	"res://game/enemy_projectile/Boom_projectile/Boom_projectile.tscn"
)

func _ready() -> void:
	if not is_instance_valid(ImpenetrableField):
		is_active = false
		_enable_attack()
		$Node3D/button.queue_free()

func handle_interaction(object_name: String) -> void:
	if object_name != "start":
		return
	if not is_active or not is_instance_valid(ImpenetrableField):
		return
	is_active = false
	start_wave()
	wave_timer.start()

func _on_attack_body_entered(body: Node3D) -> void:
	if body.is_in_group("phantom") and body.has_method("take_damage"):
		body.take_damage(999999)

func _before_wave_start() -> void:
	var boom := BOOM_SCENE.instantiate() as Node3D
	get_tree().root.add_child(boom)
	boom.global_position = $BulletSpawn.global_position

func _on_wave_complete() -> void:
	_enable_attack()
	if is_instance_valid(ImpenetrableField):
		ImpenetrableField.on(true)
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("warning"):
		player.warning("NOTICE_FIELD_OPEN")

func _enable_attack() -> void:
	$attack/AnimationPlayer.play("attack")
	$attack/CollisionShape3D.set_deferred("disabled", false)
