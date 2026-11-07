extends Area3D
## A catalogue spot laid over a piece. Lives on layer 2 so it never blocks the
## walking loop nor the E ray; only the player's CatalogRay sees it.

@export var item_id: StringName

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
	monitoring = false
	monitorable = true
	add_to_group("catalog_target")
