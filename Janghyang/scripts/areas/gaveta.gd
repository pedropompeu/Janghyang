extends RefCounted
## Under the bench top, the long drawer Inácio kept his failures in: giant
## gears, screws standing like columns, a mainspring, a thimble on its side
## that a man can crawl into, and an open watch case with the dial in it.
## Its only light is the slit of the drawer front, left ajar. The way down is
## the bedroom's trapdoor and a ladder.

const Y := -3.2
const CEIL := -0.52
const X0 := -1.0
const X1 := 17.0
const Z0 := -1.0
const Z1 := 13.0
const HOLE := Rect2(14.45, 0.0, 0.95, 1.0)
const SLIT := -0.75

const DEF := {
	"id": &"gaveta",
	"maquete": &"item_214",
	"name": "A gaveta",
	"rooms": [
		{"id": &"gaveta", "name": "gaveta", "rect": Rect2(X0, Z0, X1 - X0, Z1 - Z0), "y": Vector2(-3.6, -0.5)},
	],
	"safe": Vector3(14.9, -3.0, 1.9),
	"links": [
		{"to": &"casa", "at": Vector3(14.9, 0.2, 1.3), "path": [Vector3(14.925, -3.0, 0.52), Vector3(14.925, 0.2, 0.52)], "gate": &"Trapdoor"},
	],
	"tasks": {&"gaveta": &"descer_gaveta"},
	"breaks": {"Trapdoor": &"achar_alcapao"},
}

