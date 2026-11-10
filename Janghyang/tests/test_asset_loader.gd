extends RefCounted
## Spec §14.2: every asset in assets/ is optional. A file that is there loads;
## one that is not gives null quietly, and the caller keeps its block.
const AssetLoader = preload("res://scripts/asset_loader.gd")

func test_a_model_that_exists_loads_with_its_skeleton(t) -> void:
	var node: Node3D = AssetLoader.instance("res://assets/models/figura_adulto.glb")
	t.ok(node != null, "the adult figure loads")
	if node != null:
		t.eq(node.find_children("*", "Skeleton3D", true, false).size(), 1, "the figure has one skeleton")
		node.free()

func test_a_missing_model_gives_null(t) -> void:
	t.ok(AssetLoader.instance("res://assets/models/nao_existe.glb") == null, "a missing model gives null")

func test_textures(t) -> void:
	t.ok(AssetLoader.texture("res://assets/textures/figura_adulto.png") != null, "the adult figure's texture loads")
	t.ok(AssetLoader.texture("res://assets/textures/nao_existe.png") == null, "a missing texture gives null")
