extends AnimatableBody3D
## A hinged wall panel or door built by main.gd.
## rotation_a is the rest pose; rotation_b is the moved pose.
## prompt_a is the action offered while at A; prompt_b while at B.

@export var prompt_a := "mover"
@export var prompt_b := "voltar"
@export var rotation_a := Vector3.ZERO
@export var rotation_b := Vector3.ZERO
@export var start_at_b := false
@export var duration := 1.1
@export var disable_collision_at_a := false
@export var disable_collision_at_b := false

var _at_b := false
var _busy := false

func _ready() -> void:
	_at_b = start_at_b
	rotation = rotation_b if _at_b else rotation_a
	_apply_collision()

func _apply_collision() -> void:
	var should_disable := (_at_b and disable_collision_at_b) or (not _at_b and disable_collision_at_a)
	set_deferred("collision_layer", 0 if should_disable else 1)

func get_prompt() -> String:
	return prompt_b if _at_b else prompt_a

func is_at_b() -> bool:
	return _at_b

func interact() -> void:
	if _busy:
		return
	_busy = true
	_at_b = not _at_b
	_apply_collision()
	var target := rotation_b if _at_b else rotation_a
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "rotation", target, duration)
	tw.finished.connect(func() -> void: _busy = false)
