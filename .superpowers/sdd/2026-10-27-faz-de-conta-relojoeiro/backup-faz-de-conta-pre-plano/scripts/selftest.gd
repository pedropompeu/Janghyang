extends Node
## Headless blockout verification. Run with:
##   godot --headless --path . -- --selftest
## It checks door/fold states and queries a player-sized capsule along the
## intended loop. It is diagnostic scaffolding, not part of the game.

var main: Node3D
var failures := 0
var checks := 0
var query_shape: CapsuleShape3D
var player_rid: RID

func _ready() -> void:
	query_shape = CapsuleShape3D.new()
	query_shape.radius = 0.28
	query_shape.height = 1.6
	player_rid = main.player.get_rid()
	call_deferred("_run")

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

	print("SELFTEST: loop clearance")
	_check_segment(Vector3(2.0, 0.85, 11.2), Vector3(1.7, 0.85, 9.4), "atelier -> front door")
	_check_segment(Vector3(1.7, 0.85, 9.4), Vector3(1.7, 0.85, 7.9), "front door -> entry")
	_check_segment(Vector3(1.7, 0.85, 7.9), Vector3(1.7, 0.85, 6.4), "entry -> playroom door")
	_check_segment(Vector3(1.7, 0.85, 6.4), Vector3(5.5, 0.85, 6.0), "playroom entry")
	_check_segment(Vector3(5.5, 0.85, 6.0), Vector3(6.0, 0.85, 4.8), "playroom east path")
	_check_segment(Vector3(6.0, 0.85, 4.8), Vector3(5.4, 0.85, 3.8), "playroom around the ball")
	_check_segment(Vector3(5.4, 0.85, 3.8), Vector3(5.4, 0.85, 2.5), "playroom north path")
	_check_segment(Vector3(5.4, 0.85, 2.5), Vector3(8.0, 0.85, 2.5), "playroom -> F3 opening")
	_check_segment(Vector3(8.0, 0.85, 2.5), Vector3(9.4, 0.85, 2.5), "F3 opening -> corridor")
	_check_segment(Vector3(9.4, 0.85, 2.5), Vector3(11.5, 0.85, 2.5), "corridor -> bedroom front")
	_check_segment(Vector3(11.5, 0.85, 2.5), Vector3(11.5, 0.85, 5.0), "bedroom west path")
	_check_segment(Vector3(11.5, 0.85, 5.0), Vector3(9.4, 0.85, 5.0), "bedroom back -> corridor")
	_check_segment(Vector3(9.4, 0.85, 5.0), Vector3(9.4, 0.85, 7.9), "corridor south")
	_check_segment(Vector3(9.4, 0.85, 7.9), Vector3(10.6, 0.85, 7.95), "corridor -> figure-room threshold")
	_check_segment(Vector3(9.4, 0.85, 8.3), Vector3(7.0, 0.85, 8.3), "corridor -> passage")
	_check_segment(Vector3(7.0, 0.85, 8.3), Vector3(3.2, 0.85, 8.3), "passage -> entry")
	_check_segment(Vector3(3.2, 0.85, 8.3), Vector3(3.2, 0.85, 7.9), "entry east turn")
	_check_segment(Vector3(3.2, 0.85, 7.9), Vector3(1.7, 0.85, 7.9), "entry north of bench")
	_check_segment(Vector3(1.7, 0.85, 7.9), Vector3(1.7, 0.85, 9.4), "entry -> front door")
	_check_segment(Vector3(1.7, 0.85, 9.4), Vector3(2.0, 0.85, 10.6), "front door -> atelier")

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

	print("SELFTEST: final state")
	_expect_at("DoorFront", true, "front door remains open")
	_expect_at("DoorPlayroom", true, "playroom door remains open")
	_expect_at("F1", false, "F1 ends upright")
	_expect_at("F2", false, "F2 ends closed")
	_expect_at("F3", false, "F3 ends flat")
	_expect_at("F4", false, "F4 ends closed")

	print("SELFTEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

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

func _expect_clear(pos: Vector3, label: String) -> void:
	var hits := _hits(pos)
	_record(hits.is_empty(), label, "blocked by " + _hit_names(hits))

func _expect_blocked(pos: Vector3, label: String) -> void:
	var hits := _hits(pos)
	_record(not hits.is_empty(), label, "expected a blocker at " + str(pos))

func _check_segment(a: Vector3, b: Vector3, label: String) -> void:
	var steps: int = maxi(1, int(ceil(a.distance_to(b) / 0.25)))
	for i in range(steps + 1):
		var pos := a.lerp(b, float(i) / float(steps))
		var hits := _hits(pos)
		if not hits.is_empty():
			_record(false, label, "blocked at %s by %s" % [str(pos), _hit_names(hits)])
			return
	_record(true, label, "")

func _hits(pos: Vector3) -> Array:
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = query_shape
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
