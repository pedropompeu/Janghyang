# Janghyang — Plano da Demo (noites 1 e 2) até 2027-04-15

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Uma tarefa por vez, na ordem deste arquivo; a tarefa N+1 só começa com a N `complete` no ledger.

**Goal:** transformar o protótipo de uma visita só numa campanha de noites e publicar a demo com as noites 1 e 2 (casa, passagem, sótão, torre). A demo leva as onze ações, a bússola, a planta com névoa, a captura com fuga, a casa que deixa de ser segura, o registro de áreas e os primeiros assets de maquete, depois de três playtests humanos.

**Architecture:** As áreas passam a ser dados (`const DEF` em `scripts/areas/<id>.gd`), listados num registro por `preload`. As noites são dados em `scripts/story/noites.gd`. Toda regra nova nasce como modelo `RefCounted` puro, com teste de unidade, e só depois ganha o nó que a liga ao mundo. O `main.gd` deixa de conhecer área por área e passa a percorrer os registros. Os seus helpers de construção viram um contrato testado.

**Tech Stack:** Godot 4.7.2 (GL Compatibility, 1280×720); GDScript; suíte `tests/run_unit.gd`; selftest headless (`--selftest`); Blender 4.5.15 LTS headless para os assets (`blender -b --factory-startup --python`), com exportação glTF; `python3 lint.py`; OpenCode (`mcp__opencode__ask_opencode`, somente leitura) para segunda opinião.

**Spec:** `docs/superpowers/specs/2026-11-08-janghyang-direcao-design.md` (aprovado por Pedro em 2026-11-08). As referências `§n` deste plano apontam para ele.

**Substitui:** `docs/superpowers/plans/2026-11-07-janghyang-lancamento.md`. As unidades abertas dele estão mapeadas no §0.3.

**Ledger:** `.superpowers/sdd/2026-11-08-janghyang-demo/progress.md` (ignorado pelo git, criado na Tarefa 1).

## Global Constraints

- Godot 4.7.2, GL Compatibility, viewport 1280×720 (§18). Nada de Forward+, `VolumetricFog` ou `FogVolume` (§14.3).
- Tudo o que é jogo é gerado em código. Os assets entram como `.glb` e texturas, mas a montagem é código (§18).
- Modelos de dados são `RefCounted` carregados por `preload`, sem `class_name` (§18).
- As áreas são registradas por `preload` em `const AREAS := [...]`, nunca por varredura de diretório (§12.1).
- Custo financeiro zero. Assets só CC0 ou equivalente, ou feitos do zero, e cada um registrado em `Janghyang/assets/LICENCAS.md` (§14.2).
- Sem morte, sem game over. Perder custa tempo e nervo, nunca progresso (§10).
- Sem HUD, minimapa, marcador de objetivo, barra de vida ou grade de inventário. Texto só em papel. A casa não fala (§16, §18).
- A porta da rua nunca tranca nem se barrica, e nenhum Gasto a bloqueia. Nada acontece durante o 03:33 (§11, §18).
- Sustos sem estouro de volume (§13, §20), revisar em 2026-11-22. No máximo um susto forte por minuto. Nenhum susto tira o controle por mais de 2 s fora da captura.
- O piscar da captura fica abaixo de 3 Hz e nunca usa branco cheio (§10).
- Só se salva entre noites (§5.1).
- Os testes de unidade e o selftest ficam verdes a cada tarefa. Linha de base: unidade **1093/0**, selftest **282/0**.
- Commits em Conventional Commits em inglês, **sem `Co-Authored-By`** e sem menção à IA (`CLAUDE.md` do usuário, que prevalece sobre o aviso de atribuição do ambiente). Commit direto no `main`, sem push até Pedro pedir.
- Todo fato novo em `context/` leva `[YYYY-MM-DD]` e `(d)`, `(i)` ou `(e)`. Nada se apaga: o que mudou é marcado com `~superseded`. Rodar `python3 lint.py` antes de cada `complete`.

## Review Focus

São as cinco entradas que o spec implica, que nenhum teste de feature cobriria sozinho e que têm mais chance de afetar quem joga. Cada uma tem o teste que a prende, dentro da tarefa dona do código.

1. **Save entre noites ausente, corrompido ou de versão antiga.** A campanha deve abrir na noite 1 sem travar e sem apagar o arquivo ruim (Tarefa 10, `test_corrupt_save_starts_fresh_and_keeps_the_file`).
2. **Captura em estado misturado:** caderno aberto, Elias no esconderijo, dois Gastos chegando no mesmo tick, `Esc` no meio da luta. Deve haver uma luta só, o caderno deve fechar e a luta não pode correr durante a pausa (Tarefa 15, `test_second_grab_is_ignored` e o check de selftest `capture: Esc pausa a luta`).
3. **Bússola sem cômodo ou sem caminho:** Elias na beira, na escada ou entre níveis, ou a meta atrás de um link fechado. O ponteiro deve girar devagar, ou apontar para o link fechado, e nunca dar erro (Tarefa 16, `test_outside_any_room_spins` e `test_closed_link_still_routes`).
4. **A luz acaba sem pilha à vista.** A rota de toda noite deve ter luz que baste e nunca deixar Elias preso no breu (Tarefa 19, `test_every_night_route_has_enough_light`).
5. **Gatilho do 03:33 em hora ruim:** as metas fecham com Elias já no térreo, dentro do esconderijo ou agarrado, ou o limite de 60 min cai durante a captura. O 03:33 deve esperar a captura terminar e nunca disparar duas vezes (Tarefa 11, `test_goals_met_on_ground_floor_opens_at_once` e `test_hard_limit_waits_for_the_capture`).

---

## 0. Como rodar este plano

### 0.1 Regras (herdadas do plano de 2026-11-07)

1. **Uma tarefa por vez,** em série, sem paralelismo, com um commit (ou poucos) por tarefa.
2. **Pré-voo:** rodar os três gates (§0.2). Se não baterem com a última linha `complete` do ledger, parar e registrar em `context/achados.md`.
3. **RED de verdade:** o teste novo precisa falhar antes da implementação. Quando o teste cobre código que já existe, a prova é um mutante numa cópia descartável no scratchpad, nunca no repositório.
4. **Duas tentativas falhas** na mesma tarefa param a tarefa. Registrar em `achados.md` com severidade, repro e o que foi descartado. Não afrouxar teste.
5. **Decisão técnica** entra no ledger como `Ruling:` e em `context/decisoes.md` como `(i)`. Regra de jogo, arquitetura além do spec, dependência nova ou custo ficam pendentes para Pedro (`(d)`, §0.4).
6. **Pasta nova ou serviço novo** (`scripts/story/`, `scripts/maquetes/`, `arte/`) entra em `context/arquitetura.md` na mesma tarefa.
7. **Formato misto de execução** (aprovado por Pedro em 2026-11-08). A sessão principal (Claude Code) é a gestora: escreve o pedido de cada tarefa, distribui o trabalho, lê o diff, roda de novo os três gates e faz o commit.
   - **Construtores dos modelos isolados** (Tarefas 13–16, 18–20, 22–25 e 28–33): o OpenCode (`opencode run -m opencode/deepseek-v4.1-flash-free`, agente `build`) e o Gemini CLI (`gemini -p ... --approval-mode auto_edit`, cota gratuita). Só modelos gratuitos, sempre.
   - **Revisão cruzada:** quem constrói nunca revisa a própria tarefa. O que o OpenCode constrói, o Gemini revisa (`--approval-mode plan`), e o contrário também. As tarefas da sessão principal são revisadas por um dos dois.
   - **Integração** (3–12, 17, 21 e 34) e **arte, playtests e lançamento** (35–47) ficam com a sessão principal, com Pedro onde o plano pede.
   - **Fim de cada marco:** um revisor Claude novo revisa o conjunto.
   - **Os construtores não fazem commit.** O pedido leva a tarefa do plano, as Global Constraints e a frase "não faça commit nem push".
   - **Teste inicial:** a Tarefa 13 com o OpenCode, a 14 com o Gemini e a 15 com a sessão principal. Depois delas, a distribuição do resto é registrada no ledger como `Ruling:`.
   - **Falhas:** cota esgotada ou modelo indisponível passam a tarefa ao outro construtor. Duas tentativas falhas passam a tarefa à sessão principal (regra 4).
8. **Texto de jogo novo** (capítulos, cartas, hipóteses) é escrito pela IA como rascunho e marcado `D9` no ledger até a leitura de Pedro.

Formato do ledger:

```
[YYYY-MM-DD] Tn: start | baseline unit N/0 selftest M/0 lint ok
[YYYY-MM-DD] Tn: Ruling: <decisão e custo se errada>
[YYYY-MM-DD] Tn: complete | unit N/0 selftest M/0 | commit <hash> | evidência: <comando → saída>
```

### 0.2 Gates

| Gate | Comando (de `~/Dev/Jogo`) | Passa quando |
|---|---|---|
| Unidade | `timeout 60 godot --headless --path Janghyang -s res://tests/run_unit.gd 2>&1 \| tail -3` | `UNIT RESULT: N checks, 0 failures` com N ≥ o último |
| Selftest | `timeout 150 godot --headless --path Janghyang -- --selftest 2>&1 \| tail -3` | `SELFTEST RESULT: M checks, 0 failures` com M ≥ o último |
| Lint | `python3 lint.py` | sem erro novo |

Para ver só o teste da tarefa: `... run_unit.gd 2>&1 | grep -E "UNIT: test_<arquivo>|FAIL"`. O rtk filtra saída; se ela vier vazia, use `rtk proxy <cmd>`.

### 0.3 O que veio do plano de 2026-11-07

| Unidade antiga | Estado | Onde fica agora |
|---|---|---|
| U00, U01, U10–U16, U20, U33–U37, U43, U60 | concluídas | — |
| U02 export templates | já instalados: `~/.local/share/godot/export_templates/4.7.2.stable` | Tarefa 1 só registra |
| U30 todo ponto de espreita alcança toda meta | aberta | Tarefa 2 |
| U31 pancadas depois da quebra | aberta | Tarefa 2 |
| U32 gate do 03:33 | aberta, regra mudou (§5.1) | Tarefa 11, adaptada à noite |
| U38 gate da fase 3 e D2 congelamento | obsoletas: o escopo foi reaberto (R10) | — |
| U40 luz da oficina, U41 relógio em captura | abertas, D7 | Tarefa 43 |
| U42 `Esc` em janela real | aberta | Tarefa 43 |
| U50–U52 playtests | abertas | Tarefas 25–27, 41–42 |
| U03, U04 colisão de nome | abertas, D3 | Tarefa 44 |
| U61 parcial, U62–U66 | abertas, D1, D4, D5 | Tarefas 45–47 |

### 0.4 Decisões de Pedro (`(d)`)

| ID | Decisão | Default enquanto não fecha | Bloqueia |
|---|---|---|---|
| D1 | Plataforma: Steam e/ou itch.io | Steam e itch.io | Tarefas 45–47 |
| D3 | Nome Janghyang: colisão | prosseguir se a busca não achar colisão direta | Tarefa 46 |
| D4 | Idiomas da demo | só pt-BR na demo | Tarefa 45 |
| D5 | Modelo e preço | demo gratuita; preço do jogo depois do playtest 3 | Tarefa 46 |
| D7 | Aprovação visual das capturas | Pedro aprova cada `--shot-*` | Tarefas 34–40, 43 |
| D9 | Texto dos capítulos 1 a 4, a carta e as hipóteses (§20) | rascunho da IA no jogo, marcado no ledger | Tarefa 45 (texto final) |
| D10 | Sustos com estouro de volume (§20) | não | só o afinamento da Tarefa 24 (revisar 2026-11-22) |
| D11 | Se faltar tempo, o que sai | saem antes a isca (Tarefa 33) e a barricada (Tarefa 32) | marco M3 |
| D12 | Quem joga os playtests e quando | Pedro recruta 3 a 5 pessoas por rodada | Tarefas 26, 41 |

