extends RefCounted
const Breakable = preload("res://scripts/breakable.gd")

func test_breaks_after_enough_hits(t) -> void:
	var b = Breakable.new()
	b.hits_needed = 3
	t.eq(b.hit(), &"crack", "first: cracks")
	t.eq(b.hit(), &"crack", "second: cracks")
	t.eq(b.hit(), &"break", "third: breaks")
	t.ok(b.broken, "broken")
	t.eq(b.hit(), &"", "nothing left to hit")
	b.free()

func test_sound_by_kind(t) -> void:
	t.eq(Breakable.sound_for(&"oco", false), &"oco", "hollow knock")
	t.eq(Breakable.sound_for(&"vidro", true), &"glass", "glass shatters")
	t.eq(Breakable.sound_for(&"porcelana", true), &"shatter", "porcelain shatters")

## U31 (Review Focus 1): knocks after the wall gave way change nothing: no second
## break, no second signal, and the count stops at the knock that broke it.
func test_hits_after_break_change_nothing(t) -> void:
	var b = Breakable.new()
	b.hits_needed = 3
	var breaks := [0]
	b.shattered.connect(func() -> void: breaks[0] += 1)
	for i in 3:
		b.hit()
	var results: Array = []
	for i in 10:
		results.append(b.hit())
	t.ok(results.all(func(r): return r == &""), "ten more knocks return nothing")
	t.eq(b.hits, 3, "the count stops at the knock that broke it")
	t.eq(breaks[0], 1, "shattered is emitted once")
	t.ok(b.broken, "it stays broken")
	b.free()
