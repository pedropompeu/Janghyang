extends Node3D
## FAZ DE CONTA — slice blockout.
## Builds the house from primitives so the plan, the folds and the loop can be
## tested before art. Everything is visual: no audio, no fail state.

const WALL_H := 2.7
const WALL_T := 0.14
const DOOR_H := 2.1

var mat_floor_play: StandardMaterial3D
var mat_floor_corridor: StandardMaterial3D
var mat_floor_bed: StandardMaterial3D
var mat_floor_figure: StandardMaterial3D
var mat_floor_entry: StandardMaterial3D
var mat_floor_atelier: StandardMaterial3D
var mat_wall: StandardMaterial3D
var mat_wall_corridor: StandardMaterial3D
var mat_wall_bed: StandardMaterial3D
var mat_wall_figure: StandardMaterial3D
var mat_wall_entry: StandardMaterial3D
var mat_wall_exterior: StandardMaterial3D
var mat_wall_atelier: StandardMaterial3D
var mat_ceiling: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_wood_dark: StandardMaterial3D
var mat_door: StandardMaterial3D
var mat_brass: StandardMaterial3D
var mat_cream: StandardMaterial3D
var mat_rug_play: StandardMaterial3D
var mat_rug_bed: StandardMaterial3D
var mat_rug_corridor: StandardMaterial3D
var mat_ball: StandardMaterial3D
var mat_doll_skin: StandardMaterial3D
var mat_doll_cloth: StandardMaterial3D
var mat_mirror: StandardMaterial3D
var mat_window: StandardMaterial3D
var mat_rain: StandardMaterial3D
var mat_candle: StandardMaterial3D
var mat_red: StandardMaterial3D
var mat_dark: StandardMaterial3D

var player: CharacterBody3D
var prompt_label: Label
var help_label: Label
var crosshair: ColorRect
var _shot_mode := ""

func _ready() -> void:
	_make_materials()
	_make_environment()
	_build_house()
	_build_furniture()
	_build_atelier()
	_build_player()
	_build_ui()
	_add_labels()

	var args := OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with("--shot"):
			_shot_mode = arg.substr(6)
			if _shot_mode.begins_with("-"):
				_shot_mode = _shot_mode.substr(1)
			if _shot_mode == "":
				_shot_mode = "playroom"
			_prepare_shot(_shot_mode)
			break

	if args.has("--selftest"):
		var test := preload("res://scripts/selftest.gd").new()
		test.main = self
		add_child(test)

func _process(_delta: float) -> void:
	if player == null or prompt_label == null:
		return
	var ray := player.get_node_or_null("Camera3D/RayCast3D") as RayCast3D
	if ray != null and ray.is_colliding():
		var collider := ray.get_collider()
		if collider != null and collider.has_method("get_prompt"):
			var p: String = collider.get_prompt()
			if p != "":
				prompt_label.text = "[E]  " + p
				prompt_label.visible = true
				return
	prompt_label.visible = false

# ---------------------------------------------------------------------------
# Materials and helpers
# ---------------------------------------------------------------------------

func _mat(hex: String, rough := 0.85, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color.html(hex)
	m.roughness = rough
	m.metallic = metal
	return m

func _make_materials() -> void:
	mat_floor_play = _mat("#7b5136", 0.82)
	mat_floor_corridor = _mat("#4e392a", 0.92)
	mat_floor_bed = _mat("#5b4434", 0.85)
	mat_floor_figure = _mat("#3f3026", 0.95)
	mat_floor_entry = _mat("#6a5140", 0.8)
	mat_floor_atelier = _mat("#5c3f2c", 0.75)
	mat_wall = _mat("#c7b69c", 0.9)
	mat_wall_corridor = _mat("#a48f75", 0.95)
	mat_wall_bed = _mat("#9f9a86", 0.95)
	mat_wall_figure = _mat("#6e5b49", 0.95)
	mat_wall_entry = _mat("#b8a58c", 0.9)
	mat_wall_exterior = _mat("#5a4a3c", 0.95)
	mat_wall_atelier = _mat("#4d4038", 0.95)
	mat_ceiling = _mat("#2b2620", 1.0)
	mat_wood = _mat("#6b4a35", 0.8)
	mat_wood_dark = _mat("#4b3224", 0.85)
	mat_door = _mat("#5a3a28", 0.7)
	mat_brass = _mat("#c9a15a", 0.35, 0.75)
	mat_cream = _mat("#e8ddca", 0.9)
	mat_rug_play = _mat("#8e3445", 0.95)
	mat_rug_bed = _mat("#4f3a4a", 0.95)
	mat_rug_corridor = _mat("#6d3a3a", 0.95)
	mat_ball = _mat("#a8763f", 0.6)
	mat_doll_skin = _mat("#d9b98a", 0.9)
	mat_doll_cloth = _mat("#7d3a3f", 0.95)
	mat_mirror = _mat("#6f8790", 0.08, 1.0)
	mat_rain = _mat("#8fc3cf", 0.2)
	mat_red = _mat("#7d3a3f", 0.9)
	mat_dark = _mat("#211a16", 1.0)
	mat_candle = _mat("#f2d38a", 0.5)
	mat_candle.emission_enabled = true
	mat_candle.emission = Color.html("#f2d38a")
	mat_candle.emission_energy_multiplier = 2.0
	mat_window = _mat("#5d8fa8", 0.2)
	mat_window.emission_enabled = true
	mat_window.emission = Color.html("#5d8fa8")
	mat_window.emission_energy_multiplier = 1.6

func _make_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.008, 0.010, 0.013)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.13, 0.14, 0.16)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.02, 0.025, 0.03)
	env.fog_density = 0.008
	we.environment = env
	add_child(we)

