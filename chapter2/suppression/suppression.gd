extends StaticBody3D

@export var ImpenetrableField: Node3D
@export var sound = true
var is_active = true
var current_wave = 0
var SpawnAudio = false

func _ready() -> void:
	if !ImpenetrableField:
		is_active = false
		$Node3D/Node3D/AnimationPlayer.play("start")
		$attack/AnimationPlayer.play("attack")
		$attack/CollisionShape3D.disabled = false
		$button.queue_free()
		$button2.queue_free()
		$button3.queue_free()
		$button4.queue_free()

func handle_interaction(object_name: String):
	match object_name:
		"start":
			if ImpenetrableField and is_active:
				start_wave()
				$Timer.start()
				is_active = false

func _on_attack_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage") and body.is_in_group("phantom"):
		body.take_damage(999999)

func start_wave() -> void:
	if !SpawnAudio and sound:
		$AudioStreamPlayer3D.pitch_scale = randf_range(1.9, 2.1)
		$AudioStreamPlayer3D.play()
		SpawnAudio = true
	var markers = find_children("*", "Marker3D", true, false)
	var wave_started = false
	for marker in markers:
		if marker.has_method("spawn") and marker["numberWave"] == current_wave:
			marker.spawn("key")
			wave_started = true
	if not wave_started and current_wave != 0:
		_on_wave_complete()

func _on_wave_complete() -> void:
	$Timer.stop()
	$Node3D/Node3D/AnimationPlayer.play("start")
	$attack/AnimationPlayer.play("attack")
	$attack/CollisionShape3D.disabled = false
	ImpenetrableField.on(true)
	var player = get_tree().get_first_node_in_group("player")
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		player.warning("Непробиваемое поле открылось")
	else:
		player.warning("The Impenetrable Field has opened")

func _on_timer_timeout() -> void:
	var enemy_nodes = get_tree().get_nodes_in_group("enemy_wave")
	print("enemy_wale: ", enemy_nodes.size())
	if enemy_nodes.size() == 0:
		current_wave += 1
		start_wave()
