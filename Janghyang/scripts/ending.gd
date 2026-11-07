extends Node
## Leaving the maquete: the player stops, the screen goes black, the clock is
## left as the outcome says, and the view becomes the giant's eyes over the
## bench. Three seconds later, one last entry on paper. Nothing else.

const EndingModel = preload("res://scripts/ending_model.gd")
const Mannequin = preload("res://scripts/mannequin.gd")

const FADE := 1.0
const ENTRY_DELAY := 3.0
const CAMERA_POS := Vector3(1.8, 14.0, 22.0)
const CAMERA_TARGET := Vector3(1.8, 0.5, 8.3)
const CAMERA_FOV := 24.0
## The new figure turns a page this often, when the clock was wound.
const PAGE_EVERY := 4.0
const PAGE_ARM := 25.0

signal finished(outcome: StringName)

## Set by main before add_child.
var main: Node
var final_camera: Camera3D

var _done := false
var _black: ColorRect
var _figure: Node3D
var _page_t := 0.0

func _ready() -> void:
	set_process(false)
	final_camera = Camera3D.new()
	final_camera.name = "FinalCamera"
	final_camera.fov = CAMERA_FOV
	final_camera.far = 80.0
	final_camera.transform = Transform3D(Basis.IDENTITY, CAMERA_POS).looking_at(CAMERA_TARGET, Vector3.UP)
	main.add_child.call_deferred(final_camera)
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black.modulate.a = 0.0
	_black.visible = false
	layer.add_child(_black)

func finish(outcome: StringName) -> void:
	if _done or outcome == &"":
		return
	_done = true
	main.player.input_locked = true
	main.player.velocity = Vector3.ZERO
	_black.visible = true
	var tw := create_tween()
	tw.tween_property(_black, "modulate:a", 1.0, FADE)
	tw.tween_callback(_behind_black.bind(outcome))
	tw.tween_property(_black, "modulate:a", 0.0, FADE)
	tw.tween_callback(func() -> void: _black.visible = false)
	get_tree().create_timer(FADE + ENTRY_DELAY).timeout.connect(func() -> void:
		main.notebook.show_final(EndingModel.final_entry(outcome)))
	finished.emit(outcome)

func _behind_black(outcome: StringName) -> void:
	if not EndingModel.clock_running(outcome):
		main.clock_model.force_stop()
		if main.sfx != null:
			main.sfx.set_casa_muted(true)
	var giant := main.get_node_or_null("GiantElias")
	if giant != null:
		giant.visible = false
	if main.hour_event != null and main.hour_event.is_active():
		main.hour_event.halt()
	_apply_echoes(EndingModel.echoes_mode(outcome))
	_figure = _new_figure()
	set_process(EndingModel.figure_alive(outcome))
	final_camera.make_current()

## Something of Elias stays: a figure sitting where he arrived, notebook on
## the lap, facing the open front door (and the camera beyond it).
func _new_figure() -> Node3D:
	var fig := Mannequin.new()
	fig.name = "NewFigure"
	fig.build(main.ELIAS_STYLE)
	fig.set_pose(&"no_chao")
	fig.add_notebook()
	fig.position = Vector3(main.SPAWN.x, 0.0, main.SPAWN.z)
	fig.rotation.y = PI
	main.add_child(fig)
	return fig

func _apply_echoes(mode: StringName) -> void:
	var echoes: Array = main.hour_event.echoes if main.hour_event != null else []
	match mode:
		&"loop":
			for e in echoes:
				if is_instance_valid(e):
					e.resume()
		&"frozen":
			for e in echoes:
				if is_instance_valid(e):
					e.freeze()
			var doll := main.get_node_or_null("Doll")
			if doll != null and doll.has_method("stop_writing"):
				doll.stop_writing()

func _process(delta: float) -> void:
	if _figure == null:
		return
	_page_t += delta
	if _page_t < PAGE_EVERY:
		return
	_page_t = 0.0
	var arm: Node3D = _figure.arm(1.0)
	if arm != null:
		var tw := create_tween()
		tw.tween_property(arm, "rotation:x", deg_to_rad(-PAGE_ARM), 0.4).set_trans(Tween.TRANS_SINE)
		tw.tween_property(arm, "rotation:x", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	if main.sfx != null:
		main.sfx.play_pencil_pattern(_figure.global_position)
