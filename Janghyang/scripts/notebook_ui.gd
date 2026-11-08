extends CanvasLayer
## Elias's catalogue notebook, drawn as paper: entries on the left page, the
## diary pages glued on the right. Numbered blank lines ahead are the only hint
## that there is more to find; there is never a total.

const Catalog = preload("res://scripts/catalog.gd")
const Data = preload("res://scripts/catalog_data.gd")

const PAPER := Color("#e9e1cc")
const RULE := Color("#b8ae96")
const GLUED := Color("#d8ccad")
const INK := Color("#2a2420")
const PENCIL := Color("#4a4440")
const BLANK_LINES := 3
const RULE_STEP := 30.0
const PEEK_TIME := 2.5
## How the pockets page names what Elias carries (hands_model.gd).
const POCKET_NAMES := {
	&"vareta": "vareta", &"espelho": "espelho", &"fosforo": "fósforo",
	&"lupa": "lupa", &"estetoscopio": "estetoscópio", &"brinquedo": "brinquedo",
	&"pilha": "pilha",
}

## Set by main: the notebook locks this player's input while open.
var player: Node
## Set by main: the lots (quest_model.gd) and the plan (atlas.gd).
var quest
var atlas

var _root: Control
var _entries_box: VBoxContainer
var _entries_scroll: ScrollContainer
var _pages_box: VBoxContainer
var _pockets: Label
var _peek: PanelContainer
var _peek_label: Label
var _peek_tween: Tween
var _final: Control
var _final_label: Label
var _font: SystemFont
var _font_pencil: SystemFont
var _open := false
var _book: Control
var _plan: Control
var _lots: RichTextLabel
var _map: Control
var _plan_pos := Vector3.ZERO
var _plan_level := &""

func _ready() -> void:
	layer = 5
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Liberation Serif", "FreeSerif", "Noto Serif", "DejaVu Serif", "Serif"])
	_font.font_italic = true
	_font_pencil = SystemFont.new()
	_font_pencil.font_names = _font.font_names
	_font_pencil.font_italic = true
	_font_pencil.font_weight = 300
	_build_book()
	_build_plan()
	_build_peek()
	_build_final()

func open() -> void:
	if _final.visible:
		return
	_open = true
	_root.visible = true
	_book.visible = true
	_plan.visible = false
	_peek.visible = false
	_pockets.text = pockets_text(player.hands_model.pockets if player != null and player.get("hands_model") != null else {})
	_set_locked(true)
	_scroll_to_end.call_deferred()

func close() -> void:
	_open = false
	_root.visible = false
	_set_locked(false)

func toggle() -> void:
	if _open and _book.visible:
		close()
	else:
		open()

## The other spread: the lots of the visit, and the plan Elias drew as he
## went, on the sheet of the floor he is on.
func open_plan(pos: Vector3) -> void:
	if _final.visible or quest == null or atlas == null:
		return
	_open = true
	_root.visible = true
	_book.visible = false
	_plan.visible = true
	_peek.visible = false
	_plan_pos = pos
	_plan_level = atlas.level_of(atlas.room_at(pos))
	_lots.text = _lots_bbcode()
	_map.queue_redraw()
	_set_locked(true)

func toggle_plan(pos: Vector3) -> void:
	if _open and _plan.visible:
		close()
	else:
		open_plan(pos)

## A line of paper at the bottom of the screen, for what is not an entry.
func peek_text(text: String) -> void:
	peek({"number": 0, "text": text})
	_peek_label.text = text

## The pockets page, in pencil: the watch first (always his), then the rest
## in the order of the wheel, with a count when there is more than one.
static func pockets_text(pockets: Dictionary) -> String:
	var parts: Array[String] = ["relógio"]
	var keys: Array = pockets.keys()
	keys.sort_custom(func(a, b) -> bool: return _pocket_rank(a) < _pocket_rank(b))
	for k in keys:
		var n := int(pockets[k])
		if n <= 0:
			continue
		var name: String = POCKET_NAMES.get(k, String(k))
		parts.append(name if n == 1 else "%s ×%d" % [name, n])
	return "bolsos — " + " · ".join(parts)

