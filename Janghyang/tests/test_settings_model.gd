extends RefCounted
const Settings = preload("res://scripts/settings_model.gd")

func test_defaults_match_the_game_as_it_was(t) -> void:
	var s := Settings.new()
	t.eq(s.get_value(&"sensitivity"), 0.0022, "mouse as before")
	t.eq(s.get_value(&"fov"), 70.0, "field of view as before")
	t.eq(s.get_value(&"brightness"), 1.0, "exposure as before")
	t.eq(s.get_value(&"invert_y"), false, "y not inverted")
	for k in [&"master", &"music", &"effects"]:
		t.eq(s.get_value(k), 1.0, "%s at full" % k)

func test_values_are_clamped_to_their_range(t) -> void:
	var s := Settings.new()
	s.set_value(&"fov", 300.0)
	t.eq(s.get_value(&"fov"), Settings.RANGES[&"fov"].y, "fov capped")
	s.set_value(&"music", -1.0)
	t.eq(s.get_value(&"music"), 0.0, "volume floor")
	s.set_value(&"invert_y", true)
	t.eq(s.get_value(&"invert_y"), true, "bool kept")

func test_unknown_keys_are_ignored(t) -> void:
	var s := Settings.new()
	s.set_value(&"nonsense", 3.0)
	t.ok(not s.values.has(&"nonsense"), "not stored")

func test_volume_in_decibels(t) -> void:
	t.eq(Settings.db(1.0), 0.0, "full is 0 dB")
	t.ok(Settings.db(0.5) < -5.0 and Settings.db(0.5) > -7.0, "half is about -6 dB")
	t.eq(Settings.db(0.0), Settings.SILENT_DB, "zero is silent")

func test_round_trip_through_a_config(t) -> void:
	var a := Settings.new()
	a.set_value(&"sensitivity", 0.004)
	a.set_value(&"invert_y", true)
	a.set_value(&"music", 0.25)
	var b := Settings.new()
	b.read(a.write())
	t.eq(b.get_value(&"sensitivity"), 0.004, "sensitivity back")
	t.eq(b.get_value(&"invert_y"), true, "invert back")
	t.eq(b.get_value(&"music"), 0.25, "music back")

func test_a_bad_file_falls_back_to_defaults(t) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("opcoes", "fov", "muito")
	cfg.set_value("opcoes", "master", 9.0)
	var s := Settings.new()
	s.read(cfg)
	t.eq(s.get_value(&"fov"), 70.0, "wrong type ignored")
	t.eq(s.get_value(&"master"), 1.0, "out of range clamped")