### 0.5 Marcos (datas sugeridas pela IA)

| Marco | Tarefas | Até |
|---|---|---|
| M1 registro inteiro | 1–9 | 2026-11-29 |
| M2 noite 1 jogável em blocos | 10–24 | 2026-12-23 |
| P1 primeiro playtest | 25–27 | 2027-01-04 a 2027-01-10 |
| M3 noite 2 com as onze ações | 28–33 | 2027-02-14 |
| M4 assets da demo | 34–40 | 2027-03-14 |
| P2, P3 | 41–42 | 2027-03-15 a 2027-03-31 |
| M5 demo publicada | 43–47 | 2027-04-15 |

---

## 1. Mapa de arquivos

**Novos, modelos puros (`RefCounted`, com teste):**

| Arquivo | Responsabilidade |
|---|---|
| `scripts/areas/registry.gd` | lista das áreas (`AREAS`), contrato dos helpers (`HELPERS`), junção de cômodos, pontos seguros, tarefas e links |
| `scripts/maquetes/registry.gd` | as maquetes 214, 215 e 216 e as áreas de cada uma |
| `scripts/story/noites.gd` | as cinco noites, só dados: capítulos, metas, peças, tarefas, segurança, Gastos, âncoras, cliques, luz |
| `scripts/campaign_model.gd` | o que passa de uma noite para outra, e o save em `user://campanha.json` |
| `scripts/safety_model.gd` | `is_safe(point, rule, world)` por noite |
| `scripts/capture_model.gd` | livre, agarrado, soltou, abraço |
| `scripts/compass_model.gd` | rota no grafo de links, mira, tique, tremor |
| `scripts/hands_model.gd` | mão esquerda com uma coisa por vez, e os bolsos |
| `scripts/fog_grid.gd` | grade de bits de 0,5 m por nível |
| `scripts/plan_model.gd` | névoa por nível e anotações de lápis |
| `scripts/light_model.gd` | pilha, fósforo, vela e lamparina |
| `scripts/noise_model.gd` | três níveis de ruído, e a respiração presa |
| `scripts/listen_model.gd` | o que se ouve pela parede e com o estetoscópio |
| `scripts/staging_model.gd` | poses da encenação, que andam fora da vista |
| `scripts/chapter_model.gd` | pistas, encenação e hipótese de um capítulo |
| `scripts/scare_director.gd` | ritmo dos sustos |
| `scripts/lost_model.gd` | "perdido há 3 min", para o playtest |
| `scripts/anchor_model.gd` | relógio-âncora |
| `scripts/repair_model.gd` | encaixar a peça e girar até engrenar |
| `scripts/barricade_model.gd` | porta escorada |
| `scripts/lure_model.gd` | brinquedo de corda |
| `scripts/asset_loader.gd` | `.glb`, ou o bloco de hoje se ele faltar |

**Novos, nós de cena:** `scripts/areas/casa.gd`, `scripts/areas/mecanismo.gd`, `scripts/areas/tampo.gd`, `scripts/pocket_watch.gd`, `scripts/plan_revealer.gd`, `scripts/capture_fx.gd`, `scripts/night_card_ui.gd`, `scripts/playtest_log.gd`, `scripts/hand_mirror.gd`, `scripts/wind_toy.gd`.

**Modificados:** `main.gd` (passa a percorrer os registros e a montar a noite), `atlas.gd` (`rooms()` no lugar de `ROOMS`), `gastos.gd` (segurança por ponto, `MAX := 3`, ruído, barricada), `stalker_model.gd` (pontos seguros, links bloqueados), `quest_model.gd` (fases vindas da noite), `visit_state.gd` (estado de uma noite), `notebook_ui.gd` (névoa, anotações, bolsos, hipótese, sem pausa), `player.gd` (teclas novas), `hands.gd` (mão esquerda), `settings_model.gd` e `settings_ui.gd` (opções de acessibilidade), `catalog.gd` e `catalog_data.gd` (texto da lupa, `to_dict`), `hour_event.gd` (03:33 curto), `selftest.gd` (rotas pelos links, noites).

**Arte:** `arte/fontes/` (brutos), `arte/blender/<asset>.py`, `Janghyang/assets/models/`, `Janghyang/assets/textures/`, `Janghyang/assets/LICENCAS.md`.

**Teclas novas** (escolha da IA; §19 deixa isso com quem constrói). O `Q` continua sendo catalogar, então o relógio vai para o `T`:

| Tecla | Ação |
|---|---|
| `T` | abrir ou fechar o relógio de Elias (mão esquerda) |
| roda do mouse | trocar o item da mão esquerda pelos bolsos |
| clique esquerdo | usar o item da mão esquerda; na captura, empurrar |
| `G` | marcar giz na parede |
| segurar `L` | escutar pela parede |
| segurar `H` | prender a respiração |
| segurar `E` | dar corda num âncora, barricar uma porta, girar um mecanismo |

---

## 2. Fase 0 — Preparação

### Tarefa 1: Ledger e linha de base

**Files:** Create `.superpowers/sdd/2026-11-08-janghyang-demo/progress.md`.

- [ ] **Step 1:** Criar o ledger com a linha `[2026-11-08] T1: start | baseline unit 1093/0 selftest 282/0 lint ok`, depois de rodar os três gates do §0.2.
- [ ] **Step 2:** Conferir os templates (U02) com `ls ~/.local/share/godot/export_templates/`, que deve mostrar `4.7.2.stable`, e registrar a saída no ledger.
- [ ] **Step 3:** Fechar com `T1: complete`. Não há commit, porque o ledger é ignorado pelo git.

### Tarefa 2: Testes herdados U30 e U31

**Files:** Modify `Janghyang/tests/test_stalker_model.gd`, `Janghyang/tests/test_breakable.gd`. Ler `scripts/stalker_model.gd:94` (`next_toward`) e `scripts/breakable.gd:16` (`hit`).

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_every_lurk_point_reaches_every_goal(t) -> void:
	# grafo em anel com um ramo: 0-1-2-3-0 e 2-4
	var pts: Array[Vector3] = [Vector3(0,0,0), Vector3(2,0,0), Vector3(2,0,2), Vector3(0,0,2), Vector3(4,0,2)]
	var m = StalkerModel.new(pts, [[0,1],[1,2],[2,3],[3,0],[2,4]])
	for from in pts.size():
		for goal in pts.size():
			var at := from
			for _i in pts.size():
				at = m.next_toward(at, goal)
			t.eq(at, goal, "chega de %d a %d" % [from, goal])

func test_hits_after_break_change_nothing(t) -> void:
	# três pancadas no oco: crack, crack, break; a quarta e a quinta: nada
	...
	t.eq(results, [&"crack", &"crack", &"break", &"", &""], "pancadas depois da quebra não fazem nada")
```

O formato dos `links` e o construtor da peça quebrável seguem o que os testes vizinhos já usam no mesmo arquivo.

- [ ] **Step 2:** Provar o RED com mutantes no scratchpad: remover o link `[2,4]` dentro de `next_toward`, e fazer `hit()` devolver `&"break"` de novo depois da quebra. Os dois testes devem falhar.
- [ ] **Step 3:** Rodar o gate de unidade, com 0 falhas. Se um teste falhar contra o código real, é defeito: vai para `achados.md` e é corrigido nesta tarefa.
- [ ] **Step 4: Commit** `test: lurk points always reach the goal and extra knocks change nothing`

---

## 3. Fase 1 — O registro de áreas (§12)

### Tarefa 3: Esqueleto do registro, contrato dos helpers e validação dos `DEF`

**Files:**
- Create: `Janghyang/scripts/areas/registry.gd`, `Janghyang/tests/test_registry.gd`
- Modify: `Janghyang/scripts/atlas.gd` (os `ROOMS` de hoje viram `LEGACY_ROOMS`, mais `static func rooms()`), todos os leitores de `Atlas.ROOMS` (`gastos.gd`, `notebook_ui.gd` e o que `grep -rn "ROOMS" scripts` achar), `main.gd:63-65` e `LEVEL_SAFE`.

**Interfaces:**
- Produces, em `registry.gd`:
  - `const AREAS := []`, que começa vazio e cresce uma linha por área migrada;
  - `const HELPERS := {&"_mat": 3, &"_box": 6, &"_add_mesh": 5, &"_omni": 6, &"_floor": 6, &"_wall_x": 7, &"_wall_z": 7, &"_hinge": 12, &"_cyl": 7, &"_breakable": 7, &"_rungs": 4, &"_ladder_area": 4, &"_hideout": 4, &"_piece": 3, &"_chalk": 4, &"_chalk_frame": 5, &"_catalog_target": 4}`. É a contagem de argumentos lida em `main.gd` em 2026-11-08, padrões incluídos;
  - `static func defs() -> Array[Dictionary]`, que devolve cada `DEF` com `"level"` igual ao `id` e cada cômodo com `"level"` preenchido;
  - `static func def(id: StringName) -> Dictionary`;
  - `static func rooms() -> Array`;
  - `static func safe_points() -> Dictionary` (nível para `Vector3`);
  - `static func merged(key: String) -> Dictionary`, para `"tasks"`, `"breaks"` e `"catalog"`;
  - `static func links() -> Array`, com cada link como `{from, to, at, path, gate}`.
- Produces, em `atlas.gd`:
  - `static func rooms() -> Array`, que devolve `LEGACY_ROOMS` com o que não migrou e depois `Registry.rooms()`;
  - `static func levels() -> Dictionary`, no lugar de `LEVELS`, com a mesma junção.
- Formato do `DEF` (§12.1): `{"id", "maquete", "name", "rooms": [{id, name, rect, y}], "safe": Vector3, "links": [{"to": StringName, "at": Vector3, "path": Array[Vector3], "gate": StringName}], "tasks": {}, "breaks": {}, "catalog": {}, "anchors": [], "hideouts": [], "pickups": [], "chalk": [], "mechanisms": []}`. Em cada link, `path` vai do `safe` desta área até `at`; `gate` é `&""` ou o nome da quebrável ou do mecanismo que abre o link.

- [ ] **Step 1: Escrever os testes** em `test_registry.gd`:

```gdscript
func test_area_helpers_exist_with_their_arity(t) -> void:
	var methods := {}
	for m in load("res://scripts/main.gd").get_script_method_list():
		methods[m.name] = m.args.size()
	for h in Registry.HELPERS:
		t.ok(methods.has(String(h)), "main tem %s" % h)
		t.eq(methods.get(String(h), -1), Registry.HELPERS[h], "aridade de %s" % h)

func test_defs_are_valid(t) -> void:
	var ids := {}
	for d in Registry.defs():
		t.ok(not ids.has(d.id), "id único %s" % d.id); ids[d.id] = true
		t.ok(Atlas.room_at(d.safe) in d.rooms.map(func(r): return r.id), "safe de %s está num cômodo dela" % d.id)
		for l in d.links:
			t.ok(Atlas.levels().has(l.to), "link de %s aponta para nível conhecido" % d.id)

func test_every_overlap_resolves_to_one_room(t) -> void:
	# amostra a cada 0,5 m dentro de cada rect, nas alturas y.x+0.1 e y.y-0.1:
	# room_at(p) devolve sempre o mesmo id que a primeira sala de rooms() que contém p
	...