static func _pocket_rank(item: StringName) -> int:
	var order: Array = POCKET_NAMES.keys()
	var i := order.find(item)
	return i if i >= 0 else order.size()

func pockets_shown() -> String:
	return _pockets.text

func is_open() -> bool:
	return _open

func refresh(catalog) -> void:
	for c in _entries_box.get_children():
		_entries_box.remove_child(c)
		c.queue_free()
	for c in _pages_box.get_children():
		_pages_box.remove_child(c)
		c.queue_free()
	for entry in catalog.entries:
		var line := _line(Catalog.format(entry), PENCIL if entry.author == &"duplo" else INK)
		if entry.author == &"duplo":
			line.add_theme_font_override("font", _font_pencil)
		_entries_box.add_child(line)
	var next: int = catalog.next_number()
	for i in BLANK_LINES:
		_entries_box.add_child(_line("Item %d —" % (next + i), RULE.darkened(0.25)))
	var tilt := -1.0
	for page_id in catalog.pages:
		_pages_box.add_child(_glued_page(String(Data.PAGES.get(page_id, "")), tilt))
		tilt = -tilt

## A strip of paper with the newest line, briefly, at the bottom of the screen.
func peek(entry: Dictionary) -> void:
	_peek_label.text = Catalog.format(entry)
	_peek.visible = true
	_peek.modulate.a = 0.0
	if _peek_tween != null and _peek_tween.is_valid():
		_peek_tween.kill()
	_peek_tween = create_tween()
	_peek_tween.tween_property(_peek, "modulate:a", 1.0, 0.3)
	_peek_tween.tween_interval(PEEK_TIME)
	_peek_tween.tween_property(_peek, "modulate:a", 0.0, 0.6)
	_peek_tween.tween_callback(func() -> void: _peek.visible = false)

## The closing image: one last entry on a page, nothing else.
## The player stays locked: the visit is over.
func show_final(text: String) -> void:
	_open = false
	_root.visible = false
	_peek.visible = false
	_final_label.text = text
	_final.visible = true
	_final.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_final, "modulate:a", 1.0, 2.5)

## Both visible pages as plain text (for tests).
func page_text() -> String:
	var parts: Array[String] = []
	for c in _entries_box.get_children():
		parts.append((c as Label).text)
	for c in _pages_box.get_children():
		var label := c.get_child(0) as Label
		parts.append(label.text)
	return "\n".join(parts)

## The plan spread as plain text (for tests): lots, sheets and rooms drawn.
func plan_text() -> String:
	var parts: Array[String] = [_lots.text]
	for lvl in _levels_seen():
		parts.append(String(atlas.levels()[lvl]))
	for id in _rooms_drawn():
		parts.append(String(atlas.room(id).name))
	return "\n".join(parts)

func _lots_bbcode() -> String:
	var out: Array[String] = ["[font_size=21]Lotes[/font_size]", ""]
	for i in quest.phase + 1:
		out.append("[b]%s[/b]" % quest.phases[i].title)
		for t in quest.current_tasks(i):
			out.append(("   [s]%s[/s]" if t.done else "   %s") % t.text)
		out.append("")
	return "\n".join(out)

func _levels_seen() -> Array[StringName]:
	var out: Array[StringName] = []
	for lvl in atlas.levels():
		for id in atlas.rooms_on(lvl):
			if atlas.visited.has(id):
				out.append(lvl)
				break
	return out

func _rooms_drawn() -> Array[StringName]:
	var out: Array[StringName] = []
	for id in atlas.rooms_on(_plan_level):
		if atlas.visited.has(id):
			out.append(id)
	return out

## Visited rooms of the sheet, in pencil, fitted to the page; an x for Elias.
## Pixels per metre on the plan page.
const MAP_SCALE := 20.0

