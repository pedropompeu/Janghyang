extends RefCounted
## The plan in Elias's notebook (spec §8): per level, the fog he has lifted
## (fog_grid.gd, over the union of the level's rooms) and the pencil notes:
## Gastos seen, items seen and not taken, barricades, anchors and chalk.
## Plain data for the campaign save (JSON): fog in base64, points as arrays.

const FogGrid = preload("res://scripts/fog_grid.gd")
const Atlas = preload("res://scripts/atlas.gd")

const KINDS: Array[StringName] = [&"gasto", &"item", &"barricada", &"ancora", &"giz"]

var _fogs: Dictionary = {}
## Saved fog waiting for its grid (made when first asked for).
var _pending: Dictionary = {}
## level → Array of {"at", "kind", "label", "time", "id"}
var _notes: Dictionary = {}

## The fog of `level`, made on first use; null for a level with no rooms.
func fog(level: StringName) -> FogGrid:
	if _fogs.has(level):
		return _fogs[level]
	var all := Rect2()
	var first := true
	for r in Atlas.rooms():
		if r.level == level:
			all = r.rect if first else all.merge(r.rect)
			first = false
	if first:
		return null
	var g := FogGrid.new(all)
	if _pending.has(level):
		g.from_bytes(_pending[level])
		_pending.erase(level)
	_fogs[level] = g
	return g

## A pencil note. With an id, the note of that id moves instead of piling up.
func note(level: StringName, at: Vector3, kind: StringName, label: String, time: float, id: StringName = &"") -> void:
	if not KINDS.has(kind) or level == &"":
		return
	var list: Array = _notes.get(level, [])
	if id != &"":
		for n in list:
			if n.id == id:
				n.at = at
				n.label = label
				n.time = time
				return
	list.append({"at": at, "kind": kind, "label": label, "time": time, "id": id})
	_notes[level] = list

func notes_on(level: StringName) -> Array:
	return _notes.get(level, []).duplicate()

## The item was taken: its note goes, on every sheet.
func forget_item(id: StringName) -> void:
	for level in _notes:
		_notes[level] = (_notes[level] as Array).filter(func(n) -> bool: return not (n.kind == &"item" and n.id == id))

## Levels with anything on them, fog lifted or notes.
func levels_drawn() -> Array[StringName]:
	var out: Array[StringName] = []
	for level in Atlas.levels():
		var g: FogGrid = _fogs.get(level)
		if (g != null and g.count() > 0) or not _notes.get(level, []).is_empty():
			out.append(level)
	return out

func to_dict() -> Dictionary:
	var fogs := {}
	for level in _fogs:
		if (_fogs[level] as FogGrid).count() > 0:
			fogs[String(level)] = Marshalls.raw_to_base64(_fogs[level].to_bytes())
	for level in _pending:
		fogs[String(level)] = Marshalls.raw_to_base64(_pending[level])
	var notes := {}
	for level in _notes:
		var list: Array = []
		for n in _notes[level]:
			list.append({"at": [n.at.x, n.at.y, n.at.z], "kind": String(n.kind), "label": n.label, "time": n.time, "id": String(n.id)})
		notes[String(level)] = list
	return {"fog": fogs, "notes": notes}

## Replaces everything with `d`; whatever does not parse is left out.
func from_dict(d: Dictionary) -> void:
	_fogs.clear()
	_pending.clear()
	_notes.clear()
	var fogs = d.get("fog", {})
	if fogs is Dictionary:
		for level in fogs:
			if fogs[level] is String:
				_pending[StringName(level)] = Marshalls.base64_to_raw(fogs[level])
	var notes = d.get("notes", {})
	if not notes is Dictionary:
		return
	for level in notes:
		if not notes[level] is Array:
			continue
		for n in notes[level]:
			if not n is Dictionary or not n.get("at") is Array or (n.at as Array).size() != 3:
				continue
			note(StringName(level), Vector3(float(n.at[0]), float(n.at[1]), float(n.at[2])), StringName(str(n.get("kind", ""))), str(n.get("label", "")), float(n.get("time", 0.0)), StringName(str(n.get("id", ""))))
