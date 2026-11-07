extends RefCounted
## The visit as acts, driving the entrance clock. The 03:33 gate opens once
## the four pieces of the pocket watch are together, or on time (an hour);
## winding only postpones it, and it happens once. Leaving is always possible and only reads where the visit is.

enum Act { CHEGADA, BRINCAR, DUPLO, HORA, DEPOIS, ESCOLHA, FIM }

const HURRY_SPRING := 20.0
const MAX_PRE_HORA := 3600.0
const HARD_LIMIT := 3780.0
const ESCOLHA_SPRING := 30.0
const DRAIN_CALM := 0.45
const DRAIN_DUPLO := 0.9

var act: int = Act.CHEGADA
var elapsed := 0.0
var wound_since_escolha := false
var clock
var catalog
var pieces_ready := false
var _gate_open := false

func _init(clock_model, catalog_model) -> void:
	clock = clock_model
	catalog = catalog_model
	clock.drain_rate = DRAIN_CALM

## Advance the visit. Returns &"hora_started" on the tick the clock stops.
func update(dt: float, in_bedroom: bool) -> StringName:
	if act == Act.FIM:
		# After the exit the clock runs on what it had (or stays stopped).
		clock.tick(dt)
		return &""
	elapsed += dt
	if in_bedroom and act < Act.DUPLO:
		act = Act.DUPLO
	clock.drain_rate = DRAIN_DUPLO if act == Act.DUPLO else DRAIN_CALM
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

## The pocket watch is whole: the clock may now run out.
func on_pieces_ready() -> void:
	pieces_ready = true
	if act < Act.HORA:
		_check_gate()

## Call after the clock was wound. Returns &"hora_ended" when it ends the 03:33.
func on_wind() -> StringName:
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
	if pieces_ready or elapsed >= MAX_PRE_HORA:
		_gate_open = true
		clock.can_stop = true
		clock.clamp_spring(HURRY_SPRING)
