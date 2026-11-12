extends Node3D
## Night 1's wooden ball (spec §6.2, item 8; bounce_model.gd): the ball waits
## hidden at the corridor's dark end. The first time Elias's room becomes the
## corridor, it comes out of the end farthest from him in five hops, each one
## lower and quieter (sound quique), and stops 0.6 m short of him. If the
## director refuses the scare (dread.scripted, as in 03:33) it is simply there,
## at rest where it would have stopped, silent (choice 8 of §0.5). After that
## the ball is ball.gd as always. On a night that does not list it, the ball
## starts where it was built, in the playroom: its resolved state.

const Bounce = preload("res://scripts/bounce_model.gd")
const KIND := &"bola_quica"
const ROOM := &"corredor"
## The ball's radius: its centre rests this high over the floor.
const REST := 0.14

var main: Node
var def: Dictionary
var data: Dictionary

var _active := false
## Hidden at the end, waiting for Elias to enter the corridor.
var _waiting := false
var _built_at := Vector3.INF
## The hops being played and the time into them; empty when still.
var _hops: Array = []
var _from := Vector3.ZERO
var _t := 0.0
var _next := 0

func on_night(night: Dictionary) -> void:
	var ball := _ball()
	if ball == null:
		return
	if _built_at == Vector3.INF:
		_built_at = ball.global_position
	_active = night.get("setpieces", []).has(data.id)
	_hops = []
	if _active:
		_waiting = true
		_hide(ball, true)
		ball.place(data.ends[0] + Vector3(0.0, REST, 0.0))
	else:
		_waiting = false
		_hide(ball, false)
		ball.place(_built_at)
		_release(ball)

func is_waiting() -> bool:
	return _waiting

func is_bouncing() -> bool:
	return not _hops.is_empty()

func _ball() -> RigidBody3D:
	return main.get_node_or_null("Ball") as RigidBody3D

func _hide(ball: RigidBody3D, hidden: bool) -> void:
	ball.visible = not hidden
	ball.freeze = true
	for c in ball.get_children():
		if c is CollisionShape3D:
			c.disabled = hidden

func _release(ball: RigidBody3D) -> void:
	ball.freeze = false
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.sleeping = false

func _physics_process(delta: float) -> void:
	if _waiting and main.atlas.room_at(main.player.global_position) == ROOM:
		play(main.player.global_position)
	if _hops.is_empty():
		return
	_t += delta
	_step()

## The first entry: bounce out of the far end, or, refused, just be there.
func play(elias: Vector3) -> void:
	var ball := _ball()
	if ball == null or not _waiting:
		return
	_waiting = false
	_hide(ball, false)
	var floor_y: float = data.ends[0].y
	_from = Bounce.far_end(data.ends, elias)
	var hs: Array = Bounce.hops(_from, Vector3(elias.x, floor_y, elias.z))
	if not main.dread.scripted(KIND):
		ball.place(hs[-1].at + Vector3(0.0, REST, 0.0))
		_release(ball)
		return
	_hops = hs
	_t = 0.0
	_next = 0
	ball.place(_from + Vector3(0.0, REST, 0.0))

func _step() -> void:
	var ball := _ball()
	while _next < _hops.size() and _t >= _hops[_next].t:
		var h: Dictionary = _hops[_next]
		main.sfx.play_at(&"quique", h.at, &"Casa", h.db)
		_next += 1
	if _next >= _hops.size():
		ball.place(_hops[-1].at + Vector3(0.0, REST, 0.0))
		_hops = []
		_release(ball)
		return
	var h: Dictionary = _hops[_next]
	var t0: float = _hops[_next - 1].t if _next > 0 else 0.0
	var a: Vector3 = _hops[_next - 1].at if _next > 0 else _from
	var s := clampf((_t - t0) / maxf(h.t - t0, 0.001), 0.0, 1.0)
	var p := a.lerp(h.at, s)
	p.y += REST + h.height * 4.0 * s * (1.0 - s)
	ball.place(p)
