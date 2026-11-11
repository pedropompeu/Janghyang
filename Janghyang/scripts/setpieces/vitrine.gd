extends Node3D
## Night 1's locked cabinet (spec §6.2): a glass-doored cabinet against the
## figure room's east wall, the little house on its shelf. Without the key
## (night flag chave_vitrine, setpieces/chave_vitrine.gd) E on the door only
## clicks the lock; with it the door opens and the catalogue may take the
## little house (flag vitrine_aberta, catalog_data ITEMS.casinha.gate).
## On a night that does not list it the door stands open: its resolved state.

## The cabinet's footprint: centre on the floor and size (x depth, y height, z width).
const SIZE := Vector3(0.5, 1.6, 1.1)
const SHELF_Y := 0.6
const FLAG := &"vitrine_aberta"
const KEY := &"chave_vitrine"

var main: Node
var def: Dictionary
var data: Dictionary

var door: Node3D
var _active := false
var _opened := false

func _ready() -> void:
	_build()

func _build() -> void:
	var at: Vector3 = data.at
	var wood: Material = main.mat_wood_dark
	var x0 := at.x - SIZE.x * 0.5
	var z0 := at.z - SIZE.z * 0.5
	# Back, sides, top, bottom and the shelf.
	main._box(self, Vector3(0.04, SIZE.y, SIZE.z), Vector3(at.x + SIZE.x * 0.5 - 0.02, SIZE.y * 0.5, at.z), wood, true)
	for dz in [-1.0, 1.0]:
		main._box(self, Vector3(SIZE.x, SIZE.y, 0.04), Vector3(at.x, SIZE.y * 0.5, at.z + dz * (SIZE.z * 0.5 - 0.02)), wood, true)
	main._box(self, Vector3(SIZE.x, 0.04, SIZE.z), Vector3(at.x, SIZE.y - 0.02, at.z), wood, true)
	main._box(self, Vector3(SIZE.x, 0.1, SIZE.z), Vector3(at.x, 0.05, at.z), wood, true)
	main._box(self, Vector3(SIZE.x - 0.06, 0.03, SIZE.z - 0.08), Vector3(at.x + 0.02, SHELF_Y, at.z), main.mat_wood, true)
	# The little house on the shelf (it was in the playroom before, spec §6.2).
	var h := Vector3(at.x + 0.05, SHELF_Y + 0.015, at.z)
	main._box(self, Vector3(0.3, 0.2, 0.26), h + Vector3(0.0, 0.1, 0.0), main.mat_wood, false)
	main._box(self, Vector3(0.3, 0.02, 0.17), h + Vector3(0.0, 0.25, -0.07), main.mat_red, false, Vector3(deg_to_rad(-35.0), 0.0, 0.0))
	main._box(self, Vector3(0.3, 0.02, 0.17), h + Vector3(0.0, 0.25, 0.07), main.mat_red, false, Vector3(deg_to_rad(35.0), 0.0, 0.0))
	main._box(self, Vector3(0.02, 0.1, 0.06), h + Vector3(-0.16, 0.05, 0.0), main.mat_dark, false)
	main._box(self, Vector3(0.02, 0.06, 0.06), h + Vector3(-0.155, 0.36, 0.0), main.mat_brass, false)
	# The glass door, hinged at its north edge, opening west into the room.
	door = main._hinge("CabinetDoor", Vector3(0.03, SIZE.y - 0.08, SIZE.z - 0.02), Vector3(0.0, 0.0, (SIZE.z - 0.02) * 0.5),
			Vector3(x0 - 0.02, SIZE.y * 0.5, z0 + 0.01), Vector3.ZERO, Vector3(0.0, deg_to_rad(-100.0), 0.0),
			"abrir o armário", "fechar o armário", false, false, false, main.mat_glass)
	door.can_toggle = _may_open
	door.toggled.connect(func(at_b: bool) -> void:
		if at_b:
			_opened = true
			main.catalog.set_flag(FLAG, true))
	_sync_prompt()

func on_night(night: Dictionary) -> void:
	_active = night.get("setpieces", []).has(data.id)
	if _active and not main.catalog.has(&"casinha"):
		_opened = false
		door.snap(false)
		main.catalog.set_flag(FLAG, false)
	else:
		_opened = true
		door.snap(true)
		main.catalog.set_flag(FLAG, true)
	if not main.night_flag_set.is_connected(_on_flag):
		main.night_flag_set.connect(_on_flag)
	_sync_prompt()

func _on_flag(id: StringName) -> void:
	if id == KEY:
		_sync_prompt()

func _unlocked() -> bool:
	return _opened or main.step_done(KEY)

func _may_open() -> bool:
	if _unlocked():
		return true
	main.sfx.play_at(&"click", door.global_position + Vector3(0.0, 0.0, 0.5), &"Casa", -14.0)
	return false

func _sync_prompt() -> void:
	if door != null:
		door.prompt_a = "destrancar o armário" if main.step_done(KEY) and not _opened else "abrir o armário"

func get_prompt() -> String:
	_sync_prompt()
	return door.get_prompt()

func interact() -> void:
	door.interact()
	_sync_prompt()
