extends Node3D
## One echo of Elias at 03:33: an 8 s window of what the player did, replayed
## in a loop. It only ever walks a recorded path; it has no collision and
## takes no input. Winding the clock freezes it where it stands.

const Mannequin = preload("res://scripts/mannequin.gd")
const SAMPLE_HZ := 10.0
const VOLUME_DB := -12.0
const STEP_EVERY := 0.6

## Set by the creator before setup: the shared SfxBank (may be null).
var sfx
var style: Dictionary

var _samples: Array[Dictionary] = []
var _t := 0.0
var _frozen := false
var _body: Node3D
var _last_index := -1
var _walked := 0.0

## Copies the window's samples into the echo (A-013). The recorder drops its
## oldest samples once it is full, which shifts any index into it, so the echo
## must not read the recorder after this call.
func load_window(recorder, seg: Vector2i) -> void:
	_samples.clear()
	for i in range(seg.x, seg.y):
		_samples.append(recorder.get_sample(i))

## Interpolated position and angles at time t, looping every
## (window length) / SAMPLE_HZ seconds. crouched and action come from the
## earlier sample. index is relative to the window.
func sample_at(t: float) -> Dictionary:
	var count := _samples.size()
	if count <= 0:
		return {}
	var f := fposmod(t * SAMPLE_HZ, float(count))
	var i := int(floor(f))
	var w := f - i
	var a: Dictionary = _samples[i]
	# The last sample of the window holds still until the loop restarts.
	var b: Dictionary = _samples[mini(i + 1, count - 1)]
	return {
		"pos": a.pos.lerp(b.pos, w),
		"yaw": lerp_angle(a.yaw, b.yaw, w),
		"pitch": lerpf(a.pitch, b.pitch, w),
		"crouched": a.crouched,
		"action": a.action,
		"index": i,
	}

func setup(recorder, seg: Vector2i, phase: float) -> void:
	load_window(recorder, seg)
	_t = phase
	_body = Mannequin.new()
	_body.build(style)
	add_child(_body)
	_apply(sample_at(_t))

func freeze() -> void:
	_frozen = true

func resume() -> void:
	_frozen = false

func is_frozen() -> bool:
	return _frozen

func _process(delta: float) -> void:
	if _frozen or _samples.is_empty():
		return
	_t += delta
	var before := global_position
	var s := sample_at(_t)
	_apply(s)
	if sfx == null:
		return
	_walked += Vector2(global_position.x - before.x, global_position.z - before.z).length()
	if _walked >= STEP_EVERY:
		_walked = 0.0
		sfx.play_at(&"step", global_position, &"Casa", VOLUME_DB)
	if s.index != _last_index:
		_last_index = s.index
		if s.action != &"":
			sfx.play_at(&"click", global_position + Vector3(0.0, 1.0, 0.0), &"Casa", VOLUME_DB)

func _apply(s: Dictionary) -> void:
	if s.is_empty():
		return
	global_position = s.pos
	_body.set_look(s.yaw, s.pitch)
	_body.set_pose(&"agachado" if s.crouched else &"em_pe")
