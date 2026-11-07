extends Node
## The music, synthesised at load and mixed by score_model.gd: a low drone
## that sinks as Elias goes deeper, Inácio's lullaby on a music box with notes
## missing, strings that swell when a Gasto is near, a heart that beats when
## one is very near or he runs, and with eyes closed the same lullaby clean,
## in a major key, the way it sounded when the house was a house.
## All layers loop together, so the memory and the box stay in step.

const ScoreModel = preload("res://scripts/score_model.gd")

const LAYERS: Array[StringName] = [&"drone", &"lullaby", &"memory", &"strings", &"heart"]
const RATE := 22050
const BEAT := 0.62
## Room for the last note to ring before the tune starts again.
const TAIL := 1.5
const DRONE_SECONDS := 8.0
const STRINGS_SECONDS := 6.0
## dB per second the layers move toward their mix.
const GLIDE := 14.0
## How deep each part of the bench sounds (0 house, 1 drawer).
const DEPTH := {&"casa": 0.0, &"passagem": 0.35, &"sotao": 0.3, &"mecanismo": 0.55, &"tampo": 0.7, &"gaveta": 1.0}

## Set by main before add_child.
var main: Node
var silent := DisplayServer.get_name() == "headless"
var players := {}
var targets := {}

static func render(layer: StringName) -> AudioStreamWAV:
	match layer:
		&"drone":
			return _wav(_drone(), true)
		&"lullaby":
			return _wav(_tune(false), true)
		&"memory":
			return _wav(_tune(true), true)
		&"strings":
			return _wav(_strings(), true)
		&"heart":
			return _wav(_heart(), true)
	push_error("score: unknown layer %s" % layer)
	return null

## The box has lost a few of its pins.
static func missing(i: int) -> bool:
	return (i * 7 + 3) % 9 == 0

## Minor third, sixth and seventh raised: the same tune, before.
static func to_major(semitones: float) -> float:
	var deg := posmod(int(semitones), 12)
	return semitones + 1.0 if deg in [3, 8, 10] else semitones

