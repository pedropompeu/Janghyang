extends Node3D
## A human figure, meshes only: no collision, nothing to bump into. Used for
## Elias in the mirror, his echoes, the double, the new figure, the gastos and
## each chapter's scene. Faces -Z like the player, so a recorded yaw can be
## applied as-is.
##
## With its model in assets/models/, the body is a sculpted porcelain figure on
## a skeleton: the pivots the callers move (hips, legs, torso, arms, head) sit
## on its joints and drive the bones (_sync). Without the model, the same
## pivots carry boxes (spec §14.2: a missing asset falls back to the block).

const AssetLoader = preload("res://scripts/asset_loader.gd")

## Body -> its file name in assets/models/ (.glb) and assets/textures/ (.png).
const BODIES := {&"adulto": "figura_adulto", &"menino": "figura_menino", &"gasto": "gasto"}
const MODEL_PATH := "res://assets/models/%s.glb"
const TEXTURE_PATH := "res://assets/textures/%s.png"
## The parts a style does not name, and how much each surface shines.
const DEFAULT_COLORS := {&"shoes": Color("#1f1b18"), &"eyes": Color("#e8e2d4"), &"iris": Color("#2e2620")}
const ROUGHNESS := {&"skin": 0.35, &"coat": 0.6, &"trousers": 0.6, &"shoes": 0.45, &"hair": 0.5, &"eyes": 0.2, &"iris": 0.2}
## Side (-1 left, +1 right) -> the suffix of its bones.
const SIDES := {-1.0: "L", 1.0: "R"}
## How far out the arms hang at rest (degrees, z).
const ARM_SPLAY := 4.0
## Hip joint heights for the poses (figure space, before scale).
const SEAT_Y := 0.45
const FLOOR_Y := 0.13
## Walking: the ground one cycle (two steps) covers, for a body at scale 1; the
## pace that makes a full stride; how far the thighs swing at full stride and
## how much of that the arms take (radians); faster than this is a jump, not a
## step (an echo's loop starting over).
const STRIDE_CYCLE := 1.4
const STRIDE_PACE := 2.2
const STRIDE_SWING := 0.42
const ARM_SWING := 0.55
const JUMP_PACE := 8.0

var _hips: Node3D
var _head: Node3D
var _legs: Array[Node3D] = []
var _torso: Node3D
var _arms := {}
var _mats := {}
var _layers := 1
var _seat: Node3D
var _pose := &"em_pe"
## The walk: where along its cycle (radians), how wide (0..1), and whether the
## last stride drawn left the body off its rest.
var _stride_phase := 0.0
var _stride := 0.0
var _striding := false

# The skinned figure, when its model loaded.
var _skel: Skeleton3D
var _knees: Array[Node3D] = []
var _feet: Array[Node3D] = []
## The skeleton's transform in this node's space, and its inverse.
var _ts := Transform3D.IDENTITY
var _ts_inv := Transform3D.IDENTITY
## Pivots that drive a bone, with their rest transforms (inverted) in this
## node's space, and the transforms they had at the last sync.
var _drivers: Array[Node3D] = []
var _rest_inv: Array[Transform3D] = []
var _last: Array[Transform3D] = []
## Bone index -> index in _drivers.
var _driven := {}
## Every bone, parents first, with its global rest.
var _order: Array[int] = []
var _global_rest := {}
var _hip_rest := Vector3.ZERO
## Per leg (0 left, 1 right): lengths and rest angles in the swing plane.
var _leg_geo: Array[Dictionary] = []
## The porcelain materials, shared by every figure and kept for the whole run:
## "part|colour|file" -> material. Shared because Godot 4.7 errors on a live
## figure when another figure's surface override materials are freed over the
## same mesh (an echo going at dawn); kept, so none is ever freed mid-game.
static var _porcelain_cache := {}

