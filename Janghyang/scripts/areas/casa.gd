extends RefCounted
## The Moreira house: the eight rooms of the model Elias wakes in, its
## furniture, the entry clock, the pieces of the truth, and the tabletop the
## model stands on (the dome and its cracked pane). Every other area links
## back here; links run both ways, so the house needs none of its own.

const AreaGaveta = preload("res://scripts/areas/gaveta.gd")

## The hollow part of the playroom's north wall, under the drawing (x, y).
const PANEL := Rect2(6.15, 0.0, 1.1, 1.25)

## The cracked pane of the dome's east wall, out onto the bench (z range).
const CRACKED_Z := Vector2(9.1, 12.5)

## The entry clock, against the facade beside the front door.
const ENTRY_CLOCK := Vector3(3.1, 1.0, 8.88)

## The street door's hinge, and the house's hiding places (name -> centre,
## size): the bench's figures keep clear of both (bench_model.may_land).
const DOOR_FRONT := Vector3(1.12, 0.0, 9.1)
const HIDEOUTS := {
	"HideCabana": [Vector3(1.0, 0.5, 3.5), Vector3(1.8, 1.0, 2.4)],
	"HideCama": [Vector3(14.85, 0.5, 2.7), Vector3(0.9, 1.0, 2.2)],
}

