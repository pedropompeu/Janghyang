extends RefCounted
## What the double writes about the player at 03:33. It only ever describes
## what the visit's numbers show; the item number comes from the catalog.

const FIRST := "catalogador. A mão direita gasta de um lado só."
const LAST := "catalogador. Entrou pela porta da rua. Ainda não saiu."
const CROUCHED := "catalogador. Passa muito tempo agachado, como criança."
const STILL := "catalogador. Fica parado olhando, por muito tempo."
const DEFAULT := "catalogador. Anda pela casa como quem já conhece."
## Checked in this order; on a tie the earlier verb wins.
const BY_ACTION := [
	[&"dobrar", "catalogador. Dobra as paredes para ver o que há atrás."],
	[&"bater", "catalogador. Bate nas paredes e espera resposta."],
	[&"rolar", "catalogador. Brinca com a bola quando acha que ninguém vê."],
]
const CROUCHED_S := 60.0
const STILL_S := 120.0

static func entries(stats: Dictionary) -> Array[String]:
	return [FIRST, _dominant(stats), LAST]

static func _dominant(stats: Dictionary) -> String:
	if float(stats.get("crouched_s", 0.0)) >= CROUCHED_S:
		return CROUCHED
	var actions: Dictionary = stats.get("actions", {})
	var best := ""
	var best_n := 0
	for pair in BY_ACTION:
		var n := int(actions.get(pair[0], 0))
		if n > best_n:
			best = pair[1]
			best_n = n
	if best != "":
		return best
	if float(stats.get("still_s", 0.0)) >= STILL_S:
		return STILL
	return DEFAULT
