# Janghyang — Plano de Lançamento até 2027-04-15 (execução sequencial)

> **For agentic workers:** execução **nativa** (superpowers:executing-plans), uma unidade por vez, na ordem deste arquivo. Não começar a unidade N+1 antes de a unidade N estar `complete` no ledger. Passos com `- [ ]` servem de acompanhamento.

**Goal:** levar o protótipo Janghyang (antigo FAZ DE CONTA) a um jogo publicado em PC (Windows e Linux) em 2027-04-15, com os três finais validados por jogadores de fora da equipe.

**Architecture:** Godot 4.7.2, renderer GL Compatibility, conteúdo gerado em código, sem assets nem dependências externas. Nenhuma mecânica nova entra no escopo: o trabalho é corrigir, testar, validar com jogadores, polir e publicar.

**Tech Stack:** GDScript; selftest headless (`--selftest`); suíte unitária (`tests/run_unit.gd`); `lint.py`; Git (`origin` = `github.com/pedropompeu/Janghyang`); OpenCode (`mcp__opencode__ask_opencode`, somente leitura) para segunda opinião.

**Specs:** `docs/superpowers/specs/2026-10-28-faz-de-conta-expansao-design.md` (expansão, fases, Gastos, ambientes) e `docs/superpowers/specs/2026-10-27-faz-de-conta-relojoeiro-design.md` (história, 03:33, finais).

**Ledger:** `.superpowers/sdd/2026-11-07-janghyang-lancamento/progress.md` (criado pela U00).

---

## 1. Como rodar este plano aos poucos

### 1.1 Regras de sequência

1. **Uma unidade por vez.** Cada unidade (`Uxx`) cabe em uma sessão: um arquivo de lógica, no máximo dois arquivos de teste, um commit.
2. **Pré-voo antes de cada unidade:** rodar a linha de base (seção 1.3). Se a linha de base não bater com a última linha `complete` do ledger, parar e registrar em `achados.md` antes de continuar.
3. **Ordem fixa.** A coluna "depende de" é a única fonte de ordem. Unidades bloqueadas por decisão do Pedro (marcadas `(d)`) ficam pendentes, e a fila segue pelas unidades livres.
4. **Retomada:** ler a última linha do ledger, rodar a linha de base, ler os arquivos listados na unidade, continuar pelo primeiro passo sem `[x]`.
5. **Falha:** duas tentativas falhas na mesma unidade = parar, registrar em `achados.md` com severidade, reprodução e o que foi descartado. Não remendar com teste frouxo.
6. **Sem paralelismo.** Mesmo quando duas unidades não se tocam, são feitas em série. Assim cada commit tem um único estado de partida verificado.

### 1.2 Formato do ledger

Uma linha por evento, em `progress.md`:

```
[YYYY-MM-DD] Uxx: start | baseline selftest N/0 unit M/0 lint(k pré-existente)
[YYYY-MM-DD] Uxx: Ruling: <decisão tomada e custo se errada>
[YYYY-MM-DD] Uxx: complete | gates: <números> | commit <hash> | evidência: <comando e saída>
```

Decisões técnicas entram como `Ruling:` e depois em `context/decisoes.md` com `(i)`. Decisões que mudam regra de jogo ou arquitetura não são `Ruling:`: ficam pendentes para o Pedro (`(d)`).

### 1.3 Linha de base medida (2026-11-07)

| Gate | Comando | Resultado medido |
|------|---------|------------------|
| Selftest | `timeout 150 godot --headless --path Janghyang -- --selftest` | `SELFTEST RESULT: 241 checks, 0 failures` (43 s) |
| Unidade | `timeout 60 godot --headless --path Janghyang -s res://tests/run_unit.gd` | `UNIT RESULT: 1059 checks, 0 failures` (3 s) |
| Lint | `python3 lint.py` | 1 pendência pré-existente: `context/discussoes/modelo-arquitetural-dinamico-3d.md:588` (fato pede revisão desde 2026-11-03). Não é introduzida por este plano. |
| Display | `echo $DISPLAY` | `:0` disponível (X0 presente): testes em janela real são possíveis |
| Export templates | `ls ~/.local/share/godot/export_templates/` | **vazio**: bloqueia M4 até U02 |

**Critério de qualquer unidade:** selftest ≥ baseline com 0 falhas, unidade ≥ baseline com 0 falhas, lint sem erro novo, e o gate específico da unidade.

### 1.4 Uso do OpenCode

