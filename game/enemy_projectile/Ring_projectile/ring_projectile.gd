extends Node3D

@export var damage: int = 12
@export var launch_speed: float = 9.0

@onready var ring: MeshInstance3D = $Ring
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _torus: TorusMesh
var _radius: float
var half_width: float
var half_height: float
var _hit_player := false

func _ready() -> void:
	_torus = ring.mesh.duplicate() as TorusMesh
	ring.mesh = _torus
	$Ring/Ring.mesh = _torus
	$Ring/Ring2.mesh = _torus
	animation_player.callback_mode_process = (
		AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	)
	animation_player.play("expand")
	animation_player.advance(0.0)
	_read_ring_dimensions()

func _physics_process(delta: float) -> void:
	var previous_radius := _radius
	animation_player.advance(delta)
	_read_ring_dimensions()
	if not _hit_player and not Global.IsDying:
		_check_player(previous_radius)
	if not animation_player.is_playing():
		queue_free()

func _check_player(previous_radius: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody3D
	if player == null:
		return
	var collider := player.get_node("CollisionShape3D") as CollisionShape3D
	var capsule := collider.shape as CapsuleShape3D
	var offset := collider.global_position - global_position
	var collider_basis := collider.global_transform.basis
	var player_radius := capsule.radius * maxf(
		collider_basis.x.length(), collider_basis.z.length()
	)
	var player_half_height := capsule.height * 0.5 * collider_basis.y.length()
	if absf(offset.y) > half_height + player_half_height:
		return
	var distance := Vector2(offset.x, offset.z).length()
	var inner_edge := maxf(0.0, previous_radius - half_width)
	var outer_edge := _radius + half_width
	if distance + player_radius < inner_edge or distance - player_radius > outer_edge:
		return
	_hit_player = true
	player.call("take_damage", damage)
	if Global.IsDying:
		return
	player.call("cancel_dash")
	player.velocity.y = maxf(player.velocity.y, launch_speed)

func _read_ring_dimensions() -> void:
	_radius = (_torus.inner_radius + _torus.outer_radius) * 0.5
	half_width = (_torus.outer_radius - _torus.inner_radius) * 0.5
	half_height = half_width * absf(ring.scale.y)
