extends RefCounted
## The options (Esc), as pure state: what each one is, its range, and how it
## is kept in a ConfigFile. The defaults are the game as it was tuned, so a
## player who never opens the menu plays exactly that.

const SECTION := "opcoes"
const SILENT_DB := -80.0

const DEFAULTS := {
	&"sensitivity": 0.0022,
	&"invert_y": false,
	&"fov": 70.0,
	&"brightness": 1.0,
	&"master": 1.0,
	&"music": 1.0,
	&"effects": 1.0,
	&"fullscreen": false,
}

## Numeric options: (min, max).
const RANGES := {
	&"sensitivity": Vector2(0.0006, 0.006),
	&"fov": Vector2(60.0, 90.0),
	&"brightness": Vector2(0.6, 1.8),
	&"master": Vector2(0.0, 1.0),
	&"music": Vector2(0.0, 1.0),
	&"effects": Vector2(0.0, 1.0),
}

var values := DEFAULTS.duplicate()

func get_value(key: StringName) -> Variant:
	return values.get(key, DEFAULTS.get(key))

func set_value(key: StringName, value: Variant) -> void:
	if not DEFAULTS.has(key):
		return
	var number_for_float: bool = value is int and DEFAULTS[key] is float
	if typeof(value) != typeof(DEFAULTS[key]) and not number_for_float:
		return
	if RANGES.has(key):
		var r: Vector2 = RANGES[key]
		value = clampf(float(value), r.x, r.y)
	values[key] = value

## Linear 0..1 to bus decibels; 0 is silence.
static func db(linear: float) -> float:
	return SILENT_DB if linear <= 0.0001 else linear_to_db(linear)

func write() -> ConfigFile:
	var cfg := ConfigFile.new()
	for key in values:
		cfg.set_value(SECTION, String(key), values[key])
	return cfg

## Takes what it can from a file; anything missing or malformed stays default.
func read(cfg: ConfigFile) -> void:
	for key in DEFAULTS:
		if cfg.has_section_key(SECTION, String(key)):
			set_value(key, cfg.get_value(SECTION, String(key)))

func load_from(path: String) -> void:
	var cfg := ConfigFile.new()
	if cfg.load(path) == OK:
		read(cfg)

func save_to(path: String) -> void:
	write().save(path)
