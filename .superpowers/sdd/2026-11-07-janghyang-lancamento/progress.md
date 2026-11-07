# SDD ledger — plan: /home/usuario/Dev/Jogo/docs/superpowers/plans/2026-11-07-janghyang-lancamento.md
Setup: Ruling: ledger versionado no git (mesmo padrão do ledger de 2026-10-27, que já está no repositório); decide-se por commit local do ledger junto com cada unidade — custo se errado: histórico com um arquivo a mais, reversível.
Setup: Ruling: commits locais, sem `Co-Authored-By` (regra do CLAUDE.md global do Pedro, que prevalece sobre o aviso do ambiente); sem push até pedido explícito — custo se errado: nenhum.
[2026-11-07] Baseline: selftest 241 checks, 0 failures (43 s) | unit 1059 checks, 0 failures (3 s) | lint: 1 pendência pré-existente (context/discussoes/modelo-arquitetural-dinamico-3d.md:588)
[2026-11-07] U00: start | baseline selftest 241/0 unit 1059/0 lint(1 pré-existente)
[2026-11-07] U00: Ruling: .superpowers/ não está ignorado no git e já contém ledgers versionados — mantido versionado — custo se errado: arquivos de estado no histórico.
[2026-11-07] U00: complete | gates: linha de base medida, ledger criado | commit: (ver git log, unidade docs) | evidência: git check-ignore sem saída (não ignorado)
[2026-11-07] Export templates: ausentes em ~/.local/share/godot/export_templates/ — bloqueia U60–U66 até U02 (pendente de ação do ambiente)
[2026-11-07] U10: start | baseline selftest 241/0 unit 1059/0 lint(1 pré-existente)
[2026-11-07] U10: Ruling: guarda de 120 s (45 s medidos + margem) com quit(1); o RED usa erro injetado `_nothing.size()` em cópia descartável — custo se errado: limite ajustável em uma constante.
[2026-11-07] U10: complete | gates: selftest 241/0 (43 s, código 0); mutante exit=1 com "SELFTEST GUARD: no result after 120 s" (antes: exit 124 em 60 s); unit 1059/0; lint sem erro novo | commit: pendente (ver git log) | evidência: rtk proxy timeout 60 godot ... --selftest (RED: exit 124)
[2026-11-07] U11: start | baseline selftest 241/0 unit 1059/0 lint(1 pré-existente)
[2026-11-07] U11: Ruling: sonda movida de z 8,88 para z 8,6 (cápsula de raio 0,28 não alcança a fachada em z≈9,03 e encosta no relógio, z 8,74–9,02) — custo se errado: ajuste de uma constante.
[2026-11-07] U11: complete | gates: RED mutante (sem colisão do relógio) com sonda antiga = PASS; GREEN mutante com sonda nova = FAIL; selftest real 241/0 (código 0); unit 1059/0; lint sem erro novo | commit: pendente | evidência: scratchpad a005/m1 e a005/m2
[2026-11-07] U12: start | baseline selftest 241/0 unit 1059/0 lint(1 pré-existente)
[2026-11-07] U12: Ruling: gate de `--tour` substituído por injeção de `R` num selftest de cópia (o tour pode não apertar R; a injeção prova o ramo) — custo se errado: log não aparece num tour real, só se confirma com o teclado; a investigação de A-017 segue aberta.
[2026-11-07] U12: complete | gates: log `[reload] R via ...` confirmado em cópia; selftest 241/0; unit 1059/0; lint sem erro novo | commit: pendente | evidência: scratchpad a017/out.txt
[2026-11-07] U13: start | baseline selftest 241/0 unit 1059/0 lint(1 pré-existente)
[2026-11-07] U13: Ruling: API nova `Echo.load_window(recorder, seg)` + `sample_at(t)` de instância (no lugar de `static sample_at(recorder, seg, t)`); `index` relativo à janela — custo se errado: chamadores de teste atualizados (test_echo.gd), hour_event.gd inalterado.
[2026-11-07] U13: complete | gates: RED com API antiga = `got 15.200000, expected 5.200000`; GREEN: unit 1060/0 (+1), selftest 241/0; lint sem erro novo | commit: pendente | evidência: /tmp/claude-1001/unit-u13.txt
[2026-11-07] U14: start | baseline selftest 241/0 unit 1059/0 lint(1 pré-existente)
[2026-11-07] U14: Ruling: a entrada do caderno é sempre escrita; o lápis só toca com `doll.is_double()`; flush de `end()` segue a mesma regra (escreve sem som se o duplo não sentou) — custo se errado: uma linha para voltar ao comportamento anterior.
[2026-11-07] U14: Ruling: contador `SfxBank.pencil_count` (só leitura para o selftest) em vez de espiar o áudio — custo se errado: nenhum no jogo.
[2026-11-07] U14: complete | gates: RED selftest `FAIL the pencil stays quiet ... — 1` (243 checks, 1 failure); GREEN selftest 243/0; unit 1060/0; lint sem erro novo | baseline nova: selftest 243/0, unit 1060/0 | commit: pendente | evidência: /tmp/claude-1001/self-u14-red.txt e self-u14.txt
[2026-11-07] U16: start | baseline selftest 243/0 unit 1060/0 lint(1 pré-existente)
[2026-11-07] U16: Ruling: a parte de código (gate de 3600 s e peças) já é coberta por test_visit_state.gd (test_pieces_gate, test_catalog_alone_no_longer_opens_the_gate, test_time_limit_is_an_hour); não se duplica teste — custo se errado: nenhum (o achado é de documentação).
[2026-11-07] U16: complete | gates: unit 1060/0 (sem mudança de código); lint sem erro novo; decisoes.md:70 com ~superseded; A-019 registrado e corrigido | commit: pendente
