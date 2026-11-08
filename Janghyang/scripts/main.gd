extends Node3D
## Janghyang — slice blockout.
## Builds the house from primitives so the plan, the folds and the loop can be
## tested before art. Everything is visual: no audio, no fail state.

const WALL_H := 2.7
const WALL_T := 0.14
const DOOR_H := 2.1
## Where Elias wakes: inside the model, at the entry, facing into the house.
const SPAWN := Vector3(1.8, 0.2, 8.3)
## Scale of the real workshop around the model.
const GIANT := 12.0
const CatalogData = preload("res://scripts/catalog_data.gd")
const Catalog = preload("res://scripts/catalog.gd")
const CatalogTarget = preload("res://scripts/catalog_target.gd")
const VisitState = preload("res://scripts/visit_state.gd")
const SfxBank = preload("res://scripts/sfx_bank.gd")
const EchoRecorder = preload("res://scripts/echo_recorder.gd")
const MirrorBrain = preload("res://scripts/mirror_brain.gd")
const HouseMirror = preload("res://scripts/house_mirror.gd")
const MirrorReflection = preload("res://scripts/mirror_reflection.gd")
const HourEvent = preload("res://scripts/hour_event.gd")
const Mannequin = preload("res://scripts/mannequin.gd")
const Ending = preload("res://scripts/ending.gd")
const Hands = preload("res://scripts/hands.gd")
const DreadModel = preload("res://scripts/dread_model.gd")
const Dread = preload("res://scripts/dread.gd")
const Breakable = preload("res://scripts/breakable.gd")
const Registry = preload("res://scripts/areas/registry.gd")
## Only for the drawer's hole in the floors above it, until the house and the
## tabletop move into their own areas (Tasks 7 and 8).
const AreaGaveta = preload("res://scripts/areas/gaveta.gd")
const AreaLeste = preload("res://scripts/areas/leste.gd")
const QuestModel = preload("res://scripts/quest_model.gd")
const Atlas = preload("res://scripts/atlas.gd")
const Gastos = preload("res://scripts/gastos.gd")
const Pretend = preload("res://scripts/pretend.gd")
const Score = preload("res://scripts/score.gd")
const SettingsUI = preload("res://scripts/settings_ui.gd")
## Elias's real body, sitting at the workshop bench south of the dome.
const GIANT_SEAT := Vector3(2.0, -10.0, 20.0)
## Where his right hand rests: the dome's top, over the entry.
const GIANT_HAND := Vector3(2.2, 3.65, 12.75)
const ELIAS_STYLE := {"coat": Color("#4a5866"), "skin": Color("#d9b99b"), "hair": Color("#4a3a2c"), "trousers": Color("#2b2b30")}
## Verbs the house can give back; opening doors and winding are not mirrored.
const MIRRORED_VERBS := [&"dobrar", &"rolar", &"boneco", &"bater"]
const BEDROOM_X := Vector2(10.5, 15.4)
const BEDROOM_Z := Vector2(0.0, 5.6)
## The hollow part of the playroom's north wall, under the drawing (x, y).
const PANEL := Rect2(6.15, 0.0, 1.1, 1.25)
## The cracked pane of the dome's east wall, out onto the bench (z range).
const CRACKED_Z := Vector2(9.1, 12.5)
## Where Elias wakes after a hug or a fall, by the floor he is on: where that
## floor begins. The crawlspace has no room to stand, so its point is outside.
const _LEGACY_SAFE := {
	&"casa": SPAWN,
	&"tampo": AreaLeste.SAFE,
}
## Lots struck by setting foot somewhere, breaking something, or cataloguing.
const _LEGACY_ROOM_TASKS := {&"loja_varela": &"chegar_relojoaria"}
const _LEGACY_BREAK_TASKS := {"CrackedGlass": &"quebrar_redoma"}
const _LEGACY_CATALOG_TASKS := {&"relogio_entrada": &"cat_relogio", &"desenho": &"cat_desenho", &"pagina_cabana": &"pagina"}
## The maps main reads: the legacy ones above with every registered area's own
## entries over them (an area's word wins once it has moved to the registry).
var LEVEL_SAFE: Dictionary = _LEGACY_SAFE.merged(Registry.safe_points(), true)
var ROOM_TASKS: Dictionary = _LEGACY_ROOM_TASKS.merged(Registry.merged("tasks"), true)
var BREAK_TASKS: Dictionary = _LEGACY_BREAK_TASKS.merged(Registry.merged("breaks"), true)
var CATALOG_TASKS: Dictionary = _LEGACY_CATALOG_TASKS.merged(Registry.merged("catalog"), true)

signal exit_edge_reached
signal cataloged(entry: Dictionary)
signal hora_started
signal hora_ended
## Every knock of the stick, by what it sounded like (oco, tink, glass...).
signal knock_sounded(kind: StringName)

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
var mat_glass: StandardMaterial3D
var mat_chalk: StandardMaterial3D

var player: CharacterBody3D
var prompt_label: Label
var help_label: Label
var crosshair: ColorRect
var _shot_mode := ""
## The entrance clock (WindClockModel); main drives its tick.
var clock_model
## Elias's catalogue (catalog.gd).
var catalog
var notebook
## The visit's acts (visit_state.gd); it ticks the clock.
var visit
## False in the selftest: the visit does not advance on its own.
var autonomous := true
## Synthesised prototype sound (sfx_bank.gd).
var sfx
## The house's recording of the player (echo_recorder.gd).
var recorder
## The house as a mirror: brain decides, house_mirror applies.
var brain
var house_mirror
var hour_event
var ending
## The house's mood: light, fog, hum, creaks (dread.gd).
var dread
## True once Elias has walked off the tampo; ending_outcome says how.
var ended := false
var ending_outcome: StringName = &""
var _move_cool := 0.0
## The thread of the visit (quest_model.gd), the plan (atlas.gd), the floor
## Elias is on, and the nodes that act on it.
var quest
var atlas
var level := &""
var gastos
var pretend
var score
var _black: ColorRect
var _hugging := false
var settings_ui
var _shutting_down := false