const DEF := {
	"id": &"casa",
	"maquete": &"item_214",
	"name": "A casa",
	"rooms": [
		{"id": &"entrada", "name": "entrada", "rect": Rect2(0.0, 7.0, 3.5, 2.1), "y": Vector2(-0.4, 2.8)},
		{"id": &"brincar", "name": "quarto de brincar", "rect": Rect2(0.0, 0.0, 8.4, 7.0), "y": Vector2(-0.4, 2.8)},
		{"id": &"corredor", "name": "corredor", "rect": Rect2(8.4, 0.0, 2.1, 7.7), "y": Vector2(-0.4, 2.8)},
		{"id": &"quarto", "name": "quarto", "rect": Rect2(10.5, 0.0, 4.9, 5.6), "y": Vector2(-0.4, 2.8)},
		{"id": &"figuras", "name": "sala das figuras", "rect": Rect2(10.5, 5.6, 4.9, 3.5), "y": Vector2(-0.4, 2.8)},
		{"id": &"corredor_sul", "name": "corredor da frente", "rect": Rect2(3.5, 7.7, 7.0, 1.4), "y": Vector2(-0.4, 2.8)},
		{"id": &"beira_oeste", "name": "beira oeste", "rect": Rect2(-3.2, 0.0, 3.2, 9.1), "y": Vector2(-0.4, 2.8)},
		{"id": &"beira_sul", "name": "beira sul", "rect": Rect2(0.0, 9.1, 15.4, 3.4), "y": Vector2(-0.4, 2.8)},
	],
	## Where the game starts (main.SPAWN).
	"safe": Vector3(1.8, 0.2, 8.3),
	## Chapter 1's staged scene (main._build_staging, staging_model.gd): the
	## father and the boy by the playroom's north wall; it ends at the panel.
	## Each figure: a style, a scale, a body (mannequin.BODIES, adulto when
	## left out) and one pose per step ({at, face, pose, reach}). Meshes only:
	## nothing to bump into, no Gasto graph changes.
	## The scripted scenes (main._build_setpieces).
	"setpieces": [
		{"id": &"luz_de_fora", "script": preload("res://scripts/setpieces/luz_de_fora.gd")},
		{"id": &"vitrine", "script": preload("res://scripts/setpieces/vitrine.gd"), "at": Vector3(15.1, 0.0, 8.2)},
		{"id": &"chave_vitrine", "script": preload("res://scripts/setpieces/chave_vitrine.gd"), "at": Vector3(1.78, 0.02, 3.5)},
		{"id": &"desenho_cera", "script": preload("res://scripts/setpieces/desenho_cera.gd"), "at": Vector3(14.05, 1.5, 0.08)},
		{"id": &"banco", "script": preload("res://scripts/setpieces/banco.gd"), "at": Vector3(13.1, 0.0, 5.95)},
		{"id": &"bola_quica", "script": preload("res://scripts/setpieces/bola_quica.gd"), "at": Vector3(9.45, 0.0, 0.5),
				"ends": [Vector3(9.45, 0.0, 0.5), Vector3(9.45, 0.0, 6.9)]},
	],
	## The bench along the figure room's north wall (spec §6.2): where the
	## figures sit, side by side, facing the room.
	"bench": {"seats": [Vector3(11.3, 0.0, 5.95), Vector3(11.9, 0.0, 5.95), Vector3(12.5, 0.0, 5.95), Vector3(13.1, 0.0, 5.95), Vector3(13.7, 0.0, 5.95), Vector3(14.3, 0.0, 5.95), Vector3(14.9, 0.0, 5.95)], "face": Vector3(0.0, 0.0, 1.0),
		## Where the figures go, in this order (setpieces/banco.gd, bench_model.gd).
		"away": [
			{"at": Vector3(12.0, 0.0, 3.0), "face": Vector3(11.0, 0.0, 3.0), "pose": &"sentado"},
			{"at": Vector3(9.45, 0.0, 0.5), "face": Vector3(9.45, 0.0, 1.5), "pose": &"em_pe"},
			{"at": Vector3(0.5, 0.0, 0.5), "face": Vector3(0.0, 0.0, 0.0), "pose": &"em_pe"},
		]},
	"staging": [
		{"chapter": 1, "figures": [
			{"style": {"coat": Color("#5a4636"), "skin": Color("#d1b195"), "hair": Color("#8a8378"), "trousers": Color("#2f2a26")}, "scale": 0.75, "poses": [
				{"at": Vector3(6.1, 0.0, 2.4), "face": Vector3(5.6, 0.4, 2.9), "pose": &"sentado"},
				{"at": Vector3(6.4, 0.0, 1.1), "face": Vector3(6.7, 0.7, 0.0), "pose": &"em_pe", "reach": Vector3(6.7, 0.9, 0.0)},
				{"at": Vector3(5.4, 0.0, 1.4), "face": Vector3(6.7, 0.4, 0.4), "pose": &"em_pe"},
				{"at": Vector3(5.2, 0.0, 1.9), "face": Vector3(6.7, 0.4, 0.4), "pose": &"sentado"},
			]},
			{"style": {"coat": Color("#6b5a3e"), "skin": Color("#dcbfa2"), "hair": Color("#3e2e22"), "trousers": Color("#3a3430")}, "scale": 0.45, "body": &"menino", "poses": [
				{"at": Vector3(5.6, 0.0, 2.9), "face": Vector3(6.1, 0.5, 2.4), "pose": &"em_pe"},
				{"at": Vector3(5.9, 0.0, 1.9), "face": Vector3(6.7, 0.6, 0.0), "pose": &"em_pe"},
				{"at": Vector3(6.5, 0.0, 0.7), "face": Vector3(6.7, 0.4, 0.0), "pose": &"agachado"},
				{"at": Vector3(6.7, 0.0, 0.35), "face": Vector3(6.7, 0.4, 0.0), "pose": &"agachado", "reach": Vector3(6.7, 0.5, 0.0)},
			]},
		]},
	],
	## Spec §11: no Gasto ever blocks the street door.
	"keep_clear": [&"DoorFront"],
	## Light along the way (light_model.gd): batteries, boxes of matches, candles to light.
	"pickups": [
		{"id": &"pilha_brincar", "kind": &"pilha", "at": Vector3(1.2, 0.05, 1.0)},
		{"id": &"pilha_quarto", "kind": &"pilha", "at": Vector3(11.2, 0.05, 0.8)},
		{"id": &"pilha_figuras", "kind": &"pilha", "at": Vector3(12.9, 0.05, 8.7)},
		{"id": &"vela_brincar", "kind": &"vela", "at": Vector3(7.6, 0.05, 6.3)},
		{"id": &"vela_corredor", "kind": &"vela", "at": Vector3(9.45, 0.05, 6.9)},
		{"id": &"vela_quarto", "kind": &"vela", "at": Vector3(11.0, 0.05, 5.0)},
		{"id": &"fosforo_entrada", "kind": &"fosforo", "at": Vector3(0.6, 0.05, 8.6), "n": 4},
		{"id": &"fosforo_corredor_sul", "kind": &"fosforo", "at": Vector3(9.8, 0.05, 8.6), "n": 4},
		{"id": &"fosforo_cabeceira", "kind": &"fosforo", "at": Vector3(13.95, 0.62, 0.35), "n": 3},
	],
	## The boy's chalk trails (main._build_chalk_trails), seen with eyes closed.
	"chalk": [
		{"id": &"giz_vitrine", "points": [Vector3(14.6, 0.006, 8.2), Vector3(12.9, 0.006, 7.2), Vector3(10.9, 0.006, 8.0), Vector3(9.4, 0.006, 8.4), Vector3(6.0, 0.006, 8.4), Vector3(3.9, 0.006, 8.4), Vector3(2.4, 0.006, 7.7), Vector3(1.8, 0.006, 6.9), Vector3(1.8, 0.006, 5.4), Vector3(1.78, 0.006, 3.9)], "leads_to": &"chave_vitrine"},
		{"id": &"giz_quarto", "points": [Vector3(9.45, 0.006, 5.0), Vector3(9.45, 0.006, 3.0), Vector3(10.9, 0.006, 1.6), Vector3(11.0, 0.006, 1.1)], "leads_to": &"pilha_quarto"},
	],
	"catalog": {&"relogio_entrada": &"cat_relogio", &"desenho": &"cat_desenho", &"casinha": &"cat_casinha", &"pagina_cabana": &"pagina"},
	## What Elias can write down (main._build_catalog_targets). The page under
	## the cabana cushion only shows after 03:33 (main.reveal_cabana_page).
	"targets": [
		{"item": &"relogio_entrada", "at": Vector3(3.1, 1.2, 8.8), "size": Vector3(0.55, 1.6, 0.4)},
		{"item": &"bola", "node": "Ball", "size": Vector3(0.4, 0.4, 0.4)},
		{"item": &"caixa_musica", "at": Vector3(3.35, 0.7, 4.45), "size": Vector3(0.45, 0.3, 0.35)},
		{"item": &"desenho", "at": Vector3(14.05, 1.5, 0.12), "size": Vector3(0.8, 0.6, 0.15)},
		{"item": &"casinha", "at": Vector3(15.05, 0.78, 8.2), "size": Vector3(0.45, 0.4, 0.6)},
		{"item": &"vitrine", "at": Vector3(14.86, 1.35, 8.2), "size": Vector3(0.1, 0.4, 1.0)},
		{"item": &"cabana", "at": Vector3(1.0, 0.4, 3.5), "size": Vector3(1.4, 0.8, 1.6)},
		{"item": &"cama", "at": Vector3(13.2, 0.5, 3.0), "size": Vector3(2.2, 0.6, 3.1)},
		{"item": &"espelho", "at": Vector3(15.25, 1.35, 2.0), "size": Vector3(0.15, 1.6, 1.0)},
		{"item": &"boneco", "node": "Doll", "at": Vector3(0.0, 0.3, 0.0), "size": Vector3(0.55, 1.0, 0.35)},
		{"item": &"vela", "at": Vector3(11.85, 0.6, 7.7), "size": Vector3(0.25, 0.3, 0.25)},
		{"item": &"casaco", "at": Vector3(0.2, 1.2, 7.6), "size": Vector3(0.25, 0.9, 0.5)},
		{"item": &"banco_figuras", "at": Vector3(13.1, 0.75, 5.86), "size": Vector3(3.4, 0.7, 0.5)},
		{"item": &"figura_inacio_a", "at": Vector3(11.15, 0.7, 8.35), "size": Vector3(0.45, 1.3, 0.45)},
		{"item": &"figura_inacio_b", "at": Vector3(11.85, 0.7, 8.35), "size": Vector3(0.45, 1.3, 0.45)},
		{"item": &"figura_catalogador", "at": Vector3(12.55, 0.7, 8.35), "size": Vector3(0.45, 1.3, 0.45)},
	],
}

static func build(main: Node3D) -> void:
	_build_house(main)
	_build_furniture(main)
	_build_tampo(main)

