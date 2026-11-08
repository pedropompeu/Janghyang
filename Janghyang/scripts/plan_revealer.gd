extends Node
## Lifts the fog of the plan as Elias looks (spec §8): RATE times a second,
## RAYS rays across the camera's width, out to RANGE metres (or the lit
## lantern's reach, if shorter), stopped by walls; every cell along a ray is
## seen. A Gasto in view is pencilled where it stands, and so is an item in
## view (nodes of group &"PlanItem", with meta "item_id" and "label") until
## it is taken (plan_model.forget_item). Writes into main.plan_model.

const RATE := 4.0
const RAYS := 9
const RANGE := 6.0
## Distance between samples along a ray (half a fog cell).
const STEP := 0.25

## Set by main.
var main: Node
var _in := 0.0

func _process(delta: float) -> void:
	_in -= delta
	if _in > 0.0:
		return
	_in = 1.0 / RATE
	scan()

func reach() -> float:
	var fl: SpotLight3D = main.player.flashlight if main.player.get("flashlight") != null else null
	if fl != null and fl.visible:
		return minf(RANGE, fl.spot_range)
	return RANGE

## Half the camera's horizontal field of view (rad).
func half_width() -> float:
	var cam: Camera3D = main.player.camera
	var size := get_viewport().get_visible_rect().size
	var aspect := size.x / size.y if size.y > 0.0 else 16.0 / 9.0
	return atan(tan(deg_to_rad(cam.fov) * 0.5) * aspect)

## One look: the fog along each ray, then what stands in view.
func scan() -> void:
	if main == null or main.player == null or main.plan_model == null:
		return
	var p: Node3D = main.player
	var level: StringName = main.atlas.level_of(main.atlas.room_at(p.global_position))
	if level == &"":
		return
	var fog = main.plan_model.fog(level)
	if fog == null:
		return
	var eye: Vector3 = p.camera.global_position
	var fwd: Vector3 = -p.camera.global_basis.z
	fwd.y = 0.0
	if fwd.length() < 0.01:
		fwd = -p.global_basis.z
	fwd = fwd.normalized()
	var space := p.get_world_3d().direct_space_state
	var far := reach()
	var half := half_width()
	fog.reveal(Vector2(p.global_position.x, p.global_position.z))
	for k in RAYS:
		var dir := fwd.rotated(Vector3.UP, lerpf(half, -half, float(k) / (RAYS - 1)))
		var length := _clear_to(space, eye, eye + dir * far, p)
		var d := 0.0
		while d <= length:
			var at := eye + dir * d
			fog.reveal(Vector2(at.x, at.z))
			d += STEP
	var now: float = main.visit.elapsed if main.get("visit") != null and main.visit != null else 0.0
	if main.gastos != null:
		for i in main.gastos.placed():
			var head: Vector3 = main.gastos.head_of(i)
			if _in_view(space, eye, fwd, head, far, half, p):
				var foot := Vector3(head.x, head.y - main.gastos.HEAD, head.z)
				main.plan_model.note(main.atlas.level_of(main.atlas.room_at(foot + Vector3(0.0, 0.3, 0.0))), foot, &"gasto", "Gasto", now, StringName("gasto_%d" % i))
	for item in get_tree().get_nodes_in_group(&"PlanItem"):
		var n := item as Node3D
		if n == null or not n.is_visible_in_tree() or not n.has_meta(&"item_id"):
			continue
		if _in_view(space, eye, fwd, n.global_position, far, half, p):
			var id := StringName(str(n.get_meta(&"item_id")))
			main.plan_model.note(main.atlas.level_of(main.atlas.room_at(n.global_position + Vector3(0.0, 0.3, 0.0))), n.global_position, &"item", str(n.get_meta(&"label", String(id))), now, id)

## How far the ray goes before a wall (the whole way when nothing is hit).
func _clear_to(space: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3, p: Node3D) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, to, 1)
	if p is CollisionObject3D:
		q.exclude = [(p as CollisionObject3D).get_rid()]
	var hit := space.intersect_ray(q)
	return from.distance_to(to) if hit.is_empty() else from.distance_to(hit.position)

func _in_view(space: PhysicsDirectSpaceState3D, eye: Vector3, fwd: Vector3, at: Vector3, far: float, half: float, p: Node3D) -> bool:
	var to := at - eye
	var flat := Vector3(to.x, 0.0, to.z)
	if flat.length() > far or flat.length() < 0.01 or absf(fwd.signed_angle_to(flat.normalized(), Vector3.UP)) > half:
		return false
	return _clear_to(space, eye, at, p) >= to.length() - 0.3