func build(style: Dictionary, scale_factor := 1.0, body := &"adulto") -> void:
	for part in style:
		var m := StandardMaterial3D.new()
		m.albedo_color = style[part]
		m.roughness = 0.9
		_mats[part] = m
	scale = Vector3.ONE * scale_factor
	var file: String = BODIES.get(body, "")
	var model: Node3D = AssetLoader.instance(MODEL_PATH % file) if file != "" else null
	if model != null and not _build_model(model, style, file):
		model.free()
		model = null
	if model == null:
		_build_boxes()
	set_process(has_model())
	set_pose(&"em_pe")

func _ready() -> void:
	set_process(has_model())

## Godot 4.7: bones posed out of the tree mark the skeleton dirty without
## queueing its redraw, and it then ignores every later pose (a figure posed
## before add_child is drawn standing). Once the whole body is in, refresh it
## and pose the bones again.
func _notification(what: int) -> void:
	if what == NOTIFICATION_POST_ENTER_TREE and _skel != null:
		_skel.force_update_all_bone_transforms()
		_last.clear()
		_sync()

func _process(_delta: float) -> void:
	if is_visible_in_tree():
		_sync()

## Whether the body is the sculpted figure (false: boxes).
func has_model() -> bool:
	return _skel != null

func set_pose(pose: StringName) -> void:
	if _hips == null:
		return
	_pose = pose
	if pose != &"em_pe":
		_stride = 0.0
	if has_model():
		_pose_model(pose)
		_apply_stride()
		_sync()
		return
	var hip_y := 0.85
	var leg_angle := 0.0
	var lean := 0.0
	match pose:
		&"agachado":
			hip_y = 0.45
			leg_angle = deg_to_rad(58.0)
			lean = deg_to_rad(-18.0)
		&"sentado":
			hip_y = 0.45
			leg_angle = deg_to_rad(84.0)
		&"no_chao":
			hip_y = 0.1
			leg_angle = deg_to_rad(86.0)
	_hips.position.y = hip_y
	_torso.rotation.x = lean
	for leg in _legs:
		leg.rotation.x = leg_angle
	_apply_stride()

## Walks the body over `moved` metres of ground in `delta` seconds: the legs
## and arms swing in step, a stride as wide as the pace allows (STRIDE_PACE and
## up is a full one), easing in and out. Only a standing body walks; a jump
## faster than JUMP_PACE is no step. The bones follow on the next frame.
func walk(moved: float, delta: float) -> void:
	if delta <= 0.0:
		return
	var pace := moved / delta
	if pace > JUMP_PACE:
		moved = 0.0
		pace = 0.0
	var wide := clampf(pace / STRIDE_PACE, 0.0, 1.0) if _pose == &"em_pe" else 0.0
	_stride = move_toward(_stride, wide, delta * 4.0)
	_stride_phase = fposmod(_stride_phase + moved / (STRIDE_CYCLE * scale.x) * TAU, TAU)
	_apply_stride()

## Holds the body mid-step: `phase` along the cycle (radians; PI/2 is the left
## foot ahead), `amount` of a full stride. Standing only.
func set_stride(phase: float, amount: float) -> void:
	_stride_phase = fposmod(phase, TAU)
	_stride = clampf(amount, 0.0, 1.0) if _pose == &"em_pe" else 0.0
	_apply_stride()

## How wide the body is striding now (0 standing still, 1 a full stride).
func stride() -> float:
	return _stride

func set_look(yaw: float, pitch: float) -> void:
	rotation.y = yaw
	if _head != null:
		_head.rotation.x = clampf(pitch, -0.8, 0.8) * 0.7
	_sync()

## Leans the torso forward (radians), for a body bent over a bench.
func set_lean(angle: float) -> void:
	if _torso != null:
		_torso.rotation.x = -angle
	_sync()

