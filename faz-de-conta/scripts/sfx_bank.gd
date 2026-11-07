extends Node
## Prototype sound, synthesised at load: sine, seeded noise and exponential
## envelopes. Nothing is ever loud; the house is heard, not announced.
## Two layers: "Mundo" (rain, breath; never muted) and "Casa" (the house).

const KINDS := [&"tick", &"click", &"knock", &"step", &"pencil", &"fold", &"rain", &"hum", &"breath", &"creak", &"swish",
	&"door", &"slam", &"porcelain", &"shatter", &"glass", &"tink", &"oco", &"crumble", &"land", &"step_metal", &"rung", &"ticks"]
const LOOPED := [&"rain", &"hum", &"breath", &"ticks"]
const RATE := 22050
const POOL_SIZE := 12
const PENCIL_PATTERN := [0.0, 0.18, 0.31, 0.55, 0.7]

## Headless runs (tests) have only a dummy audio driver: play nothing, so no
## playback is left behind at quit.
var silent := DisplayServer.get_name() == "headless"
var _streams := {}
var _pool: Array[AudioStreamPlayer3D] = []
var _next := 0

static func make(kind: StringName, seed: int = 7) -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var samples := PackedFloat32Array()
	match kind:
		&"tick":
			samples = _render(0.06, func(t: float) -> float:
				return (sin(TAU * 2400.0 * t) * 0.6 + rng.randf_range(-1.0, 1.0) * 0.4) * exp(-t * 90.0) * 0.4)
		&"click":
			samples = _render(0.04, func(t: float) -> float:
				return rng.randf_range(-1.0, 1.0) * exp(-t * 140.0) * 0.35)
		&"knock":
			# A basswood stick on wood: a dry tap, the house answers in kind.
			samples = _render(0.14, func(t: float) -> float:
				var body := sin(TAU * 330.0 * t) + sin(TAU * 610.0 * t) * 0.45
				var snap := rng.randf_range(-1.0, 1.0) * exp(-t * 260.0)
				return (body * 0.6 * exp(-t * 42.0) + snap * 0.5) * 0.34)
		&"step":
			samples = _render(0.12, func(t: float) -> float:
				return (rng.randf_range(-1.0, 1.0) * 0.6 + sin(TAU * 90.0 * t) * 0.4) * exp(-t * 40.0) * 0.22)
		&"pencil":
			samples = _render(0.09, func(t: float) -> float:
				var grain := rng.randf_range(-1.0, 1.0)
				return grain * sin(PI * t / 0.09) * 0.16)
		&"fold":
			samples = _render(0.35, func(t: float) -> float:
				var creak := sin(TAU * (60.0 + 40.0 * t) * t)
				return (rng.randf_range(-1.0, 1.0) * 0.5 + creak * 0.5) * exp(-t * 9.0) * 0.25)
		&"rain":
			var low := 0.0
			samples = _render(2.0, func(t: float) -> float:
				low = lerpf(low, rng.randf_range(-1.0, 1.0), 0.25)
				var drop := rng.randf_range(-1.0, 1.0) if rng.randf() < 0.004 else 0.0
				return low * 0.18 + drop * 0.12)
		&"hum":
			samples = _render(2.0, func(t: float) -> float:
				return (sin(TAU * 55.0 * t) * 0.7 + sin(TAU * 110.0 * t) * 0.3) * 0.12)
		&"breath":
			var air := 0.0
			samples = _render(4.0, func(t: float) -> float:
				air = lerpf(air, rng.randf_range(-1.0, 1.0), 0.08)
				var swell := pow(sin(PI * fmod(t, 4.0) / 4.0), 2.0)
				return air * swell * 0.3)
		&"creak":
			# Old wood settling somewhere else in the house: a slow, falling groan.
			var phase := 0.0
			samples = _render(1.1, func(t: float) -> float:
				phase += TAU * (95.0 - 30.0 * t + 6.0 * sin(TAU * 7.0 * t)) / RATE
				var rasp := rng.randf_range(-1.0, 1.0) * 0.35
				var swell := sin(PI * t / 1.1)
				return (sin(phase) * 0.65 + rasp) * swell * swell * 0.22)
		&"swish":
			var air := 0.0
			samples = _render(0.16, func(t: float) -> float:
				air = lerpf(air, rng.randf_range(-1.0, 1.0), 0.35)
				return air * sin(PI * t / 0.16) * 0.14)
		&"door":
			# Hinges that have not been oiled since Inácio: a long, rising
			# groan in two pulls, the second one higher.
			var phase := 0.0
			samples = _render(1.3, func(t: float) -> float:
				var pull := 0.0 if t < 0.55 else 1.0
				var f := 140.0 + 90.0 * fmod(t, 0.55) + 70.0 * pull + 18.0 * sin(TAU * 23.0 * t)
				phase += TAU * f / RATE
				var stick := 1.0 if fmod(t * 31.0, 1.0) < 0.55 else 0.35
				var rasp := rng.randf_range(-1.0, 1.0) * 0.3
				var env := sin(PI * fmod(t, 0.55) / 0.55) if t < 1.1 else exp(-(t - 1.1) * 20.0)
				return (sin(phase) * 0.55 + sin(phase * 2.01) * 0.2 + rasp) * stick * env * 0.24)
		&"slam":
			# A door closing on its own frame: a heavy thump, a rattle after.
			samples = _render(0.5, func(t: float) -> float:
				var thump := (sin(TAU * 62.0 * t) + sin(TAU * 118.0 * t) * 0.5) * exp(-t * 14.0)
				var hit := rng.randf_range(-1.0, 1.0) * exp(-t * 70.0)
				var rattle := rng.randf_range(-1.0, 1.0) * 0.25 * exp(-absf(t - 0.12) * 30.0)
				return (thump * 0.6 + hit * 0.45 + rattle) * 0.48)
		&"porcelain":
			# A porcelain joint settling: two thin, glassy clicks.
			samples = _render(0.22, func(t: float) -> float:
				var a := sin(TAU * 3100.0 * t) * exp(-t * 120.0)
				var t2 := maxf(0.0, t - 0.07)
				var b := sin(TAU * 2650.0 * t2) * exp(-t2 * 140.0) if t >= 0.07 else 0.0
				return (a + b * 0.7 + rng.randf_range(-1.0, 1.0) * 0.1 * exp(-t * 60.0)) * 0.22)
		&"shatter":
			samples = _render(0.9, func(t: float) -> float:
				var bits := 0.0
				for k in 3:
					bits += sin(TAU * (2200.0 + 900.0 * k) * t + k) * exp(-fmod(t + k * 0.13, 0.21) * 40.0)
				return (rng.randf_range(-1.0, 1.0) * exp(-t * 7.0) * 0.5 + bits * 0.18 * exp(-t * 3.0)) * 0.42)
		&"glass":
			samples = _render(1.4, func(t: float) -> float:
				var ring := sin(TAU * 1760.0 * t) * 0.4 + sin(TAU * 2793.0 * t) * 0.3 + sin(TAU * 4186.0 * t) * 0.2
				var crash := rng.randf_range(-1.0, 1.0) * exp(-t * 5.0)
				return (ring * exp(-t * 2.5) * 0.4 + crash * 0.6) * 0.42)
		&"tink":
			samples = _render(0.3, func(t: float) -> float:
				return (sin(TAU * 2350.0 * t) + sin(TAU * 3720.0 * t) * 0.4) * exp(-t * 26.0) * 0.26)
		&"oco":
			# Knocking on something hollow: a low, boxy boom that rings a bit.
			samples = _render(0.32, func(t: float) -> float:
				var body := sin(TAU * 140.0 * t) + sin(TAU * 212.0 * t) * 0.6
				var snap := rng.randf_range(-1.0, 1.0) * exp(-t * 200.0)
				return (body * exp(-t * 14.0) * 0.6 + snap * 0.4) * 0.4)
		&"crumble":
			var dust := 0.0
			samples = _render(1.0, func(t: float) -> float:
				dust = lerpf(dust, rng.randf_range(-1.0, 1.0), 0.4)
				var chunks := rng.randf_range(-1.0, 1.0) if rng.randf() < 0.02 * exp(-t * 2.0) else 0.0
				var crack := sin(TAU * 90.0 * t) * exp(-t * 18.0)
				return (dust * exp(-t * 3.5) * 0.5 + chunks * 0.6 + crack * 0.5) * 0.42)
		&"land":
			samples = _render(0.2, func(t: float) -> float:
				return (sin(TAU * 70.0 * t) * 0.7 + rng.randf_range(-1.0, 1.0) * 0.4) * exp(-t * 24.0) * 0.32)
		&"step_metal":
			samples = _render(0.18, func(t: float) -> float:
				var ring := sin(TAU * 820.0 * t) * 0.4 + sin(TAU * 1310.0 * t) * 0.25
				return (rng.randf_range(-1.0, 1.0) * 0.4 * exp(-t * 60.0) + ring * exp(-t * 22.0)) * 0.2)
		&"rung":
			samples = _render(0.12, func(t: float) -> float:
				return (sin(TAU * 240.0 * t) * 0.5 + rng.randf_range(-1.0, 1.0) * 0.4) * exp(-t * 45.0) * 0.2)
		&"ticks":
			# The Relojoaria Varela: seven clocks, none keeping the same time.
			var clocks := [[1.0, 0.0, 2600.0], [0.97, 0.21, 3100.0], [1.04, 0.47, 2200.0], [0.5, 0.33, 3400.0],
				[1.11, 0.72, 1900.0], [0.93, 0.86, 2800.0], [0.61, 0.12, 2450.0]]
			samples = _render(4.0, func(t: float) -> float:
				var v := rng.randf_range(-1.0, 1.0) * 0.004
				for c in clocks:
					var local := fmod(t + c[1], c[0])
					v += (sin(TAU * c[2] * local) * 0.7 + rng.randf_range(-1.0, 1.0) * 0.3) * exp(-local * 110.0) * 0.06
				return v)
		_:
			push_error("sfx_bank: unknown kind %s" % kind)
			return null
	return _to_wav(samples, kind in LOOPED)

