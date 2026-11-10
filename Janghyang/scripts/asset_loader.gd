extends RefCounted
## Spec §14.2: every asset in assets/ is optional. A file that is there loads;
## one that is not gives null quietly, and the caller keeps its block.

## A new instance of the scene at `path` (a .glb or .tscn), or null.
static func instance(path: String) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var scene := load(path) as PackedScene
	if scene == null:
		return null
	var node := scene.instantiate()
	if node is Node3D:
		return node
	node.free()
	return null

## The texture at `path`, or null.
static func texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
