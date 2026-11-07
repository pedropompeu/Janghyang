extends RefCounted
const Rec = preload("res://scripts/echo_recorder.gd")
const Echo = preload("res://scripts/echo.gd")

func _line(r) -> void:
	for i in 1200:
		r.update(1.0 / 60.0, Vector3(i / 60.0, 0, 0), 0.0, 0.0, false)

func test_loops_inside_segment(t) -> void:
	var r = Rec.new(); _line(r)
	var e = Echo.new()
	e.load_window(r, Vector2i(0, 80))
	t.near(e.sample_at(0.0).pos.x, r.get_sample(0).pos.x, 0.001, "starts at the segment start")
	t.near(e.sample_at(8.0).pos.x, r.get_sample(0).pos.x, 0.001, "loops after 8 s")
	e.free()

func test_never_leaves_recorded_path(t) -> void:
	var r = Rec.new(); _line(r)
	var e = Echo.new()
	e.load_window(r, Vector2i(80, 160))
	for k in 100:
		var x: float = e.sample_at(k * 0.137).pos.x
		t.ok(x >= r.get_sample(80).pos.x - 0.001 and x <= r.get_sample(159).pos.x + 0.001, "echo stays on what the player did")
	e.free()

## A-013: the echo keeps the window it was given after the recorder drops its
## oldest samples (MAX_SAMPLES passed).
func test_echo_keeps_its_window_after_trim(t) -> void:
	var r = Rec.new()
	for i in 1000:
		r.update(0.1, Vector3(i * 0.01, 0, 0), 0.0, 0.0, false)
	var e = Echo.new()
	e.load_window(r, Vector2i(500, 580))
	var before: float = e.sample_at(2.0).pos.x
	for i in 18000:
		r.update(0.1, Vector3(10.0 + i * 0.01, 0, 0), 0.0, 0.0, false)
	t.near(e.sample_at(2.0).pos.x, before, 0.001, "echo keeps its window after the recorder trims")
	e.free()