func _draw_map() -> void:
	var tabs_y := 30.0
	var x := 26.0
	for lvl in _levels_seen():
		var name := String(atlas.levels()[lvl])
		var col := INK if lvl == _plan_level else RULE.darkened(0.3)
		_map.draw_string(_font, Vector2(x, tabs_y), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, col)
		var w := _font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		if lvl == _plan_level:
			_map.draw_line(Vector2(x, tabs_y + 4.0), Vector2(x + w, tabs_y + 4.0), INK, 1.5)
		x += w + 18.0
	var ids := _rooms_drawn()
	if ids.is_empty():
		return
	var all := Rect2()
	var first := true
	for id in atlas.rooms_on(_plan_level):
		var r: Rect2 = atlas.room(id).rect
		all = r if first else all.merge(r)
		first = false
	var area := Rect2(30.0, 60.0, _map.size.x - 60.0, _map.size.y - 90.0)
	# One scale for every floor (a small tower stays small), unless the floor is too big for the page.
	var k := minf(MAP_SCALE, minf(area.size.x / all.size.x, area.size.y / all.size.y))
	var origin := area.position + (area.size - all.size * k) * 0.5
	var to_page := func(p: Vector2) -> Vector2: return origin + (p - all.position) * k
	for id in ids:
		var r: Rect2 = atlas.room(id).rect
		var a: Vector2 = to_page.call(r.position)
		var page_rect := Rect2(a, r.size * k)
		_map.draw_rect(page_rect, Color(PENCIL, 0.08), true)
		_map.draw_rect(page_rect, PENCIL, false, 1.4)
		var label := String(atlas.room(id).name)
		var fs := 13 if page_rect.size.x > 70.0 else 11
		_map.draw_string(_font, page_rect.position + Vector2(5.0, 16.0), label, HORIZONTAL_ALIGNMENT_LEFT, page_rect.size.x - 8.0, fs, PENCIL)
	var me: Vector2 = to_page.call(Vector2(_plan_pos.x, _plan_pos.z))
	_map.draw_line(me + Vector2(-6, -6), me + Vector2(6, 6), INK, 2.0)
	_map.draw_line(me + Vector2(-6, 6), me + Vector2(6, -6), INK, 2.0)

func _set_locked(on: bool) -> void:
	if player != null:
		player.input_locked = on
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if on else Input.MOUSE_MODE_CAPTURED)

func _scroll_to_end() -> void:
	_entries_scroll.scroll_vertical = int(_entries_scroll.get_v_scroll_bar().max_value)

func _line(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(380.0, 0.0)
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 9)
	return label

func _glued_page(text: String, tilt: float) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = GLUED
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	style.shadow_color = Color(0, 0, 0, 0.18)
	style.shadow_size = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.rotation_degrees = tilt * 1.2
	var label := _line(text, INK)
	label.add_theme_font_size_override("font_size", 16)
	label.custom_minimum_size = Vector2(360.0, 0.0)
	panel.add_child(label)
	return panel

func _paper(rect: Rect2) -> Panel:
	var page := Panel.new()
	page.position = rect.position
	page.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	page.add_theme_stylebox_override("panel", style)
	page.draw.connect(func() -> void:
		var y := 64.0
		while y < page.size.y - 20.0:
			page.draw_line(Vector2(24.0, y), Vector2(page.size.x - 24.0, y), RULE, 1.0)
			y += RULE_STEP)
	return page