func test_atlas_rooms_are_unchanged_by_the_merge(t) -> void:
	t.eq(Atlas.rooms().map(func(r): return r.id), [&"entrada", &"brincar", &"corredor", &"quarto", &"figuras", &"corredor_sul", &"beira_oeste", &"beira_sul", &"passagem", &"mecanismo", &"sotao", &"gaveta", &"loja_varela", &"oficina_varela", &"tampo_leste"], "mesma ordem de hoje")
```

O teste de ordem prende a regra de sobreposição: a torre vem antes do sótão. Ele é atualizado na Tarefa 8, quando a ordem passa a ser a do registro.

- [ ] **Step 2:** Rodar os testes. O RED esperado é `could not load` ou falha, porque `registry.gd` ainda não existe.
- [ ] **Step 3:** Implementar o `registry.gd` com `AREAS` vazio, o `atlas.rooms()` e o `levels()`, e trocar todos os leitores de `ROOMS` e `LEVELS`. No `main.gd`, `LEVEL_SAFE`, `ROOM_TASKS`, `BREAK_TASKS` e `CATALOG_TASKS` passam a ser os mapas de hoje mesclados com `Registry.safe_points()` e `Registry.merged(...)`.
- [ ] **Step 4:** Rodar os gates de unidade e de selftest, ambos com 0 falhas e a mesma contagem do selftest.
- [ ] **Step 5:** Registrar `scripts/areas/registry.gd` em `context/arquitetura.md`.
- [ ] **Step 6: Commit** `refactor: add area registry with helper contract and merged atlas`

### Tarefa 4: Migrar a passagem

**Files:** Modify `scripts/areas/passagem.gd` (ganha `const DEF`), `scripts/areas/registry.gd` (primeira linha de `AREAS`), `scripts/atlas.gd` (sai o cômodo `passagem` de `LEGACY_ROOMS` e o nível de `LEGACY_LEVELS`), `scripts/main.gd` (saem a entrada `passagem` de `LEVEL_SAFE`, as tarefas da passagem e o `preload` e a chamada de `AreaPassagem`, porque o main constrói o que está em `AREAS`).

- [ ] **Step 1:** Acrescentar a `test_registry.gd` o teste `test_passagem_def_matches_today`: `Registry.def(&"passagem").safe` é aproximadamente `Vector3(6.7, 0.2, 1.2)`, o cômodo é `Rect2(0.3, -1.3, 10.1, 1.3)` com `y` igual a `Vector2(-0.4, 2.9)`, e as tarefas e quebráveis são as que o `main.gd` tinha para ela.
- [ ] **Step 2:** Rodar o teste e ver o RED.
- [ ] **Step 3:** Escrever o `DEF` com os links para `casa` (a parede oca, com `gate` igual ao nome da quebrável) e `sotao` (a escada). Cada `path` é feito dos pontos que o selftest de hoje já percorre nessa rota. No `main._ready`, um laço `for a in Registry.AREAS: a.build(self)` entra no lugar das chamadas à mão, na mesma posição.
- [ ] **Step 4:** Rodar os gates. A unidade deve ficar verde e o selftest com a mesma contagem e 0 falhas.
- [ ] **Step 5: Commit** `refactor: move the passage into the area registry`

### Tarefa 5: Migrar o sótão e a torre

**Files:** Modify `scripts/areas/sotao.gd`; Create `scripts/areas/mecanismo.gd`; Modify `registry.gd`, `atlas.gd` e `main.gd` como na Tarefa 4.

- [ ] **Step 1:** Escrever os testes `test_sotao_def_matches_today` e `test_mecanismo_def_matches_today`. O safe dos dois é aproximadamente `Vector3(9.8, 3.14, 0.55)`, os cômodos e os `y` são os de hoje, e em `AREAS` o `mecanismo` vem **antes** do `sotao`, para a torre continuar ganhando a sobreposição.
- [ ] **Step 2:** Rodar e ver o RED.
- [ ] **Step 3:** O `mecanismo.gd` leva o `DEF` da torre e um `build` com a geometria da torre que hoje está em `sotao.gd`. Se essa geometria não se separar sem mudar a cena, o `build` fica vazio e a separação vira um `Ruling:` no ledger. Link do sótão para a torre: o alçapão, com `gate` igual ao alçapão.
- [ ] **Step 4:** Rodar os gates, com o selftest igual.
- [ ] **Step 5: Commit** `refactor: move the attic and the tower into the area registry`

### Tarefa 6: Migrar a gaveta

Tarefa igual à 4, com `scripts/areas/gaveta.gd`. Teste `test_gaveta_def_matches_today`: safe aproximadamente `Vector3(14.9, -3.0, 1.9)`, cômodo `Rect2(-1, -1, 18, 14)` com `y` igual a `Vector2(-3.6, -0.5)`. Commit: `refactor: move the drawer into the area registry`.

### Tarefa 7: Migrar o tampo (relojoaria, oficina dos fundos e bancada)

**Files:** Create `scripts/areas/tampo.gd`, que recebe os corpos de `main._build_tampo` (`main.gd:1003`) e `main._build_oficina` (`main.gd:1076`) e chama `AreaLeste.build(main)`. O `leste.gd` fica como construtor auxiliar e não entra em `AREAS`. Modify `registry.gd`, `atlas.gd` e `main.gd`.

- [ ] **Step 1:** Escrever o teste `test_tampo_def_matches_today`: os três cômodos `loja_varela`, `oficina_varela` e `tampo_leste`, nessa ordem, e o safe igual a `AreaLeste.SAFE`.
- [ ] **Step 2:** Rodar e ver o RED.
- [ ] **Step 3:** Mover o código. As referências a materiais e helpers passam a ser `main._mat`, `main._box` e assim por diante. Se um helper novo aparecer, ele entra em `HELPERS`.
- [ ] **Step 4:** Rodar os gates, com o selftest igual.
- [ ] **Step 5: Commit** `refactor: move the tabletop and the clockmaker into the area registry`

### Tarefa 8: Migrar a casa e fechar a migração

**Files:** Create `scripts/areas/casa.gd`, com `_build_house` (`main.gd:607`) e `_build_furniture` (`main.gd:756`). Modify `registry.gd` (`casa` vira a primeira de `AREAS`), `atlas.gd` (somem `LEGACY_ROOMS` e `LEGACY_LEVELS`), `main.gd` (somem os mapas fixos e `LEVEL_SAFE` vira `Registry.safe_points()`).

- [ ] **Step 1:** Escrever `test_casa_def_matches_today` (os oito cômodos de hoje e o safe igual ao `SPAWN` `Vector3(1.8, 0.2, 8.3)`) e o teste do anti-objetivo:

```gdscript
func test_main_knows_no_area_by_name(t) -> void:
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	t.ok(not src.contains("res://scripts/areas/") or src.count("res://scripts/areas/") == 1, "main só carrega o registry")
	for id in [&"passagem", &"sotao", &"gaveta", &"tampo"]:
		t.ok(not src.contains("Area%s" % String(id).capitalize()), "main não chama %s direto" % id)
```

- [ ] **Step 2:** Atualizar `test_atlas_rooms_are_unchanged_by_the_merge` para a ordem do registro: casa, passagem, mecanismo, sótão, gaveta, tampo. Ver o RED.
- [ ] **Step 3:** Mover o código e apagar os restos legados.
- [ ] **Step 4:** Rodar os gates. O selftest deve ficar igual. Se uma rota de selftest depender da ordem das abas, ajustar a rota, não o registro.
- [ ] **Step 5:** Registrar em `context/arquitetura.md` (mapa das áreas) e em `decisoes.md` como `(i)`: "migração do registro concluída; `main.gd` não conhece área por nome".
- [ ] **Step 6: Commit** `refactor: move the house into the area registry and drop the fixed maps`

### Tarefa 9: Maquetes e rota genérica no selftest

**Files:**
- Create: `scripts/maquetes/registry.gd`, `tests/test_maquetes.gd`
- Modify: `scripts/selftest.gd`, que ganha `_routes_by_links()` e perde as rotas à mão que ela cobrir

**Interfaces:** `const MAQUETES := [{"id": &"item_214", "item": 214, "name": "a casa da rua do Porto", "areas": [&"casa", &"passagem", &"mecanismo", &"sotao", &"gaveta"], "dome": Transform3D}, {"id": &"item_215", "item": 215, "name": "Relojoaria Varela", "areas": [&"tampo"], ...}, {"id": &"item_216", "item": 216, "name": "a mansão das falésias", "areas": [], ...}]`; `static func of_area(id: StringName) -> StringName`.

- [ ] **Step 1:** Escrever o teste `test_every_area_is_in_exactly_one_maquete`, que cruza `Registry.defs()` com `MAQUETES` e confere que cada `DEF.maquete` bate.
- [ ] **Step 2:** Escrever `_routes_by_links()` no selftest. Para cada link de `Registry.links()`, a rota abre o `gate` como o selftest de hoje já faz e roda `_check_segment_shape` em cada par seguido de `[safe] + path + [at]`, com a cápsula de Elias. O rótulo é `"rota %s→%s #%d"`.
- [ ] **Step 3:** Rodar o selftest. A contagem sobe e fica com 0 falhas. As rotas à mão que a nova cobre podem sair, mas o total de checks não pode cair.
- [ ] **Step 4:** Registrar `scripts/maquetes/` em `arquitetura.md`.
- [ ] **Step 5: Commit** `feat: add maquete registry and generic link routes to the selftest`

---

## 4. Fase 2 — Noites e campanha (§5)

### Tarefa 10: As noites como dados e a campanha com save

**Files:**
- Create: `scripts/story/noites.gd`, `scripts/campaign_model.gd`, `tests/test_noites.gd`, `tests/test_campaign_model.gd`
- Modify: `scripts/quest_model.gd` (`_init(phases := PHASES)`, para que a noite passe as fases dela; os testes de hoje continuam no padrão), `scripts/catalog.gd` e `scripts/atlas.gd` (`to_dict() -> Dictionary` e `from_dict(d: Dictionary) -> void`)

**Interfaces:**
- `noites.gd`:
  - `const NOITES := [...]`, com cinco entradas no formato `{"n": int, "date": String, "chapters": Array, "goals": Array[{task, area, at}], "pieces": Array, "phases": Array, "safety": StringName, "stalkers": Array[{after: StringName, n: int}], "anchor_time": float, "entry_clock_scale": float, "capture_clicks": int, "pickups": Array[StringName], "final": bool}`;
  - `const DEMO_LAST := 2`;
  - `static func get_night(n: int) -> Dictionary`;
  - `static func last() -> int`, que devolve `DEMO_LAST` quando `OS.has_feature("demo")` e 5 nos outros casos.
- Valores do spec, em `noites.gd`:
  - `capture_clicks` `[10, 12, 13, 15, 16]` (§10);
  - `anchor_time` `[90.0, 75.0, 60.0, 45.0, 30.0]` (§9.1; a queda por noite é escolha da IA);
  - `safety` `[&"casa_toda", &"relogio_entrada", &"comodos_com_luz", &"so_ancoras", &"so_ancoras"]` (§11);
  - `entry_clock_scale` 0,5 na noite 3 e 1,0 nas outras;
  - `stalkers` (§11): noite 1 `[{after:&"", n:0}, {after:&"coroa", n:1}]`, noite 2 `[{&"",1},{&"alcapao",2}]`, noites 3 e 4 com 2, noite 5 com 3;
  - `final` só na noite 5.
- As noites 3 a 5 entram **em rascunho**, com as fases e peças de hoje (gaveta e mostrador; relojoaria e caixa; a noite 5 com o gatilho de hoje: as quatro peças e `voltar`), para o fluxo completo e o final continuarem jogáveis e testados. A mansão (item 216) fica fora deste plano.
- `campaign_model.gd`:
  - `const PATH := "user://campanha.json"` e `const VERSION := 1`;
  - os campos `night: int`, `pieces: Array[StringName]`, `items: Array[StringName]`, `shortcuts: Array[String]`, `plan: Dictionary`, `catalog: Dictionary`, `visited: Dictionary` e `chapters: Dictionary`;
  - `func carry(from_night: Dictionary) -> void`, que guarda só o que passa de noite: peças, `items` (espelho, lupa, estetoscópio), atalhos, planta, catálogo e capítulos. Pilhas, fósforos e o brinquedo **não** passam (§5.1);
  - `func to_dict() -> Dictionary` e `func from_dict(d: Dictionary) -> bool`;
  - `func save(path := PATH) -> Error`;
  - `func load_or_fresh(path := PATH) -> bool`. Com o arquivo ausente, devolve false e a campanha fica na noite 1. Com o arquivo corrompido ou de versão desconhecida, devolve false, a campanha fica na noite 1 e o arquivo é renomeado para `campanha.bad.json`, sem ser apagado.

- [ ] **Step 1: Escrever os testes**

```gdscript
# test_noites.gd
func test_five_nights_with_spec_numbers(t) -> void:
	t.eq(Noites.NOITES.size(), 5, "cinco noites")
	t.eq(Noites.NOITES.map(func(n): return n.capture_clicks), [10, 12, 13, 15, 16], "cliques por noite")
	t.eq(Noites.get_night(1).safety, &"casa_toda", "noite 1 segura")
	t.ok(Noites.get_night(5).final and not Noites.get_night(2).final, "só a 5 é final")

