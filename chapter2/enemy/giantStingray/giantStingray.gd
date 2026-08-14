extends "res://chapter2/enemy/BaseEnemy.gd"

var death_rotation: float = 0.0

func _ready():
	double_damage_in_air = false
	super._ready()
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 5

func _get_boss_id() -> String:
	return "stingray"
	
func _handle_death_process(delta):
	if Global.game_settings["UI"] or Global.game_settings["GhostMod"]:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		is_dead = true
		_spawn_boom_projectile()
		queue_free()
		return
	death_timer += delta
	var progress = min(death_timer / DEATH_DELAY, 1.0)
	death_rotation = progress * 90.0
	rotation_degrees.x = death_rotation
	velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
	move_and_slide()

func _spawn_boom_projectile():
	var boom_scene = load("res://chapter2/item/Boom_projectile/Boom_projectile.tscn")
	if boom_scene:
		var boom_instance = boom_scene.instantiate()
		get_tree().root.add_child(boom_instance)
		boom_instance.global_position = $BulletSpawn.global_position

func die():
	if is_dying or is_dead:
		return
	super.die()
	death_rotation = 0.0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fly":
		queue_free()
