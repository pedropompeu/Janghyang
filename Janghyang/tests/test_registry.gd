extends RefCounted
const Registry = preload("res://scripts/areas/registry.gd")
const Atlas = preload("res://scripts/atlas.gd")

## Today's rooms, in today's order: the first room that holds a point wins, so
## the tower must stay before the attic. The merge must never reorder them.
const TODAY := [&"entrada", &"brincar", &"corredor", &"quarto", &"figuras", &"corredor_sul", &"beira_oeste", &"beira_sul", &"passagem", &"mecanismo", &"sotao", &"gaveta", &"loja_varela", &"oficina_varela", &"tampo_leste"]

func test_area_helpers_exist_with_their_arity(t) -> void:
	var methods := {}
	for m in load("res://scripts/main.gd").get_script_method_list():
		methods[m.name] = m.args.size()
	for h in Registry.HELPERS:
		t.ok(methods.has(String(h)), "main has %s" % h)
		t.eq(methods.get(String(h), -1), Registry.HELPERS[h], "arity of %s" % h)

func test_defs_are_valid(t) -> void:
	var ids := {}
	var atlas := Atlas.new()
	for d in Registry.defs():
		t.ok(not ids.has(d.id), "unique id %s" % d.id)
		ids[d.id] = true
		t.ok(d.rooms.size() > 0, "%s has rooms" % d.id)
		var own: Array = d.rooms.map(func(r): return r.id)
		if d.safe_room == &"":
			t.ok(own.has(atlas.room_at(d.safe)), "safe point of %s lies in one of its rooms" % d.id)
		else:
			t.eq(atlas.room_at(d.safe), d.safe_room, "safe point of %s lies where its DEF says" % d.id)
		for r in d.rooms:
			t.eq(r.level, d.id, "room %s carries its area as level" % r.id)
		for l in d.links:
			t.ok(Atlas.levels().has(l.to), "link of %s goes to a known level (%s)" % [d.id, l.to])
			t.eq(l.from, d.id, "link of %s knows where it starts" % d.id)
			t.ok(l.path is Array, "link of %s has a path" % d.id)

func test_atlas_rooms_are_unchanged_by_the_merge(t) -> void:
	t.eq(Atlas.rooms().map(func(r): return r.id), TODAY, "same rooms, same order as today")
	for lvl in [&"casa", &"passagem", &"sotao", &"mecanismo", &"gaveta", &"tampo"]:
		t.ok(Atlas.levels().has(lvl), "level %s is still known" % lvl)

## Every pair of rooms whose boxes overlap, the room tried first on the left.
## A new area that lands inside another, or a reordering, shows up here.
const OVERLAPS := [
	[&"passagem", &"sotao"],
	[&"mecanismo", &"sotao"],
	[&"loja_varela", &"tampo_leste"],
	[&"oficina_varela", &"tampo_leste"],
]

func test_every_overlap_is_known_and_the_first_room_wins(t) -> void:
	var rooms := Atlas.rooms()
	var found := []
	for i in rooms.size():
		for j in range(i + 1, rooms.size()):
			var a: Dictionary = rooms[i]
			var b: Dictionary = rooms[j]
			var flat: Rect2 = a.rect.intersection(b.rect)
			var band := minf(a.y.y, b.y.y) - maxf(a.y.x, b.y.x)
			if flat.get_area() > 0.0001 and band > 0.0001:
				found.append([a.id, b.id])
	t.eq(found, OVERLAPS, "the overlaps of the bench, the first room first")
	var atlas := Atlas.new()
	for pair in OVERLAPS:
		var a: Dictionary = rooms.filter(func(r): return r.id == pair[0])[0]
		var b: Dictionary = rooms.filter(func(r): return r.id == pair[1])[0]
		var c: Vector2 = a.rect.intersection(b.rect).get_center()
		var y := (maxf(a.y.x, b.y.x) + minf(a.y.y, b.y.y)) * 0.5
		t.eq(atlas.room_at(Vector3(c.x, y, c.y)), pair[0], "%s wins over %s" % pair)

