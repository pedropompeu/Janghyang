extends RefCounted
## A Gasto has Elias: he has WINDOW seconds to push it off (clicks, or one
## steady hold in the accessible mode) or it hugs him. Either way the
## result is told once, and after STAGGER seconds he can be grabbed again.

enum State { FREE, GRABBED, BROKE_FREE, HUG }

const WINDOW := 4.0
const STAGGER := 2.0
const HOLD_TIME := 2.5

var state := State.FREE
## The Gasto in the fight (-1 when free).
var gasto := -1
var clicks_needed := 10
var hold_mode := false
var clicks := 0
var _fight := 0.0
var _held_for := 0.0
var _after := 0.0

func _init(needed: int = 10, hold := false) -> void:
	clicks_needed = maxi(needed, 1)
	hold_mode = hold

## Returns false unless free (one fight at a time, none while staggering).
func grab(g: int) -> bool:
	if state != State.FREE:
		return false
	state = State.GRABBED
	gasto = g
	clicks = 0
	_fight = 0.0
	_held_for = 0.0
	return true

func push() -> void:
	if state == State.GRABBED:
		clicks += 1

## &"broke_free" or &"hug" once, at the moment it happens; &"" otherwise.
func update(dt: float, held: bool) -> StringName:
	match state:
		State.GRABBED:
			_fight += dt
			_held_for = _held_for + dt if held and hold_mode else 0.0
			if clicks >= clicks_needed or (hold_mode and _held_for >= HOLD_TIME):
				_end(State.BROKE_FREE)
				return &"broke_free"
			if _fight >= WINDOW:
				_end(State.HUG)
				return &"hug"
		State.BROKE_FREE, State.HUG:
			_after += dt
			if _after >= STAGGER:
				state = State.FREE
				gasto = -1
	return &""

## How close Elias is to breaking free, 0 to 1.
func progress() -> float:
	if state != State.GRABBED:
		return 0.0
	var p := float(clicks) / clicks_needed
	if hold_mode:
		p = maxf(p, _held_for / HOLD_TIME)
	return clampf(p, 0.0, 1.0)

func is_grabbed() -> bool:
	return state == State.GRABBED

func _end(s: State) -> void:
	state = s
	_after = 0.0
