extends RefCounted
## When a playtester is lost (playtest 1, U50): LOST_AFTER seconds on the
## same goal without coming PROGRESS metres closer to it than their best.
## Told once; coming closer, or a new goal, starts the count over.

const LOST_AFTER := 180.0
const PROGRESS := 2.0

var _goal: StringName = &""
var _best := INF
var _since := 0.0
var _lost := false

## True only on the tick the count reaches LOST_AFTER.
func update(dt: float, goal_distance: float, goal_id: StringName) -> bool:
	if goal_id == &"":
		_goal = &""
		_lost = false
		return false
	if goal_id != _goal:
		_goal = goal_id
		_best = goal_distance
		_since = 0.0
		_lost = false
	elif goal_distance <= _best - PROGRESS:
		_best = goal_distance
		_since = 0.0
		_lost = false
		return false
	_since += dt
	if not _lost and _since >= LOST_AFTER:
		_lost = true
		return true
	return false

func is_lost() -> bool:
	return _lost