## Points one arm (side -1 left, +1 right) at a point in the world. Plain
## math rather than look_at, so it works before the figure is in the tree.
func reach(side: float, target: Vector3) -> void:
	var arm: Node3D = _arms.get(side)
	if arm == null:
		return
	var world := global_transform if is_inside_tree() else transform
	var parent := world * _in_model(arm.get_parent())
	var dir := parent.affine_inverse() * target - arm.position
	var up := (parent.basis.inverse() * Vector3.UP).normalized()
	if dir.length_squared() < 1e-6 or absf(dir.normalized().dot(up)) > 0.999:
		return
	# The arm hangs along -Y; turn it so -Y takes the direction -Z was given.
	arm.basis = Basis.looking_at(dir, up) * Basis(Vector3.RIGHT, PI * 0.5)
	_sync()

## One arm's pivot (side -1 left, +1 right), for small gestures. A caller that
## turns it by hand gets the figure's arm along on the next frame (or at once
## with sync_pose).
func arm(side: float) -> Node3D:
	return _arms.get(side)

## Moves the bones to the pivots now, without waiting for the next frame.
func sync_pose() -> void:
	_sync()

## A bone's transform in this node's space (before its scale), as posed now.
## Identity for the box body or an unknown bone. Composed from the bone poses
## up the chain: Skeleton3D only refreshes its global poses inside the tree.
func bone_transform(bone: StringName) -> Transform3D:
	if _skel == null:
		return Transform3D.IDENTITY
	var b := _skel.find_bone(bone)
	if b < 0:
		return Transform3D.IDENTITY
	var t := Transform3D.IDENTITY
	while b >= 0:
		t = _skel.get_bone_pose(b) * t
		b = _skel.get_bone_parent(b)
	return _ts * t

func bone_position(bone: StringName) -> Vector3:
	return bone_transform(bone).origin

func set_render_layer(bit: int) -> void:
	_layers = 1 << (bit - 1)
	for mi in find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).layers = _layers

## A wooden stool under the hips, shown while `on`: the staged scenes sit
## their figures where the house has no chair. Meshes only, on the figure's
## layer; built the first time it is asked for.
func set_seat(on: bool) -> void:
	if _seat == null:
		if not on:
			return
		_seat = Node3D.new()
		_seat.name = "Seat"
		add_child(_seat)
		var wood := StandardMaterial3D.new()
		wood.albedo_color = Color("#5b4734")
		wood.roughness = 0.8
		_mats[&"seat"] = wood
		var top := SEAT_Y - 0.09
		_part(_seat, Vector3(0.38, 0.04, 0.34), Vector3(0.0, top - 0.02, 0.03), &"seat")
		for x in [-0.15, 0.15]:
			for z in [-0.11, 0.17]:
				_part(_seat, Vector3(0.035, top - 0.04, 0.035), Vector3(x, (top - 0.04) * 0.5, z), &"seat")
		for mi in _seat.get_children():
			(mi as MeshInstance3D).layers = _layers
	_seat.visible = on

## A notebook on the lap (the double writing, the new figure).
func add_notebook() -> void:
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color("#e9e1cc")
	paper.roughness = 0.95
	_mats[&"paper"] = paper
	# The sculpted thigh is rounder than the box: the lap sits higher.
	var lap := 0.1 if has_model() else 0.06
	var book := _part(_hips, Vector3(0.22, 0.025, 0.3), Vector3(0.0, lap, -0.3), &"paper")
	book.rotation.x = deg_to_rad(-10.0)
	book.layers = _layers