- Usar `consult` (somente leitura) para perguntas de unidade: confirmar chamadores, comparar opções, checar um caminho no código.
- A resposta é dado de apoio, não verdade: cada afirmação relevante é checada por leitura direta antes de virar `Ruling:`.
- Registrar o `session_id` no ledger quando a resposta mudar uma decisão.

---

## 2. Decisões que dependem do Pedro (`(d)`)

Estas decisões bloqueiam unidades. Cada uma tem recomendação, para o Pedro só aprovar ou trocar.

| ID | Decisão | Recomendação | Bloqueia |
|----|---------|--------------|----------|
| D1 | Plataforma: PC (Windows e Linux) via Steam e/ou itch.io | Steam + itch.io, lançamento simultâneo | U60–U66 |
| D2 | Escopo congelado: nenhuma mecânica, área ou Gasto novo até o lançamento | Congelar em 2026-11-21 (fim da U38) | toda a fase 3 em diante |
| D3 | Nome Janghyang (já `(d)`): falta checagem de colisão | Prosseguir se U03/U04 não acharem colisão | U04, U63 |
| D4 | Idiomas: pt-BR apenas, ou pt-BR + inglês | pt-BR + inglês (ampliar alcance) | U62 |
| D5 | Modelo: preço, premium ou gratuito, demo | Premium com demo; preço a definir após playtest | U63 |
| D6 | A-014: o duplo conta como sentado para o catálogo, ou `Q` vale direto no duplo | **(a)**: o duplo conta como sentado. O OpenCode confirmou que tem menos efeitos colaterais: `doll_sat` só é lido por `catalog.gd:17-21`. | U20 |
| D7 | Aprovação visual das capturas de luz (U40, U41) | Pedro aprova a imagem | U40, U41 |
| D8 | Revisão do fato de 2026-11-03 (lint) | Pedro revisa `modelo-arquitetural-dinamico-3d.md:588` | U01 |

---

## 3. Matriz de dependências e marcos

| Fase | Unidades | Marco | Depende de |
|------|----------|-------|------------|
| 0 Preparação | U00–U03 | M0 (até 11-20) | — |
| 1 Harness e correções técnicas | U10–U16 | M2 (início) | U00 |
| 2 Decisão + correção de catálogo | U20 | M2 | D6 |
| 3 Rotas e regressão | U30–U38 | M2 (até 01-15) | U10, U11 |
| 4 Clima e interface | U40–U43 | M3 (até 02-12) | U38, D7 |
| 5 Playtests | U50–U52 | M1 (até 12-11), repetido em M3 | U00, D1 |
| 6 Release | U60–U66 | M4–M6 | U02, D1, D4, D5 |

> Observação: M1 (playtest) foi colocado depois da fase 3 na execução real, porque o playtest precisa do jogo com as rotas e as correções prontas. O roteiro (U50) pode ser escrito em paralelo, em texto, sem alterar o jogo.

---

## 4. Unidades

Cada unidade tem: **Arquivos**, **Passos** (teste primeiro, depois implementação), **Gate** (comando e saída esperada) e **Commit**.

---

### Fase 0 — Preparação

#### U00 — Ledger e pré-voo
**Arquivos:** criar `.superpowers/sdd/2026-11-07-janghyang-lancamento/progress.md`; ler `.gitignore` (hoje: `.godot/`, `*.tmp`).

- [ ] Verificar se `.superpowers/` está versionado: `git -C /home/usuario/Dev/Jogo check-ignore -v .superpowers/`. Se não estiver ignorado, decidir como `Ruling:`: versionar ou ignorar. Sem decisão do Pedro: ignorar (é estado de execução, não produto).
- [ ] Criar `progress.md` com a linha de base da seção 1.3 e a primeira entrada `start`.
- **Gate:** arquivo existe e a linha de base do ledger bate com a seção 1.3.
- **Commit:** nenhum (ledger de execução), salvo se o Pedro pedir versionamento.

#### U01 — Pendência de lint (D8)
**Arquivos:** `context/discussoes/modelo-arquitetural-dinamico-3d.md:588`.

- [ ] Mostrar ao Pedro o fato e a data (2026-11-03). **Bloqueado por D8.**
- [ ] Após a resposta: atualizar o fato com `(d)` e data, ou marcar `~superseded 2026-11-07` apontando para o fato novo. Nunca apagar.
- **Gate:** `python3 lint.py` sem a pendência de validade vencida.
- **Commit:** `docs: review overdue architecture fact (lint)`.

#### U02 — Export templates do Godot 4.7.2
**Arquivos:** nenhum no repositório (ferramenta local).

