extends Node3D
## Night 1, behind the playroom's north wall (spec §6.2, item 5;
## presence_model.gd): while Elias listens (L) within ListenModel.WALL_REACH
## of that wall, something in the passage creaks every PERIOD and drags itself
## toward his ear, stopping a metre short; the drag loops at LOOP_DB and is cut
## within CUT seconds when it stops moving or he lets go. Never in the 03:33,
## never once the panel is broken. It completes no task (§10). On a night that
## does not list it there is nothing behind the wall: its resolved state.

const Presence = preload("res://scripts/presence_model.gd")
const ListenModel = preload("res://scripts/listen_model.gd")
const ROOM := &"brincar"
## The passage's middle (z) and the height the sounds come from.
const Z := -0.65
const Y := 0.3
const LOOP_DB := -14.0
const CREAK_DB := -4.0
## The loop fades out this fast (s), under the 0.1 s the spec allows.
const CUT := 0.05
const PANEL := &"achar_passagem"

var main: Node
var def: Dictionary
var data: Dictionary

var model = Presence.new()
var _beat = ListenModel.new()
var _active := false
var _loop: AudioStreamPlayer3D
var _fade: Tween
## The drag sounds (also when sfx is silent, headless): set while it moves,
## cleared once the fade is over.
var _dragging := false

func on_night(night: Dictionary) -> void:
	_active = night.get("setpieces", []).has(data.id)
	model = Presence.new()
	_beat.reset()
	_cut(true)

## The drag is sounding, its fade included.
func is_dragging() -> bool:
	return _dragging

## Elias's ear at the playroom's north wall: listening, in the playroom,
## within WALL_REACH of the wall's face.
func at_wall() -> bool:
	var pl = main.player
	if pl == null or not pl.listening:
		return false
	if main.atlas.room_at(pl.global_position) != ROOM:
		return false
	return pl.camera.global_position.z - main.WALL_T * 0.5 <= ListenModel.WALL_REACH

func _panel_broken() -> bool:
	var panel := main.find_child("HollowPanel", true, false)
	return main.step_done(PANEL) or (panel != null and panel.get("broken") == true)

func _physics_process(delta: float) -> void:
	if not _active:
		return
	if _panel_broken():
		model.stop()
	var hour: bool = main.hour_event != null and main.hour_event.is_active()
	var on := not hour and not _panel_broken() and at_wall()
	var r: Dictionary = model.update(delta, on, main.player.camera.global_position.x)
	var at := Vector3(r.x, Y, Z)
	if on:
		if _beat.beat(delta):
			main.sfx.play_at(&"porcelain_muffled", at, &"Mundo", CREAK_DB)
	else:
		_beat.reset()
	if r.drag:
		_drag(at)
	else:
		_cut(false)

func _drag(at: Vector3) -> void:
	if _loop == null:
		_loop = AudioStreamPlayer3D.new()
		_loop.name = "Arrastar"
		_loop.stream = main.sfx.stream(&"arrastar")
		_loop.bus = &"Mundo"
		add_child(_loop)
	_loop.global_position = at
	if _fade != null:
		_fade.kill()
		_fade = null
	_loop.volume_db = LOOP_DB
	_dragging = true
	if not _loop.playing and not main.sfx.silent:
		_loop.play()

func _cut(now: bool) -> void:
	if not _dragging:
		return
	if now:
		if _fade != null:
			_fade.kill()
			_fade = null
		_stop()
		return
	if _fade != null and _fade.is_running():
		return
	_fade = create_tween()
	_fade.tween_property(_loop, "volume_db", -60.0, CUT)
	_fade.tween_callback(_stop)

func _stop() -> void:
	_dragging = false
	if _loop != null:
		_loop.stop()
