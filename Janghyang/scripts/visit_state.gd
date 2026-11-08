extends RefCounted
## One night as acts, driving the entrance clock. On the final night (or
## with no night, as before the nights) the 03:33 gate opens once the four
## pieces of the pocket watch are together; on the other nights it opens once
## the night's goals are met and Elias is on the ground floor. Either way it
## also opens on time (an hour); winding only postpones it, and it happens
## once. The short 03:33 of nights 1 to 4 ends on a wind or after SHORT_HOUR.
## While Elias is held by a Gasto, nothing starts. Leaving is always possible
## and only reads where the visit is. A new night makes a new VisitState.

enum Act { CHEGADA, BRINCAR, DUPLO, HORA, DEPOIS, ESCOLHA, FIM }

const HURRY_SPRING := 20.0
const MAX_PRE_HORA := 3600.0
const HARD_LIMIT := 3780.0
const ESCOLHA_SPRING := 30.0
const DRAIN_CALM := 0.45
const DRAIN_DUPLO := 0.9
## How long the short 03:33 lasts when nobody winds the clock.
const SHORT_HOUR := 90.0

var act: int = Act.CHEGADA
var elapsed := 0.0
var wound_since_escolha := false
var clock
var catalog
var pieces_ready := false
var goals_met := false
var on_ground := false
## The night from scripts/story/noites.gd; empty means today's single visit.
var night: Dictionary
var hour_elapsed := 0.0
var _gate_open := false

func _init(clock_model, catalog_model, night_data := {}) -> void:
	clock = clock_model
	catalog = catalog_model
	night = night_data
	clock.drain_rate = DRAIN_CALM

## True on nights 1 to 4: a short 03:33, no choice.
func is_short() -> bool:
	return not night.get("final", true)

## Advance the night. Returns &"hora_started" on the tick the clock stops and,
## on a short night, &"night_over" when the short 03:33 runs out. `holding` is
## true while a Gasto holds Elias: the gate and the time limit wait for it.
func update(dt: float, in_bedroom: bool, holding := false) -> StringName:
	if act == Act.FIM:
		# After the exit the clock runs on what it had (or stays stopped).
		clock.tick(dt)
		return &""
	elapsed += dt
	if holding and act < Act.HORA:
		return &""
	if in_bedroom and act < Act.DUPLO:
		act = Act.DUPLO
	clock.drain_rate = DRAIN_DUPLO if act == Act.DUPLO else DRAIN_CALM
	if act == Act.HORA and is_short():
		hour_elapsed += dt
		if hour_elapsed >= SHORT_HOUR:
			return _end_night()
	if act < Act.HORA:
		_check_gate()
		if elapsed >= HARD_LIMIT:
			clock.force_stop()
			act = Act.HORA
			return &"hora_started"
	var stopped: bool = clock.tick(dt)
	if stopped and act < Act.HORA:
		act = Act.HORA
		return &"hora_started"
	return &""

func on_cataloged(item: StringName) -> void:
	if act == Act.CHEGADA:
		act = Act.BRINCAR
	if item == &"pagina_cabana" and act == Act.DEPOIS:
		act = Act.ESCOLHA
		clock.clamp_spring(ESCOLHA_SPRING)
	if act < Act.HORA:
		_check_gate()

## The pocket watch is whole: on the final night the clock may now run out.
func on_pieces_ready() -> void:
	pieces_ready = true
	if act < Act.HORA:
		_check_gate()

## The night's last goal is struck: on a short night, the 03:33 waits only for
## Elias to be on the ground floor.
func on_goals_met() -> void:
	goals_met = true
	if act < Act.HORA:
		_check_gate()

## Whether Elias is on the ground floor of the house now.
func on_ground_floor(on: bool) -> void:
	on_ground = on
	if act < Act.HORA:
		_check_gate()

## Call after the clock was wound. Returns &"hora_ended" when it ends the full
## 03:33, &"night_over" when it ends a short one.
func on_wind() -> StringName:
	if act == Act.HORA and is_short():
		return _end_night()
	if act == Act.HORA:
		act = Act.DEPOIS
		clock.can_stop = false
		return &"hora_ended"
	if act == Act.ESCOLHA:
		wound_since_escolha = true
	return &""

## The tampo edge. Only the first call counts.
func on_exit() -> StringName:
	if act == Act.FIM:
		return &""
	var before: int = act
	act = Act.FIM
	if before < Act.ESCOLHA:
		return &"incompleto"
	return &"corda" if wound_since_escolha else &"parar"

func recording_enabled() -> bool:
	return act != Act.HORA and act != Act.FIM

func _check_gate() -> void:
	if _gate_open:
		return
	var ready := (goals_met and on_ground) if is_short() else pieces_ready
	if ready or elapsed >= MAX_PRE_HORA:
		_gate_open = true
		clock.can_stop = true
		clock.clamp_spring(HURRY_SPRING)

func _end_night() -> StringName:
	act = Act.FIM
	clock.can_stop = false
	return &"night_over"
