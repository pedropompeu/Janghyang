extends RefCounted
## Who decides when the house may frighten Elias (spec §13, the scares):
## every scare asks first. A strong one needs a minute since the last strong
## one, enough tension, and a kind not yet used tonight; a weak one needs
## WEAK_GAP since the last weak one. Any scare needs QUIET_BEFORE seconds of
## quiet before it (and is itself noise), and none comes during 03:33.
## A scripted scare (force) skips tension and quiet, once a night, and makes
## room after it. A night may mute kinds it scripts itself (muted).
## Nothing here plays louder than the bank's peak (regra de Pedro, 2026-11-10:
## no volume bursts).

const STRONG_GAP := 60.0
const WEAK_GAP := 20.0
const QUIET_BEFORE := 8.0
## The least tension for a strong scare.
const STRONG_TENSION := 0.6
## sfx_bank.gd clips every sample at this; scares play at MAX_DB at most.
const PEAK := 0.5
const MAX_DB := 0.0
const KINDS := [&"lampada", &"pose", &"caixa_musica", &"tique_para", &"duplo_espelho", &"pancadas", &"lanterna_pisca",
	&"bola_quica", &"olho_fresta", &"figura_painel", &"reflexo_fica", &"figura_some", &"catalogo_muda"]

var _since_strong := INF
var _since_weak := INF
var _quiet := 0.0
var _hour := false
var _used: Array[StringName] = []
## Kinds the night plays only from its script: request refuses them.
var muted: Array[StringName] = []

func update(dt: float, loud_now: bool) -> void:
	_since_strong += dt
	_since_weak += dt
	_quiet = 0.0 if loud_now else _quiet + dt

func set_hour(active: bool) -> void:
	_hour = active

## True when the scare may happen now (and counts it as happened).
func request(kind: StringName, strong: bool, tension: float) -> bool:
	if _hour or not KINDS.has(kind) or muted.has(kind) or _quiet < QUIET_BEFORE:
		return false
	if strong:
		if _since_strong < STRONG_GAP or tension < STRONG_TENSION or _used.has(kind):
			return false
		_since_strong = 0.0
		_used.append(kind)
	else:
		if _since_weak < WEAK_GAP:
			return false
		_since_weak = 0.0
	_quiet = 0.0
	return true

## A scripted scare: no tension or quiet asked, but never during 03:33 and
## each kind once a night. It counts as the last strong and weak scare and
## breaks the quiet, so the director's own scares wait after it.
func force(kind: StringName) -> bool:
	if _hour or not KINDS.has(kind) or _used.has(kind):
		return false
	_used.append(kind)
	_since_strong = 0.0
	_since_weak = 0.0
	_quiet = 0.0
	return true

## A new night: every kind is fresh, and the night starts quiet.
func new_night() -> void:
	_used.clear()
	_since_strong = INF
	_since_weak = INF
	_quiet = 0.0
