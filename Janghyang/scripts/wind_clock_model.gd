extends RefCounted
## The entrance clock as pure state. The spring runs down one unit per second
## (times drain_rate); each wind gives back less than the one before. Until
## can_stop is set the clock stalls just short of stopping.

const SPRING_MAX := 600.0
const FIRST_WIND := 180.0
const WIND_FACTOR := 0.7
const WIND_FLOOR := 15.0
const STALL_SPRING := 5.0

var spring := 600.0
var winds := 0
var drain_rate := 1.0
var can_stop := false
var _stopped := false

## Advance by dt seconds. Returns true only on the tick the clock stops.
func tick(dt: float) -> bool:
	if _stopped:
		return false
	var next := spring - dt * drain_rate
	if not can_stop:
		spring = maxf(next, minf(spring, STALL_SPRING))
		return false
	spring = maxf(next, 0.0)
	if spring <= 0.0:
		_stopped = true
		return true
	return false

## Back to the clock as it leaves the shop: a new night starts on it.
func reset() -> void:
	spring = SPRING_MAX
	winds = 0
	drain_rate = 1.0
	can_stop = false
	_stopped = false

## Wind once. Returns how much spring went in. A stopped clock runs again.
func wind() -> float:
	var amount := maxf(WIND_FLOOR, FIRST_WIND * pow(WIND_FACTOR, winds))
	var added := minf(amount, SPRING_MAX - spring)
	spring += added
	winds += 1
	if spring > 0.0:
		_stopped = false
	return added

func clamp_spring(max_value: float) -> void:
	spring = minf(spring, max_value)

func force_stop() -> void:
	spring = 0.0
	_stopped = true

func is_stopped() -> bool:
	return _stopped

## Minutes past three: 0 = 03:00, 33 = 03:33.
func display_minutes() -> float:
	return (1.0 - spring / SPRING_MAX) * 33.0

## The audible tick drifts late as the spring runs out, while the pendulum
## animation stays on a fixed 1.0 s.
func audio_tick_period() -> float:
	return 1.0 + 0.25 * (1.0 - spring / SPRING_MAX)