# ---------------------------------------------------------------------------
# House: the compact vista plan, scaled for walking
# ---------------------------------------------------------------------------

static func _build_house(main: Node3D) -> void:
	var house := Node3D.new()
	house.name = "House"
	main.add_child(house)

	# Floors.
	main._floor(house, 0.0, 0.0, 8.4, 7.0, main.mat_floor_play)
	main._floor(house, 8.4, 0.0, 10.5, 7.7, main.mat_floor_corridor)
	main._floor(house, 10.5, 0.0, AreaGaveta.HOLE.position.x, 5.6, main.mat_floor_bed)
	main._floor(house, AreaGaveta.HOLE.position.x, AreaGaveta.HOLE.end.y, 15.4, 5.6, main.mat_floor_bed)
	var hole: Rect2 = AreaGaveta.HOLE
	main._breakable(house, "Trapdoor", &"alcapao", Vector3(hole.size.x, 0.12, hole.size.y), Vector3(hole.get_center().x, -0.06, hole.get_center().y), main.mat_wood_dark)
	main._floor(house, 10.5, 5.6, 15.4, 9.1, main.mat_floor_figure)
	main._floor(house, 0.0, 7.0, 3.5, 9.1, main.mat_floor_entry)
	main._floor(house, 3.5, 7.7, 10.5, 9.1, main.mat_floor_corridor)

	# Ceilings.
	main._ceiling(house, 0.0, 0.0, 8.4, 7.0)
	main._ceiling(house, 8.4, 0.0, 10.5, 7.7)
	main._ceiling(house, 10.5, 0.0, 15.4, 5.6)
	main._ceiling(house, 10.5, 5.6, 15.4, 9.1)
	main._ceiling(house, 0.0, 7.0, 3.5, 9.1)
	main._ceiling(house, 3.5, 7.7, 10.5, 9.1)

	# North wall: playroom, corridor, bedroom.
	main._wall_z(house, 0.0, 0.0, PANEL.position.x, 0.0, main.WALL_H, main.mat_wall)
	main._wall_z(house, 0.0, PANEL.end.x, 8.4, 0.0, main.WALL_H, main.mat_wall)
	main._wall_z(house, 0.0, PANEL.position.x, PANEL.end.x, PANEL.end.y, main.WALL_H, main.mat_wall)
	main._breakable(house, "HollowPanel", &"oco", Vector3(PANEL.size.x, PANEL.size.y, main.WALL_T), Vector3(PANEL.get_center().x, PANEL.get_center().y, 0.0), main.mat_wall)
	main._wall_z(house, 0.0, 8.4, 10.5, 0.0, main.WALL_H, main.mat_wall_corridor)
	main._wall_z(house, 0.0, 10.5, 15.4, 0.0, main.WALL_H, main.mat_wall_bed)

	# West: F1 replaces the playroom wall; entry wall is static.
	main._wall_x(house, 0.0, 7.0, 9.1, 0.0, main.WALL_H, main.mat_wall_entry)

	# East side.
	main._wall_x(house, 15.4, 0.0, 5.6, 0.0, main.WALL_H, main.mat_wall_bed)
	main._wall_x(house, 15.4, 5.6, 9.1, 0.0, main.WALL_H, main.mat_wall_figure)

	# South facade with the front door opening.
	main._wall_z(house, 9.1, 0.0, 1.12, 0.0, main.WALL_H, main.mat_wall_exterior)
	main._wall_z(house, 9.1, 2.52, 15.4, 0.0, main.WALL_H, main.mat_wall_exterior)
	main._wall_z(house, 9.1, 1.12, 2.52, main.DOOR_H, main.WALL_H, main.mat_wall_exterior)

	# Playroom south wall / entry north wall, with the door.
	main._wall_z(house, 7.0, 0.0, 1.12, 0.0, main.WALL_H, main.mat_wall)
	main._wall_z(house, 7.0, 2.52, 8.4, 0.0, main.WALL_H, main.mat_wall)
	main._wall_z(house, 7.0, 1.12, 2.52, main.DOOR_H, main.WALL_H, main.mat_wall)

	# Playroom east wall / corridor west wall.
	main._wall_x(house, 8.4, 0.0, 0.6, 0.0, main.WALL_H, main.mat_wall)
	main._wall_x(house, 8.4, 2.0, 3.0, main.DOOR_H, main.WALL_H, main.mat_wall)
	main._wall_x(house, 8.4, 4.6, 7.7, 0.0, main.WALL_H, main.mat_wall_corridor)

	# Corridor east wall: bedroom doors and solid pieces.
	main._wall_x(house, 10.5, 0.0, 1.4, 0.0, main.WALL_H, main.mat_wall_bed)
	main._wall_x(house, 10.5, 1.4, 2.8, main.DOOR_H, main.WALL_H, main.mat_wall_bed)
	main._wall_x(house, 10.5, 2.8, 3.92, 0.0, main.WALL_H, main.mat_wall_bed)
	main._wall_x(house, 10.5, 3.92, 5.32, main.DOOR_H, main.WALL_H, main.mat_wall_bed)
	main._wall_x(house, 10.5, 5.32, 7.0, 0.0, main.WALL_H, main.mat_wall_corridor)

	# Figure-room west wall.
	main._wall_x(house, 10.5, 7.0, 7.56, 0.0, main.WALL_H, main.mat_wall_figure)
	main._wall_x(house, 10.5, 7.56, 8.4, main.DOOR_H, main.WALL_H, main.mat_wall_figure)
	main._wall_x(house, 10.5, 8.4, 9.1, 0.0, main.WALL_H, main.mat_wall_figure)

	# Bedroom south and figure-room north (one wall since the room grew, spec §6.2).
	main._wall_z(house, 5.6, 10.5, 15.4, 0.0, main.WALL_H, main.mat_wall_bed)

	# Entry east side and passage north.
	main._wall_x(house, 3.5, 7.0, 7.7, 0.0, main.WALL_H, main.mat_wall_entry)
	main._wall_z(house, 7.7, 3.5, 8.4, 0.0, main.WALL_H, main.mat_wall_corridor)

	# The four folds.
	main._hinge("F1", Vector3(main.WALL_T, main.WALL_H, 7.0), Vector3(main.WALL_T * 0.5, main.WALL_H * 0.5, 3.5),
			Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(0.0, 0.0, deg_to_rad(-45.0)),
			"dobrar a parede oeste", "desdobrar a parede oeste", false, false, false, main.mat_wall)

	main._hinge("F2", Vector3(0.12, main.WALL_H, 1.4), Vector3(0.0, main.WALL_H * 0.5, 0.7),
			Vector3(8.4, 0.0, 0.6), Vector3.ZERO, Vector3(0.0, deg_to_rad(80.0), 0.0),
			"dobrar o painel norte", "desdobrar o painel norte", false, false, false, main.mat_wall_corridor)

	main._hinge("F3", Vector3(0.06, main.DOOR_H, 1.0), Vector3(0.0, main.DOOR_H * 0.5, 0.5),
			Vector3(8.4, 0.0, 2.0), Vector3(0.0, 0.0, deg_to_rad(-90.0)), Vector3.ZERO,
			"levantar a porta", "deitar a porta", false, true, false, main.mat_door)

	main._hinge("F4", Vector3(0.12, main.WALL_H, 1.6), Vector3(0.0, main.WALL_H * 0.5, -0.8),
			Vector3(8.4, 0.0, 4.6), Vector3.ZERO, Vector3(0.0, deg_to_rad(-80.0), 0.0),
			"dobrar o painel sul", "desdobrar o painel sul", false, false, false, main.mat_wall_corridor)

	# Doors.
	main._hinge("DoorPlayroom", Vector3(1.4, main.DOOR_H, 0.06), Vector3(0.7, main.DOOR_H * 0.5, 0.0),
			Vector3(1.12, 0.0, 7.0), Vector3.ZERO, Vector3(0.0, deg_to_rad(90.0), 0.0),
			"abrir a porta do quarto de brincar", "fechar a porta do quarto de brincar",
			true, false, false, main.mat_door)

	main._hinge("DoorBedroomFront", Vector3(0.06, main.DOOR_H, 1.4), Vector3(0.0, main.DOOR_H * 0.5, 0.7),
			Vector3(10.5, 0.0, 1.4), Vector3.ZERO, Vector3(0.0, deg_to_rad(70.0), 0.0),
			"abrir a porta da frente do quarto", "fechar a porta da frente do quarto",
			false, false, false, main.mat_door)

	main._hinge("DoorBedroomBack", Vector3(0.06, main.DOOR_H, 1.4), Vector3(0.0, main.DOOR_H * 0.5, 0.7),
			Vector3(10.5, 0.0, 3.92), Vector3.ZERO, Vector3(0.0, deg_to_rad(-70.0), 0.0),
			"abrir a porta dos fundos", "fechar a porta dos fundos",
			false, false, false, main.mat_door)

	main._hinge("DoorFigure", Vector3(0.06, main.DOOR_H, 0.84), Vector3(0.0, main.DOOR_H * 0.5, 0.42),
			Vector3(10.5, 0.0, 7.56), Vector3.ZERO, Vector3(0.0, deg_to_rad(90.0), 0.0),
			"abrir a porta das figuras", "fechar a porta das figuras",
			false, false, false, main.mat_door)

	var front_door: Node3D = main._hinge("DoorFront", Vector3(1.4, main.DOOR_H, 0.08), Vector3(0.7, main.DOOR_H * 0.5, 0.0),
			DOOR_FRONT, Vector3.ZERO, Vector3(0.0, deg_to_rad(-110.0), 0.0),
			"abrir a porta da rua", "fechar a porta da rua",
			true, false, false, main.mat_door)
	var knob := MeshInstance3D.new()
	var knob_mesh := SphereMesh.new()
	knob_mesh.radius = 0.055
	knob_mesh.height = 0.11
	knob.mesh = knob_mesh
	knob.material_override = main.mat_brass
	knob.position = Vector3(1.3, 1.0, 0.06)
	front_door.add_child(knob)

	# Brass thresholds.
	main._box(house, Vector3(1.4, 0.02, 0.12), Vector3(1.82, 0.01, 7.0), main.mat_brass, false)
	main._box(house, Vector3(1.4, 0.02, 0.12), Vector3(1.82, 0.01, 9.1), main.mat_brass, false)
	main._box(house, Vector3(0.12, 0.02, 1.4), Vector3(10.5, 0.01, 2.1), main.mat_brass, false)
	main._box(house, Vector3(0.12, 0.02, 1.4), Vector3(10.5, 0.01, 4.62), main.mat_brass, false)

	# Bedroom window (visual; the wall stays solid).
	var bedroom_window: Node3D = main._box(house, Vector3(2.0, 1.3, 0.04), Vector3(12.5, 1.65, 0.04), main.mat_window, false)
	bedroom_window.name = "BedroomWindow"
	bedroom_window.get_child(0).add_to_group(&"HouseWindow")
	# The street lamp behind it: night 1 puts it out (setpieces/luz_de_fora.gd).
	main._omni(house, Vector3(12.5, 2.0, -0.9), Color(1.0, 0.78, 0.5), 0.9, 3.0, false).add_to_group(&"OutsideLight")
	main._box(house, Vector3(2.2, 0.08, 0.08), Vector3(12.5, 1.0, 0.06), main.mat_wood, false)
	main._box(house, Vector3(2.2, 0.08, 0.08), Vector3(12.5, 2.3, 0.06), main.mat_wood, false)
	main._box(house, Vector3(0.08, 1.3, 0.08), Vector3(11.5, 1.65, 0.06), main.mat_wood, false)
	main._box(house, Vector3(0.08, 1.3, 0.08), Vector3(13.5, 1.65, 0.06), main.mat_wood, false)

	# Lighting inside.
	# Night 1 leaves only this one lit (spec §7.3).
	main._house_light(house, Vector3(4.2, 2.55, 3.5), Color(1.0, 0.78, 0.5), 1.4, 6.5, false).name = "PlayroomLamp"
	main._house_light(house, Vector3(1.6, 2.2, 3.6), Color(1.0, 0.72, 0.42), 0.55, 4.0, false)
	main._house_light(house, Vector3(1.2, 1.0, 4.0), Color(1.0, 0.65, 0.4), 0.45, 3.0, false)
	main._house_light(house, Vector3(12.5, 2.2, 0.7), Color(0.55, 0.7, 0.95), 1.3, 5.5, false)
	main._house_light(house, Vector3(11.2, 1.2, 2.0), Color(1.0, 0.62, 0.35), 0.45, 3.0, false)
	main._house_light(house, Vector3(1.8, 2.3, 8.1), Color(1.0, 0.72, 0.45), 0.55, 3.2, false)
	main._house_light(house, Vector3(8.6, 2.1, 1.1), Color(1.0, 0.7, 0.45), 0.8, 4.0, false)
	main._house_light(house, Vector3(8.6, 2.1, 5.4), Color(1.0, 0.7, 0.45), 0.7, 4.0, false)
	main._house_light(house, Vector3(9.45, 2.1, 7.8), Color(1.0, 0.7, 0.45), 0.6, 3.5, false)

