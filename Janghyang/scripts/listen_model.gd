extends RefCounted
## Listening through a wall (spec §9, L held by a wall): Elias stands still,
## the effects bus drops DUCK_DB and every Gasto he can hear gives a muffled
## porcelain creak where it stands, every PERIOD seconds. The bare ear hears
## EAR_RANGE metres on his own floor (|dy| < FLOOR_BAND); the stethoscope
## hears SCOPE_RANGE metres through floors.

const EAR_RANGE := 12.0
const SCOPE_RANGE := 25.0
const FLOOR_BAND := 2.5
const PERIOD := 1.5
const DUCK_DB := -18.0
## L only works this close to a wall (m).
const WALL_REACH := 0.9

var _since := INF

static func audible(gasto: Vector3, ear: Vector3, scope: bool) -> bool:
	var d := gasto.distance_to(ear)
	if scope:
		return d < SCOPE_RANGE
	return d < EAR_RANGE and absf(gasto.y - ear.y) < FLOOR_BAND

## True when the next creak is due (at once when listening starts).
func beat(dt: float) -> bool:
	_since += dt
	if _since >= PERIOD - 0.0001:
		_since = 0.0
		return true
	return false

func reset() -> void:
	_since = INF
