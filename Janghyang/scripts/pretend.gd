extends CanvasLayer
## Fazer de conta: Elias closes his eyes and the house comes back as it was.
## The eyelids come down, the room returns in afternoon sepia, and what the
## boy left in chalk (arrows, crosses, a door drawn on a wall) shows. Opening
## the eyes reverses it. The Gastos are not seen meanwhile (gastos.gd).

const SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	vec3 sepia = pow(vec3(l), vec3(0.8)) * vec3(1.32, 1.06, 0.74) + vec3(0.09, 0.06, 0.02);
	vec2 p = UV - 0.5;
	float edge = smoothstep(0.25, 0.85, length(p));
	COLOR = vec4(mix(sepia, sepia * 0.5, edge), 1.0);
}
"""
const CLOSE := 0.22
const OPEN := 0.38

## Set by main before add_child.
var main: Node
var memory := false
var _memory: ColorRect
var _top: ColorRect
var _bottom: ColorRect
var _tween: Tween

func _ready() -> void:
	name = "Pretend"
	layer = 3
	_memory = ColorRect.new()
	_memory.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_memory.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER
	sm.shader = sh
	_memory.material = sm
	_memory.visible = false
	add_child(_memory)
	_top = _lid(Control.PRESET_TOP_WIDE)
	_bottom = _lid(Control.PRESET_BOTTOM_WIDE)
	main.player.pretend_changed.connect(_on_pretend)

func _lid(preset: Control.LayoutPreset) -> ColorRect:
	var lid := ColorRect.new()
	lid.color = Color(0.03, 0.02, 0.02)
	lid.set_anchors_preset(preset)
	lid.anchor_bottom = 0.0 if preset == Control.PRESET_TOP_WIDE else 1.0
	lid.anchor_top = 0.0 if preset == Control.PRESET_TOP_WIDE else 1.0
	lid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lid)
	return lid

## 0 open .. 1 shut: each lid covers half the screen.
func _set_shut(v: float) -> void:
	var half := get_viewport().get_visible_rect().size.y * 0.5 * v
	_top.offset_top = 0.0
	_top.offset_bottom = half
	_bottom.offset_top = -half
	_bottom.offset_bottom = 0.0

func _on_pretend(on: bool) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_shut, 0.0, 1.0, CLOSE)
	_tween.tween_callback(set_memory.bind(on))
	_tween.tween_method(_set_shut, 1.0, 0.0, OPEN).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func set_memory(on: bool) -> void:
	memory = on
	_memory.visible = on
	for c in get_tree().get_nodes_in_group(&"Chalk"):
		c.visible = on
	if main.get("gastos") != null:
		main.gastos.set_veiled(on)
