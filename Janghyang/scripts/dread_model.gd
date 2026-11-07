extends RefCounted
## The house's mood as pure numbers. Tension (0..1) follows the visit: it
## creeps up as the clock runs down, peaks at 03:33 and lets go when Elias
## leaves. Everything it drives stays quiet: dimmer lights, thicker fog, far
## creaks, a faster breath. Nothing comes closer, nothing stings.

const VisitState = preload("res://scripts/visit_state.gd")

## Creaks never come from within this flat distance of Elias.
const CREAK_MIN_DISTANCE := 4.0
## Below this the house does not flicker at all.
const FLICKER_FROM := 0.3

## Tension for an act and the clock's minutes past three (0..33).
static func tension(act: int, minutes: float) -> float:
	var m := clampf(minutes / 33.0, 0.0, 1.0)
	match act:
		VisitState.Act.FIM:
			return 0.0
		VisitState.Act.HORA:
			return 1.0
		VisitState.Act.DEPOIS:
			return 0.75
		VisitState.Act.ESCOLHA:
			return 0.85
		VisitState.Act.DUPLO:
			return clampf(lerpf(0.15, 0.7, m) + 0.12, 0.0, 0.85)
	return clampf(lerpf(0.15, 0.7, m), 0.0, 0.85)

## Multiplier on the house lights' built energy.
static func light_scale(t: float) -> float:
	return lerpf(0.6, 0.3, clampf(t, 0.0, 1.0))

static func fog_density(t: float) -> float:
	return lerpf(0.012, 0.04, clampf(t, 0.0, 1.0))

static func ambient_energy(t: float) -> float:
	return lerpf(0.3, 0.14, clampf(t, 0.0, 1.0))

static func breath_db(t: float) -> float:
	return lerpf(-24.0, -15.0, clampf(t, 0.0, 1.0))

static func breath_pitch(t: float) -> float:
	return lerpf(1.0, 1.3, clampf(t, 0.0, 1.0))

static func hum_db(t: float) -> float:
	return lerpf(-38.0, -22.0, clampf(t, 0.0, 1.0))

## How dark the screen edges get (0 none, 1 black).
static func vignette(t: float) -> float:
	return lerpf(0.35, 0.7, clampf(t, 0.0, 1.0))

## Amplitude in metres of the hands' tremble; none below a third of the way.
static func hand_tremor(t: float) -> float:
	return 0.004 * clampf((t - 0.35) / 0.65, 0.0, 1.0)

## Seconds to the next creak; r in 0..1 spreads them out.
static func creak_delay(t: float, r: float) -> float:
	return lerpf(40.0, 10.0, clampf(t, 0.0, 1.0)) * (0.7 + 0.6 * r)

## Seconds to the next flicker; INF while the house is still calm.
static func flicker_delay(t: float, r: float) -> float:
	if t < FLICKER_FROM:
		return INF
	var k := (clampf(t, 0.0, 1.0) - FLICKER_FROM) / (1.0 - FLICKER_FROM)
	return lerpf(50.0, 14.0, k) * (0.7 + 0.6 * r)

## Index of a point at least CREAK_MIN_DISTANCE away on the floor plan, picked
## by r in 0..1; -1 when every point is too close.
static func creak_point(points: Array, from: Vector3, r: float) -> int:
	var far: Array[int] = []
	for i in points.size():
		var p: Vector3 = points[i]
		if Vector2(p.x - from.x, p.z - from.z).length() >= CREAK_MIN_DISTANCE:
			far.append(i)
	if far.is_empty():
		return -1
	return far[mini(int(r * far.size()), far.size() - 1)]
