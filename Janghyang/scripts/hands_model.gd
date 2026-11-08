extends RefCounted
## Elias's left hand holds one thing at a time; the pockets hold the rest.
## The watch is always his (no pocket count): T opens it into the left hand
## and closing it gives back whatever was there before. The mouse wheel
## turns through the pockets; the stick swings only with the left hand empty
## or holding the stick itself (spec §6, "Mãos e bolsos").

## The order the wheel goes through (the watch has its own key).
const LEFT_ITEMS := [&"relogio", &"vareta", &"espelho", &"fosforo", &"lupa", &"estetoscopio", &"brinquedo"]
const WATCH := &"relogio"

## What the left hand holds (&"" for nothing).
var left := &""
## Item to how many Elias carries (never a zero).
var pockets: Dictionary = {}
## What the hand held before the last hold() or the watch.
var _before := &""

func take(item: StringName, n := 1) -> void:
	if n <= 0:
		return
	pockets[item] = int(pockets.get(item, 0)) + n

func count(item: StringName) -> int:
	return int(pockets.get(item, 0))

## True when `item` can go to the left hand now.
func has(item: StringName) -> bool:
	if item == WATCH:
		return true
	return LEFT_ITEMS.has(item) and count(item) > 0

## Puts `item` in the left hand (&"" empties it), keeping the one before.
func hold(item: StringName) -> bool:
	if item != &"" and not has(item):
		return false
	_before = left
	left = item
	return true

## The next pocket item (dir 1) or the one before (dir -1), with the empty
## hand between the last and the first; never the watch.
func cycle(dir: int) -> StringName:
	var ring: Array = [&""]
	for it in LEFT_ITEMS:
		if it != WATCH and has(it):
			ring.append(it)
	# With the watch open the wheel starts from what it hid.
	var at := maxi(ring.find(_before if left == WATCH else left), 0)
	var next: StringName = ring[posmod(at + signi(dir), ring.size())]
	hold(next)
	return left

func can_swing() -> bool:
	return left == &"" or left == &"vareta"

## Spends one `item` from the pockets; the hand empties when it was the last.
func use_one(item: StringName) -> bool:
	if count(item) <= 0:
		return false
	pockets[item] = count(item) - 1
	if pockets[item] == 0:
		pockets.erase(item)
		if left == item:
			left = &""
	return true

## Opens the watch into the left hand, or closes it and gives back what was
## there (if it is still in the pockets). Returns what the hand now holds.
func toggle_watch() -> StringName:
	if left == WATCH:
		var back := _before if has(_before) else &""
		_before = WATCH
		left = back
	else:
		hold(WATCH)
	return left
