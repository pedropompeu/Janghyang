extends AnimatableBody3D
## A great wheel of the tower's movement, lying flat and turning slowly, with
## one long arm. When the arm lines up with both ledges it is a bridge; the
## rest of the time Elias can ride it round. A click at every quarter turn.

signal clicked

@export var period := 16.0

var _quarter := 0

func _physics_process(delta: float) -> void:
	rotation.y = wrapf(rotation.y + TAU / period * delta, 0.0, TAU)
	var q := int(rotation.y / (PI * 0.5))
	if q != _quarter:
		_quarter = q
		clicked.emit()

## 0 when the arm lies along x (a bridge), 1 when it is across.
func misalignment() -> float:
	return absf(sin(rotation.y))
