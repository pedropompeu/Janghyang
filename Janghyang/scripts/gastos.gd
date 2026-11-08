extends Node3D
## The Gastos: Inácio and the catalogers before Elias, worn thin by the loop.
## Mannequin bodies, cracked porcelain faces with no eyes, long hands. Each
## one is a stalker_model.gd on a graph of lurk points for the floor Elias is
## on; they hop only while nobody looks, freeze in light, come apart under a
## long stare or the stick, and hug him when they reach him unseen.
## No floor is a refuge any more (spec §11): the house has its graph too, and
## the night's `safety` rule (safety_model.gd) says which points they never
## step onto and where they never hug him.

const StalkerModel = preload("res://scripts/stalker_model.gd")
const Atlas = preload("res://scripts/atlas.gd")
const Mannequin = preload("res://scripts/mannequin.gd")
const Safety = preload("res://scripts/safety_model.gd")
const Registry = preload("res://scripts/areas/registry.gd")
const Capture = preload("res://scripts/capture_model.gd")
const NoiseModel = preload("res://scripts/noise_model.gd")

## Night 5 asks for three.
const MAX := 3
## Lurk points are sampled on this grid, then joined when one can see the other.
const GRID := 2.2
const LINK := 3.4
const HEAD := 1.45
const NEAR := 1.9
## No lurk point this close (flat) to a keep_clear door: past arm's reach.
const KEEP_CLEAR := NEAR + 0.6
## A door joins the rooms on its two sides with a point this far from it.
const PORTAL := 0.6
## Gone this long when Elias changes floors; the second one later.
const FOLLOW := 6.0
const FOLLOW_STAGGER := 9.0
const VIEW_EVERY := 0.12
const STYLE := {"coat": Color("#56504a"), "skin": Color("#ece6d8"), "hair": Color("#ece6d8"), "trousers": Color("#38332e")}
## Layer of their hitboxes: the stick finds them, bodies and sight lines don't.
const HIT_LAYER := 8

## The night being played (noites.gd); empty on today's single visit.
var night: Dictionary = {}
## Rule relogio_entrada (§11): the house is safe while the entry clock still
## has spring; a test may force it. null follows main.clock_model.
var entry_wound = null
## The wound anchor clocks: [{"at": Vector3, "left": float}] (none yet).
var anchors: Array = []

## A Gasto reached Elias and holds him (capture_model.gd): he fights it off
## (broke_free) or it hugs him (caught).
signal grabbed(gasto: int)
signal broke_free(gasto: int)
signal caught(gasto: int)

## The fight going on or just over; null before the first grab.
var capture = null

## Set by main before add_child.
var main: Node
var level := &""
var veiled := false
var _graphs := {}
var _models: Array = []
var _bodies: Array[Node3D] = []
var _hitboxes: Array[StaticBody3D] = []
var _lamps: Array[OmniLight3D] = []
## The doors (foldables named Door*): sight lines of the graph go through
## them, open or shut, so every room of a floor joins the others.
var _doors: Array[Node3D] = []
var _door_rids: Array[RID] = []
var _in_view: Array = []
## Lurk points of this floor that are safe now, and whether Elias is; both
## follow the night's rule and are refreshed with the view.
var _safe: Array = []
var _elias_safe := false
var _view_in := 0.0
var _tick_in := 1.5
var _rng := RandomNumberGenerator.new()
## Gasto index -> {"at": Vector3, "left": seconds}: the last noise it heard.
var _heard := {}

func _ready() -> void:
	name = "Gastos"
	_rng.seed = 333
	for i in MAX:
		var body: Node3D = Mannequin.new()
		body.name = "Gasto%d" % i
		body.build(STYLE, 1.02)
		_dress(body)
		body.visible = false
		add_child(body)
		_bodies.append(body)
		var hb := StaticBody3D.new()
		hb.name = "Hitbox"
		hb.collision_layer = HIT_LAYER
		hb.collision_mask = 0
		hb.add_to_group(&"Gasto")
		hb.set_meta(&"gasto", i)
		var cs := CollisionShape3D.new()
		var cap := CapsuleShape3D.new()
		cap.radius = 0.26
		cap.height = 1.75
		cs.shape = cap
		cs.position.y = 0.88
		cs.disabled = true
		hb.add_child(cs)
		body.add_child(hb)
		_hitboxes.append(hb)
	_build_graphs_when_solid()

