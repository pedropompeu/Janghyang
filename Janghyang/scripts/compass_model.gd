extends RefCounted
## Where Elias's pocket watch points (spec §6, the watch as compass): at the
## goal when it is in his area, else at the first link of the shortest way
## there through the area links (registry.gd), closed ones too; it spins when
## he is outside every area or no way leads there. Its tick quickens as the
## goal nears; it trembles when a Gasto is close.

## Gastos within this many metres tremble the hand.
const TREMBLE_RADIUS := 6.0
## Gastos within this many metres hear the tick (task 20).
const HEARD_RADIUS := 3.0
## Height difference (m) from which the first link counts as up or down.
const TILT_STEP := 0.75
const TICK_FAR := 1.0
const TICK_NEAR := 0.25
const FAR := 25.0
const NEAR := 2.0

## The links of the shortest way from area `from` to area `to` (breadth
## first; each link works both ways, gate or not). Empty when already there
## or when nothing leads there.
static func route(from: StringName, to: StringName, links: Array) -> Array:
	if from == to or from == &"" or to == &"":
		return []
	var came := {from: null}
	var frontier: Array = [from]
	while not frontier.is_empty():
		var cur: StringName = frontier.pop_front()
		for l in links:
			var next: StringName = &""
			if l.from == cur:
				next = l.to
			elif l.to == cur:
				next = l.from
			if next == &"" or came.has(next):
				continue
			came[next] = [cur, l]
			if next == to:
				var path: Array = []
				var at: StringName = to
				while came[at] != null:
					path.push_front(came[at][1])
					at = came[at][0]
				return path
			frontier.append(next)
	return []

## {"mode": &"point", "at": Vector3, "tilt": -1|0|1} or {"mode": &"spin"}.
## `goal` is {"area": StringName, "at": Vector3}.
static func aim(pos: Vector3, area: StringName, goal: Dictionary, links: Array) -> Dictionary:
	if area == &"" or not goal.has("area") or not goal.has("at"):
		return {"mode": &"spin"}
	var target: Vector3 = goal.at
	if goal.area != area:
		var way := route(area, goal.area, links)
		if way.is_empty():
			return {"mode": &"spin"}
		target = way[0].at
	var dy := target.y - pos.y
	var tilt := 0
	if dy >= TILT_STEP:
		tilt = 1
	elif dy <= -TILT_STEP:
		tilt = -1
	return {"mode": &"point", "at": target, "tilt": tilt}

## Seconds between ticks: TICK_FAR from FAR metres on, TICK_NEAR within NEAR.
static func tick_period(distance: float) -> float:
	var k := clampf((distance - NEAR) / (FAR - NEAR), 0.0, 1.0)
	return lerpf(TICK_NEAR, TICK_FAR, k)

static func trembles(nearest_gasto: float) -> bool:
	return nearest_gasto < TREMBLE_RADIUS
