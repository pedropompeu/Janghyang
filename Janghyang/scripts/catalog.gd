extends RefCounted
## Elias's catalogue as pure state: numbered entries, revealed diary pages and
## the play flags that open gated items. Entry 214 is already written.

const Data = preload("res://scripts/catalog_data.gd")

var entries: Array[Dictionary] = []
var pages: Array[StringName] = []
var flags: Dictionary = {}
## Items whose text holds a number the house keeps (the bench's figures):
## item -> how many there are now, set by the piece that counts them.
var counts: Dictionary = {}

## How many times one entry may rewrite its number, and the words it uses.
const RECOUNT_MAX := 2
const COUNT_WORDS := {7: "sete", 6: "seis", 5: "cinco", 4: "quatro"}

func _init() -> void:
	entries.append({"number": Data.OPENING.number, "text": Data.OPENING.text, "author": &"elias", "item": &"maquete"})

func set_flag(name: StringName, value: bool) -> void:
	flags[name] = value

func can_catalog(item: StringName) -> bool:
	if not Data.ITEMS.has(item) or has(item):
		return false
	# A text with a number in it waits for someone to count (the empty bench
	# of the other nights has nothing to write down).
	if Data.ITEMS[item].text.contains("%s") and not counts.has(item):
		return false
	var gate: StringName = Data.ITEMS[item].gate
	return gate == &"" or flags.get(gate, false)

## Writes the entry for item and reveals its page. Returns {} when refused.
func catalog(item: StringName) -> Dictionary:
	if not can_catalog(item):
		return {}
	var data: Dictionary = Data.ITEMS[item]
	var entry := {"number": next_number(), "text": data.text, "author": &"elias", "item": item}
	if counts.has(item):
		var n: int = counts[item]
		entry.text = data.text % COUNT_WORDS.get(n, str(n))
		entry["count"] = n
		entry["rewrites"] = 0
	entries.append(entry)
	if data.page != &"" and not pages.has(data.page):
		pages.append(data.page)
	return entry

## The house changes what Elias wrote (spec §6.9): the entry for `item` now
## says `n`, in his hand, no erasure. Only while the notebook is shut, only
## downward, at most RECOUNT_MAX times. True when it rewrote.
func recount(item: StringName, n: int, notebook_open: bool) -> bool:
	if notebook_open or not Data.ITEMS.has(item):
		return false
	for e in entries:
		if e.item != item or not e.has("count"):
			continue
		if n >= int(e.count) or int(e.get("rewrites", 0)) >= RECOUNT_MAX:
			return false
		e.text = Data.ITEMS[item].text % COUNT_WORDS.get(n, str(n))
		e.count = n
		e.rewrites = int(e.get("rewrites", 0)) + 1
		return true
	return false

## A piece of the pocket watch, picked up: Elias writes it like any item and
## the page that was with it is glued in. Returns {} when unknown or done.
func note(item: StringName) -> Dictionary:
	if not Data.NOTES.has(item) or has(item):
		return {}
	var data: Dictionary = Data.NOTES[item]
	var entry := {"number": next_number(), "text": data.text, "author": &"elias", "item": item}
	entries.append(entry)
	if data.page != &"" and not pages.has(data.page):
		pages.append(data.page)
	return entry

func has(item: StringName) -> bool:
	for e in entries:
		if e.item == item:
			return true
	return false

## Items Elias catalogued himself: not the opening 214, not the double's lines.
func count_elias_items() -> int:
	var n := 0
	for e in entries:
		if e.author == &"elias" and e.item != &"maquete":
			n += 1
	return n

func next_number() -> int:
	return maxi(Data.FIRST_NUMBER, entries[-1].number + 1)

func add_double_entries(texts: Array[String]) -> void:
	for text in texts:
		entries.append({"number": next_number(), "text": text, "author": &"duplo", "item": &""})

static func format(entry: Dictionary) -> String:
	return "Item %d — %s" % [entry.number, entry.text]

## The catalogue as plain data, for the campaign save between nights.
func to_dict() -> Dictionary:
	return {"entries": entries.duplicate(true), "pages": pages.duplicate(), "flags": flags.duplicate()}

## Replaces this catalogue with `d`. Takes what JSON gives back too (floats
## for numbers, strings for ids). An entry without a number or a text is left
## out; with no entries at all, the opening one stays, so numbering goes on.
func from_dict(d: Dictionary) -> void:
	entries.clear()
	for e in d.get("entries", []):
		if e is Dictionary and (e.get("number") is int or e.get("number") is float) and e.get("text") is String:
			var entry := {"number": int(e.number), "text": e.text, "author": StringName(str(e.get("author", ""))), "item": StringName(str(e.get("item", "")))}
			for k in ["count", "rewrites"]:
				if e.get(k) is int or e.get(k) is float:
					entry[k] = int(e[k])
			entries.append(entry)
	if entries.is_empty():
		_init()
	pages.clear()
	for p in d.get("pages", []):
		pages.append(StringName(p))
	flags.clear()
	for k in d.get("flags", {}):
		flags[StringName(k)] = bool(d.flags[k])
