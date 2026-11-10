extends RefCounted
## A chapter's staged scene (spec §6.1): the area's figures go through a few
## discrete poses, like automata, and only while Elias is not looking. Each
## UNSEEN seconds in a row out of sight they take the next pose; a look
## starts the count again; they stop on the last one.

const UNSEEN := 1.5
## How near Elias (feet, flat) a figure may not appear: his capsule plus a
## body. A pose that would put one closer waits until he steps away.
const CLEAR := 0.6

var poses := 1
var pose := 0
var _unseen := 0.0

func _init(n: int = 1) -> void:
	poses = maxi(n, 1)

## True on the tick the figures take the next pose.
func update(dt: float, seen: bool) -> bool:
	if done():
		return false
	if seen:
		_unseen = 0.0
		return false
	_unseen += dt
	if _unseen < UNSEEN:
		return false
	_unseen = 0.0
	pose += 1
	return true

func done() -> bool:
	return pose >= poses - 1

## True when none of the spots (a pose's figure positions) is within CLEAR of
## `at`, on the floor plane.
static func clear_of(spots: Array, at: Vector3) -> bool:
	for p in spots:
		if Vector2(p.x - at.x, p.z - at.z).length() < CLEAR:
			return false
	return true
