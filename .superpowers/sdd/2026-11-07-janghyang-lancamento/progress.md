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