- [ ] Instalar os export templates da versão exata `4.7.2.stable` pelo editor ou pela distribuição oficial. Não é dependência do jogo: fica fora do repositório.
- [ ] Verificar: `ls ~/.local/share/godot/export_templates/4.7.2.stable/` com arquivos `.tpl` ou `templates/` presentes.
- **Gate:** diretório existe com templates de Windows e Linux. Se o download falhar, registrar em `achados.md` como bloqueio de M4 e seguir (as demais fases não dependem disso).
- **Commit:** nenhum.

#### U03 — Colisão de nome: lojas
**Arquivos:** `context/decisoes.md` (nova entrada com `(e)` para os fatos achados).

- [ ] Buscar "Janghyang" e "잔향" no Steam, itch.io e GOG, pela busca interna de cada loja (WebSearch em modo `standard`; `extended` se o resultado vier raso).
- [ ] Registrar cada resultado com data e URL: `- [YYYY-MM-DD] (e) ← <url> <resultado>`.
- **Gate:** tabela com três lojas × dois termos, cada célula com resultado e URL.
- **Commit:** `docs: record store name collision check for Janghyang`.

#### U04 — Colisão de nome: registros, domínio e redes
**Arquivos:** `context/decisoes.md`.

- [ ] INPI e USPTO, classe de jogos eletrônicos (`(e)` com URL).
- [ ] Domínio `janghyang` (.com, .games, .io) e handles em Steam, itch.io, X, Instagram, YouTube.
- [ ] Revisão de falante nativo de 잔향 (Pedro ou contato indicado): `(d)` quando feita.
- **Gate:** resultados registrados; se houver colisão direta, abrir decisão de nome (`(d)`) antes de U63.
- **Commit:** `docs: record registry, domain and handle check for Janghyang`.

---

### Fase 1 — Harness e correções técnicas

#### U10 — A-006: selftest não trava
**Arquivos:** `Janghyang/scripts/selftest.gd` (`_ready`, linha 52).

- [ ] **Teste de regressão (RED):** cópia descartável do projeto em `/tmp`-equivalente do scratchpad com uma linha de erro proposital em `_run` (ex.: `var _x = main.NOPE`). Rodar o selftest: hoje o processo não termina. Registrar o tempo até `timeout` matar o processo (esperado: não termina).
- [ ] Adicionar em `_ready`: um `SceneTreeTimer` de `GUARD_S := 120.0` (acima dos 43 s medidos) que imprime `SELFTEST GUARD: timeout` e chama `get_tree().quit(1)`.
- [ ] Repetir a cópia com o erro proposital: o processo deve sair com código 1 em até 120 s.
- [ ] Rodar o selftest real: 241/0 sem alteração.
- **Gate:** saída com código 1 na cópia; 241/0 no projeto real.
- **Commit:** `fix: exit the selftest with failure when it hangs (A-006)`.

#### U11 — A-005: sonda do relógio que não pode passar sem o relógio
**Arquivos:** `Janghyang/scripts/selftest.gd:95`.

- [ ] **Teste de regressão (RED), mutação:** cópia descartável com a colisão do relógio desligada (`scripts/entry_clock.gd`/`main._build_entry_clock`, a colisão do `relogio_entrada`). Rodar o selftest: hoje o check `entry clock is solid` **passa**, o que é o defeito.
- [ ] Trocar a sonda para `Vector3(3.1, 0.85, 8.6)` (a sonda fica à frente do relógio, longe da fachada, conforme o achado).
- [ ] Na cópia mutada: o check deve **falhar**. No projeto real: deve **passar**.
- **Gate:** mutante falha; original passa; selftest 241/0 (contagem igual, check mantido).
- **Commit:** `test: probe the entry clock where the facade cannot hide it (A-005)`.

#### U12 — A-017: registrar a causa do reinício do tour (diagnóstico)
**Arquivos:** `Janghyang/scripts/player.gd:94-95`.

- [ ] Sem mudança de comportamento: antes de `reload_current_scene()`, `print("[reload] R via %s" % event)`.
- [ ] Rodar `godot --path Janghyang -- --tour` com `DISPLAY=:0` ao menos uma vez e registrar se o log aparece com evento sintético.
- **Gate:** selftest e unidade inalterados; log presente no `--tour`.
- **Commit:** `chore: log the input that reloads the scene (A-017)`.

