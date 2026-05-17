extends "res://chapter2/enemy/BaseEnemy.gd"

var death_rotation: float = 0.0
var SPEED: float = 6
var ACCELERATION: float = 5.0

func _ready():
	double_damage_in_air = false
	super._ready()
	health = 100000
	if aura > 0:
		health *= aura + 1
	_setup_boss_bar()
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 5

func _apply_aura():
	super._apply_aura()
	SPEED *= speed_multiplier

func _get_boss_id() -> String:
	return "stingray"
	
func _physics_process(delta):
	if is_dead:
		return
	if is_dying:
		_handle_death_process(delta)
		return

func _handle_death_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		is_dead = true
		queue_free()
		return
	death_timer += delta
	var progress = min(death_timer / DEATH_DELAY, 1.0)
	death_rotation = progress * 90.0
	rotation_degrees.x = death_rotation
	velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
	move_and_slide()

func die():
	if is_dying or is_dead:
		return
	super.die()
	death_rotation = 0.0

func take_damage(damage: int):
	if is_dying or is_dead:
		return
	health -= damage
	if is_boss:
		var boss_bars = get_tree().get_nodes_in_group("BossBar")
		if boss_bars.size() > 0:
			boss_bars[0]._on_health_changed(health)
	if health <= 0:
		if spark_dead:
			spark_dead.emitting = true
		die()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fly":
		queue_free()
