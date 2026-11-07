extends RefCounted
## The house as a mirror: it gives back what the player did, after a silence,
## once per action, and never something the player did not do. The only
## exception is a single invitation (the ball) after a long idle.

const COOLDOWN := 4.0
const SILENCE_AFTER_PLAYER := 2.0
const IDLE_INVITE := 60.0
const KNOCK_GROUP := 1.5
const EPS := 0.000001

## verb -> {"n": registrations, "order": recency}
var _pending := {}
var _order := 0
var _since_action := 0.0
var _since_response := INF
var _idle := 0.0
var _invited := false
var _since_knock := INF
var _knock_count := 0
var _responses := 0

func register(verb: StringName) -> void:
	_idle = 0.0
	if verb == &"mover":
		return
	_since_action = 0.0
	if verb == &"bater":
		_knock_count = _knock_count + 1 if _since_knock <= KNOCK_GROUP else 1
		_since_knock = 0.0
	_order += 1
	var n: int = _pending[verb].n + 1 if _pending.has(verb) else 1
	_pending[verb] = {"n": n, "order": _order}

func update(dt: float) -> Dictionary:
	_since_action += dt
	_since_response += dt
	_since_knock += dt
	_idle += dt
	if _since_response <= COOLDOWN + EPS:
		return {}
	if not _pending.is_empty() and _since_action >= SILENCE_AFTER_PLAYER - EPS:
		var verb := _pick()
		_pending.erase(verb)
		_since_response = 0.0
		_responses += 1
		return {"verb": verb, "count": _knock_count if verb == &"bater" else 1, "invite": false}
	if not _invited and _idle >= IDLE_INVITE - EPS:
		_invited = true
		_since_response = 0.0
		_responses += 1
		return {"verb": &"rolar", "count": 1, "invite": true}
	return {}

func responses_given() -> int:
	return _responses

## Most registrations wins; a tie goes to the most recent.
func _pick() -> StringName:
	var best := &""
	for verb in _pending:
		if best == &"":
			best = verb
			continue
		var a: Dictionary = _pending[verb]
		var b: Dictionary = _pending[best]
		if a.n > b.n or (a.n == b.n and a.order > b.order):
			best = verb
	return best
