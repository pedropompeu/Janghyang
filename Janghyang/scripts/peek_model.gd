extends RefCounted
## Night 1 (spec §6.2, item 11): what the crack in the playroom wall shows.
## The first look shows a far shape crouched in the passage; later looks show
## only the dark until SECOND_AFTER seconds have passed and the director gives
## leave, then an eye right at the crack, once; after it, nothing. With the
## panel broken, nothing at all.

## Seconds after the first look before the eye may come.
const SECOND_AFTER := 120.0

var _first_at := -1.0
var _eye_done := false

func look(now: float, eye_allowed: bool, panel_broken: bool) -> StringName:
	if panel_broken or _eye_done:
		return &"nada"
	if _first_at < 0.0:
		_first_at = now
		return &"forma"
	if now - _first_at >= SECOND_AFTER and eye_allowed:
		_eye_done = true
		return &"olho"
	return &"escuro"

## Whether the next look would be the eye, if leave were given (so the piece
## asks the director only when it matters).
func eye_due(now: float, panel_broken: bool) -> bool:
	return not panel_broken and not _eye_done and _first_at >= 0.0 and now - _first_at >= SECOND_AFTER
