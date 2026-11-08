extends RefCounted
## The fog over one sheet of the plan (spec §8): the floor of a level cut in
## CELL-metre squares, one bit each, set when Elias has seen it. Points are
## on the floor (x, z); anything outside the rect is ignored.

const CELL := 0.5

var rect: Rect2
var cols := 0
var rows := 0
var _bits := PackedByteArray()
var _count := 0

func _init(r: Rect2) -> void:
	rect = r
	cols = maxi(ceili(r.size.x / CELL), 1)
	rows = maxi(ceili(r.size.y / CELL), 1)
	_bits.resize(ceili(cols * rows / 8.0))

## Marks the cell under `p`. True only when it was still in the fog.
func reveal(p: Vector2) -> bool:
	var i := _index(p)
	if i < 0 or _has(i):
		return false
	_bits[i >> 3] |= 1 << (i & 7)
	_count += 1
	return true

func seen(p: Vector2) -> bool:
	var i := _index(p)
	return i >= 0 and _has(i)

func count() -> int:
	return _count

## The cell's centre on the floor, for drawing.
func cell_center(col: int, row: int) -> Vector2:
	return rect.position + Vector2(col + 0.5, row + 0.5) * CELL

func seen_cell(col: int, row: int) -> bool:
	return col >= 0 and row >= 0 and col < cols and row < rows and _has(row * cols + col)

func to_bytes() -> PackedByteArray:
	return _bits.duplicate()

## Takes a saved grid of the same size; anything else is refused and the
## grid stays as it was.
func from_bytes(b: PackedByteArray) -> bool:
	if b.size() != _bits.size():
		return false
	_bits = b.duplicate()
	_count = 0
	for i in cols * rows:
		if _has(i):
			_count += 1
	return true

func _has(i: int) -> bool:
	return (_bits[i >> 3] >> (i & 7)) & 1 == 1

func _index(p: Vector2) -> int:
	if p.x < rect.position.x or p.y < rect.position.y or p.x >= rect.end.x or p.y >= rect.end.y:
		return -1
	var c := mini(int((p.x - rect.position.x) / CELL), cols - 1)
	var r := mini(int((p.y - rect.position.y) / CELL), rows - 1)
	return r * cols + c
