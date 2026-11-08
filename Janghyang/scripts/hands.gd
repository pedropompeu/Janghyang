extends Node
## Elias's hands in first person. The right one holds a stick of basswood
## left over from the maquete, for knocking; the left one carries the
## lantern. Drawn on top of the world (no depth test) so they never sink into
## a wall, lit by the house like everything else; they live on their own layer
## so the mirror and the final camera leave them out. Child of the player,
## after Camera3D.

## The stick reaches the end of its swing: this is when a knock lands.
signal struck

const HANDS_LAYER := 13
const RAISE_TIME := 0.12
const STRIKE_TIME := 0.09
const RETURN_TIME := 0.24
const LOWER_TIME := 0.25
const RIGHT_REST := Vector3(0.23, -0.27, -0.42)
const LEFT_REST := Vector3(-0.25, -0.27, -0.4)
## Where the lantern's lens sits, from the left wrist.
const LENS := Vector3(0.0, 0.03, -0.13)
const SKIN := Color("#d9b99b")
const COAT := Color("#4a5866")
const BASSWOOD := Color("#cdb48a")
const BRASS := Color("#9a7b3c")
## Blocks for what the left hand holds (hands_model.gd) until the assets.
const ITEM_COLORS := {
	&"relogio": BRASS, &"vareta": BASSWOOD, &"espelho": Color("#b9c4c9"),
	&"fosforo": Color("#c8a76a"), &"lupa": Color("#6f5a2e"),
	&"estetoscopio": Color("#3a3a3a"), &"brinquedo": Color("#a8553f"),
}
## Draw order among the parts, since depth is not tested: sleeves behind, the
## stick into the fist, the lantern in front of the left hand.
const SLEEVE_ORDER := 0
const STICK_ORDER := 1
const FIST_ORDER := 2
const LANTERN_ORDER := 3

var player: Node
## Metres of jitter; set by the house's mood.
var tremor := 0.0

var _rig: Node3D
var _right: Node3D
var _left: Node3D
var _stick: MeshInstance3D
var _lantern: Node3D
var _held: MeshInstance3D
var _held_item := &""
var _item_mats := {}
var _swing: Tween
var _reach: Tween
var _lower := 0.0
var _lift := 1.0
var _sway := Vector2.ZERO
var _last_look := Vector2.ZERO
var _time := 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	player = get_parent()
	_build_rig(player.get_node("Camera3D"))

func _build_rig(eye: Camera3D) -> void:
	_rig = Node3D.new()
	_rig.name = "HandsRig"
	eye.add_child(_rig)
	var skin := _mat(SKIN, FIST_ORDER)
	var coat := _mat(COAT, SLEEVE_ORDER)
	_right = Node3D.new()
	_right.position = RIGHT_REST
	_rig.add_child(_right)
	_hand(_right, skin, coat, 1.0)
	# The stick sits in the fist, tip up and forward.
	var grip := Node3D.new()
	grip.rotation.x = deg_to_rad(28.0)
	_right.add_child(grip)
	_stick = _part(grip, Vector3(0.022, 0.022, 0.56), Vector3(0.0, 0.0, -0.22), _mat(BASSWOOD, STICK_ORDER, 0.95))
	_left = Node3D.new()
	_left.position = LEFT_REST
	_rig.add_child(_left)
	_hand(_left, skin, coat, -1.0)
	_lantern = Node3D.new()
	_left.add_child(_lantern)
	_part(_lantern, Vector3(0.06, 0.06, 0.15), Vector3(0.0, 0.03, -0.05), _mat(BRASS, LANTERN_ORDER, 0.5, 0.6))
	var lens := _mat(Color(1.0, 0.95, 0.82), STICK_ORDER)
	lens.emission_enabled = true
	lens.emission = Color(1.0, 0.9, 0.7)
	lens.emission_energy_multiplier = 1.5
	_part(_lantern, Vector3(0.05, 0.05, 0.01), LENS, lens)
	for it in ITEM_COLORS:
		_item_mats[it] = _mat(ITEM_COLORS[it], LANTERN_ORDER, 0.6, 0.3 if it == &"relogio" else 0.0)
	_held = _part(_left, Vector3(0.07, 0.025, 0.07), Vector3(0.0, 0.07, -0.1), _item_mats[&"relogio"])
	_held.name = "HeldItem"
	_held.visible = false

## A fist and a sleeve running back out of view; side -1 left, +1 right.
func _hand(parent: Node3D, skin: Material, coat: Material, side: float) -> void:
	_part(parent, Vector3(0.085, 0.09, 0.11), Vector3.ZERO, skin)
	_part(parent, Vector3(0.07, 0.03, 0.05), Vector3(-side * 0.045, 0.03, -0.02), skin)
	var sleeve := _part(parent, Vector3(0.11, 0.11, 0.34), Vector3(side * 0.02, -0.03, 0.22), coat)
	sleeve.rotation.x = deg_to_rad(12.0)