static func _build_furniture(main: Node3D) -> void:
	# Playroom: rug, shelf, table, blocks, ball, music box.
	main._box(main, Vector3(4.6, 0.03, 2.8), Vector3(3.8, 0.015, 4.4), main.mat_rug_play, false)
	main._box(main, Vector3(2.2, 1.8, 0.35), Vector3(4.2, 0.9, 0.22), main.mat_wood_dark, true)
	# The boy's drawing, in white wax at the bedroom's head (setpieces/desenho_cera.gd):
	# the paper is blank until a flame comes near; DrawingWax holds the lines.
	main._box(main, Vector3(0.8, 0.6, 0.02), Vector3(14.05, 1.5, 0.08), main.mat_cream, false)
	var wax: Node3D = main._box(main, Vector3(0.56, 0.38, 0.01), Vector3(14.05, 1.5, 0.095), main.mat_wax_lines, false)
	wax.name = "DrawingWax"
	# The bedside table, with its box of matches (a DEF pickup) and a burnt-out stub.
	main._box(main, Vector3(0.5, 0.6, 0.5), Vector3(14.05, 0.3, 0.35), main.mat_wood, true)
	main._box(main, Vector3(0.05, 0.04, 0.05), Vector3(14.2, 0.62, 0.3), main.mat_candle, false)
	main._box(main, Vector3(0.08, 0.01, 0.08), Vector3(14.2, 0.605, 0.3), main.mat_wood_dark, false)
	for i in range(5):
		main._box(main, Vector3(0.16, 0.34, 0.06), Vector3(3.4 + i * 0.28, 1.22, 0.42), main.mat_red if i % 2 == 0 else main.mat_cream, false)
	for i in range(4):
		main._box(main, Vector3(0.14, 0.28, 0.06), Vector3(3.55 + i * 0.3, 0.72, 0.42), main.mat_cream if i % 2 == 0 else main.mat_brass, false)

	main._box(main, Vector3(1.6, 0.12, 0.9), Vector3(3.3, 0.5, 4.6), main.mat_wood, true)
	for dx in [-0.65, 0.65]:
		for dz in [-0.3, 0.3]:
			main._box(main, Vector3(0.08, 0.5, 0.08), Vector3(3.3 + dx, 0.25, 4.6 + dz), main.mat_wood_dark, false)
	main._box(main, Vector3(0.5, 0.45, 0.5), Vector3(2.25, 0.225, 4.75), main.mat_wood, true)
	for i in range(3):
		main._box(main, Vector3(0.18, 0.18, 0.18), Vector3(2.85 + i * 0.22, 0.65, 4.45 + (i % 2) * 0.18), main.mat_red if i == 1 else main.mat_cream, false)

	# The F1 cabana: blanket and cushion under the folded wall.
	main._box(main, Vector3(1.4, 0.03, 1.2), Vector3(1.5, 0.015, 3.5), main.mat_rug_play, false)
	main._box(main, Vector3(0.5, 0.12, 0.5), Vector3(1.5, 0.06, 3.5), main.mat_cream, false)

	# The little house moved into the figure room's cabinet (setpieces/vitrine.gd).
	_build_bench(main)

	var mb = preload("res://scripts/music_box.gd").new()
	mb.name = "MusicBox"
	mb.position = Vector3(3.35, 0.63, 4.45)
	main.add_child(mb)
	var mb_mesh := MeshInstance3D.new()
	var mb_box := BoxMesh.new()
	mb_box.size = Vector3(0.38, 0.18, 0.26)
	mb_mesh.mesh = mb_box
	mb_mesh.material_override = main.mat_wood_dark
	mb.add_child(mb_mesh)
	var mb_cs := CollisionShape3D.new()
	var mb_shape := BoxShape3D.new()
	mb_shape.size = Vector3(0.38, 0.18, 0.26)
	mb_cs.shape = mb_shape
	mb.add_child(mb_cs)
	var handle := MeshInstance3D.new()
	var handle_mesh := CylinderMesh.new()
	handle_mesh.top_radius = 0.018
	handle_mesh.bottom_radius = 0.018
	handle_mesh.height = 0.14
	handle.mesh = handle_mesh
	handle.material_override = main.mat_brass
	handle.position = Vector3(0.24, 0.09, 0.0)
	handle.rotation.z = deg_to_rad(90.0)
	mb.add_child(handle)
	var mb_glow := OmniLight3D.new()
	mb_glow.position = Vector3(0.0, 0.3, 0.0)
	mb_glow.light_color = Color(1.0, 0.72, 0.4)
	mb_glow.light_energy = 0.0
	mb_glow.omni_range = 2.2
	mb.add_child(mb_glow)
	mb.call("setup", handle, mb_glow)

	var ball = preload("res://scripts/ball.gd").new()
	ball.name = "Ball"
	ball.position = Vector3(6.2, 0.3, 3.4)
	var ball_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.14
	sphere.height = 0.28
	ball_mesh.mesh = sphere
	ball_mesh.material_override = main.mat_ball
	ball.add_child(ball_mesh)
	var ball_cs := CollisionShape3D.new()
	var ball_shape := SphereShape3D.new()
	ball_shape.radius = 0.14
	ball_cs.shape = ball_shape
	ball.add_child(ball_cs)
	main.add_child(ball)

	# Bedroom: bed, doll, mirror, wardrobe, rug.
	main._box(main, Vector3(2.2, 0.25, 3.1), Vector3(13.2, 0.2, 3.0), main.mat_wood_dark, true)
	main._box(main, Vector3(2.05, 0.22, 3.0), Vector3(13.2, 0.46, 3.0), main.mat_cream, true)
	main._box(main, Vector3(0.9, 0.14, 0.45), Vector3(13.2, 0.62, 1.75), main.mat_cream, false)
	main._box(main, Vector3(2.05, 0.08, 1.4), Vector3(13.2, 0.61, 3.45), main.mat_doll_cloth, false)
	main._box(main, Vector3(2.2, 0.7, 0.08), Vector3(13.2, 0.55, 1.48), main.mat_wood_dark, false)
	main._box(main, Vector3(3.4, 0.03, 2.6), Vector3(13.0, 0.015, 3.7), main.mat_rug_bed, false)
	main._box(main, Vector3(0.7, 2.0, 1.4), Vector3(15.0, 1.0, 4.6), main.mat_wood_dark, true)
	main._box(main, Vector3(0.06, 1.6, 1.0), Vector3(15.32, 1.35, 2.0), main.mat_mirror, false)
	main._box(main, Vector3(0.08, 1.7, 0.08), Vector3(15.34, 1.35, 1.5), main.mat_wood, false)
	main._box(main, Vector3(0.08, 1.7, 0.08), Vector3(15.34, 1.35, 2.5), main.mat_wood, false)
	main._box(main, Vector3(0.08, 0.08, 1.0), Vector3(15.34, 2.2, 2.0), main.mat_wood, false)
	main._box(main, Vector3(0.08, 0.08, 1.0), Vector3(15.34, 0.5, 2.0), main.mat_wood, false)

	var doll = preload("res://scripts/doll.gd").new()
	doll.name = "Doll"
	doll.position = Vector3(13.4, 0.84, 2.5)
	doll.rotation.x = deg_to_rad(90.0)
	doll.set("sit_rotation", Vector3(deg_to_rad(-80.0), 0.0, 0.0))
	doll.set("sit_offset", Vector3(0.0, 0.25, 0.08))
	var torso := MeshInstance3D.new()
	var torso_mesh := BoxMesh.new()
	torso_mesh.size = Vector3(0.34, 0.5, 0.2)
	torso.mesh = torso_mesh
	torso.material_override = main._style_mat(&"coat")
	torso.position = Vector3(0.0, 0.25, 0.0)
	doll.add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.13
	head_mesh.height = 0.26
	head.mesh = head_mesh
	head.material_override = main._style_mat(&"skin")
	head.position = Vector3(0.0, 0.58, 0.0)
	doll.add_child(head)
	main._box(doll, Vector3(0.27, 0.1, 0.28), Vector3(0.0, 0.69, 0.0), main._style_mat(&"hair"), false)
	for side in [-1.0, 1.0]:
		var limb := MeshInstance3D.new()
		var limb_mesh := BoxMesh.new()
		limb_mesh.size = Vector3(0.09, 0.4, 0.09)
		limb.mesh = limb_mesh
		limb.material_override = main._style_mat(&"coat")
		limb.position = Vector3(side * 0.2, 0.22, 0.0)
		limb.rotation.z = deg_to_rad(side * 12.0)
		doll.add_child(limb)
	var doll_cs := CollisionShape3D.new()
	var doll_shape := BoxShape3D.new()
	doll_shape.size = Vector3(0.5, 0.95, 0.3)
	doll_cs.shape = doll_shape
	doll_cs.position = Vector3(0.0, 0.3, 0.0)
	doll.add_child(doll_cs)
	main.add_child(doll)

	# Corridor runner.
	main._box(main, Vector3(0.9, 0.03, 6.0), Vector3(9.45, 0.015, 4.0), main.mat_rug_corridor, false)

	# Figure room: low table, candle, three chairs and occupants.
	main._box(main, Vector3(0.9, 0.45, 0.55), Vector3(11.85, 0.225, 7.7), main.mat_wood_dark, true)
	var candle_mesh := MeshInstance3D.new()
	var candle_cyl := CylinderMesh.new()
	candle_cyl.top_radius = 0.04
	candle_cyl.bottom_radius = 0.05
	candle_cyl.height = 0.18
	candle_mesh.mesh = candle_cyl
	candle_mesh.material_override = main.mat_candle
	candle_mesh.position = Vector3(11.85, 0.58, 7.7)
	main.add_child(candle_mesh)
	var candle_light: OmniLight3D = main._omni(main, Vector3(11.85, 0.8, 7.7), Color(1.0, 0.62, 0.3), 0.35, 3.0, false)

	for i in range(3):
		var x := 11.15 + i * 0.7
		main._box(main, Vector3(0.45, 0.08, 0.45), Vector3(x, 0.48, 8.35), main.mat_wood_dark, true)
		main._box(main, Vector3(0.45, 0.55, 0.08), Vector3(x, 0.78, 8.58), main.mat_wood_dark, false)
		main._box(main, Vector3(0.34, 0.6, 0.25), Vector3(x, 0.86, 8.35), main.mat_dark, false)
		var occ_head := MeshInstance3D.new()
		var occ_head_mesh := SphereMesh.new()
		occ_head_mesh.radius = 0.12
		occ_head_mesh.height = 0.24
		occ_head.mesh = occ_head_mesh
		occ_head.material_override = main.mat_dark
		occ_head.position = Vector3(x, 1.28, 8.35)
		main.add_child(occ_head)
	_build_story_props(main)

	# Hiding places in the house: under the folded wall of the cabana, and
	# the gap between the bed and the east wall, by the mirror.
	for h in HIDEOUTS:
		main._hideout(main, h, HIDEOUTS[h][0], HIDEOUTS[h][1])

	var figure = preload("res://scripts/figure.gd").new()
	figure.name = "Figure"
	figure.position = Vector3(11.85, 0.0, 8.35)
	var figure_body := MeshInstance3D.new()
	var figure_mesh := BoxMesh.new()
	figure_mesh.size = Vector3(0.36, 0.62, 0.28)
	figure_body.mesh = figure_mesh
	figure_body.material_override = main.mat_dark
	figure_body.position = Vector3(0.0, 0.87, 0.0)
	figure.add_child(figure_body)
	var figure_head := MeshInstance3D.new()
	var figure_head_mesh := SphereMesh.new()
	figure_head_mesh.radius = 0.13
	figure_head_mesh.height = 0.26
	figure_head.mesh = figure_head_mesh
	figure_head.material_override = main.mat_dark
	figure_head.position = Vector3(0.0, 1.3, 0.0)
	figure.add_child(figure_head)
	var figure_cs := CollisionShape3D.new()
	var figure_shape := BoxShape3D.new()
	figure_shape.size = Vector3(0.42, 1.35, 0.4)
	figure_cs.shape = figure_shape
	figure_cs.position = Vector3(0.0, 0.68, 0.0)
	figure.add_child(figure_cs)
	main.add_child(figure)
	figure.call("setup", candle_light)

	# Entry: bench, hooks, coat.
	main._box(main, Vector3(1.2, 0.4, 0.45), Vector3(0.7, 0.2, 8.5), main.mat_wood, true)
	for z in [7.4, 7.7, 8.0]:
		var hook := MeshInstance3D.new()
		var hook_mesh := SphereMesh.new()
		hook_mesh.radius = 0.035
		hook_mesh.height = 0.07
		hook.mesh = hook_mesh
		hook.material_override = main.mat_brass
		hook.position = Vector3(0.06, 1.6, z)
		main.add_child(hook)
	main._box(main, Vector3(0.1, 0.8, 0.4), Vector3(0.14, 1.2, 7.6), main.mat_red, false)
	main._box(main, Vector3(1.2, 0.02, 0.8), Vector3(1.82, 0.01, 8.9), main.mat_rug_corridor, false)
	_build_entry_clock(main)

