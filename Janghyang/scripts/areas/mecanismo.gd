extends RefCounted
## The tower of the movement, rising through the attic: the clock the house is
## part of. Inside: a ladder to a west ledge, a great wheel turning flat with
## one long arm, an east ledge, two more ladders, and at the top the back of
## the dial, where the hands are. Its door opens from the attic floor.

const Y := 2.94
const TOWER := Rect2(5.2, 1.0, 5.4, 5.5)
const TOWER_TOP := 12.6
const LEDGE_Y := 5.4
const L3_Y := 8.2
const PLATFORM_Y := 10.4
const HUB := Vector3(7.9, 5.33, 3.75)

## The tower has no floor of its own to wake on: Elias wakes on the attic
## floor, by the shaft, as before.
const DEF := {
	"id": &"mecanismo",
	"maquete": &"item_214",
	"name": "O mecanismo",
	"rooms": [
		{"id": &"mecanismo", "name": "torre", "rect": TOWER, "y": Vector2(2.8, 13.0)},
	],
	"safe": Vector3(9.8, 3.14, 0.55),
	"safe_room": &"sotao",
	"links": [
		{"to": &"sotao", "at": Vector3(7.9, 3.14, 7.4), "path": [Vector3(11.2, 3.14, 0.55), Vector3(11.2, 3.14, 7.4)]},
	],
	"tasks": {&"mecanismo": &"entrar_mecanismo"},
}

static func build(main: Node3D) -> void:
	_build_tower(main, main)

static func _slab(main: Node3D, parent: Node3D, x0: float, z0: float, x1: float, z1: float, top: float, m: Material) -> Node3D:
	return main._box(parent, Vector3(x1 - x0, 0.12, z1 - z0), Vector3((x0 + x1) * 0.5, top - 0.06, (z0 + z1) * 0.5), m)

static func _metal(main: Node3D, parent: Node3D, x0: float, z0: float, x1: float, z1: float, top: float, m: Material) -> void:
	var b := _slab(main, parent, x0, z0, x1, z1, top, m)
	b.add_to_group(&"Metal")

