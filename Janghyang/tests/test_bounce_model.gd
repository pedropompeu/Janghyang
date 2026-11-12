extends RefCounted
## Noite 1, Tarefa 10 (§6.2, item 8): a bola que quica para fora do corredor.
const Bounce = preload("res://scripts/bounce_model.gd")
const Director = preload("res://scripts/scare_director.gd")

func test_bounces_fall_and_fade(t) -> void:
	var hs: Array = Bounce.hops(Vector3(9.45, 0.0, 0.5), Vector3(9.45, 0.0, 6.0))
	t.eq(hs.size(), Bounce.HOPS, "cinco quiques")
	for k in range(1, hs.size()):
		t.ok(hs[k].height < hs[k - 1].height, "quique %d mais baixo" % k)
		t.ok(hs[k].db < hs[k - 1].db, "quique %d mais baixo no som" % k)
		t.ok(hs[k].t > hs[k - 1].t, "quique %d depois do anterior" % k)
	for h in hs:
		t.ok(h.db <= Director.MAX_DB, "nenhum quique acima de MAX_DB")
	t.ok(absf(hs[-1].t - 2.4) < 0.001, "o último em 2,4 s")
	t.ok(absf(hs[0].height - 0.5) < 0.001 and absf(hs[0].db + 6.0) < 0.001, "o primeiro: 0,5 m, -6 dB")

func test_ball_stops_short_of_him(t) -> void:
	for elias in [Vector3(9.45, 0.0, 6.0), Vector3(9.0, 0.0, 1.2), Vector3(10.2, 0.0, 3.0)]:
		var hs: Array = Bounce.hops(Vector3(9.45, 0.0, 0.5) if elias.z > 3.0 else Vector3(9.45, 0.0, 6.9), elias)
		t.ok(absf(hs[-1].at.distance_to(elias) - Bounce.STOP) <= 0.01, "para a 0,6 m de %s" % elias)
		for h in hs:
			t.ok(h.at.distance_to(elias) >= Bounce.STOP - 0.01, "nunca mais perto que 0,6 m")

func test_it_comes_from_the_far_end(t) -> void:
	var ends := [Vector3(9.45, 0.0, 0.5), Vector3(9.45, 0.0, 6.9)]
	t.eq(Bounce.far_end(ends, Vector3(9.45, 0.0, 1.2)), ends[1], "Elias no norte: sai do sul")
	t.eq(Bounce.far_end(ends, Vector3(9.45, 0.0, 6.0)), ends[0], "Elias no sul: sai do norte")
