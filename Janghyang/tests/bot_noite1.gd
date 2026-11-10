extends SceneTree
## The night 1 bot (playtest 1): plays night 1 from the letter to the paper
## card through the real keys (W, C, Q, E, B, T, the left click while held),
## with no teleport and no call to main._complete. It aims by turning the body
## and the camera, as the mouse would. It walks an A* over a 0.2 m grid built
## from Elias's capsule against the physics, so it only gets where a player
## could. It knows where everything is: its time is the night's floor, not a
## first-time player's.
##
##   godot --headless --path . --fixed-fps 60 -s res://tests/bot_noite1.gd -- --playtest --night=1 [--bot-out=DIR]
##
## Without --headless (and with --audio-driver Dummy), --bot-shots=DIR also
## saves what Elias sees at each milestone.
##
## Prints one "BOT" line per milestone and "BOT RESULT ok|fail" at the end.
## Its CSV leaves user://playtest/ for DIR (user://bot by default).

const CELL := 0.2
const MIN_X := -0.4
const MAX_X := 15.4
const MIN_Z := -1.4
const MAX_Z := 9.3
const RADIUS := 0.32
## Sim seconds before the bot gives up.
const LIMIT := 1500.0

var main: Node
var _start_frame := 0
var _grab_frames := 0
var _grabs_seen := 0
var _was_grabbed := false
var _rooms: Dictionary = {}
var _room := &""
var _failures: Array[String] = []
var _shots := 0

func _initialize() -> void:
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	main = scene
	_run.call_deferred()

func now() -> float:
	return (Engine.get_physics_frames() - _start_frame) / 60.0

func _say(text: String) -> void:
	print("BOT %6.1fs [%s] %s" % [now(), _room, text])

func _fail(text: String) -> void:
	_failures.append(text)
	_say("FAIL " + text)

# ---------------------------------------------------------------------------
# One physics frame, with what any player does every frame: push free when
# held, and the room clock.
# ---------------------------------------------------------------------------

func _step() -> void:
	await physics_frame
	var r: StringName = main.atlas.room_at(main.player.global_position)
	if r != _room:
		_room = r
	_rooms[r] = _rooms.get(r, 0.0) + 1.0 / 60.0
	var held: bool = main.gastos.is_grabbed()
	if held and not _was_grabbed:
		_grabs_seen += 1
		_say("grabbed by a Gasto")
	if not held and _was_grabbed:
		_say("broke free")
	_was_grabbed = held
	if held:
		_grab_frames += 1
		if _grab_frames % 5 == 0:
			_click()

func _steps(n: int) -> void:
	for i in n:
		await _step()

func _wait(seconds: float) -> void:
	await _steps(int(seconds * 60.0))

func _key(code: Key, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)

func _tap(code: Key) -> void:
	_key(code, true)
	await _step()
	_key(code, false)
	await _step()

func _click() -> void:
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		Input.parse_input_event(ev)

func _look_at(p: Vector3) -> void:
	var pl = main.player
	var to: Vector3 = p - pl.camera.global_position
	pl.rotation.y = atan2(-to.x, -to.z)
	pl.camera.rotation.x = atan2(to.y, Vector2(to.x, to.z).length())

## What Elias sees, saved as DIR/NN-name.png with --bot-shots=DIR (only
## when the game renders, that is, without --headless).
func _shot(name: String) -> void:
	var dir := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--bot-shots="):
			dir = arg.substr(12)
	if dir == "" or DisplayServer.get_name() == "headless":
		return
	await _steps(2)
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(dir)
	_shots += 1
	var img := root.get_texture().get_image()
	img.save_png(dir.path_join("%02d-%s.png" % [_shots, name]))

func _crouch(on: bool) -> void:
	if main.player.crouched != on:
		await _tap(KEY_C)
		await _steps(4)
	if main.player.crouched != on:
		_say("could not %s" % ("crouch" if on else "stand up"))

# ---------------------------------------------------------------------------
# Walking: a grid of where the capsule fits, A* over it, W held.
# ---------------------------------------------------------------------------

