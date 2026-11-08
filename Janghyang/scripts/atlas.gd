extends RefCounted
## The plan Elias draws as he goes: every room of the bench, by level, and
## which ones he has set foot in. Rects are on the floor (x, z); a room also
## has a height band so the attic is not the playroom. Order matters: the
## first room that contains a point wins (the tower sits inside the attic).
##
## The rooms and levels come from the area registry, in its order.

const Registry = preload("res://scripts/areas/registry.gd")

const ATTIC_Y := 2.94
const ATTIC_TOP := 5.24
const DRAWER_Y := -3.2

## Rooms whose name takes "na" (the rest take "no").
const FEMININE := [&"entrada", &"figuras", &"beira_oeste", &"beira_sul", &"passagem", &"mecanismo", &"gaveta", &"loja_varela", &"oficina_varela", &"tampo_leste"]

var visited: Dictionary = {}

static var _rooms: Array = []
static var _levels: Dictionary = {}

## Every room of the bench, in registry order.
static func rooms() -> Array:
	if _rooms.is_empty():
		_rooms = Registry.rooms()
	return _rooms

## Level id → its name on the plan, in registry order.
static func levels() -> Dictionary:
	if _levels.is_empty():
		_levels = Registry.levels()
	return _levels

## "na passagem", "no corredor": where something happened, for the notebook.
static func where(id: StringName) -> String:
	for r in rooms():
		if r.id == id:
			return ("na " if FEMININE.has(id) else "no ") + r.name
	return "na casa"

func room_at(pos: Vector3) -> StringName:
	var r := room_data(pos)
	return r.id if not r.is_empty() else &""

func room_data(pos: Vector3) -> Dictionary:
	var p := Vector2(pos.x, pos.z)
	for r in rooms():
		if r.rect.has_point(p) and pos.y >= r.y.x and pos.y < r.y.y:
			return r
	return {}

## Marks the room under `pos`. Returns its id the first time, else &"".
func visit(pos: Vector3) -> StringName:
	var id := room_at(pos)
	if id == &"" or visited.has(id):
		return &""
	visited[id] = true
	return id

func level_of(id: StringName) -> StringName:
	for r in rooms():
		if r.id == id:
			return r.level
	return &""

func rooms_on(level: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for r in rooms():
		if r.level == level:
			out.append(r.id)
	return out

func room(id: StringName) -> Dictionary:
	for r in rooms():
		if r.id == id:
			return r
	return {}
