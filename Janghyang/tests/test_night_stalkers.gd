extends RefCounted
const Gastos = preload("res://scripts/gastos.gd")
const Noites = preload("res://scripts/story/noites.gd")

func _done(ids: Array) -> Callable:
	return func(id: StringName) -> bool: return ids.has(id)

func test_the_night_counts_the_gastos(t) -> void:
	var one: Array = Noites.get_night(1).stalkers
	t.eq(Gastos.night_stalkers(one, _done([])), 0, "noite 1: nenhum antes da coroa")
	t.eq(Gastos.night_stalkers(one, _done([&"coroa"])), 1, "noite 1: um depois da coroa")
	var two: Array = Noites.get_night(2).stalkers
	t.eq(Gastos.night_stalkers(two, _done([])), 1, "noite 2: um desde o começo")
	t.eq(Gastos.night_stalkers(two, _done([&"alcapao"])), 2, "noite 2: dois depois do alçapão")
	t.eq(Gastos.night_stalkers(Noites.get_night(5).stalkers, _done([])), 3, "noite 5: três")
