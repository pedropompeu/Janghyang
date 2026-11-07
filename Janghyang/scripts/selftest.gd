extends Node
## Headless blockout verification. Run with:
##   godot --headless --path . -- --selftest
## It checks door/fold states and queries a player-sized capsule along the
## intended loop. It is diagnostic scaffolding, not part of the game.

var main: Node3D
var failures := 0
var checks := 0
var query_shape: CapsuleShape3D
var crouch_shape: CapsuleShape3D
var player_rid: RID
var _errors := _ErrorCounter.new()

## A script error mid-run must not end as a green result.
class _ErrorCounter extends Logger:
	var count := 0
	func _log_error(_function: String, _file: String, _line: int, _code: String, _rationale: String,
			_editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		count += 1

## The walking loop: spawn, playroom, corridor, bedroom, passage, tampo edge.
const LOOP := [
	[Vector3(1.8, 0.85, 8.3), Vector3(1.7, 0.85, 7.9), "spawn -> entry"],
	[Vector3(1.7, 0.85, 9.4), Vector3(1.7, 0.85, 7.9), "front door -> entry"],
	[Vector3(1.7, 0.85, 7.9), Vector3(1.7, 0.85, 6.4), "entry -> playroom door"],
	[Vector3(1.7, 0.85, 6.4), Vector3(5.5, 0.85, 6.0), "playroom entry"],
	[Vector3(5.5, 0.85, 6.0), Vector3(6.0, 0.85, 4.8), "playroom east path"],
	[Vector3(6.0, 0.85, 4.8), Vector3(5.4, 0.85, 3.8), "playroom around the ball"],
	[Vector3(5.4, 0.85, 3.8), Vector3(5.4, 0.85, 2.5), "playroom north path"],
	[Vector3(5.4, 0.85, 2.5), Vector3(8.0, 0.85, 2.5), "playroom -> F3 opening"],
	[Vector3(8.0, 0.85, 2.5), Vector3(9.4, 0.85, 2.5), "F3 opening -> corridor"],
	[Vector3(9.4, 0.85, 2.5), Vector3(11.5, 0.85, 2.5), "corridor -> bedroom front"],
	[Vector3(11.5, 0.85, 2.5), Vector3(11.5, 0.85, 5.0), "bedroom west path"],
	[Vector3(11.5, 0.85, 5.0), Vector3(9.4, 0.85, 5.0), "bedroom back -> corridor"],
	[Vector3(9.4, 0.85, 5.0), Vector3(9.4, 0.85, 7.9), "corridor south"],
	[Vector3(9.4, 0.85, 7.9), Vector3(10.6, 0.85, 7.95), "corridor -> figure-room threshold"],
	[Vector3(9.4, 0.85, 8.3), Vector3(7.0, 0.85, 8.3), "corridor -> passage"],
	[Vector3(7.0, 0.85, 8.3), Vector3(3.2, 0.85, 8.3), "passage -> entry"],
	[Vector3(3.2, 0.85, 8.3), Vector3(3.2, 0.85, 7.9), "entry east turn"],
	[Vector3(3.2, 0.85, 7.9), Vector3(1.7, 0.85, 7.9), "entry north of bench"],
	[Vector3(1.7, 0.85, 7.9), Vector3(1.7, 0.85, 9.4), "entry -> front door"],
	[Vector3(1.7, 0.85, 9.4), Vector3(2.0, 0.85, 12.0), "front door -> tampo edge"],
]

## A run that stops early (script error inside _run) never reaches quit(), so the
## guard ends the process as a failure instead of letting it hang. The full run
## takes about 43 s; 120 s leaves room for a slow machine.
const GUARD_S := 120.0

func _ready() -> void:
	OS.add_logger(_errors)
	get_tree().create_timer(GUARD_S).timeout.connect(_on_guard)
	main.autonomous = false
	query_shape = CapsuleShape3D.new()
	query_shape.radius = 0.28
	query_shape.height = 1.6
	crouch_shape = CapsuleShape3D.new()
	crouch_shape.radius = 0.28
	crouch_shape.height = 1.0
	player_rid = main.player.get_rid()
	call_deferred("_run")

func _on_guard() -> void:
	print("SELFTEST GUARD: no result after %.0f s, the run stopped early" % GUARD_S)
	get_tree().quit(1)

func _run() -> void:
	await get_tree().physics_frame
	main.player.set_physics_process(false)
	main.player.velocity = Vector3.ZERO

	print("SELFTEST: initial states")
	_expect_at("DoorFront", true, "front door is open at 0:00")
	_expect_at("DoorPlayroom", true, "playroom door is open")
	_expect_at("DoorBedroomFront", false, "bedroom front door starts closed")
	_expect_at("DoorBedroomBack", false, "bedroom back door starts closed")
	_expect_at("DoorFigure", false, "figure-room door starts closed")
	_expect_at("F1", false, "F1 starts upright")
	_expect_at("F2", false, "F2 starts closed")
	_expect_at("F3", false, "F3 starts flat")
	_expect_at("F4", false, "F4 starts closed")
	_expect_clear(Vector3(8.4, 0.85, 2.5), "flat F3 leaves the playroom doorway walkable")

	print("SELFTEST: closed doors block")
	_expect_blocked(Vector3(10.5, 0.85, 2.5), "closed bedroom front door blocks")
	_expect_blocked(Vector3(10.5, 0.85, 5.0), "closed bedroom back door blocks")
	_expect_blocked(Vector3(10.5, 0.85, 8.0), "closed figure-room door blocks")
	_expect_blocked(Vector3(8.4, 0.85, 1.3), "closed F2 is a wall")
	_expect_blocked(Vector3(8.4, 0.85, 3.7), "closed F4 is a wall")

	print("SELFTEST: opening the three closed doors")
	await _toggle("DoorBedroomFront")
	await _toggle("DoorBedroomBack")
	await _toggle("DoorFigure")
	_expect_clear(Vector3(10.5, 0.85, 2.5), "open bedroom front door is walkable")
	_expect_clear(Vector3(10.5, 0.85, 5.0), "open bedroom back door is walkable")
	_expect_clear(Vector3(10.5, 0.85, 8.0), "open figure-room door is walkable")

	print("SELFTEST: space")
	_record(main.player.global_position.distance_to(main.SPAWN) < 0.3, "player spawns at the entry", str(main.player.global_position))
	_record(main.get_node_or_null("ExitEdge") is Area3D, "tampo edge trigger exists", "")
	_record(main.get_node_or_null("Atelier") == null and main.get_node_or_null("Tampo") != null, "atelier became the tampo", "")
	_expect_clear(Vector3(1.8, 0.85, 8.3), "spawn point is clear")
	_expect_blocked(Vector3(3.1, 0.85, 8.6), "entry clock is solid")
	_record(main.get_node_or_null("EntryClock") != null and main.get_node("EntryClock").get_prompt() == "dar corda", "entry clock can be wound", "")
	_record(main.visit.act == main.VisitState.Act.CHEGADA, "visit starts at arrival", "")
	var verbs := [main.player.verb_for(main.get_node("DoorFront")), main.player.verb_for(main.get_node("F1")), main.player.verb_for(main.get_node("EntryClock")), main.player.verb_for(main.get_node("Doll"))]
	_record(verbs == [&"abrir", &"dobrar", &"corda", &"boneco"], "gestures have the house's verbs", str(verbs))
	_record(AudioServer.get_bus_index("Casa") >= 0 and AudioServer.get_bus_index("Mundo") >= 0, "audio buses exist", "")

	print("SELFTEST: loop clearance")
	_loop_segments("")

	print("SELFTEST: folds")
	_expect_clear(Vector3(1.5, 0.85, 3.5), "F1 upright leaves the playroom floor clear")
	await _toggle("F1")
	_expect_blocked(Vector3(1.5, 0.85, 3.5), "folded F1 blocks the low cabana volume")
	await _toggle("F1")
	_expect_clear(Vector3(1.5, 0.85, 3.5), "unfolded F1 restores the playroom")

	await _toggle("F2")
	_expect_clear(Vector3(8.4, 0.85, 1.3), "open F2 opens the wall")
	await _toggle("F2")
	_expect_blocked(Vector3(8.4, 0.85, 1.3), "closed F2 restores the wall")

	await _toggle("F4")
	_expect_clear(Vector3(8.4, 0.85, 3.7), "open F4 opens the wall")
	await _toggle("F4")
	_expect_blocked(Vector3(8.4, 0.85, 3.7), "closed F4 restores the wall")

	await _toggle("F3")
	_expect_blocked(Vector3(8.4, 0.85, 2.5), "raised F3 closes the playroom doorway")
	await _toggle("F3")
	_expect_clear(Vector3(8.4, 0.85, 2.5), "lowered F3 reopens the playroom doorway")

	print("SELFTEST: cabana")
	await _toggle("F1")
	_expect_blocked(Vector3(1.5, 0.85, 3.5), "folded F1 still blocks a standing player")
	_expect_clear_shape(Vector3(1.5, 0.52, 3.5), crouch_shape, "crouched player fits inside the cabana")
	_check_segment_shape(Vector3(2.6, 0.52, 3.5), Vector3(1.5, 0.52, 3.5), crouch_shape, "crouched path into the cabana")
	var saved: Vector3 = main.player.global_position
	main.player.global_position = Vector3(1.5, 0.0, 3.5)
	main.player.set_crouched(true)
	await get_tree().physics_frame
	_record(not main.player.set_crouched(false), "cannot stand up under folded F1", "")
	_record(main.player.crouched, "player stays crouched under folded F1", "")
	_node("F1").interact()
	await get_tree().create_timer(1.3).timeout
	_expect_at("F1", true, "F1 refuses to move with the player inside the cabana")
	main.player.global_position = saved
	await get_tree().physics_frame
	_record(main.player.set_crouched(false), "player stands up outside the cabana", "")
	await _toggle("F1")

	print("SELFTEST: catalog")
	var targets := get_tree().get_nodes_in_group("catalog_target")
	for tg in targets:
		_record(tg is Area3D and tg.collision_layer == 2, "catalog target %s is an area on layer 2" % tg.item_id, "")
	_record(targets.size() == main.CatalogData.ITEMS.size() - 1, "every item but the cabana page has a target", str(targets.size()))
	var saved_view: Vector3 = main.player.global_position
	main.player.global_position = Vector3(3.1, 0.2, 7.9)
	main.player.rotation.y = PI
	main.player.camera.rotation.x = deg_to_rad(-15.0)
	await get_tree().physics_frame
	main.player.ray.force_raycast_update()
	main.player.catalog_ray.force_raycast_update()
	var seen: Area3D = main.player.catalog_target_in_view()
	_record(seen != null and seen.item_id == &"relogio_entrada", "looking at the entry clock offers it to Q", str(seen))
	main.player.global_position = saved_view
	main.player.rotation.y = 0.0
	main.player.camera.rotation.x = 0.0

	print("SELFTEST: notebook")
	main.notebook.refresh(main.catalog)
	main.notebook.open()
	var text: String = main.notebook.page_text()
	_record(text.contains("Item 214 —"), "notebook shows the opening entry", "")
	_record(text.contains("Item 215 —"), "notebook shows numbered blank lines ahead", "")
	var counter := RegEx.create_from_string("\\d+\\s*(/|de)\\s*\\d+")
	_record(counter.search(text) == null, "notebook has no x-of-y counter", text)
	_record(main.player.input_locked, "notebook locks player input", "")
	main.notebook.close()
	_record(not main.player.input_locked, "closing the notebook unlocks input", "")

	print("SELFTEST: hands")
	var hands = main.player.get("hands")
	_record(hands != null and hands.is_shown(), "Elias's hands are in view", "")
	if hands != null:
		var hl: int = 1 << (hands.HANDS_LAYER - 1)
		_record((main.player.camera.cull_mask & hl) != 0 and hands.drawn_on_top(), "the hands are drawn over the world, never into a wall", "")
		_record((main.get_node("MirrorReflection")._camera.cull_mask & hl) == 0, "the mirror does not show floating hands", "")
		_record((main.ending.final_camera.cull_mask & hl) == 0, "the final camera does not show the hands", "")
		_record(hands.has_stick(), "the right hand holds a stick", "")
		var knocks: Array = []
		var on_act := func(verb: StringName, _c: Node) -> void: knocks.append(verb)
		main.player.acted.connect(on_act)
		var saved_k: Vector3 = main.player.global_position
		main.player.global_position = Vector3(4.0, 0.2, 1.0)
		main.player.rotation.y = 0.0
		main.player.camera.rotation.x = 0.0
		await get_tree().physics_frame
		main.player._knock()
		_record(knocks.is_empty(), "the knock lands with the stick, not on the key", str(knocks))
		main.player._knock()
		await get_tree().create_timer(0.7).timeout
		_record(knocks == [&"bater"], "one swing, one knock: B mid-swing is ignored", str(knocks))
		knocks.clear()
		main.player.rotation.y = PI
		await get_tree().physics_frame
		main.player.ray.force_raycast_update()
		var open_air: bool = not main.player.ray.is_colliding() or main.player.camera.global_position.distance_to(main.player.ray.get_collision_point()) > main.player.KNOCK_REACH
		main.player._knock()
		await get_tree().create_timer(0.7).timeout
		_record(open_air and knocks.is_empty(), "a swing at nothing knocks nothing", str(knocks))
		main.player.acted.disconnect(on_act)
		main.player.global_position = saved_k
		main.player.rotation.y = 0.0
		var lamp_was: bool = main.player.flashlight.visible
		main.player.flashlight.visible = true
		await get_tree().process_frame
		_record(hands.lantern_shown() and main.player.flashlight.position.x < 0.0, "the lantern beam comes from the left hand", str(main.player.flashlight.position))
		main.player.flashlight.visible = false
		await get_tree().create_timer(0.4).timeout
		_record(not hands.lantern_shown(), "the lantern is put away when off", "")
		main.player.flashlight.visible = lamp_was
		main.notebook.open()
		await get_tree().create_timer(0.4).timeout
		_record(not hands.is_shown(), "the hands are lowered while reading", "")
		main.notebook.close()
		await get_tree().create_timer(0.4).timeout
		_record(hands.is_shown(), "the hands come back after reading", "")

	print("SELFTEST: breakables")
	var panel := main.find_child("HollowPanel", true, false)
	_record(panel != null and panel.is_in_group(&"Breakable"), "the playroom has a hollow panel", "")
	_expect_blocked(Vector3(6.7, 0.52, 0.0), "the hollow panel starts whole")
	var sounds: Array = []
	var on_sound := func(kind: StringName) -> void: sounds.append(kind)
	main.knock_sounded.connect(on_sound)
	var saved_b: Vector3 = main.player.global_position
	main.player.global_position = Vector3(6.7, 0.2, 0.9)
	main.player.rotation.y = 0.0
	main.player.camera.rotation.x = deg_to_rad(-40.0)
	await get_tree().physics_frame
	for i in 3:
		main.player._knock()
		await get_tree().create_timer(0.75).timeout
	_record(sounds == [&"oco", &"oco", &"crumble"], "the wall sounds hollow, then gives", str(sounds))
	_record(panel.broken, "three knocks break the hollow panel", "")
	await get_tree().physics_frame
	_expect_clear_shape(Vector3(6.7, 0.52, 0.0), crouch_shape, "a crouched child fits through the broken panel")
	# U33: the crawl route, crouched, from the playroom through the broken panel into the passage.
	_check_segment_shape(Vector3(6.7, 0.52, 0.9), Vector3(6.7, 0.52, -0.6), crouch_shape, "a crouched child walks from the playroom through the broken panel")
	_check_segment_shape(Vector3(6.7, 0.52, -0.6), Vector3(8.4, 0.52, -0.6), crouch_shape, "the passage runs east at crouch height")
	main.player.camera.rotation.x = 0.0
	sounds.clear()
	main.player._knock()
	await get_tree().create_timer(0.75).timeout
	_record(not sounds.has(&"crumble"), "a broken panel does not break again", str(sounds))
	main.knock_sounded.disconnect(on_sound)
	main.player.global_position = saved_b

	# U34 (Review Focus 4): W climbs only on a ladder; the shaft leads to the attic and the tower ladder to the mechanism.
	print("SELFTEST: ladders")
	var saved_l: Vector3 = main.player.global_position
	var saved_rot: float = main.player.rotation.y
	main.player.set_physics_process(true)
	main.player.rotation.y = 0.0
	main.player.global_position = Vector3(7.0, 0.0, -0.68)
	await _frames(3)
	_key_event(KEY_W, true)
	await _frames(30)
	_key_event(KEY_W, false)
	_record(main.player.global_position.y < 0.05 and main.player.ladders == 0, "W off the ladder walks, Elias stays on the floor", str(main.player.global_position))

	main.player.global_position = Vector3(10.12, 0.0, -0.68)
	await _frames(3)
	_record(main.player.ladders > 0, "the shaft counts Elias as on the ladder", str(main.player.ladders))
	_key_event(KEY_W, true)
	var shaft_top: float = await _climb_until(2.9)
	_key_event(KEY_W, false)
	_record(shaft_top >= 2.9, "W climbs the shaft to the attic floor", "top y %.2f" % shaft_top)
	_record(main.atlas.room_at(main.player.global_position) == &"sotao", "the top of the shaft is the attic", str(main.atlas.room_at(main.player.global_position)))

	main.player.rotation.y = PI * 0.5
	main.player.global_position = Vector3(6.0, 2.95, 5.5)
	await _frames(3)
	_record(main.player.ladders > 0, "the tower ladder counts Elias as on the ladder", str(main.player.ladders))
	_key_event(KEY_W, true)
	var tower_top: float = await _climb_until(5.5)
	_key_event(KEY_W, false)
	_record(tower_top >= 5.4, "W climbs the tower ladder", "top y %.2f" % tower_top)
	_record(tower_top >= 5.4 and main.atlas.room_at(main.player.global_position) == &"mecanismo", "at the top of the tower ladder Elias is in the mechanism", "y %.2f, %s" % [tower_top, main.atlas.room_at(main.player.global_position)])

	main.player.global_position = saved_l
	main.player.rotation.y = saved_rot
	await _frames(3)
	main.player.set_physics_process(false)

	# U35 (Review Focus 4): the bedroom trapdoor opens onto the ladder down to the drawer.
	print("SELFTEST: drawer")
	var trap := main.find_child("Trapdoor", true, false)
	_record(trap != null and trap.is_in_group(&"Breakable"), "the bedroom has a trapdoor", "")
	for i in 3:
		trap.hit()
	await _frames(2)
	_record(trap.broken, "three knocks break the trapdoor", "")
	main.player.set_physics_process(true)
	main.player.rotation.y = PI * 0.5
	main.player.global_position = Vector3(14.925, 0.0, 0.52)
	await _frames(3)
	_record(main.player.ladders > 0, "the drawer ladder counts Elias as on the ladder", str(main.player.ladders))
	_key_event(KEY_S, true)
	var low: float = await _sink_until(-3.0)
	_key_event(KEY_S, false)
	_record(low <= -3.0, "S on the ladder goes down into the drawer", "low y %.2f" % low)
	_record(main.atlas.room_at(main.player.global_position) == &"gaveta", "the foot of the ladder is the drawer", str(main.atlas.room_at(main.player.global_position)))
	main.player.global_position = saved_l
	main.player.rotation.y = saved_rot
	await _frames(3)
	main.player.set_physics_process(false)

	print("SELFTEST: story")
	var quest = main.get("quest")
	var gastos = main.get("gastos")
	_record(quest != null and quest.phase_id() == &"I", "the visit starts in phase I", "")
	_record(quest != null and quest.is_done(&"achar_passagem"), "breaking the hollow panel finds what the drawing hides", "")
	_record(gastos != null and gastos.wanted() == 0, "no Gasto before the crown", "")
	for lvl in main.LEVEL_SAFE:
		var safe: Vector3 = main.LEVEL_SAFE[lvl]
		_expect_clear(safe + Vector3(0.0, 0.85, 0.0), "safe point of %s is clear" % lvl)
		var fq := PhysicsRayQueryParameters3D.create(safe + Vector3(0.0, 0.3, 0.0), safe + Vector3(0.0, -0.5, 0.0), 1)
		_record(not main.get_world_3d().direct_space_state.intersect_ray(fq).is_empty(), "safe point of %s stands on a floor" % lvl, str(safe))
	if gastos != null:
		for lvl in [&"passagem", &"sotao", &"mecanismo", &"gaveta", &"tampo"]:
			var g: Dictionary = gastos.graph(lvl)
			_record(g.points.size() >= 4, "%s has lurk points" % lvl, str(g.points.size()))
			_record(g.links.all(func(l): return not l.is_empty()), "every lurk point of %s leads somewhere" % lvl, "")
			# U30 (Review Focus 3): one piece, so from its first point every lurk point is reachable (a way back).
			var reached := {0: true}
			var frontier := [0]
			while not frontier.is_empty():
				var cur_pt: int = frontier.pop_front()
				for nxt_pt in g.links[cur_pt]:
					if not reached.has(nxt_pt):
						reached[nxt_pt] = true
						frontier.append(nxt_pt)
			_record(not g.points.is_empty() and reached.size() == g.points.size(), "every lurk point of %s walks back to the rest" % lvl, "%d of %d" % [reached.size(), g.points.size()])
		_record(gastos.graph(&"casa").points.is_empty(), "the house ground floor is a refuge", "")
	var coroa := main.find_child("Piece_coroa", true, false)
	coroa.interact()
	await get_tree().process_frame
	_record(quest.has_piece(&"coroa") and main.catalog.has(&"coroa"), "the crown goes in the notebook", "")
	_record(quest.phase_id() == &"II" and gastos.wanted() == 0, "phase II opens; the house stays a refuge", str(gastos.wanted()))
	var saved_s: Vector3 = main.player.global_position
	main.player.global_position = main.LEVEL_SAFE[&"gaveta"]
	main.player.rotation.y = 0.0
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_record(main.player.respawn_point.distance_to(main.LEVEL_SAFE[&"gaveta"]) < 0.01, "going down the drawer moves the safe point", str(main.player.respawn_point))
	_record(gastos.wanted() == 1, "the first Gasto follows into the drawer", str(gastos.wanted()))
	gastos.spawn_now()
	await get_tree().physics_frame
	var placed: Array = gastos.placed()
	_record(placed.size() == 1, "one Gasto stands somewhere", str(placed.size()))
	if placed.size() == 1:
		_record(not main.is_seen(gastos.head_of(placed[0])), "it appears out of view", "")
		_record(gastos.threat() >= 0.0 and gastos.threat() <= 1.0, "the music knows how near it is", str(gastos.threat()))
		var hit_sounds: Array = []
		var on_hit := func(kind: StringName) -> void: hit_sounds.append(kind)
		main.knock_sounded.connect(on_hit)
		main._knock_on(gastos.hitbox_of(placed[0]), gastos.head_of(placed[0]))
		main.knock_sounded.disconnect(on_hit)
		_record(hit_sounds == [&"shatter"] and gastos.placed().is_empty(), "the stick undoes a Gasto with a porcelain crack", str(hit_sounds))
	var lines_before: int = main.catalog.entries.size()
	var phase_before: int = quest.phase
	gastos.spawn_now()
	main.player.global_position = main.LEVEL_SAFE[&"gaveta"] + Vector3(-6.0, 0.0, 4.0)
	await get_tree().physics_frame
	main.hug(main.player.global_position)
	await get_tree().create_timer(2.6).timeout
	_record(main.player.global_position.distance_to(main.LEVEL_SAFE[&"gaveta"]) < 0.3, "after the hug Elias wakes at the safe point", str(main.player.global_position))
	_record(main.catalog.entries.size() == lines_before + 1 and main.catalog.entries[-1].author == &"duplo" and main.catalog.entries[-1].text.contains("na gaveta"), "the double writes down the hug", main.catalog.entries[-1].text)
	_record(quest.phase == phase_before and not main.ended, "the hug costs no progress", "")
	_record(not main.player.input_locked and absf(main.player.camera.rotation.z) < 0.01, "Elias gets up again", "")
	_record(gastos.placed().is_empty(), "the Gastos scatter after a hug", "")
	main.player.set_pretending(true)
	await get_tree().create_timer(0.9).timeout
	var chalk := get_tree().get_nodes_in_group(&"Chalk")
	_record(not chalk.is_empty() and chalk.all(func(c): return c.visible), "eyes closed: the boy's chalk shows", "")
	_record(main.pretend.memory, "eyes closed: the house as it was", "")
	main.player.set_pretending(false)
	await get_tree().create_timer(0.9).timeout
	_record(chalk.all(func(c): return not c.visible) and not main.pretend.memory, "eyes open: the chalk is gone", "")
	var s_in: Dictionary = main.score_inputs()
	_record(s_in.depth > 0.9 and s_in.has("threat") and not s_in.pretending, "the drawer sounds deepest", str(s_in))
	main.player.global_position = main.LEVEL_SAFE[&"casa"]
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_record(gastos.wanted() == 0, "back in the house, no Gasto", "%s %s %s %s" % [main.level, main.player.global_position, main.atlas.room_at(main.player.global_position), main.ended])
	main.notebook.open_plan(main.player.global_position)
	var plan: String = main.notebook.plan_text()
	_record(plan.contains("II. O sótão") and plan.contains("[s]a coroa do relógio de bolso[/s]"), "the lots page strikes what is done", plan)
	_record(plan.contains("gaveta") and plan.contains("quarto de brincar") and not plan.contains("Relojoaria Varela"), "the map shows only what Elias has seen", plan)
	main.notebook.close()
	_record(main.visit.pieces_ready == false, "the clock waits for the four pieces", "")
	main.player.global_position = saved_s

	print("SELFTEST: settings")
	var opts = main.settings_ui
	_record(opts != null and opts.path == "", "options exist and the selftest leaves the saved file alone", "")
	opts.open()
	_record(get_tree().paused and opts.is_open(), "Esc sheet pauses the game", "")
	opts.change(&"sensitivity", 0.004)
	opts.change(&"invert_y", true)
	opts.change(&"fov", 80.0)
	opts.change(&"brightness", 1.4)
	opts.change(&"music", 0.0)
	opts.change(&"effects", 0.5)
	var env: Environment = main.find_children("*", "WorldEnvironment", false, false)[0].environment
	_record(main.player.mouse_sensitivity == 0.004 and main.player.invert_y, "mouse options reach Elias", "")
	_record(is_equal_approx(main.player.camera.fov, 80.0), "field of view applies", str(main.player.camera.fov))
	_record(is_equal_approx(env.tonemap_exposure, 1.4), "brightness applies", str(env.tonemap_exposure))
	_record(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Musica")) <= -79.0, "music can be silenced", "")
	_record(absf(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Mundo")) + 6.0) < 0.1 and absf(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Casa")) + 6.0) < 0.1, "effects volume moves the house and the world", "")
	opts._reset()
	_record(main.player.mouse_sensitivity == 0.0022 and not main.player.invert_y and is_equal_approx(main.player.camera.fov, 70.0) and is_equal_approx(env.tonemap_exposure, 1.0), "defaults put everything back", "")
	_record(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Musica")), 0.0), "music back to full", "")
	opts.close()
	_record(not get_tree().paused and not opts.is_open(), "closing the sheet resumes the game", "")
	_record(main.help_label.text.contains("Esc opções"), "help mentions the options", "")

	print("SELFTEST: dread")
	var dread = main.get("dread")
	_record(dread != null, "the house has a mood", "")
	if dread != null:
		_record(get_tree().get_nodes_in_group("HouseLight").size() == 9, "the mood knows the nine house lights", str(get_tree().get_nodes_in_group("HouseLight").size()))
		dread.set_tension(0.1)
		var calm_light: float = dread.house_light_energy(0)
		var calm_fog: float = dread.env.fog_density
		var calm_edge: float = dread.vignette_strength()
		dread.set_tension(0.9)
		_record(dread.house_light_energy(0) < calm_light, "dread dims the house lights", "%f -> %f" % [calm_light, dread.house_light_energy(0)])
		_record(dread.env.fog_density > calm_fog, "dread thickens the fog", "")
		_record(dread.vignette_strength() > calm_edge, "dread closes in the edges of the view", "")
		_record(dread.hum != null and dread.hum.bus == &"Casa", "the house hum belongs to the house", "")
		var lit: float = dread.house_light_energy(0)
		dread.flicker_now(0)
		await get_tree().create_timer(0.08).timeout
		_record(dread.house_light_energy(0) < lit, "a flicker dips a house light", "")
		await get_tree().create_timer(1.0).timeout
		_record(absf(dread.house_light_energy(0) - lit) < 0.01, "the light comes back after the flicker", "")
		var p: Vector3 = main.player.global_position
		var creak = dread.creak_now()
		_record(creak is Vector3 and Vector2(creak.x - p.x, creak.z - p.z).length() >= 4.0, "creaks come from far rooms", str(creak))
		dread.set_tension(main.DreadModel.tension(main.visit.act, main.visit.clock.display_minutes()))

	print("SELFTEST: house mirror")
	var f1_before: bool = _node("F1").is_at_b()
	var f3_before: bool = _node("F3").is_at_b()
	_record(main.house_mirror.respond({"verb": &"dobrar", "count": 1, "invite": false}), "house folds back from far away", "")
	await get_tree().create_timer(1.3).timeout
	_record(_node("F2").is_at_b() or _node("F4").is_at_b(), "house used F2 or F4", "")
	_record(_node("F1").is_at_b() == f1_before and _node("F3").is_at_b() == f3_before, "house never touches F1 or F3", "")
	for n in ["F2", "F4"]:
		if _node(n).is_at_b():
			await _toggle(n)
	var saved_m: Vector3 = main.player.global_position
	main.player.global_position = Vector3(8.0, 0.2, 2.6)
	await get_tree().physics_frame
	main.house_mirror.respond({"verb": &"dobrar", "count": 1, "invite": false})
	await get_tree().create_timer(1.3).timeout
	_record(not _node("F2").is_at_b() and not _node("F4").is_at_b(), "house does not fold within 3 m of the player", "")
	main.player.global_position = saved_m
	_record((main.player.get_node("Camera3D").cull_mask & (1 << 10)) == 0, "player camera does not see the reflection layer", "")

	print("SELFTEST: 03:33")
	_feed_loop()
	var duplo_before: int = main.catalog.entries.filter(func(e): return e.author == &"duplo").size()
	main.hour_event.begin()
	# A-015: a double that is not at the bench yet must not make the pencil sound.
	var pencils_before: int = main.sfx.pencil_count
	main.hour_event._write_next()
	_record(main.sfx.pencil_count == pencils_before, "the pencil stays quiet while the double is not at the bench", str(main.sfx.pencil_count - pencils_before))
	await get_tree().create_timer(0.5).timeout
	_record(main.hour_event.echoes.size() > 0, "echoes appear at 03:33", "")
	_record(main.get_node("Echoes").find_children("*", "CollisionObject3D", true, false).is_empty(), "echoes have no collision", "")
	_expect_at("DoorFront", true, "front door stays open during 03:33")
	_record(main.find_children("CrackThing*", "", true, false).size() == 3, "three things come out of the cracks", "")
	_record(main.find_children("CrackThing*", "", true, false).all(func(n): return n.find_children("*", "CollisionObject3D", true, false).is_empty()), "crack things have no collision", "")
	_check_segment(Vector3(1.8, 0.85, 8.3), Vector3(1.7, 0.85, 9.4), "spawn -> front door during 03:33")
	_check_segment(Vector3(1.7, 0.85, 9.4), Vector3(2.0, 0.85, 12.0), "front door -> tampo edge during 03:33")
	main.hour_event.end()
	_record(main.sfx.pencil_count > pencils_before, "the pencil sounds once the double sits at the bench", str(main.sfx.pencil_count - pencils_before))
	_record(main.hour_event.echoes.all(func(e): return e.is_frozen()), "winding freezes the echoes", "")
	var duplo: Array = main.catalog.entries.filter(func(e): return e.author == &"duplo")
	_record(duplo.size() - duplo_before == 3, "the double wrote three entries at 03:33", str(duplo.size() - duplo_before))
	_record(main.catalog.entries[-1].number == main.catalog.entries[-2].number + 1, "double entries continue the numbering", "")
	_record(_node("Doll").global_position.distance_to(Vector3(0.7, 0.45, 8.5)) < 0.3, "the double sits on the entry bench", "")
	# A-014: the double counts as the seated doll, so the catalogue can take it.
	_record(main.catalog.flags.get(&"doll_sat", false) == true, "the double counts as the seated doll for the catalogue (A-014)", str(main.catalog.flags.get(&"doll_sat", false)))
	var pq := PhysicsPointQueryParameters3D.new()
	pq.position = _node("Doll").global_position + Vector3(0.0, 0.3, 0.0)
	var hits := main.get_world_3d().direct_space_state.intersect_point(pq)
	_record(hits.all(func(h): return h.collider != _node("Doll")), "the double has no collision", str(hits.size()))
	_loop_segments(" with frozen echoes")

	print("SELFTEST: truth props")
	_record(main.find_child("PocketWatchA", true, false) != null and main.find_child("PocketWatchB", true, false) != null, "two Inácio figures carry the same pocket watch", "")
	_record(main.find_child("CatalogerLetter", true, false) != null, "the cataloger figure holds the letter", "")
	_record(main.catalog.can_catalog(&"pagina_cabana"), "cabana page appears after 03:33", "")
	var targets2 := get_tree().get_nodes_in_group("catalog_target")
	_record(targets2.size() == main.CatalogData.ITEMS.size(), "every catalog item now has a target", str(targets2.size()))
	var giant := main.get_node_or_null("GiantElias")
	_record(giant != null and giant.visible, "Elias's giant body is seen after 03:33", "")
	_record(giant != null and giant.find_children("*", "CollisionObject3D", true, false).is_empty(), "giant body has no collision", "")

	print("SELFTEST: final state")
	_expect_at("DoorFront", true, "front door remains open")
	_expect_at("DoorPlayroom", true, "playroom door remains open")
	_expect_at("F1", false, "F1 ends upright")
	_expect_at("F2", false, "F2 ends closed")
	_expect_at("F3", false, "F3 ends flat")
	_expect_at("F4", false, "F4 ends closed")

	print("SELFTEST: exit")
	_record(not main.help_label.text.contains("front door") and main.help_label.text.contains("B bater"), "help text is pt-BR and lists every verb", "")
	_expect_at("DoorFront", true, "front door is still open before leaving")
	# Leave while a 03:33 is in progress (Review Focus 1).
	main.hour_event.begin()
	await get_tree().create_timer(0.3).timeout
	main.player.set_physics_process(true)
	main.player.global_position = Vector3(2.0, 0.2, 12.2)
	for i in 4:
		await get_tree().physics_frame
	main.player.set_physics_process(false)
	_record(main.ended and main.ending_outcome == &"incompleto", "reaching the tampo edge ends the visit", str(main.ending_outcome))
	await get_tree().create_timer(1.2).timeout
	_record(main.ending.final_camera.current, "final camera takes over", "")
	_record(main.player.get("hands") != null and not main.player.hands.is_shown(), "the hands are gone after the exit", "")
	_record(not main.hour_event.is_active(), "leaving during 03:33 ends the hour behind the black", "")
	_record(main.hour_event.crack_things.all(func(c): return not c.is_active()), "crack things stop when Elias leaves", "")
	var writes_before: int = main.catalog.entries.size()
	await get_tree().create_timer(3.2).timeout
	_record(main.notebook._final.visible, "the last entry is shown on paper", "")
	_record(main.player.input_locked, "the player stays still after the last entry", "")
	await get_tree().create_timer(3.0).timeout
	_record(main.catalog.entries.size() == writes_before, "the double stops writing once Elias has left", str(main.catalog.entries.size() - writes_before))
	main.player.notebook_requested.emit()
	main.player.notebook_requested.emit()
	_record(main.player.input_locked and not main.notebook.is_open(), "the notebook does not reopen over the last entry", "")

	print("SELFTEST: what stays")
	var fig := main.get_node_or_null("NewFigure")
	_record(fig != null, "a new figure stays in the maquete", "")
	if fig != null:
		var head: Vector3 = fig.global_position + Vector3(0, 0.9, 0)
		var cam: Camera3D = main.ending.final_camera
		_record(fig.find_children("*", "CollisionObject3D", true, false).is_empty(), "new figure has no collision", "")
		_record(fig.global_position.distance_to(Vector3(main.SPAWN.x, 0.0, main.SPAWN.z)) < 0.2, "new figure sits where Elias arrived", "")
		_record(cam.is_position_in_frustum(head), "final camera frames the new figure", "")
		var q := PhysicsRayQueryParameters3D.create(cam.global_position, head, 1)
		_record(main.get_world_3d().direct_space_state.intersect_ray(q).is_empty(), "new figure is seen through the redoma and the open door", "")
		_record(not main.get_node("GiantElias").visible, "the giant body is gone: the camera is him", "")
		_record(main.hour_event.echoes.all(func(e): return e.is_frozen()), "leaving during 03:33 leaves the echoes frozen where they stand", "")

	_record(_errors.count == 0, "no script errors during the selftest", "%d errors" % _errors.count)
	print("SELFTEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _loop_segments(suffix: String) -> void:
	for seg in LOOP:
		_check_segment(seg[0], seg[1], seg[2] + suffix)

## The whole loop walked at 1.4 m/s, then 10 s crouched in the cabana.
func _feed_loop() -> void:
	var rec = main.recorder
	var dt := 0.1
	var foot := Vector3(0.0, 0.65, 0.0)
	for seg in LOOP:
		var a: Vector3 = seg[0] - foot
		var b: Vector3 = seg[1] - foot
		var dir := b - a
		var yaw := atan2(-dir.x, -dir.z)
		var steps := maxi(1, int(ceil(a.distance_to(b) / (1.4 * dt))))
		for i in range(steps + 1):
			rec.update(dt, a.lerp(b, float(i) / float(steps)), yaw, 0.0, false)
	for i in 100:
		rec.update(dt, Vector3(1.5, 0.0, 3.5), PI * 0.5, -0.2, true)

func _toggle(node_name: String) -> void:
	var node := _node(node_name)
	if node == null:
		return
	node.interact()
	await get_tree().create_timer(1.3).timeout
	await get_tree().physics_frame

func _expect_at(node_name: String, expected: bool, label: String) -> void:
	var node := _node(node_name)
	if node == null:
		return
	var actual: bool = node.is_at_b()
	_record(actual == expected, label, "expected at_b=%s, got %s" % [str(expected), str(actual)])

func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

## A key press or release through the Input singleton, as the keyboard sends it.
func _key_event(code: Key, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)

## Waits (at most 4 s) while W is held; returns the highest y Elias reached.
func _climb_until(height: float) -> float:
	var top := 0.0
	for i in 240:
		await get_tree().physics_frame
		top = maxf(top, main.player.global_position.y)
		if top >= height:
			break
	return top

## Waits (at most 4 s) while S is held; returns the lowest y Elias reached.
func _sink_until(depth: float) -> float:
	var low := 0.0
	for i in 240:
		await get_tree().physics_frame
		low = minf(low, main.player.global_position.y)
		if low <= depth:
			break
	return low

func _expect_clear(pos: Vector3, label: String) -> void:
	_expect_clear_shape(pos, query_shape, label)

func _expect_clear_shape(pos: Vector3, shape: Shape3D, label: String) -> void:
	var hits := _hits_shape(pos, shape)
	_record(hits.is_empty(), label, "blocked by " + _hit_names(hits))

func _expect_blocked(pos: Vector3, label: String) -> void:
	var hits := _hits(pos)
	_record(not hits.is_empty(), label, "expected a blocker at " + str(pos))

func _check_segment(a: Vector3, b: Vector3, label: String) -> void:
	_check_segment_shape(a, b, query_shape, label)

func _check_segment_shape(a: Vector3, b: Vector3, shape: Shape3D, label: String) -> void:
	var steps: int = maxi(1, int(ceil(a.distance_to(b) / 0.25)))
	for i in range(steps + 1):
		var pos := a.lerp(b, float(i) / float(steps))
		var hits := _hits_shape(pos, shape)
		if not hits.is_empty():
			_record(false, label, "blocked at %s by %s" % [str(pos), _hit_names(hits)])
			return
	_record(true, label, "")

func _hits(pos: Vector3) -> Array:
	return _hits_shape(pos, query_shape)

func _hits_shape(pos: Vector3, shape: Shape3D) -> Array:
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis.IDENTITY, pos)
	params.collision_mask = 1
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.exclude = [player_rid]
	return main.get_world_3d().direct_space_state.intersect_shape(params, 8)

func _hit_names(hits: Array) -> String:
	var names: Array[String] = []
	for hit in hits:
		var collider: Variant = hit.get("collider")
		if collider is Node:
			names.append(String(collider.name))
	return ", ".join(names)

func _node(node_name: String) -> Node:
	var node := main.get_node_or_null(node_name)
	if node == null:
		_record(false, "missing node " + node_name, "")
	return node

func _record(ok: bool, label: String, detail: String) -> void:
	checks += 1
	if ok:
		print("  PASS  " + label)
	else:
		failures += 1
		print("  FAIL  " + label + (" — " + detail if detail != "" else ""))
