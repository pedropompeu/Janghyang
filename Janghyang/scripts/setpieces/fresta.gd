extends Node3D
## Night 1, the crack in the playroom's north wall (spec §6.2, §8.4, item 11;
## peek_model.gd). E held on it (player.gd's hold) puts the eye to it: the
## view moves to PEEK_AT, looking east down the passage, and the mouse turns
## it at most LOOK_MAX either way. The first look shows a Gasto crouched far
## off, barely lit; later ones only the dark, until SECOND_AFTER has passed and
## the director allows olho_fresta: then an eye right at the crack, once, that
## neither blinks nor draws back. After it, or with the panel broken, nothing.
## No sound in any of them. Whatever is shown goes when the look ends. Elias
## keeps his body: walking, a grab or the notebook end the look
## (player.release_hold). On a night that does not list it the wall has no
## crack: its resolved state.

const Peek = preload("res://scripts/peek_model.gd")
const Mannequin = preload("res://scripts/mannequin.gd")
const Gastos = preload("res://scripts/gastos.gd")
const KIND := &"olho_fresta"
const PANEL := &"achar_passagem"
## The crack's mark on the wall's playroom face (main.WALL_T 0.14 wide wall
## centred on z 0), west of the toy shelf (x 3.1 to 5.3), and its size.
const MARK_AT := Vector3(2.6, 1.1, 0.075)
const MARK_SIZE := Vector3(0.02, 0.25, 0.004)
## Where the eye goes, just behind the wall, and how far it may turn.
const PEEK_AT := Vector3(2.6, 1.0, -0.1)
const LOOK_MAX := deg_to_rad(15.0)
## He has to be this close to put his eye to it (m, from his eye).
const REACH := 1.3
const SHAPE_AT := Vector3(8.6, 0.0, -0.65)
const EYE_AWAY := 0.08
const EYE_R := 0.025

var main: Node
var def: Dictionary
var data: Dictionary

var model = Peek.new()
var camera: Camera3D
## What the look in progress shows (&"" when no look).
var showing := &""
var _active := false
var _clock := 0.0
var _yaw := 0.0
var _pitch := 0.0
var _body: StaticBody3D
var _shape: Node3D
var _shape_light: OmniLight3D
var _eye: Node3D

## The crack itself: what the player's ray hits and holds.
class Crack extends StaticBody3D:
	var piece
	func hold_begin() -> bool:
		return piece.hold_begin()
	func hold_end() -> void:
		piece.hold_end()
	func hold_look(rel: Vector2) -> void:
		piece.hold_look(rel)

func _ready() -> void:
	_build()

func on_night(night: Dictionary) -> void:
	if _body == null:
		_build()
	if showing != &"":
		main.player.release_hold()
	_active = night.get("setpieces", []).has(data.id)
	model = Peek.new()
	_clock = 0.0
	_body.visible = _active
	(_body.get_node("Shape") as CollisionShape3D).disabled = not _active
	_show(&"")

func _physics_process(delta: float) -> void:
	if _active:
		_clock += delta

func hold_begin() -> bool:
	if not _active or showing != &"":
		return false
	if main.player.camera.global_position.distance_to(MARK_AT) > REACH:
		return false
	var broken := _panel_broken()
	var allowed := false
	if model.eye_due(_clock, broken):
		allowed = main.dread.director.request(KIND, true, main.dread.tension)
	var what: StringName = model.look(_clock, allowed, broken)
	_yaw = 0.0
	_pitch = 0.0
	_aim()
	camera.make_current()
	_show(what)
	return true

func hold_end() -> void:
	if showing == &"":
		return
	_show(&"")
	main.player.camera.make_current()

func hold_look(rel: Vector2) -> void:
	_yaw = clampf(_yaw - rel.x, -LOOK_MAX, LOOK_MAX)
	_pitch = clampf(_pitch - rel.y, -LOOK_MAX, LOOK_MAX)
	_aim()

func _aim() -> void:
	camera.rotation = Vector3(_pitch, -PI / 2.0 + _yaw, 0.0)

func _show(what: StringName) -> void:
	showing = what
	_shape.visible = what == &"forma"
	_shape_light.visible = what == &"forma"
	_eye.visible = what == &"olho"

func _panel_broken() -> bool:
	var panel := main.find_child("HollowPanel", true, false)
	return main.step_done(PANEL) or (panel != null and panel.get("broken") == true)

func _build() -> void:
	_body = Crack.new()
	_body.name = "Crack"
	_body.piece = self
	_body.position = MARK_AT
	add_child(_body)
	var cs := CollisionShape3D.new()
	cs.name = "Shape"
	var box := BoxShape3D.new()
	box.size = Vector3(0.1, 0.32, 0.02)
	cs.shape = box
	_body.add_child(cs)
	var mark := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = MARK_SIZE
	mark.mesh = bm
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.03, 0.025, 0.02)
	dark.roughness = 1.0
	mark.material_override = dark
	_body.add_child(mark)

	camera = Camera3D.new()
	camera.name = "PeekCamera"
	camera.position = PEEK_AT
	camera.near = 0.01
	camera.far = 30.0
	camera.fov = 60.0
	add_child(camera)
	_aim()

	var m := Mannequin.new()
	m.name = "CrackShape"
	add_child(m)
	m.build(Gastos.STYLE, 1.0, &"gasto")
	m.position = SHAPE_AT
	m.set_pose(&"agachado")
	m.set_look(PI / 2.0, 0.0)
	_shape = m
	_shape_light = OmniLight3D.new()
	_shape_light.name = "CrackShapeLight"
	_shape_light.position = SHAPE_AT + Vector3(-0.6, 1.0, 0.3)
	_shape_light.light_color = Color(0.55, 0.6, 0.7)
	_shape_light.light_energy = 0.12
	_shape_light.omni_range = 1.8
	_shape_light.shadow_enabled = false
	add_child(_shape_light)

	_eye = Node3D.new()
	_eye.name = "CrackEye"
	_eye.position = PEEK_AT + Vector3(EYE_AWAY, 0.0, 0.0)
	add_child(_eye)
	var ball := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = EYE_R
	sm.height = EYE_R * 2.0
	ball.mesh = sm
	var porcelain := StandardMaterial3D.new()
	porcelain.albedo_color = Color(0.93, 0.91, 0.86)
	porcelain.roughness = 0.25
	porcelain.emission_enabled = true
	porcelain.emission = Color(0.93, 0.91, 0.86)
	porcelain.emission_energy_multiplier = 0.08
	ball.material_override = porcelain
	_eye.add_child(ball)
	var iris := MeshInstance3D.new()
	var im := SphereMesh.new()
	im.radius = EYE_R * 0.45
	im.height = EYE_R * 0.3
	iris.mesh = im
	var ink := StandardMaterial3D.new()
	ink.albedo_color = Color(0.12, 0.09, 0.07)
	ink.roughness = 0.4
	iris.material_override = ink
	iris.position = Vector3(-EYE_R * 0.93, 0.0, 0.0)
	iris.rotation.z = PI / 2.0
	_eye.add_child(iris)
	var leak := OmniLight3D.new()
	leak.name = "CrackLeak"
	leak.position = Vector3(-EYE_AWAY + 0.01, 0.0, 0.02)
	leak.light_color = Color(0.9, 0.8, 0.6)
	leak.light_energy = 0.35
	leak.omni_range = 0.25
	_eye.add_child(leak)
	_show(&"")
