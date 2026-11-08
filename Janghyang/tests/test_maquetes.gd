extends RefCounted
const Maquetes = preload("res://scripts/maquetes/registry.gd")
const Registry = preload("res://scripts/areas/registry.gd")

func test_every_area_is_in_exactly_one_maquete(t) -> void:
	for d in Registry.defs():
		var holders: Array = Maquetes.MAQUETES.filter(func(m): return m.areas.has(d.id))
		t.eq(holders.size(), 1, "area %s is in exactly one maquete" % d.id)
		if holders.size() == 1:
			t.eq(holders[0].id, d.maquete, "the DEF of %s names its maquete" % d.id)
	for m in Maquetes.MAQUETES:
		for a in m.areas:
			t.ok(Registry.has_area(a), "maquete %s lists a registered area (%s)" % [m.id, a])

func test_the_three_maquetes(t) -> void:
	t.eq(Maquetes.MAQUETES.map(func(m): return m.id), [&"item_214", &"item_215", &"item_216"], "the three maquetes, in order")
	t.eq(Maquetes.MAQUETES.map(func(m): return m.item), [214, 215, 216], "their item numbers")
	t.eq(Maquetes.MAQUETES.map(func(m): return m.name), ["a casa da rua do Porto", "Relojoaria Varela", "a mansão das falésias"], "their names")
	for m in Maquetes.MAQUETES:
		t.ok(m.dome is Transform3D, "maquete %s has a dome transform" % m.id)

func test_of_area(t) -> void:
	t.eq(Maquetes.of_area(&"casa"), &"item_214", "the house is in item 214")
	t.eq(Maquetes.of_area(&"mecanismo"), &"item_214", "the tower too")
	t.eq(Maquetes.of_area(&"tampo"), &"item_215", "the tabletop is in item 215")
	t.eq(Maquetes.of_area(&"nada"), &"", "an unknown area is in none")

func test_the_house_dome_covers_the_house(t) -> void:
	var dome: Transform3D = Maquetes.get_maquete(&"item_214").dome
	var local := dome.affine_inverse() * Vector3(1.8, 0.2, 8.3)
	t.ok(absf(local.x) <= 0.5 and absf(local.z) <= 0.5 and local.y >= 0.0 and local.y <= 1.0, "the spawn point is under the house dome")
