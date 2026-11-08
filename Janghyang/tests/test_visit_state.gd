extends RefCounted
const Visit = preload("res://scripts/visit_state.gd")
const WindClock = preload("res://scripts/wind_clock_model.gd")
const Catalog = preload("res://scripts/catalog.gd")

const HORA_RUN := int(Visit.HARD_LIMIT) + 2

func _new() -> Visit:
	return Visit.new(WindClock.new(), Catalog.new())

func _run(v, seconds: int, in_bedroom := false) -> StringName:
	for i in seconds:
		var ev: StringName = v.update(1.0, in_bedroom)
		if ev != &"":
			return ev
	return &""

func test_acts_advance(t) -> void:
	var v := _new()
	t.eq(v.act, Visit.Act.CHEGADA, "starts at arrival")
	v.catalog.catalog(&"bola"); v.on_cataloged(&"bola")
	t.eq(v.act, Visit.Act.BRINCAR, "first catalog -> play")
	v.update(1.0, true)
	t.eq(v.act, Visit.Act.DUPLO, "bedroom -> double")

func test_no_hora_before_gate(t) -> void:
	var v := _new()
	t.eq(_run(v, 1100), &"", "clock stalls instead of stopping before the gate")
	t.ok(v.clock.spring >= WindClock.STALL_SPRING - 0.001, "spring stalled")

func test_pieces_gate(t) -> void:
	var v := _new()
	v.on_pieces_ready()
	t.ok(v.clock.spring <= Visit.HURRY_SPRING + 0.001, "the four pieces hurry the clock")
	t.eq(_run(v, 60), &"hora_started", "03:33 follows the pieces")

func test_catalog_alone_no_longer_opens_the_gate(t) -> void:
	var v := _new()
	v.catalog.set_flag(&"doll_sat", true)
	for id in [&"boneco", &"bola", &"vela", &"cama", &"casaco", &"espelho"]:
		v.catalog.catalog(id); v.on_cataloged(id)
	t.eq(_run(v, 1500), &"", "doll and items without the pieces: no 03:33 yet")

func test_time_limit_is_an_hour(t) -> void:
	t.ok(Visit.MAX_PRE_HORA >= 3600.0, "the safety limit waits an hour")
	t.ok(Visit.HARD_LIMIT > Visit.MAX_PRE_HORA, "hard limit after the safety limit")

func test_time_gate_without_doll(t) -> void:
	var v := _new()
	var limit := int(Visit.MAX_PRE_HORA + Visit.HURRY_SPRING / Visit.DRAIN_CALM) + 1
	t.eq(_run(v, limit), &"hora_started", "03:33 by time with nothing cataloged")

func test_wind_spam_cannot_prevent_hora(t) -> void:
	var v := _new()
	var got := &""
	for i in int(Visit.HARD_LIMIT) + 2:
		v.clock.wind(); v.on_wind()
		got = v.update(1.0, false)
		if got != &"":
			break
	t.eq(got, &"hora_started", "03:33 arrives by HARD_LIMIT even when winding every second")
	t.ok(v.elapsed <= Visit.HARD_LIMIT + 1.0, "no later than HARD_LIMIT")

func test_hora_ends_on_wind_and_never_returns(t) -> void:
	var v := _new()
	_run(v, HORA_RUN)
	t.eq(v.act, Visit.Act.HORA, "in hora")
	t.ok(not v.recording_enabled(), "no recording during hora")
	v.clock.wind()
	t.eq(v.on_wind(), &"hora_ended", "wind ends hora")
	t.eq(v.act, Visit.Act.DEPOIS, "after hora")
	t.ok(v.recording_enabled(), "recording resumes")
	t.eq(_run(v, 8000), &"", "there is no second 03:33")

