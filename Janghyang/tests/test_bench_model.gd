extends RefCounted
## Noite 1, Tarefa 11 (§6.2, §8.3, item 4): as sete figuras do banco saem uma
## por visita, no máximo três, só para lugares legais.
const Bench = preload("res://scripts/bench_model.gd")
const Casa = preload("res://scripts/areas/casa.gd")
const Atlas = preload("res://scripts/atlas.gd")

func _bench():
	return Bench.new(Casa.DEF.bench.seats, Casa.DEF.bench.away)

func test_seven_sit_at_first(t) -> void:
	var b = _bench()
	t.eq(b.seated(), 7, "sete sentadas")
	t.eq(b.pending(), -1, "ninguém armado")
	t.eq(b.stage, &"busca", "começa na busca")

func test_one_leaves_per_visit(t) -> void:
	var b = _bench()
	b.on_leave_room()
	var i: int = b.pending()
	b.on_leave_room()
	t.ok(i >= 0 and b.pending() == i, "duas saídas seguidas armam uma só")
	b.move(i)
	t.eq(b.seated(), 6, "depois de move, seis")
	t.eq(b.pending(), -1, "move desarma")
	b.on_leave_room()
	t.ok(b.pending() >= 0 and b.pending() != i, "a visita seguinte arma a próxima")

func test_at_most_three_leave(t) -> void:
	var b = _bench()
	for k in 3:
		b.on_leave_room()
		b.move(b.pending())
	b.on_leave_room()
	t.eq(b.pending(), -1, "a quarta não arma")
	t.eq(b.seated(), 4, "quatro ficam")

func test_only_while_searching(t) -> void:
	var b = _bench()
	b.stage = &"outra"
	b.on_leave_room()
	t.eq(b.pending(), -1, "fora da busca, nada arma")

func test_they_go_where_the_def_says(t) -> void:
	var b = _bench()
	var away: Array = Casa.DEF.bench.away
	var got := []
	for k in 3:
		b.on_leave_room()
		var i: int = b.pending()
		var to: Dictionary = b.target_of(i)
		b.move(i)
		got.append(b.spots[i])
		t.eq(to.at, away[k].at, "a %dª vai para o lugar %d" % [k + 1, k])
	t.ok(got[0].at.distance_to(Vector3(12.0, 0.0, 3.0)) < 0.01 and got[0].pose == &"sentado" and not got[0].seated, "a primeira senta na beira da cama")
	t.ok(got[0].face.x < got[0].at.x, "olhando para oeste")
	t.ok(got[1].at.distance_to(Vector3(9.45, 0.0, 0.5)) < 0.01 and got[1].pose == &"em_pe" and got[1].face.z > got[1].at.z, "a segunda de pé no fim do corredor, olhando para o sul")
	var room := Vector3(4.2, 0.0, 3.5)
	var looks: Vector3 = got[2].face - got[2].at
	t.ok(got[2].at.distance_to(Vector3(0.5, 0.0, 0.5)) < 0.01 and got[2].pose == &"em_pe" and looks.dot(room - got[2].at) < 0.0, "a terceira no canto, de costas para a sala")

func test_never_lands_on_elias_hideout_or_door(t) -> void:   # Review Focus 4
	var at := Vector3(5.0, 0.0, 5.0)
	var door := Vector3(5.0, 0.0, 7.6)
	var hide := [AABB(Vector3(6.0, 0.0, 4.0), Vector3(1.0, 1.0, 2.0))]
	t.ok(not Bench.may_land(at, at + Vector3(0.5, 0.2, 0.0), [], Vector3(20, 0, 20), false), "Elias a 0,5 m")
	t.ok(Bench.may_land(at, at + Vector3(0.7, 0.2, 0.0), [], Vector3(20, 0, 20), false), "Elias a 0,7 m")
	t.ok(not Bench.may_land(Vector3(6.5, 0.0, 5.0), Vector3(0, 0, 0), hide, Vector3(20, 0, 20), false), "dentro do esconderijo")
	t.ok(Bench.may_land(at, Vector3(0, 0, 0), hide, Vector3(20, 0, 20), false), "fora do esconderijo")
	t.ok(not Bench.may_land(at, Vector3(0, 0, 0), [], at + Vector3(0, 0, 2.4), false), "a 2,4 m da porta")
	t.ok(Bench.may_land(at, Vector3(0, 0, 0), [], at + Vector3(0, 0, 2.6), false), "a 2,6 m da porta")
	t.ok(not Bench.may_land(at, Vector3(0, 0, 0), [], Vector3(20, 0, 20), true), "visto")

func test_def_places_are_legal(t) -> void:
	var atlas := Atlas.new()
	var door: Vector3 = Casa.DOOR_FRONT
	var hides := []
	for h in Casa.HIDEOUTS.values():
		hides.append(AABB(h[0] - h[1] * 0.5, h[1]))
	var places := []
	for s in Casa.DEF.bench.seats:
		places.append(s)
	for a in Casa.DEF.bench.away:
		places.append(a.at)
	t.eq(places.size(), 10, "sete assentos e três destinos")
	for p in places:
		t.ok(Bench.may_land(p, Vector3(100, 0, 100), hides, door, false), "%s longe da porta e fora dos esconderijos" % p)
		t.ok(atlas.room_at(p) in [&"entrada", &"brincar", &"corredor", &"quarto", &"figuras", &"corredor_sul"], "%s dentro da casa" % p)