func _grid(crouch: bool) -> AStarGrid2D:
	var g := AStarGrid2D.new()
	var w := int(ceil((MAX_X - MIN_X) / CELL)) + 1
	var h := int(ceil((MAX_Z - MIN_Z) / CELL)) + 1
	g.region = Rect2i(0, 0, w, h)
	g.cell_size = Vector2(CELL, CELL)
	g.offset = Vector2(MIN_X, MIN_Z)
	g.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	g.update()
	var space: PhysicsDirectSpaceState3D = main.get_world_3d().direct_space_state
	var cap := CapsuleShape3D.new()
	cap.radius = RADIUS
	cap.height = 1.0 if crouch else 1.7
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.collision_mask = 1
	q.exclude = [main.player.get_rid()]
	for i in w:
		for j in h:
			var x := MIN_X + i * CELL
			var z := MIN_Z + j * CELL
			var solid := true
			var fr := PhysicsRayQueryParameters3D.create(Vector3(x, 0.4, z), Vector3(x, -0.3, z), 1, [main.player.get_rid()])
			var hit := space.intersect_ray(fr)
			if not hit.is_empty() and hit.normal.y > 0.7 and absf(hit.position.y) < 0.15:
				q.transform = Transform3D(Basis(), Vector3(x, hit.position.y + cap.height * 0.5 + 0.06, z))
				solid = not space.intersect_shape(q, 1).is_empty()
			g.set_point_solid(Vector2i(i, j), solid)
	return g

func _cell(p: Vector3) -> Vector2i:
	return Vector2i(roundi((p.x - MIN_X) / CELL), roundi((p.z - MIN_Z) / CELL))

func _free_near(g: AStarGrid2D, c: Vector2i, reach := 6) -> Vector2i:
	if g.is_in_boundsv(c) and not g.is_point_solid(c):
		return c
	for r in range(1, reach + 1):
		for dx in range(-r, r + 1):
			for dz in range(-r, r + 1):
				var n := c + Vector2i(dx, dz)
				if g.is_in_boundsv(n) and not g.is_point_solid(n):
					return n
	return Vector2i(-1, -1)

## Walks to `to` (y ignored). True when Elias stands within `tol` of it.
func _walk(to: Vector3, crouch := false, tol := 0.25) -> bool:
	await _crouch(crouch)
	for attempt in 3:
		var g := _grid(crouch)
		var a := _free_near(g, _cell(main.player.global_position))
		var b := _free_near(g, _cell(to), 2)
		if a.x < 0 or b.x < 0:
			_say("no free cell (from %s, to %s)" % [a, b])
			return false
		var path := g.get_point_path(a, b)
		if path.is_empty():
			_say("no path to (%.1f, %.1f)" % [to.x, to.z])
			return false
		# A spot the capsule does not fit ends on the nearest free cell instead.
		var goal := Vector2(to.x, to.z) if b == _cell(to) else path[-1]
		if await _follow(path, goal, tol):
			return true
		var pl = main.player
		var what := ""
		if pl.ray.is_colliding():
			what = "%s at %.2f m" % [pl.ray.get_collider().name, pl.camera.global_position.distance_to(pl.ray.get_collision_point())]
		_say("stuck at (%.2f, %.2f) heading to (%.2f, %.2f), ahead: %s; planning again" % [pl.global_position.x, pl.global_position.z, to.x, to.z, what])
	return false

func _follow(path: PackedVector2Array, goal: Vector2, tol: float) -> bool:
	var pl = main.player
	var i := 1
	var mark: Vector3 = pl.global_position
	var since := 0
	var tried_door := false
	pl.camera.rotation.x = -0.12
	_key(KEY_W, true)
	while true:
		if now() > LIMIT:
			_key(KEY_W, false)
			return false
		var p: Vector3 = pl.global_position
		var here := Vector2(p.x, p.z)
		var wp: Vector2 = goal if i >= path.size() else path[i]
		var close := tol if i >= path.size() else 0.22
		if here.distance_to(wp) < close:
			if i >= path.size():
				break
			i += 1
			continue
		if not main.gastos.is_grabbed():
			pl.rotation.y = atan2(-(wp.x - here.x), -(wp.y - here.y))
		await _step()
		since += 1
		if since >= 60:
			if pl.global_position.distance_to(mark) < 0.15 and not main.gastos.is_grabbed():
				if not tried_door:
					tried_door = true
					await _tap(KEY_E)
				else:
					_key(KEY_W, false)
					return false
			mark = pl.global_position
			since = 0
	_key(KEY_W, false)
	await _steps(12)
	return true

## Stand points around `at`, nearest to Elias first, where the capsule fits.
func _stands(at: Vector3, crouch: bool, radii: Array) -> Array:
	var g := _grid(crouch)
	var out: Array = []
	for r in radii:
		for k in 16:
			var a := TAU * k / 16.0
			var s := Vector3(at.x + cos(a) * r, 0.0, at.z + sin(a) * r)
			var c := _cell(s)
			if g.is_in_boundsv(c) and not g.is_point_solid(c):
				out.append(s)
	var from: Vector3 = main.player.global_position
	out.sort_custom(func(x: Vector3, y: Vector3) -> bool: return x.distance_to(from) < y.distance_to(from))
	return out

