extends RefCounted
## The five nights of the campaign, as data (spec §5, §6.2, §9.1, §10, §11).
## A night is one session: Elias winds the model, wakes in the house, plays its
## chapters and ends on a 03:33 (short on nights 1 to 4, the full one with the
## choice on night 5). What carries from one night to the next lives in
## scripts/campaign_model.gd.
##
## Each night: n, date (the notebook's date for it), chapters (spec §6.2:
## {id, area, title, clues, reward}; chapters 1 and 2 also poses, hypothesis
## and right, for chapter_model.gd, and their figures in the areas' DEF
## "staging"), goals ({task, area, at}: what the compass
## points to, in order), pieces (the watch pieces won that night), phases (the
## night's lots for quest_model.gd), safety (§11), stalkers (how many Gastos
## from the moment `after` is struck; &"" is the start of the night),
## anchor_time (seconds a wound anchor clock lasts), entry_clock_scale,
## capture_clicks (§10), pickups (ids from the areas' DEF pickups) and final.
##
## Nights 3 to 5 are drafts: today's phases and pieces, so the whole flow and
## the ending stay playable and tested. The mansion (item 216) is outside the
## demo plan, so chapter 7 stays in the house for now. Dates, titles and new
## lot texts are drafts too (D9, waiting for Pedro's reading).

const Quest = preload("res://scripts/quest_model.gd")

## The demo build (feature tag "demo") ends after this night.
const DEMO_LAST := 2

## Nights 1 to 4 end at home: back on the ground floor, then the short 03:33.
const _HOME_STRETCH := {"id": &"fim", "title": "Antes do 03:33", "tasks": [&"voltar_terreo", &"dar_corda"]}

