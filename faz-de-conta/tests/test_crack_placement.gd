extends RefCounted
const Crack = preload("res://scripts/crack_placement.gd")
var A: Array[Vector3] = [Vector3(0.3, 0, 0.3), Vector3(8.1, 0, 0.3), Vector3(2.0, 0, 8.6), Vector3(15.1, 0, 5.3)]
var never := func(_p): return false

func test_respects_distances(t) -> void:
	var i: int = Crack.pick(A, Vector3(1.0, 0, 1.0), -1, never)
	t.eq(i, 3, "farthest valid anchor")
	t.ok(A[i].distance_to(Vector3(1, 0, 1)) >= 4.0, "never near the player")

func test_never_near_door_or_current_or_seen(t) -> void:
	t.ok(Crack.pick(A, Vector3(14.0, 0, 5.0), -1, never) != 2, "never next to the front door")
	t.ok(Crack.pick(A, Vector3(1.0, 0, 1.0), 3, never) != 3, "always somewhere else")
	var seen_far := func(p): return p.x > 10.0
	t.ok(Crack.pick(A, Vector3(1.0, 0, 1.0), -1, seen_far) != 3, "never where the player is looking")

func test_hides_when_nothing_fits(t) -> void:
	t.eq(Crack.pick(A, Vector3(4.0, 0, 3.0), -1, func(_p): return true), -1, "hide instead of coming close")
