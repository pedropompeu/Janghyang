extends RefCounted
const Listen = preload("res://scripts/listen_model.gd")

func test_ear_hears_the_same_floor_only(t) -> void:
	var ear := Vector3(0.0, 1.0, 0.0)
	t.ok(Listen.audible(Vector3(10.0, 1.0, 0.0), ear, false), "10 m no mesmo piso: ouve")
	t.ok(Listen.audible(Vector3(0.0, 3.4, 11.5), ear, false), "11,5 m e 2,4 m acima: ainda o mesmo piso")
	t.ok(not Listen.audible(Vector3(0.0, 1.0, 12.5), ear, false), "12,5 m: longe demais")
	t.ok(not Listen.audible(Vector3(3.0, 4.0, 0.0), ear, false), "3 m acima: outro piso, não ouve")
	t.ok(not Listen.audible(Vector3(3.0, -2.0, 0.0), ear, false), "3 m abaixo: não ouve")

func test_stethoscope_hears_through_floors(t) -> void:
	var ear := Vector3(0.0, 1.0, 0.0)
	var far := Vector3(19.77, 4.0, 0.0)
	t.ok(absf(far.distance_to(ear) - 20.0) < 0.01, "a 20 m")
	t.ok(not Listen.audible(far, ear, false), "20 m e 3 m acima: sem o estetoscópio, nada")
	t.ok(Listen.audible(far, ear, true), "com o estetoscópio, ouve")
	t.ok(not Listen.audible(Vector3(0.0, 1.0, 25.5), ear, true), "além de 25 m, nem com ele")

func test_beat_every_period(t) -> void:
	var l = Listen.new()
	t.ok(l.beat(0.01), "o primeiro estalo sai logo")
	t.ok(not l.beat(Listen.PERIOD - 0.1), "antes de 1,5 s, nada")
	t.ok(l.beat(0.2), "aos 1,5 s, outro")
	l.reset()
	t.ok(l.beat(0.01), "ao recomeçar a escutar, sai logo de novo")