#### U13 — A-013: eco mantém a própria janela de amostras
**Arquivos:** `Janghyang/scripts/echo.gd` (`sample_at` linha 26, `setup` linha 45, `_process` linha 68); `Janghyang/tests/test_echo.gd` (linhas 12, 13, 19); `Janghyang/scripts/echo_recorder.gd` (limite `MAX_SAMPLES`, `pop_front` linha 79).

**Interface nova:**
- Produz: `Echo.setup(recorder, seg: Vector2i, phase: float) -> void`: copia as amostras do segmento (`seg.y - seg.x` itens) para `_samples: Array[Dictionary]`.
- Produz: `Echo._sample_at(t: float) -> Dictionary` (instância; antes era `static sample_at(recorder, seg, t)`). Mesmo formato de retorno: `pos, yaw, pitch, crouched, action, index`. O campo `index` passa a ser relativo ao segmento.
- Consome: `EchoRecorder.get_sample(i)`.
- Chamadores confirmados (OpenCode + grep): `echo.gd:52` (`setup`), `echo.gd:68` (`_process`), `tests/test_echo.gd:12,13,19`.

- [ ] **Teste (RED):** em `test_echo.gd`, `test_echo_keeps_its_window_after_trim`: gravar amostras até passar de `MAX_SAMPLES`, criar `Echo` com um segmento, continuar gravando; o `_sample_at(t)` precisa devolver a mesma posição de antes do corte. Rodar a unidade: falha (chamadores antigos e índices deslocados).
- [ ] Implementar a interface acima e adaptar os três chamadores de teste.
- [ ] Rodar a unidade e o selftest.
- **Gate:** unidade ≥ 1059 + novos checks, 0 falhas; selftest 241/0.
- **Commit:** `fix: echoes keep their own samples after the recorder trims (A-013)`.

#### U14 — A-015: lápis só com o duplo sentado
**Arquivos:** `Janghyang/scripts/hour_event.gd` (`_write_next`, linhas 115–118; `end()`, linhas 64–70); `Janghyang/scripts/doll.gd` (`is_double()`, linha 57).

**Regra (Ruling, `(i)`):** a entrada do caderno é sempre escrita; o som do lápis só toca se `doll.is_double()` for verdadeiro no momento. O flush de `end()` escreve as entradas que faltam, mas **sem som** se o duplo não estiver sentado. Custo se errado: um som a menos no fim da hora; a regra pode ser revertida em uma linha.

- [ ] **Teste (RED):** selftest: com o banco vazio (duplo ainda não sentado) durante o 03:33, `main.sfx` não recebe `play_pencil_pattern`. Implementar um contador de chamadas ou um espião em `sfx` (scratch) e registrar o estado atual: hoje toca (defeito).
- [ ] Implementar a regra nos dois pontos.
- [ ] Mutação: reverter a checagem, o check deve falhar.
- **Gate:** check novo passa; mutante falha; selftest ≥ 241/0.
- **Commit:** `fix: pencil sounds only when the double sits at the bench (A-015)`.

#### U15 — A-007: saída sem vazamento de áudio
**Arquivos:** `Janghyang/scripts/sfx_bank.gd` (`LOOPED` linha 8; pool linhas 178–212); `Janghyang/scripts/main.gd` (players de loop: `breath` e `_loop_3d`, linhas 1205–1244; `_take_shot`, linha 1748–1758); `Janghyang/scripts/settings_ui.gd:191` (botão “Sair do jogo”).

**Ruling (`(i)`):** em vez de confiar em `_exit_tree` (já testado sem efeito, segundo o achado), o desligamento é explícito e centralizado:
- `SfxBank.stop_all() -> void`: para todo player de loop registrado e o pool; sem novos sons.
- Registro: `main` passa a guardar os players de loop (`breath`, cada `_loop_3d`) num array e os entrega a `SfxBank` para `stop_all`.
- `main.shutdown() -> void`: `sfx.stop_all()`, `await get_tree().process_frame`, `get_tree().quit()`.
- Chamadores de `shutdown`: `NOTIFICATION_WM_CLOSE_REQUEST` (novo `_notification` em `main.gd`), `settings_ui.gd:191` e `_take_shot`.

