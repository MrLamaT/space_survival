extends Area3D

@export var boost = 30

func _ready() -> void:
	$Sprite3D/Label3D.text = str(boost)

func _on_body_entered(body: Node3D) -> void:
	if $Sprite3D.visible:
		$AudioStreamPlayer3D.play()
		$Sprite3D.visible = false
		$sparkDead.emitting = true
		body.timerBoost(boost)

func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
