extends CanvasLayer
## What a grab looks like (capture_model.gd): the head pulled toward the
## Gasto and shaken, the screen flickering dark, the hands pushing at each
## click. Never full white, never faster than MAX_HZ; "reduce_flash" halves
## the depth and slows it to 1 Hz. A _process node: it stops with the tree.

const MAX_HZ := 2.5
const REDUCED_HZ := 1.0
## The lightest the flicker gets.
const LIGHTEST := Color(0.75, 0.72, 0.66)
const DARK := Color(0.03, 0.025, 0.02)
const DEPTH := 0.55
const SHAKE := 0.018
const PULL := 3.0

## Set by main.
var main: Node
var reduce_flash := false
var _rect: ColorRect
var _active := false
var _at := Vector3.ZERO
var _time := 0.0
var _rng := RandomNumberGenerator.new()

static func flicker_hz(reduced: bool) -> float:
	return REDUCED_HZ if reduced else MAX_HZ

static func flicker_depth(reduced: bool) -> float:
	return DEPTH * (0.5 if reduced else 1.0)

## The overlay colour `t` seconds into the grab: dark at the trough, LIGHTEST
## at the crest, with alpha up to the depth.
static func flicker_color(t: float, reduced: bool) -> Color:
	var wave := 0.5 + 0.5 * sin(TAU * flicker_hz(reduced) * t)
	var c := DARK.lerp(LIGHTEST, wave * 0.35)
	c.a = flicker_depth(reduced) * (1.0 - wave * 0.6)
	return c

func _ready() -> void:
	layer = 4
	_rect = ColorRect.new()
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.visible = false
	add_child(_rect)

## A Gasto at `head` has Elias.
func start(head: Vector3) -> void:
	_active = true
	_at = head
	_time = 0.0
	_rect.visible = true
	_rect.color = flicker_color(0.0, reduce_flash)

func stop() -> void:
	_active = false
	_rect.visible = false
	var cam: Camera3D = main.player.camera if main != null and main.player != null else null
	if cam != null:
		cam.h_offset = 0.0
		cam.v_offset = 0.0

## One click: the left hand shoves and the porcelain gives a little.
func push() -> void:
	if not _active:
		return
	var p = main.player
	if p.get("hands") != null:
		p.hands.reach()
	main.sfx.play_at(&"crack", _at, &"Mundo", -3.0)

func is_active() -> bool:
	return _active

func color_now() -> Color:
	return _rect.color

func _process(delta: float) -> void:
	if not _active or main == null or main.player == null:
		return
	_time += delta
	_rect.color = flicker_color(_time, reduce_flash)
	var p = main.player
	var to: Vector3 = _at - p.global_position
	if Vector2(to.x, to.z).length() > 0.05:
		p.rotation.y = lerp_angle(p.rotation.y, atan2(-to.x, -to.z), minf(1.0, delta * PULL))
	var k := SHAKE * (0.5 if reduce_flash else 1.0)
	p.camera.h_offset = _rng.randf_range(-k, k)
	p.camera.v_offset = _rng.randf_range(-k, k)