static func _build_entry_clock(main: Node3D) -> void:
	# Tall case clock against the facade, beside the front door, facing in.
	var clock = preload("res://scripts/entry_clock.gd").new()
	clock.name = "EntryClock"
	clock.position = ENTRY_CLOCK
	main.add_child(clock)
	var case_mesh := MeshInstance3D.new()
	var case_box := BoxMesh.new()
	case_box.size = Vector3(0.5, 2.0, 0.28)
	case_mesh.mesh = case_box
	case_mesh.material_override = main.mat_dark
	clock.add_child(case_mesh)
	var case_cs := CollisionShape3D.new()
	var case_shape := BoxShape3D.new()
	case_shape.size = Vector3(0.5, 2.0, 0.28)
	case_cs.shape = case_shape
	clock.add_child(case_cs)
	# Dial, hour hand fixed on the 3, minute hand on a pivot.
	main._box(clock, Vector3(0.36, 0.36, 0.02), Vector3(0.0, 0.6, -0.15), main.mat_cream, false)
	main._box(clock, Vector3(0.12, 0.02, 0.01), Vector3(-0.06, 0.6, -0.165), main.mat_dark, false)
	var minute_pivot := Node3D.new()
	minute_pivot.position = Vector3(0.0, 0.6, -0.17)
	clock.add_child(minute_pivot)
	main._box(minute_pivot, Vector3(0.015, 0.15, 0.01), Vector3(0.0, 0.075, 0.0), main.mat_dark, false)
	# Pendulum swinging in front of the lower case.
	var pendulum_pivot := Node3D.new()
	pendulum_pivot.position = Vector3(0.0, 0.3, -0.16)
	clock.add_child(pendulum_pivot)
	main._box(pendulum_pivot, Vector3(0.015, 0.7, 0.01), Vector3(0.0, -0.35, 0.0), main.mat_brass, false)
	var bob := CylinderMesh.new()
	bob.top_radius = 0.07
	bob.bottom_radius = 0.07
	bob.height = 0.02
	main._add_mesh(pendulum_pivot, bob, Vector3(0.0, -0.72, 0.0), main.mat_brass, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	clock.call("setup", main.clock_model, minute_pivot, pendulum_pivot)

static func _build_tampo(main: Node3D) -> void:
	# The bench top the model stands on. Its walls are the glass of the dome:
	# same collision as the old atelier walls, but the workshop shows through.
	var west := Node3D.new()
	west.name = "WestTampo"
	main.add_child(west)
	main._floor(west, -3.2, 0.0, 0.0, 9.1, main.mat_wood)
	main._wall_x(west, -3.2, 0.0, 9.1, 0.0, main.WALL_H, main.mat_glass)
	main._wall_z(west, 0.0, -3.2, 0.0, 0.0, main.WALL_H, main.mat_glass)
	main._wall_z(west, 9.1, -3.2, 0.0, 0.0, main.WALL_H, main.mat_glass)
	main._omni(west, Vector3(-1.6, 2.2, 4.0), Color(1.0, 0.72, 0.45), 0.5, 5.0, false)

	var tampo := Node3D.new()
	tampo.name = "Tampo"
	main.add_child(tampo)
	main._floor(tampo, 0.0, 9.1, 15.4, 12.5, main.mat_wood)
	main._wall_x(tampo, 0.0, 9.1, 12.5, 0.0, main.WALL_H, main.mat_glass)
	var cracked: StaticBody3D = main._breakable(tampo, "CrackedGlass", &"vidro", Vector3(main.WALL_T, main.WALL_H, CRACKED_Z.y - CRACKED_Z.x), Vector3(15.4, main.WALL_H * 0.5, (CRACKED_Z.x + CRACKED_Z.y) * 0.5), main.mat_glass)
	var cracks := Node3D.new()
	cracks.name = "Cracks"
	tampo.add_child(cracks)
	var hit_at := Vector3(15.32, 1.2, 10.4)
	for a in [0.3, 1.1, 1.9, 2.6, 3.5, 4.4, 5.3]:
		var ln := 0.4 + fmod(a * 7.3, 0.9)
		main._box(cracks, Vector3(0.005, ln, 0.012), hit_at + Vector3(0.0, cos(a) * ln * 0.5, sin(a) * ln * 0.5), main.mat_dark, false, Vector3(-a, 0.0, 0.0))
	cracked.shattered.connect(func() -> void: cracks.visible = false)
	main._chalk(tampo, Vector3(0.6, 0.01, 0.05), Vector3(14.4, 0.006, 10.8))
	main._chalk(tampo, Vector3(0.25, 0.01, 0.05), Vector3(14.62, 0.006, 10.72), Vector3(0.0, 0.7, 0.0))
	main._chalk(tampo, Vector3(0.25, 0.01, 0.05), Vector3(14.62, 0.006, 10.88), Vector3(0.0, -0.7, 0.0))
	main._wall_z(tampo, 12.5, 0.0, 15.4, 0.0, main.WALL_H, main.mat_glass)

	# Giant tools left on the bench: a gear lying flat and a pencil.
	var gear := CylinderMesh.new()
	gear.top_radius = 1.2
	gear.bottom_radius = 1.2
	gear.height = 0.3
	main._add_mesh(tampo, gear, Vector3(11.0, 0.15, 11.0), main.mat_brass)
	main._box(tampo, Vector3(0.25, 0.25, 4.0), Vector3(6.5, 0.12, 11.6), main.mat_wood_dark, false, Vector3(0.0, deg_to_rad(90.0), 0.0))
	main._omni(tampo, Vector3(3.2, 2.3, 11.0), Color(1.0, 0.72, 0.45), 0.7, 4.5, false)

	# The dome: visual glass only, over the whole model.
	var redoma := Node3D.new()
	redoma.name = "Redoma"
	main.add_child(redoma)
	var x0 := -3.4
	var x1 := 15.6
	var z0 := -1.6
	var z1 := 12.7
	var top := 13.2
	main._box(redoma, Vector3(x1 - x0, 0.03, z1 - z0), Vector3((x0 + x1) * 0.5, top, (z0 + z1) * 0.5), main.mat_glass, false)
	main._box(redoma, Vector3(0.03, top, z1 - z0), Vector3(x0, top * 0.5, (z0 + z1) * 0.5), main.mat_glass, false)
	main._box(redoma, Vector3(0.03, top, CRACKED_Z.x - z0), Vector3(x1, top * 0.5, (z0 + CRACKED_Z.x) * 0.5), main.mat_glass, true)
	main._box(redoma, Vector3(0.03, top, z1 - CRACKED_Z.y), Vector3(x1, top * 0.5, (CRACKED_Z.y + z1) * 0.5), main.mat_glass, true)
	main._box(redoma, Vector3(0.03, top - main.WALL_H, CRACKED_Z.y - CRACKED_Z.x), Vector3(x1, (top + main.WALL_H) * 0.5, (CRACKED_Z.x + CRACKED_Z.y) * 0.5), main.mat_glass, false)
	main._box(redoma, Vector3(x1 - x0, top, 0.03), Vector3((x0 + x1) * 0.5, top * 0.5, z0), main.mat_glass, false)
	main._box(redoma, Vector3(x1 - x0, top, 0.03), Vector3((x0 + x1) * 0.5, top * 0.5, z1), main.mat_glass, false)

	# The tampo edge: walking to it is how Elias leaves.
	var edge := Area3D.new()
	edge.name = "ExitEdge"
	edge.collision_layer = 0
	edge.collision_mask = 1
	edge.position = Vector3(7.7, 1.25, 12.2)
	var edge_shape := CollisionShape3D.new()
	var edge_box := BoxShape3D.new()
	edge_box.size = Vector3(15.4, 2.5, 0.6)
	edge_shape.shape = edge_box
	edge.add_child(edge_shape)
	edge.body_entered.connect(func(body: Node3D) -> void:
		if body == main.player:
			main.exit_edge_reached.emit())
	main.add_child(edge)

## The pieces of the truth: the two Inácio figures wear the same pocket watch;
## the cataloger figure has none, only a notebook and a letter on its lap.
## Under the cabana cushion, a page that only shows after 03:33.
static func _build_story_props(main: Node3D) -> void:
	var watch := CylinderMesh.new()
	watch.top_radius = 0.05
	watch.bottom_radius = 0.05
	watch.height = 0.018
	for pair in [["PocketWatchA", 11.15], ["PocketWatchB", 11.85]]:
		var w: MeshInstance3D = main._add_mesh(main, watch, Vector3(pair[1], 1.0, 8.2), main.mat_brass, Vector3(deg_to_rad(90.0), 0.0, 0.0))
		w.name = pair[0]
	var book: Node3D = main._box(main, Vector3(0.2, 0.035, 0.26), Vector3(12.55, 0.6, 8.13), main.mat_cream, false)
	book.name = "CatalogerNotebook"
	var letter: Node3D = main._box(main, Vector3(0.16, 0.006, 0.21), Vector3(12.58, 0.623, 8.11), main.mat_cream, false, Vector3(0.0, deg_to_rad(14.0), 0.0))
	letter.name = "CatalogerLetter"
	var page: Node3D = main._box(main, Vector3(0.22, 0.004, 0.29), Vector3(1.5, 0.13, 3.5), main.mat_cream, false, Vector3(0.0, deg_to_rad(-18.0), 0.0))
	page.name = "CabanaPage"
	page.visible = false

## The figure room's bench (DEF.bench): plain dark wood along the north
## wall, long enough for the seven seats, solid to walk into.
static func _build_bench(main: Node3D) -> void:
	var seats: Array = DEF.bench.seats
	var x0: float = seats[0].x - 0.3
	var x1: float = seats[-1].x + 0.3
	var cx := (x0 + x1) * 0.5
	var z: float = seats[0].z - 0.09
	main._box(main, Vector3(x1 - x0, 0.06, 0.42), Vector3(cx, 0.43, z), main.mat_wood_dark, true)
	main._box(main, Vector3(x1 - x0, 0.5, 0.05), Vector3(cx, 0.75, 5.66), main.mat_wood_dark, true)
	for x in [x0 + 0.05, cx, x1 - 0.05]:
		main._box(main, Vector3(0.06, 0.4, 0.38), Vector3(x, 0.2, z), main.mat_wood_dark, true)
