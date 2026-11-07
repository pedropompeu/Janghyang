extends RefCounted
## A-014: the double is the doll seated on the entry bench. The catalogue reads
## the doll's "sat" state through the toggled signal, so becoming the double must
## report it seated even if Elias never sat the doll before 03:33.
const Doll = preload("res://scripts/doll.gd")

func test_double_counts_as_seated_doll(t) -> void:
	var d = Doll.new()
	var states: Array = []
	d.toggled.connect(func(lying: bool) -> void: states.append(lying))
	d.become_double(Vector3(0.7, 0.45, 8.5))
	t.ok(states.has(false), "becoming the double reports it seated (not lying)")
	t.ok(not d.is_lying(), "the double is not lying")
	d.free()
