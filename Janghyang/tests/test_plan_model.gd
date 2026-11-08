extends RefCounted
const Plan = preload("res://scripts/plan_model.gd")
const Atlas = preload("res://scripts/atlas.gd")

func test_fog_covers_the_rooms_of_the_level(t) -> void:
	var p = Plan.new()
	var f = p.fog(&"casa")
	t.ok(f != null, "a casa tem névoa")
	for r in Atlas.rooms():
		if r.level == &"casa":
			t.ok(f.rect.encloses(r.rect), "%s cabe na névoa" % r.id)
	t.ok(p.fog(&"casa") == f, "a mesma grade a cada pedido")
	t.ok(p.fog(&"nada") == null, "nível desconhecido: sem grade")

func test_picked_item_note_disappears(t) -> void:
	var p = Plan.new()
	p.note(&"casa", Vector3(2, 0, 3), &"item", "pilha", 12.0, &"pilha_1")
	t.eq(p.notes_on(&"casa").size(), 1, "anotado")
	p.forget_item(&"pilha_1")
	t.eq(p.notes_on(&"casa").size(), 0, "pego, a anotação some")

func test_same_id_moves_the_note(t) -> void:
	var p = Plan.new()
	p.note(&"casa", Vector3(1, 0, 1), &"gasto", "Gasto", 5.0, &"gasto_0")
	p.note(&"casa", Vector3(3, 0, 1), &"gasto", "Gasto", 7.0, &"gasto_0")
	var notes: Array = p.notes_on(&"casa")
	t.eq(notes.size(), 1, "o mesmo Gasto é uma anotação")
	t.eq(notes[0].at, Vector3(3, 0, 1), "no lugar mais recente")
	t.near(notes[0].time, 7.0, 0.001, "na hora mais recente")

func test_unknown_kind_is_ignored(t) -> void:
	var p = Plan.new()
	p.note(&"casa", Vector3.ZERO, &"tesouro", "?", 1.0)
	t.eq(p.notes_on(&"casa").size(), 0, "só os cinco tipos")
	for k in Plan.KINDS:
		p.note(&"casa", Vector3.ZERO, k, String(k), 1.0)
	t.eq(p.notes_on(&"casa").size(), 5, "gasto, item, barricada, âncora e giz")

func test_round_trip_through_json(t) -> void:
	var p = Plan.new()
	p.fog(&"casa").reveal(Vector2(4.2, 3.1))
	p.note(&"sotao", Vector3(7, 3.2, 6), &"giz", "seta", 30.0)
	var d = JSON.parse_string(JSON.stringify(p.to_dict()))
	var q = Plan.new()
	q.from_dict(d)
	t.ok(q.fog(&"casa").seen(Vector2(4.2, 3.1)) and q.fog(&"casa").count() == 1, "a névoa volta")
	var notes: Array = q.notes_on(&"sotao")
	t.ok(notes.size() == 1 and notes[0].kind == &"giz" and notes[0].label == "seta", "a anotação volta")
	t.ok(notes.size() == 1 and (notes[0].at as Vector3).is_equal_approx(Vector3(7, 3.2, 6)), "no mesmo lugar")

func test_bad_save_starts_clean(t) -> void:
	var q = Plan.new()
	q.from_dict({"fog": {"casa": 42}, "notes": "x"})
	t.eq(q.fog(&"casa").count(), 0, "névoa limpa")
	t.eq(q.notes_on(&"casa").size(), 0, "sem anotações")

func test_chalk_marks_keep_the_last_twenty(t) -> void:
	var p = Plan.new()
	for k in 21:
		p.note(&"casa", Vector3(k * 0.5, 1.2, 0.1), &"giz", str(k + 1), float(k))
	var marks: Array = p.notes_on(&"casa").filter(func(n) -> bool: return n.kind == &"giz")
	t.eq(marks.size(), Plan.MAX_MARKS, "ficam 20 marcas")
	t.eq(marks[0].label if marks.size() > 0 else "", "2", "a primeira saiu")
	t.eq(marks[-1].label if marks.size() > 0 else "", "21", "a última ficou")

func test_chalk_limit_counts_every_sheet(t) -> void:
	var p = Plan.new()
	for k in 20:
		p.note(&"casa", Vector3(k * 0.5, 1.2, 0.1), &"giz", "c%d" % k, float(k))
	p.note(&"sotao", Vector3(2.0, 4.2, 4.0), &"giz", "s0", 30.0)
	p.note(&"casa", Vector3(1.0, 0.0, 1.0), &"gasto", "Gasto", 31.0)
	t.eq(p.notes_on(&"casa").filter(func(n) -> bool: return n.kind == &"giz").size(), 19, "a marca do sótão apaga a mais antiga da casa")
	t.eq(p.notes_on(&"sotao").size(), 1, "a do sótão fica")
	t.eq(p.notes_on(&"casa").filter(func(n) -> bool: return n.kind == &"gasto").size(), 1, "outras notas não contam")

func test_chalk_marks_cross_the_night_in_the_save(t) -> void:
	var p = Plan.new()
	for k in 3:
		p.note(&"casa", Vector3(k, 1.2, 0.1), &"giz", "g%d" % k, float(k))
	var q = Plan.new()
	q.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	t.eq(q.notes_on(&"casa").size(), 3, "as três marcas passam pela gravação")
	for k in 20:
		q.note(&"casa", Vector3(k, 1.5, 0.1), &"giz", "n%d" % k, 10.0 + k)
	t.eq(q.notes_on(&"casa").size(), Plan.MAX_MARKS, "o limite vale depois de carregar")
	t.eq(q.notes_on(&"casa")[0].label, "n0", "as carregadas são as mais antigas")
