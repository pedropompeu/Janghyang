extends RefCounted
## Scarce light (spec §6, mechanic 6): the lantern spends a battery in about
## four minutes and flickers in its last LOW seconds; a spare in the pockets
## goes in by itself. A match burns MATCH seconds and can light a candle or an
## oil lamp, which then burns CANDLE seconds as a fixed light. Batteries and
## matches do not carry from one night to the next (spec §5).
##
## A night's light is the battery Elias starts with plus the pickups the night
## lays out (`pickups`: ids of the areas' DEF pickups, each
## {id, kind: pilha|fosforo|vela, at, n}).

const Registry = preload("res://scripts/areas/registry.gd")

const BATTERY := 240.0
const MATCH := 20.0
const CANDLE := 120.0
const LOW := 30.0
## Pickup kinds: a battery, a box of `n` matches, a candle (or oil lamp) to light.
const KINDS := [&"pilha", &"fosforo", &"vela"]
const _WORTH := {&"pilha": BATTERY, &"fosforo": MATCH, &"vela": CANDLE}

var battery := BATTERY
## Batteries in the pockets.
var spare := 0
## hands_model.gd: where the matches are (strike spends one).
var hands
var _match_left := 0.0

## Spends `dt` seconds: the lantern's battery while `on`, and the match always.
## &"low" when the battery crosses LOW, &"dead" when it runs out, &"swapped"
## when a spare goes in instead; &"" otherwise.
func drain(dt: float, on: bool) -> StringName:
	_match_left = maxf(_match_left - dt, 0.0)
	if not on:
		return &""
	if battery <= 0.0:
		if spare > 0:
			_spend_spare()
			battery = BATTERY
			return &"swapped"
		return &""
	var before := battery
	battery -= dt
	if battery <= 0.0:
		if spare > 0:
			_spend_spare()
			battery = maxf(BATTERY + battery, 0.0)
			return &"swapped"
		battery = 0.0
		return &"dead"
	if before > LOW and battery <= LOW:
		return &"low"
	return &""

## A spare goes in: one battery fewer in the pockets too.
func _spend_spare() -> void:
	spare -= 1
	if hands != null:
		hands.use_one(&"pilha")

## Lights a match from the pockets; false with none, or with one burning.
func strike() -> bool:
	if burning() or hands == null or not hands.use_one(&"fosforo"):
		return false
	_match_left = MATCH
	return true

func burning() -> bool:
	return _match_left > 0.0

func match_left() -> float:
	return _match_left

## The lantern's energy multiplier at time `t`: 1 until the last LOW seconds,
## then dips that come more often as the battery ends; 0 with no battery.
func flicker(t: float) -> float:
	if battery <= 0.0:
		return 0.0
	if battery > LOW:
		return 1.0
	var k := 1.0 - battery / LOW
	var w := sin(t * 23.0) * sin(t * 7.3 + 1.0)
	if w > 1.0 - 0.8 * k - 0.1:
		return 0.25
	return 1.0 - 0.15 * k

## The pickup with this id in any area's DEF ({} if none).
static func pickup(id: StringName) -> Dictionary:
	for d in Registry.defs():
		for p in d.pickups:
			if p.id == id:
				return p
	return {}

## Seconds of light one pickup is worth.
static func worth(p: Dictionary) -> float:
	return float(_WORTH.get(p.get("kind", &""), 0.0)) * int(p.get("n", 1))

## The light a night's route holds: the battery Elias starts with, plus every
## pickup the night lays out (batteries, matches, candles).
static func route_seconds(night: Dictionary) -> float:
	var total := BATTERY
	for id in night.get("pickups", []):
		var p := pickup(id)
		if not p.is_empty():
			total += worth(p)
	return total
