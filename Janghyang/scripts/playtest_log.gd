extends Node
## The playtest log (playtest 1, U50): with --playtest, every INTERVAL
## seconds one CSV line in user://playtest/<date-time>.csv with where the
## player is, what the watch is after and how far, whether the watch and the
## notebook are open, how many grabs, and whether lost_model.gd says lost.

const LostModel = preload("res://scripts/lost_model.gd")

const INTERVAL := 5.0
const COLUMNS := ["t", "noite", "area", "comodo", "meta", "dist", "relogio_aberto", "caderno_aberto", "capturas", "perdido"]

## Set by main before add_child.
var main: Node
var path := ""
var lost = LostModel.new()
var _file: FileAccess
var _t := 0.0
var _next := 0.0

static func header() -> String:
	return ",".join(COLUMNS)

## One line, in COLUMNS order; a missing value is left empty.
static func row(d: Dictionary) -> String:
	var out: PackedStringArray = []
	for c in COLUMNS:
		var v = d.get(c, "")
		if v is float:
			v = "%.1f" % v if is_finite(v) else ""
		elif v is bool:
			v = "1" if v else "0"
		out.append(str(v).replace(",", ";"))
	return ",".join(out)

func _ready() -> void:
	if path == "":
		path = "user://playtest/%s.csv" % Time.get_datetime_string_from_system().replace(":", "-")
	start(path)

func start(at: String) -> void:
	path = at
	DirAccess.make_dir_recursive_absolute(at.get_base_dir())
	_file = FileAccess.open(at, FileAccess.WRITE)
	if _file != null:
		_file.store_line(header())
		_file.flush()

func stop() -> void:
	if _file != null:
		_file.close()
		_file = null

func _exit_tree() -> void:
	stop()

## What the log writes now.
func sample() -> Dictionary:
	var d := {"t": _t, "capturas": main.get("grabs")}
	d["noite"] = main.night.get("n", main.campaign.night if main.campaign != null else 0)
	var p: Node3D = main.player
	var goal: Dictionary = main.watch_goal()
	d["meta"] = goal.get("task", "")
	d["perdido"] = lost.is_lost()
	if p != null:
		var room: StringName = main.atlas.room_at(p.global_position)
		d["comodo"] = room
		d["area"] = main.atlas.level_of(room)
		if goal.has("at"):
			d["dist"] = p.global_position.distance_to(goal.at)
	d["relogio_aberto"] = main.pocket_watch != null and main.pocket_watch.is_open
	d["caderno_aberto"] = main.notebook != null and main.notebook.is_open()
	return d

func write_row() -> void:
	if _file != null:
		_file.store_line(row(sample()))
		_file.flush()

func _process(delta: float) -> void:
	if main == null or main.player == null:
		return
	_t += delta
	var goal: Dictionary = main.watch_goal()
	var dist := INF
	if goal.has("at"):
		dist = main.player.global_position.distance_to(goal.at)
	lost.update(delta, dist, goal.get("task", &""))
	_next -= delta
	if _next <= 0.0:
		_next = INTERVAL
		write_row()
