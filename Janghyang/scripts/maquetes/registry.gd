extends RefCounted
## The maquetes on Inácio's bench, as data. Each one groups the areas built
## inside it (an area's DEF names its maquete back). `dome` places the glass
## dome on the bench: its origin is the centre of the dome's floor, its basis
## scales a unit box (x and z from -0.5 to 0.5, y from 0 to 1) to the dome.
##
## Listed by hand, like the areas: an exported build packs only what is
## preloaded or written here.

const MAQUETES := [
	{
		"id": &"item_214",
		"item": 214,
		"name": "a casa da rua do Porto",
		"areas": [&"casa", &"passagem", &"mecanismo", &"sotao", &"gaveta"],
		# The dome casa.gd builds: x -3.4..15.6, z -1.6..12.7, 13.2 high.
		"dome": Transform3D(Vector3(19.0, 0.0, 0.0), Vector3(0.0, 13.2, 0.0), Vector3(0.0, 0.0, 14.3), Vector3(6.1, 0.0, 5.55)),
	},
	{
		"id": &"item_215",
		"item": 215,
		"name": "Relojoaria Varela",
		"areas": [&"tampo"],
		# Over the shop and its back room (x 20..30, z -12..-2); no glass is built yet.
		"dome": Transform3D(Vector3(10.0, 0.0, 0.0), Vector3(0.0, 3.0, 0.0), Vector3(0.0, 0.0, 10.0), Vector3(25.0, 0.0, -7.0)),
	},
	{
		"id": &"item_216",
		"item": 216,
		"name": "a mansão das falésias",
		"areas": [],
		# At the far end of the bench; placed for real when the mansion is built.
		"dome": Transform3D(Vector3(8.0, 0.0, 0.0), Vector3(0.0, 6.0, 0.0), Vector3(0.0, 0.0, 8.0), Vector3(30.0, 0.0, -14.0)),
	},
]

static func get_maquete(id: StringName) -> Dictionary:
	for m in MAQUETES:
		if m.id == id:
			return m
	return {}

## The maquete that holds an area, or &"" when none does.
static func of_area(id: StringName) -> StringName:
	for m in MAQUETES:
		if m.areas.has(id):
			return m.id
	return &""