func _box(parent: Node3D, size: Vector3, pos: Vector3, m: Material, collide := true, rot := Vector3.ZERO) -> Node3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation = rot
	parent.add_child(body)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = m
	body.add_child(mi)
	if collide:
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		cs.shape = shape
		body.add_child(cs)
	return body

func _add_mesh(parent: Node3D, mesh: Mesh, pos: Vector3, m: Material, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi

func _omni(parent: Node3D, pos: Vector3, color: Color, energy: float, radius: float, shadows := false) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.shadow_enabled = shadows
	parent.add_child(light)
	return light

func _label(text: String, pos: Vector3, color: Color, size := 40, no_depth := false) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = size
	label.pixel_size = 0.0045
	label.modulate = color
	label.outline_size = 10
	label.outline_modulate = Color(0, 0, 0, 0.8)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = no_depth
	label.render_priority = 2
	add_child(label)
	return label

func _floor(parent: Node3D, x0: float, z0: float, x1: float, z1: float, m: Material) -> void:
	_box(parent, Vector3(x1 - x0, 0.12, z1 - z0), Vector3((x0 + x1) * 0.5, -0.06, (z0 + z1) * 0.5), m, true)

func _ceiling(parent: Node3D, x0: float, z0: float, x1: float, z1: float) -> void:
	var body := _box(parent, Vector3(x1 - x0, 0.12, z1 - z0), Vector3((x0 + x1) * 0.5, WALL_H + 0.06, (z0 + z1) * 0.5), mat_ceiling, true)
	body.add_to_group("Ceiling")

func _wall_x(parent: Node3D, x: float, z0: float, z1: float, y0: float, y1: float, m: Material) -> void:
	_box(parent, Vector3(WALL_T, y1 - y0, z1 - z0), Vector3(x, (y0 + y1) * 0.5, (z0 + z1) * 0.5), m, true)

func _wall_z(parent: Node3D, z: float, x0: float, x1: float, y0: float, y1: float, m: Material) -> void:
	_box(parent, Vector3(x1 - x0, y1 - y0, WALL_T), Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, z), m, true)

func _hinge(name: String, size: Vector3, offset: Vector3, hinge_pos: Vector3, rot_a: Vector3, rot_b: Vector3,
		prompt_a: String, prompt_b: String, start_at_b: bool, disable_a: bool, disable_b: bool, m: Material) -> Node3D:
	var body = preload("res://scripts/foldable.gd").new()
	body.name = name
	body.set("rotation_a", rot_a)
	body.set("rotation_b", rot_b)
	body.set("prompt_a", prompt_a)
	body.set("prompt_b", prompt_b)
	body.set("start_at_b", start_at_b)
	body.set("disable_collision_at_a", disable_a)
	body.set("disable_collision_at_b", disable_b)
	body.set("duration", 1.1)
	body.position = hinge_pos
	body.sync_to_physics = false

	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = m
	mi.position = offset
	body.add_child(mi)

	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	cs.position = offset
	body.add_child(cs)

	add_child(body)
	return body

# ---------------------------------------------------------------------------
# House: the compact vista plan, scaled for walking
# ---------------------------------------------------------------------------

