extends Node
## Demo only (`-- --tour`): walks Elias through the house with the real keys
## (W held, B, F, Tab, E at a closed door, F9 for 03:33) and says on screen
## what it is doing. Turning is set directly; the rest goes through input.
## When it ends, the controls are the player's again.

const ARRIVE := 0.35
const TURN_SPEED := 3.0
const STUCK_TIME := 1.0

## Set by main before add_child.
var main: Node
var _caption: Label

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	_caption = Label.new()
	_caption.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_caption.position.y = 24.0
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_caption.add_theme_font_size_override(&"font_size", 22)
	_caption.add_theme_color_override(&"font_color", Color(0.92, 0.88, 0.8))
	_caption.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_caption.add_theme_constant_override(&"outline_size", 6)
	layer.add_child(_caption)
	_run.call_deferred()

func _run() -> void:
	var p: Node = main.player
	_say("Tour automático: só assista")
	await _wait(2.0)
	await _turn_to(p.rotation.y + 1.2, 0.0)
	await _turn_to(p.rotation.y - 2.4, -0.2)
	await _turn_to(0.0, 0.0)

	_say("Entrada → quarto de brincar")
	for at in [Vector3(1.7, 0, 7.9), Vector3(1.7, 0, 6.4), Vector3(5.5, 0, 6.0), Vector3(6.0, 0, 4.8), Vector3(5.4, 0, 3.8), Vector3(5.4, 0, 2.5), Vector3(4.0, 0, 1.0)]:
		await _walk_to(at)
	_say("B: a vareta bate na parede")
	await _turn_to(0.0, 0.0)
	await _wait(0.6)
	for i in 3:
		_tap(KEY_B)
		await _wait(1.0)
	_say("F: lanterna desligada…")
	_tap(KEY_F)
	await _wait(2.0)
	_say("F: …e ligada de novo")
	_tap(KEY_F)
	await _wait(1.5)

	_say("O painel oco embaixo do desenho")
	await _walk_to(Vector3(6.7, 0, 1.0))
	await _turn_to(0.0, deg_to_rad(-40.0))
	for i in 3:
		_tap(KEY_B)
		await _wait(1.1)
	_say("V (segurar): fazer de conta — o giz do menino aparece")
	await _turn_to(0.0, 0.0)
	_key(KEY_V, true)
	await _wait(2.8)
	_key(KEY_V, false)
	await _wait(1.0)
	_say("M: os lotes e o plano no caderno")
	_tap(KEY_M)
	await _wait(3.5)
	_tap(KEY_M)
	await _wait(1.0)

	_say("Para o corredor")
	for at in [Vector3(5.4, 0, 2.5), Vector3(8.0, 0, 2.5), Vector3(9.4, 0, 2.5)]:
		await _walk_to(at)
	await _turn_to(PI, 0.0)
	_say("B no ar: só o zunido")
	await _wait(0.5)
	_tap(KEY_B)
	await _wait(1.2)
	_say("Tab: o caderno (as mãos se recolhem)")
	_tap(KEY_TAB)
	await _wait(3.0)
	_tap(KEY_TAB)
	await _wait(1.0)

	_say("Quarto")
	for at in [Vector3(11.5, 0, 2.5), Vector3(11.5, 0, 5.0), Vector3(9.4, 0, 5.0)]:
		await _walk_to(at)
	_say("F9: o relógio acaba… 03:33")
	_tap(KEY_F9)
	await _wait(1.0)
	await _turn_to(p.rotation.y + 1.5, -0.1, 2.0)
	await _turn_to(p.rotation.y - 3.0, 0.1, 3.0)
	await _wait(3.0)

	_say("Pelo corredor de volta à entrada")
	for at in [Vector3(9.4, 0, 7.9), Vector3(9.4, 0, 8.3), Vector3(7.0, 0, 8.3), Vector3(3.2, 0, 8.3)]:
		await _walk_to(at)
	await _turn_to(PI, 0.0)
	_say("Fim do tour: o controle é seu")
	await _wait(4.0)
	_say("")
	queue_free()

func _say(text: String) -> void:
	_caption.text = text
	if text != "":
		print("tour: ", text)

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _key(code: Key, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)

func _tap(code: Key) -> void:
	_key(code, true)
	_key(code, false)

## Turn the head to a yaw and pitch over a time that suits the angle.
func _turn_to(yaw: float, pitch: float, seconds := -1.0) -> void:
	var p: Node = main.player
	var from: float = p.rotation.y
	var to: float = from + wrapf(yaw - from, -PI, PI)
	if seconds < 0.0:
		seconds = maxf(0.3, absf(to - from) / TURN_SPEED * 1.6)
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(p, "rotation:y", to, seconds)
	tw.parallel().tween_property(p.camera, "rotation:x", pitch, seconds)
	await tw.finished

## Walk with W held, steering toward the point. A closed door in the way gets
## an E; if that does not help, Elias is set down at the point.
func _walk_to(at: Vector3) -> void:
	var p: Node = main.player
	var stuck := 0.0
	var tries := 0
	var last: Vector3 = p.global_position
	while true:
		await get_tree().physics_frame
		var delta := get_physics_process_delta_time()
		var to := Vector2(at.x - p.global_position.x, at.z - p.global_position.z)
		if to.length() < ARRIVE:
			break
		var want := atan2(-to.x, -to.y)
		var err := wrapf(want - p.rotation.y, -PI, PI)
		p.rotation.y += clampf(err, -TURN_SPEED * delta, TURN_SPEED * delta)
		p.camera.rotation.x = move_toward(p.camera.rotation.x, 0.0, delta)
		_key(KEY_W, absf(err) < 0.6)
		var moved := Vector2(p.global_position.x - last.x, p.global_position.z - last.z).length()
		last = p.global_position
		stuck = stuck + delta if moved < 0.01 and absf(err) < 0.6 else 0.0
		if stuck > STUCK_TIME:
			stuck = 0.0
			tries += 1
			_key(KEY_W, false)
			if tries <= 2:
				_tap(KEY_E)
				await _wait(1.3)
			else:
				p.global_position = Vector3(at.x, p.global_position.y, at.z)
				break
	_key(KEY_W, false)