func test_night_tasks_and_goals_exist(t) -> void:
	# toda task de goals está em phases da noite; toda area de goals está em Registry; todo
	# pickup existe num DEF; toda pista de capítulo existe em catalog_data
	...

func test_night_one_has_no_gasto_before_the_crown(t) -> void:
	t.eq(Noites.get_night(1).stalkers[0].n, 0, "nenhum Gasto antes da coroa")

# test_campaign_model.gd
func test_carry_keeps_pieces_and_drops_light(t) -> void:
	var c = Campaign.new()
	c.carry({"pieces": [&"coroa"], "items": [&"espelho", &"pilha", &"fosforo", &"brinquedo"], "shortcuts": ["Oco1"]})
	t.eq(c.pieces, [&"coroa"], "peça passa")
	t.eq(c.items, [&"espelho"], "pilha, fósforo e brinquedo não passam")

func test_save_round_trip(t) -> void:
	# save em user://test_campanha.json, load_or_fresh, to_dict() igual

func test_corrupt_save_starts_fresh_and_keeps_the_file(t) -> void:
	# escreve "{nao é json" em user://test_campanha.json
	t.eq(c.load_or_fresh("user://test_campanha.json"), false, "corrompido não carrega")
	t.eq(c.night, 1, "volta à noite 1")
	t.ok(FileAccess.file_exists("user://test_campanha.bad.json"), "o arquivo ruim é guardado")
```

- [ ] **Step 2:** Rodar e ver o RED.
- [ ] **Step 3:** Implementar. As fases das noites 1 e 2 se escrevem a partir das tarefas e capítulos do §6.2. As tarefas novas entram em `quest_model.TASKS`, com texto em rascunho (D9).
- [ ] **Step 4:** Rodar os gates: unidade com 0 falhas e o selftest igual, porque o `main` ainda não usa noites.
- [ ] **Step 5:** Registrar `scripts/story/` em `arquitetura.md`.
- [ ] **Step 6: Commit** `feat: add nights as data and the campaign save between nights`

### Tarefa 11: O estado de uma noite e o 03:33 curto (U32 adaptada)

**Files:** Modify `scripts/visit_state.gd`, `tests/test_visit_state.gd`.

**Interfaces:**
- `_init(clock_model, catalog_model, night := {})`. Com o dicionário vazio, vale o comportamento de hoje, para os testes atuais seguirem.
- `const SHORT_HOUR := 90.0`.
- `func on_goals_met() -> void`.
- `func on_ground_floor(on: bool) -> void`.
- `func is_short() -> bool`, que devolve `not night.get("final", true)`.
- `update(dt, in_bedroom, holding := false) -> StringName`. Com `holding` verdadeiro (Elias agarrado), o gate e o limite esperam.
- Regras:
  - Fora da noite final, o gate abre quando `on_goals_met` foi chamado **e** Elias está no térreo.
  - Na noite final, vale a regra de hoje (`on_pieces_ready`).
  - `MAX_PRE_HORA` continua em 3600 s nas duas.
  - O 03:33 curto termina com corda ou aos `SHORT_HOUR`, devolvendo `&"night_over"`.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_skipping_phases_reaches_the_hour_only_by_time(t) -> void:
	# noite 1, nada feito: update(3599.0) não abre o gate; update(1.0) abre (clock.can_stop)

func test_pieces_open_the_gate_at_once(t) -> void:
	# noite final: on_pieces_ready() abre o gate sem esperar

func test_goals_met_on_ground_floor_opens_at_once(t) -> void:
	# noite 1: on_ground_floor(true) antes; depois on_goals_met(): gate aberto no mesmo update

func test_goals_met_away_waits_for_the_ground_floor(t) -> void:
	# on_goals_met() no sótão: gate fechado; on_ground_floor(true): abre

func test_hard_limit_waits_for_the_capture(t) -> void:
	# elapsed passa de HARD_LIMIT com holding=true: nada; holding=false no tick seguinte: &"hora_started", uma vez só

func test_short_hour_ends_by_itself(t) -> void:
	# noite 1, hora começou: update por 90 s sem corda devolve &"night_over" uma vez
```

- [ ] **Step 2:** Rodar. Os dois primeiros testes (os da U32) passam contra o código de hoje, e a prova deles é por mutante. Os outros devem falhar.
- [ ] **Step 3:** Implementar.
- [ ] **Step 4:** Rodar os gates. Os testes antigos de `test_visit_state.gd` têm que ficar verdes sem alteração.
- [ ] **Step 5: Commit** `feat: per-night 03:33 gate with a short hour`

### Tarefa 12: O laço das noites no jogo

**Files:**
- Create: `scripts/night_card_ui.gd` (tela de papel entre noites, com a página de hipótese e a data)
- Modify: `scripts/main.gd` (`_wire_story`, `_complete`, `_track_place`, os argumentos), `scripts/hour_event.gd` (o modo curto com o eco do capítulo), `scripts/selftest.gd`

**Interfaces:**
- No `main`:
  - `var campaign`;
  - `var night: Dictionary`;
  - `func begin_night(n: int) -> void`, que recria `quest` com `night.phases`, recria `visit` com `night`, coloca Elias no `SPAWN`, aplica `campaign` (atalhos, catálogo, planta) e chama `gastos.on_night(night)`;
  - `func end_night() -> void`, que faz `campaign.carry`, `campaign.night += 1`, `save` e mostra o card. Depois do card, vem `begin_night` ou, se `n == Noites.last()`, o card de fim da demo.
- Argumento `--night N`, para começar na noite N com uma campanha limpa e sem tocar o save.
- No `hour_event.gd`, `begin(short := false)`. No modo curto, toca só o eco do capítulo da noite e não abre a escolha.
- `_track_place` chama `visit.on_ground_floor(level == &"casa" and room in térreo)`. O `_complete` chama `visit.on_goals_met()` quando a última meta da noite fecha.

- [ ] **Step 1:** Escrever os checks de selftest, rótulo `noites:`. Com `--night 1` e as metas forçadas por `_complete`, voltar ao térreo leva a `hora_started`. Corda ou 90 s levam ao card. Depois do card, `campaign.night == 2`, as peças são mantidas, pilhas e fósforos zeram e Elias está no `SPAWN`. O fluxo antigo, completo e com final, roda com `--night 5`.
- [ ] **Step 2:** Rodar e ver o RED.
- [ ] **Step 3:** Implementar. O selftest de hoje passa a rodar o final com `--night 5`, sem mudar o que ele confere.
- [ ] **Step 4:** Rodar os gates.
- [ ] **Step 5: Commit** `feat: play the game as nights with a paper card between them`

---

## 5. Fase 3 — Noite 1 jogável em blocos (§7–§11, §13)

### Tarefa 13: A casa deixa de ser refúgio fixo (segurança por ponto)

**Files:**
- Create: `scripts/safety_model.gd`, `tests/test_safety_model.gd`
- Modify: `scripts/gastos.gd` (sai `REFUGE`; `MAX := 3`; a casa ganha grafo; `wanted()` lê a noite; `func on_night(night: Dictionary) -> void`), `scripts/stalker_model.gd`

**Interfaces:**
- `safety_model.gd`:
  - `const ANCHOR_RADIUS := 4.0`;
  - `static func is_safe(point: Vector3, rule: StringName, world: Dictionary) -> bool`, com `world = {"level": StringName, "lit": bool, "entry_wound": bool, "anchors": Array[{"at": Vector3, "left": float}]}`.
- Regras (§11):
  - `casa_toda`: seguro se `level == &"casa"`;
  - `relogio_entrada`: casa e `entry_wound`;
  - `comodos_com_luz`: casa e `lit`;
  - `so_ancoras`: só os âncoras;
  - em todas as regras, o raio de um âncora com `left > 0` protege.
- `stalker_model.update(dt, seen, blind, goal, near, hidden, in_view, safe := [], elias_safe := false)`. O Gasto nunca salta para um índice em `safe` e nunca devolve `&"caught"` com `elias_safe`.
- `gastos.wanted()`: soma de `n` em `night.stalkers` para cada `after` já cumprido (o último que vale), limitada a `MAX`. Continua zero durante o 03:33 e depois da saída.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_rules_by_night(t) -> void:
	var casa := {"level": &"casa", "lit": false, "entry_wound": false, "anchors": []}
	t.ok(Safety.is_safe(Vector3.ZERO, &"casa_toda", casa), "noite 1: casa segura")
	t.ok(not Safety.is_safe(Vector3.ZERO, &"relogio_entrada", casa), "noite 2: sem corda, não")
	t.ok(Safety.is_safe(Vector3.ZERO, &"relogio_entrada", casa.merged({"entry_wound": true})), "noite 2: com corda, sim")
	t.ok(Safety.is_safe(Vector3.ZERO, &"comodos_com_luz", casa.merged({"lit": true})), "noite 3: com luz")
	t.ok(not Safety.is_safe(Vector3.ZERO, &"so_ancoras", casa.merged({"lit": true, "entry_wound": true})), "noite 4: casa não basta")

func test_anchor_radius_is_four_metres(t) -> void:
	var w := {"level": &"sotao", "lit": false, "entry_wound": false, "anchors": [{"at": Vector3.ZERO, "left": 10.0}]}
	t.ok(Safety.is_safe(Vector3(3.9, 0, 0), &"so_ancoras", w), "dentro de 4 m")
	t.ok(not Safety.is_safe(Vector3(4.1, 0, 0), &"so_ancoras", w), "fora de 4 m")
	t.ok(not Safety.is_safe(Vector3(1, 0, 0), &"so_ancoras", {"level": &"sotao", "lit": false, "entry_wound": false, "anchors": [{"at": Vector3.ZERO, "left": 0.0}]}), "sem corda não protege")

# test_stalker_model.gd
func test_never_hops_onto_a_safe_point(t) -> void:
	# linha 0-1-2, meta 2, safe [1]: update várias vezes não sai de 0
func test_never_catches_a_safe_elias(t) -> void:
	# near=true, hidden=false, elias_safe=true: nunca &"caught"
