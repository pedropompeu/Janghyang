extends RefCounted
const Director = preload("res://scripts/scare_director.gd")
const SfxBank = preload("res://scripts/sfx_bank.gd")

func _quiet(d, seconds: float) -> void:
	d.update(seconds, false)

func test_one_strong_scare_per_minute(t) -> void:
	var d = Director.new()
	_quiet(d, Director.QUIET_BEFORE + 0.1)
	t.ok(d.request(&"pancadas", true, 0.9), "o primeiro forte passa")
	_quiet(d, 59.0)
	t.ok(not d.request(&"duplo_espelho", true, 0.9), "aos 59 s, outro forte é negado")
	_quiet(d, 2.0)
	t.ok(d.request(&"duplo_espelho", true, 0.9), "aos 61 s, passa")

func test_needs_quiet_before(t) -> void:
	var d = Director.new()
	d.update(30.0, true)
	t.ok(not d.request(&"lampada", false, 0.5), "logo depois de barulho, não")
	_quiet(d, Director.QUIET_BEFORE - 0.5)
	t.ok(not d.request(&"lampada", false, 0.5), "7,5 s de silêncio não bastam")
	_quiet(d, 1.0)
	t.ok(d.request(&"lampada", false, 0.5), "8 s de silêncio, passa")
	_quiet(d, Director.WEAK_GAP - 1.0)
	t.ok(not d.request(&"lampada", false, 0.5), "dois fracos, só com 20 s entre eles")
	_quiet(d, 2.0)
	t.ok(d.request(&"lampada", false, 0.5), "depois de 20 s, passa")

func test_a_scare_counts_as_noise(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	t.ok(d.request(&"lampada", false, 0.5), "um fraco")
	_quiet(d, 1.0)
	t.ok(not d.request(&"pancadas", true, 0.9), "o próprio susto quebra o silêncio")

func test_never_during_the_hour(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	d.set_hour(true)
	t.ok(not d.request(&"lampada", false, 0.5), "fraco não, no 03:33")
	t.ok(not d.request(&"pancadas", true, 0.9), "forte também não")
	d.set_hour(false)
	t.ok(d.request(&"pancadas", true, 0.9), "depois da hora, volta")

func test_same_strong_kind_once_per_night(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	t.ok(d.request(&"caixa_musica", true, 0.9), "a caixa de música uma vez")
	_quiet(d, 100.0)
	t.ok(not d.request(&"caixa_musica", true, 0.9), "a mesma não volta na noite")
	t.ok(d.request(&"pancadas", true, 0.9), "outro tipo passa")
	_quiet(d, 100.0)
	t.ok(d.request(&"lampada", false, 0.5), "fraco pode repetir")
	_quiet(d, 100.0)
	t.ok(d.request(&"lampada", false, 0.5), "fraco de novo")
	d.new_night()
	_quiet(d, 100.0)
	t.ok(d.request(&"caixa_musica", true, 0.9), "noite nova, a caixa volta")

func test_strong_scares_wait_for_tension(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	t.ok(not d.request(&"pancadas", true, Director.STRONG_TENSION - 0.05), "pouca tensão, nada de forte")
	t.ok(d.request(&"pancadas", true, Director.STRONG_TENSION), "com tensão, passa")

func test_unknown_kinds_are_refused(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	t.ok(not d.request(&"grito", false, 0.5), "tipo fora da lista")

func test_no_scare_past_the_bank_peak(t) -> void:
	t.ok(Director.MAX_DB <= 0.0, "nenhum susto toca acima de 0 dB")
	for kind in [&"creak", &"knock", &"slam", &"shatter"]:
		var w: AudioStreamWAV = SfxBank.make(kind)
		var peak := 0
		for i in range(0, w.data.size(), 2):
			peak = maxi(peak, absi(w.data.decode_s16(i)))
		t.ok(peak <= int(Director.PEAK * 32767.0) + 1, "%s não passa do pico 0,5" % kind)
