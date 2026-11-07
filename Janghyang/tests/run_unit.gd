extends SceneTree
## Unit harness for the pure models. Run with:
##   godot --headless --path . -s res://tests/run_unit.gd
## Loads every res://tests/test_*.gd and calls each test_* method with this
## runner as the only argument.

var checks := 0
var failures := 0
var _errors := _ErrorCounter.new()

## A script error aborts the test method silently; count it as a failure.
class _ErrorCounter extends Logger:
	var count := 0
	func _log_error(_function: String, _file: String, _line: int, _code: String, _rationale: String,
			_editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		count += 1

func _init() -> void:
	OS.add_logger(_errors)
	var dir := DirAccess.open("res://tests")
	var files: Array[String] = []
	if dir != null:
		for f in dir.get_files():
			if f.begins_with("test_") and f.ends_with(".gd"):
				files.append(f)
	files.sort()
	for f in files:
		var path := "res://tests/" + f
		var script = load(path)
		if script == null or not script.can_instantiate():
			_fail("could not load %s" % path)
			continue
		var suite = script.new()
		for m in script.get_script_method_list():
			var method: String = m["name"]
			if method.begins_with("test_"):
				print("UNIT: %s::%s" % [f, method])
				var errors_before := _errors.count
				suite.call(method, self)
				if _errors.count > errors_before:
					_fail("%s::%s raised a script error" % [f, method])
	print("UNIT RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func ok(cond: bool, label: String) -> void:
	checks += 1
	if not cond:
		_fail(label)

func eq(actual, expected, label: String) -> void:
	checks += 1
	if actual != expected:
		_fail("%s (got %s, expected %s)" % [label, str(actual), str(expected)])

func near(actual: float, expected: float, eps: float, label: String) -> void:
	checks += 1
	if absf(actual - expected) > eps:
		_fail("%s (got %f, expected %f)" % [label, actual, expected])

func _fail(label: String) -> void:
	failures += 1
	print("UNIT FAIL ", label)
