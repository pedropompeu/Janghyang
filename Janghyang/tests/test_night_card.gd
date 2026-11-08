extends RefCounted
const NightCard = preload("res://scripts/night_card_ui.gd")
const Noites = preload("res://scripts/story/noites.gd")

func test_the_card_has_the_date_and_the_chapters(t) -> void:
	var text: String = NightCard.night_text(Noites.get_night(1))
	t.ok(text.contains("12 de novembro"), "a data da noite")
	t.ok(text.contains("A casa da rua do Porto") and text.contains("O menino que escutava"), "os capítulos da noite")
	t.ok(not text.contains(NightCard.DEMO_END), "não é o fim da demo")

func test_the_last_demo_night_says_so(t) -> void:
	t.ok(NightCard.night_text(Noites.get_night(2), true).contains(NightCard.DEMO_END), "a noite 2 da demo fecha a demo")

func test_the_card_keeps_the_hypothesis_written_out(t) -> void:
	var n1: Dictionary = Noites.get_night(1)
	var right: String = n1.chapters[0].hypothesis[n1.chapters[0].right]
	t.ok(NightCard.night_text(n1, false, {"1": {"chosen": n1.chapters[0].right}}).contains(right), "a frase certa do capítulo 1 vai no cartão")
	t.ok(not NightCard.night_text(n1).contains(right), "sem página escrita, só o título")
	t.ok(not NightCard.night_text(n1, false, {"1": {"chosen": -1}}).contains(right), "página sem frase escolhida, só o título")