## Goes near `at` and tries `act` from each stand point until `done` says so.
func _reach(label: String, at: Vector3, act: Callable, done: Callable, crouch := false, radii := [1.0, 1.4, 1.8]) -> bool:
	var tries := 0
	for s in _stands(at, crouch, radii):
		if done.call():
			break
		tries += 1
		if tries > 8:
			break
		if not await _walk(s, crouch):
			continue
		_look_at(at)
		await _steps(3)
		await act.call()
		await _steps(20)
		if done.call():
			_say(label)
			await _shot(label.replace(" ", "-"))
			return true
	if done.call():
		_say(label)
		return true
	_fail(label + ": never managed it")
	return false

# ---------------------------------------------------------------------------
# The night.
# ---------------------------------------------------------------------------

func _catalog(item: StringName, at: Vector3) -> bool:
	var act := func() -> void:
		var target = main.player.catalog_target_in_view()
		if target != null and target.item_id == item:
			await _tap(KEY_Q)
	return await _reach("cataloged " + item, at, act, func() -> bool: return main.catalog.has(item))

func _run() -> void:
	_start_frame = Engine.get_physics_frames()
	await _steps(30)
	_say("night %d, letter open: %s" % [main.night.get("n", 0), main.night_card.is_letter()])
	# The card ignores keys for its first INPUT_GRACE_MS of real time.
	OS.delay_msec(800)
	await _tap(KEY_ENTER)
	await _steps(6)
	if main.night_card.is_open():
		_fail("the letter did not close")
		_finish()
		return
	_say("letter put down")
	await _shot("carta-fechada")
	await _tap(KEY_T)
	_say("watch open: %s, points at %s" % [main.pocket_watch.is_open, main.pocket_watch.goal.get("task")])

	# Chapter 1's clues: the entry clock, the little house, the drawing.
	await _catalog(&"relogio_entrada", Vector3(3.1, 1.2, 8.8))
	await _catalog(&"casinha", Vector3(7.5, 0.3, 1.0))
	await _catalog(&"desenho", Vector3(6.7, 1.6, 0.1))
	_say("watch points at %s" % main.watch_goal().get("task"))

	# The staged scene: watched it keeps still, looked away it moves on.
	var ch = main.chapters[0]
	if ch.opened and not ch.staging.done():
		_say("turning to the figures at pose %d" % ch.staging.pose)
		_look_at(main.staging_center(ch.id))
		await _steps(2)
		if not main._staging_seen(ch.id):
			await _walk(Vector3(3.6, 0.0, 4.2))
		var looks := 0
		while not ch.staging.done() and now() < LIMIT:
			var pose: int = ch.staging.pose
			_look_at(main.staging_center(ch.id))
			await _wait(1.5)
			main.player.rotation.y += PI
			main.player.camera.rotation.x = 0.0
			var waited := 0.0
			var stepped := false
			while ch.staging.pose == pose and not ch.staging.done() and waited < 20.0:
				# A pose never lands on Elias: standing where a figure goes,
				# nothing happens until he steps aside, as a player would.
				if waited >= 3.0 and not stepped and not main._staging_clear(ch.id, pose + 1):
					stepped = true
					_say("pose %d waits: Elias stands where a figure goes; stepping aside" % (pose + 1))
					await _walk(Vector3(3.6, 0.0, 4.2))
					_look_at(main.staging_center(ch.id))
					main.player.rotation.y += PI
					main.player.camera.rotation.x = 0.0
				await _wait(0.25)
				waited += 0.25
			looks += 1
			var near := INF
			for pair in main._staging[ch.id].figures:
				var fp: Vector3 = pair[0].global_position
				near = minf(near, Vector2(fp.x, fp.z).distance_to(Vector2(main.player.global_position.x, main.player.global_position.z)))
			_say("looked away (%d), pose %d -> %d after %.2f s; nearest figure %.2f m from Elias" % [looks, pose, ch.staging.pose, waited, near])
			main.player.rotation.y += PI
			await _shot("pose-%d-de-frente" % ch.staging.pose)
			_look_at(main.staging_center(ch.id))
			await _shot("pose-%d-olhando" % ch.staging.pose)
			if waited >= 20.0:
				_fail("the scene does not move on when unseen")
				break
		_say("the scene is over; watch points at %s" % main.watch_goal().get("task"))

	# The hollow panel under the drawing: three knocks of the stick.
	if main.player.hands_model.left == &"relogio":
		await _tap(KEY_T)
	var knock := func() -> void:
		await _tap(KEY_B)
		await _wait(0.8)
	var panel: Node = main.find_child("HollowPanel", true, false)
	var broke := false
	for k in 4:
		broke = await _reach("the panel broke", Vector3(6.7, 0.6, 0.0), knock, func() -> bool: return panel.broken, false, [0.85, 1.0])
		if broke:
			break
	if not main.quest.is_done(&"achar_passagem"):
		_fail("achar_passagem not struck")
		_finish()
		return
	_say("watch points at %s" % main.watch_goal().get("task"))

	# Through the panel, crawling west to the crown.
	await _walk(Vector3(6.7, 0.0, 0.9))
	var take := func() -> void:
		await _tap(KEY_E)
	await _reach("took the crown", Vector3(0.75, 0.05, -0.65), take, func() -> bool: return main.quest.is_done(&"coroa"), true, [0.6, 0.8, 1.0])
	if not main.quest.is_done(&"coroa"):
		_finish()
		return
	_say("Gastos wanted now: %d; watch points at %s" % [main.gastos.wanted(), main.watch_goal().get("task")])
	if main.pocket_watch.goal.get("task") != &"voltar_terreo":
		_fail("after the crown the watch does not point the way back")
	await _steps(2)
	_say("the hand: %s (trembling %s)" % [main.pocket_watch.aim_now().get("mode"), main.pocket_watch.trembling])

	# Back out to the playroom and on to the entry clock.
	if not await _walk(Vector3(6.7, 0.0, 1.2), true):
		_fail("could not crawl back out")
		_finish()
		return
	await _crouch(false)
	_say("voltar_terreo struck: %s; the 03:33 may come: %s; watch points at %s" % [main.quest.is_done(&"voltar_terreo"), main.clock_model.can_stop, main.pocket_watch.goal.get("task")])
	if main.pocket_watch.goal.get("task") != &"dar_corda":
		_fail("on the ground floor the watch does not point at the clock")
	await _steps(2)
	_say("the hand: %s (trembling %s)" % [main.pocket_watch.aim_now().get("mode"), main.pocket_watch.trembling])
	await _walk(Vector3(2.3, 0.0, 8.5))
	var waited := 0.0
	while not main.hour_event.is_active() and waited < 180.0:
		await _wait(0.5)
		waited += 0.5
	_say("03:33 started: %s after %.1f s at the clock (spring %.1f)" % [main.hour_event.is_active(), waited, main.clock_model.spring])
	await _shot("0333")
	var wind := func() -> void:
		await _tap(KEY_E)
	await _reach("wound the clock", Vector3(3.1, 1.0, 8.8), wind, func() -> bool: return main.night_card.is_open(), false, [0.9, 1.2])
	await _shot("cartao")
	_say("card open: %s, campaign night %d, text: %s" % [main.night_card.is_open(), main.campaign.night, main.night_card.text().replace("\n", " | ").left(120)])
	_finish()

