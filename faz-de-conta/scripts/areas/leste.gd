extends RefCounted
## East of the dome, out on the bench: Inácio's tools at a giant's scale, a
## crack between two boards of the bench that only a steel ruler crosses, and
## the second model he built, the Relojoaria Varela. A shop with a counter to
## hide under, porcelain on the shelves, a mannequin in the window and dozens
## of clocks that do not agree with each other; behind a curtain, the back
## workshop, where the case of the pocket watch waits on the bench.
## The way in is the cracked glass in the dome's east wall (main.gd).

const SHOP := Rect2(20.0, -12.0, 10.0, 10.0)
const FRONT_Z := -2.0
const PARTITION_Z := -7.0
## The crack between the boards: wider than a running hop.
const GROOVE := Rect2(17.4, 0.0, 16.6, 4.2)
const GROOVE_DEPTH := -9.6
const EAST_X := 34.0
const NORTH_Z := -16.0
const SOUTH_Z := 13.4
## Where a fall into the crack wakes him: just outside the broken glass.
const SAFE := Vector3(16.6, 0.2, 10.8)

static func build(main: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Leste"
	main.add_child(root)
	_build_bench(main, root)
	_build_shop(main, root)
	_build_back_room(main, root)

static func _build_bench(main: Node3D, root: Node3D) -> void:
	var bench: Material = main.mat_wood
	var dark: Material = main.mat_wood_dark
	var steel: Material = main._mat("#8a8d93", 0.35, 0.85)

	# The bench, both sides of the crack.
	main._floor(root, 15.4, GROOVE.end.y, EAST_X, SOUTH_Z, bench)
	main._floor(root, 15.6, NORTH_Z, EAST_X, GROOVE.position.y, bench)
	# The crack: two sheer sides, a far end, and nothing at the bottom.
	main._wall_z(root, GROOVE.position.y - 0.07, GROOVE.position.x, EAST_X, GROOVE_DEPTH, 0.0, dark)
	main._wall_z(root, GROOVE.end.y + 0.07, GROOVE.position.x, EAST_X, GROOVE_DEPTH, 0.0, dark)
	main._wall_x(root, GROOVE.position.x + 0.07, GROOVE.position.y, GROOVE.end.y, GROOVE_DEPTH, 0.0, dark)
	main._box(root, Vector3(GROOVE.size.x, 0.1, GROOVE.size.y), Vector3(GROOVE.get_center().x, GROOVE_DEPTH, GROOVE.get_center().y), main.mat_dark, false)

	# The steel ruler laid across it, the only bridge.
	main._box(root, Vector3(0.7, 0.04, GROOVE.size.y + 1.0), Vector3(24.5, 0.02, GROOVE.get_center().y), steel)
	for i in 21:
		var long := i % 5 == 0
		main._box(root, Vector3(0.22 if long else 0.12, 0.005, 0.015), Vector3(24.5 - 0.35 + (0.11 if long else 0.06), 0.043, GROOVE.position.y - 0.4 + i * 0.25), main.mat_dark, false)

	# What closes the bench in: a box of screws at the crack's west end, a
	# cigar box along the dome to the north-west, the toolbox to the east,
	# a stack of ledgers to the north. All taller than a hop.
	main._box(root, Vector3(1.8, 3.2, 5.8), Vector3(16.5, 1.6, 2.1), main._mat("#6b5a3e", 0.9))
	main._box(root, Vector3(1.82, 0.08, 5.82), Vector3(16.5, 3.2, 2.1), main.mat_brass, false)
	main._box(root, Vector3(2.6, 2.8, -0.3 - NORTH_Z), Vector3(14.3, 1.4, (NORTH_Z - 0.3) * 0.5), main._mat("#7a3f2a", 0.8))
	main._box(root, Vector3(1.5, 4.0, SOUTH_Z - NORTH_Z), Vector3(EAST_X + 0.75, 2.0, (NORTH_Z + SOUTH_Z) * 0.5), main._mat("#3d4a3a", 0.85))
	main._box(root, Vector3(0.1, 0.5, 0.9), Vector3(EAST_X - 0.02, 3.2, 1.0), main.mat_brass, false)
	main._wall_x(root, EAST_X - 0.07, GROOVE.position.y, GROOVE.end.y, GROOVE_DEPTH, 0.0, dark)
	var ledgers := [["#4a2a24", 1.4], ["#2c3a4a", 1.2], ["#5a4a2a", 1.1]]
	var y := 0.0
	for l in ledgers:
		main._box(root, Vector3(EAST_X - 15.6 + 1.5, l[1], 1.6), Vector3((15.6 + EAST_X + 1.5) * 0.5, y + l[1] * 0.5, NORTH_Z - 0.8), main._mat(l[0], 0.9))
		y += l[1]

	# Giant tools left about: a screwdriver, the loupe, tweezers, a spool
	# of thread that closes the corner by the dome.
	main._cyl(root, 0.32, 2.6, Vector3(29.0, 0.32, 9.0), main._mat("#8b2f2a", 0.6), true, Vector3(0.0, 0.0, deg_to_rad(90.0)))
	main._cyl(root, 0.07, 3.6, Vector3(26.0, 0.32, 9.0), steel, true, Vector3(0.0, 0.0, deg_to_rad(90.0)))
	var loupe := TorusMesh.new()
	loupe.inner_radius = 1.05
	loupe.outer_radius = 1.2
	main._add_mesh(root, loupe, Vector3(20.6, 0.07, 7.6), main._mat("#1e1e22", 0.5))
	main._box(root, Vector3(0.12, 0.05, 4.0), Vector3(31.0, 0.03, 4.9), steel, false, Vector3(0.0, deg_to_rad(4.0), 0.0))
	main._box(root, Vector3(0.12, 0.05, 4.0), Vector3(31.4, 0.03, 4.9), steel, false, Vector3(0.0, deg_to_rad(-4.0), 0.0))
	main._cyl(root, 0.5, 1.2, Vector3(15.9, 0.6, 13.05), main._mat("#b8b2a2", 0.95))
	main._cyl(root, 0.62, 0.08, Vector3(15.9, 1.24, 13.05), main.mat_wood_dark, false)

	main._omni(root, Vector3(24.0, 5.0, 7.0), Color(0.6, 0.68, 0.85), 0.35, 16.0)
	main._omni(root, Vector3(25.0, 5.0, -9.0), Color(0.6, 0.68, 0.85), 0.25, 14.0)

	# The bench's south edge is the same edge as the tampo's: the way out.
	var edge := Area3D.new()
	edge.name = "ExitEdgeLeste"
	edge.collision_layer = 0
	edge.collision_mask = 1
	edge.position = Vector3((15.4 + EAST_X) * 0.5, 1.25, SOUTH_Z - 0.25)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(EAST_X - 15.4, 2.5, 0.5)
	cs.shape = shape
	edge.add_child(cs)
	edge.body_entered.connect(func(body: Node3D) -> void:
		if body == main.player:
			main.exit_edge_reached.emit())
	root.add_child(edge)

	# Out here a fall into the crack wakes him by the broken glass; back
	# under the dome, by the front door as always.
	_safe_zone(main, root, "SafeLeste", Vector3(24.7, 1.0, 8.8), Vector3(18.6, 2.0, 9.2), SAFE)
	_safe_zone(main, root, "SafeTampo", Vector3(13.0, 1.0, 10.8), Vector3(4.8, 2.0, 3.4), main.SPAWN)

static func _safe_zone(main: Node3D, root: Node3D, node_name: String, center: Vector3, size: Vector3, point: Vector3) -> void:
	var area := Area3D.new()
	area.name = node_name
	area.collision_layer = 0
	area.collision_mask = 1
	area.position = center
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	area.add_child(cs)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body == main.player:
			body.respawn_point = point)
	root.add_child(area)

