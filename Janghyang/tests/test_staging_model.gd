extends RefCounted
const Staging = preload("res://scripts/staging_model.gd")

func test_poses_advance_only_unseen(t) -> void:
	var s = Staging.new(4)
	t.ok(not s.update(5.0, true), "olhando, não anda")
	t.ok(not s.update(1.4, false), "1,4 s fora da vista, não")
	t.ok(s.update(0.2, false), "1,5 s fora da vista, anda")
	t.eq(s.pose, 1, "uma pose")

func test_staging_stops_at_the_last_pose(t) -> void:
	var s = Staging.new(4)
	var moved := 0
	for i in 10:
		if s.update(1.6, false):
			moved += 1
	t.eq(s.pose, 3, "para na última pose")
	t.eq(moved, 3, "anda três vezes e para")
	t.ok(s.done(), "terminou")

func test_a_look_restarts_the_count(t) -> void:
	var s = Staging.new(4)
	s.update(1.4, false)
	s.update(0.1, true)
	t.ok(not s.update(1.4, false), "olhar no meio zera a conta")
	t.ok(s.update(0.1, false), "1,5 s seguidos fora da vista")

func test_one_pose_is_done_from_the_start(t) -> void:
	var s = Staging.new(1)
	t.ok(s.done(), "uma pose só já está no fim")
	t.ok(not s.update(5.0, false), "e não anda")