- [ ] **Teste (RED):** `tests/test_sfx_bank.gd`: `test_stop_all_silences_loops` com `silent = false` e um player de loop criado: após `stop_all`, `playing == false` para todos. Falha hoje (método não existe).
- [ ] Implementar `stop_all`, o registro e `shutdown`.
- [ ] **Gate de saída (headful):** `DISPLAY=:0 timeout 30 godot --path Janghyang --resolution 1280x720 -- --shot-clock 2>&1 | grep -c "ObjectDB instances were leaked"` → **0**. Linha de base medida no achado: 5.
- [ ] Se o gate não chegar a 0: não remendar. Registrar em `achados.md` o que sobrou (nomes dos objetos vazados do log) e parar a unidade como `blocked`.
- **Gate:** unidade ≥ 1059 + 1, 0 falhas; selftest 241/0; saída headful com 0 vazamentos.
- **Commit:** `fix: stop looping audio before exit so no playback leaks (A-007)`.

#### U16 — A-019: marcar o gatilho antigo do 03:33 como superado
**Arquivos:** `context/decisoes.md` (linha 70, decisão de 2026-10-28 sobre corda e 03:33); `Janghyang/tests/test_visit_state.gd`.

**Achado (novo, `(e)`):** `decisoes.md:70` diz que o 03:33 vem com "boneco + 5 itens, ou aos 1200 s". O spec de expansão (`§5`, regra "03:33 só começa na fase V") e o código (`visit_state.gd:9`, `MAX_PRE_HORA := 3600.0`) dizem outra coisa. Não há `~superseded` no fato antigo.

- [ ] **Teste (RED):** `test_visit_state.gd`: `test_gate_uses_the_expansion_rule`: o gate é `pieces_ready or elapsed >= 3600`; teste de constante e de comportamento.
- [ ] Em `decisoes.md:70`, marcar `~superseded 2026-11-07` apontando para a entrada de 2026-10-29 (linha 174) e para o spec de expansão `§5`. Não apagar o texto.
- [ ] Registrar `A-019` em `achados.md` com severidade `baixo`, reprodução (ler `decisoes.md:70` contra `visit_state.gd:9`) e fix (esta unidade).
- **Gate:** unidade passa; lint sem erro novo.
- **Commit:** `docs: mark the 1200 s 03:33 gate as superseded (A-019)`.

---

### Fase 2 — Decisão e correção de catálogo

#### P1 — Pedro decide D6 (A-014)
- [x] Mostrar as opções (seção 2, D6). Resolvido por delegação: "resolva e escolha tu" (2026-11-07).
- [x] Registrar em `context/decisoes.md` como `(i)` delegado (não `(d)`): escolha (a), por quê, descartado.

#### U20 — A-014: duplo conta como sentado (opção a, se confirmada em D6)
**Arquivos:** `Janghyang/scripts/doll.gd` (`become_double`); `Janghyang/scripts/selftest.gd`; `Janghyang/tests/test_doll.gd` (novo; o comportamento está em `doll.gd` e `test_catalog.gd` não alcança o duplo). Commit 67ccc48.

**Interface:** nenhuma nova. Após `become_double(seat)`, `catalog.set_flag(&"doll_sat", true)` (sinal ou chamada direta em `main`, decidido por leitura de `main.gd:1172-1180`).

- [x] **Teste (RED):** `test_doll.gd`: `test_double_counts_as_seated_doll` (falhou: `becoming the double reports it seated`).
- [x] Implementar: `become_double` emite `toggled(false)`; `main` já escreve `doll_sat` por esse sinal.
- [x] Selftest: check "the double counts as the seated doll for the catalogue (A-014)" (RED: `— false`; GREEN: passa).
- **Gate:** unidade 1064/0 e selftest 244/0 — cumprido.
- **Commit:** `fix: the double counts as the seated doll for the catalogue (A-014)`.

---

### Fase 3 — Rotas e regressão (M2)

Cada unidade desta fase cobre uma entrada do Review Focus (seção 5).

#### U30 — Gastos sempre têm caminho de volta (Review Focus 3)
**Arquivos:** `Janghyang/tests/test_stalker_model.gd`; leitura de `Janghyang/scripts/gastos.gd:105-134` (`graph`, `_build_graphs`) e `stalker_model.gd:94` (`next_toward`).

- [ ] **Teste (RED):** `test_every_lurk_point_reaches_every_goal`: para cada nível de `graph(lvl)` (casa, passagem, sótão, mecanismo, gaveta, tampo), para cada par (nó, objetivo) alcançável no grafo, `next_toward` chega ao objetivo em no máximo `n` passos (n = número de nós).
- [ ] Se algum nível falhar: é defeito de grafo (`achados.md`), não do teste.
- [ ] Mutação: remover um link de um nível na cópia descartável: o teste falha.
- **Gate:** unidade ≥ 1059 + novos, 0 falhas.
- **Commit:** `test: every lurk point has a way back to the goal`.

