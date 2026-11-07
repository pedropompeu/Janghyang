extends RefCounted
const End = preload("res://scripts/ending_model.gd")

func test_final_entries_are_the_spec_texts(t) -> void:
	t.eq(End.final_entry(&"corda"), "Item 214 — maquete de casa. Dei corda. Dentro, uma figura nova. Ele não está mais sozinho.", "with winding")
	t.eq(End.final_entry(&"parar"), "Item 214 — maquete de casa. Deixei parar às 03:33. As figuras pararam de olhar para mim. A minha não.", "letting it stop")
	t.eq(End.final_entry(&"incompleto"), "Item 214 — maquete de casa. Funciona. Não sei por que há uma figura a mais.", "leaving early")

func test_world_after_exit(t) -> void:
	t.ok(End.clock_running(&"corda") and End.clock_running(&"incompleto"), "clock keeps running")
	t.ok(not End.clock_running(&"parar"), "clock stops behind him")
	t.eq(End.echoes_mode(&"corda"), &"loop", "company in a loop")
	t.eq(End.echoes_mode(&"parar"), &"frozen", "stopped together")
	t.eq(End.echoes_mode(&"incompleto"), &"as_is", "echoes stay as they were")
	t.ok(End.figure_alive(&"corda") and not End.figure_alive(&"parar") and not End.figure_alive(&"incompleto"), "only the wound clock keeps him moving")