func _ready() -> void:
	clock_model = preload("res://scripts/wind_clock_model.gd").new()
	catalog = Catalog.new()
	visit = VisitState.new(clock_model, catalog)
	quest = QuestModel.new()
	atlas = Atlas.new()
	recorder = EchoRecorder.new()
	brain = MirrorBrain.new()
	sfx = SfxBank.new()
	sfx.name = "Sfx"
	add_child(sfx)
	get_tree().auto_accept_quit = false
	_make_materials()
	_make_environment()
	_build_house()
	_build_furniture()
	_build_tampo()
	_build_oficina()
	for area in Registry.AREAS:
		area.build(self)
	AreaLeste.build(self)
	_build_giant_elias()
	_build_player()
	# F1 never folds onto a player sitting in the cabana.
	get_node("F1").can_toggle = func() -> bool:
		return not (player.position.x < 2.1 and player.position.z < 7.0)
	_wire_catalog()
	_wire_sound()
	_wire_mirror()
	_wire_hour()
	_wire_ending()
	_wire_dread()
	_build_ui()
	_wire_story()

	var args := OS.get_cmdline_user_args()
	if args.has("--labels"):
		_add_labels()
	for arg in args:
		if arg.begins_with("--shot"):
			_shot_mode = arg.substr(6)
			if _shot_mode.begins_with("-"):
				_shot_mode = _shot_mode.substr(1)
			if _shot_mode == "":
				_shot_mode = "playroom"
			_prepare_shot(_shot_mode)
			break

	if args.has("--tour"):
		var tour := preload("res://scripts/tour.gd").new()
		tour.name = "Tour"
		tour.main = self
		add_child(tour)

	if args.has("--selftest"):
		var test := preload("res://scripts/selftest.gd").new()
		test.main = self
		add_child(test)

func _physics_process(delta: float) -> void:
	if player == null or not visit.recording_enabled():
		return
	recorder.update(delta, player.global_position, player.rotation.y, player.camera.rotation.x, player.crouched)

func _process(delta: float) -> void:
	if player != null and atlas != null and not ended:
		_track_place()
	if autonomous and visit != null and player != null:
		if visit.update(delta, in_bedroom(player.position)) == &"hora_started":
			hora_started.emit()
		_update_mirror(delta)
	if player == null or prompt_label == null:
		return
	var lines: Array[String] = []
	var ray := player.get_node_or_null("Camera3D/RayCast3D") as RayCast3D
	if ray != null and ray.is_colliding():
		var collider := ray.get_collider()
		if collider != null and collider.has_method("get_prompt"):
			var p: String = collider.get_prompt()
			if p != "":
				lines.append("[E]  " + p)
	var target: Area3D = player.catalog_target_in_view()
	if target != null and catalog.can_catalog(target.item_id):
		lines.append("[Q]  catalogar")
	prompt_label.text = "\n".join(lines)
	prompt_label.visible = not lines.is_empty()

# ---------------------------------------------------------------------------
# Materials and helpers
# ---------------------------------------------------------------------------

func _mat(hex: String, rough := 0.85, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color.html(hex)
	m.roughness = rough
	m.metallic = metal
	return m

## Elias's colours, shared by the doll and every figure of him.
func _style_mat(part: StringName) -> StandardMaterial3D:
	return _mat(ELIAS_STYLE[part].to_html(false), 0.9)

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
	mat_glass = _mat("#9fb4c0", 0.05)
	mat_glass.albedo_color.a = 0.18
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _make_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.008, 0.010, 0.013)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.13, 0.14, 0.16)
	# Starting values only: dread.gd sets ambient and fog from the mood.
	env.ambient_light_energy = 0.3
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.02, 0.025, 0.03)
	env.fog_density = 0.012
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

## A lamp of the house itself: the mood dims and flickers these, never the
## workshop's or the giant's.
func _house_light(parent: Node3D, pos: Vector3, color: Color, energy: float, radius: float, shadows := false) -> OmniLight3D:
	var light := _omni(parent, pos, color, energy, radius, shadows)
	light.add_to_group(&"HouseLight")
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

func _cyl(parent: Node3D, radius: float, height: float, pos: Vector3, m: Material, collide := true, rot := Vector3.ZERO) -> Node3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation = rot
	parent.add_child(body)
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	_add_mesh(body, mesh, Vector3.ZERO, m)
	if collide:
		var cs := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		cs.shape = shape
		body.add_child(cs)
	return body

## Something the stick can break (breakable.gd): a box of `size` at `pos`.
func _breakable(parent: Node3D, node_name: String, kind: StringName, size: Vector3, pos: Vector3, m: Material, hits := 3) -> StaticBody3D:
	var body: StaticBody3D = Breakable.new()
	body.name = node_name
	body.kind = kind
	body.hits_needed = hits
	body.position = pos
	body.add_to_group(&"Breakable")
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = m
	body.add_child(mi)
	parent.add_child(body)
	return body

## A slab from y0 to y1 over (x0, z0)-(x1, z1) with rectangular holes,
## no collision: cut on the grid of the holes' edges, merged along x.
func _slab_with_holes(parent: Node3D, x0: float, z0: float, x1: float, z1: float, y0: float, y1: float, holes: Array, m: Material) -> void:
	var xs: Array[float] = [x0, x1]
	var zs: Array[float] = [z0, z1]
	for h: Rect2 in holes:
		xs.append_array([clampf(h.position.x, x0, x1), clampf(h.end.x, x0, x1)])
		zs.append_array([clampf(h.position.y, z0, z1), clampf(h.end.y, z0, z1)])
	xs.sort()
	zs.sort()
	for j in zs.size() - 1:
		var za := zs[j]
		var zb := zs[j + 1]
		if zb - za < 0.001:
			continue
		var in_run := false
		var run_x := x0
		for i in xs.size() - 1:
			var xa := xs[i]
			var xb := xs[i + 1]
			if xb - xa < 0.001:
				continue
			var c := Vector2((xa + xb) * 0.5, (za + zb) * 0.5)
			var solid := holes.all(func(h: Rect2) -> bool: return not h.has_point(c))
			if solid and not in_run:
				in_run = true
				run_x = xa
			elif not solid and in_run:
				in_run = false
				_box(parent, Vector3(xa - run_x, y1 - y0, zb - za), Vector3((run_x + xa) * 0.5, (y0 + y1) * 0.5, (za + zb) * 0.5), m, false)
		if in_run:
			_box(parent, Vector3(x1 - run_x, y1 - y0, zb - za), Vector3((run_x + x1) * 0.5, (y0 + y1) * 0.5, (za + zb) * 0.5), m, false)

## Rails and rungs of a ladder, from `base` up `height`; `along_x` when the
## rungs run along x (ladder on a wall facing z).
func _rungs(parent: Node3D, base: Vector3, height: float, along_x: bool) -> void:
	var across := Vector3(1.0, 0.0, 0.0) if along_x else Vector3(0.0, 0.0, 1.0)
	for side in [-0.27, 0.27]:
		var rail := Vector3(0.05, height, 0.05)
		_box(parent, rail, base + across * side + Vector3(0.0, height * 0.5, 0.0), mat_wood_dark, false)
	var y := 0.25
	while y < height:
		var size := Vector3(0.54, 0.035, 0.035) if along_x else Vector3(0.035, 0.035, 0.54)
		_box(parent, size, base + Vector3(0.0, y, 0.0), mat_wood, false)
		y += 0.32

