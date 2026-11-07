extends RefCounted
## The thread of the visit as Elias writes it: phases of a few lots each.
## Each phase ends with a piece of Inácio's pocket watch; the phase is the
## first one whose piece is still missing, so lots done early show struck when
## their phase opens. No totals anywhere.

const PIECES: Array[StringName] = [&"coroa", &"ponteiros", &"mostrador", &"caixa"]

const PHASES := [
	{"id": &"I", "title": "I. A casa da rua do Porto", "tasks": [&"cat_relogio", &"cat_desenho", &"achar_passagem", &"coroa"], "stalkers": 0},
	{"id": &"II", "title": "II. O sótão", "tasks": [&"subir_sotao", &"entrar_mecanismo", &"ponteiros"], "stalkers": 1},
	{"id": &"III", "title": "III. A gaveta", "tasks": [&"achar_alcapao", &"descer_gaveta", &"mostrador"], "stalkers": 2},
	{"id": &"IV", "title": "IV. A relojoaria", "tasks": [&"quebrar_redoma", &"chegar_relojoaria", &"caixa"], "stalkers": 2},
	{"id": &"V", "title": "V. 03:33", "tasks": [&"voltar", &"hora", &"corda", &"pagina", &"sair"], "stalkers": 0},
]

const TASKS := {
	&"cat_relogio": "catalogar o relógio da entrada",
	&"cat_desenho": "catalogar o desenho do menino",
	&"achar_passagem": "achar o que o desenho esconde",
	&"coroa": "a coroa do relógio de bolso",
	&"subir_sotao": "subir ao sótão",
	&"entrar_mecanismo": "entrar no mecanismo da torre",
	&"ponteiros": "os ponteiros, lá no alto",
	&"achar_alcapao": "achar o alçapão do quarto",
	&"descer_gaveta": "descer à gaveta da bancada",
	&"mostrador": "o mostrador",
	&"quebrar_redoma": "sair da redoma pelo vidro trincado",
	&"chegar_relojoaria": "chegar à Relojoaria Varela",
	&"caixa": "a caixa do relógio",
	&"voltar": "voltar à casa com as quatro peças",
	&"hora": "esperar o relógio da entrada",
	&"corda": "dar corda, ou não",
	&"pagina": "ler o que ficou na cabana",
	&"sair": "sair pela beira do tampo",
}

var phase := 0
var done: Dictionary = {}

## Strikes a lot. Returns &"phase" when a new phase opens, &"task" when only
## the lot is new, &"" when it was already struck.
func complete(id: StringName) -> StringName:
	if done.has(id) or not TASKS.has(id):
		return &""
	done[id] = true
	var before := phase
	phase = _first_open_phase()
	return &"phase" if phase != before else &"task"

func is_done(id: StringName) -> bool:
	return done.has(id)

func pieces() -> int:
	var n := 0
	for p in PIECES:
		if done.has(p):
			n += 1
	return n

func has_piece(id: StringName) -> bool:
	return PIECES.has(id) and done.has(id)

func all_pieces() -> bool:
	return pieces() == PIECES.size()

func phase_id() -> StringName:
	return PHASES[phase].id

func stalkers() -> int:
	return PHASES[phase].stalkers

## The lots of phase i (the current one by default), as {id, text, done}.
func current_tasks(i := -1) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in PHASES[phase if i < 0 else i].tasks:
		out.append({"id": id, "text": TASKS[id], "done": done.has(id)})
	return out

func _first_open_phase() -> int:
	for i in PIECES.size():
		if not done.has(PIECES[i]):
			return i
	return PHASES.size() - 1
