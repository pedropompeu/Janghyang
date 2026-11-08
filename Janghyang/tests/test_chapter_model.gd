extends RefCounted
const Chapter = preload("res://scripts/chapter_model.gd")

func _def(right := 2) -> Dictionary:
	return {"id": 1, "area": &"casa", "title": "T", "clues": [&"a", &"b", &"c"], "poses": 4,
		"hypothesis": ["um", "dois", "três"], "right": right, "reward": &"r"}

func test_chapter_opens_when_all_clues_are_in(t) -> void:
	var c = Chapter.new(_def())
	t.ok(not c.on_cataloged(&"a"), "a: ainda não")
	t.ok(not c.on_cataloged(&"x"), "o que não é pista não conta")
	t.ok(not c.on_cataloged(&"b"), "b: ainda não")
	t.ok(not c.opened, "fechado com duas pistas")
	t.ok(c.on_cataloged(&"c"), "c fecha as pistas")
	t.ok(c.opened, "aberto")
	t.ok(not c.on_cataloged(&"a"), "repetir a não reabre")

func test_repeated_clue_counts_once(t) -> void:
	var c = Chapter.new(_def())
	c.on_cataloged(&"a")
	c.on_cataloged(&"a")
	t.ok(not c.on_cataloged(&"b"), "a repetida não conta duas vezes")

func test_staging_moves_only_once_opened(t) -> void:
	var c = Chapter.new(_def())
	t.ok(not c.update(5.0, false), "fechado, a encenação não anda")
	t.eq(c.staging.pose, 0, "pose 0")
	for id in [&"a", &"b", &"c"]:
		c.on_cataloged(id)
	t.ok(c.update(1.6, false), "aberto, anda fora da vista")
	t.eq(c.staging.poses, 4, "as poses vêm do capítulo")
	t.ok(not c.ready_to_write(), "a hipótese espera o fim da encenação")
	c.update(1.6, false)
	c.update(1.6, false)
	t.ok(c.ready_to_write(), "no fim da encenação, a página de hipótese")

func test_wrong_hypothesis_is_crossed_and_retried(t) -> void:
	var c = Chapter.new(_def(2))
	t.ok(not c.choose(0), "a frase 0 é errada")
	t.eq(c.page().crossed, [0], "riscada")
	t.eq(c.page().chosen, -1, "nada escolhido ainda")
	t.ok(not c.choose(0), "a riscada não volta")
	t.ok(c.choose(2), "a frase 2 é a certa")
	t.eq(c.page().chosen, 2, "passada a limpo")
	t.eq(c.page().lines, ["um", "dois", "três"], "as três frases")
	t.ok(not c.choose(1), "depois de passada a limpo, nada muda")
	t.eq(c.page().crossed, [0], "e nada mais se risca")

func test_out_of_range_choice_is_ignored(t) -> void:
	var c = Chapter.new(_def())
	t.ok(not c.choose(-1) and not c.choose(3), "fora das três frases")
	t.eq(c.page().crossed, [], "nada riscado")

func test_no_clues_is_open_from_the_start(t) -> void:
	var d := _def()
	d.clues = []
	var c = Chapter.new(d)
	t.ok(c.opened, "sem pistas, aberto")