static func _build_shop(main: Node3D, root: Node3D) -> void:
	var facade: Material = main._mat("#26362c", 0.8)
	var paper: Material = main._mat("#5a4a3a", 0.95)
	var boards: Material = main._mat("#4a3826", 0.9)
	var glass: Material = main.mat_glass
	var x0 := SHOP.position.x
	var x1 := SHOP.end.x
	var z0 := SHOP.position.y
	var top: float = main.WALL_H
	var door_h: float = main.DOOR_H

	# The front: two shop windows and the door between them.
	main._wall_z(root, FRONT_Z, x0, 21.0, 0.0, top, facade)
	main._wall_z(root, FRONT_Z, 23.8, 24.4, 0.0, top, facade)
	main._wall_z(root, FRONT_Z, 25.6, 26.2, 0.0, top, facade)
	main._wall_z(root, FRONT_Z, 29.0, x1, 0.0, top, facade)
	main._wall_z(root, FRONT_Z, 24.4, 25.6, door_h, top, facade)
	for w in [Vector2(21.0, 23.8), Vector2(26.2, 29.0)]:
		main._wall_z(root, FRONT_Z, w.x, w.y, 0.0, 0.5, facade)
		main._wall_z(root, FRONT_Z, w.x, w.y, 0.5, 2.0, glass)
		main._wall_z(root, FRONT_Z, w.x, w.y, 2.0, top, facade)
	# Sides, back, the partition with the back room's doorway, the ceiling.
	main._wall_x(root, x0, z0, FRONT_Z, 0.0, top, paper)
	main._wall_x(root, x1, z0, FRONT_Z, 0.0, top, paper)
	main._wall_z(root, z0, x0, x1, 0.0, top, paper)
	main._wall_z(root, PARTITION_Z, x0, 27.0, 0.0, top, paper)
	main._wall_z(root, PARTITION_Z, 28.0, x1, 0.0, top, paper)
	main._wall_z(root, PARTITION_Z, 27.0, 28.0, door_h, top, paper)
	main._box(root, Vector3(x1 - x0 + 0.14, 0.12, SHOP.size.y + 0.14), Vector3(SHOP.get_center().x, top + 0.06, SHOP.get_center().y), main.mat_ceiling)
	main._box(root, Vector3(x1 - x0 + 0.5, 0.22, SHOP.size.y + 0.5), Vector3(SHOP.get_center().x, top + 0.23, SHOP.get_center().y), facade, false)
	main._box(root, Vector3(x1 - x0 - 0.2, 0.01, SHOP.size.y - 0.2), Vector3(SHOP.get_center().x, 0.006, SHOP.get_center().y), boards, false)

	# The door, left ajar into the shop.
	var hinge := Node3D.new()
	hinge.name = "ShopDoor"
	hinge.position = Vector3(24.4, 0.0, FRONT_Z)
	hinge.rotation.y = deg_to_rad(75.0)
	root.add_child(hinge)
	main._box(hinge, Vector3(1.15, door_h - 0.02, 0.05), Vector3(0.6, door_h * 0.5, 0.0), facade)
	main._box(hinge, Vector3(0.7, 0.9, 0.06), Vector3(0.6, 1.45, 0.0), glass, false)

	# The sign, and a bracket clock hung out over the street.
	main._box(root, Vector3(4.2, 0.46, 0.06), Vector3(25.0, 2.38, FRONT_Z + 0.1), main.mat_dark, false)
	var sign := Label3D.new()
	sign.name = "Letreiro"
	sign.text = "RELOJOARIA VARELA"
	sign.font_size = 64
	sign.pixel_size = 0.0045
	sign.modulate = Color(0.86, 0.7, 0.4)
	sign.outline_size = 0
	sign.position = Vector3(25.0, 2.38, FRONT_Z + 0.14)
	root.add_child(sign)
	main._box(root, Vector3(0.05, 0.05, 0.5), Vector3(29.5, 2.45, FRONT_Z + 0.25), main.mat_dark, false)
	var bracket := Node3D.new()
	bracket.position = Vector3(29.5, 2.1, FRONT_Z + 0.5)
	bracket.rotation.y = deg_to_rad(90.0)
	root.add_child(bracket)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3332
	_clock(main, bracket, Vector3(0.0, 0.0, 0.03), 0.0, 0.28, 1.0, rng)
	_clock(main, bracket, Vector3(0.0, 0.0, -0.03), PI, 0.28, 1.03, rng)

	# The left window: a mannequin in a watchmaker's coat, facing the street.
	main._box(root, Vector3(2.8, 0.5, 0.95), Vector3(22.4, 0.25, FRONT_Z - 0.55), main.mat_wood_dark)
	var dummy: Node3D = main.Mannequin.new()
	dummy.name = "ManequimVitrine"
	root.add_child(dummy)
	dummy.build({"coat": Color("#3b3530"), "skin": Color("#e6ddd0"), "hair": Color("#e6ddd0"), "trousers": Color("#2b2b30")})
	dummy.position = Vector3(22.4, 0.5, FRONT_Z - 0.6)
	dummy.rotation.y = PI
	main._omni(root, Vector3(22.4, 1.9, FRONT_Z - 0.4), Color(1.0, 0.8, 0.55), 0.22, 2.5)

	# The right window: a stand of clocks, none of them past 03:32.
	main._box(root, Vector3(2.8, 0.5, 0.95), Vector3(27.6, 0.25, FRONT_Z - 0.55), main.mat_wood_dark)
	main._box(root, Vector3(2.6, 0.35, 0.4), Vector3(27.6, 0.675, FRONT_Z - 0.8), main.mat_wood_dark)
	for i in 4:
		_clock(main, root, Vector3(26.7 + i * 0.6, 0.72, FRONT_Z - 0.35), 0.0, 0.16, rng.randf_range(0.9, 1.12), rng)
	for i in 3:
		_clock(main, root, Vector3(27.0 + i * 0.6, 1.12, FRONT_Z - 0.72), 0.0, 0.2, rng.randf_range(0.9, 1.12), rng)
	main._catalog_target(root, &"relogios_varela", Vector3(27.6, 1.0, FRONT_Z - 0.6), Vector3(2.8, 1.0, 1.0))
	main._omni(root, Vector3(27.6, 1.9, FRONT_Z - 0.4), Color(1.0, 0.8, 0.55), 0.22, 2.5)

	# Clocks on every wall of the shop, each in its own time.
	for row in 3:
		for col in 8:
			if rng.randf() < 0.2:
				continue
			var p := Vector3(20.6 + col * 0.82 + rng.randf_range(-0.12, 0.12), 1.35 + row * 0.5 + rng.randf_range(-0.08, 0.08), PARTITION_Z + 0.1)
			_clock(main, root, p, 0.0, rng.randf_range(0.13, 0.22), rng.randf_range(0.85, 1.15), rng)
	for i in 7:
		var p := Vector3(x0 + 0.1, 1.5 + (i % 2) * 0.55, -6.3 + i * 0.55)
		_clock(main, root, p, PI * 0.5, rng.randf_range(0.14, 0.24), rng.randf_range(0.85, 1.15), rng)
	main._loop_3d(&"ticks", Vector3(25.0, 1.6, -4.8), -12.0)

	# The counter, open behind: crouch under it and nothing reaches you.
	main._box(root, Vector3(5.0, 1.1, 0.08), Vector3(25.0, 0.55, -4.6), main.mat_wood_dark)
	main._box(root, Vector3(5.1, 0.1, 0.9), Vector3(25.0, 1.15, -5.0), main.mat_wood)
	main._box(root, Vector3(0.08, 1.1, 0.8), Vector3(22.5, 0.55, -5.0), main.mat_wood_dark)
	main._box(root, Vector3(0.08, 1.1, 0.8), Vector3(27.5, 0.55, -5.0), main.mat_wood_dark)
	main._hideout(root, "HideBalcao", Vector3(25.0, 0.5, -5.05), Vector3(4.8, 1.0, 0.75))
	var porcelain: Material = main._mat("#ece6da", 0.3)
	for i in 3:
		main._breakable(root, "Xicara%d" % (i + 1), &"porcelana", Vector3(0.11, 0.09, 0.11), Vector3(23.6 + i * 0.5, 1.245, -4.95), porcelain, 1)
	# A shelf of vases on the east wall.
	main._box(root, Vector3(0.3, 0.04, 3.2), Vector3(x1 - 0.22, 1.35, -4.5), main.mat_wood)
	for i in 3:
		main._breakable(root, "Vaso%d" % (i + 1), &"porcelana", Vector3(0.18, 0.3, 0.18), Vector3(x1 - 0.22, 1.52, -5.6 + i * 1.1), porcelain, 1)
	main._omni(root, Vector3(25.0, 2.4, -4.0), Color(1.0, 0.76, 0.5), 0.3, 6.0)

