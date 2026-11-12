extends RefCounted
## Night 1's wooden ball (spec §6.2, item 8): out of the dark end of the
## corridor it bounces toward Elias, five times in 2.4 s, each hop lower and
## quieter, and stops STOP metres short of him on the line between them.
## Pure: the piece (setpieces/bola_quica.gd) plays it.

const HOPS := 5
const STOP := 0.6
const DURATION := 2.4
const FIRST_HEIGHT := 0.5
const FALL := 0.6
const FIRST_DB := -6.0
const DB_STEP := -5.0

## The end of the corridor farthest from Elias.
static func far_end(ends: Array, elias: Vector3) -> Vector3:
	var best: Vector3 = ends[0]
	for e in ends:
		if _flat(e).distance_to(_flat(elias)) > _flat(best).distance_to(_flat(elias)):
			best = e
	return best

## The hops: {"t", "at", "height", "db"}; "at" is where the ball lands (at
## from's height), "height" the arc that leads to it. A hop's flight lasts as
## the square root of its height, so they come quicker as they fall.
static func hops(from: Vector3, elias: Vector3) -> Array:
	var him := Vector3(elias.x, from.y, elias.z)
	var back := from - him
	var dir := back.normalized() if back.length() > 0.001 else Vector3.FORWARD
	var last := him + dir * STOP
	var weights: Array[float] = []
	var total := 0.0
	for k in HOPS:
		var w := sqrt(FIRST_HEIGHT * pow(FALL, k))
		weights.append(w)
		total += w
	var out := []
	var t := 0.0
	for k in HOPS:
		t += weights[k] / total * DURATION
		out.append({
			"t": DURATION if k == HOPS - 1 else t,
			"at": from.lerp(last, float(k + 1) / HOPS),
			"height": FIRST_HEIGHT * pow(FALL, k),
			"db": FIRST_DB + DB_STEP * k,
		})
	return out

static func _flat(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)
