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
