extends StaticBody3D
## The copy: lying on the bed, then sitting up. The player's touch is the trigger.

var sit_rotation := Vector3(-1.3, 0.0, 0.0)
var sit_offset := Vector3(0.0, 0.25, 0.08)

var _rest_pos: Vector3
var _rest_rot: Vector3
var _lying := true
var _busy := false

func _ready() -> void:
	_rest_pos = position
	_rest_rot = rotation

func get_prompt() -> String:
	return "sentar o boneco" if _lying else "deitar o boneco"

func interact() -> void:
	if _busy:
		return
	_busy = true
	_lying = not _lying
	var target_pos := _rest_pos if _lying else _rest_pos + sit_offset
	var target_rot := _rest_rot if _lying else _rest_rot + sit_rotation
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position", target_pos, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "rotation", target_rot, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func() -> void: _busy = false)
