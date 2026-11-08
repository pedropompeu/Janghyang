extends RefCounted
const Hands = preload("res://scripts/hands_model.gd")

func test_watch_takes_the_left_hand(t) -> void:
	var h = Hands.new()
	h.take(&"lupa")
	t.ok(h.hold(&"lupa"), "a lupa vai para a mão")
	t.eq(h.toggle_watch(), &"relogio", "T abre o relógio")
	t.eq(h.left, &"relogio", "o relógio ocupa a mão esquerda")
	t.ok(not h.can_swing(), "com o relógio aberto não há golpe")
	t.eq(h.toggle_watch(), &"lupa", "fechar devolve a lupa")
	t.eq(h.left, &"lupa", "a lupa volta à mão")

func test_watch_is_always_at_hand(t) -> void:
	var h = Hands.new()
	t.ok(h.can_swing(), "mão vazia golpeia")
	t.eq(h.toggle_watch(), &"relogio", "o relógio não precisa de bolso")
	t.eq(h.toggle_watch(), &"", "fechar devolve a mão vazia")
	t.ok(h.can_swing(), "de volta ao golpe")

func test_stick_still_swings(t) -> void:
	var h = Hands.new()
	h.take(&"vareta")
	t.ok(h.hold(&"vareta") and h.can_swing(), "a vareta golpeia")
	h.take(&"espelho")
	h.hold(&"espelho")
	t.ok(not h.can_swing(), "o espelho na mão não golpeia")

func test_hold_needs_the_item(t) -> void:
	var h = Hands.new()
	t.ok(not h.hold(&"espelho"), "sem espelho no bolso")
	t.eq(h.left, &"", "a mão segue vazia")
	t.ok(not h.hold(&"pedra"), "item que não vai na mão")
	t.ok(h.hold(&""), "esvaziar a mão sempre pode")

func test_cycle_skips_empty_pockets(t) -> void:
	var h = Hands.new()
	h.take(&"fosforo", 2)
	h.take(&"estetoscopio")
	t.eq(h.cycle(1), &"fosforo", "pula vareta e espelho, que não estão no bolso")
	t.eq(h.cycle(1), &"estetoscopio", "pula a lupa")
	t.eq(h.cycle(1), &"", "depois do último, a mão vazia")
	t.eq(h.cycle(-1), &"estetoscopio", "para trás")
	h.take(&"lupa")
	t.eq(h.cycle(-1), &"lupa", "a lupa entra na roda ao chegar ao bolso")

func test_cycle_never_picks_the_watch(t) -> void:
	var h = Hands.new()
	t.eq(h.cycle(1), &"", "bolsos vazios: a mão fica vazia")
	h.toggle_watch()
	h.take(&"espelho")
	t.eq(h.cycle(1), &"espelho", "a roda fecha o relógio e passa ao bolso")
	t.eq(h.toggle_watch(), &"relogio", "o relógio abre de novo")
	t.eq(h.toggle_watch(), &"espelho", "e devolve o espelho")

func test_matches_are_counted(t) -> void:
	var h = Hands.new()
	t.ok(not h.use_one(&"fosforo"), "0 fósforos: nada")
	h.take(&"fosforo", 2)
	h.hold(&"fosforo")
	t.ok(h.use_one(&"fosforo"), "um fósforo")
	t.eq(h.count(&"fosforo"), 1, "sobra um")
	t.ok(h.use_one(&"fosforo"), "o último")
	t.eq(h.count(&"fosforo"), 0, "acabou")
	t.ok(not h.pockets.has(&"fosforo"), "o bolso não guarda zero")
	t.eq(h.left, &"", "o último fósforo deixa a mão vazia")
	t.ok(not h.use_one(&"fosforo"), "sem fósforo de novo")

func test_take_ignores_nothing(t) -> void:
	var h = Hands.new()
	h.take(&"lupa", 0)
	t.ok(not h.pockets.has(&"lupa"), "pegar zero não põe nada no bolso")
	h.take(&"pilha", 3)
	t.eq(h.count(&"pilha"), 3, "o bolso guarda o que não vai na mão")