func _build_house() -> void:
	var house := Node3D.new()
	house.name = "House"
	add_child(house)

	# Floors.
	_floor(house, 0.0, 0.0, 8.4, 7.0, mat_floor_play)
	_floor(house, 8.4, 0.0, 10.5, 7.7, mat_floor_corridor)
	_floor(house, 10.5, 0.0, 15.4, 5.6, mat_floor_bed)
	_floor(house, 10.5, 7.0, 13.3, 9.1, mat_floor_figure)
	_floor(house, 0.0, 7.0, 3.5, 9.1, mat_floor_entry)
	_floor(house, 3.5, 7.7, 10.5, 9.1, mat_floor_corridor)

	# Ceilings.
	_ceiling(house, 0.0, 0.0, 8.4, 7.0)
	_ceiling(house, 8.4, 0.0, 10.5, 7.7)
	_ceiling(house, 10.5, 0.0, 15.4, 5.6)
	_ceiling(house, 10.5, 7.0, 13.3, 9.1)
	_ceiling(house, 0.0, 7.0, 3.5, 9.1)
	_ceiling(house, 3.5, 7.7, 10.5, 9.1)

	# North wall: playroom, corridor, bedroom.
	_wall_z(house, 0.0, 0.0, 8.4, 0.0, WALL_H, mat_wall)
	_wall_z(house, 0.0, 8.4, 10.5, 0.0, WALL_H, mat_wall_corridor)
	_wall_z(house, 0.0, 10.5, 15.4, 0.0, WALL_H, mat_wall_bed)

	# West: F1 replaces the playroom wall; entry wall is static.
	_wall_x(house, 0.0, 7.0, 9.1, 0.0, WALL_H, mat_wall_entry)

	# East side.
	_wall_x(house, 15.4, 0.0, 5.6, 0.0, WALL_H, mat_wall_bed)
	_wall_x(house, 13.3, 7.0, 9.1, 0.0, WALL_H, mat_wall_figure)

	# South facade with the front door opening.
	_wall_z(house, 9.1, 0.0, 1.12, 0.0, WALL_H, mat_wall_exterior)
	_wall_z(house, 9.1, 2.52, 15.4, 0.0, WALL_H, mat_wall_exterior)
	_wall_z(house, 9.1, 1.12, 2.52, DOOR_H, WALL_H, mat_wall_exterior)

	# Playroom south wall / entry north wall, with the door.
	_wall_z(house, 7.0, 0.0, 1.12, 0.0, WALL_H, mat_wall)
	_wall_z(house, 7.0, 2.52, 8.4, 0.0, WALL_H, mat_wall)
	_wall_z(house, 7.0, 1.12, 2.52, DOOR_H, WALL_H, mat_wall)

	# Playroom east wall / corridor west wall.
	_wall_x(house, 8.4, 0.0, 0.6, 0.0, WALL_H, mat_wall)
	_wall_x(house, 8.4, 2.0, 3.0, DOOR_H, WALL_H, mat_wall)
	_wall_x(house, 8.4, 4.6, 7.7, 0.0, WALL_H, mat_wall_corridor)

	# Corridor east wall: bedroom doors and solid pieces.
	_wall_x(house, 10.5, 0.0, 1.4, 0.0, WALL_H, mat_wall_bed)
	_wall_x(house, 10.5, 1.4, 2.8, DOOR_H, WALL_H, mat_wall_bed)
	_wall_x(house, 10.5, 2.8, 3.92, 0.0, WALL_H, mat_wall_bed)
	_wall_x(house, 10.5, 3.92, 5.32, DOOR_H, WALL_H, mat_wall_bed)
	_wall_x(house, 10.5, 5.32, 7.0, 0.0, WALL_H, mat_wall_corridor)

	# Figure-room west wall.
	_wall_x(house, 10.5, 7.0, 7.56, 0.0, WALL_H, mat_wall_figure)
	_wall_x(house, 10.5, 7.56, 8.4, DOOR_H, WALL_H, mat_wall_figure)
	_wall_x(house, 10.5, 8.4, 9.1, 0.0, WALL_H, mat_wall_figure)

	# Bedroom south and figure-room north.
	_wall_z(house, 5.6, 10.5, 15.4, 0.0, WALL_H, mat_wall_bed)
	_wall_z(house, 7.0, 10.5, 13.3, 0.0, WALL_H, mat_wall_figure)

	# Entry east side and passage north.
	_wall_x(house, 3.5, 7.0, 7.7, 0.0, WALL_H, mat_wall_entry)
	_wall_z(house, 7.7, 3.5, 8.4, 0.0, WALL_H, mat_wall_corridor)

	# The four folds.
	_hinge("F1", Vector3(WALL_T, WALL_H, 7.0), Vector3(WALL_T * 0.5, WALL_H * 0.5, 3.5),
			Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(0.0, 0.0, deg_to_rad(-65.0)),
			"dobrar a parede oeste", "desdobrar a parede oeste", false, false, false, mat_wall)

	_hinge("F2", Vector3(0.12, WALL_H, 1.4), Vector3(0.0, WALL_H * 0.5, 0.7),
			Vector3(8.4, 0.0, 0.6), Vector3.ZERO, Vector3(0.0, deg_to_rad(80.0), 0.0),
			"dobrar o painel norte", "desdobrar o painel norte", false, false, false, mat_wall_corridor)

	_hinge("F3", Vector3(0.06, DOOR_H, 1.0), Vector3(0.0, DOOR_H * 0.5, 0.5),
			Vector3(8.4, 0.0, 2.0), Vector3(0.0, 0.0, deg_to_rad(-90.0)), Vector3.ZERO,
			"levantar a porta", "deitar a porta", false, true, false, mat_door)

	_hinge("F4", Vector3(0.12, WALL_H, 1.6), Vector3(0.0, WALL_H * 0.5, -0.8),
			Vector3(8.4, 0.0, 4.6), Vector3.ZERO, Vector3(0.0, deg_to_rad(-80.0), 0.0),
			"dobrar o painel sul", "desdobrar o painel sul", false, false, false, mat_wall_corridor)

	# Doors.
	_hinge("DoorPlayroom", Vector3(1.4, DOOR_H, 0.06), Vector3(0.7, DOOR_H * 0.5, 0.0),
			Vector3(1.12, 0.0, 7.0), Vector3.ZERO, Vector3(0.0, deg_to_rad(90.0), 0.0),
			"abrir a porta do quarto de brincar", "fechar a porta do quarto de brincar",
			true, false, false, mat_door)

	_hinge("DoorBedroomFront", Vector3(0.06, DOOR_H, 1.4), Vector3(0.0, DOOR_H * 0.5, 0.7),
			Vector3(10.5, 0.0, 1.4), Vector3.ZERO, Vector3(0.0, deg_to_rad(70.0), 0.0),
			"abrir a porta da frente do quarto", "fechar a porta da frente do quarto",
			false, false, false, mat_door)

	_hinge("DoorBedroomBack", Vector3(0.06, DOOR_H, 1.4), Vector3(0.0, DOOR_H * 0.5, 0.7),
			Vector3(10.5, 0.0, 3.92), Vector3.ZERO, Vector3(0.0, deg_to_rad(-70.0), 0.0),
			"abrir a porta dos fundos", "fechar a porta dos fundos",
			false, false, false, mat_door)

	_hinge("DoorFigure", Vector3(0.06, DOOR_H, 0.84), Vector3(0.0, DOOR_H * 0.5, 0.42),
			Vector3(10.5, 0.0, 7.56), Vector3.ZERO, Vector3(0.0, deg_to_rad(90.0), 0.0),
			"abrir a porta das figuras", "fechar a porta das figuras",
			false, false, false, mat_door)

	var front_door := _hinge("DoorFront", Vector3(1.4, DOOR_H, 0.08), Vector3(0.7, DOOR_H * 0.5, 0.0),
			Vector3(1.12, 0.0, 9.1), Vector3.ZERO, Vector3(0.0, deg_to_rad(-110.0), 0.0),
			"abrir a porta da rua", "fechar a porta da rua",
			true, false, false, mat_door)
	var knob := MeshInstance3D.new()
	var knob_mesh := SphereMesh.new()
	knob_mesh.radius = 0.055
	knob_mesh.height = 0.11
	knob.mesh = knob_mesh
	knob.material_override = mat_brass
	knob.position = Vector3(1.3, 1.0, 0.06)
	front_door.add_child(knob)

	# Brass thresholds.
	_box(house, Vector3(1.4, 0.02, 0.12), Vector3(1.82, 0.01, 7.0), mat_brass, false)
	_box(house, Vector3(1.4, 0.02, 0.12), Vector3(1.82, 0.01, 9.1), mat_brass, false)
	_box(house, Vector3(0.12, 0.02, 1.4), Vector3(10.5, 0.01, 2.1), mat_brass, false)
	_box(house, Vector3(0.12, 0.02, 1.4), Vector3(10.5, 0.01, 4.62), mat_brass, false)

	# Bedroom window (visual; the wall stays solid).
	_box(house, Vector3(2.0, 1.3, 0.04), Vector3(12.5, 1.65, 0.04), mat_window, false)
	_box(house, Vector3(2.2, 0.08, 0.08), Vector3(12.5, 1.0, 0.06), mat_wood, false)
	_box(house, Vector3(2.2, 0.08, 0.08), Vector3(12.5, 2.3, 0.06), mat_wood, false)
	_box(house, Vector3(0.08, 1.3, 0.08), Vector3(11.5, 1.65, 0.06), mat_wood, false)
	_box(house, Vector3(0.08, 1.3, 0.08), Vector3(13.5, 1.65, 0.06), mat_wood, false)

	# Lighting inside.
	_omni(house, Vector3(4.2, 2.55, 3.5), Color(1.0, 0.78, 0.5), 1.4, 6.5, false)
	_omni(house, Vector3(1.6, 2.2, 3.6), Color(1.0, 0.72, 0.42), 0.55, 4.0, false)
	_omni(house, Vector3(1.2, 1.0, 4.0), Color(1.0, 0.65, 0.4), 0.45, 3.0, false)
	_omni(house, Vector3(12.5, 2.2, 0.7), Color(0.55, 0.7, 0.95), 1.3, 5.5, false)
	_omni(house, Vector3(11.2, 1.2, 2.0), Color(1.0, 0.62, 0.35), 0.45, 3.0, false)
	_omni(house, Vector3(1.8, 2.3, 8.1), Color(1.0, 0.72, 0.45), 0.55, 3.2, false)
	_omni(house, Vector3(8.6, 2.1, 1.1), Color(1.0, 0.7, 0.45), 0.8, 4.0, false)
	_omni(house, Vector3(8.6, 2.1, 5.4), Color(1.0, 0.7, 0.45), 0.7, 4.0, false)
	_omni(house, Vector3(9.45, 2.1, 7.8), Color(1.0, 0.7, 0.45), 0.6, 3.5, false)

