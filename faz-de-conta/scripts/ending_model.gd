extends RefCounted
## What the house is like after Elias walks off the tampo, by outcome.
## Pure logic; ending.gd applies it to the scene.

const FINAL := {
	&"corda": "Item 214 — maquete de casa. Dei corda. Dentro, uma figura nova. Ele não está mais sozinho.",
	&"parar": "Item 214 — maquete de casa. Deixei parar às 03:33. As figuras pararam de olhar para mim. A minha não.",
	&"incompleto": "Item 214 — maquete de casa. Funciona. Não sei por que há uma figura a mais.",
}

static func final_entry(outcome: StringName) -> String:
	return String(FINAL.get(outcome, FINAL[&"incompleto"]))

static func clock_running(outcome: StringName) -> bool:
	return outcome != &"parar"

static func echoes_mode(outcome: StringName) -> StringName:
	match outcome:
		&"corda":
			return &"loop"
		&"parar":
			return &"frozen"
	return &"as_is"

static func figure_alive(outcome: StringName) -> bool:
	return outcome == &"corda"
