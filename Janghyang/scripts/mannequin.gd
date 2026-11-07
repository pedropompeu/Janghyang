extends Node3D
## A body made of boxes, meshes only: no collision, nothing to bump into.
## Used for Elias in the mirror, his echoes, the double and the new figure.
## Faces -Z like the player, so a recorded yaw can be applied as-is.

var _hips: Node3D
var _head: Node3D
var _legs: Array[Node3D] = []
var _torso: Node3D
var _arms := {}
var _mats := {}

func build(style: Dictionary, scale_factor := 1.0) -> void:
	for part in style:
		var m := StandardMaterial3D.new()
		m.albedo_color = style[part]
		m.roughness = 0.9
		_mats[part] = m
	scale = Vector3.ONE * scale_factor
	_hips = Node3D.new()
	add_child(_hips)
	for side in [-1.0, 1.0]:
		var leg := Node3D.new()
		leg.position = Vector3(side * 0.1, 0.0, 0.0)
		_hips.add_child(leg)
		_part(leg, Vector3(0.14, 0.85, 0.16), Vector3(0.0, -0.425, 0.0), &"trousers")
		_legs.append(leg)
	_torso = Node3D.new()
	_hips.add_child(_torso)
	_part(_torso, Vector3(0.44, 0.62, 0.24), Vector3(0.0, 0.31, 0.0), &"coat")
	_part(_torso, Vector3(0.46, 0.26, 0.26), Vector3(0.0, -0.03, 0.0), &"coat")
	for side in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.position = Vector3(side * 0.29, 0.6, 0.0)
		arm.rotation.z = deg_to_rad(side * 4.0)
		_torso.add_child(arm)
		_arms[side] = arm
		_part(arm, Vector3(0.11, 0.6, 0.12), Vector3(0.0, -0.28, 0.0), &"coat")
	_head = Node3D.new()
	_head.position = Vector3(0.0, 0.66, 0.0)
	_torso.add_child(_head)
	var skull := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.11
	sphere.height = 0.24
	skull.mesh = sphere
	skull.material_override = _mats.get(&"skin")
	skull.position = Vector3(0.0, 0.13, 0.0)
	_head.add_child(skull)
	_part(_head, Vector3(0.23, 0.12, 0.24), Vector3(0.0, 0.2, 0.01), &"hair")
	set_pose(&"em_pe")

func set_pose(pose: StringName) -> void:
	if _hips == null:
		return
	var hip_y := 0.85
	var leg_angle := 0.0
	var lean := 0.0
	match pose:
		&"agachado":
			hip_y = 0.45
			leg_angle = deg_to_rad(58.0)
			lean = deg_to_rad(-18.0)
		&"sentado":
			hip_y = 0.45
			leg_angle = deg_to_rad(84.0)
		&"no_chao":
			hip_y = 0.1
			leg_angle = deg_to_rad(86.0)
	_hips.position.y = hip_y
	_torso.rotation.x = lean
	for leg in _legs:
		leg.rotation.x = leg_angle

func set_look(yaw: float, pitch: float) -> void:
	rotation.y = yaw
	if _head != null:
		_head.rotation.x = clampf(pitch, -0.8, 0.8) * 0.7

## Leans the torso forward (radians), for a body bent over a bench.
func set_lean(angle: float) -> void:
	if _torso != null:
		_torso.rotation.x = -angle

## Points one arm (side -1 left, +1 right) at a point in the world.
func reach(side: float, target: Vector3) -> void:
	var arm: Node3D = _arms.get(side)
	if arm == null:
		return
	arm.look_at(target, Vector3.UP)
	# The arm hangs along -Y; turn it so -Y takes the direction -Z was given.
	arm.rotate_object_local(Vector3.RIGHT, PI * 0.5)

## One arm's pivot (side -1 left, +1 right), for small gestures.
func arm(side: float) -> Node3D:
	return _arms.get(side)

func set_render_layer(bit: int) -> void:
	for mi in find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).layers = 1 << (bit - 1)

## A notebook on the lap (the double writing, the new figure).
func add_notebook() -> void:
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color("#e9e1cc")
	paper.roughness = 0.95
	_mats[&"paper"] = paper
	var book := _part(_hips, Vector3(0.22, 0.025, 0.3), Vector3(0.0, 0.06, -0.3), &"paper")
	book.rotation.x = deg_to_rad(-10.0)
	var layer: int = (_legs[0].get_child(0) as MeshInstance3D).layers if not _legs.is_empty() else 1
	book.layers = layer

func _part(parent: Node3D, size: Vector3, pos: Vector3, mat: StringName) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mats.get(mat)
	mi.position = pos
	parent.add_child(mi)
	return mi
