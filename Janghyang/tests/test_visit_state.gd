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
