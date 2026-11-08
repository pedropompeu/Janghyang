extends RefCounted
## What the Gastos hear (spec §6): three levels of noise, each with its
## radius. Crouched steps are QUIET; walking is NORMAL; running, winding,
## repairing, the stick and a gasp are LOUD; the open watch's tick carries
## Compass.HEARD_RADIUS. A Gasto that hears a noise heads for it for
## NOISE_MEMORY seconds. Elias can hold his breath (H) for BREATH_MAX
## seconds; then he gasps out loud and needs BREATH_REST before holding again.

enum Level { QUIET, NORMAL, LOUD }

const RADIUS := [1.5, 5.0, 10.0]
const NOISE_MEMORY := 10.0
const BREATH_MAX := 8.0
const BREATH_REST := 4.0

## True while Elias holds his breath.
var holding := false
var _held := 0.0
var _rest := 0.0

static func radius(level: int) -> float:
	return RADIUS[clampi(level, Level.QUIET, Level.LOUD)]

static func heard(src: Vector3, ear: Vector3, level: int) -> bool:
	return src.distance_to(ear) < radius(level)

## One tick of the H key. Returns &"gasp" the moment the breath gives out.
func breath(dt: float, pressed: bool) -> StringName:
	if _rest > 0.0:
		_rest -= dt
		if _rest > 0.0:
			holding = false
			return &""
		dt = -_rest
		_rest = 0.0
	if not pressed:
		holding = false
		_held = 0.0
		return &""
	holding = true
	_held += dt
	if _held > BREATH_MAX:
		holding = false
		_held = 0.0
		_rest = BREATH_REST
		return &"gasp"
	return &""
