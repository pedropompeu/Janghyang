extends RefCounted
const Score = preload("res://scripts/score_model.gd")

func test_calm_house_plays_the_lullaby(t) -> void:
	var m: Dictionary = Score.mix(0.0, 0.0, false, 0.0, false)
	t.ok(m.lullaby > m.strings, "calm: lullaby over strings")
	t.ok(m.heart <= Score.SILENT + 0.1, "calm: no heartbeat")

func test_threat_brings_strings_and_heart(t) -> void:
	var calm: Dictionary = Score.mix(0.0, 0.0, false, 0.0, false)
	var near: Dictionary = Score.mix(0.0, 1.0, false, 0.0, false)
	t.ok(near.strings > calm.strings + 10.0, "strings swell")
	t.ok(near.heart > calm.heart + 10.0, "heart beats")
	t.ok(near.lullaby < calm.lullaby, "the lullaby recedes")

func test_pretending_is_memory(t) -> void:
	var m: Dictionary = Score.mix(0.0, 1.0, true, 0.0, false)
	t.ok(m.memory > m.lullaby and m.memory > m.strings, "eyes closed: the clean tune")

func test_hora_is_almost_silent(t) -> void:
	var m: Dictionary = Score.mix(0.0, 1.0, false, 1.0, true)
	t.ok(m.lullaby <= Score.SILENT + 0.1 and m.strings <= Score.SILENT + 0.1, "03:33 leaves room for the echoes")

func test_depth_lowers_the_drone(t) -> void:
	t.ok(Score.drone_hz(1.0) < Score.drone_hz(0.0), "deeper is lower")

func test_never_loud(t) -> void:
	for th in [0.0, 0.5, 1.0]:
		var m: Dictionary = Score.mix(1.0, th, false, 1.0, false)
		for k in m:
			t.ok(m[k] <= Score.CEILING, "layer %s under the ceiling" % k)

func test_lullaby_is_in_tune_with_itself(t) -> void:
	t.ok(Score.LULLABY.size() >= 16, "a real melody")
	t.near(Score.note_hz(0), Score.ROOT_HZ, 0.01, "root")
	t.near(Score.note_hz(12), Score.ROOT_HZ * 2.0, 0.01, "octave")
