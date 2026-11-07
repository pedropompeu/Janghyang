extends StaticBody3D
## A previous occupant. Touching it warms the candle, then lets it fade.

var _glow: OmniLight3D
var _busy := false

func setup(glow: OmniLight3D) -> void:
	_glow = glow

func get_prompt() -> String:
	return "tocar a figura"

func interact() -> void:
	if _busy or _glow == null:
		return
	_busy = true
	var tw := create_tween()
	tw.tween_property(_glow, "light_energy", 1.5, 0.25)
	tw.tween_property(_glow, "light_energy", 0.3, 1.5)
	tw.finished.connect(func() -> void: _busy = false)