func _build_furniture() -> void:
	# Playroom: rug, shelf, table, blocks, ball, music box.
	_box(self, Vector3(4.6, 0.03, 2.8), Vector3(3.8, 0.015, 4.4), mat_rug_play, false)
	_box(self, Vector3(2.2, 1.8, 0.35), Vector3(4.2, 0.9, 0.22), mat_wood_dark, true)
	_box(self, Vector3(0.8, 0.6, 0.04), Vector3(6.7, 1.6, 0.06), mat_cream, false)
	_box(self, Vector3(0.56, 0.38, 0.02), Vector3(6.7, 1.6, 0.02), mat_red, false)
	for i in range(5):
		_box(self, Vector3(0.16, 0.34, 0.06), Vector3(3.4 + i * 0.28, 1.22, 0.42), mat_red if i % 2 == 0 else mat_cream, false)
	for i in range(4):
		_box(self, Vector3(0.14, 0.28, 0.06), Vector3(3.55 + i * 0.3, 0.72, 0.42), mat_cream if i % 2 == 0 else mat_brass, false)

	_box(self, Vector3(1.6, 0.12, 0.9), Vector3(3.3, 0.5, 4.6), mat_wood, true)
	for dx in [-0.65, 0.65]:
		for dz in [-0.3, 0.3]:
			_box(self, Vector3(0.08, 0.5, 0.08), Vector3(3.3 + dx, 0.25, 4.6 + dz), mat_wood_dark, false)
	_box(self, Vector3(0.5, 0.45, 0.5), Vector3(2.25, 0.225, 4.75), mat_wood, true)
	for i in range(3):
		_box(self, Vector3(0.18, 0.18, 0.18), Vector3(2.85 + i * 0.22, 0.65, 4.45 + (i % 2) * 0.18), mat_red if i == 1 else mat_cream, false)

	# The F1 cabana: blanket and cushion under the folded wall.
	_box(self, Vector3(1.4, 0.03, 1.2), Vector3(1.4, 0.015, 3.5), mat_rug_play, false)
	_box(self, Vector3(0.5, 0.12, 0.5), Vector3(1.2, 0.06, 3.5), mat_cream, false)

	# A small house inside the house.
	_box(self, Vector3(0.9, 0.55, 0.7), Vector3(7.5, 0.275, 1.0), mat_wood, true)
	_box(self, Vector3(0.55, 0.05, 0.8), Vector3(7.25, 0.62, 1.0), mat_red, false, Vector3(0.0, 0.0, deg_to_rad(30.0)))
	_box(self, Vector3(0.55, 0.05, 0.8), Vector3(7.75, 0.62, 1.0), mat_red, false, Vector3(0.0, 0.0, deg_to_rad(-30.0)))
	_box(self, Vector3(0.18, 0.3, 0.02), Vector3(7.5, 0.2, 1.36), mat_dark, false)
	_box(self, Vector3(0.12, 0.12, 0.02), Vector3(7.2, 0.35, 1.36), mat_window, false)

	var mb = preload("res://scripts/music_box.gd").new()
	mb.name = "MusicBox"
	mb.position = Vector3(3.35, 0.63, 4.45)
	add_child(mb)
	var mb_mesh := MeshInstance3D.new()
	var mb_box := BoxMesh.new()
	mb_box.size = Vector3(0.38, 0.18, 0.26)
	mb_mesh.mesh = mb_box
	mb_mesh.material_override = mat_wood_dark
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
	handle.material_override = mat_brass
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
	ball_mesh.material_override = mat_ball
	ball.add_child(ball_mesh)
	var ball_cs := CollisionShape3D.new()
	var ball_shape := SphereShape3D.new()
	ball_shape.radius = 0.14
	ball_cs.shape = ball_shape
	ball.add_child(ball_cs)
	add_child(ball)

	# Bedroom: bed, doll, mirror, wardrobe, rug.
	_box(self, Vector3(2.2, 0.25, 3.1), Vector3(13.2, 0.2, 3.0), mat_wood_dark, true)
	_box(self, Vector3(2.05, 0.22, 3.0), Vector3(13.2, 0.46, 3.0), mat_cream, true)
	_box(self, Vector3(0.9, 0.14, 0.45), Vector3(13.2, 0.62, 1.75), mat_cream, false)
	_box(self, Vector3(2.05, 0.08, 1.4), Vector3(13.2, 0.61, 3.45), mat_doll_cloth, false)
	_box(self, Vector3(2.2, 0.7, 0.08), Vector3(13.2, 0.55, 1.48), mat_wood_dark, false)
	_box(self, Vector3(3.4, 0.03, 2.6), Vector3(13.0, 0.015, 3.7), mat_rug_bed, false)
	_box(self, Vector3(0.7, 2.0, 1.4), Vector3(15.0, 1.0, 4.6), mat_wood_dark, true)
	_box(self, Vector3(0.06, 1.6, 1.0), Vector3(15.32, 1.35, 2.0), mat_mirror, false)
	_box(self, Vector3(0.08, 1.7, 0.08), Vector3(15.34, 1.35, 1.5), mat_wood, false)
	_box(self, Vector3(0.08, 1.7, 0.08), Vector3(15.34, 1.35, 2.5), mat_wood, false)
	_box(self, Vector3(0.08, 0.08, 1.0), Vector3(15.34, 2.2, 2.0), mat_wood, false)
	_box(self, Vector3(0.08, 0.08, 1.0), Vector3(15.34, 0.5, 2.0), mat_wood, false)

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
	torso.material_override = mat_doll_cloth
	torso.position = Vector3(0.0, 0.25, 0.0)
	doll.add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.13
	head_mesh.height = 0.26
	head.mesh = head_mesh
	head.material_override = mat_doll_skin
	head.position = Vector3(0.0, 0.58, 0.0)
	doll.add_child(head)
	for side in [-1.0, 1.0]:
		var limb := MeshInstance3D.new()
		var limb_mesh := BoxMesh.new()
		limb_mesh.size = Vector3(0.09, 0.4, 0.09)
		limb.mesh = limb_mesh
		limb.material_override = mat_doll_skin
		limb.position = Vector3(side * 0.2, 0.22, 0.0)
		limb.rotation.z = deg_to_rad(side * 12.0)
		doll.add_child(limb)
	var doll_cs := CollisionShape3D.new()
	var doll_shape := BoxShape3D.new()
	doll_shape.size = Vector3(0.5, 0.95, 0.3)
	doll_cs.shape = doll_shape
	doll_cs.position = Vector3(0.0, 0.3, 0.0)
	doll.add_child(doll_cs)
	add_child(doll)

	# Corridor runner.
	_box(self, Vector3(0.9, 0.03, 6.0), Vector3(9.45, 0.015, 4.0), mat_rug_corridor, false)

	# Figure room: low table, candle, three chairs and occupants.
	_box(self, Vector3(0.9, 0.45, 0.55), Vector3(11.85, 0.225, 7.7), mat_wood_dark, true)
	var candle_mesh := MeshInstance3D.new()
	var candle_cyl := CylinderMesh.new()
	candle_cyl.top_radius = 0.04
	candle_cyl.bottom_radius = 0.05
	candle_cyl.height = 0.18
	candle_mesh.mesh = candle_cyl
	candle_mesh.material_override = mat_candle
	candle_mesh.position = Vector3(11.85, 0.58, 7.7)
	add_child(candle_mesh)
	var candle_light := _omni(self, Vector3(11.85, 0.8, 7.7), Color(1.0, 0.62, 0.3), 0.35, 3.0, false)

	for i in range(3):
		var x := 11.15 + i * 0.7
		_box(self, Vector3(0.45, 0.08, 0.45), Vector3(x, 0.48, 8.35), mat_wood_dark, true)
		_box(self, Vector3(0.45, 0.55, 0.08), Vector3(x, 0.78, 8.58), mat_wood_dark, false)
		_box(self, Vector3(0.34, 0.6, 0.25), Vector3(x, 0.86, 8.35), mat_dark, false)
		var occ_head := MeshInstance3D.new()
		var occ_head_mesh := SphereMesh.new()
		occ_head_mesh.radius = 0.12
		occ_head_mesh.height = 0.24
		occ_head.mesh = occ_head_mesh
		occ_head.material_override = mat_dark
		occ_head.position = Vector3(x, 1.28, 8.35)
		add_child(occ_head)

	var figure = preload("res://scripts/figure.gd").new()
	figure.name = "Figure"
	figure.position = Vector3(11.85, 0.0, 8.35)
	var figure_body := MeshInstance3D.new()
	var figure_mesh := BoxMesh.new()
	figure_mesh.size = Vector3(0.36, 0.62, 0.28)
	figure_body.mesh = figure_mesh
	figure_body.material_override = mat_dark
	figure_body.position = Vector3(0.0, 0.87, 0.0)
	figure.add_child(figure_body)
	var figure_head := MeshInstance3D.new()
	var figure_head_mesh := SphereMesh.new()
	figure_head_mesh.radius = 0.13
	figure_head_mesh.height = 0.26
	figure_head.mesh = figure_head_mesh
	figure_head.material_override = mat_dark
	figure_head.position = Vector3(0.0, 1.3, 0.0)
	figure.add_child(figure_head)
	var figure_cs := CollisionShape3D.new()
	var figure_shape := BoxShape3D.new()
	figure_shape.size = Vector3(0.42, 1.35, 0.4)
	figure_cs.shape = figure_shape
	figure_cs.position = Vector3(0.0, 0.68, 0.0)
	figure.add_child(figure_cs)
	add_child(figure)
	figure.call("setup", candle_light)

	# Entry: bench, hooks, coat.
	_box(self, Vector3(1.2, 0.4, 0.45), Vector3(0.7, 0.2, 8.5), mat_wood, true)
	for z in [7.4, 7.7, 8.0]:
		var hook := MeshInstance3D.new()
		var hook_mesh := SphereMesh.new()
		hook_mesh.radius = 0.035
		hook_mesh.height = 0.07
		hook.mesh = hook_mesh
		hook.material_override = mat_brass
		hook.position = Vector3(0.06, 1.6, z)
		add_child(hook)
	_box(self, Vector3(0.1, 0.8, 0.4), Vector3(0.14, 1.2, 7.6), mat_red, false)
	_box(self, Vector3(1.2, 0.02, 0.8), Vector3(1.82, 0.01, 8.9), mat_rug_corridor, false)