#### U31 — Parede oca além do necessário (Review Focus 1)
**Arquivos:** `Janghyang/tests/test_breakable.gd`; `Janghyang/scripts/breakable.gd` (`hit()`, linha 15).

- [ ] **Teste (RED):** `test_hits_after_break_change_nothing`: `hit()` depois de `&""` (nada restante) devolve `&""` e não recria o objeto; três pancadas em `oco` devolvem `crack, crack, break` e a quarta, `&""`.
- [ ] Implementar só se o teste falhar (provavelmente já passa: registrar `complete` sem mudança de código).
- **Gate:** unidade verde.
- **Commit:** `test: extra knocks after a wall gives way change nothing` (se só o teste foi adicionado).

#### U32 — 03:33 só libera com as peças ou no limite de tempo (Review Focus 2)
**Arquivos:** `Janghyang/tests/test_visit_state.gd`; leitura de `Janghyang/scripts/visit_state.gd:29-92`.

- [ ] **Teste (RED):** `test_skipping_phases_reaches_the_hour_only_by_time`: visita sem `on_pieces_ready`, sem catalogar nada: `update` não abre o gate antes de 3600 s; abre em 3600 s.
- [ ] **Teste (RED):** `test_pieces_open_the_gate_at_once`: com `on_pieces_ready` a qualquer momento, o gate abre sem esperar o tempo.
- **Gate:** unidade verde.
- **Commit:** `test: the 03:33 gate opens only with the pieces or the hour limit`.

#### U33 — Rota da passagem (selftest)
**Arquivos:** `Janghyang/scripts/selftest.gd` (`LOOP` linha 23; `_run`); leitura de `Janghyang/scripts/areas/passagem.gd` (coordenadas da parede oca e da entrada agachada).

- [x] **Teste (RED):** segmento agachado (`crouch_shape`) da sala de brincar (z 0.9) pela parede oca (z 0) até a passagem. **Desvio (i):** os segmentos ficam numa checagem própria logo após a quebra da parede, não em `LOOP`, porque `LOOP` alimenta `_feed_loop`, que grava a trajetória do eco. RED por mutante em cópia: parede com 999 pancadas → FAIL "blocked by HollowPanel".
- [x] Após quebrar a parede pelo pipeline de `hit()` (3 pancadas), o segmento é transitável (GREEN).
- [x] **Gate:** selftest 251/0 (+2), código 0; unit 1075/0 sem mudança.
- **Commit:** `test: walk the passage route in the selftest`.

#### U34 — Rota do sótão e do mecanismo, com escada (Review Focus 4)
**Arquivos:** `Janghyang/scripts/selftest.gd`; leitura de `Janghyang/scripts/areas/sotao.gd` (torre, escada, `TurningGear`) e `Janghyang/scripts/ladder.gd`, `main.gd:503` (`_ladder_area`).

- [x] **Teste (RED):** `W` fora de escada não sobe — `W off the ladder walks, Elias stays on the floor` (teclas por `Input.parse_input_event`, como o `tour.gd`). RED por mutante do volume da escada (`ladder.gd` sem contar): 5 FAIL.
- [x] **Teste (RED):** dentro da escada, `W` sobe; no topo da escada da torre, `atlas.room_at` retorna `&"mecanismo"` (`W climbs the tower ladder`; `at the top of the tower ladder Elias is in the mechanism`).
- [~] Segmento da rota: sala → escada → sótão → torre. **Parcial (i):** a escada da passagem e a da torre são percorridas com `W`; o chão do sótão entre elas **não** é percorrido por segmento, e a base da escada da torre é alcançada por teleporte. A porta da torre (`DoorTower`) é fechada e exige interação, que o selftest ainda não faz.
- [x] **Gate:** selftest 258/0 (+7 sobre 251), código 0; unit 1075/0 sem mudança.
- **Commit:** `test: climb the attic ladder and reach the mechanism in the selftest`.

#### U35 — Rota da gaveta
**Arquivos:** `Janghyang/scripts/selftest.gd`; leitura de `Janghyang/scripts/areas/gaveta.gd` (alçapão, escada para baixo).

- [x] **Teste (RED):** quarto de dormir → alçapão → escada → `room_at == &"gaveta"`. Checks: `three knocks break the trapdoor`, `S on the ladder goes down into the drawer`, `the foot of the ladder is the drawer`. RED por mutante do alçapão (999 pancadas): 3 FAIL. Sem segmento de caminhada até o alçapão: à altura do corpo em pé ele não toca o colisor do chão, então o check passaria mesmo no mutante (descartado).
- [x] **Gate:** selftest 263/0 (+5 sobre 258), código 0; unit 1075/0.
- **Commit:** `test: reach the drawer through the bedroom trapdoor in the selftest`.

