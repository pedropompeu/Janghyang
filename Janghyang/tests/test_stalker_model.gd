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

## U30 (Review Focus 3): on a connected graph every lurk point walks back to
## every goal, one hop at a time, within the number of points.
## A 3x3 grid, 1 m apart, each point linked to its four neighbours.
func _grid() -> Stalker:
	var pts: Array[Vector3] = []
	var lnk: Array = []
	for i in 9:
		pts.append(Vector3(i % 3, 0.0, int(i / 3.0)))
	for i in 9:
		var x: int = i % 3
		var z: int = int(i / 3.0)
		var l: Array = []
		if x > 0: l.append(i - 1)
		if x < 2: l.append(i + 1)
		if z > 0: l.append(i - 3)
		if z < 2: l.append(i + 3)
		lnk.append(l)
	return Stalker.new(pts, lnk)

func _walks_to(s: Stalker, from: int, goal: int) -> bool:
	var p := from
	for step in s.points.size():
		if p == goal:
			return true
		var nxt: int = s.next_toward(p, goal)
		if nxt == p:
			return false
		p = nxt
	return p == goal

func test_every_lurk_point_walks_back_to_every_goal(t) -> void:
	var s := _grid()
	var stuck := 0
	for from in s.points.size():
		for goal in s.points.size():
			if not _walks_to(s, from, goal):
				stuck += 1
	t.eq(stuck, 0, "no lurk point is stuck on the grid")

func test_cut_off_point_stays_put(t) -> void:
	var pts: Array[Vector3] = [Vector3(0.0, 0.0, 0.0), Vector3(9.0, 0.0, 0.0)]
	var s := Stalker.new(pts, [[], []])
	t.eq(s.next_toward(0, 1), 0, "no way back: it stays where it is, never wanders")

func test_never_hops_onto_a_safe_point(t) -> void:
	var pts: Array[Vector3] = [Vector3.ZERO, Vector3(4, 0, 0), Vector3(8, 0, 0)]
	var s := Stalker.new(pts, [[1], [0, 2], [1]])
	s.place(0)
	var moved := false
	for i in 200:
		moved = moved or s.update(0.1, false, false, 2, false, false, [], [1]) == &"moved"
	t.ok(not moved, "a safe point in the way: it waits")
	t.eq(s.at, 0, "still at the start")

func test_never_hops_onto_a_safe_goal(t) -> void:
	# Elias stands on a safe point right next to it: the way there is open,
	# but the last hop is not.
	var pts: Array[Vector3] = [Vector3.ZERO, Vector3(4, 0, 0), Vector3(8, 0, 0)]
	var s := Stalker.new(pts, [[1], [0, 2], [1]])
	s.place(1)
	var moved := false
	for i in 200:
		moved = moved or s.update(0.1, false, false, 2, false, false, [], [2]) == &"moved"
	t.ok(not moved and s.at == 1, "the safe goal next door: it stays put")

func test_never_returns_onto_a_safe_point(t) -> void:
	var s := _line()
	s.hit()
	_run(s, Stalker.RETURN_TIME + 1.0, 4)
	s.hit()
	var ev: StringName = &""
	for i in int((Stalker.RETURN_TIME + 1.0) / 0.1):
		ev = s.update(0.1, false, false, 4, false, false, [], [0, 1])
		if ev != &"":
			break
	t.eq(ev, &"returned", "back again")
	t.eq(s.at, 2, "the farthest point that is not safe")

func test_never_catches_a_safe_elias(t) -> void:
	var s := _line()
	s.place(3)
	var hugged := false
	for i in 200:
		hugged = hugged or s.update(0.1, false, false, 4, true, false, [], [], true) == &"caught"
	t.ok(not hugged, "safe: no hug")
	t.eq(s.at, 3, "it stays where it is")
	t.eq(_run(s, Stalker.STEP_TIME + 0.2, 4, false, false, true), &"caught", "no longer safe: the hug")

func test_goes_around_a_safe_point(t) -> void:
	var pts: Array[Vector3] = [Vector3.ZERO, Vector3(4, 0, 0), Vector3(0, 0, 4), Vector3(4, 0, 4)]
	var s := Stalker.new(pts, [[1, 2], [0, 3], [0, 3], [1, 2]])
	t.eq(s.next_toward(0, 3, [1]), 2, "the dark way round")
	t.eq(s.next_toward(0, 3, [1, 2]), 0, "no way round: it waits")
	s.place(0)
	t.eq(_run_safe(s, Stalker.STEP_TIME + 0.2, 3, [1]), &"moved", "it hops the other way")
	t.eq(s.at, 2, "onto the point that is not safe")

func _run_safe(s: Stalker, seconds: float, goal: int, safe: Array) -> StringName:
	var t := 0.0
	while t < seconds:
		var ev: StringName = s.update(0.1, false, false, goal, false, false, [], safe)
		if ev != &"":
			return ev
		t += 0.1
	return &""

## Ticks with Elias hidden and near; `breath`: he holds it the whole time.
func _run_hidden(s: Stalker, seconds: float, breath: bool) -> Array:
	var evs: Array = []
	var t := 0.0
	while t < seconds - 0.0001:
		var ev: StringName = s.update(0.1, false, false, 4, true, true, [], [], false, breath)
		if ev != &"":
			evs.append([ev, t + 0.1])
		t += 0.1
	return evs

func test_hidden_without_breath_is_found(t) -> void:
	var s := _line()
	s.place(3)
	t.eq(_run_hidden(s, Stalker.HIDE_FOUND - 0.2, false), [], "antes de HIDE_FOUND, nada")
	var evs := _run_hidden(s, 0.4, false)
	t.eq(evs.size(), 1, "um evento")
	t.eq(evs[0][0] if evs.size() > 0 else &"", &"caught", "sem prender a respiração: achado")

func test_hidden_with_breath_waits_and_gives_up(t) -> void:
	var s := _line()
	s.place(3)
	var evs := _run_hidden(s, Stalker.HIDE_GIVE_UP + Stalker.STEP_TIME + 1.0, true)
	t.eq(evs.size(), 1, "um evento só")
	t.eq(evs[0][0] if evs.size() > 0 else &"", &"gave_up", "prendendo a respiração: desiste")
	t.ok(evs.size() > 0 and evs[0][1] >= Stalker.HIDE_GIVE_UP, "não antes de HIDE_GIVE_UP")
	t.eq(s.at, -1, "foi embora")

func test_letting_breath_go_restarts_the_search(t) -> void:
	var s := _line()
	s.place(3)
	t.eq(_run_hidden(s, 2.0, false), [], "2 s sem prender: ainda não")
	t.eq(_run_hidden(s, 2.0, true), [], "prender a respiração zera a busca")
	t.eq(_run_hidden(s, Stalker.HIDE_FOUND - 0.2, false), [], "soltar recomeça a conta do zero")
