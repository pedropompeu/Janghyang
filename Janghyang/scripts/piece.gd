extends StaticBody3D
## A piece of Inácio's pocket watch, left where the house hid it. E picks it
## up: main writes it in the notebook, the phase moves on and it is gone from
## the world.

signal taken(id: StringName)

const NAMES := {
	&"coroa": "a coroa do relógio de bolso",
	&"ponteiros": "os ponteiros",
	&"mostrador": "o mostrador",
	&"caixa": "a caixa do relógio",
}

@export var piece_id: StringName = &"coroa"

var _taken := false

func get_prompt() -> String:
	return "" if _taken else "pegar " + String(NAMES.get(piece_id, "a peça"))

func interact() -> void:
	if _taken:
		return
	_taken = true
	for c in get_children():
		if c is CollisionShape3D:
			c.set_deferred(&"disabled", true)
	visible = false
	taken.emit(piece_id)

## Already in the campaign's hands from an earlier night: gone, no signal.
func put_away() -> void:
	_taken = true
	for c in get_children():
		if c is CollisionShape3D:
			c.set_deferred(&"disabled", true)
	visible = false

func is_taken() -> bool:
	return _taken
