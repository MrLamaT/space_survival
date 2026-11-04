class_name SeamlessPortal
extends Node3D

const PORTAL_LAYER := 20
const PORTAL_SHADER := """
shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D portal_texture : filter_linear, repeat_disable;

void fragment() {
    ALBEDO = texture(portal_texture, SCREEN_UV).rgb;
}
"""

@export var exit_portal: SeamlessPortal
@export var opening_size := Vector2(2.0, 3.0)
@export_range(0.25, 1.0, 0.05) var render_scale := 0.75

var _portal_view: SubViewport
var _portal_camera: Camera3D


func _ready() -> void:
	process_priority = 100

	_portal_view = SubViewport.new()
	_portal_view.size = Vector2i(16, 16)
	_portal_view.world_3d = get_world_3d()
	_portal_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_portal_view)

	_portal_camera = Camera3D.new()
	_portal_view.add_child(_portal_camera)
	_portal_camera.make_current()

	var quad := QuadMesh.new()
	quad.size = opening_size

	var shader := Shader.new()
	shader.code = PORTAL_SHADER

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("portal_texture", _portal_view.get_texture())

	var surface := MeshInstance3D.new()
	surface.mesh = quad
	surface.material_override = material
	surface.layers = 1 << (PORTAL_LAYER - 1)
	surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(surface)


func _process(_delta: float) -> void:
	var main_view := get_viewport()
	var main_camera := main_view.get_camera_3d()

	if main_camera == null or not is_instance_valid(exit_portal):
		_portal_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return

	var render_size := Vector2i(main_view.get_visible_rect().size * render_scale)
	render_size.x = maxi(16, render_size.x)
	render_size.y = maxi(16, render_size.y)
	if _portal_view.size != render_size:
		_portal_view.size = render_size

	var half_turn := Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	var passage := (
		exit_portal.global_transform
		* half_turn
		* global_transform.affine_inverse()
	)

	_portal_camera.global_transform = passage * main_camera.get_camera_transform()
	_portal_camera.keep_aspect = main_camera.keep_aspect
	_portal_camera.set_perspective(main_camera.fov, main_camera.near, main_camera.far)
	_portal_camera.cull_mask = main_camera.cull_mask
	_portal_camera.set_cull_mask_value(PORTAL_LAYER, false)
	_portal_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
