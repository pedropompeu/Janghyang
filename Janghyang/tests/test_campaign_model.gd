extends RefCounted
const Campaign = preload("res://scripts/campaign_model.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Atlas = preload("res://scripts/atlas.gd")

const TEST_PATH := "user://test_campanha.json"
const BAD_PATH := "user://test_campanha.bad.json"
const BAD_PATH_2 := "user://test_campanha.bad-2.json"

func _clean() -> void:
	for p in [TEST_PATH, BAD_PATH, BAD_PATH_2, TEST_PATH + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _write(text: String) -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(text)
	f.close()

func test_starts_on_night_one(t) -> void:
	var c = Campaign.new()
	t.eq(c.night, 1, "noite 1")
	t.eq(c.pieces, [], "sem peças")

func test_carry_keeps_pieces_and_drops_light(t) -> void:
	var c = Campaign.new()
	c.carry({"pieces": [&"coroa"], "items": [&"espelho", &"pilha", &"fosforo", &"brinquedo"], "shortcuts": ["Oco1"]})
	t.eq(c.pieces, [&"coroa"], "peça passa")
	t.eq(c.items, [&"espelho"], "pilha, fósforo e brinquedo não passam")
	t.eq(c.shortcuts, ["Oco1"], "atalho passa")

func test_carry_adds_to_what_was_kept(t) -> void:
	var c = Campaign.new()
	c.carry({"pieces": [&"coroa"], "items": [&"espelho"], "shortcuts": ["Oco1"]})
	c.carry({"pieces": [&"coroa", &"ponteiros"], "items": [&"lupa", &"estetoscopio"], "shortcuts": ["Oco1", "Alcapao"]})
	t.eq(c.pieces, [&"coroa", &"ponteiros"], "as peças somam, sem repetir")
	t.eq(c.items, [&"espelho", &"lupa", &"estetoscopio"], "os itens de mão somam")
	t.eq(c.shortcuts, ["Oco1", "Alcapao"], "os atalhos somam")

func test_carry_takes_the_latest_plan_and_catalog(t) -> void:
	var c = Campaign.new()
	var cat = Catalog.new()
	cat.catalog(&"bola")
	var atlas := Atlas.new()
	atlas.visited[&"brincar"] = true
	c.carry({"plan": {"notes": [1]}, "catalog": cat.to_dict(), "visited": atlas.to_dict(), "chapters": {1: {"chosen": 2}}})
	c.carry({"pieces": [&"coroa"]})
	t.eq(c.plan, {"notes": [1]}, "a planta fica")
	t.eq(c.catalog, cat.to_dict(), "o catálogo fica")
	t.eq(c.visited, atlas.to_dict(), "os cômodos vistos ficam")
	t.eq(c.chapters, {1: {"chosen": 2}}, "os capítulos ficam")

func test_save_round_trip(t) -> void:
	_clean()
	var c = Campaign.new()
	var cat = Catalog.new()
	cat.catalog(&"relogio_entrada")
	cat.set_flag(&"f1_folded", true)
	var atlas := Atlas.new()
	atlas.visited[&"entrada"] = true
	c.carry({"pieces": [&"coroa"], "items": [&"espelho"], "shortcuts": ["Oco1"], "plan": {"chalk": [Vector3(1, 2, 3)]}, "catalog": cat.to_dict(), "visited": atlas.to_dict(), "chapters": {1: {"chosen": 0, "crossed": [1]}}})
	c.night = 2
	t.eq(c.save(TEST_PATH), OK, "salva")
	t.ok(not FileAccess.file_exists(TEST_PATH + ".tmp"), "o arquivo temporário não sobra")
	var d = Campaign.new()
	t.eq(d.load_or_fresh(TEST_PATH), true, "carrega")
	t.eq(d.to_dict(), c.to_dict(), "o mesmo estado volta")
	t.eq(d.night, 2, "na noite 2")
	t.ok(d.pieces is Array and d.pieces[0] is StringName, "as peças voltam como StringName")
	var back = Catalog.new()
	back.from_dict(d.catalog)
	t.ok(back.has(&"relogio_entrada") and back.flags.get(&"f1_folded", false), "o catálogo volta inteiro")
	var seen := Atlas.new()
	seen.from_dict(d.visited)
	t.eq(seen.visited, {&"entrada": true}, "os cômodos vistos voltam ao atlas")
	_clean()

func test_missing_save_starts_fresh(t) -> void:
	_clean()
	var c = Campaign.new()
	c.night = 3
	t.eq(c.load_or_fresh(TEST_PATH), false, "sem arquivo, não carrega")
	t.eq(c.night, 1, "noite 1")
	t.ok(not FileAccess.file_exists(BAD_PATH), "nada a guardar")

func test_corrupt_save_starts_fresh_and_keeps_the_file(t) -> void:
	_clean()
	_write("{nao é json")
	var c = Campaign.new()
	t.eq(c.load_or_fresh(TEST_PATH), false, "corrompido não carrega")
	t.eq(c.night, 1, "volta à noite 1")
	t.eq(FileAccess.get_file_as_string(BAD_PATH), "{nao é json", "o arquivo ruim é guardado como estava")
	t.ok(not FileAccess.file_exists(TEST_PATH), "e sai do lugar do save")
	_clean()

func test_unknown_version_starts_fresh_and_keeps_the_file(t) -> void:
	_clean()
	var c = Campaign.new()
	c.night = 2
	c.save(TEST_PATH)
	var text := FileAccess.get_file_as_string(TEST_PATH).replace('"version":1', '"version":99')
	t.ok(text.contains('"version":99'), "a versão foi trocada no arquivo")
	_write(text)
	var d = Campaign.new()
	t.eq(d.load_or_fresh(TEST_PATH), false, "versão desconhecida não carrega")
	t.eq(d.night, 1, "volta à noite 1")
	t.ok(FileAccess.file_exists(BAD_PATH), "o arquivo é guardado")
	_clean()

func test_wrong_shape_starts_fresh(t) -> void:
	_clean()
	_write('{"version": 1, "night": "dois"}')
	var c = Campaign.new()
	t.eq(c.load_or_fresh(TEST_PATH), false, "um save sem estado não carrega")
	t.eq(c.night, 1, "volta à noite 1")
	_write(JSON.stringify({"version": 1, "state": JSON.from_native({"version": 1, "night": "dois"})}))
	t.eq(c.load_or_fresh(TEST_PATH), false, "um save com campos errados não carrega")
	t.eq(c.night, 1, "volta à noite 1")
	t.ok(FileAccess.file_exists(BAD_PATH) and not FileAccess.file_exists(TEST_PATH), "o save de forma errada também sai do lugar")
	_clean()

func _state(over: Dictionary) -> Dictionary:
	return {"version": 1, "night": 1, "pieces": [], "items": [], "shortcuts": [], "plan": {}, "catalog": {}, "visited": {}, "chapters": {}}.merged(over, true)

func test_bad_elements_do_not_load(t) -> void:
	var c = Campaign.new()
	t.eq(c.from_dict(_state({"pieces": [{}]})), false, "uma peça que não é nome não carrega")
	t.eq(c.from_dict(_state({"items": [3]})), false, "um item que não é nome não carrega")
	t.eq(c.from_dict(_state({"shortcuts": [[1]]})), false, "um atalho que não é texto não carrega")
	t.eq(c.from_dict(_state({"pieces": ["coroa"]})), true, "texto vira nome")

func test_a_night_past_the_campaign_does_not_load(t) -> void:
	var c = Campaign.new()
	t.eq(c.from_dict(_state({"night": 6})), false, "não há noite 6")
	t.eq(c.from_dict(_state({"night": 5})), true, "a noite 5 carrega")

func test_a_second_bad_save_keeps_the_first(t) -> void:
	_clean()
	var c = Campaign.new()
	_write("primeiro")
	c.load_or_fresh(TEST_PATH)
	_write("segundo")
	c.load_or_fresh(TEST_PATH)
	t.eq(FileAccess.get_file_as_string(BAD_PATH), "primeiro", "o primeiro arquivo ruim fica")
	t.eq(FileAccess.get_file_as_string(BAD_PATH_2), "segundo", "o segundo vai ao lado")
	_clean()