static func _build_back_room(main: Node3D, root: Node3D) -> void:
	var z0 := SHOP.position.y
	# A curtain of dark cloth in the doorway: strips, nothing to stop him.
	var cloth: Material = main._mat("#2a2024", 1.0)
	for i in 5:
		main._box(root, Vector3(0.2, 2.0, 0.02), Vector3(27.1 + i * 0.2, 1.05, PARTITION_Z + (0.02 if i % 2 == 0 else -0.02)), cloth, false, Vector3(0.0, 0.0, deg_to_rad(1.5 * (i - 2))))

	# The workbench along the back wall, the vise, a stool, the apron.
	main._box(root, Vector3(8.0, 0.9, 0.9), Vector3(25.0, 0.45, z0 + 0.55), main.mat_wood_dark)
	main._box(root, Vector3(8.05, 0.06, 0.95), Vector3(25.0, 0.93, z0 + 0.55), main.mat_wood, false)
	main._box(root, Vector3(0.3, 0.25, 0.3), Vector3(22.0, 1.08, z0 + 0.6), main._mat("#4a4d52", 0.5, 0.7), false)
	main._cyl(root, 0.2, 0.6, Vector3(25.3, 0.3, z0 + 1.4), main.mat_wood)
	main._box(root, Vector3(0.5, 0.8, 0.03), Vector3(SHOP.position.x + 0.1, 1.3, z0 + 2.6), main._mat("#6a5a46", 1.0), false, Vector3(0.0, deg_to_rad(90.0), 0.0))
	for i in 6:
		main._box(root, Vector3(0.03, 0.18, 0.03), Vector3(23.0 + i * 0.12, 1.05, z0 + 0.25), main._mat("#8a8d93", 0.35, 0.85), false)

	# The lamp over the bench, and under it the case of the pocket watch.
	var shade := CylinderMesh.new()
	shade.top_radius = 0.06
	shade.bottom_radius = 0.24
	shade.height = 0.2
	main._add_mesh(root, shade, Vector3(25.0, 1.75, z0 + 0.7), main.mat_cream)
	main._omni(root, Vector3(25.0, 1.55, z0 + 0.8), Color(1.0, 0.74, 0.45), 0.55, 4.5)
	main._piece(root, &"caixa", Vector3(25.0, 0.96, z0 + 0.6))

