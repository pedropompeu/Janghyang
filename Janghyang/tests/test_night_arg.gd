extends RefCounted
const Main = preload("res://scripts/main.gd")

func test_no_night_argument_is_zero(t) -> void:
	t.eq(Main.night_arg(PackedStringArray()), 0, "no --night")
	t.eq(Main.night_arg(PackedStringArray(["--selftest"])), 0, "other arguments")

func test_both_spellings_name_the_night(t) -> void:
	t.eq(Main.night_arg(PackedStringArray(["--night", "3"])), 3, "--night 3")
	t.eq(Main.night_arg(PackedStringArray(["--night=2"])), 2, "--night=2")

func test_night_is_clamped_and_must_be_a_number(t) -> void:
	t.eq(Main.night_arg(PackedStringArray(["--night", "9"])), 5, "past the campaign")
	t.eq(Main.night_arg(PackedStringArray(["--night", "0"])), 1, "before the campaign")
	t.eq(Main.night_arg(PackedStringArray(["--night", "x"])), 0, "not a number")
	t.eq(Main.night_arg(PackedStringArray(["--night"])), 0, "no value")