```

- [ ] **Step 2:** Rodar e ver o RED.
- [ ] **Step 3:** Implementar. Os pontos protegidos da casa são recalculados a cada `VIEW_EVERY`. O `_lit` de cada cômodo vem das luzes acesas, como o `_lit` de hoje.
- [ ] **Step 4:** Escrever os checks de selftest: com `--night 1`, `gastos.wanted() == 0` na casa antes da coroa; com `--night 4`, a casa tem grafo e `wanted() == 2`; nenhum ponto de espreita fica a menos de 1 m da porta da rua.
- [ ] **Step 5:** Rodar os gates.
- [ ] **Step 6:** Registrar a troca de `REFUGE` por segurança por ponto em `decisoes.md` como `(i)`, porque segue o §11 e o R12. A linha de 2026-10-29 sobre o refúgio já está superada em `decisoes.md` e em `rumo-2026-11.md#medo` (feito em 2026-11-08).
- [ ] **Step 7: Commit** `feat: safety by point and by night instead of a refuge level`

### Tarefa 14: Mãos e bolsos

**Files:**
- Create: `scripts/hands_model.gd`, `tests/test_hands_model.gd`
- Modify: `scripts/hands.gd` (mostra o item da mão esquerda), `scripts/player.gd` (roda do mouse, clique esquerdo, `T`), `scripts/notebook_ui.gd` (página "bolsos", desenhada a lápis)

**Interfaces:**
- `hands_model.gd`:
  - `const LEFT_ITEMS := [&"relogio", &"vareta", &"espelho", &"fosforo", &"lupa", &"estetoscopio", &"brinquedo"]`;
  - os campos `var left := &""` e `var pockets: Dictionary` (item para quantidade);
  - `func take(item: StringName, n := 1) -> void`;
  - `func hold(item: StringName) -> bool`, que guarda o que estava antes;
  - `func cycle(dir: int) -> StringName`;
  - `func can_swing() -> bool`, verdadeiro com `left` em `&""` ou `&"vareta"`, como hoje;
  - `func use_one(item: StringName) -> bool`;
  - `func toggle_watch() -> StringName`.
- No `player.gd`, o sinal `left_used(item: StringName)`, que respeita o `input_locked` como as teclas de hoje.

- [ ] **Step 1: Escrever os testes:** `test_watch_takes_the_left_hand` (com o relógio aberto, `can_swing()` é falso e `left == &"relogio"`; fechar devolve o item anterior), `test_cycle_skips_empty_pockets`, `test_matches_are_counted` (`use_one(&"fosforo")` com 0 fósforos devolve false).
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar de novo, até o verde.
- [ ] **Step 3:** Escrever o check de selftest: com o relógio na mão, `B` não emite `swung`.
- [ ] **Step 4:** Rodar os gates.
- [ ] **Step 5: Commit** `feat: one thing in the left hand and a pockets page`

### Tarefa 15: A captura com fuga

**Files:**
- Create: `scripts/capture_model.gd`, `scripts/capture_fx.gd` (câmera puxada e sacudida, piscar escuro e mãos empurrando), `tests/test_capture_model.gd`
- Modify: `scripts/gastos.gd` (`caught` passa pelo modelo), `scripts/main.gd` (`hug` só no fim em abraço), `scripts/settings_model.gd` e `settings_ui.gd`, `tests/test_settings_model.gd`

**Interfaces:**
- `capture_model.gd`:
  - `enum State { FREE, GRABBED, BROKE_FREE, HUG }`;
  - `const WINDOW := 4.0`, `const STAGGER := 2.0`, `const HOLD_TIME := 2.5`;
  - `_init(clicks_needed: int, hold_mode := false)`;
  - `func grab(gasto: int) -> bool`, que devolve false se não estiver em FREE;
  - `func push() -> void`, que conta um clique;
  - `func update(dt: float, held: bool) -> StringName`, que devolve `&"broke_free"` ou `&"hug"` uma vez e, depois do `STAGGER`, volta a FREE;
  - `func progress() -> float`, de 0 a 1;
  - `var gasto := -1`.
- No modo segurar, `held` contínuo por `HOLD_TIME` solta Elias.
- Settings: `DEFAULTS` ganha `&"reduce_flash": false` e `&"hold_to_escape": false`. Com `reduce_flash`, a frequência do piscar cai para 1 Hz e a amplitude, pela metade.
- Enquanto `GRABBED`:
  - `gastos` não atualiza nenhum modelo;
  - `player.input_locked` fica verdadeiro, mas o clique esquerdo chega a `push`;
  - o caderno fecha.
- `BROKE_FREE` chama `stalker.hit()` no Gasto e manda `pocket_watch.lose_spring()`.
- A captura roda em `_process` e, por isso, fica parada com a árvore pausada.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_ten_clicks_in_four_seconds_break_free(t) -> void:
	var c = Capture.new(10)
	t.ok(c.grab(0), "agarra")
	for i in 10:
		c.push(); c.update(0.3, false)
	t.eq(c.update(0.0, false), &"broke_free", "soltou com 10 cliques em 3 s")

func test_too_few_clicks_end_in_a_hug(t) -> void:
	var c = Capture.new(10); c.grab(0)
	for i in 9: c.push()
	t.eq(c.update(4.01, false), &"hug", "9 cliques e 4 s: abraço")

func test_second_grab_is_ignored(t) -> void:
	var c = Capture.new(10); c.grab(0)
	t.ok(not c.grab(1), "uma luta só"); t.eq(c.gasto, 0, "o primeiro Gasto fica")

func test_hold_mode_breaks_free_by_holding(t) -> void:
	var c = Capture.new(16, true); c.grab(0)
	t.eq(c.update(2.6, true), &"broke_free", "segurar 2,5 s solta")

func test_stagger_returns_to_free(t) -> void:
	# depois de broke_free, update(2.0) volta a FREE e grab() aceita de novo

# test_settings_model.gd
func test_accessibility_defaults(t) -> void:
	t.eq(S.new().get_value(&"reduce_flash"), false, "reduzir piscar começa desligado")
	t.eq(S.new().get_value(&"hold_to_escape"), false, "segurar começa desligado")
```

- [ ] **Step 2:** Rodar, ver o RED e implementar o modelo e as opções.
- [ ] **Step 3:** Ligar no jogo. O `capture_fx.gd` pisca a no máximo 2,5 Hz, com a cor mais clara em `Color(0.75, 0.72, 0.66)`, nunca branco cheio. A porcelana estalando passa pelo `sfx_bank` com pico ≤ 0,5.
- [ ] **Step 4:** Escrever os checks de selftest, rótulo `capture:`:
  - um Gasto forçado em `near` dá `GRABBED`;
  - com o caderno aberto, a captura fecha o caderno;
  - **Esc pausa a luta:** pausar a árvore por 300 frames e despausar deixa o estado ainda em `GRABBED`;
  - 9 cliques terminam em `hug` e no respawn de hoje.
- [ ] **Step 5:** Rodar os gates.
- [ ] **Step 6: Commit** `feat: break free from a Gasto by clicking, with accessible options`

### Tarefa 16: O modelo da bússola

**Files:** Create `scripts/compass_model.gd`, `tests/test_compass_model.gd`.

**Interfaces:**
- `static func route(from: StringName, to: StringName, links: Array) -> Array`, que devolve a lista de links do caminho mais curto por BFS. Os links valem nos dois sentidos e os fechados também contam.
- `static func aim(pos: Vector3, area: StringName, goal: Dictionary, links: Array) -> Dictionary`, que devolve `{"mode": &"point", "at": Vector3, "tilt": int}` ou `{"mode": &"spin"}`. O `tilt` vale -1, 0 ou 1, conforme o primeiro link desce, fica no mesmo nível ou sobe.
- `static func tick_period(distance: float) -> float`: 1,0 s a 25 m ou mais, 0,25 s a 2 m ou menos, linear entre os dois.
- `const TREMBLE_RADIUS := 6.0` e `static func trembles(nearest_gasto: float) -> bool`.
- `const HEARD_RADIUS := 3.0`: o raio em que os Gastos ouvem o tique.

- [ ] **Step 1: Escrever os testes**

```gdscript
const LINKS := [{"from": &"casa", "to": &"passagem", "at": Vector3(1, 0, 0), "gate": &"oco"}, {"from": &"passagem", "to": &"sotao", "at": Vector3(5, 3, 0), "gate": &""}]

func test_same_area_points_straight(t) -> void:
	var a := Compass.aim(Vector3.ZERO, &"casa", {"area": &"casa", "at": Vector3(3, 0, 4)}, LINKS)
	t.eq(a.mode, &"point", "aponta"); t.eq(a.at, Vector3(3, 0, 4), "direto na meta")

func test_other_area_points_at_the_first_link(t) -> void:
	var a := Compass.aim(Vector3.ZERO, &"casa", {"area": &"sotao", "at": Vector3(9, 3, 0)}, LINKS)
	t.eq(a.at, Vector3(1, 0, 0), "primeiro link do caminho")

func test_closed_link_still_routes(t) -> void:
	t.eq(Compass.route(&"casa", &"sotao", LINKS).size(), 2, "o oco fechado conta")

func test_links_work_both_ways(t) -> void:
	t.eq(Compass.route(&"sotao", &"casa", LINKS).size(), 2, "volta pelo mesmo caminho")

func test_outside_any_room_spins(t) -> void:
	t.eq(Compass.aim(Vector3.ZERO, &"", {"area": &"casa", "at": Vector3.ONE}, LINKS).mode, &"spin", "fora de área: gira")
	t.eq(Compass.aim(Vector3.ZERO, &"casa", {"area": &"gaveta", "at": Vector3.ONE}, LINKS).mode, &"spin", "sem caminho: gira")

func test_tick_and_tremble(t) -> void:
	t.near(Compass.tick_period(30.0), 1.0, 0.001, "longe: 1 s")
	t.near(Compass.tick_period(1.0), 0.25, 0.001, "perto: 0,25 s")
	t.ok(Compass.trembles(5.9) and not Compass.trembles(6.1), "treme abaixo de 6 m")
```

- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar de novo, até o verde.
- [ ] **Step 3: Commit** `feat: compass model routes through area links`

### Tarefa 17: O relógio de Elias na mão, e a apresentação da noite 1

**Files:**
- Create: `scripts/pocket_watch.gd`, um nó na mão esquerda, em blocos por enquanto (o asset vem na Tarefa 35)
- Modify: `scripts/main.gd` (o começo da noite 1, pelo §7.3), `scripts/gastos.gd` (o tique do relógio é um ruído, ver a Tarefa 20), `scripts/catalog_data.gd` (a carta)

**Interfaces:**
- `func open() -> void` e `func close() -> void`.
- `func set_goal(goal: Dictionary) -> void`.
- `func lose_spring() -> void`, que deixa o tique 30% mais lento até a próxima noite.
- `var is_open := false`.
- A cada frame, o ponteiro usa `Compass.aim` com `Registry.links()` e a área de `atlas.level_of(atlas.room_at(pos))`. A meta é a primeira de `night.goals` que ainda não foi cumprida.
- O ponteiro gira devagar, a 0,5 volta por segundo, no modo `spin`. Treme com um Gasto a menos de 6 m. Nunca marca nada na tela.

**Sequência da noite 1** (§7.3):
- a carta chega à mão, com o texto exato: "O relógio que segue com esta carta sabe onde estão as partes do outro. Abra-o quando não souber para onde ir.";
- o tique no bolso fica fora de compasso com o relógio da entrada;
- as luzes da entrada piscam e só fica a do quarto de brincar;
- a primeira meta é catalogar o desenho do menino.

- [ ] **Step 1:** Escrever os checks de selftest, rótulo `bussola:`:
  - com `--night 1`, `T` abre o relógio e a mira aponta para o quarto de brincar, com ângulo menor que 10° em relação ao desenho;
  - com a meta no sótão e Elias na casa, a mira aponta para o link da passagem;
  - na beira oeste, a mira está em `spin`;
  - a cena não ganha nenhum nó de marcador.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3:** Fazer uma captura `--shot-watch` para a D7.
- [ ] **Step 4: Commit** `feat: Elias's pocket watch points the way, introduced on night one`

