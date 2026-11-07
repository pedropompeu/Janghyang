extends RefCounted
## The house records everything: the player's body at 10 Hz and what the hands
## did. Later the echoes replay the most telling windows of the visit.

const SAMPLE_HZ := 10.0
const MAX_SAMPLES := 18000
const SEGMENT_LEN := 8.0
const MAX_ECHOES := 6
const STILL_SPEED := 0.15

var _samples: Array[Dictionary] = []
var _acc := 0.0
var _pending := &""
var _crouched_s := 0.0
var _still_s := 0.0
var _meters := 0.0
var _actions := {}
var _last_pos = null

func update(dt: float, pos: Vector3, yaw: float, pitch: float, crouched: bool) -> void:
	_acc += dt
	var step := 1.0 / SAMPLE_HZ
	while _acc >= step - 0.000001:
		_acc -= step
		_push(pos, yaw, pitch, crouched)

## The next sample carries this verb.
func mark_action(verb: StringName) -> void:
	_pending = verb
	_actions[verb] = int(_actions.get(verb, 0)) + 1

func sample_count() -> int:
	return _samples.size()

func get_sample(i: int) -> Dictionary:
	return _samples[i]

## Where the player was `seconds` ago, or {} if the house has not seen that far.
func delayed(seconds: float) -> Dictionary:
	var i := _samples.size() - 1 - int(round(seconds * SAMPLE_HZ))
	if i < 0:
		return {}
	return _samples[i]

## The most telling 8 s windows, at most MAX_ECHOES, ordered by start.
## Windows are aligned from the oldest retained sample and never overlap.
func select_segments() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var len := int(SEGMENT_LEN * SAMPLE_HZ)
	if _samples.size() < len:
		return out
	var scored: Array = []
	var start := 0
	while start + len <= _samples.size():
		scored.append([_score(start, start + len), start])
		start += len
	scored.sort_custom(func(a, b) -> bool:
		return a[0] > b[0] or (a[0] == b[0] and a[1] < b[1]))
	for i in mini(MAX_ECHOES, scored.size()):
		out.append(Vector2i(scored[i][1], scored[i][1] + len))
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	return out

## Totals for the whole visit, not only the retained samples.
func stats() -> Dictionary:
	return {"crouched_s": _crouched_s, "still_s": _still_s, "meters": _meters, "actions": _actions.duplicate()}

func _push(pos: Vector3, yaw: float, pitch: float, crouched: bool) -> void:
	var moved := 0.0 if _last_pos == null else pos.distance_to(_last_pos)
	_last_pos = pos
	_meters += moved
	if crouched:
		_crouched_s += 1.0 / SAMPLE_HZ
	if moved * SAMPLE_HZ < STILL_SPEED:
		_still_s += 1.0 / SAMPLE_HZ
	_samples.append({"pos": pos, "yaw": yaw, "pitch": pitch, "crouched": crouched, "action": _pending})
	_pending = &""
	if _samples.size() > MAX_SAMPLES:
		_samples.pop_front()

func _score(from: int, to: int) -> float:
	var actions := 0
	var still := 0
	var crouched := 0
	var meters := 0.0
	for i in range(from, to):
		var s: Dictionary = _samples[i]
		if s.action != &"":
			actions += 1
		if s.crouched:
			crouched += 1
		var moved: float = 0.0 if i == from else s.pos.distance_to(_samples[i - 1].pos)
		meters += moved
		if moved * SAMPLE_HZ < STILL_SPEED:
			still += 1
	return 3.0 * actions + still / SAMPLE_HZ + 2.0 * crouched / SAMPLE_HZ + 0.5 * meters