func test_every_def_spells_out_what_it_needs(t) -> void:
	# The defaults fill the optional keys; these four have no sane default
	# (a missing safe point would wake Elias at the origin, in the playroom).
	for a in Registry.AREAS:
		for k in ["id", "name", "rooms", "safe"]:
			t.ok(a.DEF.has(k), "%s says its %s" % [a.DEF.get("id", a.resource_path), k])
		for r in a.DEF.get("rooms", []):
			t.ok(r.get("id") is StringName and r.get("name", "") != "", "room of %s has id and name" % a.DEF.get("id"))
			t.ok(r.get("rect") is Rect2 and r.rect.get_area() > 0.0, "room %s has a floor rect" % r.get("id"))
			t.ok(r.get("y") is Vector2 and r.y.y > r.y.x, "room %s has a height band" % r.get("id"))

func test_no_area_is_left_in_mains_legacy_maps(t) -> void:
	var consts: Dictionary = load("res://scripts/main.gd").get_script_constant_map()
	var pairs := {"_LEGACY_SAFE": Registry.safe_points(), "_LEGACY_ROOM_TASKS": Registry.merged("tasks"), "_LEGACY_BREAK_TASKS": Registry.merged("breaks"), "_LEGACY_CATALOG_TASKS": Registry.merged("catalog")}
	for name in pairs:
		for k in consts.get(name, {}):
			t.ok(not pairs[name].has(k), "%s is said once: in its area, not in main's %s" % [k, name])

func test_the_maps_still_hold_todays_lots(t) -> void:
	var consts: Dictionary = load("res://scripts/main.gd").get_script_constant_map()
	var tasks: Dictionary = consts.get("_LEGACY_ROOM_TASKS", {}).merged(Registry.merged("tasks"))
	var breaks: Dictionary = consts.get("_LEGACY_BREAK_TASKS", {}).merged(Registry.merged("breaks"))
	var catalog: Dictionary = consts.get("_LEGACY_CATALOG_TASKS", {}).merged(Registry.merged("catalog"))
	t.eq(tasks, {&"passagem": &"achar_passagem", &"sotao": &"subir_sotao", &"mecanismo": &"entrar_mecanismo", &"gaveta": &"descer_gaveta", &"loja_varela": &"chegar_relojoaria"}, "lots struck by setting foot")
	t.eq(breaks, {"HollowPanel": &"achar_passagem", "Trapdoor": &"achar_alcapao", "CrackedGlass": &"quebrar_redoma"}, "lots struck by breaking")
	t.eq(catalog, {&"relogio_entrada": &"cat_relogio", &"desenho": &"cat_desenho", &"pagina_cabana": &"pagina"}, "lots struck by cataloguing")

func test_passagem_def_matches_today(t) -> void:
	var d := Registry.def(&"passagem")
	t.ok(not d.is_empty(), "the passage is registered")
	if d.is_empty():
		return
	t.near(d.safe.distance_to(Vector3(6.7, 0.2, 1.2)), 0.0, 0.01, "safe point of the passage")
	t.eq(d.safe_room, &"brincar", "too low to stand in: Elias wakes in the playroom")
	t.eq(d.rooms.size(), 1, "one room")
	t.eq(d.rooms[0].id, &"passagem", "the crawlspace")
	t.eq(d.rooms[0].rect, Rect2(0.3, -1.3, 10.1, 1.3), "rect of the crawlspace")
	t.eq(d.rooms[0].y, Vector2(-0.4, 2.9), "height band of the crawlspace")
	t.eq(d.tasks, {&"passagem": &"achar_passagem"}, "setting foot there finds it")
	t.eq(d.breaks, {"HollowPanel": &"achar_passagem"}, "breaking the panel finds it too")
	var to := {}
	for l in d.links:
		to[l.to] = l
	t.eq(to.keys(), [&"casa", &"sotao"], "links to the house and the attic")
	t.eq(to.get(&"casa", {}).get("gate"), &"HollowPanel", "the hollow panel gates the house")

