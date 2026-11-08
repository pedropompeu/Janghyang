extends RefCounted
const NoiseModel = preload("res://scripts/noise_model.gd")

func test_three_noise_radii(t) -> void:
	var ear := Vector3.ZERO
	t.ok(NoiseModel.heard(Vector3(1.4, 0.0, 0.0), ear, NoiseModel.Level.QUIET), "quiet: 1,4 m ouve")
	t.ok(not NoiseModel.heard(Vector3(1.6, 0.0, 0.0), ear, NoiseModel.Level.QUIET), "quiet: 1,6 m não ouve")
	t.ok(NoiseModel.heard(Vector3(0.0, 0.0, 4.9), ear, NoiseModel.Level.NORMAL), "normal: 4,9 m ouve")
	t.ok(not NoiseModel.heard(Vector3(0.0, 0.0, 5.1), ear, NoiseModel.Level.NORMAL), "normal: 5,1 m não ouve")
	t.ok(NoiseModel.heard(Vector3(9.9, 0.0, 0.0), ear, NoiseModel.Level.LOUD), "loud: 9,9 m ouve")
	t.ok(not NoiseModel.heard(Vector3(10.1, 0.0, 0.0), ear, NoiseModel.Level.LOUD), "loud: 10,1 m não ouve")
	t.eq(NoiseModel.RADIUS, [1.5, 5.0, 10.0], "os três raios")

func test_breath_gasps_after_eight_seconds(t) -> void:
	var n = NoiseModel.new()
	t.eq(n.breath(7.9, true), &"", "7,9 s prendendo: nada")
	t.ok(n.holding, "prendendo")
	t.eq(n.breath(0.2, true), &"gasp", "passou de 8 s: ofego")
	t.ok(not n.holding, "o ofego solta o ar")
	t.eq(n.breath(NoiseModel.BREATH_REST - 0.1, true), &"", "no descanso, nada")
	t.ok(not n.holding, "no descanso, apertar não prende")
	n.breath(0.2, true)
	t.ok(n.holding, "depois do descanso, prende de novo")

func test_letting_go_starts_the_count_again(t) -> void:
	var n = NoiseModel.new()
	n.breath(6.0, true)
	t.eq(n.breath(0.1, false), &"", "soltar não ofega")
	t.ok(not n.holding, "soltou")
	t.eq(n.breath(7.0, true), &"", "a conta recomeça ao prender de novo")
	t.eq(n.breath(1.1, true), &"gasp", "e ofega aos 8 s da nova conta")

func test_level_out_of_range_is_clamped(t) -> void:
	t.ok(NoiseModel.heard(Vector3(9.0, 0.0, 0.0), Vector3.ZERO, 7), "nível acima do LOUD vale LOUD")
	t.ok(not NoiseModel.heard(Vector3(1.6, 0.0, 0.0), Vector3.ZERO, -2), "nível abaixo do QUIET vale QUIET")
