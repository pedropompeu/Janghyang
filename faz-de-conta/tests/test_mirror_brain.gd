extends RefCounted
const Brain = preload("res://scripts/mirror_brain.gd")

func _run(b, seconds: float) -> Array:
	var out := []
	for i in int(seconds * 10.0):
		var r: Dictionary = b.update(0.1)
		if not r.is_empty():
			out.append(r)
	return out

func test_waits_for_silence(t) -> void:
	var b = Brain.new()
	b.register(&"dobrar")
	t.eq(_run(b, 1.9).size(), 0, "no response within 2 s of the action")
	t.eq(_run(b, 0.3).size(), 1, "responds after silence")

func test_one_response_per_action(t) -> void:
	var b = Brain.new()
	b.register(&"dobrar")
	var got := _run(b, 50.0).filter(func(r): return not r.invite)
	t.eq(got.size(), 1, "one action, one response")

func test_cooldown_and_tie_break(t) -> void:
	var b = Brain.new()
	b.register(&"rolar"); b.register(&"dobrar")
	var got := _run(b, 6.0)
	t.eq(got[0].verb, &"dobrar", "tie goes to the most recent")
	t.eq(got.size(), 1, "cooldown holds the second response")
	t.eq(_run(b, 2.0)[0].verb, &"rolar", "second response after cooldown")

func test_knock_count(t) -> void:
	var b = Brain.new()
	for i in 3:
		b.register(&"bater"); _run(b, 0.3)
	var got := _run(b, 3.0)
	t.eq(got[0].count, 3, "house knocks back the same count")

func test_move_is_not_a_gesture_and_invite_once(t) -> void:
	var b = Brain.new()
	b.register(&"mover")
	t.eq(_run(b, 59.0).size(), 0, "moving is never answered")
	var inv := _run(b, 200.0)
	t.eq(inv.size(), 1, "idle invite happens once")
	t.ok(inv[0].invite and inv[0].verb == &"rolar", "invite is the ball")

func test_never_invents(t) -> void:
	var b = Brain.new()
	b.register(&"bater"); b.register(&"dobrar")
	for r in _run(b, 30.0):
		t.ok(r.verb in [&"bater", &"dobrar"] or r.invite, "only answers what the player did")
