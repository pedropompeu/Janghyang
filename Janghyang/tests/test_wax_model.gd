extends RefCounted
const Wax = preload("res://scripts/wax_model.gd")

func test_only_a_flame_shows_it(t) -> void:
	var at := Vector3(14.7, 1.5, 0.06)
	t.ok(not Wax.shows([], at), "no flame, blank paper")
	t.ok(Wax.shows([Vector3(14.6, 1.2, 1.0)], at), "a match in the hand")
	t.ok(not Wax.shows([Vector3(11.0, 0.3, 5.0)], at), "the candle across the room is too far")
	t.eq(Wax.REVEAL, 2.5, "REVEAL 2,5 m")
	t.ok(Wax.shows([at + Vector3(0.0, 0.0, Wax.REVEAL)], at), "exactly at REVEAL still shows")

func test_box_refills_while_the_drawing_is_missing(t) -> void:   # Review Focus 1
	t.ok(Wax.refill_due(0, false, false, false, false), "out of flame, unseen: one more match")
	t.ok(not Wax.refill_due(0, false, false, false, true), "never while he looks at the box")
	t.ok(not Wax.refill_due(1, false, false, false, false), "he still has one")
	t.ok(not Wax.refill_due(0, true, false, false, false), "a candle burns by the drawing")
	t.ok(not Wax.refill_due(0, false, true, false, false), "already in the notebook")
	t.ok(not Wax.refill_due(0, false, false, true, false), "the box is not empty")
