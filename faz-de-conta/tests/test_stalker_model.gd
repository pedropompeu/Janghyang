extends RefCounted
const Stalker = preload("res://scripts/stalker_model.gd")

## A straight line of five lurk points, 4 m apart.
func _line() -> Stalker:
	var pts: Array[Vector3] = []
	for i in 5:
		pts.append(Vector3(i * 4.0, 0.0, 0.0))
	var s := Stalker.new(pts, [[1], [0, 2], [1, 3], [2, 4], [3]])
	s.place(0)
	return s

## Ticks until something happens; the player stands at `goal`.
func _run(s: Stalker, seconds: float, goal: int, seen := false, blind := false, near := false, hidden := false, in_view: Array = []) -> StringName:
	var t := 0.0
	while t < seconds:
		var ev: StringName = s.update(0.1, seen, blind, goal, near, hidden, in_view)
		if ev != &"":
			return ev
		t += 0.1
	return &""

func test_hops_one_point_toward_the_player(t) -> void:
	var s := _line()
	t.eq(_run(s, Stalker.STEP_TIME + 0.2, 4), &"moved", "unseen, it hops")
	t.eq(s.at, 1, "one point closer")

func test_never_moves_while_seen(t) -> void:
	var s := _line()
	t.eq(_run(s, Stalker.STARE_TIME - 0.3, 4, true), &"", "seen: frozen")
	t.eq(s.at, 0, "stays put")

func test_long_stare_undoes_it(t) -> void:
	var s := _line()
	t.eq(_run(s, Stalker.STARE_TIME + 0.3, 4, true), &"undone", "stared at: it comes apart")
	t.eq(s.at, -1, "gone from the world")

func test_blind_is_faster(t) -> void:
	var s := _line()
	t.eq(_run(s, Stalker.STEP_TIME_BLIND + 0.2, 4, false, true), &"moved", "eyes closed: hops sooner")

func test_never_hops_into_view(t) -> void:
	var s := _line()
	t.eq(_run(s, Stalker.STEP_TIME * 3.0, 4, false, false, false, false, [1]), &"", "the next point is in view: waits")
	t.eq(s.at, 0, "still at the start")

func test_catches_when_near_and_unseen(t) -> void:
	var s := _line()
	s.place(3)
	t.eq(_run(s, Stalker.STEP_TIME + 0.2, 4, false, false, true), &"caught", "near, unseen: the hug")

func test_hidden_player_makes_it_give_up(t) -> void:
	var s := _line()
	s.place(3)
	t.eq(_run(s, Stalker.HIDE_GIVE_UP + Stalker.STEP_TIME + 1.0, 4, false, false, true, true), &"gave_up", "hidden: it leaves")
	t.eq(s.at, -1, "gone")

func test_hit_sends_it_away_then_it_returns_far(t) -> void:
	var s := _line()
	s.place(3)
	s.hit()
	t.eq(s.at, -1, "struck: gone")
	t.eq(_run(s, Stalker.RETURN_TIME - 1.0, 4), &"", "away for a while")
	t.eq(_run(s, 2.0, 4), &"returned", "then back")
	t.eq(s.at, 0, "at the point farthest from the player")

func test_return_avoids_points_in_view(t) -> void:
	var s := _line()
	s.hit()
	_run(s, Stalker.RETURN_TIME + 1.0, 4, false, false, false, false, [0])
	t.eq(s.at, 1, "farthest point not in view")

func test_next_toward_follows_links(t) -> void:
	var s := _line()
	t.eq(s.next_toward(0, 3), 1, "first step on the path")
	t.eq(s.next_toward(2, 2), 2, "already there")

func test_send_away_comes_back_later_far(t) -> void:
	var s := _line()
	s.place(3)
	s.send_away(6.0)
	t.ok(s.is_away(), "gone while Elias changes floors")
	t.eq(_run(s, 5.0, 4), &"", "not back yet")
	t.eq(_run(s, 2.0, 4), &"returned", "back after the given time")
	t.eq(s.at, 0, "far from him")