## Lays the stride over the standing pose: each thigh swings opposite the
## other, the knee of the leg coming forward bends, the arms swing against the
## legs, the hips dip as the legs spread (so the planted foot stays down) and
## the shoulders turn a little. A body that never strode is left as it is, so
## a reaching arm keeps its reach.
func _apply_stride() -> void:
	if _hips == null or _pose != &"em_pe":
		_striding = false
		return
	if _stride <= 0.0 and not _striding:
		return
	_striding = _stride > 0.0
	var a := _stride
	var swing := a * STRIDE_SWING
	# How far the lowest ankle hangs under the hip joints, standing and now:
	# the hips come down by the difference, so that foot stays on the floor.
	var rest_drop := 0.85
	var drop := 0.0
	var thighs := []
	for i in _legs.size():
		var side := -1.0 if i == 0 else 1.0
		var thigh := -side * swing * sin(_stride_phase)
		thighs.append(thigh)
		_legs[i].rotation.x = thigh
		if i < _knees.size():
			var knee := -a * (0.08 + 0.7 * maxf(0.0, -side * cos(_stride_phase)))
			_knees[i].rotation.x = knee
			# The leading foot comes down nearly flat, heel first; the one
			# behind pushes off, heel up and toes down.
			_feet[i].rotation.x = -(thigh + knee) * (0.6 if thigh + knee > 0.0 else 0.2)
			var g: Dictionary = _leg_geo[i]
			rest_drop = g.l1 * cos(g.a1) + g.l2 * cos(g.a2)
			drop = maxf(drop, g.l1 * cos(g.a1 + thigh) + g.l2 * cos(g.a2 + thigh + knee))
		else:
			drop = maxf(drop, rest_drop * cos(thigh))
	var hip_y: float = _hip_rest.y if has_model() else 0.85
	_hips.position.y = hip_y - (rest_drop - drop)
	_torso.rotation.y = 0.08 * a * sin(_stride_phase)
	for side in _arms:
		# Each arm swings with the leg of the other side.
		var arm: Node3D = _arms[side]
		arm.rotation = Vector3(thighs[0 if side > 0.0 else 1] * ARM_SWING, 0.0, deg_to_rad(side * ARM_SPLAY))

# --- The sculpted figure --------------------------------------------------

## Sets up the pivots on the model's joints and its porcelain materials.
## False if the model lacks a bone the pivots need.
func _build_model(model: Node3D, style: Dictionary, file: String) -> bool:
	var skels := model.find_children("*", "Skeleton3D", true, false)
	if skels.size() != 1:
		return false
	var skel: Skeleton3D = skels[0]
	var needed := ["hips", "spine", "head"]
	for s in SIDES.values():
		needed.append_array(["upper_arm." + s, "thigh." + s, "shin." + s, "foot." + s])
	for bone in needed:
		if skel.find_bone(bone) < 0:
			return false
	model.name = "Figura"
	add_child(model)
	_skel = skel
	_ts = _in_model(_skel)
	_ts_inv = _ts.affine_inverse()

	_hip_rest = _joint(&"hips")
	_hips = _pivot(self, _hip_rest)
	_torso = _pivot(_hips, _joint(&"spine"))
	_head = _pivot(_torso, _joint(&"head"))
	_drive(&"hips", _hips)
	_drive(&"spine", _torso)
	_drive(&"head", _head)
	for side in SIDES:
		var s: String = SIDES[side]
		var a := _pivot(_torso, _joint(StringName("upper_arm." + s)))
		a.rotation.z = deg_to_rad(side * ARM_SPLAY)
		_arms[side] = a
		_drive(StringName("upper_arm." + s), a)
		var hip := _joint(StringName("thigh." + s))
		var knee := _joint(StringName("shin." + s))
		var ankle := _joint(StringName("foot." + s))
		var leg := _pivot(_hips, hip)
		var shin := _pivot(leg, knee)
		var foot := _pivot(shin, ankle)
		_legs.append(leg)
		_knees.append(shin)
		_feet.append(foot)
		_drive(StringName("thigh." + s), leg)
		_drive(StringName("shin." + s), shin)
		_drive(StringName("foot." + s), foot)
		# The legs swing about x: only their y-z shadow counts. Angles from
		# straight down toward the front (-Z).
		var t := knee - hip
		var c := ankle - knee
		_leg_geo.append({
			"l1": Vector2(t.y, t.z).length(), "a1": atan2(-t.z, -t.y),
			"l2": Vector2(c.y, c.z).length(), "a2": atan2(-c.z, -c.y),
			"ankle": ankle.y, "dy": hip.y - _hip_rest.y,
		})
	for p in _drivers:
		_rest_inv.append(_in_model(p).affine_inverse())

	var depth := {}
	for b in _skel.get_bone_count():
		var d := 0
		var p := _skel.get_bone_parent(b)
		while p >= 0:
			d += 1
			p = _skel.get_bone_parent(p)
		depth[b] = d
		_order.append(b)
		_global_rest[b] = _skel.get_bone_global_rest(b)
	_order.sort_custom(func(x: int, y: int) -> bool: return depth[x] < depth[y])

	var tex := AssetLoader.texture(TEXTURE_PATH % file)
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var mesh := mi.mesh
		if mesh == null:
			continue
		for i in mesh.get_surface_count():
			var src := mesh.surface_get_material(i)
			var part := StringName(src.resource_name if src != null else "")
			var color: Color = style.get(part, DEFAULT_COLORS.get(part, Color.WHITE))
			mi.set_surface_override_material(i, _porcelain(part, color, file, tex))
	return true

