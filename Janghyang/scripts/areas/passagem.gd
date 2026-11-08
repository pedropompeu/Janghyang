extends RefCounted
## Behind the playroom's north wall, under the drawing: the boy's crawlspace.
## A hollow panel opens onto it; it runs east, low enough that Elias has to
## crouch, to a dead end where the crown waits, and to a shaft with a ladder
## that climbs to the attic.

const ATTIC_Y := 2.94
const CRAWL_TOP := 1.3

## Links run from the safe point through `path` to `at`. Both cross the hollow
## panel, so both are gated by it.
const DEF := {
	"id": &"passagem",
	"maquete": &"item_214",
	"name": "A passagem",
	"rooms": [
		{"id": &"passagem", "name": "passagem", "rect": Rect2(0.3, -1.3, 10.1, 1.3), "y": Vector2(-0.4, 2.9)},
	],
	"safe": Vector3(6.7, 0.2, 1.2),
	"safe_room": &"brincar",
	"links": [
		{"to": &"casa", "at": Vector3(6.7, 0.2, 0.0), "gate": &"HollowPanel"},
		{"to": &"sotao", "at": Vector3(10.12, 0.2, -0.65), "path": [Vector3(6.7, 0.2, -0.6), Vector3(8.4, 0.2, -0.6)], "gate": &"HollowPanel"},
	],
	"tasks": {&"passagem": &"achar_passagem"},
	"breaks": {"HollowPanel": &"achar_passagem"},
}

static func build(main: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Passagem"
	main.add_child(root)
	var plank: Material = main._mat("#5b4734", 0.95)
	var wall: Material = main.mat_wood_dark

	# Floor, the low ceiling (the shaft at the east end is open), the walls.
	main._floor(root, 0.3, -1.3, 10.4, 0.0, plank)
	main._box(root, Vector3(8.9, 0.12, 1.3), Vector3(4.75, CRAWL_TOP + 0.06, -0.65), wall)
	main._wall_z(root, -1.37, 0.2, 10.47, 0.0, ATTIC_Y, wall)
	main._wall_x(root, 0.23, -1.37, 0.0, 0.0, CRAWL_TOP + 0.12, wall)
	main._wall_x(root, 9.2, -1.3, -0.07, CRAWL_TOP + 0.12, ATTIC_Y, wall)
	main._wall_x(root, 10.47, -1.37, 0.0, 0.0, ATTIC_Y, wall)

	# Joists overhead and a few things the boy kept here.
	for i in 9:
		main._box(root, Vector3(0.1, 0.08, 1.25), Vector3(0.9 + i * 1.0, CRAWL_TOP - 0.04, -0.65), plank, false)
	main._box(root, Vector3(0.5, 0.3, 0.35), Vector3(1.6, 0.15, -1.0), main.mat_wood)
	main._box(root, Vector3(0.22, 0.04, 0.3), Vector3(2.4, 0.02, -0.4), main.mat_cream, false, Vector3(0.0, 0.4, 0.0))
	main._cyl(root, 0.09, 0.03, Vector3(3.1, 0.015, -0.9), main.mat_red, false)

	# The crown at the west dead end, a glint of brass in the dark.
	main._piece(root, &"coroa", Vector3(0.75, 0.0, -0.65))
	main._omni(root, Vector3(0.9, 0.5, -0.65), Color(1.0, 0.75, 0.45), 0.18, 1.6)

	# The shaft: a ladder on the east wall up to the attic floor.
	main._rungs(root, Vector3(10.36, 0.0, -0.65), ATTIC_Y + 0.1, false)
	main._ladder_area(root, "LadderShaft", Vector3(10.12, 1.85, -0.68), Vector3(0.55, 3.7, 1.2))

	# Chalk: the boy's door drawn around the panel (playroom side), arrows
	# along the crawl, a door drawn at the dead end, marks of his height.
	main._chalk_frame(root, Vector3(6.7, 0.6, 0.085), 1.1, 1.25, false)
	main._chalk(root, Vector3(0.18, 0.035, 0.01), Vector3(6.7, 1.32, 0.085), Vector3(0.0, 0.0, 0.5))
	for x in [8.2, 5.2, 3.2]:
		main._chalk(root, Vector3(0.5, 0.01, 0.04), Vector3(x, 0.006, -0.65))
		main._chalk(root, Vector3(0.22, 0.01, 0.04), Vector3(x - 0.2, 0.006, -0.58), Vector3(0.0, 0.7, 0.0))
		main._chalk(root, Vector3(0.22, 0.01, 0.04), Vector3(x - 0.2, 0.006, -0.72), Vector3(0.0, -0.7, 0.0))
	main._chalk_frame(root, Vector3(0.31, 0.55, -0.65), 0.6, 0.9, true)
	for y in [0.55, 0.7, 0.86, 1.02]:
		main._chalk(root, Vector3(0.2, 0.025, 0.01), Vector3(9.6, y, -1.29))
