extends RefCounted
const Writer = preload("res://scripts/double_writer.gd")
func _stats(c := 0.0, s := 0.0, a := {}) -> Dictionary:
	return {"crouched_s": c, "still_s": s, "meters": 100.0, "actions": a}

func test_first_and_last_are_fixed(t) -> void:
	var e: Array[String] = Writer.entries(_stats())
	t.eq(e.size(), 3, "three entries")
	t.eq(e[0], "catalogador. A mão direita gasta de um lado só.", "spec example first")
	t.eq(e[2], "catalogador. Entrou pela porta da rua. Ainda não saiu.", "closing entry")

func test_dominant_behavior(t) -> void:
	t.eq(Writer.entries(_stats(90.0))[1], "catalogador. Passa muito tempo agachado, como criança.", "crouching wins")
	t.eq(Writer.entries(_stats(0.0, 0.0, {&"bater": 5, &"dobrar": 2}))[1], "catalogador. Bate nas paredes e espera resposta.", "most counted action")
	t.eq(Writer.entries(_stats())[1], "catalogador. Anda pela casa como quem já conhece.", "default")

func test_never_invents(t) -> void:
	var e: Array[String] = Writer.entries(_stats(0.0, 0.0, {&"rolar": 1}))
	t.ok(not e[1].contains("Bate") and not e[1].contains("Dobra"), "only what the player did")
