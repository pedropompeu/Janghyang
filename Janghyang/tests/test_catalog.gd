extends RefCounted
const Catalog = preload("res://scripts/catalog.gd")
const Data = preload("res://scripts/catalog_data.gd")

func test_opening_entry(t) -> void:
	var c = Catalog.new()
	t.eq(Catalog.format(c.entries[0]), "Item 214 — maquete de casa sob redoma, relógio no telhado, parado. Dei corda para testar o mecanismo.", "opening entry text")
	t.eq(c.next_number(), 215, "next is 215")

func test_sequential_and_no_repeat(t) -> void:
	var c = Catalog.new()
	t.eq(c.catalog(&"bola").get("number"), 215, "first catalog is 215")
	t.ok(c.catalog(&"bola").is_empty(), "same item twice is refused")
	t.eq(c.catalog(&"vela").get("number"), 216, "numbering continues")

func test_gates(t) -> void:
	var c = Catalog.new()
	t.ok(not c.can_catalog(&"cabana"), "cabana needs the fold")
	t.ok(not c.can_catalog(&"boneco"), "doll needs to be turned")
	t.ok(not c.can_catalog(&"pagina_cabana"), "page needs the 03:33")
	c.set_flag(&"f1_folded", true)
	t.ok(c.can_catalog(&"cabana"), "fold opens cabana")

func test_pages_follow_items(t) -> void:
	var c = Catalog.new()
	c.catalog(&"relogio_entrada")
	t.ok(c.pages.has(&"p1"), "entry clock reveals page 1")

func test_double_entries(t) -> void:
	var c = Catalog.new()
	c.catalog(&"bola")
	c.add_double_entries(["catalogador. A mão direita gasta de um lado só."])
	t.eq(c.entries[-1].get("author"), &"duplo", "author is the double")
	t.eq(c.entries[-1].get("number"), 216, "double continues numbering")
	t.eq(c.count_elias_items(), 1, "double and 214 do not count")

func test_data_integrity(t) -> void:
	for id in Data.ITEMS:
		var item: Dictionary = Data.ITEMS[id]
		t.ok(String(item.text) != "", "%s has text" % id)
		t.ok(item.page == &"" or Data.PAGES.has(item.page), "%s page exists" % id)
	for p in Data.PAGES:
		t.ok(String(Data.PAGES[p]).split("\n").size() <= 4, "%s has at most 4 lines" % p)

func test_piece_note_is_an_elias_entry_with_its_page(t) -> void:
	var c := Catalog.new()
	var e: Dictionary = c.note(&"coroa")
	t.eq(e.item, &"coroa", "the note names the piece")
	t.eq(e.author, &"elias", "Elias writes it")
	t.ok(c.pages.has(Data.NOTES[&"coroa"].page), "its diary page is glued in")
	t.ok(c.note(&"coroa").is_empty(), "a piece is noted once")
	t.ok(c.note(&"nada").is_empty(), "unknown notes are refused")

func test_every_piece_has_a_note_and_a_page(t) -> void:
	for id in [&"coroa", &"ponteiros", &"mostrador", &"caixa"]:
		t.ok(Data.NOTES.has(id), "note for %s" % id)
		t.ok(Data.PAGES.has(Data.NOTES[id].page), "page for %s" % id)

func test_to_dict_round_trip(t) -> void:
	var c = Catalog.new()
	c.catalog(&"relogio_entrada")
	c.set_flag(&"f1_folded", true)
	c.catalog(&"cabana")
	c.add_double_entries(["outra letra"])
	var d = Catalog.new()
	d.from_dict(c.to_dict())
	t.eq(d.to_dict(), c.to_dict(), "o mesmo catálogo volta")
	t.eq(d.next_number(), c.next_number(), "a numeração continua de onde parou")
	t.ok(d.can_catalog(&"bola") and not d.can_catalog(&"cabana"), "o que já foi catalogado não repete")

func test_from_dict_takes_json_types(t) -> void:
	var d = Catalog.new()
	d.from_dict({"entries": [{"number": 214.0, "text": "x", "author": "elias", "item": "maquete"}, {"number": 215.0, "text": "y", "author": "elias", "item": "bola"}], "pages": ["p1"], "flags": {"f1_folded": true}})
	t.eq(d.next_number(), 216, "o número volta inteiro")
	t.ok(d.has(&"bola") and d.pages.has(&"p1") and d.flags.get(&"f1_folded", false), "os ids voltam")
