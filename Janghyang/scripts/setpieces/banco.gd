extends Node3D
## Night 1's bench (spec §6.2, §8.3, item 4; bench_model.gd): seven porcelain
## figures sit on it. Each time Elias leaves the figure room one is armed to
## leave; when neither its seat nor where it goes is in sight (and the place is
## legal: may_land) and the director allows a weak scare (figura_some), it is
## there instead. Every figure he is not looking at turns its head toward him,
## up to 70 degrees either way. Meshes only, no collision. On a night that does
## not list it the bench is empty: its resolved state.

const Bench = preload("res://scripts/bench_model.gd")
const Mannequin = preload("res://scripts/mannequin.gd")
const Gastos = preload("res://scripts/gastos.gd")
const ROOM := &"figuras"
const KIND := &"figura_some"
const SCALE := 1.02
const TURN := deg_to_rad(70.0)
## Where on a figure the eye is checked: about chest high.
const CHEST := 0.9

var main: Node
var def: Dictionary
var data: Dictionary

var model
var _active := false
var _figures: Array = []
var _was_in := false

func on_night(night: Dictionary) -> void:
	if _figures.is_empty():
		_build()
	_active = night.get("setpieces", []).has(data.id)
	model = Bench.new(def.bench.seats, def.bench.away, def.bench.get("face", Bench.SEAT_FACE))
	_was_in = false
	for i in _figures.size():
		_figures[i].visible = _active
		_place(i)

func figures() -> Array:
	return _figures

func _build() -> void:
	for i in Bench.N:
		var m := Mannequin.new()
		m.name = "BenchFigure_%d" % i
		add_child(m)
		m.build(Gastos.STYLE, SCALE, &"gasto")
		_figures.append(m)

func _base_yaw(i: int) -> float:
	var s: Dictionary = model.spots[i]
	var to: Vector3 = s.face - s.at
	return atan2(-to.x, -to.z)

func _place(i: int) -> void:
	var m = _figures[i]
	var s: Dictionary = model.spots[i]
	m.position = s.at
	m.set_pose(s.pose)
	m.set_seat(false)
	m.set_look(_base_yaw(i), 0.0)

func _chest(at: Vector3) -> Vector3:
	return at + Vector3(0.0, CHEST, 0.0)

func _hideouts() -> Array:
	var out := []
	for h in get_tree().get_nodes_in_group(&"Hideout"):
		for c in h.get_children():
			if c is CollisionShape3D and c.shape is BoxShape3D:
				var size: Vector3 = c.shape.size
				out.append(AABB(h.global_position - size * 0.5, size))
	return out

func _door() -> Vector3:
	var d: Node3D = main.get_node_or_null("DoorFront") as Node3D
	return d.global_position if d != null else Vector3(INF, 0.0, INF)

func _physics_process(_delta: float) -> void:
	if not _active or model == null:
		return
	var elias: Vector3 = main.player.global_position
	var inside: bool = main.atlas.room_at(elias) == ROOM
	if _was_in and not inside:
		model.on_leave_room()
	_was_in = inside
	_try_move(elias)
	_turn_heads(elias)

## The armed figure goes when both ends are out of sight and legal, and the
## director lets a weak scare through; refused, it tries again next tick.
func _try_move(elias: Vector3) -> void:
	var i: int = model.pending()
	if i < 0:
		return
	var to: Dictionary = model.target_of(i)
	var from: Vector3 = model.spots[i].at
	var hides := _hideouts()
	var door := _door()
	if not Bench.may_land(from, elias, hides, door, main.is_seen(_chest(from))):
		return
	if not Bench.may_land(to.at, elias, hides, door, main.is_seen(_chest(to.at))):
		return
	if not main.dread.director.request(KIND, false, main.dread.tension):
		return
	model.move(i)
	_place(i)

func _turn_heads(elias: Vector3) -> void:
	for i in _figures.size():
		var m = _figures[i]
		if main.is_seen(_chest(m.global_position)):
			continue
		var to: Vector3 = elias - m.global_position
		var want := atan2(-to.x, -to.z)
		var base := _base_yaw(i)
		m.set_look(base + clampf(wrapf(want - base, -PI, PI), -TURN, TURN), 0.0)
