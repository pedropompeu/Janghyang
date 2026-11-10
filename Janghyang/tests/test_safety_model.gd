extends RefCounted
const Safety = preload("res://scripts/safety_model.gd")
const Registry = preload("res://scripts/areas/registry.gd")
const Noites = preload("res://scripts/story/noites.gd")
const Casa = preload("res://scripts/areas/casa.gd")

func _casa() -> Dictionary:
	return {"level": &"casa", "lit": false, "entry_wound": false, "anchors": []}

func test_rules_by_night(t) -> void:
	var casa := _casa()
	t.ok(Safety.is_safe(Vector3.ZERO, &"casa_toda", casa), "noite 1: casa segura")
	t.ok(not Safety.is_safe(Vector3.ZERO, &"relogio_entrada", casa), "noite 2: sem corda, não")
	t.ok(Safety.is_safe(Vector3.ZERO, &"relogio_entrada", casa.merged({"entry_wound": true}, true)), "noite 2: com corda, sim")
	t.ok(not Safety.is_safe(Vector3.ZERO, &"comodos_com_luz", casa), "noite 3: no escuro, não")
	t.ok(Safety.is_safe(Vector3.ZERO, &"comodos_com_luz", casa.merged({"lit": true}, true)), "noite 3: com luz")
	t.ok(not Safety.is_safe(Vector3.ZERO, &"so_ancoras", casa.merged({"lit": true, "entry_wound": true}, true)), "noite 4: casa não basta")

func test_house_rules_need_the_house(t) -> void:
	var away := {"level": &"sotao", "lit": true, "entry_wound": true, "anchors": []}
	for rule in [&"casa_toda", &"relogio_entrada", &"comodos_com_luz", &"so_ancoras"]:
		t.ok(not Safety.is_safe(Vector3.ZERO, rule, away), "%s: fora da casa não protege" % rule)

func test_anchor_radius_is_four_metres(t) -> void:
	var w := {"level": &"sotao", "lit": false, "entry_wound": false, "anchors": [{"at": Vector3.ZERO, "left": 10.0}]}
	t.ok(Safety.is_safe(Vector3(3.9, 0, 0), &"so_ancoras", w), "dentro de 4 m")
	t.ok(not Safety.is_safe(Vector3(4.1, 0, 0), &"so_ancoras", w), "fora de 4 m")
	t.ok(not Safety.is_safe(Vector3(1, 0, 0), &"so_ancoras", {"level": &"sotao", "lit": false, "entry_wound": false, "anchors": [{"at": Vector3.ZERO, "left": 0.0}]}), "sem corda não protege")

func test_anchors_protect_under_every_rule(t) -> void:
	var w := {"level": &"sotao", "lit": false, "entry_wound": false, "anchors": [{"at": Vector3.ZERO, "left": 5.0}]}
	for rule in [&"casa_toda", &"relogio_entrada", &"comodos_com_luz", &"so_ancoras", &""]:
		t.ok(Safety.is_safe(Vector3(1, 0, 0), rule, w), "%s: o raio do âncora protege" % rule)

func test_no_rule_no_house_safety(t) -> void:
	t.ok(not Safety.is_safe(Vector3.ZERO, &"", _casa().merged({"lit": true, "entry_wound": true}, true)), "sem regra: só âncoras")

func test_an_anchor_guards_only_its_area(t) -> void:
	var w := {"level": &"casa", "lit": false, "entry_wound": false, "anchors": [{"at": Vector3(0, 3, 0), "left": 10.0, "level": &"sotao"}]}
	t.ok(not Safety.is_safe(Vector3.ZERO, &"so_ancoras", w), "um âncora do sótão não guarda o térreo logo abaixo")
	w.level = &"sotao"
	t.ok(Safety.is_safe(Vector3.ZERO, &"so_ancoras", w), "no sótão, guarda")

func test_rule_of_steps(t) -> void:
	var steps := [{"after": &"", "rule": &"casa_toda"}, {"after": &"achar_passagem", "rule": &"raio_relogio"}]
	t.eq(Safety.rule_of(steps, func(_id): return false), &"casa_toda", "before the panel")
	t.eq(Safety.rule_of(steps, func(id): return id == &"achar_passagem"), &"raio_relogio", "after it")
	t.eq(Safety.rule_of(&"relogio_entrada", func(_id): return false), &"relogio_entrada", "a single rule passes through")
	t.eq(Safety.rule_of([{"after": &"x", "rule": &"casa_toda"}], func(_id): return false), &"", "no step reached: only the anchors")

func test_raio_relogio(t) -> void:
	var w := {"level": &"casa", "clock": Vector3(3.1, 1.0, 8.88), "anchors": []}
	t.ok(Safety.is_safe(Vector3(1.8, 0.2, 8.3), &"raio_relogio", w), "the spawn is inside")
	t.ok(Safety.is_safe(Vector3(3.1, 0.0, 4.9), &"raio_relogio", w), "3.98 m, height ignored")
	t.ok(not Safety.is_safe(Vector3(3.1, 0.0, 4.8), &"raio_relogio", w), "4.08 m is out")
	t.ok(not Safety.is_safe(Vector3(6.7, 0.0, 0.3), &"raio_relogio", w), "the panel is out")
	w.level = &"passagem"
	t.ok(not Safety.is_safe(Vector3(3.1, 0.0, 8.0), &"raio_relogio", w), "only at home")
	t.ok(not Safety.is_safe(Vector3(3.1, 0.0, 8.0), &"raio_relogio", {"level": &"casa"}), "no clock, no refuge")

func test_wake_for(t) -> void:
	var away := Vector3(9.0, 3.0, 9.0)
	var home := Vector3(1.8, 0.2, 8.3)
	t.eq(Safety.wake_for(&"raio_relogio", away, home), home, "under the clock's radius Elias always wakes by the clock")
	for rule in [&"", &"casa_toda", &"relogio_entrada", &"comodos_com_luz", &"so_ancoras"]:
		t.eq(Safety.wake_for(rule, away, home), away, "%s: he wakes on the floor he was on, as before" % rule)

## Review Focus 2: no night leaves Elias waking where the Gasto that caught
## him can catch him again. Wherever a step's rule has a refuge at home, the
## point he wakes at (from every area) is inside it, at the rule's best.
func test_wake_point_is_safe_under_every_step(t) -> void:
	var home: Vector3 = Registry.def(Registry.HOME).safe
	var rules := {}
	for n in Noites.NOITES:
		var s = n.get("safety", &"")
		for step in (s if s is Array else [{"rule": s}]):
			rules[step.rule] = true
	rules[&"raio_relogio"] = true
	for rule in rules:
		var best := {"level": Registry.HOME, "lit": true, "entry_wound": true, "clock": Casa.ENTRY_CLOCK, "anchors": []}
		if not Safety.is_safe(home, rule, best) and rule != &"raio_relogio":
			continue
		for d in Registry.defs():
			var p: Vector3 = Safety.wake_for(rule, d.safe, home)
			if p != home and d.id != Registry.HOME:
				continue
			t.ok(Safety.is_safe(p, rule, best), "%s: waking from %s lands in the refuge" % [rule, d.id])