### Tarefa 18: A planta com névoa e anotações, sem pausa

**Files:**
- Create: `scripts/fog_grid.gd`, `scripts/plan_model.gd`, `scripts/plan_revealer.gd`, `tests/test_fog_grid.gd`, `tests/test_plan_model.gd`
- Modify: `scripts/notebook_ui.gd` (desenho da planta: névoa, anotações e a seta do olhar; uma aba por área na ordem do registro, abrindo na área atual; o caderno não pausa)

**Interfaces:**
- `fog_grid.gd`:
  - `const CELL := 0.5`;
  - `_init(rect: Rect2)`;
  - `func reveal(p: Vector2) -> bool`, que devolve verdadeiro se a célula era nova;
  - `func seen(p: Vector2) -> bool`;
  - `func count() -> int`;
  - `func to_bytes() -> PackedByteArray` e `func from_bytes(b: PackedByteArray) -> bool`.
- `plan_model.gd`:
  - `func fog(level: StringName) -> FogGrid`, que cria a grade sobre a união dos rects dos cômodos do nível;
  - `func note(level: StringName, at: Vector3, kind: StringName, label: String, time: float) -> void`, com os tipos `&"gasto"`, `&"item"`, `&"barricada"`, `&"ancora"` e `&"giz"`;
  - `func notes_on(level: StringName) -> Array`;
  - `func forget_item(id: StringName) -> void`, quando o item é pego;
  - `func to_dict() -> Dictionary` e `func from_dict(d: Dictionary) -> void`.
- `plan_revealer.gd`: a 4 Hz, lança 9 raios no cone da câmera até 6 m (ou até o alcance da lanterna acesa, se for menor). Cada ponto ao longo do raio revela a sua célula. Também registra as anotações automáticas de Gasto visto, item visto e item não pego.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_drawer_grid_is_about_a_thousand_cells(t) -> void:
	var g = Fog.new(Rect2(-1, -1, 18, 14))
	t.eq(g.to_bytes().size(), ceili(36 * 28 / 8.0), "1008 células em bits")

func test_reveal_round_trip(t) -> void:
	var g = Fog.new(Rect2(0, 0, 4, 4))
	t.ok(g.reveal(Vector2(1.2, 1.2)), "nova"); t.ok(not g.reveal(Vector2(1.3, 1.4)), "mesma célula de 0,5 m")
	var h = Fog.new(Rect2(0, 0, 4, 4)); h.from_bytes(g.to_bytes())
	t.ok(h.seen(Vector2(1.2, 1.2)) and h.count() == 1, "volta igual do save")

func test_outside_rect_is_ignored(t) -> void:
	t.ok(not Fog.new(Rect2(0, 0, 4, 4)).reveal(Vector2(9, 9)), "fora do nível não quebra")

func test_picked_item_note_disappears(t) -> void:
	# note(&"casa", p, &"item", "pilha", 12.0) com id; forget_item → notes_on vazio
```

- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar de novo, até o verde.
- [ ] **Step 3:** No `notebook_ui.gd`, o caderno aberto continua travando Elias (`_set_locked`), mas o jogo não pausa. Escrever o check de selftest `planta: o mundo anda com o caderno aberto`: com `M` aberto, um Gasto forçado ainda salta e `visit.elapsed` avança. Escrever também o check da aba inicial igual à área atual.
- [ ] **Step 4:** Ligar `campaign.plan` com `plan_model.to_dict`. Rodar os gates.
- [ ] **Step 5: Commit** `feat: live plan with per-cell fog and pencil notes`

### Tarefa 19: Luz escassa

**Files:**
- Create: `scripts/light_model.gd`, `tests/test_light_model.gd`
- Modify: `scripts/player.gd` (a lanterna gasta pilha), `scripts/main.gd` (pickups dos `DEF` ativos pela noite; velas e lamparinas acendíveis), os `DEF` da casa e da passagem (`pickups`)

**Interfaces:**
- `light_model.gd`:
  - `const BATTERY := 240.0` (cerca de 4 min), `const MATCH := 20.0`, `const CANDLE := 120.0`, `const LOW := 30.0` (o tempo em que a lanterna pisca);
  - `var battery := BATTERY` e `var spare := 0`;
  - `func drain(dt: float, on: bool) -> StringName`, que devolve `&"low"` ao cruzar `LOW` e `&"dead"` ao zerar. Com reserva, ela entra sozinha e devolve `&"swapped"`;
  - `func strike() -> bool`, que acende um fósforo de `MATCH` s e gasta do `hands_model`;
  - `func flicker(t: float) -> float`, um multiplicador de energia;
  - `static func route_seconds(night: Dictionary) -> float`, a soma da luz disponível na rota (pilha inicial, pickups da noite e fósforos).
- A luz das velas acesas entra nas lâmpadas de `gastos._lit` e no `lit` da segurança.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_battery_lasts_four_minutes(t) -> void:
	var l = Light.new()
	t.eq(l.drain(209.9, true), &"", "ainda não"); t.eq(l.drain(0.2, true), &"low", "últimos 30 s piscam")
	t.eq(l.drain(30.0, true), &"dead", "acabou")

func test_spare_swaps_in(t) -> void:
	var l = Light.new(); l.spare = 1
	t.eq(l.drain(240.1, true), &"swapped", "troca sozinha"); t.near(l.battery, 239.9, 0.01, "pilha nova")

func test_off_does_not_drain(t) -> void:
	var l = Light.new(); l.drain(100.0, false); t.near(l.battery, 240.0, 0.001, "desligada não gasta")

func test_every_night_route_has_enough_light(t) -> void:
	for n in [1, 2]:
		t.ok(Light.route_seconds(Noites.get_night(n)) >= 0.6 * 50 * 60, "noite %d: luz para 60%% de 50 min" % n)
```

- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar de novo, até o verde. Se a noite não tiver luz que baste, o ajuste é nos `pickups` dos `DEF`, não no teste.
- [ ] **Step 3:** Escrever o check de selftest: os fósforos acendem uma vela do quarto de brincar e ela entra em `gastos._lamps`.
- [ ] **Step 4:** Rodar os gates.
- [ ] **Step 5: Commit** `feat: scarce light with batteries, matches and candles`

### Tarefa 20: Ruído, esconderijo e respiração

**Files:**
- Create: `scripts/noise_model.gd`, `tests/test_noise_model.gd`
- Modify: `scripts/gastos.gd` (`func hear(at: Vector3, level: int) -> void`; `_goal()` prefere o último ruído ouvido por `NOISE_MEMORY`), `scripts/player.gd` (o ruído dos passos e o `H`), `scripts/stalker_model.gd` (`HIDE_FOUND`)

**Interfaces:**
- `noise_model.gd`:
  - `enum Level { QUIET, NORMAL, LOUD }` e `const RADIUS := [1.5, 5.0, 10.0]`;
  - `const NOISE_MEMORY := 10.0`;
  - `static func heard(src: Vector3, ear: Vector3, level: int) -> bool`;
  - `const BREATH_MAX := 8.0` e `const BREATH_REST := 4.0`;
  - `func breath(dt: float, pressed: bool) -> StringName`, que devolve `&"gasp"` ao passar de 8 s. O ofego é um ruído LOUD na posição de Elias;
  - `var holding := false`.
- Níveis de ruído: agachado é QUIET; andar é NORMAL; correr, consertar, dar corda e a vareta são LOUD; o tique do relógio aberto é QUIET, com raio de 3 m (`Compass.HEARD_RADIUS`).
- No `stalker_model`, entra `const HIDE_FOUND := 3.0`. No esconderijo sem prender a respiração, um Gasto perto encontra Elias em 3 s. Prendendo a respiração, vale o `HIDE_GIVE_UP` de hoje, de 8 s, e o Gasto desiste.

- [ ] **Step 1: Escrever os testes:**
  - `test_three_noise_radii`: `heard` vale para 1,4 m em QUIET e não para 1,6 m; vale para 9,9 m em LOUD;
  - `test_breath_gasps_after_eight_seconds`: 7,9 s devolvem `&""` e 8,1 s devolvem `&"gasp"`; dentro do descanso de 4 s, `pressed` não prende;
  - `test_hidden_without_breath_is_found` (em `test_stalker_model.gd`): `near` e `hidden` sem respiração dão `&"caught"` depois de `HIDE_FOUND`;
  - `test_hidden_with_breath_waits_and_gives_up`: o Gasto desiste em 8 s.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar de novo, até o verde. Os testes de hoje de `HIDE_GIVE_UP` devem seguir válidos para o caso com respiração. Se a assinatura precisar de `breath_held`, ele entra como parâmetro com padrão `true`, para não quebrá-los.
- [ ] **Step 3:** Escrever o check de selftest: correr a 8 m de um Gasto muda o objetivo dele para o ponto mais perto do ruído.
- [ ] **Step 4:** Rodar os gates.
- [ ] **Step 5: Commit** `feat: three noise levels, hearing Gastos and holding the breath`

### Tarefa 21: O giz

**Files:** Modify `scripts/player.gd` (`G`), `scripts/main.gd` (a marca de Elias: um quad de giz na parede, pelo helper `_chalk`), os `DEF` (`chalk`: as trilhas do menino, `[{"id", "points": Array[Vector3], "leads_to": StringName}]`), `scripts/plan_model.gd` (nota `&"giz"`). Test: `tests/test_plan_model.gd`.

**Interfaces:**
- `const MAX_MARKS := 20`; com a vigésima primeira marca, a mais antiga se apaga.
- A marca só pega numa parede a até 2 m pelo raio de olhar.
- As marcas passam de noite pela planta.

- [ ] **Step 1:** Escrever o teste `test_chalk_marks_keep_the_last_twenty`: depois de 21 notas `&"giz"`, ficam 20 e a primeira sai.
- [ ] **Step 2:** Escrever o check de selftest: cada trilha `chalk` dos `DEF` da noite 1 termina a menos de 1,5 m do seu `leads_to` (um pickup ou um alvo de catálogo).
- [ ] **Step 3:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 4: Commit** `feat: chalk marks on walls and the boy's chalk trails`

### Tarefa 22: Escutar pela parede

**Files:**
- Create: `scripts/listen_model.gd`, `tests/test_listen_model.gd`
- Modify: `scripts/player.gd` (segurar `L` a até 0,9 m de uma parede), `scripts/gastos.gd` (posição dos Gastos para o som), `scripts/sfx_bank.gd` (estalo de porcelana abafado)

**Interfaces:**
- `const EAR_RANGE := 12.0`, `const SCOPE_RANGE := 25.0`, `const FLOOR_BAND := 2.5`.
- `static func audible(gasto: Vector3, ear: Vector3, scope: bool) -> bool`. Sem o estetoscópio, vale só com `|dy| < FLOOR_BAND`; com ele, vale através dos pisos.
- Enquanto escuta, o bus de efeitos cai 18 dB e cada Gasto audível toca um estalo posicional a cada 1,5 s. Elias fica parado.

- [ ] **Step 1:** Escrever os testes `test_ear_hears_the_same_floor_only` e `test_stethoscope_hears_through_floors` (a 20 m e 3 m acima: falso sem o estetoscópio, verdadeiro com ele).
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3: Commit** `feat: listen through walls for the Gastos`

