extends Area3D
## A ladder's volume: while Elias is inside, W and S climb instead of walk.
## The volume reaches a little above the landing so the last steps carry him
## over the edge.

func _ready() -> void:
	body_entered.connect(func(b: Node) -> void:
		if "ladders" in b:
			b.ladders += 1)
	body_exited.connect(func(b: Node) -> void:
		if "ladders" in b:
			b.ladders = maxi(0, b.ladders - 1))
