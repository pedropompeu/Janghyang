extends RefCounted
const Rec = preload("res://scripts/echo_recorder.gd")
const Echo = preload("res://scripts/echo.gd")

func _line(r) -> void:
	for i in 1200:
		r.update(1.0 / 60.0, Vector3(i / 60.0, 0, 0), 0.0, 0.0, false)

func test_loops_inside_segment(t) -> void:
	var r = Rec.new(); _line(r)
	var seg := Vector2i(0, 80)
	t.near(Echo.sample_at(r, seg, 0.0).pos.x, r.get_sample(0).pos.x, 0.001, "starts at the segment start")
	t.near(Echo.sample_at(r, seg, 8.0).pos.x, r.get_sample(0).pos.x, 0.001, "loops after 8 s")

func test_never_leaves_recorded_path(t) -> void:
	var r = Rec.new(); _line(r)
	var seg := Vector2i(80, 160)
	for k in 100:
		var x: float = Echo.sample_at(r, seg, k * 0.137).pos.x
		t.ok(x >= r.get_sample(80).pos.x - 0.001 and x <= r.get_sample(159).pos.x + 0.001, "echo stays on what the player did")
