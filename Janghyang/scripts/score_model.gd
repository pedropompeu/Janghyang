extends RefCounted
## The music as numbers: how loud each layer plays for where Elias is and
## what is near him. Quiet always; the scare is presence, not volume.
##   drone    low, breathy; lower the deeper he goes
##   lullaby  the music box tune, slow, out of tune, with notes missing
##   strings  a dissonant cluster that swells when a Gasto is near
##   heart    a low pulse: a Gasto very near, or running
##   memory   the same tune, clean and in a major key: eyes closed

const SILENT := -60.0
const CEILING := -6.0
const ROOT_HZ := 293.66
const DRONE_HZ := 55.0

## The lullaby in D minor, 3/4: (semitones from D, beats).
const LULLABY: Array[Vector2] = [
	Vector2(7, 1), Vector2(3, 1), Vector2(0, 1), Vector2(2, 2), Vector2(3, 1),
	Vector2(5, 1), Vector2(2, 1), Vector2(-2, 1), Vector2(0, 3),
	Vector2(7, 1), Vector2(3, 1), Vector2(0, 1), Vector2(2, 2), Vector2(3, 1),
	Vector2(5, 1), Vector2(7, 1), Vector2(8, 1), Vector2(7, 3),
	Vector2(10, 1), Vector2(8, 1), Vector2(7, 1), Vector2(5, 2), Vector2(3, 1),
	Vector2(2, 1), Vector2(3, 1), Vector2(2, 1), Vector2(0, 3),
]

## dB per layer. depth 0 (house) .. 1 (drawer); threat 0..1; running 0..1.
static func mix(depth: float, threat: float, pretending: bool, running: float, hora: bool) -> Dictionary:
	threat = clampf(threat, 0.0, 1.0)
	running = clampf(running, 0.0, 1.0)
	if hora:
		return {&"drone": -24.0, &"lullaby": SILENT, &"strings": SILENT, &"heart": SILENT, &"memory": SILENT}
	var drone := lerpf(-22.0, -16.0, clampf(depth, 0.0, 1.0))
	var lullaby := lerpf(-17.0, -34.0, threat)
	var strings := lerpf(SILENT, -13.0, pow(threat, 1.3))
	var heart := lerpf(SILENT, -10.0, smoothstep(0.35, 1.0, threat))
	heart = maxf(heart, lerpf(SILENT, -20.0, running))
	var memory := SILENT
	if pretending:
		memory = -12.0
		lullaby = -40.0
		strings -= 14.0
		drone -= 8.0
	return {
		&"drone": minf(drone, CEILING),
		&"lullaby": minf(lullaby, CEILING),
		&"strings": minf(maxf(strings, SILENT), CEILING),
		&"heart": minf(heart, CEILING),
		&"memory": minf(memory, CEILING),
	}

static func note_hz(semitones: float) -> float:
	return ROOT_HZ * pow(2.0, semitones / 12.0)

static func drone_hz(depth: float) -> float:
	return DRONE_HZ * pow(2.0, -clampf(depth, 0.0, 1.0) * 5.0 / 12.0)
