extends Node3D
## Elias's own pocket watch, the compass (spec §7): it came with the letter
## and its seconds hand feels the parts of Inácio's watch. Shut, it ticks in
## his pocket; open (T, the left hand), the hand stops and points at the
## night's goal, or at the first link on the way there (compass_model.gd),
## and the watch tips up or down with it. It turns slowly when there is no
## way, and trembles and turns with a Gasto close. It never marks anything
## on screen: blocks on the hands' layer until the asset (task 35).
## Child of the left hand (hands.gd), where the held item's block sits.

const Compass = preload("res://scripts/compass_model.gd")
const Registry = preload("res://scripts/areas/registry.gd")
const Hands = preload("res://scripts/hands.gd")
const HandsModel = preload("res://scripts/hands_model.gd")

## Turns per second while the hand finds nothing.
const SPIN := 0.5
## A struggle with a Gasto (capture_model.gd) slows the tick by this much,
## once per fight, until the next night.
const SPRING_LOSS := 1.3
const SPRING_WORST := 2.0
## How far the watch tips for a link above or below (rad).
const TIP := 0.35
## How hard the hand shakes with a Gasto near (rad).
const SHAKE := 0.3
## Where the watch sits on the left hand (over the held item's block).
const SEAT := Vector3(0.0, 0.085, -0.1)

## Heard by the Gastos within Compass.HEARD_RADIUS while open (task 20).
signal ticked(at: Vector3, open: bool)

## Set by main.
var main: Node
var is_open := false
var goal: Dictionary = {}
## 1 a full spring; SPRING_LOSS after one fight, and so on.
var spring_scale := 1.0
var trembling := false
var _aim: Dictionary = {"mode": &"spin"}
var _yaw := 0.0
var _tick_in := 0.5
var _links: Array = []
var _needle_pivot: Node3D
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_links = Registry.links()
	position = SEAT
	var face := _block(self, Vector3(0.058, 0.004, 0.058), Vector3.ZERO, Color("#e8dcc0"), Hands.LANTERN_ORDER + 1)
	face.name = "Face"
	_needle_pivot = Node3D.new()
	_needle_pivot.name = "Needle"
	_needle_pivot.position = Vector3(0.0, 0.004, 0.0)
	add_child(_needle_pivot)
	_block(_needle_pivot, Vector3(0.004, 0.003, 0.026), Vector3(0.0, 0.0, -0.011), Color("#2a2620"), Hands.LANTERN_ORDER + 2)
	visible = false

func _block(parent: Node3D, size: Vector3, pos: Vector3, c: Color, order: int) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.no_depth_test = true
	m.render_priority = order
	m.roughness = 0.7
	mi.material_override = m
	mi.position = pos
	mi.layers = 1 << (Hands.HANDS_LAYER - 1)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

func open() -> void:
	is_open = true
	visible = true

func close() -> void:
	is_open = false
	visible = false

## {"area": StringName, "at": Vector3}, or {} when the night has none left.
func set_goal(g: Dictionary) -> void:
	goal = g

## The struggle shook the spring: the tick drags until the next night.
func lose_spring() -> void:
	spring_scale = minf(spring_scale * SPRING_LOSS, SPRING_WORST)

## A new night: the spring is whole, the watch shut, the tick off the
## entry clock's beat.
func new_night() -> void:
	spring_scale = 1.0
	_tick_in = 0.5
	close()

## What the hand does now: Compass.aim's answer, or a spin with a Gasto near.
func aim_now() -> Dictionary:
	return _aim

## The direction the hand points to, flat, in the world (zero while it turns).
func pointing() -> Vector3:
	if _aim.get("mode") != &"point" or trembling:
		return Vector3.ZERO
	var d: Vector3 = _needle_pivot.global_basis * Vector3(0.0, 0.0, -1.0)
	d.y = 0.0
	return d.normalized()

## Seconds between ticks now.
func tick_period() -> float:
	var d := Compass.FAR
	if main != null and main.player != null and goal.has("at"):
		d = main.player.global_position.distance_to(goal.at)
	return Compass.tick_period(d) * spring_scale

func _process(delta: float) -> void:
	if main == null or main.player == null:
		return
	var p: Node3D = main.player
	if is_open and (p.get("hands_model") == null or p.hands_model.left != HandsModel.WATCH):
		close()
	var pos := p.global_position
	var area: StringName = main.atlas.level_of(main.atlas.room_at(pos))
	_aim = Compass.aim(pos, area, goal, _links)
	trembling = main.gastos != null and Compass.trembles(main.gastos.nearest(pos))
	_tick(delta, p)
	if not is_open:
		return
	var tilt := 0
	if _aim.mode == &"point" and not trembling:
		var to: Vector3 = p.global_basis.inverse() * (_aim.at - pos)
		_yaw = lerp_angle(_yaw, atan2(-to.x, -to.z), minf(1.0, delta * 8.0))
		tilt = _aim.tilt
	else:
		_yaw = wrapf(_yaw + TAU * SPIN * delta, -PI, PI)
	var shake := _rng.randf_range(-SHAKE, SHAKE) if trembling else 0.0
	_needle_pivot.rotation.y = _yaw + shake
	rotation.x = lerpf(rotation.x, tilt * TIP, minf(1.0, delta * 6.0))

func _tick(delta: float, p: Node3D) -> void:
	_tick_in -= delta
	if _tick_in > 0.0:
		return
	_tick_in = tick_period()
	var at: Vector3 = p.camera.global_position + p.camera.global_basis.x * -0.2 + Vector3(0.0, -0.4, 0.0)
	if main.sfx != null:
		main.sfx.play_at(&"tick", at, &"Mundo", -6.0 if is_open else -14.0)
	ticked.emit(at, is_open)
