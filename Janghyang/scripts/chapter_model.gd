extends RefCounted
## One chapter of a night (spec §6.1): its clues are catalogue ids; when the
## last one is in, the staged scene opens; when the scene is over, the
## hypothesis page: three lines Elias drafted, one the clues bear out. A wrong
## line is crossed out and costs nothing but time; the right one is written
## out clean and the page is done.

const Staging = preload("res://scripts/staging_model.gd")

var id := 0
var area: StringName = &""
var title := ""
var clues: Array = []
var hypothesis: Array = []
var right := 0
var reward: StringName = &""
var opened := false
var staging
var chosen := -1
var crossed: Array[int] = []
var _have := {}

## `def` is a chapter of noites.gd: {id, area, title, clues, poses,
## hypothesis, right, reward}.
func _init(def: Dictionary = {}) -> void:
	id = int(def.get("id", 0))
	area = def.get("area", &"")
	title = String(def.get("title", ""))
	clues = def.get("clues", []).duplicate()
	hypothesis = def.get("hypothesis", []).duplicate()
	right = int(def.get("right", 0))
	reward = def.get("reward", &"")
	staging = Staging.new(int(def.get("poses", 1)))
	opened = clues.is_empty()

## True when `item` is the last clue still missing: the scene opens.
func on_cataloged(item: StringName) -> bool:
	if opened or not clues.has(item) or _have.has(item):
		return false
	_have[item] = true
	if _have.size() < clues.size():
		return false
	opened = true
	return true

## The scene's tick (nothing while closed); true when it takes a pose.
func update(dt: float, seen: bool) -> bool:
	if not opened:
		return false
	return staging.update(dt, seen)

## The scene is over: the hypothesis page is in the notebook.
func ready_to_write() -> bool:
	return opened and staging.done()

## True when `i` is the right line (written out clean); a wrong one is
## crossed out. Nothing changes once the page is done.
func choose(i: int) -> bool:
	if chosen >= 0 or i < 0 or i >= hypothesis.size() or crossed.has(i):
		return false
	if i == right:
		chosen = i
		return true
	crossed.append(i)
	return false

func page() -> Dictionary:
	return {"lines": hypothesis.duplicate(), "chosen": chosen, "crossed": crossed.duplicate()}
