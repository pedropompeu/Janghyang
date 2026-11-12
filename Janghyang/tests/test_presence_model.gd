extends RefCounted
## Noite 1, Tarefa 13 (§6.2, item 5): o que se arrasta atrás da parede da sala de brincar.
const Presence = preload("res://scripts/presence_model.gd")

func test_drag_only_while_listening(t) -> void:
	var p = Presence.new()
	var r: Dictionary = p.update(1.0, false, 3.0)
	t.ok(not r.drag, "sem escutar, não arrasta")
	t.eq(r.x, 8.6, "e não sai do lugar")
	r = p.update(1.0, true, 3.0)
	t.ok(r.drag, "escutando, arrasta")
	t.ok(absf(r.x - 8.35) < 0.0001, "e anda 0,25 m em 1 s")

func test_it_crawls_toward_the_ear_and_stops_short(t) -> void:
	var p = Presence.new()
	var r: Dictionary = {}
	for i in 600:
		r = p.update(0.1, true, 3.0)
	t.ok(absf(r.x - 4.0) < 0.0001, "para a 1 m da orelha (%.3f)" % r.x)
	t.ok(not r.drag, "parado, não há o que arrastar")

func test_it_stays_inside_the_passage(t) -> void:
	var p = Presence.new()
	var r: Dictionary = {}
	for i in 600:
		r = p.update(0.1, true, -5.0)
	t.ok(r.x >= Presence.X_MIN - 0.0001, "não passa do fim oeste da passagem")

func test_silent_after_the_panel(t) -> void:
	var p = Presence.new()
	p.update(1.0, true, 3.0)
	p.stop()
	for i in 20:
		t.ok(not p.update(0.5, true, 3.0).drag, "depois do painel, nunca mais arrasta")
