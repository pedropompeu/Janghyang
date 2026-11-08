extends RefCounted
const Compass = preload("res://scripts/compass_model.gd")
const LINKS := [{"from": &"casa", "to": &"passagem", "at": Vector3(1, 0, 0), "gate": &"oco"}, {"from": &"passagem", "to": &"sotao", "at": Vector3(5, 3, 0), "gate": &""}]

func test_same_area_points_straight(t) -> void:
	var a := Compass.aim(Vector3.ZERO, &"casa", {"area": &"casa", "at": Vector3(3, 0, 4)}, LINKS)
	t.eq(a.mode, &"point", "aponta")
	t.eq(a.at, Vector3(3, 0, 4), "direto na meta")
	t.eq(a.tilt, 0, "mesmo nível")

func test_other_area_points_at_the_first_link(t) -> void:
	var a := Compass.aim(Vector3.ZERO, &"casa", {"area": &"sotao", "at": Vector3(9, 3, 0)}, LINKS)
	t.eq(a.mode, &"point", "aponta")
	t.eq(a.at, Vector3(1, 0, 0), "primeiro link do caminho")
	t.eq(a.tilt, 0, "o oco fica no mesmo nível")

func test_tilt_follows_the_first_link(t) -> void:
	var up := Compass.aim(Vector3(1, 0, 0), &"passagem", {"area": &"sotao", "at": Vector3(9, 3, 0)}, LINKS)
	t.eq(up.at, Vector3(5, 3, 0), "da passagem, o link do sótão")
	t.eq(up.tilt, 1, "sobe")
	var down := Compass.aim(Vector3(5, 3, 0), &"sotao", {"area": &"casa", "at": Vector3(0, 0, 3)}, LINKS)
	t.eq(down.at, Vector3(5, 3, 0), "do sótão, volta pelo mesmo link")
	t.eq(down.tilt, 0, "já está na altura do link")
	var low := Compass.aim(Vector3(5, 6, 0), &"sotao", {"area": &"casa", "at": Vector3(0, 0, 3)}, LINKS)
	t.eq(low.tilt, -1, "desce")

func test_closed_link_still_routes(t) -> void:
	t.eq(Compass.route(&"casa", &"sotao", LINKS).size(), 2, "o oco fechado conta")
	t.eq(Compass.route(&"casa", &"sotao", LINKS)[0], LINKS[0], "primeiro o oco")

func test_links_work_both_ways(t) -> void:
	var back := Compass.route(&"sotao", &"casa", LINKS)
	t.eq(back.size(), 2, "volta pelo mesmo caminho")
	t.eq(back[0], LINKS[1], "primeiro o link do sótão")
	t.eq(Compass.route(&"casa", &"casa", LINKS), [], "já na área: nenhum link")

func test_route_is_shortest(t) -> void:
	var links := LINKS + [{"from": &"casa", "to": &"sotao", "at": Vector3(0, 3, 0), "gate": &""}]
	t.eq(Compass.route(&"casa", &"sotao", links).size(), 1, "o atalho direto ganha")

func test_outside_any_room_spins(t) -> void:
	t.eq(Compass.aim(Vector3.ZERO, &"", {"area": &"casa", "at": Vector3.ONE}, LINKS).mode, &"spin", "fora de área: gira")
	t.eq(Compass.aim(Vector3.ZERO, &"casa", {"area": &"gaveta", "at": Vector3.ONE}, LINKS).mode, &"spin", "sem caminho: gira")
	t.eq(Compass.aim(Vector3.ZERO, &"casa", {}, LINKS).mode, &"spin", "sem meta: gira")

func test_tick_and_tremble(t) -> void:
	t.near(Compass.tick_period(30.0), 1.0, 0.001, "longe: 1 s")
	t.near(Compass.tick_period(25.0), 1.0, 0.001, "a 25 m: 1 s")
	t.near(Compass.tick_period(1.0), 0.25, 0.001, "perto: 0,25 s")
	t.near(Compass.tick_period(2.0), 0.25, 0.001, "a 2 m: 0,25 s")
	t.near(Compass.tick_period(13.5), 0.625, 0.001, "no meio: linear")
	t.ok(Compass.trembles(5.9) and not Compass.trembles(6.1), "treme abaixo de 6 m")
	t.eq(Compass.TREMBLE_RADIUS, 6.0, "raio do tremor")
	t.eq(Compass.HEARD_RADIUS, 3.0, "raio em que os Gastos ouvem o tique")