## A glazed surface: the colour over the baked shading and crazing of `file`.
static func _porcelain(part: StringName, color: Color, file: String, tex: Texture2D) -> StandardMaterial3D:
	var key := "%s|%s|%s" % [part, color.to_html(), file]
	if _porcelain_cache.has(key):
		return _porcelain_cache[key]
	var m := StandardMaterial3D.new()
	m.resource_name = part
	m.albedo_color = color
	m.albedo_texture = tex
	m.roughness = ROUGHNESS.get(part, 0.5)
	_porcelain_cache[key] = m
	return m

## A bone's rest head in this node's space.
func _joint(bone: StringName) -> Vector3:
	return _ts * (_skel.get_bone_global_rest(_skel.find_bone(bone)) as Transform3D).origin

## An empty pivot under `parent`, placed at `at` (this node's space).
func _pivot(parent: Node3D, at: Vector3) -> Node3D:
	var p := Node3D.new()
	parent.add_child(p)
	p.position = _in_model(parent).affine_inverse() * at
	return p

func _drive(bone: StringName, pivot: Node3D) -> void:
	_driven[_skel.find_bone(bone)] = _drivers.size()
	_drivers.append(pivot)

## A node's transform in this node's space (before this node's own).
func _in_model(n: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	while n != null and n != self:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return t

## Pose the legs by two-bone IK: the hips at their height for the pose, each
## ankle back at its standing height `ahead` in front of its hip joint, the
## knee forward, the foot flat (or toes up when sitting on the floor).
func _pose_model(pose: StringName) -> void:
	var h := _hip_rest.y
	var ahead := NAN
	var lean := 0.0
	var flat := 1.0
	var thigh: float = _leg_geo[0].l1
	var shin: float = _leg_geo[0].l2
	match pose:
		&"agachado":
			h = SEAT_Y
			ahead = 0.12
			lean = deg_to_rad(-18.0)
		&"sentado":
			h = SEAT_Y
			ahead = 0.95 * thigh
		&"no_chao":
			h = FLOOR_Y
			ahead = 0.99 * (thigh + shin)
			flat = 0.0
	_hips.position = Vector3(_hip_rest.x, h, _hip_rest.z)
	_torso.rotation = Vector3(lean, 0.0, 0.0)
	for i in _legs.size():
		if is_nan(ahead):
			_legs[i].rotation = Vector3.ZERO
			_knees[i].rotation = Vector3.ZERO
			_feet[i].rotation = Vector3.ZERO
			continue
		var g: Dictionary = _leg_geo[i]
		var l1: float = g.l1
		var l2: float = g.l2
		var drop: float = h + g.dy - g.ankle
		var d := clampf(Vector2(ahead, drop).length(), absf(l1 - l2) + 0.01, l1 + l2 - 0.001)
		var at_hip := acos(clampf((l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d), -1.0, 1.0))
		var at_knee := acos(clampf((l1 * l1 + l2 * l2 - d * d) / (2.0 * l1 * l2), -1.0, 1.0))
		var thigh_angle := atan2(ahead, drop) + at_hip
		var shin_angle := thigh_angle - (PI - at_knee)
		var t1: float = thigh_angle - g.a1
		var t2: float = shin_angle - g.a2 - t1
		_legs[i].rotation = Vector3(t1, 0.0, 0.0)
		_knees[i].rotation = Vector3(t2, 0.0, 0.0)
		_feet[i].rotation = Vector3(-(t1 + t2) * flat, 0.0, 0.0)

## Moves every bone after its pivot: a driven bone takes its pivot's motion
## since rest; the others follow their parent as they were at rest.
func _sync() -> void:
	if _skel == null:
		return
	var now: Array[Transform3D] = []
	var changed := _last.size() != _drivers.size()
	for k in _drivers.size():
		var t := _in_model(_drivers[k])
		now.append(t)
		if not changed and not t.is_equal_approx(_last[k]):
			changed = true
	if not changed:
		return
	_last = now
	var global := {}
	for b in _order:
		var parent := _skel.get_bone_parent(b)
		var pg: Transform3D = global[parent] if parent >= 0 else Transform3D.IDENTITY
		var g: Transform3D
		if _driven.has(b):
			var k: int = _driven[b]
			g = _ts_inv * now[k] * _rest_inv[k] * _ts * (_global_rest[b] as Transform3D)
		else:
			g = pg * _skel.get_bone_rest(b)
		global[b] = g
		var local := pg.affine_inverse() * g
		_skel.set_bone_pose_position(b, local.origin)
		_skel.set_bone_pose_rotation(b, local.basis.get_rotation_quaternion())
		_skel.set_bone_pose_scale(b, local.basis.get_scale())

# --- The box body (no model) ----------------------------------------------

func _build_boxes() -> void:
	_hips = Node3D.new()
	add_child(_hips)
	for side in [-1.0, 1.0]:
		var leg := Node3D.new()
		leg.position = Vector3(side * 0.1, 0.0, 0.0)
		_hips.add_child(leg)
		_part(leg, Vector3(0.14, 0.85, 0.16), Vector3(0.0, -0.425, 0.0), &"trousers")
		_legs.append(leg)
	_torso = Node3D.new()
	_hips.add_child(_torso)
	_part(_torso, Vector3(0.44, 0.62, 0.24), Vector3(0.0, 0.31, 0.0), &"coat")
	_part(_torso, Vector3(0.46, 0.26, 0.26), Vector3(0.0, -0.03, 0.0), &"coat")
	for side in [-1.0, 1.0]:
		var a := Node3D.new()
		a.position = Vector3(side * 0.29, 0.6, 0.0)
		a.rotation.z = deg_to_rad(side * ARM_SPLAY)
		_torso.add_child(a)
		_arms[side] = a
		_part(a, Vector3(0.11, 0.6, 0.12), Vector3(0.0, -0.28, 0.0), &"coat")
	_head = Node3D.new()
	_head.position = Vector3(0.0, 0.66, 0.0)
	_torso.add_child(_head)
	var skull := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.11
	sphere.height = 0.24
	skull.mesh = sphere
	skull.material_override = _mats.get(&"skin")
	skull.position = Vector3(0.0, 0.13, 0.0)
	_head.add_child(skull)
	_part(_head, Vector3(0.23, 0.12, 0.24), Vector3(0.0, 0.2, 0.01), &"hair")

func _part(parent: Node3D, size: Vector3, pos: Vector3, mat: StringName) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mats.get(mat)
	mi.position = pos
	parent.add_child(mi)
	return mi
