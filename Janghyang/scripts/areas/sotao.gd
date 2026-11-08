extends RefCounted
## Above the house: the attic, boards and sheets over what nobody uses. The
## tower of the movement rises through it (mecanismo.gd); the shaft from the
## passage comes up by its west end.

const Mecanismo = preload("res://scripts/areas/mecanismo.gd")

const Y := 2.94
const TOP := 5.24
const TOWER := Mecanismo.TOWER

const DEF := {
	"id": &"sotao",
	"maquete": &"item_214",
	"name": "O sótão",
	"rooms": [
		{"id": &"sotao", "name": "sótão", "rect": Rect2(0.3, -1.3, 14.8, 10.1), "y": Vector2(2.8, 5.3)},
	],
	"safe": Vector3(9.8, 3.14, 0.55),
	"links": [
		{"to": &"passagem", "at": Vector3(9.8, 3.14, -0.65)},
		{"to": &"mecanismo", "at": Vector3(7.9, 3.14, 5.0), "path": [Vector3(11.2, 3.14, 0.55), Vector3(11.2, 3.14, 7.4), Vector3(7.9, 3.14, 7.4)], "gate": &"DoorTower"},
	],
	"tasks": {&"sotao": &"subir_sotao"},
}

static func build(main: Node3D) -> void:
	var root := Node3D.new()
	root.name = "Sotao"
	main.add_child(root)
	var boards: Material = main._mat("#4b3a2a", 0.95)
	var beam: Material = main.mat_wood_dark
	var sheet: Material = main._mat("#cfc8b8", 1.0)

	# Floor around the shaft hole (x 9.2..10.4, z -1.3..0).
	_slab(main, root, 0.3, -1.3, 9.2, 8.8, Y, boards)
	_slab(main, root, 9.2, 0.0, 10.4, 8.8, Y, boards)
	_slab(main, root, 10.4, -1.3, 15.1, 8.8, Y, boards)
	# Walls and a ceiling with the tower going through it.
	main._wall_z(root, -1.37, 0.2, 15.2, Y, TOP, beam)
	main._wall_z(root, 8.87, 0.2, 15.2, Y, TOP, beam)
	main._wall_x(root, 0.23, -1.37, 8.87, Y, TOP, beam)
	main._wall_x(root, 15.17, -1.37, 8.87, Y, TOP, beam)
	_slab(main, root, 0.2, -1.37, 15.2, TOWER.position.y, TOP + 0.12, beam)
	_slab(main, root, 0.2, TOWER.end.y, 15.2, 8.87, TOP + 0.12, beam)
	_slab(main, root, 0.2, TOWER.position.y, TOWER.position.x, TOWER.end.y, TOP + 0.12, beam)
	_slab(main, root, TOWER.end.x, TOWER.position.y, 15.2, TOWER.end.y, TOP + 0.12, beam)
	for x in [1.0, 2.6, 4.2, 12.0, 13.6]:
		main._box(root, Vector3(0.14, 0.2, 10.2), Vector3(x, TOP - 0.1, 3.75), beam, false)

	# A round window to the west and the little light it lets in.
	main._cyl(root, 0.42, 0.04, Vector3(0.31, Y + 1.5, 3.5), main.mat_window, false, Vector3(0.0, 0.0, deg_to_rad(90.0)))
	main._omni(root, Vector3(1.6, Y + 1.5, 3.5), Color(0.6, 0.7, 0.95), 0.45, 4.5)
	main._omni(root, Vector3(12.6, Y + 1.9, 4.2), Color(1.0, 0.7, 0.42), 0.22, 5.0)

	# Sheets over what nobody uses; one of them is tall as a man.
	main._box(root, Vector3(1.8, 0.9, 1.0), Vector3(1.4, Y + 0.45, 6.4), sheet)
	main._box(root, Vector3(1.2, 0.7, 0.9), Vector3(12.8, Y + 0.35, -0.6), sheet)
	main._box(root, Vector3(1.4, 1.1, 1.4), Vector3(13.4, Y + 0.55, 3.0), sheet)
	var tall: Node3D = main._box(root, Vector3(0.7, 1.75, 0.6), Vector3(13.6, Y + 0.875, 7.9), sheet)
	tall.name = "SheetFigure"
	main._cyl(root, 0.32, 0.25, Vector3(13.6, Y + 1.9, 7.9), sheet, false)
	main._catalog_target(root, &"lencois", Vector3(13.6, Y + 1.0, 7.9), Vector3(0.9, 2.0, 0.8))
	main._box(root, Vector3(0.9, 0.55, 0.55), Vector3(1.2, Y + 0.275, 1.6), main.mat_wood)
	main._box(root, Vector3(0.95, 0.06, 0.6), Vector3(1.2, Y + 0.58, 1.6), main.mat_brass, false)


static func _slab(main: Node3D, parent: Node3D, x0: float, z0: float, x1: float, z1: float, top: float, m: Material) -> Node3D:
	return main._box(parent, Vector3(x1 - x0, 0.12, z1 - z0), Vector3((x0 + x1) * 0.5, top - 0.06, (z0 + z1) * 0.5), m)