func test_exit_outcomes(t) -> void:
	var v := _new()
	t.eq(v.on_exit(), &"incompleto", "exit before choice")
	var a := _new(); _run(a, HORA_RUN); a.clock.wind(); a.on_wind()
	a.catalog.set_flag(&"after_hora", true); a.catalog.catalog(&"pagina_cabana"); a.on_cataloged(&"pagina_cabana")
	t.eq(a.act, Visit.Act.ESCOLHA, "cabana page opens the choice")
	t.ok(a.clock.spring <= Visit.ESCOLHA_SPRING + 0.001, "clock is almost unwound at the choice")
	t.eq(a.on_exit(), &"parar", "leave without winding")
	var b := _new(); _run(b, HORA_RUN); b.clock.wind(); b.on_wind()
	b.catalog.set_flag(&"after_hora", true); b.catalog.catalog(&"pagina_cabana"); b.on_cataloged(&"pagina_cabana")
	b.clock.wind(); b.on_wind()
	t.eq(b.on_exit(), &"corda", "wind then leave")

func test_clock_keeps_running_after_exit(t) -> void:
	var v := _new()
	v.on_exit()
	var before: float = v.clock.spring
	v.update(10.0, false)
	t.ok(v.clock.spring < before, "leaving early: the clock keeps its wind and runs down")

## U32 (Review Focus 2): a visit that skips every phase (no pieces, nothing
## cataloged) reaches 03:33 only through the hour: the gate stays shut before
## 3600 s and opens at 3600 s.
func test_skipping_phases_reaches_the_hour_only_by_time(t) -> void:
	var v := _new()
	t.eq(_run(v, 3599), &"", "no 03:33 before the hour with nothing done")
	t.ok(not v.clock.can_stop, "the gate is still shut at 3599 s")
	v.update(1.0, false)
	t.ok(v.clock.can_stop, "the gate opens at 3600 s")

## U32: the pieces open the gate at once, with no time passed.
func test_pieces_open_the_gate_at_once(t) -> void:
	var v := _new()
	v.on_pieces_ready()
	t.eq(v.elapsed, 0.0, "no time has passed")
	t.ok(v.clock.can_stop, "the pieces open the gate at once")

## U37 (spec 6.7 / relojoeiro line 134): leaving before the third fragment is
## incompleto, and the exit itself leaves the rope as it was. The spring starts
## at its cap, so it is set lower first: a wind would then show.
func test_leaving_before_fragment_three_keeps_the_rope(t) -> void:
	var v := _new()
	v.clock.spring = 100.0
	t.eq(v.on_exit(), &"incompleto", "leaving before the third fragment is incompleto")
	t.eq(v.clock.spring, 100.0, "the exit does not change the spring")
	t.eq(v.clock.winds, 0, "the exit does not wind the clock")

# --- Tarefa 11: the state of one night and the short 03:33 ---
const Noites = preload("res://scripts/story/noites.gd")

func _night(n: int) -> Visit:
	return Visit.new(WindClock.new(), Catalog.new(), Noites.get_night(n))

func test_an_empty_night_is_todays_visit(t) -> void:
	t.ok(not _new().is_short(), "sem noite, o 03:33 é o completo de hoje")
	t.ok(_night(1).is_short() and not _night(5).is_short(), "só a noite final tem o 03:33 completo")

## U32 adapted: a night where nothing is done reaches 03:33 only by time.
func test_night_skipping_goals_reaches_the_hour_only_by_time(t) -> void:
	var v := _night(1)
	v.on_ground_floor(true)
	t.eq(_run(v, 3599), &"", "nada feito: sem 03:33 antes da hora")
	t.ok(not v.clock.can_stop, "o gate segue fechado aos 3599 s")
	v.update(1.0, false)
	t.ok(v.clock.can_stop, "o gate abre aos 3600 s")

func test_final_night_pieces_open_the_gate_at_once(t) -> void:
	var v := _night(5)
	v.on_pieces_ready()
	t.ok(v.clock.can_stop, "noite final: as peças abrem o gate sem esperar")

func test_pieces_do_not_open_a_short_night(t) -> void:
	var v := _night(4)
	v.on_ground_floor(true)
	v.on_pieces_ready()
	t.ok(not v.clock.can_stop, "fora da noite final, as peças não abrem o gate")

