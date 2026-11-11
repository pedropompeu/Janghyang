extends RefCounted
## The wax drawing at the bedroom's head (spec §6.2, item 1): white wax on
## cream paper, blank under the lantern; only a flame near enough brings the
## lines out. And so the night never locks: while the drawing is missing and
## Elias has no flame left, the bedside box quietly holds one more match.

## How near a flame (a match, a lit candle) must be, in metres.
const REVEAL := 2.5

## Whether any of `flames` (lit flames' positions) shows the wax at `at`.
## The lantern is not a flame.
static func shows(flames: Array, at: Vector3) -> bool:
	for f in flames:
		if (f as Vector3).distance_to(at) <= REVEAL:
			return true
	return false

## Whether the bedside box should hold a match again: the drawing is not in
## the notebook, Elias has no match, no flame burns by the drawing, the box
## is empty, and nobody is looking at it.
static func refill_due(matches: int, flame_near: bool, cataloged: bool, box_active: bool, box_seen: bool) -> bool:
	return matches <= 0 and not flame_near and not cataloged and not box_active and not box_seen
