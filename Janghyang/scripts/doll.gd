extends StaticBody3D
## The copy: lying on the bed, then sitting up. The player's touch is the trigger.

signal toggled(lying: bool)

var sit_rotation := Vector3(-1.3, 0.0, 0.0)
var sit_offset := Vector3(0.0, 0.25, 0.08)

## Small turns the doll takes between looks (set by the house, never in view).
const POSE_VARIANTS := [Vector3.ZERO, Vector3(0.0, 0.0, 0.45), Vector3(0.25, 0.0, -0.35)]

var _variant := Vector3.ZERO
var _rest_pos: Vector3
var _rest_rot: Vector3
var _lying := true
var _busy := false
var _double := false
var _pencil: Node3D
var _pencil_tween: Tween

func _ready() -> void:
	_rest_pos = position
	_rest_rot = rotation

func get_prompt() -> String:
	if _double:
		return ""
	return "sentar o boneco" if _lying else "deitar o boneco"

func interact() -> void:
	if _busy or _double:
		return
	_busy = true
	_lying = not _lying
	var target_pos := _rest_pos if _lying else _rest_pos + sit_offset
	var target_rot := _base_rotation() + _variant
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position", target_pos, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "rotation", target_rot, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func() -> void:
		_busy = false
		toggled.emit(_lying))

func is_lying() -> bool:
	return _lying

func set_pose_variant(i: int) -> void:
	if _double:
		return
	_variant = POSE_VARIANTS[posmod(i, POSE_VARIANTS.size())]
	if not _busy:
		rotation = _base_rotation() + _variant

func _base_rotation() -> Vector3:
	return _rest_rot if _lying else _rest_rot + sit_rotation

func is_double() -> bool:
	return _double

## 03:33: the doll is now the double, sitting on the entry bench facing north,
## a notebook on its knees and a pencil that keeps writing. Only ever called
## while neither the doll nor the bench is in view.
func become_double(seat: Vector3) -> void:
	if _double:
		return
	_double = true
	# The double is never in the way: no collision, no interaction ray.
	collision_layer = 0
	_lying = false
	_busy = false
	# The double sits on the bench, so the catalogue sees it seated (A-014).
	toggled.emit(false)
	position = seat
	rotation = Vector3(deg_to_rad(-8.0), 0.0, 0.0)
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color("#e9e1cc")
	paper.roughness = 0.95
	var book := MeshInstance3D.new()
	var book_mesh := BoxMesh.new()
	book_mesh.size = Vector3(0.2, 0.02, 0.26)
	book.mesh = book_mesh
	book.material_override = paper
	book.position = Vector3(0.0, 0.08, -0.2)
	book.rotation.x = deg_to_rad(-15.0)
	add_child(book)
	var graphite := StandardMaterial3D.new()
	graphite.albedo_color = Color("#3a3a3a")
	_pencil = Node3D.new()
	_pencil.position = Vector3(0.12, 0.12, -0.22)
	add_child(_pencil)
	var lead := MeshInstance3D.new()
	var lead_mesh := BoxMesh.new()
	lead_mesh.size = Vector3(0.012, 0.012, 0.14)
	lead.mesh = lead_mesh
	lead.material_override = graphite
	lead.rotation.x = deg_to_rad(35.0)
	_pencil.add_child(lead)
	_pencil_tween = create_tween().set_loops()
	_pencil_tween.tween_property(_pencil, "position:x", 0.04, 0.35).set_trans(Tween.TRANS_SINE)
	_pencil_tween.tween_property(_pencil, "position:x", 0.12, 0.35).set_trans(Tween.TRANS_SINE)

## The double stops mid-line (the clock was let stop).
func stop_writing() -> void:
	if _pencil_tween != null and _pencil_tween.is_valid():
		_pencil_tween.kill()
