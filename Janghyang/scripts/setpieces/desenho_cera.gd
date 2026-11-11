extends Node3D
## Night 1's wax drawing (spec §6.2, item 1; wax_model.gd): every frame the
## wax lines (node DrawingWax) and the catalogue flag chama_no_desenho follow
## whether a flame is near: the match in Elias's hand while it burns, and any
## lit CandleLight. While the drawing is missing and Elias has no flame, the
## bedside box (pickup fosforo_cabeceira) comes back with one match, unseen.
## On a night that does not list it the wax always shows: its resolved state.

const Wax = preload("res://scripts/wax_model.gd")
const FLAG := &"chama_no_desenho"
const BOX := &"fosforo_cabeceira"

var main: Node
var def: Dictionary
var data: Dictionary

var _active := false

func on_night(night: Dictionary) -> void:
	_active = night.get("setpieces", []).has(data.id)
	_apply(not _active)

func _wax() -> Node3D:
	return main.get_node_or_null("DrawingWax") as Node3D

func _box() -> Node:
	return main.get_node_or_null("LightPickups/Pickup_" + String(BOX))

func _apply(on: bool) -> void:
	var w := _wax()
	if w != null:
		w.visible = on
	main.catalog.set_flag(FLAG, on)

## The match in the hand while light.burning() (its glow is only a lamp),
## and every other lit CandleLight.
func _flames() -> Array:
	var out := []
	var glow: Node3D = main.get_node_or_null("MatchGlow") as Node3D
	if glow == null:
		glow = main.find_child("MatchGlow", true, false) as Node3D
	if main.light.burning():
		out.append(glow.global_position if glow != null else main.player.camera.global_position)
	for l in get_tree().get_nodes_in_group(&"CandleLight"):
		if l != glow and l is Node3D and (l as Node3D).is_visible_in_tree():
			out.append((l as Node3D).global_position)
	return out

func _physics_process(_dt: float) -> void:
	if not _active or main.player == null:
		return
	var at: Vector3 = data.at
	var near := Wax.shows(_flames(), at)
	_apply(near)
	var box = _box()
	if box == null:
		return
	var matches: int = main.player.hands_model.count(&"fosforo") + (1 if main.light.burning() else 0)
	if Wax.refill_due(matches, near, main.catalog.has(&"desenho"), box.active, main.is_seen(box.global_position)):
		box.n = 1
		box.set_active(true)
