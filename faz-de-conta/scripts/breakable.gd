extends StaticBody3D
## Something the stick can break: a hollow panel of the wall, a trapdoor, the
## cracked glass of the dome, a porcelain cup. Each knock cracks it; the last
## one breaks it, its pieces fall and the way is open.

signal shattered

## &"oco" (hollow wall), &"alcapao" (trapdoor), &"vidro", &"porcelana".
@export var kind: StringName = &"oco"
@export var hits_needed := 3

var hits := 0
var broken := false

## One knock. Returns &"crack", &"break", or &"" once nothing is left.
func hit() -> StringName:
	if broken:
		return &""
	hits += 1
	if hits < hits_needed:
		_crack()
		return &"crack"
	_break()
	return &"break"

static func sound_for(k: StringName, breaking: bool) -> StringName:
	match k:
		&"vidro":
			return &"glass" if breaking else &"tink"
		&"porcelana":
			return &"shatter" if breaking else &"tink"
		_:
			return &"crumble" if breaking else &"oco"

func _crack() -> void:
	if not is_inside_tree():
		return
	var tw := create_tween()
	var p := position
	tw.tween_property(self, "position", p + Vector3(0.015, 0.0, 0.015), 0.04)
	tw.tween_property(self, "position", p, 0.08)

func _break() -> void:
	broken = true
	if is_inside_tree():
		for c in get_children():
			if c is CollisionShape3D:
				c.set_deferred(&"disabled", true)
		_debris()
		for c in get_children():
			if c is MeshInstance3D:
				c.visible = false
	shattered.emit()

## A handful of pieces falling from where it stood; they settle and stay.
func _debris() -> void:
	var src: MeshInstance3D = null
	for c in get_children():
		if c is MeshInstance3D:
			src = c
	if src == null or not (src.mesh is BoxMesh):
		return
	var size: Vector3 = (src.mesh as BoxMesh).size
	var m := src.material_override
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(name)
	var parent := get_parent()
	for i in 7:
		var piece := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(rng.randf_range(0.06, 0.2), rng.randf_range(0.04, 0.12), rng.randf_range(0.06, 0.2))
		piece.mesh = bm
		piece.material_override = m
		var from := global_position + src.position + Vector3(rng.randf_range(-0.5, 0.5) * size.x, rng.randf_range(-0.3, 0.3) * size.y, rng.randf_range(-0.5, 0.5) * size.z)
		parent.add_child(piece)
		piece.global_position = from
		piece.rotation = Vector3(rng.randf() * TAU, rng.randf() * TAU, rng.randf() * TAU)
		var floor_y := global_position.y - size.y * 0.5 + bm.size.y * 0.5
		var land := from + Vector3(rng.randf_range(-0.4, 0.4), 0.0, rng.randf_range(-0.4, 0.4))
		land.y = floor_y
		var tw := piece.create_tween()
		tw.tween_property(piece, "global_position", land, rng.randf_range(0.25, 0.45)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
