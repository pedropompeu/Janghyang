extends RefCounted
## Noite 1, Tarefa 13 (§6.2, item 11): o que se vê pela fresta.
const Peek = preload("res://scripts/peek_model.gd")

func test_first_look_is_the_far_shape(t) -> void:
	var p = Peek.new()
	t.eq(p.look(10.0, true, false), &"forma", "a primeira olhada mostra a forma ao fundo")
	t.eq(p.look(11.0, true, false), &"escuro", "a segunda, só o escuro")

func test_eye_needs_time_and_leave(t) -> void:
	var p = Peek.new()
	p.look(0.0, true, false)
	t.eq(p.look(60.0, true, false), &"escuro", "aos 60 s, mesmo com licença, escuro")
	t.eq(p.look(130.0, false, false), &"escuro", "aos 130 s sem licença, escuro")
	t.eq(p.look(130.0, true, false), &"olho", "aos 130 s com licença, o olho")

func test_after_the_eye_nothing(t) -> void:
	var p = Peek.new()
	p.look(0.0, true, false)
	t.eq(p.look(200.0, true, false), &"olho", "o olho")
	t.eq(p.look(400.0, true, false), &"nada", "depois do olho, nada")
	t.eq(p.look(900.0, true, false), &"nada", "nunca mais")

func test_nothing_once_the_panel_is_broken(t) -> void:
	var p = Peek.new()
	t.eq(p.look(0.0, true, true), &"nada", "painel quebrado, nem a forma")
	var q = Peek.new()
	q.look(0.0, true, false)
	t.eq(q.look(200.0, true, true), &"nada", "painel quebrado, nem o olho")
