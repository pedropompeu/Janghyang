extends RefCounted
## Night 1 (spec §6.2, item 5): something in the hidden passage behind the
## playroom's north wall. It moves only while Elias listens there, crawling
## toward his ear along the passage (x) and stopping STOP metres short; the
## dragging is heard only while it moves. Once the panel breaks it is gone.

## Crawling speed (m/s).
const SPEED := 0.25
## How far from the ear it stops (m).
const STOP := 1.0
## The passage's ends along x.
const X_MIN := 0.8
const X_MAX := 9.0

var x := 8.6
var _stopped := false

## Advances `dt` seconds; returns {"x", "drag"}: drag is true only while it
## actually moved this step.
func update(dt: float, listening: bool, ear_x: float) -> Dictionary:
	if _stopped or not listening:
		return {"x": x, "drag": false}
	var goal := clampf(ear_x + STOP if ear_x < x else ear_x - STOP, X_MIN, X_MAX)
	if ear_x >= x - STOP and ear_x <= x + STOP:
		goal = x
	var nx := move_toward(x, goal, SPEED * dt)
	var moved := absf(nx - x) > 0.00001
	x = nx
	return {"x": x, "drag": moved}

## The panel broke: it never drags again.
func stop() -> void:
	_stopped = true
