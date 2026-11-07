# SDD ledger — plan: /home/usuario/Dev/Jogo/docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md
Setup: Ruling: sem git (diretório não é repo; plano já prevê checkpoints em vez de commits) — backup em scratchpad/sdd/backup-faz-de-conta-pre-plano; scripts task-start/task-done (dependem de git) substituídos por ledger manual — custo se errado: sem histórico por tarefa, só o backup inicial.
Pre-flight: interfaces verificadas por brief a cada tarefa (Ruling: varredura completa não feita antes — plano de 1335 linhas; custo se errado: conflito descoberto mais tarde)
Task 1: Ruling: selftest com script error trava em vez de sair — passei a rodar com timeout 150 — custo: nenhum
Task 1: complete (checkpoint sem git; tests: godot --headless --path . -- --selftest → 60 checks, 0 failures; lint ok)
Task 2: Ruling: giant pencil box (0.25x0.25x4.0 at z 11.6) would cross the south glass wall along z — rotated 90° about y so it lies along x inside the tampo — cost if wrong: one rotation.
Task 2: Ruling: atelier rain window (south) and west-strip window removed; the giant 12x rain window on the oficina back wall replaces them, as glass walls cannot hold frames — cost if wrong: re-add two small windows.
Task 2: Ruling: ExitEdge collision_layer = 0 so it never blocks rays or shape queries — cost if wrong: none expected.
Task 2: complete (no git; tests: timeout 110 godot --headless --path . -- --selftest → 64 checks, 0 failures; lint ok; shot-atelier visually checked)
Task 3: Ruling: "entry clock is solid" passed before the clock existed (probe reaches the facade) — kept as plan wrote it, logged as achados A-005 — cost if wrong: clock collision regression goes unnoticed.
Task 3: complete (no git; tests: unit → 414 checks, 0 failures; selftest → 66 checks, 0 failures; lint ok)
Pause: 2026-10-27 Pedro asked to stop after Task 3 and document; resume at Task 4 tomorrow.
Resume: 2026-10-28 new session resumed at Task 4 (goal: finish 4–15 + final review). Backup pre-task4 in session scratchpad.
Task 4: Ruling: plan gives target positions but not sizes — sizes chosen to wrap each piece (e.g. clock 0.55×1.6×0.4, figures 0.45×1.3×0.45) — cost if wrong: Q harder/easier to aim, tune numbers.
Task 4: Ruling: prompt label raised (offset_top −96) so the second line "[Q] catalogar" fits — cost: none.
Task 4: Ruling: extra selftest check "looking at the entry clock offers it to Q" and shot mode --shot-clock added (written after impl, passed first run; not watched failing) — cost if wrong: check may be weaker than it looks.
Task 4: complete (no git; tests: unit → 462 checks, 0 failures; selftest → 82 checks, 0 failures; lint ok; blockout-clock.png visually checked: dial readable, hour on 3, minute on 12, pendulum visible)
Task 5: Ruling: player emits `notebook_requested` on Tab and main connects it to notebook.toggle (plan says "Tab chama toggle()" without naming the path) — cost: none.
Task 5: Ruling: notebook entries live in a ScrollContainer (scrolled to the end on open) so long visits never overflow the page — cost if wrong: player scrolls with the wheel.
Task 5: Ruling: font list starts with Liberation Serif/FreeSerif (DejaVu has no italic installed here) — cost: none.
Task 5: Ruling: show_final(text) implemented now as a black screen with one paper page (used by Task 14) — cost if wrong: restyle in Task 14.
Task 5: complete (no git; tests: unit → 462 checks, 0 failures; selftest → 87 checks, 0 failures; lint ok; --shot-notebook checked: entries left, glued pages right, blank numbered lines, no total)
Task 6: Ruling: bedroom test lives in main as `in_bedroom(pos)` with BEDROOM_X/BEDROOM_Z constants (x 10.5..15.4, z 0..5.6 from the brief) — cost if wrong: retune two constants.
Task 6: Ruling: gate also re-checked in on_cataloged (not only in update) so the hurry clamp lands the moment the 5th piece is catalogued — cost: none, test_catalog_gate covers it.
Task 6: complete (no git; tests: unit → 483 checks, 0 failures; selftest → 88 checks, 0 failures; lint ok)
Task 7: Ruling: sfx_bank has `silent` (true when DisplayServer is headless) so tests play nothing — headless audio left 7 leaked playbacks at quit — cost if wrong: none for players; tests never exercise playback.
Task 7: Ruling: footfalls come from a new `player.stepped` signal (bob crossing each PI), played by main on Casa at -8 dB; folds hook every main child with a `toggled` signal (doors, F1–F4, doll) — cost: doll sitting up also creaks.
Task 7: Ruling: rain loops placed at the bedroom window and toward the giant workshop window; breath is a non-positional AudioStreamPlayer at -24 dB; `hum` is synthesised but not yet placed (no layer in the brief uses it) — cost if wrong: add one player.
Task 7: Ruling: Step 6 listening check not possible here (no ears); headful run of --shot-clock had no audio errors. Exit leak with a real driver logged as A-007 — cost: Pedro must listen to the tick.
Task 7: complete (no git; tests: unit → 520 checks, 0 failures; selftest → 89 checks, 0 failures; lint ok)
Task 8: Ruling: run_unit.gd now counts script errors raised during a test method as failures (OS.add_logger) — the first GREEN of this task was false: echo_recorder.gd did not compile and the harness said 0 failures (A-008). Probe test RED→GREEN, then removed — cost: none.
Task 8: Ruling: stats() returns whole-visit totals (running counters), not only retained samples; select_segments scores only retained samples — cost if wrong: stats for >30 min visits differ.
Task 8: Ruling: verb map is `player.verb_for(collider)` (static): names Ball/Doll/MusicBox/Figure/EntryClock, else a foldable (has rotation_a) → abrir if name starts with Door, else dobrar; catalogar marked by main on a successful catalog. Added selftest check "gestures have the house's verbs" (written after the code) — cost: none.
Task 8: complete (no git; tests: unit → 539 checks, 0 failures; selftest → 90 checks, 0 failures; lint ok)
Task 9: Ruling: mirror SubViewport is 320×512 (glass aspect 1.0×1.6), not 512×512 — a square target stretched the image — cost: none.
Task 9: Ruling: reflection uses a frustum camera at the eye mirrored on x = 15.285 (front face of the glass), near plane on the glass, u flipped on the quad; glass quad on layer 12 hidden from the mirror camera — cost if wrong: visual only.
Task 9: Ruling: knock answers come from a fixed list of 9 interior wall points (≥3 m filter, random pick); player's own knock sound is played by main from the acted(&"bater") handler — cost: list must follow wall edits.
Task 9: Ruling: doll pose variants are 3 rotation offsets added to the lying/sitting base; the house applies one only after 5 s unseen (main.is_seen on the doll's chest), expiring at 30 s — cost: none.
Task 9: Ruling: selftest now fails on any script error logged during its run (Logger), same hole as A-008 — a broken mannequin.gd had produced "95 checks, 0 failures"; cp.sh also flags SCRIPT ERROR lines — cost: none.
Task 9: Ruling: Step 6 hands-on checks (hear 3 knocks, see F4 fold) not playable here; covered by selftest (fold from far / never within 3 m / never F1-F3) and --shot-mirror (Elias in the mirror) — cost: Pedro should knock 3× once.
Task 9: complete (no git; tests: unit → 551 checks, 0 failures; selftest → 96 checks, 0 failures; lint ok; blockout-mirror.png checked)
Task 10: Ruling: test_echo._line fed 600 frames at 60 Hz (10 s = 100 samples) but test_never_leaves_recorded_path reads sample 159 — feed 1200 frames (20 s) — the brief's own segment needs 160 samples; cost if wrong: none, test data only.
Task 10: Ruling: brief says main stores the ball position every second; the ball keeps its own 1 s trail and roll_back() takes no args — matches the Produces signature, keeps main thinner — cost if wrong: move 8 lines to main.
Task 10: Ruling: F9 via clock.force_stop() would never be seen (tick() returns false on an already-stopped clock, so visit never enters HORA) — F9 sets can_stop=true and spring=0 so the next tick stops the clock and visit emits hora_started through the normal path — cost if wrong: debug key only.
Task 10: Ruling: added --shot-hour capture (walk + pause, begin+end) to look at the frozen echoes; the brief's manual check (recognise your own paths in play) stays for Pedro — cost if wrong: none.
Task 10: complete (no git; tests: cp.sh → unit 653/0, selftest 122/0, lint ok; blockout-hour.png checked)
Task 11: Ruling: three crack things could all pick the same farthest corner — each thing's seen-callable also treats a corner held by another visible thing as taken; pick() itself is unchanged — cost if wrong: things may cluster less than intended.
Task 11: Ruling: added "three things come out of the cracks" check so "crack things have no collision" cannot pass on an empty list — cost if wrong: none.
Task 11: complete (no git; tests: cp.sh → unit 659/0, selftest 124/0, lint ok)
Task 12: Ruling: the brief's selftest line `var duplo := main.catalog.entries.filter(...)` does not compile (untyped main) — typed it `var duplo: Array` — cost if wrong: none.
Task 12: Ruling: after become_double the doll ignores E (no prompt) and the house mirror's pose variants, so nothing teleports it back to the bed or moves it in view — cost if wrong: the player cannot touch the double.
Task 12: Ruling: entries at 6/12/18 s are independent of whether the doll already moved; the doll's move keeps waiting after end() until doll and bench are both out of view — cost if wrong: the pencil may be heard before the double is seated.
Task 12: Ruling: added --shot-double capture — cost if wrong: none.
Task 12: complete (no git; tests: cp.sh → unit 666/0, selftest 127/0, lint ok; blockout-double.png checked)
Task 13: Ruling: the Mannequin API had no way to raise the hand to the dome — added set_lean(angle) and reach(side, target) (look_at + quarter turn) — cost if wrong: two small methods to fold back.
Task 13: Ruling: GIANT_HAND = (2.2, 3.65, 11.8): dome top near its south edge over the entry; torso leaned 22° so a 12x arm actually reaches it from (2,-10,20) — cost if wrong: art pass moves the hand.
Task 13: Ruling: giant shown on hour_event.ended (not only hora_ended) so the direct end() path also reveals him; flag + page are set inside end() as the brief says — cost if wrong: none.
Task 13: Ruling: the giant reads poorly in the dark blockout (seen from the front door: head, torso, arm across); pose verified with a temporary side-lit capture, then reverted. Readability is an art/lighting call for Pedro — cost if wrong: the reveal may land weaker than intended until lit.
Task 13: complete (no git; tests: cp.sh → unit 666/0, selftest 133/0, lint ok; blockout-giant.png)
Task 14: Ruling: notebook_ui.show_final already existed (Task 5) but called close(), which released player.input_locked and recaptured the mouse — show_final now hides the book without unlocking, and open() is ignored once the final page is up; covered by selftest "the player stays still after the last entry" / "the notebook does not reopen over the last entry" (RED→GREEN) — cost if wrong: Tab is dead after the ending
Task 14: Ruling: ESC and R were behind the input_locked guard, so "ESC solta o mouse e R recarrega, como hoje" failed after finish() — moved both above the guard in player.gd (also works while the notebook is open) — cost if wrong: R reloads with the notebook open
Task 14: Ruling: main ignores exit_edge_reached when visit.on_exit() returns &"" (second crossing), and sets ended/ending_outcome before ending.finish — cost if wrong: none
Task 14: complete (no git; tests: cp.sh → unit 675/0, selftest 139/0, lint ok)
Task 15: Ruling: final_camera transform is set in ending._ready via Transform3D.looking_at (camera added to main deferred) instead of look_at at finish time — look_at fails while the camera is outside the tree (seen in the new --shot-ending capture) — cost if wrong: none, same pose
Task 15: Ruling: NewFigure uses a new mannequin pose &"no_chao" (hip 0.1 m, legs 86°) instead of &"sentado" — brief says "sentada no chão da entrada" and its head check at +0.9 matches a floor-sitting body; &"sentado" is a chair pose and left the legs 0.45 m in the air (seen in blockout-ending.png) — cost if wrong: one-word revert
Task 15: Ruling: the "frozen" (parar) mode also kills the double's pencil tween (doll.stop_writing) so the bench double is still, per the brief's table — cost if wrong: none
Task 15: Ruling: NewFigure is created behind the black (in finish's fade callback), not at the instant finish() is called — it is still part of finish() in every outcome and the player never sees it pop — cost if wrong: none
Task 15: Ruling: added a --shot-ending capture mode (not in the plan) to verify the final image — cost if wrong: dead debug code
Task 15: Ruling: context facts dated [2026-10-28] (the day they were made and verified), not [2026-10-27] as the brief wrote — the date rule is about when the fact holds — cost if wrong: one date per line
Task 15: complete (no git; tests: cp.sh → unit 675/0, selftest 146/0, lint ok)
Final review: opus reviewer (fresh context) on review-package.diff (backup→current, no git) — verdict "With fixes": 0 Critical, 2 Important, 6 Minor
Final: Ruling: re-graded Minor 2 (clock stops after exit in corda/incompleto) to Important — the Task 15 table promises "o tique segue"; the corda ending lost its tick — cost if wrong: one extra fix
Final: Ruling: re-graded Minor 4 (English help line, no B) to Important — player-facing pt-BR is a hard constraint and the help label is visible on every run — cost if wrong: one extra fix
Final: fixed exit during an active 03:33 left the hour running (A-009) — selftest "leaving during 03:33 ends the hour behind the black" / "crack things stop when Elias leaves" / "the double stops writing once Elias has left" / "leaving during 03:33 leaves the echoes frozen where they stand" RED→GREEN, suite unit 676/0 selftest 151/0
Final: fixed double kept collision (A-010) — selftest "the double has no collision" RED→GREEN, suite 676/0 + 151/0
Final: fixed clock stopped after exit in corda/incompleto (A-011) — unit test_clock_keeps_running_after_exit RED→GREEN, suite 676/0 + 151/0
Final: fixed English help line and missing B (A-012) — selftest "help text is pt-BR and lists every verb" RED→GREEN, suite 676/0 + 151/0
Final: Ruling: the exit selftest now re-runs hour_event.begin() before leaving to exercise Review Focus 1 (exit during an active hour); the post-end() exit path is no longer the one tested — cost if wrong: a regression only in the after-hour exit would go unseen (its logic is the same finish() path)
Final: Ruling: reviewer disagreed with Task 3 keeping "entry clock is solid" (A-005) — stands as an open achado; rewriting the probe was not in the fix pass — cost if wrong: a check that cannot fail stays green
Final: Ruling: declined "audio by ear", "visual quality/final framing", "feel/tuning" — stand for Pedro's playtest; the peak clamp and the final-camera ray/frustum are machine-checked, the rest needs a human — cost if wrong: tuning found late
Final: Ruling: declined "code only skimmed (mirror_brain, house_mirror, mirror_reflection, mannequin, music_box, figure)" — stands on their unit/selftest coverage — cost if wrong: an unreviewed bug in the mirror
Final: minor (deferred): echoes replay a drifted window in very long sessions (A-013)
Final: minor (deferred): boneco cannot be catalogued if never sat before 03:33 (A-014)
Final: minor (deferred): pencil heard at an empty bench during 03:33 (A-015)
Final: minor (deferred): crack-thing visibility tested from a single point
Final: minor (deferred): F9 also stops the clock in DEPOIS/ESCOLHA (debug only)
