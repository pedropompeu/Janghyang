extends RefCounted
const Noites = preload("res://scripts/story/noites.gd")
const Quest = preload("res://scripts/quest_model.gd")
const Registry = preload("res://scripts/areas/registry.gd")
const Atlas = preload("res://scripts/atlas.gd")
const Data = preload("res://scripts/catalog_data.gd")

func _col(key: String) -> Array:
	return Noites.NOITES.map(func(n): return n[key])

func test_five_nights_with_spec_numbers(t) -> void:
	t.eq(Noites.NOITES.size(), 5, "cinco noites")
	t.eq(_col("n"), [1, 2, 3, 4, 5], "numeradas em ordem")
	t.eq(_col("capture_clicks"), [10, 12, 13, 15, 16], "cliques por noite (§10)")
	t.eq(_col("anchor_time"), [90.0, 75.0, 60.0, 45.0, 30.0], "corda dos âncoras por noite (§9.1)")
	t.eq(_col("safety"), [&"casa_toda", &"relogio_entrada", &"comodos_com_luz", &"so_ancoras", &"so_ancoras"], "segurança por noite (§11)")
	t.eq(_col("entry_clock_scale"), [1.0, 1.0, 0.5, 1.0, 1.0], "o relógio da entrada dura metade na noite 3")
	t.eq(_col("final"), [false, false, false, false, true], "só a 5 é final")
	t.eq(Noites.get_night(1).safety, &"casa_toda", "noite 1 segura")
	t.ok(Noites.get_night(5).final and not Noites.get_night(2).final, "só a 5 é final")
	t.eq(Noites.DEMO_LAST, 2, "a demo vai até a noite 2")

func test_stalkers_follow_the_spec(t) -> void:
	var most := func(n): return n.stalkers.map(func(s): return s.n).max()
	t.eq(Noites.get_night(1).stalkers, [{"after": &"", "n": 0}, {"after": &"coroa", "n": 1}], "noite 1: nenhum, um depois da coroa")
	t.eq(Noites.get_night(2).stalkers, [{"after": &"", "n": 1}, {"after": &"alcapao", "n": 2}], "noite 2: um, dois depois do alçapão")
	t.eq(Noites.NOITES.map(most), [1, 2, 2, 2, 3], "o máximo de Gastos por noite (§11)")

func test_night_one_has_no_gasto_before_the_crown(t) -> void:
	t.eq(Noites.get_night(1).stalkers[0].n, 0, "nenhum Gasto antes da coroa")
	t.eq(Noites.get_night(1).stalkers[0].after, &"", "desde o começo da noite")

func test_get_night_outside_the_range_is_empty(t) -> void:
	t.eq(Noites.get_night(0), {}, "não há noite 0")
	t.eq(Noites.get_night(6), {}, "não há noite 6")

func test_last_is_five_outside_the_demo(t) -> void:
	t.eq(Noites.last(false), 5, "fora da build da demo, as cinco noites")
	t.eq(Noites.last(true), 2, "a demo para depois da noite 2")
	t.eq(Noites.last(), Noites.last(OS.has_feature("demo")), "sem argumento, vale a build")

func test_night_tasks_and_goals_exist(t) -> void:
	var atlas := Atlas.new()
	for night in Noites.NOITES:
		var tasks := []
		for ph in night.phases:
			t.ok(ph.has("id") and ph.has("title") and ph.tasks.size() > 0, "noite %d: fase %s completa" % [night.n, ph.get("id")])
			for id in ph.tasks:
				t.ok(Quest.TASKS.has(id), "noite %d: a tarefa %s tem texto" % [night.n, id])
				tasks.append(id)
		t.ok(night.goals.size() > 0, "noite %d tem metas" % night.n)
		for g in night.goals:
			t.ok(tasks.has(g.task), "noite %d: a meta %s está nas fases" % [night.n, g.task])
			t.ok(Registry.has_area(g.area), "noite %d: a área %s existe" % [night.n, g.area])
			t.eq(atlas.level_of(atlas.room_at(g.at)), g.area, "noite %d: a meta %s fica na área %s" % [night.n, g.task, g.area])
		for p in night.pieces:
			t.ok(Quest.PIECES.has(p) and tasks.has(p), "noite %d: a peça %s está nas fases" % [night.n, p])
		for s in night.stalkers:
			t.ok(s.after == &"" or tasks.has(s.after), "noite %d: os Gastos aumentam depois de %s, uma tarefa da noite" % [night.n, s.after])
		for c in night.chapters:
			t.ok(Registry.has_area(c.area), "capítulo %d: a área %s existe" % [c.id, c.area])
			t.ok(c.clues.size() > 0, "capítulo %d tem pistas" % c.id)
			for clue in c.clues:
				t.ok(Data.ITEMS.has(clue), "capítulo %d: a pista %s está no catálogo" % [c.id, clue])
			t.ok(tasks.has(c.reward), "capítulo %d termina numa tarefa da noite (%s)" % [c.id, c.reward])
		var pickups := []
		for d in Registry.defs():
			pickups.append_array(d.pickups.map(func(p): return p.id))
		for p in night.pickups:
			t.ok(pickups.has(p), "noite %d: o pickup %s está num DEF" % [night.n, p])

func test_seven_chapters_in_order(t) -> void:
	var ids := []
	for night in Noites.NOITES:
		ids.append_array(night.chapters.map(func(c): return c.id))
	t.eq(ids, [1, 2, 3, 4, 5, 6, 7], "os sete capítulos, um após o outro (§6.2)")
	t.eq(Noites.get_night(1).chapters.map(func(c): return c.area), [&"casa", &"passagem"], "noite 1: casa e passagem")
	t.eq(Noites.get_night(2).chapters.map(func(c): return c.area), [&"sotao", &"mecanismo"], "noite 2: sótão e torre")

func test_every_piece_is_won_on_exactly_one_night(t) -> void:
	var won := []
	for night in Noites.NOITES:
		won.append_array(night.pieces)
	t.eq(won, Quest.PIECES, "as quatro peças, uma por noite, em ordem")
	t.eq(Noites.get_night(5).goals.map(func(g): return g.task), [&"voltar"], "a noite 5 tem o gatilho de hoje")
	t.eq(Noites.get_night(5).phases.size(), 1, "a noite 5 tem uma fase só")
	t.eq(Noites.get_night(5).phases[0].tasks, [&"voltar", &"hora", &"corda", &"pagina", &"sair"], "a noite 5 é a fase V de hoje")

## Outside the final night, the last phase is getting home and winding the
## clock; it is what the short 03:33 waits for.
func test_short_nights_end_at_home(t) -> void:
	for night in Noites.NOITES:
		if not night.final:
			t.eq(night.phases[-1].tasks, [&"voltar_terreo", &"dar_corda"], "noite %d termina em casa" % night.n)

func test_goals_follow_the_chapters(t) -> void:
	for night in Noites.NOITES:
		t.eq(night.goals.map(func(g): return g.task), night.chapters.map(func(c): return c.reward), "noite %d: uma meta por capítulo, na ordem" % night.n)

func test_get_night_gives_a_copy(t) -> void:
	var n1 := Noites.get_night(1)
	n1.n = 99
	n1.phases[-1].tasks.append(&"x")
	t.eq(Noites.get_night(1).n, 1, "mexer na noite devolvida não muda a tabela")
	t.eq(Noites.get_night(2).phases[-1].tasks, [&"voltar_terreo", &"dar_corda"], "nem a fase final das outras noites")
