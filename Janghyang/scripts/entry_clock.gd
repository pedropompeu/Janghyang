extends StaticBody3D
## The tall clock by the front door. Winding it is the only thing it asks;
## the hands and the pendulum only read the WindClockModel.

signal wound(amount: float)

var model
var _minute_pivot: Node3D
var _pendulum_pivot: Node3D
var _swing_time := 0.0
## Set by main (sfx_bank.gd). The tick is heard all over the house.
var sfx: Node
var _tick_time := 0.0

func setup(clock_model, minute_pivot: Node3D, pendulum_pivot: Node3D) -> void:
	model = clock_model
	_minute_pivot = minute_pivot
	_pendulum_pivot = pendulum_pivot

func get_prompt() -> String:
	return "dar corda"

func interact() -> void:
	if model == null:
		return
	wound.emit(model.wind())

func _process(delta: float) -> void:
	if model == null:
		return
	if sfx != null and not model.is_stopped():
		_tick_time += delta
		if _tick_time >= model.audio_tick_period():
			_tick_time = 0.0
			sfx.play_at(&"tick", global_position + Vector3(0.0, 1.6, 0.0))
	if _minute_pivot != null:
		_minute_pivot.rotation.z = deg_to_rad(model.display_minutes() * 6.0)
	if _pendulum_pivot != null:
		if model.is_stopped():
			_pendulum_pivot.rotation.z = lerpf(_pendulum_pivot.rotation.z, 0.0, 4.0 * delta)
		else:
			# Fixed 1.0 s beat: the pendulum never drifts, only the tick does.
			_swing_time += delta
			_pendulum_pivot.rotation.z = sin(_swing_time * PI) * 0.16
