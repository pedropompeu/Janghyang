extends RefCounted
const Score = preload("res://scripts/score.gd")
const Sfx = preload("res://scripts/sfx_bank.gd")

func _peak(w: AudioStreamWAV) -> float:
	var d := w.data
	var peak := 0
	for i in range(0, d.size() - 1, 2):
		peak = maxi(peak, absi(d.decode_s16(i)))
	return peak / 32768.0

func test_every_layer_loops_and_stays_soft(t) -> void:
	for layer in Score.LAYERS:
		var w: AudioStreamWAV = Score.render(layer)
		t.ok(w != null and w.data.size() > 0, "%s has sound" % layer)
		if w == null:
			continue
		t.ok(w.loop_mode == AudioStreamWAV.LOOP_FORWARD, "%s loops" % layer)
		t.ok(_peak(w) <= 0.5, "%s never stings" % layer)

func test_lullaby_is_the_whole_tune(t) -> void:
	var w: AudioStreamWAV = Score.render(&"lullaby")
	var beats := 0.0
	for n in Score.ScoreModel.LULLABY:
		beats += n.y
	var secs := w.data.size() / 2.0 / w.mix_rate
	t.near(secs, beats * Score.BEAT + Score.TAIL, 0.1, "the tune plays out once per loop")

func test_memory_is_major(t) -> void:
	t.eq(Score.to_major(3), 4.0, "minor third becomes major")
	t.eq(Score.to_major(8), 9.0, "minor sixth becomes major")
	t.eq(Score.to_major(7), 7.0, "fifth stays")

func test_lullaby_drops_notes_memory_does_not(t) -> void:
	var dropped := 0
	for i in Score.ScoreModel.LULLABY.size():
		if Score.missing(i):
			dropped += 1
	t.ok(dropped >= 2 and dropped <= 5, "a few notes are missing from the box (%d)" % dropped)
