extends RefCounted
const Atlas = preload("res://scripts/atlas.gd")

func test_rooms_by_position(t) -> void:
	var a := Atlas.new()
	t.eq(a.room_at(Vector3(4.0, 0.0, 3.0)), &"brincar", "playroom")
	t.eq(a.room_at(Vector3(9.4, 0.0, 3.0)), &"corredor", "corridor")
	t.eq(a.room_at(Vector3(5.0, 0.0, -0.7)), &"passagem", "secret passage behind the north wall")
	t.eq(a.room_at(Vector3(3.0, Atlas.ATTIC_Y, 6.0)), &"sotao", "attic, above the playroom")
	t.eq(a.room_at(Vector3(7.9, 5.5, 3.7)), &"mecanismo", "the tower inside the attic")
	t.eq(a.room_at(Vector3(8.0, Atlas.DRAWER_Y, 6.0)), &"gaveta", "the drawer under the house")
	t.eq(a.room_at(Vector3(25.0, 0.0, -9.0)), &"oficina_varela", "the back of the clock shop")
	t.eq(a.room_at(Vector3(200.0, 0.0, 0.0)), &"", "nowhere")

func test_visit_only_once(t) -> void:
	var a := Atlas.new()
	t.eq(a.visit(Vector3(4.0, 0.0, 3.0)), &"brincar", "first time: new")
	t.eq(a.visit(Vector3(4.5, 0.0, 3.0)), &"", "again: nothing new")
	t.ok(a.visited.has(&"brincar"), "remembered")

func test_levels_group_rooms(t) -> void:
	var a := Atlas.new()
	t.eq(a.level_of(&"quarto"), &"casa", "bedroom on the ground floor")
	t.eq(a.level_of(&"loja_varela"), &"tampo", "the shop lies on the bench")
	t.ok(a.rooms_on(&"casa").has(&"entrada"), "entry listed on its level")
	t.ok(not a.rooms_on(&"casa").has(&"sotao"), "attic is another sheet")

func test_every_room_has_a_name_and_a_level(t) -> void:
	for r in Atlas.ROOMS:
		t.ok(r.name != "" and Atlas.LEVELS.has(r.level), "room %s" % r.id)

func test_every_room_says_where_in_portuguese(t) -> void:
	for r in Atlas.ROOMS:
		var at: String = Atlas.where(r.id)
		t.ok(at.ends_with(r.name) and (at.begins_with("no ") or at.begins_with("na ")), "%s: %s" % [r.id, at])
	t.eq(Atlas.where(&"passagem"), "na passagem", "feminine")
	t.eq(Atlas.where(&"corredor"), "no corredor", "masculine")
	t.eq(Atlas.where(&""), "na casa", "nowhere known: the house")
