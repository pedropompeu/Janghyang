extends StaticBody3D
## A light source on the night's route (light_model.gd): a battery or a box of
## matches to take, or a candle to light with a match, which then burns
## Light.CANDLE seconds as a fixed light the Gastos fear. One is built for
## every DEF pickup; begin_night shows only the night's own (main.gd).

const Light = preload("res://scripts/light_model.gd")

## How the plan (plan_model.gd) and the prompt name each kind.
const NAMES := {&"pilha": "pilha", &"fosforo": "fósforos", &"vela": "vela"}

## Set by main.
var main: Node
var pickup_id := &""
var kind := &""
var n := 1
## The candle's flame (candles only): a lamp of gastos.gd, in group CandleLight.
var glow: OmniLight3D
var active := false
var lit := false
var _left := 0.0
var _t := 0.0

func get_prompt() -> String:
	if not active:
		return ""
	match kind:
		&"vela":
			return "" if lit else "acender a vela"
		&"fosforo":
			return "pegar os fósforos (%d)" % n
	return "pegar a pilha"

func interact() -> void:
	if not active or main == null:
		return
	if kind == &"vela":
		if not lit:
			main.light_candle(self)
		return
	main.take_light(self)

## Shown and solid on the nights that lay it out; a candle starts unlit.
func set_active(on: bool) -> void:
	active = on
	visible = on
	collision_layer = 1 if on else 0
	put_out()
	if on and not is_in_group(&"PlanItem"):
		add_to_group(&"PlanItem")
	elif not on and is_in_group(&"PlanItem"):
		remove_from_group(&"PlanItem")

func light_up() -> void:
	if kind != &"vela" or glow == null:
		return
	lit = true
	_left = Light.CANDLE
	glow.visible = true

func put_out() -> void:
	lit = false
	_left = 0.0
	if glow != null:
		glow.visible = false

func burn_left() -> float:
	return _left

func _process(delta: float) -> void:
	if not lit:
		return
	_t += delta
	_left -= delta
	if _left <= 0.0:
		put_out()
		return
	glow.light_energy = 0.9 + 0.12 * sin(_t * 9.0) * sin(_t * 3.1)