## Cracks and long hands over the mannequin: a person turned into a piece.
func _dress(body: Node3D) -> void:
	var crack := StandardMaterial3D.new()
	crack.albedo_color = Color(0.12, 0.1, 0.09)
	var porcelain := StandardMaterial3D.new()
	porcelain.albedo_color = STYLE.skin
	porcelain.roughness = 0.25
	var head: Node3D = body._head
	for c in [[Vector3(0.012, 0.13, 0.01), Vector3(0.02, 0.16, -0.105), 0.3], [Vector3(0.01, 0.08, 0.01), Vector3(-0.03, 0.1, -0.1), -0.6]]:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = c[0]
		mi.mesh = bm
		mi.material_override = crack
		mi.position = c[1]
		mi.rotation.z = c[2]
		head.add_child(mi)
	for side in [-1.0, 1.0]:
		var arm: Node3D = body.arm(side)
		for f in 3:
			var mi := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.025, 0.26, 0.025)
			mi.mesh = bm
			mi.material_override = porcelain
			mi.position = Vector3((f - 1) * 0.032, -0.7, 0.0)
			arm.add_child(mi)

# ---------------------------------------------------------------------------
# Lurk points
# ---------------------------------------------------------------------------

func graph(lvl: StringName) -> Dictionary:
	return _graphs.get(lvl, {"points": [], "links": []})

## Sight lines need the world in the physics space: wait a step first.
func _build_graphs_when_solid() -> void:
	await get_tree().physics_frame
	_build_graphs()
	if level != &"":
		on_level(level)

func _build_graphs() -> void:
	var atlas := Atlas.new()
	for l in main.find_children("*", "OmniLight3D", true, false):
		add_lamp(l)
	for d in main.find_children("Door*", "AnimatableBody3D", true, false):
		_doors.append(d)
		_door_rids.append((d as CollisionObject3D).get_rid())
	for lvl in Atlas.levels():
		var pts: Array[Vector3] = []
		var pairs: Array = []
		for r in Atlas.rooms():
			if r.level != lvl:
				continue
			for x in _rows(r.rect.position.x, r.rect.size.x):
				for z in _rows(r.rect.position.y, r.rect.size.y):
					for p in _floors_at(x, z, r.y):
						if atlas.room_at(p) == r.id:
							pts.append(p)
		for d in _doors:
			var side := _door_sides(d, lvl, atlas)
			if side.size() == 2:
				pairs.append([pts.size(), pts.size() + 1])
				pts.append_array(side)
		var clear: Array[Vector3] = []
		for name in Registry.def(lvl).get("keep_clear", []):
			var door := main.find_child(String(name), true, false)
			if door != null:
				clear.append(door_center(door))
		_graphs[lvl] = _largest_part(pts, pairs, clear)

## The middle of door `d`'s opening, shut, at its foot.
static func door_center(d: Node3D) -> Vector3:
	var panel: Node3D = d.get_child(0)
	var c: Vector3 = d.get_parent().global_transform * (d.position + Basis.from_euler(d.rotation_a) * panel.position)
	return Vector3(c.x, d.get_parent().global_transform.origin.y + d.position.y, c.z)

## One floor point on each side of door `d`, both in rooms of `lvl`; [] when
## the door is not a wall door of that floor.
func _door_sides(d: Node3D, lvl: StringName, atlas) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var panel := d.get_child(0) as MeshInstance3D
	if panel == null or not panel.mesh is BoxMesh:
		return out
	var size: Vector3 = (panel.mesh as BoxMesh).size
	var axis := Vector3.RIGHT if size.x <= minf(size.y, size.z) else (Vector3.BACK if size.z <= size.y else Vector3.UP)
	var n: Vector3 = d.get_parent().global_transform.basis * (Basis.from_euler(d.rotation_a) * axis)
	n.y = 0.0
	if n.length() < 0.5:
		return out
	n = n.normalized()
	var c := door_center(d)
	for s in [-1.0, 1.0]:
		var q: Vector3 = c + n * PORTAL * s
		var room_id: StringName = atlas.room_at(q + Vector3(0.0, 0.3, 0.0))
		var band := Vector2.ZERO
		for r in Atlas.rooms():
			if r.id == room_id and r.level == lvl:
				band = r.y
		var floors := _floors_at(q.x, q.z, band) if band != Vector2.ZERO else ([] as Array[Vector3])
		if floors.is_empty():
			out.clear()
			return out
		out.append(floors[0])
	return out