func _build_atelier() -> void:
	# West strip of the atelier: what F1 opens onto. The player cannot enter
	# it in the blockout; it exists so the fold reveals a room, not a void.
	var west := Node3D.new()
	west.name = "WestAtelier"
	add_child(west)
	_floor(west, -3.2, 0.0, 0.0, 9.1, mat_floor_atelier)
	_wall_x(west, -3.2, 0.0, 9.1, 0.0, WALL_H, mat_wall_atelier)
	_wall_z(west, 0.0, -3.2, 0.0, 0.0, WALL_H, mat_wall_atelier)
	_wall_z(west, 9.1, -3.2, 0.0, 0.0, WALL_H, mat_wall_atelier)
	_ceiling(west, -3.2, 0.0, 0.0, 9.1)
	_omni(west, Vector3(-1.6, 2.2, 4.0), Color(1.0, 0.72, 0.45), 0.5, 5.0, false)
	_box(west, Vector3(0.04, 1.5, 2.8), Vector3(-3.12, 1.65, 4.2), mat_window, false)
	_box(west, Vector3(0.08, 0.08, 3.0), Vector3(-3.1, 0.9, 4.2), mat_wood, false)
	_box(west, Vector3(0.08, 0.08, 3.0), Vector3(-3.1, 2.4, 4.2), mat_wood, false)
	_box(west, Vector3(0.08, 1.5, 0.08), Vector3(-3.1, 1.65, 2.8), mat_wood, false)
	_box(west, Vector3(0.08, 1.5, 0.08), Vector3(-3.1, 1.65, 5.6), mat_wood, false)
	for i in range(7):
		_box(west, Vector3(0.012, 1.2, 0.012), Vector3(-3.09, 1.65, 3.1 + i * 0.36), mat_rain, false)

	var atelier := Node3D.new()
	atelier.name = "Atelier"
	add_child(atelier)
	_floor(atelier, 0.0, 9.1, 15.4, 12.5, mat_floor_atelier)
	_ceiling(atelier, 0.0, 9.1, 15.4, 12.5)
	_wall_x(atelier, 0.0, 9.1, 12.5, 0.0, WALL_H, mat_wall_atelier)
	_wall_x(atelier, 15.4, 9.1, 12.5, 0.0, WALL_H, mat_wall_atelier)
	_wall_z(atelier, 12.5, 0.0, 15.4, 0.0, WALL_H, mat_wall_atelier)

	# Desk.
	_box(atelier, Vector3(3.4, 0.12, 1.2), Vector3(11.2, 0.8, 11.2), mat_wood, true)
	for dx in [-1.5, 1.5]:
		for dz in [-0.45, 0.45]:
			_box(atelier, Vector3(0.1, 0.8, 0.1), Vector3(11.2 + dx, 0.4, 11.2 + dz), mat_wood_dark, false)

	# Lamp: base, stem, shade, warm light.
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.2
	base_mesh.bottom_radius = 0.2
	base_mesh.height = 0.06
	_add_mesh(atelier, base_mesh, Vector3(12.3, 0.86, 11.15), mat_brass)
	var stem := MeshInstance3D.new()
	var stem_mesh := CylinderMesh.new()
	stem_mesh.top_radius = 0.025
	stem_mesh.bottom_radius = 0.025
	stem_mesh.height = 0.45
	stem.mesh = stem_mesh
	stem.material_override = mat_brass
	stem.position = Vector3(12.3, 1.12, 11.15)
	atelier.add_child(stem)
	var shade := MeshInstance3D.new()
	var shade_mesh := CylinderMesh.new()
	shade_mesh.top_radius = 0.07
	shade_mesh.bottom_radius = 0.28
	shade_mesh.height = 0.22
	shade.mesh = shade_mesh
	shade.material_override = mat_cream
	shade.position = Vector3(12.3, 1.38, 11.15)
	atelier.add_child(shade)
	var bulb := MeshInstance3D.new()
	var bulb_mesh := SphereMesh.new()
	bulb_mesh.radius = 0.07
	bulb_mesh.height = 0.14
	bulb.mesh = bulb_mesh
	bulb.material_override = mat_candle
	bulb.position = Vector3(12.3, 1.28, 11.15)
	atelier.add_child(bulb)
	_omni(atelier, Vector3(12.3, 1.28, 11.15), Color(1.0, 0.74, 0.45), 2.2, 7.0, true)

	# Desk chair.
	_box(atelier, Vector3(0.52, 0.06, 0.5), Vector3(11.2, 0.45, 10.55), mat_wood_dark, true)
	_box(atelier, Vector3(0.52, 0.55, 0.06), Vector3(11.2, 0.72, 10.3), mat_wood_dark, false)
	for dx in [-0.2, 0.2]:
		for dz in [-0.2, 0.2]:
			_box(atelier, Vector3(0.06, 0.45, 0.06), Vector3(11.2 + dx, 0.225, 10.55 + dz), mat_wood_dark, false)
	_omni(atelier, Vector3(3.2, 2.3, 11.0), Color(1.0, 0.72, 0.45), 0.7, 4.5, false)

	# Notebook and pencil.
	_box(atelier, Vector3(0.5, 0.02, 0.35), Vector3(11.0, 0.87, 11.1), mat_cream, false)
	_box(atelier, Vector3(0.02, 0.02, 0.4), Vector3(10.6, 0.89, 11.15), mat_dark, false)

	# Rain window on the south wall.
	_box(atelier, Vector3(5.0, 1.5, 0.04), Vector3(7.0, 1.65, 12.43), mat_window, false)
	_box(atelier, Vector3(5.2, 0.08, 0.08), Vector3(7.0, 0.9, 12.4), mat_wood, false)
	_box(atelier, Vector3(5.2, 0.08, 0.08), Vector3(7.0, 2.4, 12.4), mat_wood, false)
	_box(atelier, Vector3(0.08, 1.5, 0.08), Vector3(4.5, 1.65, 12.4), mat_wood, false)
	_box(atelier, Vector3(0.08, 1.5, 0.08), Vector3(9.5, 1.65, 12.4), mat_wood, false)
	for i in range(12):
		var x := 4.7 + i * 0.42
		_box(atelier, Vector3(0.012, 1.1, 0.012), Vector3(x, 1.65, 12.41), mat_rain, false, Vector3(0.0, 0.0, deg_to_rad(-8.0)))
	_omni(atelier, Vector3(7.0, 1.6, 12.1), Color(0.45, 0.6, 0.8), 0.6, 4.5, false)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(preload("res://scripts/player.gd"))
	player.position = Vector3(2.0, 0.2, 11.2)

	var capsule := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.7
	capsule.shape = shape
	capsule.position.y = 0.85
	player.add_child(capsule)

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position.y = 1.62
	camera.fov = 70.0
	camera.near = 0.05
	camera.far = 80.0
	player.add_child(camera)

	var ray := RayCast3D.new()
	ray.name = "RayCast3D"
	ray.target_position = Vector3(0.0, 0.0, -3.4)
	ray.collision_mask = 1
	ray.enabled = true
	camera.add_child(ray)

	var flashlight := SpotLight3D.new()
	flashlight.name = "SpotLight3D"
	flashlight.position = Vector3(0.12, -0.08, 0.0)
	flashlight.light_color = Color(1.0, 0.93, 0.8)
	flashlight.light_energy = 0.8
	flashlight.spot_range = 10.0
	flashlight.spot_angle = 38.0
	flashlight.shadow_enabled = false
	camera.add_child(flashlight)

	add_child(player)
	ray.add_exception(player)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	crosshair = ColorRect.new()
	crosshair.color = Color(0.95, 0.9, 0.8, 0.55)
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.offset_left = -2.0
	crosshair.offset_top = -2.0
	crosshair.offset_right = 2.0
	crosshair.offset_bottom = 2.0
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(crosshair)

	prompt_label = Label.new()
	prompt_label.text = ""
	prompt_label.visible = false
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_label.offset_left = -360.0
	prompt_label.offset_right = 360.0
	prompt_label.offset_top = -78.0
	prompt_label.offset_bottom = -42.0
	prompt_label.add_theme_font_size_override("font_size", 18)
	prompt_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.8))
	prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	prompt_label.add_theme_constant_override("shadow_offset_x", 2)
	prompt_label.add_theme_constant_override("shadow_offset_y", 2)
	root.add_child(prompt_label)

	help_label = Label.new()
	help_label.text = "FAZ DE CONTA — blockout\nWASD mover · mouse olhar · E interagir · F lanterna · R reiniciar · ESC liberar mouse\nDobras: F1 parede oeste · F2/F4 painéis do corredor · F3 porta deitada\nThe front door is open. Exit is a choice."
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	help_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	help_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	help_label.offset_left = 20.0
	help_label.offset_top = 16.0
	help_label.offset_right = 980.0
	help_label.offset_bottom = 110.0
	help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_label.add_theme_font_size_override("font_size", 14)
	help_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.74))
	help_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	help_label.add_theme_constant_override("shadow_offset_x", 2)
	help_label.add_theme_constant_override("shadow_offset_y", 2)
	root.add_child(help_label)

	var tw := create_tween()
	tw.tween_interval(9.0)
	tw.tween_property(help_label, "modulate:a", 0.0, 2.0)

