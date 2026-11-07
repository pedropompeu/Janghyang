extends RefCounted
const Quest = preload("res://scripts/quest_model.gd")

func test_starts_in_phase_one(t) -> void:
	var q := Quest.new()
	t.eq(q.phase, 0, "phase I")
	t.eq(q.pieces(), 0, "no piece yet")
	t.ok(q.current_tasks().size() >= 2, "a few tasks")

func test_tasks_strike_and_piece_ends_phase(t) -> void:
	var q := Quest.new()
	t.eq(q.complete(&"cat_relogio"), &"task", "a task is struck")
	t.eq(q.complete(&"cat_relogio"), &"", "only once")
	t.ok(q.is_done(&"cat_relogio"), "done")
	t.eq(q.complete(&"coroa"), &"phase", "the piece closes the phase")
	t.eq(q.phase, 1, "phase II")
	t.eq(q.pieces(), 1, "one piece")

func test_early_task_counts_later(t) -> void:
	var q := Quest.new()
	t.eq(q.complete(&"quebrar_redoma"), &"task", "done early")
	q.complete(&"coroa"); q.complete(&"ponteiros"); q.complete(&"mostrador")
	t.eq(q.phase, 3, "phase IV")
	var struck := false
	for task in q.current_tasks():
		if task.id == &"quebrar_redoma":
			struck = task.done
	t.ok(struck, "shows struck when its phase opens")

func test_all_pieces_open_the_hour(t) -> void:
	var q := Quest.new()
	for p in Quest.PIECES:
		q.complete(p)
	t.eq(q.pieces(), 4, "four pieces")
	t.ok(q.all_pieces(), "watch complete")
	t.eq(q.phase_id(), &"V", "phase V: 03:33")

func test_stalkers_per_phase(t) -> void:
	var q := Quest.new()
	t.eq(q.stalkers(), 0, "phase I: nobody")
	q.complete(&"coroa")
	t.eq(q.stalkers(), 1, "after the crown: the first one")
	for p in Quest.PIECES:
		q.complete(p)
	t.eq(q.stalkers(), 0, "03:33 belongs to the echoes")

func test_every_task_has_text(t) -> void:
	for ph in Quest.PHASES:
		t.ok(ph.title != "", "phase title")
		for id in ph.tasks:
			t.ok(Quest.TASKS.has(id), "text for %s" % id)