func test_atlas_keeps_the_crawlspace_before_the_attic(t) -> void:
	# The passage and the attic share the band y 2.8–2.9 over x 0.3–10.4:
	# the passage came first, and still does after the move.
	t.eq(Atlas.new().room_at(Vector3(5.0, 2.85, -0.6)), &"passagem", "the overlap goes to the passage")

func _links_by_target(d: Dictionary) -> Dictionary:
	var to := {}
	for l in d.links:
		to[l.to] = l
	return to

func test_sotao_def_matches_today(t) -> void:
	var d := Registry.def(&"sotao")
	t.ok(not d.is_empty(), "the attic is registered")
	if d.is_empty():
		return
	t.near(d.safe.distance_to(Vector3(9.8, 3.14, 0.55)), 0.0, 0.01, "safe point of the attic")
	t.eq(d.rooms.map(func(r): return r.id), [&"sotao"], "one room")
	t.eq(d.rooms[0].rect, Rect2(0.3, -1.3, 14.8, 10.1), "rect of the attic")
	t.eq(d.rooms[0].y, Vector2(2.8, 5.3), "height band of the attic")
	t.eq(d.tasks, {&"sotao": &"subir_sotao"}, "setting foot there climbs it")
	var to := _links_by_target(d)
	t.eq(to.keys(), [&"passagem", &"mecanismo"], "links down the shaft and into the tower")
	t.eq(to.get(&"mecanismo", {}).get("gate"), &"DoorTower", "the tower door gates the tower")

func test_mecanismo_def_matches_today(t) -> void:
	var d := Registry.def(&"mecanismo")
	t.ok(not d.is_empty(), "the tower is registered")
	if d.is_empty():
		return
	t.near(d.safe.distance_to(Vector3(9.8, 3.14, 0.55)), 0.0, 0.01, "safe point of the tower is the attic's")
	t.eq(d.safe_room, &"sotao", "Elias wakes on the attic floor")
	t.eq(d.rooms.map(func(r): return r.id), [&"mecanismo"], "one room")
	t.eq(d.rooms[0].rect, Rect2(5.2, 1.0, 5.4, 5.5), "rect of the tower")
	t.eq(d.rooms[0].y, Vector2(2.8, 13.0), "height band of the tower")
	t.eq(d.tasks, {&"mecanismo": &"entrar_mecanismo"}, "setting foot there enters it")
	t.eq(_links_by_target(d).keys(), [&"sotao"], "a link back to the attic")
	var ids: Array = Registry.defs().map(func(x): return x.id)
	t.ok(ids.find(&"mecanismo") < ids.find(&"sotao"), "the tower is built and tried before the attic")
	t.eq(Atlas.new().room_at(Vector3(7.9, 4.0, 3.75)), &"mecanismo", "inside the tower is the tower, not the attic")

func test_gaveta_def_matches_today(t) -> void:
	var d := Registry.def(&"gaveta")
	t.ok(not d.is_empty(), "the drawer is registered")
	if d.is_empty():
		return
	t.near(d.safe.distance_to(Vector3(14.9, -3.0, 1.9)), 0.0, 0.01, "safe point of the drawer")
	t.eq(d.rooms.map(func(r): return r.id), [&"gaveta"], "one room")
	t.eq(d.rooms[0].rect, Rect2(-1.0, -1.0, 18.0, 14.0), "rect of the drawer")
	t.eq(d.rooms[0].y, Vector2(-3.6, -0.5), "height band of the drawer")
	t.eq(d.tasks, {&"gaveta": &"descer_gaveta"}, "setting foot there goes down")
	t.eq(d.breaks, {"Trapdoor": &"achar_alcapao"}, "breaking the trapdoor finds it")
	var to := _links_by_target(d)
	t.eq(to.keys(), [&"casa"], "a link up to the house")
	t.eq(to.get(&"casa", {}).get("gate"), &"Trapdoor", "the trapdoor gates the house")