static func _build_tower(main: Node3D, root: Node3D) -> void:
	var tower := Node3D.new()
	tower.name = "Mecanismo"
	root.add_child(tower)
	var wood: Material = main.mat_wood_dark
	var iron: Material = main._mat("#3b3b40", 0.55, 0.7)
	var brass: Material = main.mat_brass
	var x0 := TOWER.position.x
	var x1 := TOWER.end.x
	var z0 := TOWER.position.y
	var z1 := TOWER.end.y
	var ix0 := x0 + 0.07
	var ix1 := x1 - 0.07
	var iz0 := z0 + 0.07
	var iz1 := z1 - 0.07

	main._wall_x(tower, x0, z0, z1, Y, TOWER_TOP, wood)
	main._wall_x(tower, x1, z0, z1, Y, TOWER_TOP, wood)
	main._wall_z(tower, z0, x0, x1, Y, TOWER_TOP, wood)
	main._wall_z(tower, z1, x0, 7.4, Y, TOWER_TOP, wood)
	main._wall_z(tower, z1, 8.4, x1, Y, TOWER_TOP, wood)
	main._wall_z(tower, z1, 7.4, 8.4, Y + 2.1, TOWER_TOP, wood)
	_slab(main, tower, x0, z0, x1, z1, TOWER_TOP + 0.12, wood)
	main._hinge("DoorTower", Vector3(1.0, 2.1, 0.06), Vector3(0.5, 1.05, 0.0),
			Vector3(7.4, Y, z1), Vector3.ZERO, Vector3(0.0, deg_to_rad(90.0), 0.0),
			"abrir a porta da torre", "fechar a porta da torre", false, false, false, main.mat_door)

	# Grating floor, the west ledge and its ladder.
	_metal(main, tower, ix0, iz0, ix1, iz1, Y + 0.03, iron)
	_metal(main, tower, ix0, iz0, 6.3, 4.9, LEDGE_Y, iron)
	main._rungs(tower, Vector3(ix0 + 0.04, Y, 5.5), LEDGE_Y - Y + 0.1, false)
	main._ladder_area(tower, "LadderTowerA", Vector3(ix0 + 0.28, (Y + LEDGE_Y + 0.7) * 0.5, 5.5), Vector3(0.55, LEDGE_Y + 0.7 - Y, 0.7))

	# The great wheel: a flat gear on an axle, one long arm across it.
	main._cyl(tower, 0.16, HUB.y - Y - 0.06, Vector3(HUB.x, (Y + HUB.y - 0.06) * 0.5, HUB.z), iron)
	var gear: AnimatableBody3D = preload("res://scripts/turning_gear.gd").new()
	gear.name = "TurningGear"
	gear.position = HUB
	gear.sync_to_physics = true
	gear.add_to_group(&"Metal")
	tower.add_child(gear)
	var disc := CylinderMesh.new()
	disc.top_radius = 1.1
	disc.bottom_radius = 1.1
	disc.height = 0.1
	main._add_mesh(gear, disc, Vector3.ZERO, brass)
	for i in 16:
		var a := TAU * i / 16.0
		main._add_mesh(gear, _box_mesh(Vector3(0.2, 0.1, 0.16)), Vector3(cos(a) * 1.16, 0.0, sin(a) * 1.16), brass, Vector3(0.0, -a, 0.0))
	main._add_mesh(gear, _box_mesh(Vector3(3.24, 0.1, 0.7)), Vector3(0.0, 0.02, 0.0), iron)
	var disc_shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 1.1
	cyl.height = 0.1
	disc_shape.shape = cyl
	gear.add_child(disc_shape)
	var arm_shape := CollisionShape3D.new()
	var arm := BoxShape3D.new()
	arm.size = Vector3(3.24, 0.1, 0.7)
	arm_shape.shape = arm
	arm_shape.position.y = 0.02
	gear.add_child(arm_shape)

	# East ledge, ladder up to the north gallery, ladder up to the top.
	_metal(main, tower, 9.5, iz0, ix1, iz1, LEDGE_Y, iron)
	main._rungs(tower, Vector3(ix1 - 0.04, LEDGE_Y, 2.6), L3_Y - LEDGE_Y + 0.1, false)
	main._ladder_area(tower, "LadderTowerB", Vector3(ix1 - 0.28, (LEDGE_Y + L3_Y + 0.7) * 0.5, 2.6), Vector3(0.55, L3_Y + 0.7 - LEDGE_Y, 0.7))
	_metal(main, tower, ix0, iz0, ix1, 2.2, L3_Y, iron)
	main._rungs(tower, Vector3(ix0 + 0.04, L3_Y, 1.6), PLATFORM_Y - L3_Y + 0.1, false)
	main._ladder_area(tower, "LadderTowerC", Vector3(ix0 + 0.28, (L3_Y + PLATFORM_Y + 0.7) * 0.5, 1.6), Vector3(0.55, PLATFORM_Y + 0.7 - L3_Y, 0.7))
	_metal(main, tower, 6.3, iz0, ix1, iz1, PLATFORM_Y, iron)
	_metal(main, tower, ix0, 2.2, 6.3, iz1, PLATFORM_Y, iron)

	# The back of the dial, and the hands left on the top platform.
	main._cyl(tower, 0.95, 0.05, Vector3(7.9, 11.45, iz1 - 0.03), wood, false, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	main._cyl(tower, 0.08, 0.5, Vector3(7.9, 11.45, iz1 - 0.3), brass, false, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	main._box(tower, Vector3(0.5, 0.12, 0.36), Vector3(9.7, PLATFORM_Y + 0.06, 5.7), main.mat_red, false)
	main._piece(tower, &"ponteiros", Vector3(9.7, PLATFORM_Y + 0.12, 5.7))
	main._omni(tower, Vector3(7.9, 12.1, 3.75), Color(0.75, 0.82, 1.0), 0.5, 5.0)
	main._omni(tower, Vector3(7.9, 8.6, 3.75), Color(1.0, 0.72, 0.45), 0.35, 6.5)
	main._omni(tower, Vector3(7.9, Y + 1.8, 4.6), Color(1.0, 0.7, 0.42), 0.25, 4.0)

	# The clock face outside, stopped a minute short.
	var face: Material = main.mat_cream
	main._cyl(tower, 1.05, 0.06, Vector3(7.9, 11.45, z1 + 0.1), face, false, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	for h in 12:
		var a := TAU * h / 12.0
		main._box(tower, Vector3(0.05, 0.16, 0.02), Vector3(7.9 + sin(a) * 0.88, 11.45 + cos(a) * 0.88, z1 + 0.14), main.mat_dark, false, Vector3(0.0, 0.0, -a))
	_hand(main, tower, Vector3(7.9, 11.45, z1 + 0.16), 0.55, (3.0 + 32.0 / 60.0) / 12.0 * TAU, 0.06)
	_hand(main, tower, Vector3(7.9, 11.45, z1 + 0.17), 0.85, 32.0 / 60.0 * TAU, 0.04)

	# The pendulum, under the top platform, ticking.
	var pivot := Node3D.new()
	pivot.name = "Pendulum"
	pivot.position = Vector3(7.9, PLATFORM_Y - 0.12, 5.75)
	tower.add_child(pivot)
	main._box(pivot, Vector3(0.05, 2.9, 0.05), Vector3(0.0, -1.45, 0.0), brass, false)
	main._cyl(pivot, 0.34, 0.08, Vector3(0.0, -2.95, 0.0), brass, false, Vector3(deg_to_rad(90.0), 0.0, 0.0))
	main._catalog_target(tower, &"pendulo", Vector3(7.9, PLATFORM_Y - 3.0, 5.75), Vector3(2.0, 0.9, 0.5))
	_swing(main, pivot)

static func _swing(main: Node3D, pivot: Node3D) -> void:
	var tw := pivot.create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(pivot, "rotation:z", 0.28, 1.0)
	tw.tween_callback(func() -> void: main.sfx.play_at(&"tick", pivot.global_position + Vector3(0.0, -2.9, 0.0), &"Mundo", -6.0))
	tw.tween_property(pivot, "rotation:z", -0.28, 1.0)
	tw.tween_callback(func() -> void: main.sfx.play_at(&"tick", pivot.global_position + Vector3(0.0, -2.9, 0.0), &"Mundo", -8.0))

static func _hand(main: Node3D, parent: Node3D, center: Vector3, length: float, angle: float, width: float) -> void:
	var dir := Vector3(sin(angle), cos(angle), 0.0)
	main._box(parent, Vector3(width, length, 0.02), center + dir * length * 0.5, main.mat_dark, false, Vector3(0.0, 0.0, -angle))

static func _box_mesh(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m
