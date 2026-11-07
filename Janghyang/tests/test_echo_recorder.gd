extends RefCounted
const Rec = preload("res://scripts/echo_recorder.gd")

func _feed(r, seconds: float, pos: Vector3, crouched := false, step := Vector3.ZERO) -> void:
	var n := int(seconds * 60.0)
	for i in n:
		pos += step / 60.0
		r.update(1.0 / 60.0, pos, 0.0, 0.0, crouched)

func test_samples_at_10hz(t) -> void:
	var r = Rec.new()
	_feed(r, 1.0, Vector3.ZERO)
	t.eq(r.sample_count(), 10, "one second = 10 samples")

func test_cap_and_segments_in_range(t) -> void:
	var r = Rec.new()
	_feed(r, 2000.0, Vector3.ZERO, false, Vector3(0.5, 0, 0))
	t.eq(r.sample_count(), Rec.MAX_SAMPLES, "recorder respects the cap")
	for seg in r.select_segments():
		t.ok(seg.x >= 0 and seg.y <= r.sample_count() and seg.y - seg.x == 80, "segment inside retained samples")

func test_segments_limit_and_no_overlap(t) -> void:
	var r = Rec.new()
	_feed(r, 120.0, Vector3.ZERO, false, Vector3(1, 0, 0))
	var segs: Array[Vector2i] = r.select_segments()
	t.ok(segs.size() <= Rec.MAX_ECHOES, "at most 6 echoes")
	for i in range(1, segs.size()):
		t.ok(segs[i].x >= segs[i - 1].y, "segments do not overlap")

func test_crouch_and_actions_win(t) -> void:
	var r = Rec.new()
	_feed(r, 8.0, Vector3.ZERO)          # parado em pé
	_feed(r, 8.0, Vector3.ZERO, true)    # agachado
	for i in 6:
		r.mark_action(&"dobrar")
		_feed(r, 8.0 / 6.0, Vector3(5, 0, 0))
	var segs: Array[Vector2i] = r.select_segments()
	t.ok(segs.has(Vector2i(80, 160)), "crouched window chosen")
	t.ok(segs.has(Vector2i(160, 240)), "action window chosen")
	t.eq(r.stats().actions.get(&"dobrar", 0), 6, "actions counted")

func test_delayed(t) -> void:
	var r = Rec.new()
	_feed(r, 2.0, Vector3.ZERO, false, Vector3(1, 0, 0))
	var d: Dictionary = r.delayed(0.5)
	t.near(d.pos.x, r.get_sample(r.sample_count() - 6).pos.x, 0.001, "delayed picks the sample 0.5 s back")
	t.ok(Rec.new().delayed(0.5).is_empty(), "empty recorder has nothing delayed")
