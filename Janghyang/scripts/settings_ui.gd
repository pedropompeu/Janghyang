extends CanvasLayer
## Esc: the game stops and a sheet of the same paper as the notebook comes
## up with the options (settings_model.gd). Every change applies at once;
## closing saves them to user:// so the next visit starts the same way.

const Settings = preload("res://scripts/settings_model.gd")
const PATH := "user://opcoes.cfg"

const PAPER := Color("#e9e1cc")
const RULE := Color("#b8ae96")
const INK := Color("#2a2420")
const PENCIL := Color("#4a4440")

## (key, label) in the order they appear on the sheet.
const ROWS := [
	[&"sensitivity", "Sensibilidade do mouse"],
	[&"invert_y", "Inverter o eixo vertical"],
	[&"fov", "Campo de visão"],
	[&"brightness", "Brilho"],
	[&"master", "Volume geral"],
	[&"music", "Música"],
	[&"effects", "Sons da casa e do mundo"],
	[&"fullscreen", "Tela cheia"],
]

## Set by main before add_child. An empty path keeps the file untouched
## (selftest, tour, captures).
var main: Node
var path := PATH
var model := Settings.new()
var _sheet: Control
var _font: SystemFont
var _readouts := {}
var _controls := {}

func _ready() -> void:
	name = "Opcoes"
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Liberation Serif", "FreeSerif", "Noto Serif", "DejaVu Serif", "Serif"])
	_font.font_italic = true
	if path != "":
		model.load_from(path)
	_build()
	_sheet.visible = false
	for row in ROWS:
		_apply(row[0], false)

func is_open() -> bool:
	return _sheet.visible

func open() -> void:
	_sync_controls()
	_sheet.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close() -> void:
	_sheet.visible = false
	get_tree().paused = false
	if path != "":
		model.save_to(path)
	var reading: bool = main.notebook != null and main.notebook.is_open()
	if not reading and not main.ended:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle() -> void:
	if is_open():
		close()
	else:
		open()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE:
		toggle()
		get_viewport().set_input_as_handled()

## Change one option as the menu does: store, apply, show.
func change(key: StringName, value: Variant) -> void:
	model.set_value(key, value)
	_apply(key, true)
	_show_value(key)

func _apply(key: StringName, user_changed: bool) -> void:
	var v: Variant = model.get_value(key)
	var player: Node = main.player
	match key:
		&"sensitivity":
			player.mouse_sensitivity = v
		&"invert_y":
			player.invert_y = v
		&"fov":
			player.set_base_fov(v)
		&"brightness":
			for we in main.find_children("*", "WorldEnvironment", false, false):
				we.environment.tonemap_exposure = v
		&"master":
			_bus_volume(&"Master", v)
		&"music":
			_bus_volume(&"Musica", v)
		&"effects":
			_bus_volume(&"Casa", v)
			_bus_volume(&"Mundo", v)
		&"fullscreen":
			# At start only a saved "on" acts, so a window stays a window.
			if user_changed or v:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if v else DisplayServer.WINDOW_MODE_WINDOWED)

func _bus_volume(bus: StringName, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, Settings.db(linear))

# ---------------------------------------------------------------------------
# The sheet
# ---------------------------------------------------------------------------

func _build() -> void:
	_sheet = Control.new()
	_sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_sheet)
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sheet.add_child(dim)

	var paper := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.content_margin_left = 40.0
	style.content_margin_right = 40.0
	style.content_margin_top = 28.0
	style.content_margin_bottom = 28.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	style.shadow_size = 12
	paper.add_theme_stylebox_override("panel", style)
	paper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	paper.grow_horizontal = Control.GROW_DIRECTION_BOTH
	paper.grow_vertical = Control.GROW_DIRECTION_BOTH
	_sheet.add_child(paper)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	paper.add_child(col)
	col.add_child(_text("Opções", 30, INK))
	col.add_child(_text("O jogo para enquanto esta folha está aberta.", 15, PENCIL))
	col.add_child(_rule())

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 10)
	col.add_child(grid)
	for row in ROWS:
		var key: StringName = row[0]
		grid.add_child(_text(row[1], 19, INK))
		var control: Control
		if Settings.RANGES.has(key):
			var slider := HSlider.new()
			var r: Vector2 = Settings.RANGES[key]
			slider.min_value = r.x
			slider.max_value = r.y
			slider.step = (r.y - r.x) / 100.0
			slider.custom_minimum_size = Vector2(240.0, 24.0)
			slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			slider.value_changed.connect(func(v: float) -> void: change(key, v))
			control = slider
		else:
			var box := CheckBox.new()
			box.toggled.connect(func(on: bool) -> void: change(key, on))
			control = box
		grid.add_child(control)
		_controls[key] = control
		var readout := _text("", 17, PENCIL)
		readout.custom_minimum_size = Vector2(64.0, 0.0)
		grid.add_child(readout)
		_readouts[key] = readout

	col.add_child(_rule())
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 18)
	col.add_child(buttons)
	buttons.add_child(_button("Continuar (Esc)", close))
	buttons.add_child(_button("Padrões", _reset))
	buttons.add_child(_button("Reiniciar (R)", func() -> void:
		close()
		get_tree().reload_current_scene()))
	buttons.add_child(_button("Sair do jogo", func() -> void:
		close()
		main.shutdown()))

func _sync_controls() -> void:
	for row in ROWS:
		var key: StringName = row[0]
		var c: Control = _controls[key]
		if c is HSlider:
			c.set_value_no_signal(model.get_value(key))
		else:
			c.set_pressed_no_signal(model.get_value(key))
		_show_value(key)

func _reset() -> void:
	for key in Settings.DEFAULTS:
		change(key, Settings.DEFAULTS[key])
	_sync_controls()

func _show_value(key: StringName) -> void:
	var v: Variant = model.get_value(key)
	var label: Label = _readouts.get(key)
	if label == null:
		return
	match key:
		&"sensitivity":
			label.text = ("%.1f×" % (v / Settings.DEFAULTS[key])).replace(".", ",")
		&"fov":
			label.text = "%d°" % roundi(v)
		&"brightness", &"master", &"music", &"effects":
			label.text = "%d%%" % roundi(v * 100.0)
		_:
			label.text = "sim" if v else "não"

func _text(s: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _rule() -> ColorRect:
	var r := ColorRect.new()
	r.color = RULE
	r.custom_minimum_size = Vector2(0.0, 1.0)
	return r

func _button(s: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = s
	b.flat = true
	b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 19)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(state, INK if state != "font_hover_color" else Color("#7a2a1e"))
	b.pressed.connect(action)
	return b
