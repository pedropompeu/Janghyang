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

# --- Noite 1, Tarefa 5: sustos de roteiro e tipos novos ---

const NEW_KINDS := [&"bola_quica", &"olho_fresta", &"figura_painel", &"reflexo_fica", &"figura_some", &"catalogo_muda"]

func test_new_kinds_are_known(t) -> void:
	for k in NEW_KINDS:
		t.ok(Director.KINDS.has(k), "%s é um tipo de susto" % k)

func test_force_passes_cold(t) -> void:
	var d = Director.new()
	d.new_night()
	t.ok(d.force(&"bola_quica"), "de roteiro passa sem silêncio nem tensão")

func test_force_refused_in_the_hour(t) -> void:
	var d = Director.new()
	d.set_hour(true)
	t.ok(not d.force(&"bola_quica"), "no 03:33, nem o de roteiro")
	d.set_hour(false)
	t.ok(d.force(&"bola_quica"), "recusado na hora, não ficou usado")

func test_force_only_once(t) -> void:
	var d = Director.new()
	t.ok(d.force(&"figura_painel"), "a primeira vez")
	t.ok(not d.force(&"figura_painel"), "a segunda não, na mesma noite")
	t.ok(not d.force(&"grito"), "tipo desconhecido, não")

func test_force_makes_room(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	t.ok(d.force(&"bola_quica"), "o de roteiro")
	t.ok(not d.request(&"pose", false, 1.0), "logo depois, nenhum fraco")
	d.update(Director.WEAK_GAP, false)
	t.ok(d.request(&"pose", false, 1.0), "depois de WEAK_GAP, o fraco passa")
	t.ok(not d.request(&"olho_fresta", true, 1.0), "o forte ainda espera")
	d.update(Director.STRONG_GAP, false)
	t.ok(d.request(&"olho_fresta", true, 1.0), "depois de STRONG_GAP, o forte passa")

func test_strong_new_kinds_once_weak_ones_repeat(t) -> void:
	var d = Director.new()
	_quiet(d, 100.0)
	t.ok(d.request(&"olho_fresta", true, 1.0), "o olho na fresta uma vez")
	_quiet(d, 100.0)
	t.ok(not d.request(&"olho_fresta", true, 1.0), "não volta na noite")
	t.ok(d.request(&"figura_some", false, 0.5), "a figura some (fraco)")
	_quiet(d, Director.WEAK_GAP + Director.QUIET_BEFORE)
	t.ok(d.request(&"figura_some", false, 0.5), "e pode sumir de novo")

func test_muted_kind_is_refused_but_force_passes(t) -> void:
	var d = Director.new()
	d.muted.assign([&"lanterna_pisca"])
	_quiet(d, 100.0)
	t.ok(not d.request(&"lanterna_pisca", true, 1.0), "mudo, o pedido é negado")
	t.ok(d.force(&"lanterna_pisca"), "mas o roteiro passa (e não estava usado)")

func test_max_db_is_the_rule(t) -> void:
	t.eq(Director.MAX_DB, 0.0, "MAX_DB 0 dB")
	t.eq(Director.PEAK, 0.5, "PEAK 0,5")

func test_new_sounds_are_clipped(t) -> void:
	for kind in [&"interruptor", &"quique", &"arrastar", &"caixa_frase", &"madeira"]:
		t.ok(SfxBank.KINDS.has(kind), "%s está no banco" % kind)
		var w: AudioStreamWAV = SfxBank.make(kind, 1) if SfxBank.KINDS.has(kind) else null
		t.ok(w != null and w.data.size() > 0, "%s tem amostras" % kind)
		if w == null:
			continue
		var peak := 0
		for i in range(0, w.data.size(), 2):
			peak = maxi(peak, absi(w.data.decode_s16(i)))
		t.ok(peak <= int(Director.PEAK * 32767.0) + 1, "%s não passa do pico 0,5" % kind)
		t.eq(SfxBank.make(kind, 1).data, w.data, "%s: mesma semente, mesmo som" % kind)
