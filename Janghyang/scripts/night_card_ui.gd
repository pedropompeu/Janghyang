extends CanvasLayer
## The paper between two nights (spec §5.1): the date in the notebook and what
## the night was about. The game has just saved. Any key or click goes on.
## The hypothesis page of each chapter comes with the chapters (Tarefa 23 on);
## until then the card lists the night's chapters. Copy is a draft (D9).

const NotebookUI = preload("res://scripts/notebook_ui.gd")

## The last line of the demo's last card.
const DEMO_END := "Aqui termina a demonstração. Obrigado por jogar."

signal closed
## The letter (show_letter) was put down.
signal letter_closed

## Set by main: the card holds this player still while it is up.
var player: Node

var _root: Control
var _label: Label
var _open := false
var _final := false
var _letter := false
var _shown_ms := 0

## The key that wound the clock must not also turn the card.
const INPUT_GRACE_MS := 600

static func night_text(night: Dictionary, last := false) -> String:
	var lines: Array[String] = [String(night.get("date", "")), ""]
	for c in night.get("chapters", []):
		lines.append(c.title)
	lines.append("")
	lines.append(DEMO_END if last else "Elias acorda na bancada. Amanhã, de novo.")
	return "\n".join(lines)

func _ready() -> void:
	layer = 6
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	var black := ColorRect.new()
	black.color = Color(0.02, 0.018, 0.016)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(black)
	var page := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = NotebookUI.PAPER
	page.add_theme_stylebox_override("panel", style)
	page.set_anchors_preset(Control.PRESET_CENTER)
	page.offset_left = -300.0
	page.offset_right = 300.0
	page.offset_top = -190.0
	page.offset_bottom = 190.0
	_root.add_child(page)
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Liberation Serif", "FreeSerif", "Noto Serif", "DejaVu Serif", "Serif"])
	font.font_italic = true
	_label = Label.new()
	_label.position = Vector2(44.0, 48.0)
	_label.size = Vector2(512.0, 290.0)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", 19)
	_label.add_theme_color_override("font_color", NotebookUI.INK)
	_label.add_theme_constant_override("line_spacing", 9)
	page.add_child(_label)

## Shows the card for the night that just ended. On the demo's last night the
## card stays: there is no next night to go on to.
func show_night(night: Dictionary, last := false) -> void:
	_label.text = night_text(night, last)
	_final = last
	_letter = false
	_shown_ms = Time.get_ticks_msec()
	_open = true
	_root.visible = true
	if player != null:
		player.input_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## A letter on the same paper (night 1's, spec §7.3): any key puts it down.
func show_letter(text: String) -> void:
	_label.text = text
	_final = false
	_letter = true
	_shown_ms = Time.get_ticks_msec()
	_open = true
	_root.visible = true
	if player != null:
		player.input_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_letter() -> bool:
	return _open and _letter

func is_open() -> bool:
	return _open

func text() -> String:
	return _label.text if _open else ""

func close() -> void:
	if not _open or _final:
		return
	_open = false
	_root.visible = false
	if player != null:
		player.input_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if _letter:
		_letter = false
		letter_closed.emit()
	else:
		closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	# The demo's last card leaves Esc to the settings (and their quit).
	if not _open or _final or Time.get_ticks_msec() - _shown_ms < INPUT_GRACE_MS:
		return
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed and not event.is_echo():
		get_viewport().set_input_as_handled()
		close()
