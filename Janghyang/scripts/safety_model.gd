extends RefCounted
## Where a Gasto cannot reach Elias (spec §11, R12). The house is no longer a
## fixed refuge: each night says which of its points are safe, and a wound
## anchor clock keeps a circle safe anywhere while it still runs.
##
## world: {"level": StringName (the area of the point), "lit": bool (a lamp
## that is on lights the point), "entry_wound": bool (the entry clock was wound
## this night), "anchors": [{"at": Vector3, "left": float seconds, "level":
## StringName (optional: an anchor guards only its own area)}]}.
## rule: the night's `safety` (noites.gd); &"" (today's single visit) means
## only the anchors.

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
	return false
