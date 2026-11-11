extends Node
## The house's mood in the scene: dims the house lights, thickens the fog,
## raises a low hum and Elias's breath, closes in the edges of the view, and
## now and then a far room creaks or a lamp falters. dread_model.gd gives the
## numbers; nothing here comes closer to Elias or makes a loud sound. The
## lamp and the flashlight flickers ask the scare director first; the creaks
## are the house breathing, not scares.

const DreadModel = preload("res://scripts/dread_model.gd")
const ScareDirector = preload("res://scripts/scare_director.gd")

## How fast the mood follows the visit, in tension per second.
const FOLLOW := 0.05
## Floors of the rooms, and the corners the house knocks from.
const CREAK_POINTS := [
	Vector3(4.0, 0.1, 3.5), Vector3(9.4, 0.1, 4.0), Vector3(13.0, 0.1, 2.8),
	Vector3(12.5, 0.1, 7.7), Vector3(1.8, 0.1, 8.3), Vector3(-1.6, 0.1, 4.0),
	Vector3(15.28, 1.3, 0.8), Vector3(13.2, 1.3, 8.0), Vector3(6.0, 1.3, 7.6),
]
const FLASHLIGHT_ENERGY := 1.3
const SHADER := """
shader_type canvas_item;
uniform float strength = 0.35;
uniform float grain = 0.025;
void fragment() {
	vec2 p = UV - 0.5;
	p.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float edge = smoothstep(0.22, 0.85, length(p)) * strength;
	float n = fract(sin(dot(FRAGCOORD.xy + vec2(TIME * 61.0, TIME * 17.0), vec2(12.9898, 78.233))) * 43758.5453);
	COLOR = vec4(vec3(n * 0.08), clamp(edge + (n - 0.5) * grain, 0.0, 1.0));
}
"""

## Set by main before add_child.
var main: Node
var env: Environment
var hum: AudioStreamPlayer
var tension := 0.0
## A fright on top of where the visit is (a hug); it fades on its own.
var shock := 0.0
## Says when a scare may come (scare_director.gd).
var director = ScareDirector.new()

## A scene's scare, from its script (scare_director.force): true when it may play.
func scripted(kind: StringName) -> bool:
	return director.force(kind)

var _lights: Array[OmniLight3D] = []
var _base: Array[float] = []
var _dip: Array[float] = []
var _flicks: Array[Tween] = []
var _edge: ShaderMaterial
var _breath: AudioStreamPlayer
var _creak_in := 0.0
var _flicker_in := INF
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	for n in get_tree().get_nodes_in_group(&"HouseLight"):
		_lights.append(n)
		_base.append(n.light_energy)
		_dip.append(1.0)
		_flicks.append(null)
	for c in main.get_children():
		if c is WorldEnvironment:
			env = c.environment
	_breath = main.get_node_or_null("Breath")
	hum = AudioStreamPlayer.new()
	hum.name = "Hum"
	hum.stream = main.sfx.stream(&"hum")
	hum.bus = &"Casa"
	hum.autoplay = not main.sfx.silent
	add_child(hum)
	var layer := CanvasLayer.new()
	layer.layer = 0
	add_child(layer)
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = SHADER
	_edge = ShaderMaterial.new()
	_edge.shader = shader
	rect.material = _edge
	layer.add_child(rect)
	_creak_in = DreadModel.creak_delay(0.0, _rng.randf())
	set_tension(_target())

## Jump straight to a mood (tests, and the first frame).
func set_tension(t: float) -> void:
	tension = clampf(t, 0.0, 1.0)
	_apply()

func house_light_energy(i: int) -> float:
	return _lights[i].light_energy

func vignette_strength() -> float:
	return _edge.get_shader_parameter(&"strength")

func _target() -> float:
	return minf(1.0, DreadModel.tension(main.visit.act, main.visit.clock.display_minutes()) + shock)

