extends RefCounted
const Safety = preload("res://scripts/safety_model.gd")

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
