extends RefCounted
const Fog = preload("res://scripts/fog_grid.gd")

func test_drawer_grid_is_about_a_thousand_cells(t) -> void:
	var g = Fog.new(Rect2(-1, -1, 18, 14))
	t.eq(g.to_bytes().size(), ceili(36 * 28 / 8.0), "1008 células em bits")

func test_reveal_round_trip(t) -> void:
	var g = Fog.new(Rect2(0, 0, 4, 4))
	t.ok(g.reveal(Vector2(1.2, 1.2)), "nova")
	t.ok(not g.reveal(Vector2(1.3, 1.4)), "mesma célula de 0,5 m")
	var h = Fog.new(Rect2(0, 0, 4, 4))
	t.ok(h.from_bytes(g.to_bytes()), "lê o save")
	t.ok(h.seen(Vector2(1.2, 1.2)) and h.count() == 1, "volta igual do save")
	t.ok(not h.seen(Vector2(2.2, 1.2)), "a vizinha segue na névoa")

func test_outside_rect_is_ignored(t) -> void:
	var g = Fog.new(Rect2(0, 0, 4, 4))
	t.ok(not g.reveal(Vector2(9, 9)), "fora do nível não quebra")
	t.ok(not g.seen(Vector2(-0.1, 2.0)), "fora não é visto")
	t.eq(g.count(), 0, "nada contado")

func test_edges_belong_to_the_grid(t) -> void:
	var g = Fog.new(Rect2(0, 0, 4, 4))
	t.ok(g.reveal(Vector2(0.0, 0.0)), "o canto de origem conta")
	t.ok(g.reveal(Vector2(3.99, 3.99)), "a última célula conta")

func test_wrong_size_bytes_are_refused(t) -> void:
	var g = Fog.new(Rect2(0, 0, 4, 4))
	g.reveal(Vector2(1.0, 1.0))
	t.ok(not g.from_bytes(PackedByteArray([1, 2, 3])), "outro tamanho é recusado")
	t.ok(g.seen(Vector2(1.0, 1.0)), "e a grade fica como estava")
