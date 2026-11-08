extends RefCounted
## What carries from one night to the next (spec §5.1), and the only thing the
## game saves: it saves between nights, never during one. Pieces, hand items
## (mirror, loupe, stethoscope), opened shortcuts, the plan, the catalogue,
## the rooms seen and the chapters' pages carry; batteries, matches and the
## wind-up toy do not, so every night starts with little light.
##
## The file is JSON: {"version", "state"}, with the state written through
## JSON.from_native so ids come back as StringName and numbers as int. A file
## that does not read back is moved aside to *.bad.json, never deleted, and
## the campaign starts on night 1.

const PATH := "user://campanha.json"
const VERSION := 1

## The hand items that carry; everything else in a night's pockets stays.
const CARRIED_ITEMS: Array[StringName] = [&"espelho", &"lupa", &"estetoscopio"]

var night := 1
var pieces: Array[StringName] = []
var items: Array[StringName] = []
var shortcuts: Array[String] = []
var plan: Dictionary = {}
var catalog: Dictionary = {}
var visited: Dictionary = {}
var chapters: Dictionary = {}

## Keeps what passes from the night that ended. `from_night` may hold any of
## pieces, items, shortcuts (added to what was kept) and plan, catalog,
## visited, chapters (the night's latest, replacing the old).
func carry(from_night: Dictionary) -> void:
	for p in from_night.get("pieces", []):
		if not pieces.has(p):
			pieces.append(p)
	for i in from_night.get("items", []):
		if CARRIED_ITEMS.has(i) and not items.has(i):
			items.append(i)
	for s in from_night.get("shortcuts", []):
		if not shortcuts.has(s):
			shortcuts.append(s)
	for key in ["plan", "catalog", "visited", "chapters"]:
		if from_night.has(key):
			set(key, from_night[key].duplicate(true))

func to_dict() -> Dictionary:
	return {
		"version": VERSION, "night": night, "pieces": pieces.duplicate(), "items": items.duplicate(),
		"shortcuts": shortcuts.duplicate(), "plan": plan.duplicate(true), "catalog": catalog.duplicate(true),
		"visited": visited.duplicate(true), "chapters": chapters.duplicate(true),
	}

## Takes `d` when it is a save of this version with the right shapes; returns
## false and leaves the campaign untouched otherwise.
func from_dict(d: Dictionary) -> bool:
	if d.get("version") is not int or d.version != VERSION:
		return false
	if d.get("night") is not int or d.night < 1:
		return false
	for key in ["pieces", "items", "shortcuts"]:
		if d.get(key) is not Array:
			return false
	for key in ["plan", "catalog", "visited", "chapters"]:
		if d.get(key) is not Dictionary:
			return false
	night = d.night
	pieces.assign(d.pieces.map(func(x): return StringName(x)))
	items.assign(d.items.map(func(x): return StringName(x)))
	shortcuts.assign(d.shortcuts.map(func(x): return String(x)))
	plan = d.plan
	catalog = d.catalog
	visited = d.visited
	chapters = d.chapters
	return true

## Writes the campaign to `path` through a temporary file, so a crash while
## saving leaves the old save whole.
func save(path := PATH) -> Error:
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify({"version": VERSION, "state": JSON.from_native(to_dict())}))
	f.close()
	return DirAccess.rename_absolute(tmp, path)

## Loads `path`. Returns false and starts on night 1 when there is no save;
## when the save does not read back (corrupt, unknown version, wrong shape),
## also moves it to *.bad.json so it is never lost.
func load_or_fresh(path := PATH) -> bool:
	_fresh()
	if not FileAccess.file_exists(path):
		return false
	if _read(FileAccess.get_file_as_string(path)):
		return true
	_fresh()
	DirAccess.rename_absolute(path, path.get_basename() + ".bad.json")
	return false

## Checks the envelope before decoding, so a bad file never reaches the
## engine's decoder (which would only log errors).
func _read(text: String) -> bool:
	var json := JSON.new()
	if json.parse(text) != OK or json.data is not Dictionary:
		return false
	var data: Dictionary = json.data
	if data.get("version") != VERSION or data.get("state") is not Dictionary or data.state.get("type") != "Dictionary":
		return false
	var state = JSON.to_native(data.state)
	return state is Dictionary and from_dict(state)

func _fresh() -> void:
	night = 1
	pieces.clear()
	items.clear()
	shortcuts.clear()
	plan = {}
	catalog = {}
	visited = {}
	chapters = {}
