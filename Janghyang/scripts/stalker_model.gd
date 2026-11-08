extends RefCounted
## A Gasto's mind, as pure state. It lives on a graph of lurk points (door
## frames, corners, the far end of corridors) and only ever moves while nobody
## looks: one point closer to Elias per hop, never onto a point he can see.
## Looked at, it freezes; looked at long enough in light, it comes apart and
## stays away for a while. Near and unseen, it hugs him; if he hides, it waits
## and then gives up.

const STEP_TIME := 5.0
## Eyes closed or no light: it does not wait for long.
const STEP_TIME_BLIND := 1.2
const STARE_TIME := 3.5
const RETURN_TIME := 25.0
const HIDE_GIVE_UP := 8.0

var points: Array[Vector3] = []
var links: Array = []
## The point it stands on, or -1 while it is away.
var at := -1
## The point it came from on its last hop (for placing it out of reach).
var came_from := -1
var stare := 0.0
var _clock := 0.0
var _away := 0.0
var _hidden_for := 0.0

func _init(pts: Array[Vector3], lnk: Array) -> void:
	points = pts
	links = lnk

func place(i: int) -> void:
	at = i
	came_from = i
	_clock = 0.0
	stare = 0.0
	_hidden_for = 0.0

## Struck by the stick: it comes apart at once.
func hit() -> void:
	_undo()

## Gone for `seconds` (Elias changed floors); then back, far from him.
func send_away(seconds: float) -> void:
	_undo()
	_away = seconds

func is_away() -> bool:
	return at < 0

## One tick. `seen`: in Elias's view and lit. `blind`: his eyes are closed or
## the dark is total. `goal`: the point nearest Elias. `near`: within reach.
## `hidden`: crouched inside a hiding place. `in_view`: points he can see now.
## `safe`: points it must never step onto (safety_model.gd); `elias_safe`:
## Elias stands where it cannot reach him, so it never hugs him there.
## Returns &"moved", &"caught", &"undone", &"gave_up", &"returned" or &"".
func update(dt: float, seen: bool, blind: bool, goal: int, near: bool, hidden: bool, in_view: Array, safe: Array = [], elias_safe := false) -> StringName:
	if at < 0:
		_away -= dt
		if _away > 0.0:
			return &""
		var back := _farthest_from(goal, in_view, safe)
		if back < 0:
			return &""
		place(back)
		return &"returned"
	if seen:
		stare += dt
		_clock = 0.0
		if stare >= STARE_TIME:
			_undo()
			return &"undone"
		return &""
	stare = maxf(0.0, stare - dt)
	_clock += dt
	var interval := STEP_TIME_BLIND if blind else STEP_TIME
	if _clock < interval - 0.0001:
		return &""
	_clock = 0.0
	if near:
		if elias_safe:
			_hidden_for = 0.0
			return &""
		if not hidden:
			return &"caught"
		_hidden_for += interval
		if _hidden_for >= HIDE_GIVE_UP:
			_undo()
			return &"gave_up"
		return &""
	_hidden_for = 0.0
	var step := next_toward(at, goal, safe)
	if step == at or in_view.has(step) or safe.has(step):
		return &""
	came_from = at
	at = step
	return &"moved"

## The first point on the shortest path from `from` to `goal` (or `from`),
## going around the `safe` points it may not step onto.
func next_toward(from: int, goal: int, safe: Array = []) -> int:
	if from == goal or from < 0 or goal < 0:
		return from
	var dist := _distances(goal, safe)
	var best := from
	for n in links[from]:
		if dist[n] >= 0 and (best == from or dist[n] < dist[best]):
			best = n
	if dist[best] < 0 or (best != from and dist[best] >= dist[from] and dist[from] >= 0):
		return from
	return best

func _undo() -> void:
	at = -1
	came_from = -1
	stare = 0.0
	_clock = 0.0
	_hidden_for = 0.0
	_away = RETURN_TIME

func _farthest_from(goal: int, in_view: Array, safe: Array = []) -> int:
	var dist := _distances(goal) if goal >= 0 else []
	var best := -1
	var best_d := -1
	for i in points.size():
		if in_view.has(i) or safe.has(i):
			continue
		var d: int = dist[i] if goal >= 0 else 0
		if d > best_d:
			best_d = d
			best = i
	return best

## Hops from every point to `goal`; -1 where it cannot be reached. The path
## never passes through a `blocked` point (the goal itself may be one).
func _distances(goal: int, blocked: Array = []) -> Array:
	var dist := []
	dist.resize(points.size())
	dist.fill(-1)
	dist[goal] = 0
	var queue := [goal]
	while not queue.is_empty():
		var p: int = queue.pop_front()
		for n in links[p]:
			if dist[n] < 0 and not blocked.has(n):
				dist[n] = dist[p] + 1
				queue.append(n)
	return dist