## A Gasto held Elias: the house closes in for a while.
func scare(amount: float) -> void:
	shock = minf(0.6, shock + amount)

func _process(delta: float) -> void:
	director.set_hour(main.hour_event != null and main.hour_event.is_active())
	director.update(delta, loud_now())
	if main.autonomous:
		shock = move_toward(shock, 0.0, 0.004 * delta)
		tension = move_toward(tension, _target(), FOLLOW * delta)
		_creak_in -= delta
		if _creak_in <= 0.0:
			creak_now()
			_creak_in = DreadModel.creak_delay(tension, _rng.randf())
		if _flicker_in == INF:
			_flicker_in = DreadModel.flicker_delay(tension, _rng.randf())
		_flicker_in -= delta
		if _flicker_in <= 0.0:
			if tension > 0.8 and _rng.randf() < 0.4 and director.request(&"lanterna_pisca", true, tension):
				flicker_now(_nearest_light())
				_flicker_flashlight()
			elif director.request(&"lampada", false, tension):
				flicker_now(_nearest_light())
			_flicker_in = DreadModel.flicker_delay(tension, _rng.randf())
	_apply()

func _apply() -> void:
	var t := tension
	var scale := DreadModel.light_scale(t)
	for i in _lights.size():
		_lights[i].light_energy = _base[i] * scale * _dip[i]
	if env != null:
		env.fog_density = DreadModel.fog_density(t)
		env.ambient_light_energy = DreadModel.ambient_energy(t)
	if _breath != null:
		# After a run the breath is his own, whatever the house is doing.
		var strain: float = main.player.strain() if main.player != null else 0.0
		_breath.volume_db = maxf(DreadModel.breath_db(t), lerpf(-30.0, -9.0, strain))
		_breath.pitch_scale = maxf(DreadModel.breath_pitch(t), lerpf(1.0, 1.45, strain))
	hum.volume_db = DreadModel.hum_db(t)
	_edge.set_shader_parameter(&"strength", DreadModel.vignette(t))
	var hands = main.player.get("hands") if main.player != null else null
	if hands != null:
		hands.tremor = DreadModel.hand_tremor(t)

## Something loud is going on: a grab, or Elias out of breath from a run.
func loud_now() -> bool:
	if main.capture_fx != null and main.capture_fx.is_active():
		return true
	return main.player != null and main.player.strain() > 0.5

## A creak in a room at least four metres from Elias. Returns where, or null.
func creak_now() -> Variant:
	var i: int = DreadModel.creak_point(CREAK_POINTS, main.player.global_position, _rng.randf())
	if i < 0:
		return null
	var at: Vector3 = CREAK_POINTS[i]
	main.sfx.play_at(&"creak", at, &"Casa", -4.0)
	return at

## House light i falters: down, almost back, down again, back.
func flicker_now(i: int) -> void:
	if _flicks[i] != null and _flicks[i].is_valid():
		_flicks[i].kill()
	var set_dip := func(v: float) -> void:
		_dip[i] = v
		_apply()
	var tw := create_tween()
	tw.tween_method(set_dip, 1.0, 0.25, 0.06)
	tw.tween_method(set_dip, 0.25, 0.9, 0.12)
	tw.tween_method(set_dip, 0.9, 0.3, 0.08)
	tw.tween_method(set_dip, 0.3, 1.0, 0.34)
	_flicks[i] = tw

func _flicker_flashlight() -> void:
	var lamp: SpotLight3D = main.player.flashlight
	var tw := create_tween()
	tw.tween_property(lamp, "light_energy", FLASHLIGHT_ENERGY * 0.35, 0.05)
	tw.tween_property(lamp, "light_energy", FLASHLIGHT_ENERGY, 0.25)

func _nearest_light() -> int:
	var best := 0
	var best_d := INF
	for i in _lights.size():
		var d := _lights[i].global_position.distance_squared_to(main.player.global_position)
		if d < best_d:
			best_d = d
			best = i
	return best
