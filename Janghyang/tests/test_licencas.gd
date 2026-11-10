extends RefCounted
## Spec §14.2: every file in assets/ has its line in assets/LICENCAS.md
## (arquivo | origem | autor | licença | data | edição), so nothing ships
## without a known origin and licence.

const ROOT := "res://assets"

func test_every_asset_has_a_licence_line(t) -> void:
	var text := FileAccess.get_file_as_string(ROOT + "/LICENCAS.md")
	t.ok(text != "", "assets/LICENCAS.md exists")
	var files := _files(ROOT, "")
	t.ok(not files.is_empty(), "assets/ has files to check")
	for f in files:
		t.ok(text.contains("| %s |" % f), "LICENCAS.md lists %s" % f)

## Paths under `dir`, relative to ROOT, without Godot's own sidecar files.
func _files(dir: String, rel: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".import") or f.ends_with(".uid") or f == "LICENCAS.md":
			continue
		out.append(rel + f)
	for sub in d.get_directories():
		out.append_array(_files(dir + "/" + sub, rel + sub + "/"))
	return out
