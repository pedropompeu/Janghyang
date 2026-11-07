extends Node3D
## A thing from the cracks, only during 03:33: porcelain teeth and rusted
## clock hands in a corner of the floor. Meshes only. It never moves while
## seen; it moves once you look away, or if you come close without looking.

const Placement = preload("res://scripts/crack_placement.gd")
const SEEN_OFFSET := Vector3(0.0, 0.15, 0.0)

## Set by the creator before add_child.
var main: Node
var anchors: Array[Vector3] = []
## Other crack things, so two never share a corner.
var others: Array = []

var index := -1
var _active := false
var _was_seen := false

func _ready() -> void:
	visible = false
	var porcelain := _mat(Color("#f2efe6"), 0.35)
	var rust := _mat(Color("#6b3a22"), 0.95)
	for k in 7:
		var a := lerpf(-0.9, 0.9, k / 6.0)
		var tooth := _box(Vector3(0.035, 0.05 + 0.02 * (k % 2), 0.03), Vector3(sin(a) * 0.12, 0.03, -cos(a) * 0.12 + 0.06), porcelain)
		tooth.rotation.y = -a
	for k in 3:
		var hand := _box(Vector3(0.012, 0.012, 0.22 - 0.04 * k), Vector3(0.0, 0.012, 0.05), rust)
		hand.rotation = Vector3(deg_to_rad(-12.0 - 9.0 * k), deg_to_rad(-40.0 + 45.0 * k), 0.0)
		hand.position += Vector3(-0.04 + 0.04 * k, 0.0, 0.0)

func activate() -> void:
	_active = true
	_was_seen = false
	relocate()

func deactivate() -> void:
	_active = false
	visible = false

func is_active() -> bool:
	return _active

func relocate() -> void:
	index = Placement.pick(anchors, main.player.global_position, index, _blocked)
	visible = index >= 0
	if index >= 0:
		global_position = anchors[index]
		# Face into the room, away from the corner.
		look_at(Vector3(7.5, global_position.y, 4.5), Vector3.UP, true)

func _process(_delta: float) -> void:
	if not _active:
		return
	if not visible:
		relocate()
		return
	if main.is_seen(global_position + SEEN_OFFSET):
		_was_seen = true
		return
	var q: Vector3 = main.player.global_position
	var near := Vector2(global_position.x - q.x, global_position.z - q.z).length() < Placement.MIN_PLAYER_DIST
	if _was_seen or near:
		_was_seen = false
		relocate()

func _blocked(p: Vector3) -> bool:
	if main.is_seen(p + SEEN_OFFSET):
		return true
	for o in others:
		if o != self and o.visible and o.index >= 0 and o.anchors[o.index] == p:
			return true
	return false

func _mat(c: Color, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m

func _box(size: Vector3, pos: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = m
	mi.position = pos
	add_child(mi)
	return mi