const NOITES := [
	{
		"n": 1, "date": "12 de novembro",
		"chapters": [
			{"id": 1, "area": &"casa", "title": "A casa da rua do Porto", "clues": [&"desenho", &"relogio_entrada", &"casinha"], "reward": &"achar_passagem",
				"poses": 4, "right": 1, "hypothesis": [
					"Inácio copiou a maquete de uma casa que viu num catálogo de relojoeiro.",
					"A maquete é a casa onde o próprio Inácio foi menino.",
					"Inácio fez a casinha para um filho que esperou e nunca chegou a ter.",
				]},
			{"id": 2, "area": &"passagem", "title": "O menino que escutava", "clues": [&"caixa_musica", &"bola"], "reward": &"coroa",
				"poses": 4, "right": 2, "hypothesis": [
					"Na passagem, o menino escutava o pai escondido, morrendo de medo dele.",
					"A passagem era o atalho do pai até a oficina, onde só ele entrava.",
					"Pela parede, o menino aprendeu com o pai que tudo que tem corda para.",
				]},
		],
		## Tarefa 9 (§6.2, §11): the watch points at each clue of chapter 1 in turn.
		"goals": [
			{"task": &"cat_relogio", "area": &"casa", "at": Vector3(3.1, 1.0, 8.6)},
			{"task": &"cat_desenho", "area": &"casa", "at": Vector3(14.05, 1.5, 0.4)},
			{"task": &"cat_casinha", "area": &"casa", "at": Vector3(14.6, 0.6, 8.2)},
			{"task": &"achar_passagem", "area": &"casa", "at": Vector3(6.7, 0.6, 0.3)},
			{"task": &"coroa", "area": &"passagem", "at": Vector3(0.75, 0.2, -0.65)},
		],
		"pieces": [&"coroa"],
		"phases": [
			{"id": &"1", "title": "1. A casa da rua do Porto", "tasks": [&"cat_relogio", &"cat_desenho", &"cat_casinha", &"achar_passagem"]},
			{"id": &"2", "title": "2. O menino que escutava", "tasks": [&"coroa"]},
			_HOME_STRETCH,
		],
		"safety": &"casa_toda",
		"stalkers": [{"after": &"", "n": 0}, {"after": &"coroa", "n": 1}],
		"setpieces": [&"luz_de_fora", &"vitrine", &"chave_vitrine", &"desenho_cera", &"bola_quica"],
		"anchor_time": 90.0, "entry_clock_scale": 1.0, "capture_clicks": 10,
		"pickups": [&"pilha_brincar", &"pilha_quarto", &"pilha_figuras", &"vela_brincar", &"vela_corredor", &"vela_quarto", &"fosforo_entrada", &"fosforo_corredor_sul", &"fosforo_cabeceira", &"pilha_passagem", &"vela_passagem", &"fosforo_passagem"], "final": false,
	},
	{
		"n": 2, "date": "13 de novembro",
		"chapters": [
			{"id": 3, "area": &"sotao", "title": "Os lençóis", "clues": [&"lencois"], "reward": &"alcapao"},
			{"id": 4, "area": &"mecanismo", "title": "A hora marcada", "clues": [&"pendulo"], "reward": &"ponteiros"},
		],
		"goals": [
			{"task": &"alcapao", "area": &"sotao", "at": Vector3(7.9, 3.14, 7.0)},
			{"task": &"ponteiros", "area": &"mecanismo", "at": Vector3(9.7, 10.52, 5.7)},
		],
		"pieces": [&"ponteiros"],
		"phases": [
			{"id": &"3", "title": "3. Os lençóis", "tasks": [&"subir_sotao", &"alcapao"]},
			{"id": &"4", "title": "4. A hora marcada", "tasks": [&"entrar_mecanismo", &"ponteiros"]},
			_HOME_STRETCH,
		],
		"safety": &"relogio_entrada",
		"stalkers": [{"after": &"", "n": 1}, {"after": &"alcapao", "n": 2}],
		"anchor_time": 75.0, "entry_clock_scale": 1.0, "capture_clicks": 12,
		"pickups": [&"pilha_sotao_oeste", &"pilha_sotao_leste", &"pilha_sotao_sul", &"vela_sotao_oeste", &"vela_sotao_leste", &"vela_sotao_sul", &"fosforo_sotao_poco", &"fosforo_sotao_sul", &"pilha_torre", &"vela_torre", &"fosforo_torre"], "final": false,
	},
	{
		"n": 3, "date": "14 de novembro",
		"chapters": [
			{"id": 5, "area": &"gaveta", "title": "As versões gastas", "clues": [&"dedal"], "reward": &"mostrador"},
		],
		"goals": [
			{"task": &"mostrador", "area": &"gaveta", "at": Vector3(3.0, -2.75, 10.6)},
		],
		"pieces": [&"mostrador"],
		"phases": [
			{"id": &"5", "title": "5. As versões gastas", "tasks": [&"achar_alcapao", &"descer_gaveta", &"mostrador"]},
			_HOME_STRETCH,
		],
		"safety": &"comodos_com_luz",
		"stalkers": [{"after": &"", "n": 2}],
		"anchor_time": 60.0, "entry_clock_scale": 0.5, "capture_clicks": 13,
		"pickups": [], "final": false,
	},
	{
		"n": 4, "date": "15 de novembro",
		"chapters": [
			{"id": 6, "area": &"tampo", "title": "A carta", "clues": [&"relogios_varela"], "reward": &"caixa"},
		],
		"goals": [
			{"task": &"caixa", "area": &"tampo", "at": Vector3(25.0, 0.96, -11.4)},
		],
		"pieces": [&"caixa"],
		"phases": [
			{"id": &"6", "title": "6. A carta", "tasks": [&"quebrar_redoma", &"chegar_relojoaria", &"caixa"]},
			_HOME_STRETCH,
		],
		"safety": &"so_ancoras",
		"stalkers": [{"after": &"", "n": 2}],
		"anchor_time": 45.0, "entry_clock_scale": 1.0, "capture_clicks": 15,
		"pickups": [], "final": false,
	},
	{
		"n": 5, "date": "16 de novembro",
		"chapters": [
			{"id": 7, "area": &"casa", "title": "03:33", "clues": [&"figura_inacio_a", &"figura_inacio_b", &"figura_catalogador"], "reward": &"voltar"},
		],
		"goals": [
			{"task": &"voltar", "area": &"casa", "at": Vector3(1.8, 0.2, 8.3)},
		],
		"pieces": [],
		"phases": [Quest.PHASES[-1]],
		"safety": &"so_ancoras",
		"stalkers": [{"after": &"", "n": 3}],
		"anchor_time": 30.0, "entry_clock_scale": 1.0, "capture_clicks": 16,
		"pickups": [], "final": true,
	},
]

## Night `n` as a copy (the table and the home stretch it shares stay
## untouched), or {} outside the campaign.
static func get_night(n: int) -> Dictionary:
	for night in NOITES:
		if night.n == n:
			return night.duplicate(true)
	return {}

## The last night this build plays: the demo (feature tag "demo", set by its
## export preset) stops at DEMO_LAST.
static func last(demo := OS.has_feature("demo")) -> int:
	return DEMO_LAST if demo else NOITES.size()
