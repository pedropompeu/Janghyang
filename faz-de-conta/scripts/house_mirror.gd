extends Node
## Applies the MirrorBrain's answers to the house. It only ever repeats a
## gesture the player made, far from the player, and the doll only moves
## when nobody is looking.

const FAR := 3.0
const KNOCK_GAP := 0.4
const KNOCK_LATE := 0.2
const DOLL_UNSEEN := 5.0
const DOLL_EXPIRE := 30.0
## Wall surfaces inside the house the knocks can come from.
const KNOCK_POINTS := [
	Vector3(4.0, 1.3, 0.12), Vector3(9.4, 1.3, 0.12), Vector3(12.5, 1.3, 0.12),
	Vector3(15.28, 1.3, 0.8), Vector3(13.0, 1.3, 5.48), Vector3(13.2, 1.3, 8.0),
	Vector3(0.2, 1.3, 8.2), Vector3(6.0, 1.3, 7.6), Vector3(8.3, 1.3, 6.2),
]

## Set by main.
var main: Node

var _doll_pending := false
var _doll_unseen := 0.0
var _doll_age := 0.0
var _doll_variant := 0

## Returns whether the answer was applied now (or scheduled, for the doll).
## An answer that cannot be applied is dropped all the same.
func respond(r: Dictionary) -> bool:
	match r.get("verb", &""):
		&"dobrar":
			return _fold_back()
		&"bater":
			return _knock_back(int(r.get("count", 1)))
		&"rolar":
			var ball := main.get_node_or_null("Ball")
			if ball == null:
				return false
			var a := randf() * TAU
			ball.push(Vector3(cos(a), 0.0, sin(a)))
			return true
		&"boneco":
			_doll_pending = true
			_doll_unseen = 0.0
			_doll_age = 0.0
			return true
	return false

func _process(delta: float) -> void:
	if not _doll_pending:
		return
	_doll_age += delta
	var doll: Node3D = main.get_node_or_null("Doll")
	if doll == null or _doll_age >= DOLL_EXPIRE:
		_doll_pending = false
		return
	if main.is_seen(doll.global_position + Vector3(0.0, 0.2, 0.0)):
		_doll_unseen = 0.0
		return
	_doll_unseen += delta
	if _doll_unseen >= DOLL_UNSEEN:
		_doll_variant = (_doll_variant + 1) % 3
		doll.set_pose_variant(_doll_variant)
		_doll_pending = false

## F2 or F4, whichever is farther from the player, and only if 3 m away.
## Never F1, F3 or a door.
func _fold_back() -> bool:
	var best: Node3D = null
	var best_d := FAR
	for n in ["F2", "F4"]:
		var f: Node3D = main.get_node_or_null(n)
		if f == null:
			continue
		var d := _flat_distance(f.global_position)
		if d >= best_d:
			best = f
			best_d = d
	if best == null:
		return false
	best.interact()
	return true

func _knock_back(count: int) -> bool:
	var options: Array = KNOCK_POINTS.filter(func(p: Vector3) -> bool: return _flat_distance(p) >= FAR)
	if options.is_empty() or main.sfx == null:
		return false
	var point: Vector3 = options[randi() % options.size()]
	for i in count:
		var delay := i * KNOCK_GAP + (KNOCK_LATE if i == count - 1 and count > 1 else 0.0)
		if delay <= 0.0:
			main.sfx.play_at(&"knock", point)
		else:
			get_tree().create_timer(delay).timeout.connect(main.sfx.play_at.bind(&"knock", point))
	return true

func _flat_distance(p: Vector3) -> float:
	var q: Vector3 = main.player.global_position
	return Vector2(p.x - q.x, p.z - q.z).length()
