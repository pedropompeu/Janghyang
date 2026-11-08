extends RefCounted
const Capture = preload("res://scripts/capture_model.gd")

func test_ten_clicks_in_four_seconds_break_free(t) -> void:
	var c = Capture.new(10)
	t.ok(c.grab(0), "agarra")
	t.eq(c.state, Capture.State.GRABBED, "agarrado")
	var evs: Array = []
	for i in 10:
		c.push()
		evs.append(c.update(0.3, false))
	t.eq(evs.count(&"broke_free"), 1, "soltou uma vez com 10 cliques em 3 s")
	t.eq(evs[9], &"broke_free", "no décimo clique")
	t.eq(c.update(0.0, false), &"", "o aviso não se repete")
	t.eq(c.state, Capture.State.BROKE_FREE, "cambaleando")

func test_too_few_clicks_end_in_a_hug(t) -> void:
	var c = Capture.new(10)
	c.grab(0)
	for i in 9:
		c.push()
	t.eq(c.update(3.99, false), &"", "ainda luta antes dos 4 s")
	t.eq(c.update(0.02, false), &"hug", "9 cliques e 4 s: abraço")
	t.eq(c.state, Capture.State.HUG, "abraço")
	t.eq(c.update(0.1, false), &"", "o abraço se avisa uma vez")

func test_second_grab_is_ignored(t) -> void:
	var c = Capture.new(10)
	c.grab(0)
	t.ok(not c.grab(1), "uma luta só")
	t.eq(c.gasto, 0, "o primeiro Gasto fica")

func test_clicks_count_only_while_grabbed(t) -> void:
	var c = Capture.new(3)
	for i in 5:
		c.push()
	c.grab(0)
	t.eq(c.update(0.1, false), &"", "cliques de antes não contam")
	t.eq(c.progress(), 0.0, "progresso zero")
	c.push()
	t.ok(absf(c.progress() - 1.0 / 3.0) < 0.001, "um terço")

func test_hold_mode_breaks_free_by_holding(t) -> void:
	var c = Capture.new(16, true)
	c.grab(0)
	t.eq(c.update(2.6, true), &"broke_free", "segurar 2,5 s solta")

func test_hold_mode_needs_a_steady_hold(t) -> void:
	var c = Capture.new(16, true)
	c.grab(0)
	c.update(2.0, true)
	t.ok(c.progress() > 0.7, "quase")
	c.update(0.1, false)
	t.eq(c.progress(), 0.0, "soltar o botão recomeça")
	t.eq(c.update(1.95, true), &"hug", "sem tempo para segurar de novo: abraço")

func test_stagger_returns_to_free(t) -> void:
	var c = Capture.new(1)
	c.grab(0)
	c.push()
	t.eq(c.update(0.1, false), &"broke_free", "solta")
	t.ok(not c.grab(1), "cambaleando, ninguém agarra")
	c.update(Capture.STAGGER - 0.05, false)
	t.eq(c.state, Capture.State.BROKE_FREE, "ainda cambaleia")
	c.update(0.1, false)
	t.eq(c.state, Capture.State.FREE, "livre depois do STAGGER")
	t.eq(c.gasto, -1, "sem Gasto")
	t.ok(c.grab(1), "pode ser agarrado de novo")

func test_hug_also_returns_to_free(t) -> void:
	var c = Capture.new(10)
	c.grab(2)
	c.update(Capture.WINDOW + 0.01, false)
	c.update(Capture.STAGGER + 0.01, false)
	t.eq(c.state, Capture.State.FREE, "depois do abraço, livre")

func test_holding_counts_nothing_in_click_mode(t) -> void:
	var c = Capture.new(10)
	c.grab(0)
	t.eq(c.update(3.0, true), &"", "segurar sem a opção não solta")
	t.eq(c.progress(), 0.0, "nem conta como progresso")
	t.eq(c.update(1.01, true), &"hug", "e o tempo acaba em abraço")