## Sample lines across a room, centred so a narrow crawl gets its middle.
func _rows(start: float, size: float) -> Array[float]:
	var n := maxi(1, floori(size / GRID))
	var first := start + (size - (n - 1) * GRID) * 0.5
	var out: Array[float] = []
	for i in n:
		out.append(first + i * GRID)
	return out

## Every floor at (x, z) inside the height band where a hunched body fits.
func _floors_at(x: float, z: float, band: Vector2) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var space := get_world_3d().direct_space_state
	var top := band.y - 0.05
	while top > band.x:
		var q := PhysicsRayQueryParameters3D.create(Vector3(x, top, z), Vector3(x, band.x, z), 1)
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var p: Vector3 = hit.position
		if hit.normal.y > 0.7 and _fits(p):
			out.append(p)
		top = p.y - 0.15
	return out

func _fits(p: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var sphere := SphereShape3D.new()
	sphere.radius = 0.22
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = sphere
	q.collision_mask = 1
	q.exclude = _door_rids
	for h in [0.45, 0.95]:
		q.transform = Transform3D(Basis(), p + Vector3(0.0, h, 0.0))
		if not space.intersect_shape(q, 1).is_empty():
			return false
	return true

## Links between points that see each other (through doors), plus each door's
## two sides; points near a `clear` door are passed through, not kept; only
## the biggest connected part is kept.
func _largest_part(pts: Array[Vector3], pairs: Array = [], clear: Array[Vector3] = []) -> Dictionary:
	var space := get_world_3d().direct_space_state
	var links: Array = []
	for i in pts.size():
		links.append([])
	for pr in pairs:
		links[pr[0]].append(pr[1])
		links[pr[1]].append(pr[0])
	var dropped := {}
	for i in pts.size():
		for c in clear:
			if Vector2(pts[i].x - c.x, pts[i].z - c.z).length() < KEEP_CLEAR:
				dropped[i] = true
	for i in pts.size():
		for j in range(i + 1, pts.size()):
			var a := pts[i]
			var b := pts[j]
			if Vector2(a.x - b.x, a.z - b.z).length() > LINK or absf(a.y - b.y) > 0.5:
				continue
			var q := PhysicsRayQueryParameters3D.create(a + Vector3(0.0, 0.6, 0.0), b + Vector3(0.0, 0.6, 0.0), 1)
			q.exclude = _door_rids
			if space.intersect_ray(q).is_empty() and not links[i].has(j):
				links[i].append(j)
				links[j].append(i)
	# A point by a clear door is a way through, never a place to stand: its
	# neighbours are joined to each other before it goes (the playroom only
	# opens onto the entrance hall, right by the street door).
	for i in pts.size():
		if dropped.has(i):
			for a_ in links[i]:
				for b_ in links[i]:
					if a_ != b_ and not links[a_].has(b_):
						links[a_].append(b_)
			for n in links[i]:
				links[n].erase(i)
			links[i].clear()
	var part := []
	var seen := {}
	for i in pts.size():
		if seen.has(i) or dropped.has(i):
			continue
		var group := [i]
		seen[i] = true
		var k := 0
		while k < group.size():
			for n in links[group[k]]:
				if not seen.has(n):
					seen[n] = true
					group.append(n)
			k += 1
		if group.size() > part.size():
			part = group
	part.sort()
	var index := {}
	var out_pts: Array[Vector3] = []
	for i in part:
		index[i] = out_pts.size()
		out_pts.append(pts[i])
	var out_links: Array = []
	for i in part:
		var l: Array = []
		for n in links[i]:
			l.append(index[n])
		out_links.append(l)
	return {"points": out_pts, "links": out_links}

# ---------------------------------------------------------------------------
# The floor Elias is on
# ---------------------------------------------------------------------------

## How many Gastos the moment asks for: by the night (by phase on today's
## single visit, where the house still stays quiet), never during 03:33,
## between nights or after the exit.
func wanted() -> int:
	if main.quest == null or level == &"" or main.ended:
		return 0
	if night.is_empty() and level == Registry.HOME:
		return 0
	if main.hour_event != null and main.hour_event.is_active():
		return 0
	if main.night_card != null and main.night_card.is_open():
		return 0
	if night.is_empty():
		return mini(main.quest.stalkers(), MAX)
	return mini(night_stalkers(night.stalkers, main.quest.is_done), MAX)

## The night's count (noites.gd `stalkers`): the last step whose `after` is
## struck (&"" is the start of the night) gives the number.
static func night_stalkers(steps: Array, is_done: Callable) -> int:
	var n := 0
	for s in steps:
		if s.after == &"" or is_done.call(s.after):
			n = s.n
	return n

## A new night: whoever was out goes away; the count now follows `n`.
func on_night(n: Dictionary) -> void:
	night = n
	entry_wound = null
	scatter()

## The night's safety rule (&"" on today's single visit: only anchors).
func rule() -> StringName:
	return night.get("safety", &"")

## What safety_model.gd needs to judge point `p` on this floor.
## `lit_rooms` (from lit_rooms()) saves recounting the lamps per point.
func world_at(p: Vector3, lit: Variant = null) -> Dictionary:
	var lit_here := false
	if rule() == &"comodos_com_luz" and level == Registry.HOME:
		var rooms: Dictionary = lit if lit != null else lit_rooms()
		lit_here = rooms.has(main.atlas.room_at(p + Vector3(0.0, 0.3, 0.0)))
	return {"level": level, "lit": lit_here, "entry_wound": _entry_has_spring(), "anchors": anchors}

## A flame lit later (a candle, the match): counted as a lamp from now on.
func add_lamp(l: OmniLight3D) -> void:
	if not _lamps.has(l):
		_lamps.append(l)

## Rooms of the house with a lamp switched on (a HouseLight shown) or a flame
## burning (CandleLight), whatever the dread does to its brightness.
func lit_rooms() -> Dictionary:
	var out := {}
	for l in get_tree().get_nodes_in_group(&"HouseLight") + get_tree().get_nodes_in_group(&"CandleLight"):
		if (l as Node3D).is_visible_in_tree():
			out[main.atlas.room_at((l as Node3D).global_position)] = true
	out.erase(&"")
	return out

func _entry_has_spring() -> bool:
	if entry_wound != null:
		return entry_wound
	return main.clock_model != null and main.clock_model.spring > main.clock_model.STALL_SPRING

func is_safe(p: Vector3) -> bool:
	return Safety.is_safe(p, rule(), world_at(p))

## Indices of this floor's lurk points the Gastos may not step onto now.
func safe_points() -> Array:
	var out := []
	var g := graph(level)
	if anchors.is_empty() and (level != Registry.HOME or rule() in [&"", &"so_ancoras"]):
		return out
	var lit: Variant = lit_rooms() if rule() == &"comodos_com_luz" else null
	for k in g.points.size():
		if Safety.is_safe(g.points[k], rule(), world_at(g.points[k], lit)):
			out.append(k)
	return out

## Elias changed floors: whoever was following goes away and comes back later.
func on_level(lvl: StringName) -> void:
	level = lvl
	var g := graph(lvl)
	_models.clear()
	_heard.clear()
	for i in MAX:
		_bodies[i].visible = false
		_set_hittable(i, false)
		if g.points.is_empty():
			_models.append(null)
			continue
		var m = StalkerModel.new(g.points, g.links)
		m.send_away(FOLLOW + FOLLOW_STAGGER * i)
		_models.append(m)

## The wanted ones appear now, far and out of view (for tests and phase turns).
func spawn_now() -> void:
	_refresh_view()
	var goal := _goal()
	for i in wanted():
		var m = _models[i] if i < _models.size() else null
		if m == null:
			continue
		m.send_away(0.0)
		m.update(0.01, false, false, goal, false, false, _in_view, _safe)
		_show(i)

## A noise at `at` (NoiseModel.Level): every Gasto standing within its
## radius (or `radius`, when given) heads for it for NOISE_MEMORY seconds.
func hear(at: Vector3, level: int, radius := -1.0) -> void:
	var r: float = radius if radius > 0.0 else NoiseModel.radius(level)
	for i in placed():
		if _bodies[i].global_position.distance_to(at) < r:
			_heard[i] = {"at": at, "left": NoiseModel.NOISE_MEMORY}

## The point Gasto `i` heads for: the last noise it heard, else Elias.
func goal_of(i: int) -> int:
	if _heard.has(i):
		return _nearest_point(_heard[i].at)
	return _goal()

## Indices of the Gastos standing somewhere now.
func placed() -> Array:
	var out := []
	for i in _models.size():
		if _models[i] != null and not _models[i].is_away() and i < wanted():
			out.append(i)
	return out

## Metres from `p` to the nearest Gasto out in the house (INF with none).
func nearest(p: Vector3) -> float:
	var best := INF
	for i in placed():
		best = minf(best, _bodies[i].global_position.distance_to(p))
	return best

func head_of(i: int) -> Vector3:
	return _bodies[i].global_position + Vector3(0.0, HEAD, 0.0)

func hitbox_of(i: int) -> StaticBody3D:
	return _hitboxes[i]

## Struck by the stick: a porcelain crack, and it is gone for a while.
func struck(hitbox: Node) -> bool:
	var i: int = hitbox.get_meta(&"gasto", -1)
	if i < 0 or i >= _models.size() or _models[i] == null or _models[i].is_away():
		return false
	_models[i].hit()
	_show(i)
	return true

## After a hug everyone goes, so Elias wakes in peace.
func scatter() -> void:
	for i in _models.size():
		if _models[i] != null:
			_models[i].send_away(StalkerModel.RETURN_TIME)
			_show(i)

## Eyes closed: Elias does not see them (and they hurry).
func set_veiled(on: bool) -> void:
	veiled = on
	for i in _models.size():
		_show(i)

## 0 nothing near .. 1 one at arm's length.
func threat() -> float:
	var t := 0.0
	var p: Vector3 = main.player.global_position
	for i in placed():
		var d := _bodies[i].global_position.distance_to(p)
		t = maxf(t, clampf(1.0 - (d - 1.5) / 9.0, 0.0, 1.0))
	return t

func _process(delta: float) -> void:
	if main == null or main.player == null or _models.is_empty():
		return
	# The fight comes first: Elias is locked while held, and no Gasto moves.
	if capture != null and capture.state != Capture.State.FREE:
		_tick_capture(delta)
		if capture.is_grabbed():
			return
	var n := wanted()
	for i in range(n, _models.size()):
		if _models[i] != null and _bodies[i].visible:
			_bodies[i].visible = false
			_set_hittable(i, false)
	if n == 0 or main.world_frozen():
		return
	_view_in -= delta
	if _view_in <= 0.0:
		_view_in = VIEW_EVERY
		_refresh_view()
	var blind: bool = main.player.pretending or not _lit(main.player.camera.global_position)
	var hidden := _hidden()
	var held: bool = main.player.get("breath") != null and main.player.breath.holding
	var pp: Vector3 = main.player.global_position
	for i in _heard.keys():
		_heard[i].left -= delta
		if _heard[i].left <= 0.0:
			_heard.erase(i)
	for i in n:
		var m = _models[i]
		if m == null:
			continue
		var goal := goal_of(i)
		var seen := false
		if not m.is_away() and not veiled:
			seen = main.is_seen(head_of(i)) and _lit(head_of(i))
		var near: bool = not m.is_away() and m.points[m.at].distance_to(pp) < NEAR
		var r: StringName = m.update(delta, seen, blind, goal, near, hidden, _in_view, _safe, _elias_safe, held)
		match r:
			&"undone":
				main.sfx.play_at(&"shatter", head_of(i), &"Mundo", -6.0)
			&"caught":
				_grab(i)
		if r != &"":
			_show(i)
		if not m.is_away():
			_face(i, pp)
		if capture != null and capture.is_grabbed():
			return
	_tick_in -= delta
	if _tick_in <= 0.0:
		_tick_in = _rng.randf_range(1.4, 2.6)
		for i in placed():
			var d := _bodies[i].global_position.distance_to(pp)
			if d < 9.0:
				main.sfx.play_at(&"porcelain", head_of(i), &"Mundo", lerpf(-6.0, -20.0, d / 9.0))

## Gasto `i` takes hold of Elias, unless he is still staggering from the
## last fight.
func _grab(i: int) -> void:
	if capture != null and capture.state != Capture.State.FREE:
		return
	var hold := false
	if main.get("settings_ui") != null:
		hold = bool(main.settings_ui.model.get_value(&"hold_to_escape"))
	capture = Capture.new(int(night.get("capture_clicks", 10)), hold)
	capture.grab(i)
	grabbed.emit(i)

func _tick_capture(delta: float) -> void:
	var g: int = capture.gasto
	var r: StringName = capture.update(delta, Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))
	match r:
		&"broke_free":
			if g >= 0 and g < _models.size() and _models[g] != null:
				_models[g].hit()
				_show(g)
			broke_free.emit(g)
		&"hug":
			caught.emit(g)

