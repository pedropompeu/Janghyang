extends StaticBody3D
## The cabinet's key (spec §6.2): small, brass, half under the cabana cushion,
## at the end of the boy's chalk (casa DEF giz_vitrine). E takes it: a night
## flag (chave_vitrine) and a note in the catalogue, not a thing in the hand.
## On a night that does not list it, it is gone: its resolved state.

const ID := &"chave_vitrine"

var main: Node
var def: Dictionary
var data: Dictionary

var _active := false

func _ready() -> void:
	position = data.at
	rotation.y = deg_to_rad(20.0)
	var bow := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.01
	torus.outer_radius = 0.022
	bow.mesh = torus
	bow.material_override = main.mat_brass
	bow.position = Vector3(-0.045, 0.004, 0.0)
	add_child(bow)
	var shaft := MeshInstance3D.new()
	var bar := BoxMesh.new()
	bar.size = Vector3(0.07, 0.008, 0.008)
	shaft.mesh = bar
	shaft.material_override = main.mat_brass
	shaft.position = Vector3(0.01, 0.004, 0.0)
	add_child(shaft)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.16, 0.05, 0.1)
	cs.shape = shape
	add_child(cs)
	_set_shown(false)

func on_night(night: Dictionary) -> void:
	_active = night.get("setpieces", []).has(data.id)
	_set_shown(_active and not main.step_done(ID))

func _set_shown(on: bool) -> void:
	visible = on
	collision_layer = 1 if on else 0

func get_prompt() -> String:
	return "pegar a chave" if visible else ""

func interact() -> void:
	if not visible:
		return
	main.set_night_flag(ID)
	var entry: Dictionary = main.catalog.note(ID)
	main.sfx.play_at(&"tink", global_position, &"Mundo", -10.0)
	if not entry.is_empty():
		main.cataloged.emit(entry)
	_set_shown(false)
