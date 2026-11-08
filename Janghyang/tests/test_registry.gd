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

func test_every_overlap_resolves_to_the_first_room(t) -> void:
	# Every 0.5 m inside every rect, near the bottom and the top of its band:
	# room_at gives the first room of rooms() that holds the point.
	var atlas := Atlas.new()
	var rooms := Atlas.rooms()
	var wrong := 0
	for r in rooms:
		var x: float = r.rect.position.x + 0.25
		while x < r.rect.end.x:
			var z: float = r.rect.position.y + 0.25
			while z < r.rect.end.y:
				for y in [r.y.x + 0.1, r.y.y - 0.1]:
					var p := Vector3(x, y, z)
					var first := &""
					for q in rooms:
						if q.rect.has_point(Vector2(x, z)) and y >= q.y.x and y < q.y.y:
							first = q.id
							break
					if atlas.room_at(p) != first:
						wrong += 1
				z += 0.5
			x += 0.5
	t.eq(wrong, 0, "every sampled point lands in the first room that holds it")

func test_merged_maps_keep_todays_entries(t) -> void:
	t.ok(Registry.safe_points() is Dictionary, "safe points are a map")
	for k in ["tasks", "breaks", "catalog"]:
		t.ok(Registry.merged(k) is Dictionary, "%s is a map" % k)

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