func test_goals_on_a_final_night_are_not_the_gate(t) -> void:
	var v := _night(5)
	v.on_ground_floor(true)
	v.on_goals_met()
	t.ok(not v.clock.can_stop, "na noite final o gate é o de hoje, não as metas")

func test_goals_met_on_ground_floor_opens_at_once(t) -> void:
	var v := _night(1)
	v.on_ground_floor(true)
	v.on_goals_met()
	v.update(1.0, false)
	t.ok(v.clock.can_stop, "metas cumpridas no térreo: gate aberto no mesmo update")
	t.eq(_run(v, 120), &"hora_started", "e o 03:33 vem logo")

func test_goals_met_away_waits_for_the_ground_floor(t) -> void:
	var v := _night(2)
	v.on_ground_floor(false)
	v.on_goals_met()
	t.eq(_run(v, 120), &"", "longe do térreo, o 03:33 espera")
	t.ok(not v.clock.can_stop, "gate fechado no sótão")
	v.on_ground_floor(true)
	t.ok(v.clock.can_stop, "de volta ao térreo, abre")
	v.on_ground_floor(false)
	t.ok(v.clock.can_stop, "aberto, não fecha mais")

func test_hard_limit_waits_for_the_capture(t) -> void:
	var v := _night(1)
	var early := &""
	for i in int(Visit.HARD_LIMIT) + 5:
		var e: StringName = v.update(1.0, false, true)
		if e != &"":
			early = e
	t.eq(early, &"", "agarrado, nada começa")
	t.ok(v.elapsed > Visit.HARD_LIMIT and v.act < Visit.Act.HORA, "passou do limite agarrado, e o 03:33 esperou")
	t.eq(v.update(1.0, false, false), &"hora_started", "solto, o 03:33 começa")
	t.eq(_run(v, 5), &"", "uma vez só")

func test_capture_holds_the_open_gate_too(t) -> void:
	var v := _night(1)
	v.on_ground_floor(true)
	v.on_goals_met()
	var ev := &""
	for i in 120:
		var e: StringName = v.update(1.0, false, true)
		if e != &"":
			ev = e
	t.eq(ev, &"", "com o gate aberto, o 03:33 não começa com Elias agarrado")
	t.eq(_run(v, 120), &"hora_started", "e começa depois que ele se solta")

func test_short_hour_ends_by_itself(t) -> void:
	var v := _night(1)
	v.on_ground_floor(true)
	v.on_goals_met()
	t.eq(_run(v, 120), &"hora_started", "o 03:33 curto começa")
	var seen := []
	for i in int(Visit.SHORT_HOUR) + 5:
		var e: StringName = v.update(1.0, false)
		if e != &"":
			seen.append([i + 1, e])
	t.eq(seen, [[int(Visit.SHORT_HOUR), &"night_over"]], "aos 90 s sem corda, a noite acaba, uma vez")

func test_short_hour_ends_on_wind(t) -> void:
	var v := _night(2)
	v.on_ground_floor(true)
	v.on_goals_met()
	_run(v, 120)
	t.eq(v.act, Visit.Act.HORA, "no 03:33 curto")
	t.eq(v.on_wind(), &"night_over", "dar corda acaba a noite")
	t.eq(_run(v, int(Visit.SHORT_HOUR) + 5), &"", "e ela não acaba de novo")
	t.eq(v.on_wind(), &"", "nem com outra corda")

func test_the_full_hour_is_unchanged_on_the_final_night(t) -> void:
	var v := _night(5)
	v.on_pieces_ready()
	t.eq(_run(v, 120), &"hora_started", "o 03:33 completo começa")
	t.eq(_run(v, int(Visit.SHORT_HOUR) + 30), &"", "e não acaba sozinho aos 90 s")
	t.eq(v.on_wind(), &"hora_ended", "acaba na corda, como hoje")
