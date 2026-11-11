extends Node3D
## Night 1's opening (spec §6.1): when Elias puts the letter away, a switch
## clicks once toward the workshop and the light outside goes out: the warm
## light behind every house window (group OutsideLight) and the workshop's
## lamp, when it is built. The glass goes black with it, on this piece's own
## material, so the workshop's window keeps its colour on the other nights.
## Then the house's lamps go as before (main._house_goes_dark), and the piece
## plays nothing more. On a night that does not list it, it leaves every
## light as built (its resolved state: nothing to resolve).

const DELAY := 0.25
const FADE := 0.4
const CLICK_DB := -18.0
## How far toward the workshop's lamp the click sounds, from Elias.
const CLICK_AWAY := 4.0

var main: Node
var def: Dictionary
var data: Dictionary

var _active := false
var _played := false
var _out := false
## OutsideLight -> its energy as built.
var _base := {}
var _glass_mat: StandardMaterial3D
var _tw: Tween

func on_night(night: Dictionary) -> void:
	if _tw != null:
		_tw.kill()
		_tw = null
	_active = night.get("setpieces", []).has(data.id)
	_played = false
	_out = false
	for l in _lights():
		if not _base.has(l):
			_base[l] = l.light_energy
		l.light_energy = _base[l]
	for g in _glass():
		g.material_override = main.mat_window
	var card = main.night_card
	if card != null and not card.letter_closed.is_connected(_on_letter_closed):
		card.letter_closed.connect(_on_letter_closed)

func is_out() -> bool:
	return _out

func _lights() -> Array:
	return get_tree().get_nodes_in_group(&"OutsideLight")

func _glass() -> Array:
	return get_tree().get_nodes_in_group(&"HouseWindow")

func _on_letter_closed() -> void:
	if not _active or _played:
		return
	_played = true
	var lights := _lights()
	main.sfx.play_at(&"interruptor", _click_at(lights), &"Casa", CLICK_DB)
	if _glass_mat == null:
		_glass_mat = main.mat_window.duplicate()
	_glass_mat.emission_energy_multiplier = main.mat_window.emission_energy_multiplier
	_glass_mat.albedo_color = main.mat_window.albedo_color
	for g in _glass():
		g.material_override = _glass_mat
	_tw = create_tween().set_parallel(true)
	for l in lights:
		_tw.tween_property(l, "light_energy", 0.0, FADE).set_delay(DELAY)
	_tw.tween_property(_glass_mat, "emission_energy_multiplier", 0.0, FADE).set_delay(DELAY)
	_tw.tween_property(_glass_mat, "albedo_color", Color.BLACK, FADE).set_delay(DELAY)
	_tw.chain().tween_callback(func() -> void:
		_out = true
		main._house_goes_dark())

## A few metres from Elias toward the workshop's lamp, or above him without it.
func _click_at(lights: Array) -> Vector3:
	var from: Vector3 = main.player.global_position
	var oficina: Node = main.get_node_or_null("Oficina")
	for l in lights:
		if oficina != null and oficina.is_ancestor_of(l):
			return from + from.direction_to(l.global_position) * CLICK_AWAY
	return from + Vector3(0.0, CLICK_AWAY, 0.0)
