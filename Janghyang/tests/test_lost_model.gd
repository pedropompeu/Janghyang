extends RefCounted
const Lost = preload("res://scripts/lost_model.gd")

func test_lost_after_three_minutes_without_progress(t) -> void:
	var l = Lost.new()
	var marks := 0
	for i in 179:
		if l.update(1.0, 20.0 + sin(i) * 1.5, &"achar_passagem"):
			marks += 1
	t.eq(marks, 0, "179 s andando em volta: ainda não")
	t.ok(l.update(1.5, 19.0, &"achar_passagem"), "aos 180 s sem chegar 2 m mais perto: perdido")
	t.ok(not l.update(1.0, 19.0, &"achar_passagem"), "o aviso é uma vez só")
	t.ok(l.is_lost(), "segue perdido")
	t.ok(not l.update(1.0, 17.5, &"achar_passagem"), "chegou 2 m mais perto")
	t.ok(not l.is_lost(), "não está mais perdido")

func test_progress_resets_the_clock(t) -> void:
	var l = Lost.new()
	l.update(170.0, 20.0, &"a")
	t.ok(not l.update(1.0, 17.9, &"a"), "chegou 2 m mais perto aos 171 s")
	t.ok(not l.update(170.0, 18.0, &"a"), "170 s depois do progresso, não")
	t.ok(l.update(10.5, 18.0, &"a"), "180 s depois do progresso, sim")

func test_new_goal_resets_the_clock(t) -> void:
	var l = Lost.new()
	l.update(170.0, 20.0, &"a")
	t.ok(not l.update(1.0, 30.0, &"b"), "meta nova")
	t.ok(not l.update(170.0, 30.0, &"b"), "170 s na meta nova, não")
	t.ok(l.update(10.5, 30.0, &"b"), "180 s na meta nova, sim")

func test_no_goal_is_never_lost(t) -> void:
	var l = Lost.new()
	t.ok(not l.update(500.0, INF, &""), "sem meta, ninguém se perde")

const Log = preload("res://scripts/playtest_log.gd")

func test_the_log_row_follows_the_columns(t) -> void:
	t.eq(Log.header(), "t,noite,area,comodo,meta,dist,relogio_aberto,caderno_aberto,capturas,perdido", "cabeçalho")
	var r: String = Log.row({"t": 5.04, "noite": 1, "area": &"casa", "comodo": &"sala", "meta": &"achar_passagem", "dist": INF, "relogio_aberto": true, "caderno_aberto": false, "capturas": 2, "perdido": false})
	t.eq(r, "5.0,1,casa,sala,achar_passagem,,1,0,2,0", "uma linha, sem distância infinita")
	t.eq(Log.row({"meta": "a,b"}).split(",").size(), 10, "vírgula no valor não abre coluna")