func _add_labels() -> void:
	var cream := Color(0.92, 0.86, 0.74)
	var orange := Color(0.76, 0.35, 0.2)
	var teal := Color(0.25, 0.55, 0.52)

	_label("1 · QUARTO DE BRINCAR", Vector3(4.2, 2.45, 0.9), cream, 30)
	_label("2 · QUARTO DE DORMIR", Vector3(12.9, 2.45, 0.9), cream, 30)
	_label("3 · CORREDOR", Vector3(9.45, 2.45, 0.8), cream, 30)
	_label("3B · SALA DAS FIGURAS", Vector3(11.9, 2.2, 7.6), cream, 26)
	_label("ENTRADA", Vector3(1.75, 2.3, 7.7), cream, 24)
	_label("ATELIÊ", Vector3(12.2, 2.45, 10.9), cream, 28)

	_label("F1", Vector3(0.9, 2.2, 3.5), orange, 46)
	_label("F2", Vector3(8.72, 2.2, 1.3), orange, 34)
	_label("F3", Vector3(9.4, 0.35, 2.5), orange, 34)
	_label("F4", Vector3(8.72, 2.2, 3.8), orange, 34)
	_label("PORTA DA RUA", Vector3(1.82, 2.35, 9.0), teal, 24)

# ---------------------------------------------------------------------------
# Screenshot mode (visual review only)
# ---------------------------------------------------------------------------