static func _render(seconds: float, f: Callable) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		out[i] = f.call(float(i) / RATE)
	return out

static func _to_wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -0.5, 0.5) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = samples.size()
	return w

func _ready() -> void:
	ensure_buses()
	for k in KINDS:
		_streams[k] = make(k)
	for i in POOL_SIZE:
		var p := AudioStreamPlayer3D.new()
		p.unit_size = 4.0
		p.max_distance = 30.0
		add_child(p)
		_pool.append(p)

func stream(kind: StringName) -> AudioStreamWAV:
	return _streams.get(kind)

func ensure_buses() -> void:
	for bus in [&"Casa", &"Mundo"]:
		if AudioServer.get_bus_index(bus) >= 0:
			continue
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus)
		AudioServer.set_bus_send(idx, &"Master")

func play_at(kind: StringName, pos: Vector3, bus: StringName = &"Casa", volume_db := 0.0) -> void:
	if silent or not _streams.has(kind) or _pool.is_empty():
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stop()
	p.stream = _streams[kind]
	p.bus = bus
	p.volume_db = volume_db
	p.pitch_scale = randf_range(0.94, 1.06)
	p.global_position = pos
	p.play()

## Five strokes of a pencil. The double's writing (Task 12) uses the same rhythm.
func play_pencil_pattern(pos: Vector3) -> void:
	for delay in PENCIL_PATTERN:
		if delay <= 0.0:
			play_at(&"pencil", pos)
		else:
			get_tree().create_timer(delay).timeout.connect(play_at.bind(&"pencil", pos))

func set_casa_muted(muted: bool) -> void:
	var idx := AudioServer.get_bus_index(&"Casa")
	if idx >= 0:
		AudioServer.set_bus_mute(idx, muted)