## A wall clock facing +z in its own frame (turned by `yaw`): rim, face,
## hands stopped before 03:33, and a second hand that ticks every `period`
## seconds, which is never exactly one.
static func _clock(main: Node3D, parent: Node3D, pos: Vector3, yaw: float, r: float, period: float, rng: RandomNumberGenerator) -> void:
	var c := Node3D.new()
	c.position = pos
	c.rotation.y = yaw
	parent.add_child(c)
	var flat := Vector3(deg_to_rad(90.0), 0.0, 0.0)
	main._cyl(c, r + 0.025, 0.03, Vector3(0.0, 0.0, 0.0), main.mat_brass, false, flat)
	main._cyl(c, r, 0.03, Vector3(0.0, 0.0, 0.012), main.mat_cream, false, flat)
	var minutes := rng.randi_range(0, 3 * 60 + 32)
	var h := float(minutes) / 60.0
	var hands := [[-h / 12.0 * TAU, r * 0.5, 0.025], [-fmod(h, 1.0) * TAU, r * 0.8, 0.018]]
	for hand in hands:
		var pivot := Node3D.new()
		pivot.position = Vector3(0.0, 0.0, 0.032)
		pivot.rotation.z = hand[0]
		c.add_child(pivot)
		main._box(pivot, Vector3(hand[2], hand[1], 0.006), Vector3(0.0, hand[1] * 0.5, 0.0), main.mat_dark, false)
	var sec := Node3D.new()
	sec.position = Vector3(0.0, 0.0, 0.038)
	sec.rotation.z = -rng.randi_range(0, 59) * TAU / 60.0
	c.add_child(sec)
	main._box(sec, Vector3(0.006, r * 0.9, 0.004), Vector3(0.0, r * 0.35, 0.0), main.mat_red, false)
	var tw := sec.create_tween().set_loops()
	tw.tween_interval(maxf(0.05, period - 0.06))
	tw.tween_property(sec, "rotation:z", -TAU / 60.0, 0.06).as_relative()
