extends RefCounted
## Every area of the bench, as data. Each area script carries a `const DEF`
## (id, maquete, name, rooms, safe, safe_room, links, tasks, breaks, catalog, anchors,
## hideouts, pickups, chalk, mechanisms) and a `static func build(main)`; main
## builds them in this order and reads its maps from here. The order matters:
## the first room that holds a point wins, so the tower stays before the attic.
##
## Areas are listed by preload, never by scanning a folder: an exported build
## packs only what is preloaded.

const AREAS := [
	preload("res://scripts/areas/passagem.gd"),
]

## The helpers of main.gd an area may call, with their argument count
## (defaults included). A test holds main.gd to this contract.
const HELPERS := {
	&"_mat": 3, &"_box": 6, &"_add_mesh": 5, &"_omni": 6, &"_floor": 6,
	&"_wall_x": 7, &"_wall_z": 7, &"_hinge": 12, &"_cyl": 7, &"_breakable": 7,
	&"_rungs": 4, &"_ladder_area": 4, &"_hideout": 4, &"_piece": 3,
	&"_chalk": 4, &"_chalk_frame": 5, &"_catalog_target": 4,
}

const _EMPTY := {
	"maquete": &"", "name": "", "rooms": [], "safe": Vector3.ZERO, "safe_room": &"", "links": [],
	"tasks": {}, "breaks": {}, "catalog": {}, "anchors": [], "hideouts": [],
	"pickups": [], "chalk": [], "mechanisms": [],
}

## safe_room is empty when the safe point lies in one of the area's own rooms;
## otherwise it names the room it lies in (the crawlspace is too low to stand).

static var _defs: Array[Dictionary] = []

## Every DEF, filled in: each room knows its level (the area id), each link
## knows where it starts.
static func defs() -> Array[Dictionary]:
	if _defs.is_empty() and not AREAS.is_empty():
		for a in AREAS:
			var d: Dictionary = _EMPTY.merged(a.DEF, true).duplicate(true)
			for r in d.rooms:
				r["level"] = d.id
			for l in d.links:
				l["from"] = d.id
				if not l.has("path"):
					l["path"] = []
				if not l.has("gate"):
					l["gate"] = &""
			_defs.append(d)
	return _defs

static func def(id: StringName) -> Dictionary:
	for d in defs():
		if d.id == id:
			return d
	return {}

static func has_area(id: StringName) -> bool:
	return not def(id).is_empty()

static func rooms() -> Array:
	var out := []
	for d in defs():
		out.append_array(d.rooms)
	return out

## Area id → display name, in registry order.
static func levels() -> Dictionary:
	var out := {}
	for d in defs():
		out[d.id] = d.name
	return out

## Area id → where Elias wakes on it.
static func safe_points() -> Dictionary:
	var out := {}
	for d in defs():
		out[d.id] = d.safe
	return out

## One of the per-area maps ("tasks", "breaks", "catalog") over every area.
static func merged(key: String) -> Dictionary:
	var out := {}
	for d in defs():
		out.merge(d.get(key, {}), true)
	return out

static func links() -> Array:
	var out := []
	for d in defs():
		out.append_array(d.links)
	return out
