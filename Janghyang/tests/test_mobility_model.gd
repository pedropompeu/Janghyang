extends RefCounted
const Mobility = preload("res://scripts/mobility_model.gd")

func test_sprint_until_winded(t) -> void:
	var m := Mobility.new()
	t.ok(m.update(0.1, true, true), "fresh: sprints")
	var secs := 0.0
	while m.update(0.1, true, true) and secs < 30.0:
		secs += 0.1
	t.ok(secs > 4.0 and secs < 8.0, "a few seconds of sprint (%.1f s)" % secs)
	t.ok(m.winded, "out of breath")

func test_winded_needs_rest(t) -> void:
	var m := Mobility.new()
	m.stamina = 0.0
	m.winded = true
	t.ok(not m.update(0.1, true, true), "winded: no sprint")
	for i in 30:
		m.update(0.1, false, false)
	t.ok(m.winded, "still winded after 3 s")
	for i in 100:
		m.update(0.1, false, false)
	t.ok(not m.winded, "rested")

func test_strain_follows_stamina(t) -> void:
	var m := Mobility.new()
	t.near(m.strain(), 0.0, 0.001, "rested: no strain")
	m.stamina = 0.2
	t.ok(m.strain() > 0.6, "low stamina: heavy breath")

func test_speed_and_fov(t) -> void:
	t.near(Mobility.speed_for(false, false, false), Mobility.WALK, 0.001, "walk")
	t.near(Mobility.speed_for(true, false, false), Mobility.SPRINT, 0.001, "sprint")
	t.near(Mobility.speed_for(true, true, false), Mobility.CROUCH, 0.001, "crouched never sprints")
	t.near(Mobility.speed_for(false, false, true), Mobility.PRETEND, 0.001, "eyes closed: slow")
	t.near(Mobility.fov_for(70.0, Mobility.WALK), 70.0, 0.001, "walking: base fov")
	t.ok(Mobility.fov_for(70.0, Mobility.SPRINT) > 74.0, "sprinting opens the fov")

func test_jump_height(t) -> void:
	var h := Mobility.JUMP_VELOCITY * Mobility.JUMP_VELOCITY / (2.0 * Mobility.GRAVITY)
	t.ok(h > 0.5 and h < 0.8, "a person's hop (%.2f m)" % h)
