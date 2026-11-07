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
[2026-11-07] U15: start | baseline selftest 243/0 unit 1060/0 lint(1 pré-existente) | gate de saída: 5 vazamentos (A-007)
[2026-11-07] U15: Ruling: desligamento explícito e centralizado (`SfxBank.stop_all` + `main.shutdown`), não `_exit_tree` (já testado sem efeito) — custo se errado: uma função para reverter.
[2026-11-07] U15: Ruling: teste RED com sonda `Node` que conta `stop()` (GDScript não deixa sobrescrever `stop()` nativo; `playing` exige árvore de cena, indisponível no runner unit) — custo se errado: nenhum, o silêncio real é medido pelo gate headful.
[2026-11-07] U15: complete | gates: RED = `register_loop` inexistente; GREEN unit 1062/0 (+2 checks); selftest 243/0; headful `--shot-clock` com 0 vazamentos (linha de base 5), código 0; lint sem erro novo | commit: fix: stop looping audio before exit so no playback leaks (A-007)
[2026-11-07] Hashes finais das unidades (correção do registro "commit: pendente"): U10 1a730be, U11 7f8a234, U12 8968f2b, U13 1b4ef31, U14 abcc0f1, U16 75013c5, U15 (ver git log).
[2026-11-07] Nota de processo: o gate headful regenera `blockout-clock.png` (versionado); restaurado com `git checkout` para não entrar no commit.
[2026-11-07] U02: start | baseline selftest 243/0 unit 1062/0 lint(1 pré-existente)
[2026-11-07] U02: Ruling: templates 4.7.2.stable instalados em ~/.local/share/godot/export_templates/4.7.2.stable/ a partir do .tpz oficial, SHA512 conferido com SHA512-SUMS.txt da release — custo se errado: reinstalar; fora do repositório.
[2026-11-07] U02: complete | gates: diretório com windows_release_x86_64.exe e linux_release.x86_64 e version.txt (4.7.2.stable.official.ed1daf0bf); desbloqueia U60–U66 | commit: nenhum (ferramenta local)
[2026-11-07] U03: start | baseline selftest 243/0 unit 1062/0 lint(1 pré-existente)
[2026-11-07] U03: Ruling: buscas internas das lojas (WebFetch nas buscas da Steam; chrome-devtools nas do itch.io e GOG, que não renderizavam pelo WebFetch) em vez de WebSearch, que veio raso — custo se errado: nenhum, só mais uma verificação.
[2026-11-07] U03: complete | gates: tabela 3 lojas × 2 termos com resultado e URL em decisoes.md; nenhuma colisão direta; vizinho de tema registrado | commit: docs: record store name collision check for Janghyang
[2026-11-07] U04: start | baseline selftest 243/0 unit 1062/0 lint(1 pré-existente)
[2026-11-07] U04: Ruling: handles conferidos no navegador (código HTTP 200 dava falso positivo em todas as redes); WHOIS para .com/.io; .games inconclusivo. Ruling (d) pendente: colisão de handle é risco de marca, Pedro decide se aceita — custo se errado: renomear handle de rede.
[2026-11-07] U04: partial | gates: domínios e handles registrados com URL; INPI, USPTO, Facebook, TikTok e .games pendentes | commit: docs: record registry, domain and handle check for Janghyang (parcial)
[2026-11-07] DECISÕES (delegadas): Pedro pediu "resolva e escolha tu". Escolhas do modelo, registradas como (i) em context/decisoes.md (bloco de 2026-11-07): D1 Steam + itch.io; D2 congelar em 2026-11-21; D3 nome mantido, handles em U63; D4 pt-BR + inglês; D5 premium com demo; D6 opção (a); D8 default segue e revisão vai para 2026-11-21. D7 segue aberta (aprovação visual do Pedro). Pendentes (d): custo da taxa Steam, revisão de falante nativo, preço, aceite do risco de handle.
[2026-11-07] U20: start (registro tardio: a unidade começou antes deste ponto) | baseline unit 1062/0 selftest 243/0 lint(1 pré-existente)
[2026-11-07] U20: Ruling: teste em `tests/test_doll.gd` (novo), não em `test_catalog.gd` — o comportamento está em `doll.gd`; o catálogo só recebe o sinal — custo se errado: renomear o arquivo.
[2026-11-07] U20: Ruling: correção por `toggled.emit(false)` em `become_double` (sinal que o `main` já ouve para `doll_sat`), sem flag direta — custo se errado: uma linha a remover.
[2026-11-07] U20: complete | gates: RED unitário 1 falha (`becoming the double reports it seated`); RED selftest `the double counts ... (A-014) — false` (244 checks, 1 falha); GREEN unitário 1064/0; selftest 244/0; lint pendente antes do commit de docs | commit: 67ccc48 (código); docs f6bff72
[2026-11-07] U30: start | baseline unit 1064/0 selftest 244/0 lint nada a reportar
[2026-11-07] U30: Ruling: pino unitário em grade 3×3 (`every lurk point walks back to every goal`) e caso sem caminho (`cut-off point stays put`), em `test_stalker_model.gd`; o grafo real já é só a maior componente (`_largest_part`), então a conectividade do jogo vem por construção — custo se errado: nenhum.
[2026-11-07] U30: Ruling: check de conectividade por nível no selftest (`story`, BFS sobre `gastos.graph(lvl)`) — pina o invariante; não muda hoje. Mutação do grafo real não feita: o filtro é a fonte da garantia e o custo de mutar `_largest_part` não compensa agora.
[2026-11-07] U30: complete | gates: unit 1066/0 (+2); selftest 249/0 (+5, um por nível); mutante do `next_toward` na cópia (escolhe o 1º vizinho): FAIL `no lurk point is stuck on the grid (got 60, expected 0)`; lint nada a reportar | commit: e430d7b
[2026-11-07] U31: start | baseline unit 1066/0 selftest 249/0 lint nada a reportar
[2026-11-07] U31: Ruling: pino de pancadas extras em `test_breakable.gd` (passa de primeira: o guarda de `hit()` já existe); prova RED por mutante do guarda na cópia (4 FAIL) — custo se errado: nenhum.
[2026-11-07] U31: complete | gates: unit 1070/0 (+4); mutante `if false:` no guarda: 4 FAIL | commit: af3a440
[2026-11-07] U32: start | baseline unit 1070/0 selftest 249/0
[2026-11-07] U32: Ruling: dois testes em `test_visit_state.gd`: 3599 s sem portão e 3600 s com portão; peças abrem na hora — custo se errado: nenhum.
[2026-11-07] U32: complete | gates: unit 1075/0 (+5); mutante que ignora as peças em `_check_gate`: 3 FAIL | commit: 16e2ec2
[2026-11-07] U33: start | baseline selftest 249/0 unit 1075/0 lint nada a reportar
[2026-11-07] U33: Ruling: rota agachada numa checagem própria logo após a quebra da parede, não em `LOOP` — `LOOP` alimenta `_feed_loop` (gravação do eco); mudar a rota ali alteraria o eco sem relação com a passagem. Desvio do texto do plano, marcado (i) — custo se errado: mover duas linhas para `LOOP` e ajustar `_feed_loop`.
[2026-11-07] U33: complete | gates: RED mutante (`main.gd:635` com 999 pancadas) = FAIL `a crouched child walks from the playroom through the broken panel — blocked by HollowPanel`; GREEN selftest 251/0 (código 0, +2); unit 1075/0 (sem mudança); lint nada a reportar | commit: 1dc640e (código); docs no commit seguinte
[2026-11-07] U34: start | baseline selftest 251/0 unit 1075/0 lint nada a reportar
[2026-11-07] U34: Ruling: teclas por `Input.parse_input_event` (mesmo mecanismo do `tour.gd`), e não por mudança de API de movimento — custo se errado: nenhum, só teste. Subidas testadas com o player virado para a parede (rotação PI/2 na torre) para o movimento horizontal não sair do volume — custo se errado: ajuste de uma constante no teste.
[2026-11-07] U34: Ruling (i) parcial: o chão do sótão entre a escada da passagem e a torre NÃO é percorrido por segmento; a base da escada da torre é alcançada por teleporte. A porta da torre (`_hinge DoorTower`, start_at_b=false, rot_a=ZERO) começa fechada e exige interação ("abrir a porta da torre"), que o selftest ainda não faz. Lacuna registrada, não ocultada — custo se errado: um segmento a mais quando a porta entrar no teste.
[2026-11-07] U34: complete | gates: RED mutante (`ladder.gd` sem contar `ladders`) = 5 FAIL (shaft counts, W climbs shaft, top is attic, tower counts, W climbs tower); GREEN selftest 258/0 (código 0, +7 sobre 251); unit 1075/0 sem mudança; lint nada a reportar | commit: 26664c2 (código); docs no commit seguinte | pendente: segmento do chão do sótão e interação com a porta da torre
[2026-11-07] U35: start | baseline selftest 258/0 unit 1075/0 lint nada a reportar
[2026-11-07] U35: Ruling: quebra do alçapão por `hit()` ×3 direto no `Breakable` (sem o raycast do `_knock`, que exige mirar no chão) — o colisor é o mesmo; custo se errado: um teste a mais de mira. Descida com o player virado para a parede (rotação PI/2), mesma razão do U34.
[2026-11-07] U35: Ruling: check de caminhada até o alçapão aberto REMOVIDO depois de passar no mutante — o segmento à altura do corpo em pé não toca o colisor do chão (0 a −0.12 m); check sem poder de discriminar não entra no selftest — custo se errado: nenhum, a descida já prova o colisor.
[2026-11-07] U35: complete | gates: RED mutante (`main.gd:618` com 999 pancadas) = 3 FAIL (quebra, descida até y −3.0, sala gaveta); GREEN selftest 263/0 (código 0, +5 sobre 258); unit 1075/0 sem mudança; lint nada a reportar | commit: a881d0e (código); docs no commit seguinte
[2026-11-07] U36: start | baseline selftest 263/0 unit 1075/0 lint nada a reportar
[2026-11-07] U36: Ruling (i): rota contorna a ponta oeste da haste de aço (x 23.4) e entra na loja pela porta em x 25.2; os bloqueios da primeira versão (caixa de parafusos e parede oeste da loja) são geometria de jogo, não defeito — custo se errado: nenhum, só teste.
[2026-11-07] U36: complete | gates: RED mutante (main.gd:1020 com 999 pancadas) = 2 FAIL (três pancadas quebram o vidro; a borda do tampo bloqueia em (15.15, 0.85, 10.4) pelo CrackedGlass); GREEN selftest 273/0 (código 0, +10 sobre 263); unit 1075/0 sem mudança; lint nada a reportar | commit: 34f54de (código); docs no commit seguinte
