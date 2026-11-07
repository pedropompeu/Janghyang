extends RefCounted
const Dread = preload("res://scripts/dread_model.gd")
const Visit = preload("res://scripts/visit_state.gd")

func test_tension_starts_low(t) -> void:
	t.ok(Dread.tension(Visit.Act.CHEGADA, 0.0) < 0.25, "arrival is calm")

func test_tension_rises_with_the_clock(t) -> void:
	var early: float = Dread.tension(Visit.Act.BRINCAR, 3.0)
	var late: float = Dread.tension(Visit.Act.BRINCAR, 30.0)
	t.ok(late > early + 0.3, "the clock running down raises the dread")

func test_bedroom_adds_tension(t) -> void:
	t.ok(Dread.tension(Visit.Act.DUPLO, 10.0) > Dread.tension(Visit.Act.BRINCAR, 10.0), "after the bedroom it is worse")

func test_hour_is_the_peak(t) -> void:
	t.eq(Dread.tension(Visit.Act.HORA, 33.0), 1.0, "03:33 is the peak")
	for act in [Visit.Act.CHEGADA, Visit.Act.BRINCAR, Visit.Act.DUPLO, Visit.Act.DEPOIS, Visit.Act.ESCOLHA]:
		t.ok(Dread.tension(act, 33.0) < 1.0, "only 03:33 reaches the peak (act %d)" % act)

func test_after_the_hour_stays_uneasy(t) -> void:
	var after: float = Dread.tension(Visit.Act.DEPOIS, 0.0)
	t.ok(after > 0.6 and after < 1.0, "after 03:33 it stays uneasy")
	t.ok(Dread.tension(Visit.Act.ESCOLHA, 0.0) > after, "the choice is tenser than the aftermath")

func test_leaving_lets_go(t) -> void:
	t.eq(Dread.tension(Visit.Act.FIM, 20.0), 0.0, "once Elias leaves the house lets go")

func test_tension_is_clamped(t) -> void:
	for act in Visit.Act.values():
		for m in [-5.0, 0.0, 16.0, 33.0, 80.0]:
			var v: float = Dread.tension(act, m)
			t.ok(v >= 0.0 and v <= 1.0, "tension in 0..1 (act %d, %.0f min)" % [act, m])

func test_lights_sink_but_never_go_out(t) -> void:
	t.ok(Dread.light_scale(1.0) < Dread.light_scale(0.0), "dread dims the house")
	t.ok(Dread.light_scale(1.0) >= 0.3, "the house never goes fully dark")
	t.ok(Dread.light_scale(0.0) <= 1.0, "never brighter than built")

func test_fog_thickens(t) -> void:
	t.ok(Dread.fog_density(1.0) > Dread.fog_density(0.0) * 2.0, "fog thickens with dread")

func test_ambient_drops(t) -> void:
	t.ok(Dread.ambient_energy(1.0) < Dread.ambient_energy(0.0), "ambient light drops")

func test_breath_quickens_but_stays_quiet(t) -> void:
	t.ok(Dread.breath_pitch(1.0) > Dread.breath_pitch(0.0), "breath quickens")
	t.ok(Dread.breath_db(1.0) > Dread.breath_db(0.0), "breath grows")
	t.ok(Dread.breath_db(1.0) <= -12.0, "breath never becomes a sting")

func test_hum_grows_but_stays_low(t) -> void:
	t.ok(Dread.hum_db(1.0) > Dread.hum_db(0.0), "the house hums louder")
	t.ok(Dread.hum_db(1.0) <= -18.0, "the hum stays under everything")

func test_vignette_closes_in(t) -> void:
	t.ok(Dread.vignette(1.0) > Dread.vignette(0.0), "the edges close in")
	t.ok(Dread.vignette(1.0) < 0.9, "the centre always stays readable")

func test_hands_tremble_only_when_afraid(t) -> void:
	t.eq(Dread.hand_tremor(0.0), 0.0, "calm hands are still")
	t.ok(Dread.hand_tremor(1.0) > 0.0 and Dread.hand_tremor(1.0) < 0.01, "afraid hands tremble, a little")

func test_creaks_come_more_often(t) -> void:
	t.ok(Dread.creak_delay(1.0, 0.5) < Dread.creak_delay(0.0, 0.5), "dread brings creaks closer together")
	t.ok(Dread.creak_delay(1.0, 0.0) >= 6.0, "never a barrage of creaks")
	t.ok(Dread.creak_delay(0.5, 0.0) < Dread.creak_delay(0.5, 0.99), "jitter spreads the creaks")

func test_flicker_only_once_uneasy(t) -> void:
	t.eq(Dread.flicker_delay(0.1, 0.5), INF, "a calm house does not flicker")
	t.ok(Dread.flicker_delay(1.0, 0.5) < Dread.flicker_delay(0.5, 0.5), "dread flickers more often")
	t.ok(Dread.flicker_delay(1.0, 0.0) >= 8.0, "flickers stay rare")

func test_creak_point_is_far(t) -> void:
	var points := [Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(9, 0, 0), Vector3(0, 0, 12)]
	for r in [0.0, 0.3, 0.6, 0.99]:
		var i: int = Dread.creak_point(points, Vector3(1, 0.2, 0), r)
		t.ok(i == 2 or i == 3, "creak comes from a far room (r %.2f got %d)" % [r, i])

func test_creak_point_ignores_height(t) -> void:
	var points := [Vector3(1, 2.6, 0)]
	t.eq(Dread.creak_point(points, Vector3(1, 0.2, 0), 0.5), -1, "a creak right overhead is too close")

func test_no_far_point_no_creak(t) -> void:
	t.eq(Dread.creak_point([Vector3(1, 0, 1)], Vector3(0, 0, 0), 0.5), -1, "no far point, no creak")
