extends StaticBody3D
## Music box: the handle turns and the brass glows; the visual twin of the melody.

var _handle: Node3D
var _glow: OmniLight3D
var _busy := false

func setup(handle: Node3D, glow: OmniLight3D) -> void:
	_handle = handle
	_glow = glow

func get_prompt() -> String:
	return "dar corda na caixa"

func interact() -> void:
	if _busy or _handle == null:
		return
	_busy = true
	var tw := create_tween()
	tw.tween_property(_handle, "rotation:y", _handle.rotation.y + TAU, 1.2).set_trans(Tween.TRANS_SINE)
	tw.finished.connect(func() -> void: _busy = false)
	if _glow != null:
		var light_tw := create_tween()
		light_tw.tween_property(_glow, "light_energy", 1.8, 0.15)
		light_tw.tween_property(_glow, "light_energy", 0.0, 1.3)
