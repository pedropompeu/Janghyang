extends RefCounted
const Sfx = preload("res://scripts/sfx_bank.gd")

func _peak(w: AudioStreamWAV) -> float:
	var d := w.data
	var peak := 0
	for i in range(0, d.size() - 1, 2):
		peak = maxi(peak, absi(d.decode_s16(i)))
	return peak / 32768.0

func test_every_kind_is_wav(t) -> void:
	for k in Sfx.KINDS:
		var w: AudioStreamWAV = Sfx.make(k)
		t.ok(w != null and w.data.size() > 0, "%s has data" % k)
		t.eq(w.format, AudioStreamWAV.FORMAT_16_BITS, "%s is 16-bit" % k)
		t.eq(w.loop_mode != AudioStreamWAV.LOOP_DISABLED, k in [&"rain", &"hum", &"breath", &"ticks", &"arrastar"], "%s loop flag" % k)

func test_no_loud_sting(t) -> void:
	for k in Sfx.KINDS:
		t.ok(_peak(Sfx.make(k)) <= 0.5, "%s peak <= 0.5" % k)

func test_deterministic(t) -> void:
	t.eq(Sfx.make(&"knock", 3).data, Sfx.make(&"knock", 3).data, "same seed, same sound")

func test_creak_and_swish_exist(t) -> void:
	t.ok(&"creak" in Sfx.KINDS, "the house can creak")
	t.ok(&"swish" in Sfx.KINDS, "the stick can cut the air")

func test_creak_is_a_slow_groan(t) -> void:
	var w: AudioStreamWAV = Sfx.make(&"creak")
	t.ok(w != null and w.data.size() / 2.0 / Sfx.RATE >= 0.6, "a creak lasts")

func test_swish_is_short_and_soft(t) -> void:
	var w: AudioStreamWAV = Sfx.make(&"swish")
	t.ok(w != null and w.data.size() / 2.0 / Sfx.RATE <= 0.25, "a swish is short")
	t.ok(w != null and _peak(w) <= 0.2, "a swish is soft")

func test_knock_is_wood_on_wood(t) -> void:
	var w: AudioStreamWAV = Sfx.make(&"knock")
	t.ok(w.data.size() / 2.0 / Sfx.RATE <= 0.15, "a stick tap is short and dry")

func test_new_world_sounds_exist(t) -> void:
	for k in [&"door", &"slam", &"porcelain", &"shatter", &"glass", &"tink", &"oco", &"crumble", &"land", &"step_metal", &"rung"]:
		t.ok(k in Sfx.KINDS, "%s is a sound" % k)

func test_door_groans_long_slam_is_short(t) -> void:
	var door: AudioStreamWAV = Sfx.make(&"door")
	var slam: AudioStreamWAV = Sfx.make(&"slam")
	t.ok(door.data.size() / 2.0 / Sfx.RATE >= 0.9, "a door hinge groans for a while")
	t.ok(slam.data.size() / 2.0 / Sfx.RATE <= 0.6, "a slam is over fast")
	t.ok(_peak(slam) > _peak(Sfx.make(&"knock")), "a slam is louder than a knock")

func test_porcelain_is_a_small_dry_tick(t) -> void:
	var w: AudioStreamWAV = Sfx.make(&"porcelain")
	t.ok(w.data.size() / 2.0 / Sfx.RATE <= 0.4, "porcelain settling is short")

func test_the_shop_ticks_out_of_step(t) -> void:
	t.ok(&"ticks" in Sfx.KINDS, "the shop's clocks are a sound")
	var w: AudioStreamWAV = Sfx.make(&"ticks")
	t.ok(w != null and w.loop_mode != AudioStreamWAV.LOOP_DISABLED, "the shop never stops ticking")
	t.ok(w != null and w.data.size() / 2.0 / Sfx.RATE >= 3.0, "long enough not to be heard looping")
	# Onsets: 5 ms windows that wake up after silence, relative to the peak.
	var d := w.data
	var peak := _peak(w)
	var win := int(Sfx.RATE * 0.005)
	var onsets: Array[float] = []
	var was_quiet := true
	for start in range(0, d.size() / 2 - win, win):
		var e := 0.0
		for i in win:
			e = maxf(e, absf(d.decode_s16((start + i) * 2) / 32768.0))
		if e > peak * 0.4 and was_quiet:
			onsets.append(float(start) / Sfx.RATE)
		was_quiet = e < peak * 0.15
	t.ok(onsets.size() >= 12, "many clocks, not one (%d onsets)" % onsets.size())
	var gaps: Array[float] = []
	for i in range(1, onsets.size()):
		gaps.append(onsets[i] - onsets[i - 1])
	var lo := 99.0
	var hi := 0.0
	for g in gaps:
		lo = minf(lo, g)
		hi = maxf(hi, g)
	t.ok(hi - lo > 0.1, "they do not agree with each other")

## A-007: every loop the house starts is silenced before the game exits. The
## unit runner has no scene tree yet, so playback cannot be observed here: the
## probe records the stop() call instead. The real silence is checked by the
## headful exit gate.
class StopProbe extends Node:
	var stops := 0
	func stop() -> void:
		stops += 1

func test_stop_all_silences_loops(t) -> void:
	var bank = Sfx.new()
	bank.silent = false
	var loop := StopProbe.new()
	bank.register_loop(loop)
	bank.stop_all()
	t.eq(loop.stops, 1, "stop_all stops the registered loop")
	t.ok(bank.silent, "nothing new sounds after stop_all")
	loop.free()
	bank.free()

func test_the_crack_is_a_small_give(t) -> void:
	var w := Sfx.make(&"crack")
	t.ok(w != null and _peak(w) <= 0.45, "o estalo da luta fica abaixo de 0,45")