## One click of Elias's while held.
func push() -> void:
	if capture != null:
		capture.push()

func is_grabbed() -> bool:
	return capture != null and capture.is_grabbed()

func _show(i: int) -> void:
	var m = _models[i]
	var here: bool = m != null and not m.is_away() and i < wanted()
	if here:
		_bodies[i].global_position = m.points[m.at]
		_bodies[i].set_pose(&"agachado" if _low_ceiling(m.points[m.at]) else &"em_pe")
	_bodies[i].visible = here and not veiled
	_set_hittable(i, here)

func _set_hittable(i: int, on: bool) -> void:
	_hitboxes[i].get_child(0).set_deferred(&"disabled", not on)

func _face(i: int, target: Vector3) -> void:
	var to := target - _bodies[i].global_position
	_bodies[i].rotation.y = atan2(-to.x, -to.z)

func _low_ceiling(p: Vector3) -> bool:
	var q := PhysicsRayQueryParameters3D.create(p + Vector3(0.0, 0.2, 0.0), p + Vector3(0.0, 1.8, 0.0), 1)
	return not get_world_3d().direct_space_state.intersect_ray(q).is_empty()

func _refresh_view() -> void:
	_in_view.clear()
	_safe = safe_points()
	_elias_safe = main.player != null and is_safe(main.player.global_position)
	# Whoever stands where it just became safe goes away (no frozen Gasto there).
	for i in _models.size():
		var m = _models[i]
		if m != null and not m.is_away() and _safe.has(m.at):
			m.send_away(StalkerModel.RETURN_TIME)
			_show(i)
	var g := graph(level)
	for k in g.points.size():
		if main.is_seen(g.points[k] + Vector3(0.0, HEAD, 0.0)) or main.is_seen(g.points[k] + Vector3(0.0, 0.5, 0.0)):
			_in_view.append(k)

