extends RefCounted
const WindClock = preload("res://scripts/wind_clock_model.gd")

func test_starts_full_at_three(t) -> void:
	var c = WindClock.new()
	t.near(c.spring, 600.0, 0.001, "starts wound")
	t.near(c.display_minutes(), 0.0, 0.001, "shows 03:00")

func test_wind_diminishes_to_floor(t) -> void:
	var c = WindClock.new()
	c.spring = 0.0
	t.near(c.wind(), 180.0, 0.001, "first wind 180")
	t.near(c.wind(), 126.0, 0.001, "second wind 126")
	t.near(c.wind(), 88.2, 0.01, "third wind 88.2")
	for i in 200:
		var got: float = c.wind()
		t.ok(got >= 15.0 - 0.001 or c.spring >= 600.0 - 0.001, "wind %d never below floor" % i)
		t.ok(c.spring <= 600.0 + 0.001, "spring never above max")

func test_stall_without_permission(t) -> void:
	var c = WindClock.new()
	var stopped := false
	for i in 2000:
		stopped = c.tick(1.0) or stopped
	t.ok(not stopped, "cannot stop while can_stop is false")
	t.near(c.spring, 5.0, 0.001, "stalls at STALL_SPRING")
	t.ok(not c.is_stopped(), "stalled is not stopped")

func test_stops_once_when_allowed(t) -> void:
	var c = WindClock.new()
	c.can_stop = true
	c.spring = 2.0
	t.ok(not c.tick(1.0), "still running after 1 s")
	t.ok(c.tick(1.5), "reports the stop")
	t.ok(not c.tick(1.0), "reports it only once")
	t.near(c.display_minutes(), 33.0, 0.001, "stopped shows 03:33")

func test_tick_desyncs_as_spring_runs_out(t) -> void:
	var c = WindClock.new()
	t.near(c.audio_tick_period(), 1.0, 0.001, "in sync when full")
	c.spring = 0.0
	t.near(c.audio_tick_period(), 1.25, 0.001, "late when empty")
