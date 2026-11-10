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

const STEPS := [
	{"after": &"", "n": 0},
	{"after": &"figura_saiu", "n": 1, "levels": [&"casa"]},
	{"after": &"beco_apagou", "n": 1, "birth": {"level": &"passagem", "at": Vector3(6.45, 0.0, -0.65)}},
]

func test_levels_and_flags(t) -> void:
	var none := func(_id): return false
	var out := func(id): return id == &"figura_saiu"
	var beco := func(id): return id in [&"figura_saiu", &"beco_apagou"]
	t.eq(Gastos.night_stalkers(STEPS, none, &"casa"), 0, "nothing before the figure leaves")
	t.eq(Gastos.night_stalkers(STEPS, out, &"casa"), 1, "one in the house")
	t.eq(Gastos.night_stalkers(STEPS, out, &"passagem"), 0, "it does not follow into the passage")
	t.eq(Gastos.night_stalkers(STEPS, beco, &"passagem"), 1, "the dead end has one")
	t.eq(Gastos.night_stalkers(STEPS, beco, &"casa"), 1, "and it follows him home")
	t.eq(Gastos.night_stalkers(STEPS, out), 0, "a step bound to levels does not count on no level")

func test_old_nights_unchanged(t) -> void:
	for n in [2, 3, 4, 5]:
		var s: Array = Noites.NOITES[n - 1].stalkers
		t.eq(Gastos.night_stalkers(s, func(_id): return false), int(s[0].n), "night %d as before" % n)

func test_night_step_carries_the_birth(t) -> void:
	var beco := func(id): return id in [&"figura_saiu", &"beco_apagou"]
	t.eq(Gastos.night_step(STEPS, beco, &"passagem").get("birth", {}).get("level", &""), &"passagem", "the step in force says where its Gasto is born")
	t.ok(not Gastos.night_step(STEPS, func(id): return id == &"figura_saiu", &"casa").has("birth"), "the house step has no birth")
	t.eq(Gastos.night_step([], beco, &"casa"), {}, "no steps, no step")

func test_birth_point_is_the_nearest_graph_point(t) -> void:
	var pts: Array[Vector3] = [Vector3(2.05, 0.0, -0.65), Vector3(4.25, 0.0, -0.65), Vector3(6.45, 0.0, -0.65), Vector3(8.65, 0.0, -0.65)]
	t.eq(Gastos.birth_index(pts, Vector3(6.45, 0.0, -0.65)), 2, "the point at the dead end")
	t.eq(Gastos.birth_index(pts, Vector3(7.7, 0.0, -0.4)), 3, "the nearest one, when none is exact")
	t.eq(Gastos.birth_index([], Vector3.ZERO), -1, "no graph, no birth")