func _goal() -> int:
	return _nearest_point(main.player.global_position)

func _nearest_point(p: Vector3) -> int:
	var g := graph(level)
	var best := -1
	var best_d := INF
	for k in g.points.size():
		var q: Vector3 = g.points[k]
		var d := Vector2(q.x - p.x, q.z - p.z).length() + absf(q.y - p.y) * 2.0
		if d < best_d:
			best_d = d
			best = k
	return best

## Lit: in the lantern's cone, or near a lamp that is on.
func _lit(p: Vector3) -> bool:
	var fl: SpotLight3D = main.player.flashlight
	if fl.visible and fl.is_visible_in_tree():
		var to := p - fl.global_position
		if to.length() < fl.spot_range and (-fl.global_basis.z).angle_to(to) < deg_to_rad(fl.spot_angle):
			return true
	return _lamp_lit(p)

## Near a lamp that is on (the house's lit rooms, rule comodos_com_luz).
func _lamp_lit(p: Vector3) -> bool:
	for l in _lamps:
		if is_instance_valid(l) and l.is_visible_in_tree() and l.light_energy > 0.25 and l.global_position.distance_to(p) < l.omni_range * 0.6:
			return true
	return false

func _hidden() -> bool:
	if not main.player.crouched:
		return false
	for a in get_tree().get_nodes_in_group(&"Hideout"):
		if (a as Area3D).overlaps_body(main.player):
			return true
	return false
