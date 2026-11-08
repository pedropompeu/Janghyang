extends RefCounted
const Light = preload("res://scripts/light_model.gd")
const Noites = preload("res://scripts/story/noites.gd")
const Registry = preload("res://scripts/areas/registry.gd")
const Atlas = preload("res://scripts/atlas.gd")
const HandsModel = preload("res://scripts/hands_model.gd")

func test_battery_lasts_four_minutes(t) -> void:
	var l = Light.new()
	t.eq(l.drain(209.9, true), &"", "ainda não")
	t.eq(l.drain(0.2, true), &"low", "últimos 30 s piscam")
	t.eq(l.drain(30.0, true), &"dead", "acabou")
	t.eq(l.drain(1.0, true), &"", "morta, não avisa de novo")
	t.eq(l.battery, 0.0, "a pilha não fica negativa")

func test_spare_swaps_in(t) -> void:
	var l = Light.new()
	l.spare = 1
	t.eq(l.drain(240.1, true), &"swapped", "troca sozinha")
	t.near(l.battery, 239.9, 0.01, "pilha nova")
	t.eq(l.spare, 0, "a reserva foi usada")

func test_a_battery_found_in_the_dark_lights_the_lantern(t) -> void:
	var l = Light.new()
	l.drain(241.0, true)
	l.spare = 1
	t.eq(l.drain(0.1, true), &"swapped", "a pilha nova entra ao ligar")
	t.ok(l.battery > 239.0, "carregada")

func test_off_does_not_drain(t) -> void:
	var l = Light.new()
	l.drain(100.0, false)
	t.near(l.battery, 240.0, 0.001, "desligada não gasta")

func test_a_match_burns_twenty_seconds_and_spends_one(t) -> void:
	var l = Light.new()
	var h = HandsModel.new()
	l.hands = h
	t.ok(not l.strike(), "sem fósforo, nada")
	h.take(&"fosforo", 2)
	t.ok(l.strike(), "risca")
	t.eq(h.count(&"fosforo"), 1, "gastou um")
	t.ok(l.burning(), "aceso")
	t.ok(not l.strike(), "um de cada vez")
	t.eq(h.count(&"fosforo"), 1, "o segundo não foi gasto")
	l.drain(19.9, false)
	t.ok(l.burning(), "ainda queima com a lanterna apagada")
	l.drain(0.2, false)
	t.ok(not l.burning(), "apagou depois de 20 s")

func test_flicker_only_near_the_end(t) -> void:
	var l = Light.new()
	var full_ok := true
	for i in 200:
		full_ok = full_ok and l.flicker(i * 0.05) == 1.0
	t.ok(full_ok, "pilha cheia não pisca")
	l.drain(225.0, true)
	var dips := 0
	var floor_ok := true
	for i in 200:
		var f: float = l.flicker(i * 0.05)
		if f < 0.9:
			dips += 1
		floor_ok = floor_ok and f > 0.0 and f <= 1.0
	t.ok(dips > 0 and dips < 200, "no fim, pisca às vezes (%d de 200)" % dips)
	t.ok(floor_ok, "piscando, nunca apaga de vez nem passa de 1")
	l.drain(20.0, true)
	t.eq(l.flicker(1.0), 0.0, "sem pilha, sem luz")

func test_every_night_route_has_enough_light(t) -> void:
	for n in [1, 2]:
		t.ok(Light.route_seconds(Noites.get_night(n)) >= 0.6 * 50 * 60, "noite %d: luz para 60%% de 50 min (%.0f s)" % [n, Light.route_seconds(Noites.get_night(n))])

func test_route_seconds_counts_the_night_s_pickups_only(t) -> void:
	t.eq(Light.route_seconds({"pickups": []}), Light.BATTERY, "só a pilha inicial")
	var one: Dictionary = Light.pickup(Noites.get_night(1).pickups[0])
	t.ok(not one.is_empty(), "o primeiro pickup da noite 1 existe")
	t.near(Light.route_seconds({"pickups": [one.id]}), Light.BATTERY + Light.worth(one), 0.001, "pilha inicial e esse pickup")
	t.eq(Light.route_seconds({"pickups": [&"nao_existe"]}), Light.BATTERY, "id desconhecido não conta")

func test_pickups_are_light_and_lie_in_their_area(t) -> void:
	var atlas = Atlas.new()
	var ids := {}
	for d in Registry.defs():
		for p in d.pickups:
			t.ok(Light.KINDS.has(p.kind), "%s: tipo de luz conhecido (%s)" % [p.id, p.kind])
			t.ok(int(p.get("n", 1)) >= 1, "%s: ao menos um" % p.id)
			t.eq(atlas.level_of(atlas.room_at(p.at + Vector3(0.0, 0.1, 0.0))), d.id, "%s fica na área %s" % [p.id, d.id])
			t.ok(not ids.has(p.id), "%s: id único" % p.id)
			ids[p.id] = true
