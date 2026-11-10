extends RefCounted
## Where a Gasto cannot reach Elias (spec §11, R12). The house is no longer a
## fixed refuge: each night says which of its points are safe, and a wound
## anchor clock keeps a circle safe anywhere while it still runs.
##
## world: {"level": StringName (the area of the point), "lit": bool (a lamp
## that is on lights the point), "entry_wound": bool (the entry clock was wound
## this night), "anchors": [{"at": Vector3, "left": float seconds, "level":
## StringName (optional: an anchor guards only its own area)}], "clock":
## Vector3 (where the entry clock stands; raio_relogio measures from it on
## the floor plan, height ignored)}.
## rule: the rule in force this moment (rule_of over the night's `safety`,
## noites.gd); &"" (today's single visit) means only the anchors.

const Registry = preload("res://scripts/areas/registry.gd")

const ANCHOR_RADIUS := 4.0

static func is_safe(point: Vector3, rule: StringName, world: Dictionary) -> bool:
	for a in world.get("anchors", []):
		if a.has("level") and a.level != world.get("level", &""):
			continue
		if a.left > 0.0 and point.distance_to(a.at) <= ANCHOR_RADIUS:
			return true
	if world.get("level", &"") != Registry.HOME:
		return false
	match rule:
		&"casa_toda":
			return true
		&"relogio_entrada":
			return world.get("entry_wound", false)
		&"comodos_com_luz":
			return world.get("lit", false)
		&"raio_relogio":
			if not world.has("clock"):
				return false
			var c: Vector3 = world.clock
			return Vector2(point.x - c.x, point.z - c.z).length() <= ANCHOR_RADIUS
	return false

## The rule in force: a night's `safety` is one rule, or steps
## [{after, rule}] where the last step whose `after` is behind us wins
## (`after` &"" is the start of the night; is_done says what is behind).
static func rule_of(safety: Variant, is_done: Callable) -> StringName:
	if safety is Array:
		var out := &""
		for s in safety:
			if s.get("after", &"") == &"" or is_done.call(s.after):
				out = s.rule
		return out
	return safety if safety is StringName else &""

## Where Elias wakes after a hug or a fall: on the floor he was on, at its
## safe point, except under the clock's radius, when only the entry is safe.
static func wake_for(rule: StringName, area_safe: Vector3, home_safe: Vector3) -> Vector3:
	return home_safe if rule == &"raio_relogio" else area_safe
