extends Node
## 03:33. The house falls silent, Elias's echoes walk what the player did,
## and time slips back a little: the ball, a fold, the dust rising. Winding
## the clock ends it and the echoes stay where they stand.

const Echo = preload("res://scripts/echo.gd")
const CrackThing = preload("res://scripts/crack_thing.gd")
const Writer = preload("res://scripts/double_writer.gd")
## The entry bench, where the double sits facing north.
const DOUBLE_SEAT := Vector3(0.7, 0.45, 8.5)
const WRITE_AT := [6.0, 12.0, 18.0]
const FAR := 3.0
const MUTE_SECONDS := 2.0
const PHASE_STEP := 0.37
## Folds that can be undone, never F3 or a door. F1 keeps its own guard.
const UNDO_FOLDS := ["F1", "F2", "F4"]
const CRACK_COUNT := 3
## Floor corners the things from the cracks can sit in.
const CRACK_ANCHORS: Array[Vector3] = [
	Vector3(0.3, 0, 0.3), Vector3(8.1, 0, 0.3), Vector3(8.1, 0, 6.7), Vector3(0.3, 0, 6.7),
	Vector3(9.6, 0, 0.3), Vector3(15.1, 0, 0.3), Vector3(15.1, 0, 5.3), Vector3(13.0, 0, 8.9),
	Vector3(10.7, 0, 8.9), Vector3(6.5, 0, 8.9),
]

signal began
signal ended

## Set by main before add_child.
var main: Node
var echoes: Array[Node3D] = []
var crack_things: Array[Node3D] = []

var _active := false
var _hour_t := 0.0
var _to_write: Array[String] = []
var _double_pending := false

func is_active() -> bool:
	return _active

func begin() -> void:
	if _active:
		return
	_active = true
	_hour_t = 0.0
	_to_write = Writer.entries(main.recorder.stats())
	_double_pending = true
	main.sfx.set_casa_muted(true)
	get_tree().create_timer(MUTE_SECONDS).timeout.connect(func() -> void:
		main.sfx.set_casa_muted(false))
	var root: Node3D = main.get_node("Echoes")
	var segments: Array[Vector2i] = main.recorder.select_segments()
	for i in segments.size():
		var echo := Echo.new()
		echo.sfx = main.sfx
		echo.style = main.ELIAS_STYLE
		root.add_child(echo)
		echo.setup(main.recorder, segments[i], i * PHASE_STEP)
		echoes.append(echo)
	_turn_back_time()
	_show_crack_things()
	began.emit()

func end() -> void:
	if not _active:
		return
	_active = false
	# Whatever the double did not write yet is in the notebook all the same.
	while not _to_write.is_empty():
		_write_next()
	for echo in echoes:
		echo.freeze()
	for thing in crack_things:
		thing.deactivate()
	main.catalog.set_flag(&"after_hora", true)
	main.reveal_cabana_page()
	ended.emit()

## Elias left while the hour was still going: everything stops where it is,
## without the after-hour (no page, no giant, no more writing).
func halt() -> void:
	if not _active:
		return
	_active = false
	_double_pending = false
	for echo in echoes:
		if is_instance_valid(echo):
			echo.freeze()
	for thing in crack_things:
		if is_instance_valid(thing):
			thing.deactivate()

func _process(delta: float) -> void:
	if _double_pending:
		_try_double()
	if not _active:
		return
	_hour_t += delta
	var written := Writer.entries({}).size() - _to_write.size()
	if written < WRITE_AT.size() and _hour_t >= WRITE_AT[written]:
		_write_next()

## The doll becomes the double only when neither it nor the bench is in view.
## After 03:33 it keeps waiting for that, so it never moves in sight.
func _try_double() -> void:
	var doll: Node3D = main.get_node_or_null("Doll")
	if doll == null:
		_double_pending = false
		return
	if main.is_seen(doll.global_position + Vector3(0.0, 0.3, 0.0)) or main.is_seen(DOUBLE_SEAT + Vector3(0.0, 0.3, 0.0)):
		return
	doll.become_double(DOUBLE_SEAT)
	_double_pending = false

## The entry is always written; the pencil sounds only when the double is at
## the bench (A-015). The flush in end() follows the same rule.
func _write_next() -> void:
	var text: String = _to_write.pop_front()
	main.catalog.add_double_entries([text] as Array[String])
	if _double_sitting():
		main.sfx.play_pencil_pattern(DOUBLE_SEAT)

func _double_sitting() -> bool:
	var doll = main.get_node_or_null("Doll")
	return doll != null and doll.is_double()

func _show_crack_things() -> void:
	if crack_things.is_empty():
		for i in CRACK_COUNT:
			var thing := CrackThing.new()
			thing.name = "CrackThing%d" % (i + 1)
			thing.main = main
			thing.anchors = CRACK_ANCHORS
			thing.others = crack_things
			main.add_child(thing)
			crack_things.append(thing)
	for thing in crack_things:
		thing.activate()

func _turn_back_time() -> void:
	var ball := main.get_node_or_null("Ball")
	if ball != null:
		ball.roll_back()
	for n in UNDO_FOLDS:
		var f: Node3D = main.get_node_or_null(n)
		if f != null and f.is_at_b() and _flat_distance(f.global_position) >= FAR:
			f.interact()
			break
	_dust_rising()

## Grey dust drifting upward, a few metres ahead of the player.
func _dust_rising() -> void:
	var p := CPUParticles3D.new()
	p.name = "DustRising"
	var forward: Vector3 = -main.player.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized() if forward.length() > 0.01 else Vector3.FORWARD
	p.position = main.player.global_position + forward * (FAR + 0.5) + Vector3(0.0, 0.3, 0.0)
	p.amount = 40
	p.lifetime = 8.0
	p.one_shot = true
	p.explosiveness = 0.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(0.8, 0.2, 0.8)
	p.direction = Vector3.UP
	p.spread = 25.0
	p.initial_velocity_min = 0.02
	p.initial_velocity_max = 0.08
	p.gravity = Vector3(0.0, 0.05, 0.0)
	p.scale_amount_min = 0.01
	p.scale_amount_max = 0.025
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.6, 0.57)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	p.mesh = mesh
	main.add_child(p)
	p.emitting = true
	get_tree().create_timer(p.lifetime + 2.0).timeout.connect(p.queue_free)

func _flat_distance(p: Vector3) -> float:
	var q: Vector3 = main.player.global_position
	return Vector2(p.x - q.x, p.z - q.z).length()