### Tarefa 23: Capítulos: pistas, encenação e hipótese (capítulos 1 e 2)

**Files:**
- Create: `scripts/staging_model.gd`, `scripts/chapter_model.gd`, `tests/test_staging_model.gd`, `tests/test_chapter_model.gd`
- Modify: `scripts/notebook_ui.gd` (página de hipótese com três frases), `scripts/story/noites.gd` (capítulos 1 e 2), `scripts/catalog_data.gd` (as pistas novas), `scripts/areas/casa.gd` e `passagem.gd` (figuras com poses e a peça no fim da encenação), `scripts/main.gd` (liga o `cataloged`)

**Interfaces:**
- `staging_model.gd`:
  - `const UNSEEN := 1.5`;
  - `_init(poses: int)`;
  - `func update(dt: float, seen: bool) -> bool`, que devolve verdadeiro quando avança uma pose;
  - `var pose := 0`;
  - `func done() -> bool`.
- `chapter_model.gd`:
  - `_init(def: Dictionary)`, com o capítulo de `noites.gd`: `{"id", "area", "title", "clues": Array[StringName], "poses": int, "hypothesis": Array[String], "right": int, "reward": StringName}`;
  - `func on_cataloged(item: StringName) -> bool`, que devolve verdadeiro quando a última pista fecha;
  - `var staging`;
  - `func choose(i: int) -> bool`;
  - `func page() -> Dictionary`, com `{"lines", "chosen", "crossed": Array[int]}`.
- A frase errada fica riscada e pode-se tentar de novo. A encenação continua lá para ser revista.
- Conteúdo, em rascunho (D9): capítulo 1, *A casa da rua do Porto* (fragmento 2), com o desenho do menino como primeira pista; capítulo 2, *O menino que escutava*, que termina na coroa. O texto é o mínimo e só aparece em papel.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_poses_advance_only_unseen(t) -> void:
	var s = Staging.new(4)
	t.ok(not s.update(5.0, true), "olhando, não anda")
	t.ok(not s.update(1.4, false), "1,4 s fora da vista, não")
	t.ok(s.update(0.2, false), "1,5 s fora da vista, anda"); t.eq(s.pose, 1, "uma pose")

func test_staging_stops_at_the_last_pose(t) -> void:
	# 10 ciclos de 1,6 s fora da vista com 4 poses: pose == 3 e done()

func test_chapter_opens_when_all_clues_are_in(t) -> void:
	# clues [a, b, c]: on_cataloged(a) e (b) falsos, (c) verdadeiro; repetir (a) não reabre

func test_wrong_hypothesis_is_crossed_and_retried(t) -> void:
	# right = 2: choose(0) falso, page().crossed == [0]; choose(2) verdadeiro, chosen == 2
```

- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar de novo, até o verde.
- [ ] **Step 3:** Escrever o check de selftest, rótulo `capitulo:`: com `--night 1`, catalogar as pistas do capítulo 1 libera a encenação; virar a câmera para longe por 1,6 s quatro vezes leva a encenação até o fim; e a meta seguinte da bússola passa a ser a passagem.
- [ ] **Step 4:** Rodar os gates.
- [ ] **Step 5: Commit** `feat: chapters with clues, a staged scene and a hypothesis page`

### Tarefa 24: O diretor de sustos

**Files:** Create `scripts/scare_director.gd`, `tests/test_scare_director.gd`; Modify `scripts/dread.gd` (pede os sustos ao diretor, sem tocá-los direto).

**Interfaces:**
- `const STRONG_GAP := 60.0`, `const WEAK_GAP := 20.0`, `const QUIET_BEFORE := 8.0`.
- `const KINDS := [&"lampada", &"pose", &"caixa_musica", &"tique_para", &"duplo_espelho", &"pancadas", &"lanterna_pisca"]`.
- `func update(dt: float, loud_now: bool) -> void`.
- `func request(kind: StringName, strong: bool, tension: float) -> bool`. Devolve falso quando:
  - durante o 03:33;
  - com um susto forte há menos de 60 s;
  - sem 8 s de silêncio antes;
  - com o mesmo tipo já usado nesta noite, se for forte.
- `func set_hour(active: bool) -> void`.
- Volume: nenhum susto passa do pico 0,5 do `sfx_bank` (D10, sem estouro).

- [ ] **Step 1:** Escrever os testes:
  - `test_one_strong_scare_per_minute` (o segundo pedido aos 59 s é negado e aos 61 s é aceito);
  - `test_needs_quiet_before`;
  - `test_never_during_the_hour`;
  - `test_same_strong_kind_once_per_night`.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3: Commit** `feat: a scare director that keeps silence between scares`

---

## 6. Fase 4 — Primeiro playtest (U50–U52)

### Tarefa 25: Registro de playtest e roteiro

**Files:**
- Create: `scripts/lost_model.gd`, `scripts/playtest_log.gd`, `tests/test_lost_model.gd`, `context/discussoes/playtest-1.md` (o roteiro)
- Modify: `scripts/main.gd` (argumento `--playtest`)

**Interfaces:**
- `lost_model.gd`:
  - `const LOST_AFTER := 180.0` e `const PROGRESS := 2.0`;
  - `func update(dt: float, goal_distance: float, goal_id: StringName) -> bool`. Devolve verdadeiro no tick em que passam 180 s sem a distância até a meta cair 2 m abaixo do melhor valor e sem a meta mudar.
- `playtest_log.gd`: grava a cada 5 s em `user://playtest/<data-hora>.csv` as colunas `t, noite, area, comodo, meta, dist, relogio_aberto, caderno_aberto, capturas, perdido`. Só fica ativo com `--playtest`.

- [ ] **Step 1:** Escrever os testes `test_lost_after_three_minutes_without_progress` e `test_new_goal_resets_the_clock`.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3:** Escrever o roteiro: o que observar (o primeiro uso do relógio, onde a pessoa se perde, o medo dito em voz alta, o tempo da noite 1); nenhuma instrução além da carta; as perguntas finais.
- [ ] **Step 4:** Gerar o binário Linux com `--export-release "Linux" build/linux/Janghyang` e rodar `--selftest` nele.
- [ ] **Step 5: Commit** `feat: playtest log that marks three minutes lost`

### Tarefa 26: Sessões do playtest 1 (humanos, D12)

- [ ] Pedro conduz de 3 a 5 sessões da noite 1, com `--playtest`.
- [ ] Copiar os CSVs para `fontes/2027-01-XX-playtest-1-<pessoa>.csv` e as notas de Pedro para `fontes/`, sem interpretação.
- [ ] Registrar em `historico.md` quem jogou (sem nome: P1, P2, …), as datas e as durações.

### Tarefa 27: Triagem do playtest 1

- [ ] Cada achado vai para `achados.md` com severidade, repro e fix.
- [ ] Verificar o critério do §15 nos CSVs, com `perdido == true` sendo zero, e os anti-objetivos do §17: a bússola resolve tudo? Os Gastos viraram inimigo de ação?
- [ ] O que muda número (§9, §10, §11) é `(i)`. O que muda regra de jogo vai para Pedro como `(d)`.
- [ ] As correções viram tarefas inseridas antes da Tarefa 28, com o mesmo formato.

---

## 7. Fase 5 — Noite 2 com as outras ações (§9, §6.2)

### Tarefa 28: Relógios-âncora

**Files:** Create `scripts/anchor_model.gd`, `tests/test_anchor_model.gd`. Modify os `DEF` do sótão e da torre (`anchors`), `scripts/main.gd` (o nó do âncora; segurar `E`), `scripts/gastos.gd` (âncoras no `world` da segurança), `scripts/plan_model.gd` (nota `&"ancora"`).

**Interfaces:**
- `const WIND_HOLD := 2.0` e `const RADIUS := 4.0`.
- `_init(duration: float)`, com o `anchor_time` da noite.
- `func hold(dt: float, pressed: bool) -> StringName`, que devolve `&"wound"` aos 2 s; soltar antes zera.
- `func update(dt: float) -> void`.
- `func left() -> float`.
- `func memory() -> StringName`: `&"cheia"` acima de 2/3, `&"metade"` acima de 1/3, `&"quase_nada"` acima de 0 e `&""` em zero.
- Dar corda é um ruído LOUD.
- Na noite 2, o relógio da entrada é o âncora da casa, pela regra `relogio_entrada`, e usa o `wind_clock_model` de hoje.

- [ ] **Step 1:** Escrever os testes:
  - `test_wind_takes_two_seconds_of_holding` (1,9 s de segurar e soltar não dão corda);
  - `test_lasts_the_night_time` (com `duration` 75, `left()` está perto de 0 depois de 75 s);
  - `test_memory_thirds`.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3:** Escrever o check de selftest: com `--night 2` e um âncora com corda no sótão, nenhum ponto de espreita a menos de 4 m dele recebe um Gasto.
- [ ] **Step 4: Commit** `feat: wind-up anchor clocks that keep Gastos away`

### Tarefa 29: Consertar mecanismos

**Files:** Create `scripts/repair_model.gd`, `tests/test_repair_model.gd`. Modify o `DEF` da torre (`mechanisms`: o elevador da torre, com a engrenagem como peça, e o link que ele abre como `gate`), `scripts/main.gd`.

**Interfaces:**
- `_init(part: StringName, turn_time := 3.0)`.
- `func insert(has_part: bool) -> bool`.
- `func turn(dt: float, pressed: bool) -> StringName`, que devolve `&"engaged"` uma vez.
- `var fitted := false`.
- Girar é LOUD a cada 0,5 s.
- O link com `gate` igual ao mecanismo abre quando ele engrena e fica em `campaign.shortcuts`.

- [ ] **Step 1:** Escrever os testes `test_needs_the_part`, `test_engages_after_turning` e `test_engaged_stays_engaged`.
- [ ] **Step 2:** Escrever o check de selftest: a rota do sótão até a torre passa pelo elevador depois do conserto, pela rota genérica da Tarefa 9.
- [ ] **Step 3:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 4: Commit** `feat: repair stopped mechanisms with a found part`

### Tarefa 30: A lupa

**Files:** Modify `scripts/catalog_data.gd` (o campo opcional `"lupa": String` nos itens), `scripts/catalog.gd` (`func magnify(item: StringName) -> String`, que só vale para item catalogado e acrescenta a linha à entrada uma vez), `tests/test_catalog.gd`, `scripts/notebook_ui.gd` (o texto aparece na entrada, a lápis), `scripts/main.gd` (o clique com a lupa num alvo a até 1,5 m). Uma pista do capítulo 3 exige a lupa: `{"item", "lupa": true}` em `clues`.

- [ ] **Step 1:** Escrever os testes `test_magnify_needs_the_item_cataloged` e `test_magnify_adds_its_line_once`.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3: Commit** `feat: the loupe copies hidden details into the notebook`

### Tarefa 31: O espelho de mão

**Files:** Create `scripts/hand_mirror.gd` (uma `SubViewport` com câmera virada para trás, desenhada num quad na mão esquerda). Modify `scripts/main.gd` (`is_seen` também vale pela câmera do espelho erguido), `scripts/gastos.gd` (visto pelo espelho conta como visto, mas não como luz, então não desfaz o Gasto), `scripts/scare_director.gd` (`duplo_espelho`).

- [ ] **Step 1:** Escrever os checks de selftest, rótulo `espelho:`:
  - com um Gasto forçado atrás de Elias e o espelho erguido, o Gasto não salta;
  - o `stare` dele não cresce;
  - com o espelho baixado, ele salta.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3:** Medir o fps no `--tour`, com e sem o espelho. Se a queda passar de 20%, a `SubViewport` cai para 256×256.