static func build(main: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Gaveta"
	main.add_child(root)
	var wood: Material = main._mat("#3a2a1e", 0.95)
	var inner: Material = main._mat("#5c4430", 0.9)
	var brass: Material = main.mat_brass
	var steel: Material = main._mat("#6d6f75", 0.45, 0.8)

	# Floor, walls, and the bench top for a ceiling with the trapdoor's hole.
	main._box(root, Vector3(X1 - X0, 0.12, Z1 - Z0), Vector3((X0 + X1) * 0.5, Y - 0.06, (Z0 + Z1) * 0.5), inner)
	main._wall_x(root, X0, Z0, Z1, Y, CEIL, wood)
	main._wall_x(root, X1, Z0, Z1, Y, CEIL, wood)
	main._wall_z(root, Z0, X0, X1, Y, CEIL, wood)
	main._wall_z(root, Z1, X0, X1, Y, SLIT, wood)
	_ceil(main, root, X0, Z0, X1, HOLE.position.y, wood)
	_ceil(main, root, X0, HOLE.end.y, X1, Z1, wood)
	_ceil(main, root, X0, HOLE.position.y, HOLE.position.x, HOLE.end.y, wood)
	_ceil(main, root, HOLE.end.x, HOLE.position.y, X1, HOLE.end.y, wood)
	# The hole's sides through the thickness of the bench.
	main._wall_x(root, HOLE.position.x - 0.07, HOLE.position.y, HOLE.end.y, CEIL, -0.12, wood)
	main._wall_x(root, HOLE.end.x + 0.07, HOLE.position.y, HOLE.end.y, CEIL, -0.12, wood)
	main._wall_z(root, HOLE.position.y - 0.07, HOLE.position.x, HOLE.end.x, CEIL, -0.12, wood)
	main._wall_z(root, HOLE.end.y + 0.07, HOLE.position.x, HOLE.end.x, CEIL, -0.12, wood)

	# The ladder down from the bedroom.
	main._rungs(root, Vector3(14.925, Y, 0.1), -Y + 0.05, true)
	main._ladder_area(root, "LadderDrawer", Vector3(14.925, (Y + 0.6) * 0.5, 0.52), Vector3(0.9, 0.6 - Y, 0.9))
	main._omni(root, Vector3(14.9, -1.3, 1.2), Color(1.0, 0.68, 0.4), 0.22, 3.0)

	# The slit of light at the front of the drawer.
	var glow: StandardMaterial3D = main._mat("#ffe0a8", 1.0)
	glow.emission_enabled = true
	glow.emission = Color(1.0, 0.85, 0.6)
	glow.emission_energy_multiplier = 2.0
	main._box(root, Vector3(X1 - X0, CEIL - SLIT, 0.02), Vector3((X0 + X1) * 0.5, (SLIT + CEIL) * 0.5, Z1 + 0.06), glow, false)
	main._omni(root, Vector3(8.0, -0.9, Z1 - 0.5), Color(1.0, 0.82, 0.55), 0.6, 6.0)
	main._omni(root, Vector3(2.0, -0.9, Z1 - 0.5), Color(1.0, 0.82, 0.55), 0.4, 5.0)

	# Failures: gears flat and on edge, screws, the mainspring.
	main._cyl(root, 2.0, 0.3, Vector3(5.0, Y + 0.15, 2.6), brass)
	main._cyl(root, 1.3, 0.25, Vector3(10.5, Y + 0.125, 6.5), brass)
	main._cyl(root, 1.4, 0.22, Vector3(16.3, Y + 1.4, 7.0), brass, true, Vector3(0.0, 0.0, deg_to_rad(80.0)))
	for p in [Vector3(11.5, 0.0, 2.2), Vector3(2.4, 0.0, 6.0), Vector3(8.6, 0.0, 9.6), Vector3(13.4, 0.0, 10.4)]:
		main._cyl(root, 0.24, CEIL - Y, Vector3(p.x, (Y + CEIL) * 0.5, p.z), steel)
		for k in 6:
			main._box(root, Vector3(0.6, 0.05, 0.08), Vector3(p.x, Y + 0.3 + k * 0.38, p.z), steel, false, Vector3(0.2, k * 0.5, 0.0))
	for r in [0.35, 0.6, 0.85, 1.1]:
		var ring := TorusMesh.new()
		ring.inner_radius = r - 0.05
		ring.outer_radius = r + 0.05
		main._add_mesh(root, ring, Vector3(12.5, Y + 0.05, 8.5), steel)

	# The thimble on its side, open to the east: crouch inside to hide.
	var silver: StandardMaterial3D = main._mat("#b9bcc2", 0.35, 0.85)
	silver.cull_mode = BaseMaterial3D.CULL_DISABLED
	var shell := CylinderMesh.new()
	shell.top_radius = 0.78
	shell.bottom_radius = 0.72
	shell.height = 1.7
	shell.cap_top = false
	main._add_mesh(root, shell, Vector3(6.0, Y + 0.76, 7.0), silver, Vector3(0.0, 0.0, deg_to_rad(-90.0)))
	main._box(root, Vector3(1.7, 0.1, 1.3), Vector3(6.0, Y + 1.25, 7.0), silver, true)
	main._box(root, Vector3(1.7, 1.2, 0.1), Vector3(6.0, Y + 0.6, 6.32), silver, true)
	main._box(root, Vector3(1.7, 1.2, 0.1), Vector3(6.0, Y + 0.6, 7.68), silver, true)
	main._box(root, Vector3(0.1, 1.4, 1.4), Vector3(5.12, Y + 0.7, 7.0), silver, true)
	main._hideout(root, "HideDedal", Vector3(5.95, Y + 0.5, 7.0), Vector3(1.4, 1.0, 1.1))
	main._catalog_target(root, &"dedal", Vector3(6.0, Y + 0.76, 7.0), Vector3(1.8, 1.6, 1.6))

	# The open watch case, and the dial lying in it.
	main._cyl(root, 1.4, 0.45, Vector3(3.0, Y + 0.225, 10.6), brass)
	main._cyl(root, 1.4, 0.08, Vector3(3.0, Y + 1.4, 11.95), brass, false, Vector3(deg_to_rad(-80.0), 0.0, 0.0))
	main._piece(root, &"mostrador", Vector3(3.0, Y + 0.45, 10.6))

	# Chalk: a cross on the bedroom floor over the trapdoor.
	main._chalk(root, Vector3(0.8, 0.01, 0.05), Vector3(14.925, 0.006, 0.5), Vector3(0.0, 0.8, 0.0))
	main._chalk(root, Vector3(0.8, 0.01, 0.05), Vector3(14.925, 0.006, 0.5), Vector3(0.0, -0.8, 0.0))

static func _ceil(main: Node3D, parent: Node3D, x0: float, z0: float, x1: float, z1: float, m: Material) -> void:
	main._box(parent, Vector3(x1 - x0, 0.12, z1 - z0), Vector3((x0 + x1) * 0.5, CEIL + 0.06, (z0 + z1) * 0.5), m)
