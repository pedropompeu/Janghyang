extends Node3D
## The bedroom mirror. It does not show the player: it shows Elias, standing
## where the player stood half a second ago. Only the mirror camera sees
## layer 11; the player's own camera never does.

const Mannequin = preload("res://scripts/mannequin.gd")

const REFLECTION_LAYER := 11
const GLASS_LAYER := 12
const DELAY := 0.5
## Front face of the mirror glass, facing -X into the bedroom.
const PLANE_X := 15.285
const CENTER := Vector3(15.285, 1.35, 2.0)
const SIZE := Vector2(1.0, 1.6)

## Set by main before add_child.
var main: Node
var style: Dictionary

var _viewport: SubViewport
var _camera: Camera3D
var _elias: Node3D
var _active := false

func _ready() -> void:
	_viewport = SubViewport.new()
	# Same aspect as the glass (1.0 x 1.6) so the image is not stretched.
	_viewport.size = Vector2i(320, 512)
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_FRUSTUM
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.size = SIZE.y
	_camera.far = 30.0
	_camera.cull_mask = 0xFFFFF & ~(1 << (GLASS_LAYER - 1))
	_viewport.add_child(_camera)

	var glass := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = SIZE
	glass.mesh = quad
	glass.position = CENTER
	glass.rotation.y = deg_to_rad(-90.0)
	glass.layers = 1 << (GLASS_LAYER - 1)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = _viewport.get_texture()
	mat.albedo_color = Color(0.86, 0.9, 0.92)
	# The camera looks back into the room: flip u so the image reads as a mirror.
	mat.uv1_scale = Vector3(-1.0, 1.0, 1.0)
	mat.uv1_offset = Vector3(1.0, 0.0, 0.0)
	glass.material_override = mat
	add_child(glass)

	_elias = Mannequin.new()
	_elias.build(style)
	_elias.set_render_layer(REFLECTION_LAYER)
	_elias.visible = false
	add_child(_elias)

func _process(_delta: float) -> void:
	var on: bool = main.in_bedroom(main.player.global_position)
	if on != _active:
		_active = on
		_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
		_elias.visible = on
	if not on:
		return
	var s: Dictionary = main.recorder.delayed(DELAY)
	if not s.is_empty():
		_elias.global_position = s.pos
		_elias.set_look(s.yaw, s.pitch)
		_elias.set_pose(&"agachado" if s.crouched else &"em_pe")
	var eye: Vector3 = main.player.camera.global_position
	var mirrored := Vector3(2.0 * PLANE_X - eye.x, eye.y, eye.z)
	# Looking from behind the glass toward -X; the near plane sits on the glass.
	_camera.global_transform = Transform3D(Basis(Vector3(0, 0, -1), Vector3(0, 1, 0), Vector3(1, 0, 0)), mirrored)
	_camera.near = maxf(0.05, mirrored.x - PLANE_X)
	_camera.frustum_offset = Vector2(eye.z - CENTER.z, CENTER.y - eye.y)
