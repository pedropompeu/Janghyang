extends RefCounted
## Where a thing from the cracks may be: out of sight, far from the player,
## away from the front door, and never where it already was.

const MIN_PLAYER_DIST := 4.0
const MIN_DOOR_DIST := 2.5
const FRONT_DOOR := Vector3(1.82, 0.0, 9.1)

## Index of the valid anchor farthest from the player, or -1 to hide.
static func pick(anchors: Array[Vector3], player_pos: Vector3, current: int, seen: Callable) -> int:
	var best := -1
	var best_d := -1.0
	for i in anchors.size():
		if i == current:
			continue
		var a := anchors[i]
		var d := _flat(a, player_pos)
		if d < MIN_PLAYER_DIST or _flat(a, FRONT_DOOR) < MIN_DOOR_DIST:
			continue
		if seen.call(a):
			continue
		if d > best_d:
			best = i
			best_d = d
	return best

static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