func _build_book() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var book := Control.new()
	_book = book
	book.set_anchors_preset(Control.PRESET_CENTER)
	book.offset_left = -470.0
	book.offset_right = 470.0
	book.offset_top = -290.0
	book.offset_bottom = 290.0
	_root.add_child(book)
	var left := _paper(Rect2(0.0, 0.0, 465.0, 580.0))
	var right := _paper(Rect2(475.0, 0.0, 465.0, 580.0))
	book.add_child(left)
	book.add_child(right)
	var spine := ColorRect.new()
	spine.color = Color("#8a7f68")
	spine.position = Vector2(465.0, 0.0)
	spine.size = Vector2(10.0, 580.0)
	book.add_child(spine)

	_entries_scroll = ScrollContainer.new()
	_entries_scroll.position = Vector2(28.0, 40.0)
	_entries_scroll.size = Vector2(420.0, 520.0)
	_entries_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_entries_scroll.focus_mode = Control.FOCUS_NONE
	left.add_child(_entries_scroll)
	_entries_box = VBoxContainer.new()
	_entries_box.add_theme_constant_override("separation", 12)
	_entries_scroll.add_child(_entries_box)

	_pockets = _line("", PENCIL)
	_pockets.add_theme_font_override("font", _font_pencil)
	_pockets.position = Vector2(30.0, 24.0)
	_pockets.size = Vector2(415.0, 60.0)
	right.add_child(_pockets)

	var pages_scroll := ScrollContainer.new()
	pages_scroll.position = Vector2(30.0, 90.0)
	pages_scroll.size = Vector2(415.0, 470.0)
	pages_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pages_scroll.focus_mode = Control.FOCUS_NONE
	right.add_child(pages_scroll)
	_pages_box = VBoxContainer.new()
	_pages_box.add_theme_constant_override("separation", 22)
	pages_scroll.add_child(_pages_box)

func _build_plan() -> void:
	_plan = Control.new()
	_plan.set_anchors_preset(Control.PRESET_CENTER)
	_plan.offset_left = -470.0
	_plan.offset_right = 470.0
	_plan.offset_top = -290.0
	_plan.offset_bottom = 290.0
	_plan.visible = false
	_root.add_child(_plan)
	var left := _paper(Rect2(0.0, 0.0, 465.0, 580.0))
	var right := _paper(Rect2(475.0, 0.0, 465.0, 580.0))
	_plan.add_child(left)
	_plan.add_child(right)
	var spine := ColorRect.new()
	spine.color = Color("#8a7f68")
	spine.position = Vector2(465.0, 0.0)
	spine.size = Vector2(10.0, 580.0)
	_plan.add_child(spine)
	_lots = RichTextLabel.new()
	_lots.bbcode_enabled = true
	_lots.position = Vector2(30.0, 34.0)
	_lots.size = Vector2(410.0, 530.0)
	_lots.add_theme_font_override("normal_font", _font)
	_lots.add_theme_font_override("bold_font", _font)
	_lots.add_theme_font_size_override("normal_font_size", 17)
	_lots.add_theme_font_size_override("bold_font_size", 18)
	_lots.add_theme_color_override("default_color", INK)
	_lots.add_theme_constant_override("line_separation", 9)
	_lots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(_lots)
	_map = Control.new()
	_map.position = Vector2.ZERO
	_map.size = Vector2(465.0, 580.0)
	_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map.draw.connect(_draw_map)
	right.add_child(_map)

func _build_peek() -> void:
	_peek = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 5
	_peek.add_theme_stylebox_override("panel", style)
	_peek.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_peek.offset_left = 28.0
	_peek.offset_top = -120.0
	_peek.offset_right = 520.0
	_peek.offset_bottom = -30.0
	_peek.rotation_degrees = -1.0
	_peek.visible = false
	_peek.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_peek)
	_peek_label = _line("", INK)
	_peek_label.custom_minimum_size = Vector2(460.0, 0.0)
	_peek.add_child(_peek_label)

func _build_final() -> void:
	_final = Control.new()
	_final.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_final.visible = false
	add_child(_final)
	var black := ColorRect.new()
	black.color = Color(0.02, 0.018, 0.016)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_final.add_child(black)
	var page := _paper(Rect2(0.0, 0.0, 560.0, 300.0))
	page.set_anchors_preset(Control.PRESET_CENTER)
	page.offset_left = -280.0
	page.offset_right = 280.0
	page.offset_top = -150.0
	page.offset_bottom = 150.0
	_final.add_child(page)
	_final_label = _line("", INK)
	_final_label.position = Vector2(40.0, 58.0)
	_final_label.size = Vector2(480.0, 200.0)
	_final_label.custom_minimum_size = Vector2(480.0, 0.0)
	page.add_child(_final_label)
