extends RefCounted
## The bench the models stand on, and the Relojoaria Varela out on it: the
## second model Inácio built. leste.gd builds the bench east of the dome, the
## crack, the shop and its back room; this file adds Inácio's real workshop
## around everything, at GIANT scale. The way in is the cracked glass of the
## dome (built with the house, maquete item_214).

const AreaLeste = preload("res://scripts/areas/leste.gd")
const AreaGaveta = preload("res://scripts/areas/gaveta.gd")

const DEF := {
	"id": &"tampo",
	"maquete": &"item_215",
	"name": "O tampo",
	"rooms": [
		{"id": &"loja_varela", "name": "Relojoaria Varela", "rect": Rect2(20.0, -7.0, 10.0, 5.0), "y": Vector2(-0.4, 3.0)},
		{"id": &"oficina_varela", "name": "oficina dos fundos", "rect": Rect2(20.0, -12.0, 10.0, 5.0), "y": Vector2(-0.4, 3.0)},
		{"id": &"tampo_leste", "name": "bancada", "rect": Rect2(15.4, -16.0, 18.6, 29.4), "y": Vector2(-0.4, 3.0)},
	],
	"safe": AreaLeste.SAFE,
	"links": [
		{"to": &"casa", "at": Vector3(12.0, 0.2, 10.4), "path": [Vector3(16.6, 0.2, 10.4)], "gate": &"CrackedGlass"},
	],
	"tasks": {&"loja_varela": &"chegar_relojoaria"},
	"breaks": {"CrackedGlass": &"quebrar_redoma"},
}

static func build(main: Node3D) -> void:
	_build_oficina(main)
	AreaLeste.build(main)

static func _build_oficina(main: Node3D) -> void:
	# Inácio's real workshop at GIANT scale. Nothing here collides: it is only
	# ever seen through the dome and the windows.
	var oficina := Node3D.new()
	oficina.name = "Oficina"
	main.add_child(oficina)
	var bench_y: float = -0.8 * main.GIANT
	# Bench top around the model, its front edge and the floor far below.
	main._slab_with_holes(oficina, -34.0, -40.0, 46.0, 13.5, -0.52, -0.12, [AreaGaveta.HOLE, AreaLeste.GROOVE], main.mat_wood_dark)
	main._box(oficina, Vector3(80.0, 9.6, 0.4), Vector3(6.0, -4.8, 13.5), main.mat_wood_dark, false)
	main._box(oficina, Vector3(90.0, 0.4, 40.0), Vector3(6.0, bench_y - 0.2, 33.5), main.mat_floor_corridor, false)
	# Back wall to the north, with a rain window at 12x.
	main._box(oficina, Vector3(90.0, 40.0, 0.5), Vector3(6.0, 10.0, -40.0), main.mat_wall_exterior, false)
	var win_c := Vector3(6.0, 12.0, -39.7)
	main._box(oficina, Vector3(2.8 * main.GIANT, 1.5 * main.GIANT, 0.2), win_c, main.mat_window, false)
	main._box(oficina, Vector3(3.0 * main.GIANT, 0.08 * main.GIANT, 0.6), win_c + Vector3(0.0, 0.75 * main.GIANT, 0.2), main.mat_wood, false)
	main._box(oficina, Vector3(3.0 * main.GIANT, 0.08 * main.GIANT, 0.6), win_c + Vector3(0.0, -0.75 * main.GIANT, 0.2), main.mat_wood, false)
	main._box(oficina, Vector3(0.08 * main.GIANT, 1.5 * main.GIANT, 0.6), win_c + Vector3(-1.4 * main.GIANT, 0.0, 0.2), main.mat_wood, false)
	main._box(oficina, Vector3(0.08 * main.GIANT, 1.5 * main.GIANT, 0.6), win_c + Vector3(1.4 * main.GIANT, 0.0, 0.2), main.mat_wood, false)
	for i in range(14):
		var x: float = win_c.x - 1.3 * main.GIANT + i * 0.2 * main.GIANT
		main._box(oficina, Vector3(0.012 * main.GIANT, 1.2 * main.GIANT, 0.1), Vector3(x, win_c.y, win_c.z + 0.2), main.mat_rain, false, Vector3(0.0, 0.0, deg_to_rad(-8.0)))
	main._omni(oficina, Vector3(6.0, 10.0, -36.0), Color(0.45, 0.6, 0.8), 1.2, 30.0, false)
	# The giant desk lamp leaning over the bench.
	var shade := CylinderMesh.new()
	shade.top_radius = 0.07 * main.GIANT
	shade.bottom_radius = 0.28 * main.GIANT
	shade.height = 0.22 * main.GIANT
	main._add_mesh(oficina, shade, Vector3(6.0, 19.2, 16.0), main.mat_cream)
	var lamp: OmniLight3D = main._omni(oficina, Vector3(6.0, 18.0, 16.0), Color(1.0, 0.74, 0.45), 1.6, 45.0, false)
	lamp.name = "WorkshopLamp"
	# Night 1 puts it out with the windows (setpieces/luz_de_fora.gd).
	lamp.add_to_group(&"OutsideLight")