#### U36 — Rota do tampo e da Relojoaria
**Arquivos:** `Janghyang/scripts/selftest.gd`; leitura de `Janghyang/scripts/areas/leste.gd` (vidro da redoma, loja `loja_varela`).

- [ ] **Teste (RED):** tampo → quebrar o vidro (`quebrar_redoma`) → bancada → `room_at == &"loja_varela"`.
- **Gate:** selftest verde.
- **Commit:** `test: reach the Varela shop across the bench in the selftest`.

#### U37 — Regressão dos finais e da saída antecipada
**Arquivos:** `Janghyang/scripts/selftest.gd` (já cobre: `reaching the tampo edge ends the visit` linha 450; `leaving during 03:33 ends the hour` linha 454; `new figure stays in the maquete` linha 468).

- [ ] Confirmar a cobertura de `corda`, `parar`, `incompleto`. Acrescentar apenas o que faltar: saída antes do fragmento 3 mantém a corda como estava (relojoeiro `§6.7`, linha 134).
- **Gate:** selftest verde; cada final com ao menos um check.
- **Commit:** `test: cover the stop-before-fragment-3 exit` (se houve adição).

#### U38 — Gate de fechamento da fase 3
- [ ] Rodar os três gates e o lint. Registrar a contagem nova como linha de base.
- [ ] Propor a D2 (escopo congelado) para o Pedro com a lista de unidades concluídas.
- **Gate:** selftest e unidade com a contagem final; lint sem erro novo.
- **Commit:** nenhum (só ledger).

---

### Fase 4 — Clima e interface (M3)

#### U40 — Luz da oficina (historico:94, 134)
**Arquivos:** `Janghyang/scripts/main.gd` (luminárias da oficina, `--shot-atelier` e `--shot-giant`).

- [ ] Captura antes: `godot --path Janghyang -- --shot-giant` → `blockout-giant.png` (registrar o arquivo de antes).
- [ ] Uma mudança de energia da luz da oficina por vez; captura depois.
- [ ] **Gate visual (D7):** Pedro aprova a imagem.
- **Commit:** `fix: light the giant workshop enough to read the figures`.

#### U41 — Relógio da entrada em captura (historico:95)
**Arquivos:** captura `--shot-clock`.

- [ ] Gerar `blockout-clock.png` e revisar: ponteiros legíveis, hora e minuto identificáveis.
- [ ] **Gate visual (D7).**
- **Commit:** se houver ajuste.

#### U42 — `Esc` em janela real (Review Focus 5)
**Arquivos:** checklist em `context/discussoes/checklist-janela.md` (novo); `Janghyang/scripts/settings_ui.gd:74-75` (`Esc`), `:7` (`user://opcoes.cfg`).

- [ ] Checklist manual, executado pelo Pedro em Windows e Linux: `Esc` com caderno aberto devolve o mouse; `Esc` fecha o menu sem prender o cursor; tela cheia e troca de monitor; opções persistem entre aberturas (`user://opcoes.cfg`).
- [ ] Registrar o resultado com `(d)` por sistema.
- **Gate:** checklist preenchido nos dois sistemas.
- **Commit:** `docs: add window checklist for the options menu`.

#### U43 — Persistência de opções corrompidas (cobertura extra)
**Arquivos:** `Janghyang/tests/test_settings_model.gd`; `Janghyang/scripts/settings_model.gd:57-68` (`read`, `load_from`).

- [ ] **Teste (RED):** arquivo `user://opcoes.cfg` ausente ou com valor fora da faixa: `load_from` devolve os padrões sem erro.
- **Gate:** unidade verde.
- **Commit:** `test: options fall back to defaults when the file is missing or invalid`.

---

### Fase 5 — Playtests (M1, repetido em M3)

#### U50 — Roteiro do playtest 1
- [ ] Escrever `context/discussoes/playtest-1.md`: três finais, o 03:33, as quatro peças do relógio, métricas (conclusão da visita, % que chega ao 03:33, tempo até o primeiro Gasto, tempo até a primeira peça, abandono e ponto).
- **Gate:** roteiro aprovado pelo Pedro (`(d)`).
- **Commit:** `docs: playtest 1 script and metrics`.

