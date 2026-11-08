extends RefCounted
## The plan Elias draws as he goes: every room of the bench, by level, and
## which ones he has set foot in. Rects are on the floor (x, z); a room also
## has a height band so the attic is not the playroom. Order matters: the
## first room that contains a point wins (the tower sits inside the attic).
##
## The rooms come from the area registry; the LEGACY_ lists hold the areas not
## yet moved there. rooms() puts a registered area's rooms where its legacy
## rooms stood, so the order never changes while the move is under way.

const Registry = preload("res://scripts/areas/registry.gd")

const ATTIC_Y := 2.94
const ATTIC_TOP := 5.24
const DRAWER_Y := -3.2

const LEGACY_LEVELS := {
	&"casa": "A casa",
	&"passagem": "A passagem",
	&"sotao": "O sótão",
	&"mecanismo": "O mecanismo",
	&"gaveta": "A gaveta",
	&"tampo": "O tampo",
}

const LEGACY_ROOMS := [
	{"id": &"entrada", "name": "entrada", "level": &"casa", "rect": Rect2(0.0, 7.0, 3.5, 2.1), "y": Vector2(-0.4, 2.8)},
	{"id": &"brincar", "name": "quarto de brincar", "level": &"casa", "rect": Rect2(0.0, 0.0, 8.4, 7.0), "y": Vector2(-0.4, 2.8)},
	{"id": &"corredor", "name": "corredor", "level": &"casa", "rect": Rect2(8.4, 0.0, 2.1, 7.7), "y": Vector2(-0.4, 2.8)},
	{"id": &"quarto", "name": "quarto", "level": &"casa", "rect": Rect2(10.5, 0.0, 4.9, 5.6), "y": Vector2(-0.4, 2.8)},
	{"id": &"figuras", "name": "sala das figuras", "level": &"casa", "rect": Rect2(10.5, 7.0, 2.8, 2.1), "y": Vector2(-0.4, 2.8)},
	{"id": &"corredor_sul", "name": "corredor da frente", "level": &"casa", "rect": Rect2(3.5, 7.7, 7.0, 1.4), "y": Vector2(-0.4, 2.8)},
	{"id": &"beira_oeste", "name": "beira oeste", "level": &"casa", "rect": Rect2(-3.2, 0.0, 3.2, 9.1), "y": Vector2(-0.4, 2.8)},
	{"id": &"beira_sul", "name": "beira sul", "level": &"casa", "rect": Rect2(0.0, 9.1, 15.4, 3.4), "y": Vector2(-0.4, 2.8)},
	{"id": &"passagem", "name": "passagem", "level": &"passagem", "rect": Rect2(0.3, -1.3, 10.1, 1.3), "y": Vector2(-0.4, 2.9)},
	{"id": &"mecanismo", "name": "torre", "level": &"mecanismo", "rect": Rect2(5.2, 1.0, 5.4, 5.5), "y": Vector2(2.8, 13.0)},
	{"id": &"sotao", "name": "sótão", "level": &"sotao", "rect": Rect2(0.3, -1.3, 14.8, 10.1), "y": Vector2(2.8, 5.3)},
	{"id": &"gaveta", "name": "gaveta", "level": &"gaveta", "rect": Rect2(-1.0, -1.0, 18.0, 14.0), "y": Vector2(-3.6, -0.5)},
	{"id": &"loja_varela", "name": "Relojoaria Varela", "level": &"tampo", "rect": Rect2(20.0, -7.0, 10.0, 5.0), "y": Vector2(-0.4, 3.0)},
	{"id": &"oficina_varela", "name": "oficina dos fundos", "level": &"tampo", "rect": Rect2(20.0, -12.0, 10.0, 5.0), "y": Vector2(-0.4, 3.0)},
	{"id": &"tampo_leste", "name": "bancada", "level": &"tampo", "rect": Rect2(15.4, -16.0, 18.6, 29.4), "y": Vector2(-0.4, 3.0)},
]

## Rooms whose name takes "na" (the rest take "no").
const FEMININE := [&"entrada", &"figuras", &"beira_oeste", &"beira_sul", &"passagem", &"mecanismo", &"gaveta", &"loja_varela", &"oficina_varela", &"tampo_leste"]

var visited: Dictionary = {}

static var _rooms: Array = []
static var _levels: Dictionary = {}

## Every room of the bench, in order: legacy ones and registered areas merged.
static func rooms() -> Array:
	if _rooms.is_empty():
		var done := {}
		for r in LEGACY_ROOMS:
			if Registry.has_area(r.level):
				if not done.has(r.level):
					done[r.level] = true
					_rooms.append_array(Registry.def(r.level).rooms)
			else:
				_rooms.append(r)
		for d in Registry.defs():
			if not done.has(d.id):
				_rooms.append_array(d.rooms)
	return _rooms

## Level id → its name on the plan, in today's order, then new areas.
static func levels() -> Dictionary:
	if _levels.is_empty():
		var reg := Registry.levels()
		for lvl in LEGACY_LEVELS:
			_levels[lvl] = reg.get(lvl, LEGACY_LEVELS[lvl])
		for lvl in reg:
			if not _levels.has(lvl):
				_levels[lvl] = reg[lvl]
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