- [ ] **Step 4: Commit** `feat: a hand mirror that holds Gastos without undoing them`

### Tarefa 32: Barricar portas internas (sai antes se faltar tempo, D11)

**Files:** Create `scripts/barricade_model.gd`, `tests/test_barricade_model.gd`. Modify `scripts/stalker_model.gd` (`func block(a: int, b: int, on: bool) -> void`; `next_toward` ignora links bloqueados), `scripts/gastos.gd` (os links cujo segmento cruza a porta barricada), `scripts/main.gd` (segurar `E` numa porta interna com um móvel a até 2 m).

**Interfaces:**
- `const HOLD := 30.0` e `const FRONT_DOOR := &"porta_rua"`.
- `static func can_barricade(door: StringName) -> bool`.
- `func update(dt: float, pounding: bool) -> StringName`, que devolve `&"gave_way"` aos 30 s de pancadas.
- As pancadas são audíveis: o susto `pancadas` passa pelo diretor.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_front_door_never_barricades(t) -> void:
	t.ok(not Barricade.can_barricade(&"porta_rua"), "a porta da rua nunca")

func test_gives_way_after_thirty_seconds_of_pounding(t) -> void:
	var b = Barricade.new()
	t.eq(b.update(29.9, true), &"", "ainda segura"); t.eq(b.update(0.2, true), &"gave_way", "cede")

func test_quiet_door_does_not_wear(t) -> void:
	# update(100, false) não cede

# test_stalker_model.gd
func test_blocked_link_is_not_walked(t) -> void:
	# linha 0-1-2, block(1,2,true): de 0 a meta 2, fica em 1
```

- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3: Commit** `feat: barricade inner doors for a while; the front door never`

### Tarefa 33: O brinquedo de corda como isca (sai antes se faltar tempo, D11)

**Files:** Create `scripts/lure_model.gd`, `scripts/wind_toy.gd`, `tests/test_lure_model.gd`. Modify `scripts/gastos.gd` (o ruído do brinquedo passa por `hear`).

**Interfaces:**
- `const RUN_TIME := 15.0`, `const SPEED := 0.6` e `const NOISE_EVERY := 1.0`.
- `func release(at: Vector3, dir: Vector3) -> void`.
- `func update(dt: float) -> Array`, que devolve os pontos de ruído LOUD emitidos neste tick.
- `func is_running() -> bool`.
- Recuperar o brinquedo com `E` o devolve aos bolsos. Ele não passa de noite.

- [ ] **Step 1:** Escrever os testes `test_runs_fifteen_seconds` e `test_noise_once_a_second`, e o check de selftest: com o brinquedo solto a 6 m, o objetivo do Gasto vai até ele.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3: Commit** `feat: wind-up toy lures Gastos away`

### Tarefa 34: A noite 2: capítulos 3 e 4, a torre e o gancho

**Files:** Modify `scripts/story/noites.gd` (capítulos 3, *Os lençóis*, e 4, *A hora marcada*, com o fragmento 1, em rascunho D9), os `DEF` e builds do sótão e da torre (figuras e poses; o estetoscópio no sótão; o alçapão; os ponteiros no fim da encenação), `scripts/hour_event.gd` (o eco curto da noite 2), `scripts/main.gd` (do alto da torre, a janela mostra o Elias gigante na bancada, `_build_giant_elias`), `scripts/double_writer.gd` (o duplo escreve a partir da noite 2).

- [ ] **Step 1:** Escrever os checks de selftest, rótulo `noite2:`:
  - com `--night 2`, a sequência inteira fecha por `_complete`: pistas do capítulo 3, alçapão, conserto, pistas do capítulo 4, ponteiros, térreo, 03:33 curto e o card de fim da demo com `OS.has_feature("demo")` simulado;
  - um raio do alto da torre até a cabeça do Elias gigante passa sem obstáculo.
- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3:** Jogar as noites 1 e 2 de ponta a ponta com o `--tour` estendido e registrar a duração. O alvo do §15 é de 60 a 90 min para um jogador novo. A IA mede o caminho mínimo e registra no ledger.
- [ ] **Step 4: Commit** `feat: night two with the attic and tower chapters`

---

## 8. Fase 6 — Assets de maquete (§14)

### Tarefa 35: O fluxo de assets e o teste de licenças

**Files:**
- Create: `arte/fontes/.gitkeep`, `arte/blender/_common.py` (abrir de um caminho, aplicar o material de maquete, exportar `.glb`), `Janghyang/assets/LICENCAS.md`, `Janghyang/scripts/asset_loader.gd`, `Janghyang/tests/test_licencas.gd`, `Janghyang/tests/test_asset_loader.gd`
- Modify: `scripts/main.gd` (`--shot-compat`)

**Interfaces:**
- `asset_loader.gd`: `static func instance_or(path: String, fallback: Callable) -> Node3D`. Se o recurso não existir ou não carregar, devolve `fallback.call()`.
- `LICENCAS.md` é uma tabela Markdown com as colunas `arquivo | origem | autor | licença | data | edição`, e a licença em `{CC0, próprio}`.

- [ ] **Step 1: Escrever os testes**

```gdscript
func test_every_asset_has_a_license_line(t) -> void:
	# percorre res://assets/ recursivo, ignorando .import, .uid e LICENCAS.md;
	# cada caminho relativo aparece na coluna arquivo, e a licença é CC0 ou próprio

func test_missing_asset_falls_back(t) -> void:
	var n = Loader.instance_or("res://assets/models/nao_existe.glb", func(): var b := Node3D.new(); b.name = "Bloco"; return b)
	t.eq(n.name, "Bloco", "cai para o bloco"); n.free()
```

- [ ] **Step 2:** Rodar, ver o RED, implementar e rodar os gates.
- [ ] **Step 3:** Verificar o renderer (§14.3). O `--shot-compat` monta uma cena com `Decal`, `LightmapGI` assado e SSAO ligado, em Compatibility no Godot 4.7.2. Registrar em `context/arquitetura.md`, como `(e)`, o que funciona e o que não aparece, com a captura em `fontes/`.
- [ ] **Step 4:** Registrar `arte/` em `arquitetura.md`.
- [ ] **Step 5: Commit** `build: add the asset pipeline, license check and block fallback`

### Tarefas 36 a 40: Os assets prioritários (§14.4)

Cada tarefa segue o mesmo ciclo:
1. o bruto vai para `arte/fontes/`;
2. escrever `arte/blender/<asset>.py`;
3. rodar `blender -b --factory-startup --python arte/blender/<asset>.py`;
4. a saída vai para `Janghyang/assets/models/` e `textures/`;
5. acrescentar a linha em `LICENCAS.md`;
6. carregar o asset no `build` por `asset_loader.instance_or`;
7. rodar o gate de unidade (que inclui a licença) e o selftest com 0 falhas;
8. fazer a captura `--shot-*` antes e depois, para a D7;
9. medir o fps no `--tour`: queda acima de 20% vira achado.

As texturas são de 1K, ou de 2K nos objetos de mão. A paleta da casa é ocre, verde-musgo e creme.

| Tarefa | Asset | Origem sugerida | Captura | Commit |
|---|---|---|---|---|
| 36 | relógio de bolso de Elias (latão, vidro, ponteiro dos segundos animável) | do zero no Blender | `--shot-watch` | `feat: Elias's pocket watch model` |
| 37 | figuras e Gastos (manequim de porcelana, craquelê, rosto sem olhos, mãos compridas), com as poses da encenação | manequim CC0 editado, ou do zero | `--shot-figures` | `feat: porcelain mannequins for figures and Gastos` |
| 38 | materiais da casa: balsa, papelão com corte, papel de parede desbotado, tinta à mão, cola, forro e portas | ambientCG e Poly Haven (CC0), editados | `--shot-house` | `feat: hand-made maquete materials for the house` |
| 39 | itens de mão (lanterna, pilha, fósforo, espelho, lupa, estetoscópio, giz, vareta, brinquedo) e móveis da casa e do sótão, com os lençóis e o relógio da entrada | do zero e CC0 | `--shot-items`, `--shot-attic`, `--shot-clock` | `feat: hand items and house furniture models` |
| 40 | engrenagens e pêndulo da torre (latão oxidado, aço azulado) | do zero | `--shot-tower` | `feat: tower gears and pendulum` |

---

## 9. Fase 7 — Playtests 2 e 3

### Tarefa 41: Playtest 2 (noites 1 e 2, com assets)

As mesmas etapas das Tarefas 25 a 27, com pessoas que não jogaram o playtest 1. A meta é a duração entre 60 e 90 min e ninguém perdido mais de 3 min. As correções entram antes da Tarefa 42.

### Tarefa 42: Playtest 3 e o gate da demo

- [ ] Fazer mais uma rodada.
- [ ] O gate da demo (§15) se cumpre quando:
  - houve três playtests;
  - `perdido` ficou zero em todos os CSVs da rodada 3;
  - a duração mediana ficou entre 60 e 90 min;
  - o selftest está verde;
  - não há achado de severidade alta aberto.
- [ ] Registrar em `historico.md` com a evidência.

---

## 10. Fase 8 — Lançamento da demo

### Tarefa 43: Capturas, luz e janela (U40, U41, U42; D7)

- [ ] U40: a luz da oficina gigante, com `--shot-giant` antes e depois, e uma mudança de energia por vez.
- [ ] U41: o relógio da entrada legível em `--shot-clock`.
- [ ] U42: checklist de janela em `context/discussoes/checklist-janela.md`, que Pedro roda no Windows e no Linux:
  - `Esc` com o caderno aberto;
  - `Esc` durante a captura;
  - tela cheia;
  - troca de monitor;
  - opções que persistem.
- [ ] Commits: `fix: light the giant workshop enough to read the figures` (se houver ajuste) e `docs: add window checklist for the options menu`.

### Tarefa 44: Nome (U03, U04; D3)

- [ ] Procurar colisão do nome nas lojas (Steam, itch.io, GOG, consoles), em registros de marca, domínios e redes. Registrar o resultado em `context/` com `(e)` e a fonte.
- [ ] Com colisão direta, abrir uma decisão de nome para Pedro antes da Tarefa 46.

### Tarefa 45: Texto final e build da demo (U61, U62; D4, D9)

- [ ] Pedro lê o texto dos capítulos 1 a 4, da carta, das hipóteses e dos cards (D9). Aplicar as correções.
- [ ] Criar os presets de export com a feature tag `demo` (Windows e Linux). Gerar os dois binários e rodar `--selftest` em cada um. No Windows, Pedro roda.
- [ ] Commit: `build: add demo export presets`.

### Tarefa 46: Página da loja e beta (U63, U64; D1, D5)

- [ ] Montar os textos, as capturas das Tarefas 36 a 40 e 43 e um trailer curto. O modelo e o preço vêm da D5.
- [ ] Rodar um beta fechado com a build da Tarefa 45 e triar os achados.

### Tarefa 47: Submissão e publicação (U65, U66)

- [ ] Submeter nas plataformas da D1. Publicar em 2027-04-15 com a confirmação de Pedro.
- [ ] O push para `origin` acontece só quando Pedro pedir.

---

## 11. Fora deste plano

- As noites 3 a 5 com capítulos novos, a relojoaria refeita e a **mansão** (item 216: saguão, arquivo e oficina em miniatura), com a reviravolta da lupa no arquivo. Neste plano, as noites 3 a 5 existem em rascunho só para manter o final de hoje jogável e testado.
- Tirar os helpers do `main.gd` para uma biblioteca própria (§12.1).
- Localização além da D4. macOS, console e multijogador.