#### U51 — Sessões (humanos)
- [ ] Três a cinco sessões, com observação silenciosa e tempo medido. Material bruto em `fontes/YYYY-MM-DD-playtest-N.md` com `(e)`.
- **Gate:** métricas por jogador.
- **Commit:** `docs: raw notes from playtest sessions`.

#### U52 — Triagem dos achados de playtest
- [ ] Cada problema vira `achados.md` (severidade, reprodução, fix). Problemas de jogo que mudam regra: `(d)` antes de implementar.
- **Gate:** lista triada.
- **Commit:** `docs: triage playtest findings`.

---

### Fase 6 — Release (M4 a M6)

#### U60 — Preset de exportação
**Arquivos:** `Janghyang/export_presets.cfg` (novo).

- [ ] Preset Windows e preset Linux, nome do executável `Janghyang`.
- **Gate:** `godot --headless --path Janghyang --export-release "Linux" build/linux/Janghyang` (com U02 concluída) gera o binário.
- **Commit:** `build: add Windows and Linux export presets`.

#### U61 — Build testado
- [ ] Rodar o binário exportado: abre, menu aparece, uma visita curta sem erro no log.
- [ ] Repetir o selftest contra o binário quando possível.
- **Gate:** dois binários abrindo sem erro.
- **Commit:** nenhum.

#### U62 — Texto final e idiomas (D4)
- [ ] Revisar catálogo, caderno, finais e ajuda. Se D4 incluir inglês: traduzir tudo, pt-BR como base, revisão de falante nativo.
- **Gate:** nenhuma string em idioma errado; revisão registrada.
- **Commit:** `docs: final copy review` (ou tradução).

#### U63 — Página da loja e material (D5)
- [ ] Textos, capturas (das unidades U40/U41), trailer curto. Preço e modelo (D5).
- **Gate:** rascunho aprovado pelo Pedro (`(d)`).
- **Commit:** nenhum (material fora do git, conforme a memória do projeto).

#### U64 — Beta fechado
- [ ] Cinco a dez jogadores, Windows e Linux.
- **Gate:** zero bug de prioridade alta aberto.

#### U65 — Submissão
- [ ] Enviar à loja escolhida em D1, com folga para revisão.
- **Gate:** aprovada, ou ajuste com prazo.

#### U66 — Publicação
- [ ] Publicar em 2027-04-15. **Ação externa: exige confirmação do Pedro no momento.**
- **Gate:** jogo disponível, com canal de relatos.

---

## 5. Review Focus (cinco entradas que nenhuma tarefa testava)

Estas são as entradas com mais chance de afetar quem joga, extraídas dos specs. Cada uma tem a unidade que a testa.

1. **Parede oca batida além do necessário** → U31 (pancadas extras não travam nem reabrem a passagem).
2. **Visita fora da ordem, 03:33 chega só pelo tempo** → U32 (gate por peças ou 3600 s, e nada trava).
3. **Gasto sem caminho de volta** → U30 (todo nó de espreita alcança todo objetivo).
4. **Escada de mão** → U34 (`W` fora da escada não sobe; no topo, o jogador não fica preso).
5. **`Esc` com caderno aberto em tela cheia e troca de monitor** → U42 (checklist manual, Pedro).

---

## 6. Global Constraints

- Godot 4.7.2; renderer GL Compatibility; viewport 1280×720 (`project.godot`: `viewport_width=1280`, `viewport_height=720`).
- Nenhuma dependência externa, nenhum asset importado; som sintetizado em código, pico ≤ 0,5 (`context/decisoes.md`, 2026-10-28, `(i)`).
- Sem morte nem game over; perder custa tempo, não progresso; porta da rua nunca tranca; texto só em papel (`context/decisoes.md`, 2026-10-28, `(d)`).
- Texto do jogo em português brasileiro, revisado antes de cada marco.
- Commits: Conventional Commits em inglês. **Sem `Co-Authored-By`** (regra do `CLAUDE.md` do usuário, que prevalece sobre o aviso de atribuição do ambiente).
- Commits ficam locais até o Pedro pedir `push`.
- Antes de concluir qualquer unidade: selftest ≥ baseline com 0 falhas, unidade ≥ baseline com 0 falhas, `python3 lint.py` sem erro novo.

---

## 7. Pós-lançamento (fora deste plano)

- Novas mecânicas, áreas, Gastos e finais.
- Localização além do que D4 definir.
- Versão para macOS, se D1 não incluir.
- Console: fora de escopo até 2027-04-15 (`context/decisoes.md`, decisão de plataforma).
- Métricas de venda e feedback pós-lançamento.