static func _tune(clean: bool) -> PackedFloat32Array:
	var beats := 0.0
	for n in ScoreModel.LULLABY:
		beats += n.y
	var total := int((beats * BEAT + TAIL) * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = 33
	var at := 0.0
	for i in ScoreModel.LULLABY.size():
		var n: Vector2 = ScoreModel.LULLABY[i]
		var detune := rng.randf_range(-0.28, 0.28)
		if clean:
			_bell(out, at, ScoreModel.note_hz(to_major(n.x)), n.y * BEAT + 1.2, 0.16, true)
			if posmod(i, 3) == 0:
				_bell(out, at, ScoreModel.note_hz(to_major(n.x) - 24.0), 3.0 * BEAT, 0.07, true)
		elif not missing(i):
			_bell(out, at, ScoreModel.note_hz(n.x + detune), n.y * BEAT + 1.0, 0.15, false)
		at += n.y * BEAT
	return out

## A music-box tine (bright, quick decay, a slow wobble from a tired spring)
## or, clean, a soft round note.
static func _bell(out: PackedFloat32Array, start: float, hz: float, length: float, amp: float, clean: bool) -> void:
	var s0 := int(start * RATE)
	var n := mini(int(length * RATE), out.size() - s0)
	var decay := 2.2 if clean else 3.4
	for k in n:
		var t := float(k) / RATE
		var wob := 1.0 + (0.0 if clean else 0.006 * sin(TAU * 0.7 * (start + t)))
		var ph := TAU * hz * wob * t
		var v: float
		if clean:
			v = sin(ph) + 0.25 * sin(2.0 * ph)
			v *= minf(1.0, t * 60.0)
		else:
			v = sin(ph) + 0.45 * sin(2.76 * ph) * exp(-t * 6.0) + 0.2 * sin(5.4 * ph) * exp(-t * 12.0)
		out[s0 + k] += v * amp * exp(-t * decay)

static func _drone() -> PackedFloat32Array:
	var n := int(DRONE_SECONDS * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	var air := 0.0
	var f1 := _loopf(ScoreModel.DRONE_HZ, DRONE_SECONDS)
	var f2 := _loopf(ScoreModel.DRONE_HZ * 1.5, DRONE_SECONDS)
	var f3 := _loopf(ScoreModel.DRONE_HZ * 2.0 + 0.25, DRONE_SECONDS)
	for k in n:
		var t := float(k) / RATE
		air = lerpf(air, rng.randf_range(-1.0, 1.0), 0.03)
		var swell := pow(sin(PI * t / DRONE_SECONDS), 2.0)
		out[k] = (sin(TAU * f1 * t) * 0.5 + sin(TAU * f2 * t) * 0.18 + sin(TAU * f3 * t) * 0.22) * 0.32 + air * swell * 0.5
	return out

static func _strings() -> PackedFloat32Array:
	var n := int(STRINGS_SECONDS * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var voices := [ScoreModel.note_hz(0.0), ScoreModel.note_hz(1.0), ScoreModel.note_hz(6.0), ScoreModel.note_hz(11.7)]
	for i in voices.size():
		voices[i] = _loopf(voices[i], STRINGS_SECONDS)
	var trem := _loopf(5.5, STRINGS_SECONDS)
	for k in n:
		var t := float(k) / RATE
		var v := 0.0
		for f in voices:
			var ph: float = TAU * f * t
			v += sin(ph) + 0.5 * sin(2.0 * ph) + 0.33 * sin(3.0 * ph) + 0.2 * sin(4.0 * ph)
		out[k] = v * (0.75 + 0.25 * sin(TAU * trem * t)) * 0.06
	return out

## Lub-dub once a second; main speeds it up with pitch.
static func _heart() -> PackedFloat32Array:
	var n := RATE
	var out := PackedFloat32Array()
	out.resize(n)
	for k in n:
		var t := float(k) / RATE
		var lub := sin(TAU * 52.0 * t) * exp(-t * 22.0)
		var t2 := maxf(0.0, t - 0.3)
		var dub := sin(TAU * 64.0 * t2) * exp(-t2 * 28.0) * 0.7 if t >= 0.3 else 0.0
		out[k] = (lub + dub) * 0.45
	return out

## The nearest frequency that fits a whole number of cycles in the loop.
static func _loopf(hz: float, seconds: float) -> float:
	return roundf(hz * seconds) / seconds

static func _wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -0.5, 0.5) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_end = samples.size()
	return w

func _ready() -> void:
	_ensure_bus()
	for layer in LAYERS:
		var p := AudioStreamPlayer.new()
		p.name = "Score_" + String(layer)
		p.bus = &"Musica"
		p.volume_db = ScoreModel.SILENT
		add_child(p)
		players[layer] = p
		targets[layer] = ScoreModel.SILENT
	if silent:
		return
	for layer in LAYERS:
		players[layer].stream = render(layer)
	for layer in LAYERS:
		players[layer].play()

func _ensure_bus() -> void:
	if AudioServer.get_bus_index(&"Musica") >= 0:
		return
	var idx := AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, &"Musica")
	AudioServer.set_bus_send(idx, &"Master")
	var verb := AudioEffectReverb.new()
	verb.room_size = 0.85
	verb.damping = 0.6
	verb.wet = 0.35
	verb.dry = 0.8
	AudioServer.add_bus_effect(idx, verb)

## Sets the mix for the moment; the layers glide toward it.
func set_state(depth: float, threat: float, pretending: bool, running: float, hora: bool) -> void:
	var m := ScoreModel.mix(depth, threat, pretending, running, hora)
	for layer in LAYERS:
		targets[layer] = m[layer]
	# Deeper is lower; a near Gasto quickens the heart.
	players[&"drone"].pitch_scale = ScoreModel.drone_hz(depth) / ScoreModel.DRONE_HZ
	players[&"heart"].pitch_scale = lerpf(1.0, 1.7, clampf(maxf(threat, running), 0.0, 1.0))

func level_db(layer: StringName) -> float:
	return players[layer].volume_db

func _process(delta: float) -> void:
	if main != null and main.player != null and main.has_method("score_inputs"):
		var s: Dictionary = main.score_inputs()
		set_state(s.depth, s.threat, s.pretending, s.running, s.hora)
	for layer in LAYERS:
		var p: AudioStreamPlayer = players[layer]
		p.volume_db = move_toward(p.volume_db, targets[layer], GLIDE * delta)