func _prepare_shot(mode: String) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if help_label != null:
		help_label.visible = false
	if prompt_label != null:
		prompt_label.visible = false
	if crosshair != null:
		crosshair.visible = false
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.velocity = Vector3.ZERO
	var camera := player.get_node("Camera3D") as Camera3D

	if mode == "top":
		for node in get_tree().get_nodes_in_group("Ceiling"):
			node.visible = false
		var sun := DirectionalLight3D.new()
		sun.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		sun.light_energy = 1.4
		sun.shadow_enabled = false
		add_child(sun)

	match mode:
		"atelier":
			player.position = Vector3(14.2, 0.2, 10.7)
			player.rotation.y = deg_to_rad(105.0)
			camera.rotation.x = deg_to_rad(-5.0)
		"corridor":
			player.position = Vector3(9.45, 0.2, 6.8)
			player.rotation.y = 0.0
			camera.rotation.x = deg_to_rad(-6.0)
		"fold":
			player.position = Vector3(7.0, 0.2, 5.8)
			player.rotation.y = deg_to_rad(50.0)
			camera.rotation.x = deg_to_rad(-8.0)
			var f1 := get_node_or_null("F1")
			if f1 != null and f1.has_method("interact"):
				f1.interact()
		"top":
			player.position = Vector3(7.7, 8.5, 5.8)
			player.rotation.y = 0.0
			camera.rotation.x = deg_to_rad(-90.0)
		_:
			player.position = Vector3(7.0, 0.2, 5.8)
			player.rotation.y = deg_to_rad(50.0)
			camera.rotation.x = deg_to_rad(-8.0)
	_take_shot(mode)

func _take_shot(mode: String) -> void:
	await get_tree().create_timer(1.8).timeout
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image != null:
		var path := "res://blockout-%s.png" % mode
		var err := image.save_png(path)
		print("shot: ", path, " err=", err)
	else:
		print("shot: no image")
	get_tree().quit()