## The volume where W and S climb (ladder.gd).
func _ladder_area(parent: Node3D, node_name: String, center: Vector3, size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.name = node_name
	area.set_script(preload("res://scripts/ladder.gd"))
	area.collision_layer = 0
	area.collision_mask = 1
	area.position = center
	area.add_to_group(&"Ladder")
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	area.add_child(cs)
	parent.add_child(area)
	return area

## A place to crouch out of a Gasto's reach.
func _hideout(parent: Node3D, node_name: String, center: Vector3, size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.name = node_name
	area.collision_layer = 0
	area.collision_mask = 1
	area.position = center
	area.add_to_group(&"Hideout")
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	area.add_child(cs)
	parent.add_child(area)
	return area

## A piece of the pocket watch (piece.gd), with a small body to aim E at.
func _piece(parent: Node3D, id: StringName, pos: Vector3) -> StaticBody3D:
	var body: StaticBody3D = preload("res://scripts/piece.gd").new()
	body.name = "Piece_" + String(id)
	body.piece_id = id
	body.position = pos
	body.add_to_group(&"Piece")
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.32, 0.22, 0.32)
	cs.shape = shape
	body.add_child(cs)
	var brass := _mat("#c9a24a", 0.35, 0.8)
	brass.emission_enabled = true
	brass.emission = Color(0.55, 0.42, 0.18)
	brass.emission_energy_multiplier = 0.35
	match id:
		&"coroa":
			_cyl(body, 0.07, 0.07, Vector3(0.0, 0.035, 0.0), brass, false)
			_cyl(body, 0.025, 0.08, Vector3(0.0, 0.04, 0.07), brass, false, Vector3(deg_to_rad(90.0), 0.0, 0.0))
		&"ponteiros":
			_box(body, Vector3(0.03, 0.01, 0.2), Vector3(0.0, 0.01, -0.06), brass, false)
			_box(body, Vector3(0.04, 0.01, 0.13), Vector3(0.04, 0.02, -0.03), brass, false, Vector3(0.0, 0.6, 0.0))
		&"mostrador":
			var face := _mat("#efe8d6", 0.5)
			face.emission_enabled = true
			face.emission = Color(0.4, 0.38, 0.32)
			face.emission_energy_multiplier = 0.3
			_cyl(body, 0.16, 0.02, Vector3(0.0, 0.01, 0.0), face, false)
		_:
			_cyl(body, 0.17, 0.07, Vector3(0.0, 0.035, 0.0), brass, false)
			_cyl(body, 0.03, 0.06, Vector3(0.0, 0.035, -0.19), brass, false, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	parent.add_child(body)
	return body

## A chalk mark the boy left: only seen with eyes closed, pretending.
func _chalk(parent: Node3D, size: Vector3, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	if mat_chalk == null:
		mat_chalk = StandardMaterial3D.new()
		mat_chalk.albedo_color = Color(0.97, 0.95, 0.88)
		mat_chalk.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = mat_chalk
	mi.position = pos
	mi.rotation = rot
	mi.visible = false
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.add_to_group(&"Chalk")
	parent.add_child(mi)
	return mi

## A chalk outline of a rectangle on a wall: `normal_x` when the wall faces x.
func _chalk_frame(parent: Node3D, center: Vector3, w: float, h: float, normal_x: bool) -> void:
	var t := 0.035
	var across := Vector3(0.0, 0.0, 1.0) if normal_x else Vector3(1.0, 0.0, 0.0)
	var flat := Vector3(0.01, 0.0, 0.0) if normal_x else Vector3(0.0, 0.0, 0.01)
	var horiz := across * w + flat + Vector3(0.0, t, 0.0)
	var vert := across * t + flat + Vector3(0.0, h, 0.0)
	_chalk(parent, horiz, center + Vector3(0.0, h * 0.5, 0.0))
	_chalk(parent, horiz, center - Vector3(0.0, h * 0.5, 0.0))
	_chalk(parent, vert, center + across * w * 0.5)
	_chalk(parent, vert, center - across * w * 0.5)

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
	_floor(house, 10.5, 0.0, AreaGaveta.HOLE.position.x, 5.6, mat_floor_bed)
	_floor(house, AreaGaveta.HOLE.position.x, AreaGaveta.HOLE.end.y, 15.4, 5.6, mat_floor_bed)
	var hole: Rect2 = AreaGaveta.HOLE
	_breakable(house, "Trapdoor", &"alcapao", Vector3(hole.size.x, 0.12, hole.size.y), Vector3(hole.get_center().x, -0.06, hole.get_center().y), mat_wood_dark)
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
	_wall_z(house, 0.0, 0.0, PANEL.position.x, 0.0, WALL_H, mat_wall)
	_wall_z(house, 0.0, PANEL.end.x, 8.4, 0.0, WALL_H, mat_wall)
	_wall_z(house, 0.0, PANEL.position.x, PANEL.end.x, PANEL.end.y, WALL_H, mat_wall)
	_breakable(house, "HollowPanel", &"oco", Vector3(PANEL.size.x, PANEL.size.y, WALL_T), Vector3(PANEL.get_center().x, PANEL.get_center().y, 0.0), mat_wall)
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
			Vector3(0.0, 0.0, 0.0), Vector3.ZERO, Vector3(0.0, 0.0, deg_to_rad(-45.0)),
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
	_house_light(house, Vector3(4.2, 2.55, 3.5), Color(1.0, 0.78, 0.5), 1.4, 6.5, false)
	_house_light(house, Vector3(1.6, 2.2, 3.6), Color(1.0, 0.72, 0.42), 0.55, 4.0, false)
	_house_light(house, Vector3(1.2, 1.0, 4.0), Color(1.0, 0.65, 0.4), 0.45, 3.0, false)
	_house_light(house, Vector3(12.5, 2.2, 0.7), Color(0.55, 0.7, 0.95), 1.3, 5.5, false)
	_house_light(house, Vector3(11.2, 1.2, 2.0), Color(1.0, 0.62, 0.35), 0.45, 3.0, false)
	_house_light(house, Vector3(1.8, 2.3, 8.1), Color(1.0, 0.72, 0.45), 0.55, 3.2, false)
	_house_light(house, Vector3(8.6, 2.1, 1.1), Color(1.0, 0.7, 0.45), 0.8, 4.0, false)
	_house_light(house, Vector3(8.6, 2.1, 5.4), Color(1.0, 0.7, 0.45), 0.7, 4.0, false)
	_house_light(house, Vector3(9.45, 2.1, 7.8), Color(1.0, 0.7, 0.45), 0.6, 3.5, false)

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
	_box(self, Vector3(1.4, 0.03, 1.2), Vector3(1.5, 0.015, 3.5), mat_rug_play, false)
	_box(self, Vector3(0.5, 0.12, 0.5), Vector3(1.5, 0.06, 3.5), mat_cream, false)

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
	torso.material_override = _style_mat(&"coat")
	torso.position = Vector3(0.0, 0.25, 0.0)
	doll.add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.13
	head_mesh.height = 0.26
	head.mesh = head_mesh
	head.material_override = _style_mat(&"skin")
	head.position = Vector3(0.0, 0.58, 0.0)
	doll.add_child(head)
	_box(doll, Vector3(0.27, 0.1, 0.28), Vector3(0.0, 0.69, 0.0), _style_mat(&"hair"), false)
	for side in [-1.0, 1.0]:
		var limb := MeshInstance3D.new()
		var limb_mesh := BoxMesh.new()
		limb_mesh.size = Vector3(0.09, 0.4, 0.09)
		limb.mesh = limb_mesh
		limb.material_override = _style_mat(&"coat")
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
	_build_story_props()

	# Hiding places in the house: under the folded wall of the cabana, and
	# the gap between the bed and the east wall, by the mirror.
	_hideout(self, "HideCabana", Vector3(1.0, 0.5, 3.5), Vector3(1.8, 1.0, 2.4))
	_hideout(self, "HideCama", Vector3(14.85, 0.5, 2.7), Vector3(0.9, 1.0, 2.2))

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
	_build_entry_clock()

func _build_entry_clock() -> void:
	# Tall case clock against the facade, beside the front door, facing in.
	var clock = preload("res://scripts/entry_clock.gd").new()
	clock.name = "EntryClock"
	clock.position = Vector3(3.1, 1.0, 8.88)
	add_child(clock)
	var case_mesh := MeshInstance3D.new()
	var case_box := BoxMesh.new()
	case_box.size = Vector3(0.5, 2.0, 0.28)
	case_mesh.mesh = case_box
	case_mesh.material_override = mat_dark
	clock.add_child(case_mesh)
	var case_cs := CollisionShape3D.new()
	var case_shape := BoxShape3D.new()
	case_shape.size = Vector3(0.5, 2.0, 0.28)
	case_cs.shape = case_shape
	clock.add_child(case_cs)
	# Dial, hour hand fixed on the 3, minute hand on a pivot.
	_box(clock, Vector3(0.36, 0.36, 0.02), Vector3(0.0, 0.6, -0.15), mat_cream, false)
	_box(clock, Vector3(0.12, 0.02, 0.01), Vector3(-0.06, 0.6, -0.165), mat_dark, false)
	var minute_pivot := Node3D.new()
	minute_pivot.position = Vector3(0.0, 0.6, -0.17)
	clock.add_child(minute_pivot)
	_box(minute_pivot, Vector3(0.015, 0.15, 0.01), Vector3(0.0, 0.075, 0.0), mat_dark, false)
	# Pendulum swinging in front of the lower case.
	var pendulum_pivot := Node3D.new()
	pendulum_pivot.position = Vector3(0.0, 0.3, -0.16)
	clock.add_child(pendulum_pivot)
	_box(pendulum_pivot, Vector3(0.015, 0.7, 0.01), Vector3(0.0, -0.35, 0.0), mat_brass, false)
	var bob := CylinderMesh.new()
	bob.top_radius = 0.07
	bob.bottom_radius = 0.07
	bob.height = 0.02
	_add_mesh(pendulum_pivot, bob, Vector3(0.0, -0.72, 0.0), mat_brass, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	clock.call("setup", clock_model, minute_pivot, pendulum_pivot)

func _build_tampo() -> void:
	# The bench top the model stands on. Its walls are the glass of the dome:
	# same collision as the old atelier walls, but the workshop shows through.
	var west := Node3D.new()
	west.name = "WestTampo"
	add_child(west)
	_floor(west, -3.2, 0.0, 0.0, 9.1, mat_wood)
	_wall_x(west, -3.2, 0.0, 9.1, 0.0, WALL_H, mat_glass)
	_wall_z(west, 0.0, -3.2, 0.0, 0.0, WALL_H, mat_glass)
	_wall_z(west, 9.1, -3.2, 0.0, 0.0, WALL_H, mat_glass)
	_omni(west, Vector3(-1.6, 2.2, 4.0), Color(1.0, 0.72, 0.45), 0.5, 5.0, false)

	var tampo := Node3D.new()
	tampo.name = "Tampo"
	add_child(tampo)
	_floor(tampo, 0.0, 9.1, 15.4, 12.5, mat_wood)
	_wall_x(tampo, 0.0, 9.1, 12.5, 0.0, WALL_H, mat_glass)
	var cracked := _breakable(tampo, "CrackedGlass", &"vidro", Vector3(WALL_T, WALL_H, CRACKED_Z.y - CRACKED_Z.x), Vector3(15.4, WALL_H * 0.5, (CRACKED_Z.x + CRACKED_Z.y) * 0.5), mat_glass)
	var cracks := Node3D.new()
	cracks.name = "Cracks"
	tampo.add_child(cracks)
	var hit_at := Vector3(15.32, 1.2, 10.4)
	for a in [0.3, 1.1, 1.9, 2.6, 3.5, 4.4, 5.3]:
		var ln := 0.4 + fmod(a * 7.3, 0.9)
		_box(cracks, Vector3(0.005, ln, 0.012), hit_at + Vector3(0.0, cos(a) * ln * 0.5, sin(a) * ln * 0.5), mat_dark, false, Vector3(-a, 0.0, 0.0))
	cracked.shattered.connect(func() -> void: cracks.visible = false)
	_chalk(tampo, Vector3(0.6, 0.01, 0.05), Vector3(14.4, 0.006, 10.8))
	_chalk(tampo, Vector3(0.25, 0.01, 0.05), Vector3(14.62, 0.006, 10.72), Vector3(0.0, 0.7, 0.0))
	_chalk(tampo, Vector3(0.25, 0.01, 0.05), Vector3(14.62, 0.006, 10.88), Vector3(0.0, -0.7, 0.0))
	_wall_z(tampo, 12.5, 0.0, 15.4, 0.0, WALL_H, mat_glass)

	# Giant tools left on the bench: a gear lying flat and a pencil.
	var gear := CylinderMesh.new()
	gear.top_radius = 1.2
	gear.bottom_radius = 1.2
	gear.height = 0.3
	_add_mesh(tampo, gear, Vector3(11.0, 0.15, 11.0), mat_brass)
	_box(tampo, Vector3(0.25, 0.25, 4.0), Vector3(6.5, 0.12, 11.6), mat_wood_dark, false, Vector3(0.0, deg_to_rad(90.0), 0.0))
	_omni(tampo, Vector3(3.2, 2.3, 11.0), Color(1.0, 0.72, 0.45), 0.7, 4.5, false)

	# The dome: visual glass only, over the whole model.
	var redoma := Node3D.new()
	redoma.name = "Redoma"
	add_child(redoma)
	var x0 := -3.4
	var x1 := 15.6
	var z0 := -1.6
	var z1 := 12.7
	var top := 13.2
	_box(redoma, Vector3(x1 - x0, 0.03, z1 - z0), Vector3((x0 + x1) * 0.5, top, (z0 + z1) * 0.5), mat_glass, false)
	_box(redoma, Vector3(0.03, top, z1 - z0), Vector3(x0, top * 0.5, (z0 + z1) * 0.5), mat_glass, false)
	_box(redoma, Vector3(0.03, top, CRACKED_Z.x - z0), Vector3(x1, top * 0.5, (z0 + CRACKED_Z.x) * 0.5), mat_glass, true)
	_box(redoma, Vector3(0.03, top, z1 - CRACKED_Z.y), Vector3(x1, top * 0.5, (CRACKED_Z.y + z1) * 0.5), mat_glass, true)
	_box(redoma, Vector3(0.03, top - WALL_H, CRACKED_Z.y - CRACKED_Z.x), Vector3(x1, (top + WALL_H) * 0.5, (CRACKED_Z.x + CRACKED_Z.y) * 0.5), mat_glass, false)
	_box(redoma, Vector3(x1 - x0, top, 0.03), Vector3((x0 + x1) * 0.5, top * 0.5, z0), mat_glass, false)
	_box(redoma, Vector3(x1 - x0, top, 0.03), Vector3((x0 + x1) * 0.5, top * 0.5, z1), mat_glass, false)

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
		if body == player:
			exit_edge_reached.emit())
	add_child(edge)

func _build_oficina() -> void:
	# Inácio's real workshop at GIANT scale. Nothing here collides: it is only
	# ever seen through the dome and the windows.
	var oficina := Node3D.new()
	oficina.name = "Oficina"
	add_child(oficina)
	var bench_y := -0.8 * GIANT
	# Bench top around the model, its front edge and the floor far below.
	_slab_with_holes(oficina, -34.0, -40.0, 46.0, 13.5, -0.52, -0.12, [AreaGaveta.HOLE, AreaLeste.GROOVE], mat_wood_dark)
	_box(oficina, Vector3(80.0, 9.6, 0.4), Vector3(6.0, -4.8, 13.5), mat_wood_dark, false)
	_box(oficina, Vector3(90.0, 0.4, 40.0), Vector3(6.0, bench_y - 0.2, 33.5), mat_floor_corridor, false)
	# Back wall to the north, with a rain window at 12x.
	_box(oficina, Vector3(90.0, 40.0, 0.5), Vector3(6.0, 10.0, -40.0), mat_wall_exterior, false)
	var win_c := Vector3(6.0, 12.0, -39.7)
	_box(oficina, Vector3(2.8 * GIANT, 1.5 * GIANT, 0.2), win_c, mat_window, false)
	_box(oficina, Vector3(3.0 * GIANT, 0.08 * GIANT, 0.6), win_c + Vector3(0.0, 0.75 * GIANT, 0.2), mat_wood, false)
	_box(oficina, Vector3(3.0 * GIANT, 0.08 * GIANT, 0.6), win_c + Vector3(0.0, -0.75 * GIANT, 0.2), mat_wood, false)
	_box(oficina, Vector3(0.08 * GIANT, 1.5 * GIANT, 0.6), win_c + Vector3(-1.4 * GIANT, 0.0, 0.2), mat_wood, false)
	_box(oficina, Vector3(0.08 * GIANT, 1.5 * GIANT, 0.6), win_c + Vector3(1.4 * GIANT, 0.0, 0.2), mat_wood, false)
	for i in range(14):
		var x := win_c.x - 1.3 * GIANT + i * 0.2 * GIANT
		_box(oficina, Vector3(0.012 * GIANT, 1.2 * GIANT, 0.1), Vector3(x, win_c.y, win_c.z + 0.2), mat_rain, false, Vector3(0.0, 0.0, deg_to_rad(-8.0)))
	_omni(oficina, Vector3(6.0, 10.0, -36.0), Color(0.45, 0.6, 0.8), 1.2, 30.0, false)
	# The giant desk lamp leaning over the bench.
	var shade := CylinderMesh.new()
	shade.top_radius = 0.07 * GIANT
	shade.bottom_radius = 0.28 * GIANT
	shade.height = 0.22 * GIANT
	_add_mesh(oficina, shade, Vector3(6.0, 19.2, 16.0), mat_cream)
	_omni(oficina, Vector3(6.0, 18.0, 16.0), Color(1.0, 0.74, 0.45), 1.6, 45.0, false)

## The pieces of the truth: the two Inácio figures wear the same pocket watch;
## the cataloger figure has none, only a notebook and a letter on its lap.
## Under the cabana cushion, a page that only shows after 03:33.
func _build_story_props() -> void:
	var watch := CylinderMesh.new()
	watch.top_radius = 0.05
	watch.bottom_radius = 0.05
	watch.height = 0.018
	for pair in [["PocketWatchA", 11.15], ["PocketWatchB", 11.85]]:
		var w := _add_mesh(self, watch, Vector3(pair[1], 1.0, 8.2), mat_brass, Vector3(deg_to_rad(90.0), 0.0, 0.0))
		w.name = pair[0]
	var book := _box(self, Vector3(0.2, 0.035, 0.26), Vector3(12.55, 0.6, 8.13), mat_cream, false)
	book.name = "CatalogerNotebook"
	var letter := _box(self, Vector3(0.16, 0.006, 0.21), Vector3(12.58, 0.623, 8.11), mat_cream, false, Vector3(0.0, deg_to_rad(14.0), 0.0))
	letter.name = "CatalogerLetter"
	var page := _box(self, Vector3(0.22, 0.004, 0.29), Vector3(1.5, 0.13, 3.5), mat_cream, false, Vector3(0.0, deg_to_rad(-18.0), 0.0))
	page.name = "CabanaPage"
	page.visible = false

## After 03:33: the loose page shows under the cabana cushion, catalogable.
func reveal_cabana_page() -> void:
	var page := get_node_or_null("CabanaPage") as Node3D
	if page == null or page.visible:
		return
	page.visible = true
	_catalog_target(self, &"pagina_cabana", page.position + Vector3(0.0, 0.05, 0.0), Vector3(0.5, 0.2, 0.5))

func _build_giant_elias() -> void:
	var giant := Mannequin.new()
	giant.name = "GiantElias"
	add_child(giant)
	giant.build(ELIAS_STYLE, GIANT)
	giant.set_pose(&"sentado")
	giant.position = GIANT_SEAT
	giant.set_lean(deg_to_rad(22.0))
	giant.reach(1.0, GIANT_HAND)
	giant.visible = false

func _catalog_target(parent: Node3D, item: StringName, pos: Vector3, size: Vector3) -> Area3D:
	var area: Area3D = CatalogTarget.new()
	area.name = "Catalog_" + String(item)
	area.item_id = item
	area.position = pos
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	area.add_child(cs)
	parent.add_child(area)
	return area

func _build_catalog_targets() -> void:
	_catalog_target(self, &"relogio_entrada", Vector3(3.1, 1.2, 8.8), Vector3(0.55, 1.6, 0.4))
	_catalog_target(get_node("Ball"), &"bola", Vector3.ZERO, Vector3(0.4, 0.4, 0.4))
	_catalog_target(self, &"caixa_musica", Vector3(3.35, 0.7, 4.45), Vector3(0.45, 0.3, 0.35))
	_catalog_target(self, &"desenho", Vector3(6.7, 1.6, 0.1), Vector3(0.8, 0.6, 0.15))
	_catalog_target(self, &"casinha", Vector3(7.5, 0.3, 1.0), Vector3(1.0, 0.8, 0.8))
	_catalog_target(self, &"cabana", Vector3(1.0, 0.4, 3.5), Vector3(1.4, 0.8, 1.6))
	_catalog_target(self, &"cama", Vector3(13.2, 0.5, 3.0), Vector3(2.2, 0.6, 3.1))
	_catalog_target(self, &"espelho", Vector3(15.25, 1.35, 2.0), Vector3(0.15, 1.6, 1.0))
	_catalog_target(get_node("Doll"), &"boneco", Vector3(0.0, 0.3, 0.0), Vector3(0.55, 1.0, 0.35))
	_catalog_target(self, &"vela", Vector3(11.85, 0.6, 7.7), Vector3(0.25, 0.3, 0.25))
	_catalog_target(self, &"casaco", Vector3(0.2, 1.2, 7.6), Vector3(0.25, 0.9, 0.5))
	_catalog_target(self, &"figura_inacio_a", Vector3(11.15, 0.7, 8.35), Vector3(0.45, 1.3, 0.45))
	_catalog_target(self, &"figura_inacio_b", Vector3(11.85, 0.7, 8.35), Vector3(0.45, 1.3, 0.45))
	_catalog_target(self, &"figura_catalogador", Vector3(12.55, 0.7, 8.35), Vector3(0.45, 1.3, 0.45))

func _wire_catalog() -> void:
	_build_catalog_targets()
	get_node("F1").toggled.connect(func(at_b: bool) -> void:
		catalog.set_flag(&"f1_folded", at_b))
	get_node("Doll").toggled.connect(func(lying: bool) -> void:
		catalog.set_flag(&"doll_sat", not lying))
	player.catalog_requested.connect(_on_catalog_requested)
	player.acted.connect(func(verb: StringName, _collider: Node) -> void:
		recorder.mark_action(verb))
	get_node("EntryClock").wound.connect(func(_amount: float) -> void:
		if visit.on_wind() == &"hora_ended":
			hora_ended.emit())
	cataloged.connect(func(entry: Dictionary) -> void:
		visit.on_cataloged(entry.item))
	hora_started.connect(func() -> void: print("03:33"))

func _wire_sound() -> void:
	get_node("EntryClock").sfx = sfx
	for node in get_children():
		if not node.has_signal("toggled"):
			continue
		if String(node.name).begins_with("Door"):
			_wire_door_sound(node)
		else:
			node.toggled.connect(func(_state: bool) -> void:
				sfx.play_at(&"fold", node.global_position))
	player.stepped.connect(func() -> void:
		var kind := &"step_metal" if _floor_group(&"Metal") else &"step"
		sfx.play_at(kind, player.global_position, &"Mundo", -4.0 if player.sprinting else -8.0))
	player.landed.connect(func(impact: float) -> void:
		sfx.play_at(&"land", player.global_position, &"Mundo", lerpf(-12.0, -2.0, clampf((impact - 3.0) / 5.0, 0.0, 1.0))))
	player.climbed.connect(func() -> void:
		sfx.play_at(&"rung", player.global_position + Vector3(0.0, 1.0, 0.0), &"Mundo", -8.0))
	# Mundo: rain behind the bedroom window and the giant workshop window,
	# and the player's own breath, low and always there.
	_loop_3d(&"rain", Vector3(12.5, 1.65, -0.4), -10.0)
	_loop_3d(&"rain", Vector3(7.0, 6.0, -14.0), -6.0)
	var breath := AudioStreamPlayer.new()
	breath.name = "Breath"
	breath.stream = sfx.stream(&"breath")
	breath.bus = &"Mundo"
	breath.volume_db = -24.0
	breath.autoplay = not sfx.silent
	add_child(breath)
	sfx.register_loop(breath)

## Doors groan when they move; closing, they shut on the frame.
func _wire_door_sound(door: Node) -> void:
	var hinge: Vector3 = door.global_position + Vector3(0.0, 1.2, 0.0)
	door.moving.connect(func(to_open: bool) -> void:
		sfx.play_at(&"door", hinge, &"Casa", -3.0 if to_open else -6.0))
	door.toggled.connect(func(open: bool) -> void:
		if not open:
			sfx.play_at(&"slam", hinge, &"Casa", -4.0))

## Whether the floor under Elias belongs to a group (metal grating, glass).
func _floor_group(group: StringName) -> bool:
	var from: Vector3 = player.global_position + Vector3(0.0, 0.3, 0.0)
	var q := PhysicsRayQueryParameters3D.create(from, from + Vector3(0.0, -0.8, 0.0), 1, [player.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return false
	var n: Node = hit.collider
	return n.is_in_group(group) or (n.get_parent() != null and n.get_parent().is_in_group(group))

## The one way out (A-007): silence the loops, let the frame finish, then quit.
func shutdown() -> void:
	if _shutting_down:
		return
	_shutting_down = true
	sfx.stop_all()
	await get_tree().process_frame
	get_tree().quit()

## The window's close button also comes through here, so the loops stop first.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown()

func _loop_3d(kind: StringName, pos: Vector3, volume_db: float) -> void:
	var p := AudioStreamPlayer3D.new()
	p.stream = sfx.stream(kind)
	p.bus = &"Mundo"
	p.volume_db = volume_db
	p.unit_size = 6.0
	p.position = pos
	p.autoplay = not sfx.silent
	add_child(p)
	sfx.register_loop(p)

func _wire_mirror() -> void:
	house_mirror = HouseMirror.new()
	house_mirror.name = "HouseMirror"
	house_mirror.main = self
	add_child(house_mirror)
	var reflection := MirrorReflection.new()
	reflection.name = "MirrorReflection"
	reflection.main = self
	reflection.style = ELIAS_STYLE
	add_child(reflection)
	player.camera.cull_mask &= ~(1 << (MirrorReflection.REFLECTION_LAYER - 1))
	reflection._camera.cull_mask &= ~(1 << (Hands.HANDS_LAYER - 1))
	player.swung.connect(func() -> void:
		sfx.play_at(&"swish", player.camera.global_position, &"Mundo", -10.0))
	player.acted.connect(func(verb: StringName, collider: Node) -> void:
		if verb == &"bater":
			_knock_on(collider, player.ray.get_collision_point())
		if verb in MIRRORED_VERBS:
			brain.register(verb))

## The stick on something: a breakable cracks or gives, anything else knocks.
func _knock_on(collider: Node, point: Vector3) -> void:
	var kind := &"knock"
	if collider != null and collider.is_in_group(&"Gasto"):
		if gastos.struck(collider):
			kind = &"shatter"
	elif collider != null and collider.is_in_group(&"Breakable"):
		var result: StringName = collider.hit()
		if result != &"":
			kind = Breakable.sound_for(collider.kind, result == &"break")
	sfx.play_at(kind, point)
	knock_sounded.emit(kind)

func _wire_story() -> void:
	gastos = Gastos.new()
	gastos.main = self
	add_child(gastos)
	gastos.caught.connect(func(i: int) -> void: hug(gastos.head_of(i)))
	pretend = Pretend.new()
	pretend.main = self
	add_child(pretend)
	score = Score.new()
	score.name = "Score"
	score.main = self
	add_child(score)
	notebook.quest = quest
	notebook.atlas = atlas
	player.map_requested.connect(func() -> void: notebook.toggle_plan(player.global_position))
	for p in get_tree().get_nodes_in_group(&"Piece"):
		p.taken.connect(_on_piece)
	for n in BREAK_TASKS:
		var b := find_child(n, true, false)
		if b != null:
			b.shattered.connect(_complete.bind(BREAK_TASKS[n]))
	cataloged.connect(func(entry: Dictionary) -> void:
		if CATALOG_TASKS.has(entry.item):
			_complete(CATALOG_TASKS[entry.item]))
	hora_started.connect(_complete.bind(&"hora"))
	hora_ended.connect(_complete.bind(&"corda"))
	settings_ui = SettingsUI.new()
	settings_ui.main = self
	var args := OS.get_cmdline_user_args()
	for arg in args:
		if arg in ["--selftest", "--tour"] or arg.begins_with("--shot"):
			settings_ui.path = ""
	add_child(settings_ui)

## A piece of the pocket watch in Elias's hand: written down, the lot struck.
func _on_piece(id: StringName) -> void:
	var entry: Dictionary = catalog.note(id)
	sfx.play_at(&"tink", player.camera.global_position, &"Mundo", -8.0)
	if not entry.is_empty():
		cataloged.emit(entry)
	_complete(id)

func _complete(id: StringName) -> void:
	var r: StringName = quest.complete(id)
	if r == &"phase":
		var title: String = quest.PHASES[quest.phase].title
		var tw := create_tween()
		tw.tween_interval(3.6)
		tw.tween_callback(func() -> void: notebook.peek_text("Lote " + title))
		if dread != null:
			dread.scare(0.08)
	if id == &"voltar":
		visit.on_pieces_ready()

## Which room and floor Elias is in: the plan fills in, lots get struck,
## the safe point follows him and so do the Gastos.
func _track_place() -> void:
	var pos := player.global_position
	var room: StringName = atlas.visit(pos)
	if ROOM_TASKS.has(room):
		_complete(ROOM_TASKS[room])
	var lvl: StringName = atlas.level_of(atlas.room_at(pos))
	if lvl == &"" or lvl == level:
		return
	level = lvl
	player.respawn_point = LEVEL_SAFE.get(lvl, SPAWN)
	gastos.on_level(lvl)
	if lvl == &"casa" and quest.all_pieces():
		_complete(&"voltar")

## A Gasto reached Elias unseen. No death: black, cold, porcelain at the ear;
## he wakes lying where the floor begins, and the double writes it down.
func hug(at: Vector3) -> void:
	if _hugging or ended:
		return
	_hugging = true
	var where := Atlas.where(atlas.room_at(at))
	player.input_locked = true
	player.velocity = Vector3.ZERO
	sfx.play_at(&"shatter", player.camera.global_position, &"Mundo", -2.0)
	sfx.play_at(&"porcelain", player.camera.global_position + player.camera.global_basis.x * 0.3, &"Mundo", -4.0)
	var tw := create_tween()
	tw.tween_property(_black, "color:a", 1.0, 0.18)
	tw.tween_interval(1.1)
	tw.tween_callback(func() -> void:
		player.global_position = player.respawn_point
		player.velocity = Vector3.ZERO
		player.camera.rotation.z = deg_to_rad(80.0)
		gastos.scatter()
		var lines: Array[String] = ["catalogador, segurado %s. Frio." % where]
		catalog.add_double_entries(lines)
		notebook.refresh(catalog)
		notebook.peek(catalog.entries[-1])
		if dread != null:
			dread.scare(0.25))
	tw.tween_property(_black, "color:a", 0.0, 0.8)
	tw.parallel().tween_property(player.camera, "rotation:z", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func() -> void:
		player.input_locked = notebook.is_open()
		_hugging = false)

## What the music needs to know about the moment (score.gd asks each frame).
func score_inputs() -> Dictionary:
	var running: float = 1.0 if player.sprinting else player.strain() * 0.6
	return {
		"depth": Score.DEPTH.get(level, 0.0),
		"threat": gastos.threat() if gastos != null else 0.0,
		"pretending": player.pretending,
		"running": running,
		"hora": ended or (hour_event != null and hour_event.is_active()),
	}

func _wire_hour() -> void:
	var echoes := Node3D.new()
	echoes.name = "Echoes"
	add_child(echoes)
	hour_event = HourEvent.new()
	hour_event.name = "HourEvent"
	hour_event.main = self
	add_child(hour_event)
	hora_started.connect(hour_event.begin)
	hora_ended.connect(hour_event.end)
	hour_event.ended.connect(func() -> void:
		get_node("GiantElias").visible = true)

func _wire_dread() -> void:
	dread = Dread.new()
	dread.name = "Dread"
	dread.main = self
	add_child(dread)

func _wire_ending() -> void:
	ending = Ending.new()
	ending.name = "Ending"
	ending.main = self
	add_child(ending)
	ending.final_camera.cull_mask &= ~(1 << (Hands.HANDS_LAYER - 1))
	exit_edge_reached.connect(func() -> void:
		var outcome: StringName = visit.on_exit()
		if outcome == &"":
			return
		ended = true
		ending_outcome = outcome
		ending.finish(outcome))

## Debug only: F9 lets the clock run out now, to reach 03:33 without waiting.
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F9:
		visit.clock.can_stop = true
		visit.clock.spring = 0.0

func _update_mirror(delta: float) -> void:
	_move_cool = maxf(0.0, _move_cool - delta)
	if _move_cool <= 0.0 and Vector2(player.velocity.x, player.velocity.z).length() > 0.3:
		_move_cool = 1.0
		brain.register(&"mover")
	var r: Dictionary = brain.update(delta)
	if not r.is_empty():
		house_mirror.respond(r)

## In the player's view and not hidden behind anything solid.
func is_seen(point: Vector3) -> bool:
	var cam: Camera3D = player.camera
	if not cam.is_position_in_frustum(point):
		return false
	var q := PhysicsRayQueryParameters3D.create(cam.global_position, point, 1, [player.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return hit.is_empty() or hit.position.distance_to(point) < 0.35

func in_bedroom(pos: Vector3) -> bool:
	return pos.x >= BEDROOM_X.x and pos.x <= BEDROOM_X.y and pos.z >= BEDROOM_Z.x and pos.z <= BEDROOM_Z.y

func _on_catalog_requested(target: Area3D) -> void:
	var entry: Dictionary = catalog.catalog(target.item_id)
	if entry.is_empty():
		return
	player.examine()
	sfx.play_pencil_pattern(target.global_position)
	recorder.mark_action(&"catalogar")
	cataloged.emit(entry)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(preload("res://scripts/player.gd"))
	player.position = SPAWN
	player.rotation.y = 0.0
	player.set("respawn_point", SPAWN)

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
	ray.collision_mask = 1 | Gastos.HIT_LAYER
	ray.enabled = true
	camera.add_child(ray)

	var catalog_ray := RayCast3D.new()
	catalog_ray.name = "CatalogRay"
	catalog_ray.target_position = Vector3(0.0, 0.0, -2.5)
	catalog_ray.collision_mask = 2
	catalog_ray.collide_with_areas = true
	catalog_ray.collide_with_bodies = false
	catalog_ray.enabled = true
	camera.add_child(catalog_ray)

	var flashlight := SpotLight3D.new()
	flashlight.name = "SpotLight3D"
	flashlight.position = Vector3(0.12, -0.08, 0.0)
	flashlight.light_color = Color(1.0, 0.93, 0.8)
	flashlight.light_energy = 1.3
	flashlight.spot_range = 10.0
	flashlight.spot_angle = 32.0
	flashlight.shadow_enabled = false
	camera.add_child(flashlight)

	var hands := Hands.new()
	hands.name = "Hands"
	player.add_child(hands)

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

	_black = ColorRect.new()
	_black.color = Color(0.0, 0.0, 0.0, 0.0)
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_black)

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
	prompt_label.offset_top = -96.0
	prompt_label.offset_bottom = -42.0
	prompt_label.add_theme_font_size_override("font_size", 18)
	prompt_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.8))
	prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	prompt_label.add_theme_constant_override("shadow_offset_x", 2)
	prompt_label.add_theme_constant_override("shadow_offset_y", 2)
	root.add_child(prompt_label)

	help_label = Label.new()
	help_label.text = "Janghyang — blockout\nWASD mover · mouse olhar · E interagir · Q catalogar · Tab caderno · M plano · C agachar · Shift correr · Espaço pular · V (segurar) fazer de conta · B bater (vareta) · F lanterna · R reiniciar · Esc opções\nDobras: F1 parede oeste · F2/F4 painéis do corredor · F3 porta deitada\nA porta da rua está aberta. Sair é uma escolha."
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

	notebook = preload("res://scripts/notebook_ui.gd").new()
	notebook.name = "Notebook"
	notebook.player = player
	add_child(notebook)
	notebook.refresh(catalog)
	player.notebook_requested.connect(notebook.toggle)
	cataloged.connect(func(entry: Dictionary) -> void:
		notebook.refresh(catalog)
		notebook.peek(entry))

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
	_label("TAMPO", Vector3(12.2, 2.45, 10.9), cream, 28)

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
		"dread":
			# The corridor near 03:33: the same view as "corridor", afraid.
			autonomous = false
			dread.set_tension(0.9)
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
		"notebook":
			player.position = Vector3(2.6, 0.2, 7.5)
			for id in [&"relogio_entrada", &"bola", &"caixa_musica"]:
				cataloged.emit(catalog.catalog(id))
			notebook.open()
		"mirror":
			player.position = Vector3(13.3, 0.2, 2.3)
			player.rotation.y = deg_to_rad(-75.0)
			camera.rotation.x = deg_to_rad(-4.0)
		"hour":
			# A walk across the playroom and a pause, then 03:33 frozen in place.
			for i in 300:
				var t := i / 300.0
				recorder.update(0.1, Vector3(2.4, 0.2, 6.2).lerp(Vector3(6.2, 0.2, 2.8), t), deg_to_rad(-135.0), 0.0, i > 200)
			for i in 200:
				recorder.update(0.1, Vector3(6.2, 0.2, 2.8), deg_to_rad(90.0), -0.3, i < 100)
			hour_event.begin()
			hour_event.end()
			player.position = Vector3(7.4, 0.2, 6.4)
			player.rotation.y = deg_to_rad(40.0)
			camera.rotation.x = deg_to_rad(-10.0)
		"double":
			hour_event.begin()
			get_node("Doll").become_double(hour_event.DOUBLE_SEAT)
			hour_event.end()
			player.position = Vector3(2.4, 0.2, 7.4)
			player.rotation.y = deg_to_rad(120.0)
			camera.rotation.x = deg_to_rad(-18.0)
		"giant":
			hour_event.begin()
			hour_event.end()
			player.position = Vector3(1.8, 0.2, 9.6)
			player.rotation.y = PI
			camera.rotation.x = deg_to_rad(14.0)
		"ending":
			hour_event.begin()
			hour_event.end()
			# The image behind the black, without the fade or the last entry.
			ending._behind_black(&"corda")
		"clock":
			player.position = Vector3(2.6, 0.2, 7.5)
			player.rotation.y = deg_to_rad(160.0)
			camera.rotation.x = deg_to_rad(-12.0)
		"leste":
			# Out on the bench: the ruler over the crack and the shop beyond.
			player.position = Vector3(24.5, 0.2, 7.8)
			player.rotation.y = 0.0
			camera.rotation.x = deg_to_rad(-4.0)
		"shop":
			player.position = Vector3(23.2, 0.2, -2.7)
			player.rotation.y = deg_to_rad(-25.0)
			camera.rotation.x = deg_to_rad(4.0)
		"dome":
			player.position = Vector3(21.0, 0.2, 9.0)
			player.rotation.y = deg_to_rad(80.0)
			camera.rotation.x = deg_to_rad(10.0)
		"plano":
			player.position = Vector3(2.6, 0.2, 7.5)
			for p in [SPAWN, Vector3(4.0, 0.2, 3.0), Vector3(9.4, 0.2, 3.0), Vector3(12.0, 0.2, 2.0), Vector3(4.0, 0.2, -0.6), Vector3(6.0, 3.2, 3.0)]:
				atlas.visit(p)
			for id in [&"achar_passagem", &"coroa", &"subir_sotao"]:
				quest.complete(id)
			notebook.open_plan(Vector3(6.0, 3.2, 3.0))
		"opcoes":
			player.position = Vector3(4.0, 0.2, 3.5)
			player.rotation.y = deg_to_rad(20.0)
			settings_ui.open()
		"gasto":
			gastos.set_process(false)
			player.position = LEVEL_SAFE[&"gaveta"]
			player.rotation.y = deg_to_rad(90.0)
			camera.rotation.x = deg_to_rad(2.0)
			player.flashlight.visible = true
			get_tree().create_timer(0.5).timeout.connect(func() -> void:
				_track_place()
				var body: Node3D = gastos._bodies[0]
				body.global_position = player.position + Vector3(-2.3, 0.0, 0.25)
				body.visible = true
				gastos._face(0, player.position))
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
	shutdown()
