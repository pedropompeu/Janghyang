extends RefCounted
## Night 1's bench (spec §6.2, §8.3, item 4): seven porcelain figures sit on
## it. Each time Elias leaves the figure room, one is armed to leave, at most
## MAX_AWAY in all and only while the night is searching (stage busca); the
## piece (setpieces/banco.gd) moves it when nobody sees the seat nor the place
## it goes to (may_land). Pure: the piece asks the world.

const N := 7
const MAX_AWAY := 3
## Never closer than this to Elias (staging_model.CLEAR).
const CLEAR := 0.6
## Never this close to the street door.
const DOOR_CLEAR := 2.5
## Which seat empties first, second, third: the far end, the near end, the middle.
const LEAVE_ORDER := [6, 0, 3]
const SEAT_FACE := Vector3(0.0, 0.0, 1.0)

## Per figure: {"at", "face", "pose", "seated"}.
var spots: Array = []
## Tasks 12 and 18 read and change it.
var stage: StringName = &"busca"

var _away: Array = []
var _left := 0
var _pending := -1

func _init(seats: Array, away: Array, face := SEAT_FACE) -> void:
	_away = away
	for s in seats:
		spots.append({"at": s, "face": s + face, "pose": &"sentado", "seated": true})

func seated() -> int:
	var n := 0
	for s in spots:
		if s.seated:
			n += 1
	return n

## Elias left the room: arm one departure, unless one is already waiting.
func on_leave_room() -> void:
	if stage != &"busca" or _pending >= 0 or _left >= mini(MAX_AWAY, _away.size()):
		return
	for i in LEAVE_ORDER:
		if i < spots.size() and spots[i].seated:
			_pending = i
			return

func pending() -> int:
	return _pending

## Where figure `i` goes when it leaves: the next of the away places.
func target_of(i: int) -> Dictionary:
	if i != _pending or _left >= _away.size():
		return {}
	return _away[_left]

func move(i: int) -> void:
	var to := target_of(i)
	if to.is_empty():
		return
	spots[i] = {"at": to.at, "face": to.face, "pose": to.pose, "seated": false}
	_left += 1
	_pending = -1

## Whether a figure may appear or vanish at `at`: never in sight, on top of
## Elias, inside a hiding place or by the street door. Flat distances.
static func may_land(at: Vector3, elias: Vector3, hideouts: Array, door: Vector3, seen: bool) -> bool:
	if seen:
		return false
	var p := Vector2(at.x, at.z)
	if p.distance_to(Vector2(elias.x, elias.z)) < CLEAR:
		return false
	if p.distance_to(Vector2(door.x, door.z)) < DOOR_CLEAR:
		return false
	for h in hideouts:
		var box: AABB = h
		if p.x >= box.position.x and p.x <= box.end.x and p.y >= box.position.z and p.y <= box.end.z:
			return false
	return true
