extends RigidBody3D
## Wooden ball: the first invitation. Visual only, no audio.

const TRAIL_EVERY := 1.0
const ROLL_BACK_SECONDS := 10

var _cooldown := 0.0
## Where the ball was, once a second, newest last.
var _trail: Array[Vector3] = []
var _trail_acc := 0.0

func _ready() -> void:
	continuous_cd = true
	linear_damp = 0.65
	angular_damp = 0.9
	mass = 0.45

func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)

func _physics_process(delta: float) -> void:
	_trail_acc += delta
	if _trail_acc >= TRAIL_EVERY:
		_trail_acc -= TRAIL_EVERY
		_trail.append(global_position)
		if _trail.size() > ROLL_BACK_SECONDS + 1:
			_trail.pop_front()

## Put somewhere by a scene (setpieces/bola_quica.gd): the trail starts over
## there, so 03:33 never rolls it back across the house to where it was put from.
func place(at: Vector3) -> void:
	global_position = at
	_trail.clear()
	_trail_acc = 0.0

func get_prompt() -> String:
	return "rolar a bola"

func interact() -> void:
	if _cooldown > 0.0:
		return
	_cooldown = 0.7
	sleeping = false
	apply_central_impulse(Vector3(randf_range(-0.5, 0.5), 0.35, randf_range(-1.3, 1.3)))
	apply_torque_impulse(Vector3(randf_range(-0.2, 0.2), 0.0, randf_range(-0.4, 0.4)))

## The house rolls the ball back: a nudge along the floor.
func push(dir: Vector3) -> void:
	var flat := Vector3(dir.x, 0.0, dir.z).normalized()
	if flat == Vector3.ZERO:
		return
	sleeping = false
	apply_central_impulse(flat * 1.1 + Vector3(0.0, 0.15, 0.0))

## 03:33: the ball rolls back toward where it was ten seconds ago.
func roll_back() -> void:
	if _trail.is_empty():
		return
	var back := _trail[0] - global_position
	back.y = 0.0
	var d := back.length()
	if d < 0.1:
		return
	sleeping = false
	# Enough to cover the distance against the damping, no more.
	apply_central_impulse(back / d * clampf(mass * d * linear_damp, 0.1, 1.5))
