extends RigidBody3D
## Wooden ball: the first invitation. Visual only, no audio.

var _cooldown := 0.0

func _ready() -> void:
	continuous_cd = true
	linear_damp = 0.65
	angular_damp = 0.9
	mass = 0.45

func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)

func get_prompt() -> String:
	return "rolar a bola"

func interact() -> void:
	if _cooldown > 0.0:
		return
	_cooldown = 0.7
	sleeping = false
	apply_central_impulse(Vector3(randf_range(-0.5, 0.5), 0.35, randf_range(-1.3, 1.3)))
	apply_torque_impulse(Vector3(randf_range(-0.2, 0.2), 0.0, randf_range(-0.4, 0.4)))