func _part(parent: Node3D, size: Vector3, pos: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = m
	mi.position = pos
	mi.layers = 1 << (HANDS_LAYER - 1)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

func _mat(c: Color, order: int, rough := 0.9, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.no_depth_test = true
	m.render_priority = order
	m.roughness = rough
	m.metallic = metal
	return m

## Swing the stick once. Returns false while a swing is still under way.
func swing() -> bool:
	if _swing != null and _swing.is_valid() and _swing.is_running():
		return false
	_swing = create_tween()
	_swing.set_trans(Tween.TRANS_SINE)
	_swing.tween_property(_right, "rotation:x", deg_to_rad(38.0), RAISE_TIME).set_ease(Tween.EASE_OUT)
	_swing.parallel().tween_property(_right, "position", RIGHT_REST + Vector3(0.02, 0.06, 0.05), RAISE_TIME)
	_swing.tween_property(_right, "rotation:x", deg_to_rad(-34.0), STRIKE_TIME).set_ease(Tween.EASE_IN)
	_swing.parallel().tween_property(_right, "position", RIGHT_REST + Vector3(-0.04, -0.02, -0.12), STRIKE_TIME)
	_swing.tween_callback(struck.emit)
	_swing.tween_property(_right, "rotation:x", 0.0, RETURN_TIME).set_ease(Tween.EASE_OUT)
	_swing.parallel().tween_property(_right, "position", RIGHT_REST, RETURN_TIME)
	return true

## The stick met something: it bounces back a little before returning.
func recoil() -> void:
	if _swing != null and _swing.is_valid():
		_swing.kill()
	_swing = create_tween()
	_swing.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_swing.tween_property(_right, "rotation:x", deg_to_rad(-12.0), 0.05)
	_swing.parallel().tween_property(_right, "position", RIGHT_REST + Vector3(-0.03, 0.0, -0.06), 0.05)
	_swing.tween_property(_right, "rotation:x", 0.0, RETURN_TIME)
	_swing.parallel().tween_property(_right, "position", RIGHT_REST, RETURN_TIME)

## The left hand goes out toward what E touched.
func reach() -> void:
	if _reach != null and _reach.is_valid():
		_reach.kill()
	_reach = create_tween()
	_reach.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var out := LEFT_REST + Vector3(0.1, 0.1, -0.16)
	_reach.tween_property(_left, "position", out, 0.14)
	_reach.tween_property(_left, "position", LEFT_REST, 0.26)

## True when nothing in the world can hide or cut through the hands.
func drawn_on_top() -> bool:
	for mi in _rig.find_children("*", "MeshInstance3D", true, false):
		if not (mi.material_override as BaseMaterial3D).no_depth_test:
			return false
	return true

func is_shown() -> bool:
	return _rig.visible

func has_stick() -> bool:
	return _stick != null and _stick.is_inside_tree()

func lantern_shown() -> bool:
	return _lantern.visible and _lift > 0.5

## The left hand's node: the pocket watch sits on it (pocket_watch.gd).
func left_hand() -> Node3D:
	return _left

## What the left hand shows now (&"" for nothing).
func held_item() -> StringName:
	return _held_item

func _show_held(item: StringName) -> void:
	if item == _held_item:
		return
	_held_item = item
	_held.visible = _item_mats.has(item)
	if _held.visible:
		_held.material_override = _item_mats[item]

func _process(delta: float) -> void:
	var eye: Camera3D = player.camera
	if eye == null:
		return
	_time += delta

	# Put away while reading, while pretending, or once the visit is over.
	var want_lower := 1.0 if player.input_locked or player.pretending else 0.0
	_lower = move_toward(_lower, want_lower, delta / LOWER_TIME)
	_rig.visible = _lower < 1.0
	var lamp_on: bool = player.flashlight.visible
	_show_held(player.hands_model.left if player.get("hands_model") != null else &"")
	_lift = move_toward(_lift, 1.0 if lamp_on or _held_item != &"" else 0.0, delta / LOWER_TIME)
	_lantern.visible = _lift > 0.0

	# Walking bob, a slow breath, the lag of a turning head, and fear.
	var look := Vector2(player.rotation.y, eye.rotation.x)
	var turn := (look - _last_look) / maxf(delta, 0.001)
	_last_look = look
	_sway = _sway.lerp(Vector2(clampf(turn.x, -4.0, 4.0), clampf(turn.y, -4.0, 4.0)) * 0.006, minf(1.0, delta * 8.0))
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	var bob: float = player._bob_time
	var walk := clampf(speed / 2.6, 0.0, 1.6)
	var offset := Vector3(
		sin(bob * 0.5) * 0.012 * walk + _sway.x,
		-absf(cos(bob * 0.5)) * 0.01 * walk + sin(_time * 1.3) * 0.004 - _sway.y - _lower * 0.45,
		0.0)
	if tremor > 0.0:
		offset += Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), 0.0) * tremor
	_rig.position = offset
	var left_drop := (1.0 - _lift) * 0.3
	_left.position.y = LEFT_REST.y - left_drop if _reach == null or not _reach.is_running() else _left.position.y

	# The beam comes from the lantern in the left hand.
	var lens: Vector3 = offset + _left.position + LENS
	player.flashlight.position = lens
	player.flashlight.rotation = Vector3(-_sway.y * 0.5, -_sway.x * 0.5, 0.0)
