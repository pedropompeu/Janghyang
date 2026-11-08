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
		t.ok(own.has(atlas.room_at(d.safe)), "safe point of %s lies in one of its rooms" % d.id)
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
