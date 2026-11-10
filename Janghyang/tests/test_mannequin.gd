extends RefCounted
## The human figures (mannequin.gd): the sculpted porcelain bodies from
## assets/models/ follow the same pivots as the box body, so every pose, look
## and reach the callers use moves the skinned figure too. Without the model,
## the boxes.
const Mannequin = preload("res://scripts/mannequin.gd")

const STYLE := {"coat": Color("#4a5866"), "skin": Color("#d9b99b"), "hair": Color("#4a3a2c"), "trousers": Color("#2b2b30")}

func _figure(body := &"adulto"):
	var m = Mannequin.new()
	m.build(STYLE, 1.0, body)
	return m

func test_every_body_loads_as_a_skinned_figure(t) -> void:
	for body in Mannequin.BODIES:
		var m = _figure(body)
		t.ok(m.has_model(), "%s loads its figure" % body)
		t.eq(m.find_children("*", "Skeleton3D", true, false).size(), 1, "%s has one skeleton" % body)
		m.free()

func test_an_unknown_body_falls_back_to_boxes(t) -> void:
	var m = _figure(&"nenhum")
	t.ok(not m.has_model(), "no model for an unknown body")
	t.ok(m.find_children("*", "MeshInstance3D", true, false).size() >= 6, "the box body is built instead")
	m.set_pose(&"sentado")
	m.reach(1.0, Vector3(0.3, 1.2, -0.8))
	t.ok(m.arm(1.0) != null, "the box body still has its arms")
	m.free()

func test_the_figure_stands_on_the_floor(t) -> void:
	var m = _figure()
	t.near(m.bone_position(&"foot.L").y, 0.09, 0.03, "the left ankle at its height above the floor")
	t.near(m.bone_position(&"foot.R").y, 0.09, 0.03, "the right ankle at its height above the floor")
	t.ok(m.bone_position(&"head").y > 1.4, "the head at a grown man's height")
	m.free()

func test_sitting_lowers_the_body_and_keeps_the_feet_down(t) -> void:
	var m = _figure()
	var head: float = m.bone_position(&"head").y
	m.set_pose(&"sentado")
	t.ok(m.bone_position(&"head").y < head - 0.3, "sitting lowers the head")
	for side in [&"L", &"R"]:
		t.near(m.bone_position(StringName("foot." + side)).y, 0.09, 0.06, "sitting keeps the %s foot on the floor" % side)
		t.ok(m.bone_position(StringName("shin." + side)).z < m.bone_position(&"hips").z - 0.25, "the %s knee comes forward" % side)
	m.set_pose(&"em_pe")
	t.near(m.bone_position(&"head").y, head, 0.01, "standing up again restores the height")
	m.free()

func test_crouching_bends_the_knees_with_the_feet_down(t) -> void:
	var m = _figure()
	var head: float = m.bone_position(&"head").y
	m.set_pose(&"agachado")
	t.ok(m.bone_position(&"head").y < head - 0.3, "crouching lowers the head")
	t.near(m.bone_position(&"foot.L").y, 0.09, 0.06, "crouching keeps the foot on the floor")
	m.free()

func test_sitting_on_the_floor_puts_the_legs_ahead(t) -> void:
	var m = _figure()
	m.set_pose(&"no_chao")
	t.ok(m.bone_position(&"hips").y < 0.25, "the hips near the floor")
	t.ok(m.bone_position(&"foot.L").z < -0.5, "the legs stretched ahead")
	m.free()

func test_reach_points_the_arm_at_the_target(t) -> void:
	var m = _figure()
	var target := Vector3(0.4, 1.3, -0.9)
	var rest: float = m.bone_position(&"hand.R").distance_to(target)
	m.reach(1.0, target)
	var shoulder: Vector3 = m.bone_position(&"upper_arm.R")
	var hand: Vector3 = m.bone_position(&"hand.R")
	t.ok(hand.distance_to(target) < rest - 0.3, "the hand gets closer to the target")
	t.ok((hand - shoulder).normalized().dot((target - shoulder).normalized()) > 0.9, "the arm points at the target")
	m.free()

func test_turning_an_arm_pivot_moves_the_arm(t) -> void:
	var m = _figure()
	var hand: Vector3 = m.bone_position(&"hand.R")
	m.arm(1.0).rotation.x = -0.6
	m.sync_pose()
	t.ok(m.bone_position(&"hand.R").z > hand.z + 0.1, "a pivot turned by hand moves the arm (ending's page turn)")
	m.free()

func test_looking_up_tilts_the_head_back(t) -> void:
	var m = _figure()
	m.set_look(0.0, 0.5)
	t.ok(m.bone_transform(&"head").basis.y.z > 0.2, "looking up tilts the head back")
	m.free()

func test_a_notebook_shares_the_figure_layer(t) -> void:
	var m = _figure()
	m.set_render_layer(5)
	m.set_pose(&"no_chao")
	m.add_notebook()
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		t.eq((mi as MeshInstance3D).layers, 1 << 4, "%s on the figure's layer" % mi.name)
	m.free()

func test_figures_of_one_style_share_their_materials(t) -> void:
	var a = _figure()
	var b = _figure()
	var ma: MeshInstance3D = a.find_children("*", "MeshInstance3D", true, false)[0]
	var mb: MeshInstance3D = b.find_children("*", "MeshInstance3D", true, false)[0]
	t.ok(ma.get_surface_override_material(0) != null, "the figure has its porcelain")
	t.ok(ma.get_surface_override_material(0) == mb.get_surface_override_material(0), "one style, one set of materials (none freed when a figure goes)")
	a.free()
	b.free()

func test_a_seat_holds_a_sitting_figure_and_hides_otherwise(t) -> void:
	for body in [&"adulto", &"nenhum"]:
		var m = _figure(body)
		m.set_render_layer(5)
		t.ok(m.get_node_or_null("Seat") == null, "%s: no seat until one is asked" % body)
		m.set_pose(&"sentado")
		m.set_seat(true)
		var seat: Node3D = m.get_node("Seat")
		t.ok(seat.visible, "%s: the seat shows while sitting" % body)
		var top := -INF
		for mi in seat.find_children("*", "MeshInstance3D", true, false):
			var box: BoxMesh = (mi as MeshInstance3D).mesh
			top = maxf(top, mi.position.y + box.size.y * 0.5)
			t.eq((mi as MeshInstance3D).layers, 1 << 4, "%s: seat on the figure's layer" % body)
			t.ok(mi.find_children("*", "CollisionObject3D", true, false).is_empty(), "%s: nothing to bump into" % body)
		t.ok(top < Mannequin.SEAT_Y and top > Mannequin.SEAT_Y - 0.15, "%s: the seat top sits just under the hips (%.2f)" % [body, top])
		m.set_seat(false)
		t.ok(not seat.visible, "%s: the seat goes when the figure stands" % body)
		m.free()
