extends RefCounted
const Fx = preload("res://scripts/capture_fx.gd")

func test_flicker_is_never_white(t) -> void:
	t.eq(Fx.LIGHTEST, Color(0.75, 0.72, 0.66), "a cor mais clara é a do plano")
	var worst := 0.0
	var too_light := []
	var too_deep := []
	for k in 400:
		for reduced in [false, true]:
			var c: Color = Fx.flicker_color(k * 0.01, reduced)
			worst = maxf(worst, maxf(c.r, maxf(c.g, c.b)))
			if c.r > Fx.LIGHTEST.r or c.g > Fx.LIGHTEST.g or c.b > Fx.LIGHTEST.b:
				too_light.append(k * 0.01)
			if c.a > Fx.DEPTH + 0.0001:
				too_deep.append(k * 0.01)
	t.eq(too_light, [], "nunca passa da cor mais clara")
	t.eq(too_deep, [], "nunca cobre mais que a profundidade")
	t.ok(worst > Fx.DARK.r, "o piscar clareia de verdade")

func test_flicker_rates(t) -> void:
	t.ok(Fx.flicker_hz(false) <= 2.5, "no máximo 2,5 Hz")
	t.eq(Fx.flicker_hz(true), 1.0, "reduzido: 1 Hz")
	t.ok(absf(Fx.flicker_depth(true) - Fx.flicker_depth(false) * 0.5) < 0.0001, "reduzido: metade da amplitude")
	for reduced in [false, true]:
		var period := 1.0 / Fx.flicker_hz(reduced)
		var a: Color = Fx.flicker_color(0.13, reduced)
		var b: Color = Fx.flicker_color(0.13 + period, reduced)
		t.ok(a.is_equal_approx(b), "um ciclo por período (reduzido=%s)" % reduced)
		var half: Color = Fx.flicker_color(0.13 + period * 0.5, reduced)
		t.ok(not a.is_equal_approx(half), "meio período depois, outra cor (reduzido=%s)" % reduced)
