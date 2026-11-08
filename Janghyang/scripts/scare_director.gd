extends RefCounted
## Who decides when the house may frighten Elias (spec §13, the scares):
## every scare asks first. A strong one needs a minute since the last strong
## one, enough tension, and a kind not yet used tonight; a weak one needs
## WEAK_GAP since the last weak one. Any scare needs QUIET_BEFORE seconds of
## quiet before it (and is itself noise), and none comes during 03:33.
## Nothing here plays louder than the bank's peak (D10: no volume bursts).

const STRONG_GAP := 60.0
const WEAK_GAP := 20.0
const QUIET_BEFORE := 8.0
## The least tension for a strong scare.
const STRONG_TENSION := 0.6
## sfx_bank.gd clips every sample at this; scares play at MAX_DB at most.
const PEAK := 0.5
const MAX_DB := 0.0
const KINDS := [&"lampada", &"pose", &"caixa_musica", &"tique_para", &"duplo_espelho", &"pancadas", &"lanterna_pisca"]

var _since_strong := INF
var _since_weak := INF
var _quiet := 0.0
var _hour := false
var _used: Array[StringName] = []

func update(dt: float, loud_now: bool) -> void:
	_since_strong += dt
	_since_weak += dt
	_quiet = 0.0 if loud_now else _quiet + dt

func set_hour(active: bool) -> void:
	_hour = active

## True when the scare may happen now (and counts it as happened).
func request(kind: StringName, strong: bool, tension: float) -> bool:
	if _hour or not KINDS.has(kind) or _quiet < QUIET_BEFORE:
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

## A new night: every kind is fresh, and the night starts quiet.
func new_night() -> void:
	_used.clear()
	_since_strong = INF
	_since_weak = INF
	_quiet = 0.0