func _finish() -> void:
	_key(KEY_W, false)
	var plog = main.playtest_log
	if plog != null:
		plog.write_row()
		plog.stop()
		# Out of user://playtest/, so the people's sessions stay alone there.
		var out_dir := "user://bot"
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--bot-out="):
				out_dir = arg.substr(10)
		DirAccess.make_dir_recursive_absolute(out_dir)
		var path: String = out_dir.path_join("noite1-" + plog.path.get_file())
		DirAccess.copy_absolute(plog.path, path)
		DirAccess.remove_absolute(plog.path)
		path = ProjectSettings.globalize_path(path)
		var lines := FileAccess.get_file_as_string(path).strip_edges().split("\n")
		var lost := 0
		for l in lines.slice(1):
			if l.ends_with(",1"):
				lost += 1
		_say("csv: %s (%d rows, %d marked lost)" % [path, lines.size() - 1, lost])
	var rooms: PackedStringArray = []
	for r in _rooms:
		rooms.append("%s %.0fs" % [r if r != &"" else "?", _rooms[r]])
	_say("time by room: " + ", ".join(rooms))
	_say("grabs: %d" % _grabs_seen)
	var ok: bool = _failures.is_empty() and main.night_card.is_open() and main.campaign.night == 2
	print("BOT RESULT %s in %.1f s (%s)" % ["ok" if ok else "fail", now(), "; ".join(_failures)])
	quit(0 if ok else 1)
