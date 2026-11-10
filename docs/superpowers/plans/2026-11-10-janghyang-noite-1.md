# Janghyang — Plano da noite 1 refeita

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Uma tarefa por vez, na ordem deste arquivo; a tarefa N+1 só começa com a N `complete` no ledger.

**Goal:** refazer a noite 1 com os doze itens aprovados por Pedro: pistas espalhadas pela casa atrás de obstáculos, a casa que deixa de ser segura quando o painel quebra, o banco de sete figuras que esvazia, o beco da passagem com o nicho e o fôlego, a travessia e a vigília, sem nenhum estouro de volume.

**Architecture:** Cada regra nova nasce como modelo `RefCounted` puro com teste de unidade (segurança em degraus, banco, fresta, beco, catálogo que se reescreve). O que é cena vira uma **peça de cena**: um nó com script próprio, declarado no `DEF` da área (chave nova `setpieces`) e ligado pela noite (`night.setpieces`), de modo que o `main.gd` percorre registros e não ganha caso especial. Os dados da noite continuam em `scripts/story/noites.gd`; os lugares, nos `DEF` de `casa.gd` e `passagem.gd`.

**Tech Stack:** Godot 4.7.2 (GL Compatibility, 1280×720); GDScript; suíte `tests/run_unit.gd`; selftest headless (`--selftest`); bot `tests/bot_noite1.gd`; `python3 lint.py`; OpenCode (`mcp__opencode__ask_opencode`, só modelo gratuito) para segunda opinião.

**Spec:** `docs/superpowers/specs/2026-11-10-janghyang-noite-1-design.md` (aprovado por Pedro em 2026-11-10). As referências `§n` apontam para ele. O spec do jogo (`2026-11-08-janghyang-direcao-design.md`) continua valendo no que este não muda.

**Ledger:** `.superpowers/sdd/2026-11-10-janghyang-noite-1/progress.md` (ignorado pelo git, criado na Tarefa 1).

## Global Constraints

- Godot 4.7.2, GL Compatibility; modelos `RefCounted` via `preload`, sem `class_name`; áreas por `preload` em `Registry.AREAS` (§4).
- Custo zero. Nenhum arquivo de som ou asset externo novo: os cinco sons novos são sintetizados no `sfx_bank.gd` (§9).
- **Sem estouro de volume [Pedro]:** todo som passa pelo banco, cortado em `PEAK` (0.5), e toca no máximo em `MAX_DB` (0 dB). `MAX_DB = 0` é regra, não default (§5, §9).
- Texto só em papel; a casa não fala; nenhum susto com voz (§4).
- Nada acontece durante o 03:33 (§4, §6.8).
- Sem morte, sem game over. Ser pego custa tempo (R11). Nenhuma captura que o jogador não tinha como evitar (§3).
- Os Gastos só se movem sem ser vistos; sob a luz, giram mas não andam (§4).
- A porta da rua nunca tranca e nenhuma figura a bloqueia: nada a menos de 2,5 m de `DoorFront` (§4, `gastos.KEEP_CLEAR`).
- Nenhum susto tira o controle por mais de 2 s fora da captura (§4).
- Piscar abaixo de 3 por segundo, nunca branco total; com "reduzir piscar" a lanterna escurece e volta devagar (§10).
- Nada exige ouvir para avançar (§10).
- Não se mexe nas noites 2 a 5, nos capítulos nem na ordem das peças (§3). Sem área nova e sem ação nova de jogador.
- Conteúdo de área mora no `DEF` (R6). Todo helper `main._x(` chamado de área ou peça de cena entra em `Registry.HELPERS` com a aridade certa (o teste cobra nos dois sentidos).
- Unidade, selftest e lint verdes em cada tarefa. Linha de base: unidade **2616/0**, selftest **457/0**, bot **81,2 s**.
- Commits em Conventional Commits em inglês, **sem `Co-Authored-By`** e sem menção à IA. Commit direto no `main`, sem push até Pedro pedir.
- Todo fato novo em `context/` leva `[YYYY-MM-DD]` e `(d)`, `(i)` ou `(e)`; nada se apaga (`~superseded`). `python3 lint.py` antes de cada `complete`.

## Review Focus

As cinco situações que o spec implica, que nenhum teste de feature cobriria sozinho e que mais podem atingir quem joga. Cada uma tem o teste que a prende, na tarefa dona do código.

1. **Os fósforos acabam antes de o desenho ser catalogado.** A caixa da cabeceira nunca fica vazia enquanto o desenho não está no caderno; ninguém fica preso sem chama (Tarefa 8, `test_box_refills_while_the_drawing_is_missing`).
2. **Captura depois que o painel quebra.** Elias tem de acordar num ponto que ainda é seguro (o raio do relógio), não no ponto antigo da sala de brincar (Tarefa 2, `test_wake_point_is_safe_under_every_step`).
3. **No beco, o jogador lento, sem fôlego ou com "reduzir piscar".** Quem demora 3 s a mais ainda alcança o nicho; quem não prende a respiração é achado; a opção de acessibilidade não muda as janelas de escuro (Tarefa 17, `test_slow_player_still_reaches_the_niche`, `test_no_breath_is_found`, `test_reduce_flash_keeps_the_same_dark_windows`).
4. **Figura do banco em cima de Elias, num esconderijo, na porta da rua ou dentro do raio do relógio**, quando ele fica parado no destino, anda de costas ou se esconde (Tarefa 11, `test_never_lands_on_elias_hideout_or_door`; Tarefa 18, `test_ring_stays_outside_the_radius_and_off_the_door`).
5. **Fora de ordem e fora de hora:** painel batido antes do fim da cena, susto de roteiro pedido durante o 03:33, a lanterna que já piscou de ocasião antes do beco, `E` segurado na fresta no instante da captura. O progresso nunca trava, a cena de roteiro nunca é pulada por um susto de ocasião e o olhar volta (Tarefa 15, `test_locked_never_breaks`; Tarefa 5, `test_force_refused_in_the_hour`; Tarefa 17, `test_night1_keeps_the_flicker_for_the_dead_end`; Tarefa 13, `test_peek_ends_when_grabbed`).

---

## 0. Como este plano se executa

### 0.1 Regras

Valem as regras do §0.1 do plano da demo (`2026-11-08-janghyang-demo.md`): uma tarefa por vez; RED de verdade antes do código (o teste falha pela razão certa); duas falhas seguidas no mesmo passo param a tarefa; toda escolha que o plano não fechou vira `Ruling:` no ledger e linha `(i)` em `context/decisoes.md`; quem constrói não commita, o gestor commita depois dos gates.

Próprias deste plano:

1. **O bot fica suspenso da Tarefa 7 à Tarefa 19.** As pistas mudam de lugar na 7 e o bot antigo deixa de fechar a noite; ele é reescrito na 19. Unidade, selftest e lint continuam valendo em toda tarefa. Checagem de selftest que uma tarefa quebra é reescrita **na mesma tarefa**.
2. **Lugares são ponto de partida.** As coordenadas deste plano saíram da leitura do código, não de medição em jogo. Quem constrói pode ajustar até 0,5 m para caber, sem `Ruling:`; mais que isso, ou trocar de cômodo, pede `Ruling:`.
3. **Textos de catálogo são rascunho da IA sob D9.** Entram como estão aqui e Pedro revisa depois.

### 0.2 Gates (rodar de `~/Dev/Jogo`)

```bash
timeout 60 godot --headless --path Janghyang -s res://tests/run_unit.gd 2>&1 | tail -3      # unidade
timeout 150 godot --headless --path Janghyang -- --selftest 2>&1 | tail -3                  # selftest
python3 lint.py                                                                             # grafo de context/
(cd Janghyang && godot --headless --path . --fixed-fps 60 -s res://tests/bot_noite1.gd -- --playtest --night=1)   # bot (T1–6 e T19+)
```

Suíte nova de unidade: `tests/test_<nome>.gd` com `func test_x(t) -> void` e `t.ok/eq/near`, registrada em `tests/run_unit.gd` como as outras.

### 0.3 Contratos que várias tarefas usam (nascem na Tarefa 1)

- **`DEF` (chaves novas em `Registry._EMPTY`):**
  - `"setpieces": []` — `{"id": StringName, "script": Script (preload no arquivo da área), ...dados próprios}`.
  - `"targets": []` — alvos de catálogo: `{"item": StringName, "at": Vector3, "size": Vector3}` ou `{"item": StringName, "node": String}` (alvo preso a um nó, como `Ball`).
  - `"locks": {}` — `{"<nó Breakable>": <id do capítulo>}`: o nó não quebra antes de a cena desse capítulo acabar.
- **Noite (chaves novas em `noites.gd`, opcionais):** `"setpieces": Array[StringName]` (as peças ligadas nesta noite), `"closed": Array[StringName]` (nós fechados só nesta noite), `"mute_scares": Array[StringName]` (tipos que o diretor recusa em `request` nesta noite; o `force` de roteiro passa assim mesmo).
- **Peça de cena:** script em `scripts/setpieces/<id>.gd`, `extends Node3D`, com `var main: Node`, `var def: Dictionary` (o `DEF` da área), `var data: Dictionary` (a própria entrada) e `func on_night(night: Dictionary) -> void`. O nó se chama `Setpiece_<id>` e entra no grupo `Setpiece`. **Fora da noite que a lista, a peça fica no estado resolvido** (armário aberto, cera visível, banco vazio, fresta cega, sem alçapão), para as noites 2 a 5 não mudarem de regra.
- **Estado da noite em `main.gd`:** `var night_flags: Dictionary`; `func set_night_flag(id: StringName) -> void` (idempotente, emite `signal night_flag_set(id: StringName)`); `func step_done(id: StringName) -> bool` (`id == &""`, tarefa feita no `quest` ou flag levantada). Zera em `begin_night`.

### 0.4 Mapa de arquivos

| Arquivo | Papel | Tarefa |
|---|---|---|
| `scripts/areas/registry.gd` | chaves `setpieces`, `targets`, `locks`; helpers novos | 1 |
| `scripts/main.gd` | monta peças e alvos a partir dos `DEF`; flags da noite; `wake_point`; `lantern_dim` | 1, 2, 4, 15 |
| `scripts/safety_model.gd` | `rule_of`, regra `raio_relogio` | 2 |
| `scripts/gastos.gd`, `scripts/stalker_model.gd` | degraus com nível, flag e nascimento; `passing`; `lure`; escuro não vê | 3, 4 |
| `scripts/scare_director.gd`, `scripts/dread.gd`, `scripts/sfx_bank.gd` | tipos novos, `force`, cinco sons | 5 |
| `scripts/story/noites.gd` | dados da noite 1 | 6–18 |
| `scripts/areas/casa.gd` | sala das figuras maior, banco, armário, quarto, fresta, janelas | 6–14 |
| `scripts/areas/passagem.gd` | trava do painel, alçapão, nicho, caixa de música, giz | 15–17 |
| `scripts/setpieces/*.gd` (novos) | `luz_de_fora`, `vitrine`, `chave_vitrine`, `desenho_cera`, `bola_quica`, `banco`, `presenca`, `fresta`, `reflexo_fica`, `figura_painel`, `caixa_passagem`, `beco` | 6–18 |
| `scripts/*_model.gd` (novos) | `wax`, `bounce`, `bench`, `presence`, `peek`, `stay`, `panel_figure`, `phrase`, `beco` | 8–18 |
| `scripts/catalog.gd`, `scripts/catalog_data.gd` | portões por flag, `recount`, textos novos | 7, 8, 12 |
| `scripts/breakable.gd`, `scripts/player.gd`, `scripts/mirror_reflection.gd` | `locked`; segurar `E`; reflexo que fica | 13, 14, 15 |
| `scripts/selftest.gd`, `tests/bot_noite1.gd` | checagens e caminho novos | todas, 19 |
| `context/*`, `docs/…/2026-11-08-janghyang-demo.md` | decisões, arquitetura, roteiro do playtest | 7, 20 |

### 0.5 Escolhas do plano para Pedro conferir

São escolhas técnicas da IA feitas ao planejar, além das dez do §15 do spec. Nenhuma está construída ainda.

1. **No escuro, nenhum ponto conta como "visto"** (Tarefa 4). Hoje um Gasto não pisa num ponto que está no campo de visão de Elias mesmo com a lanterna apagada. O beco precisa do contrário ("o escuro conta como não vista", §6.6), e a mudança vale para **todas as noites**.
2. **O Gasto "de passagem"** (Tarefa 4): atraído para o fundo do beco, ele passa por Elias escondido e sem respirar em vez de parar ao lado dele por 8 s, como faz hoje.
3. **A figura do painel é uma peça de cena, não um Gasto** (Tarefa 15): mesmo corpo, nunca agarra; o Gasto de verdade só existe depois que ela some.
4. **Regras de hoje que continuam valendo no beco** (Tarefa 17): uma chama acesa deixa Elias encarar o Gasto por 3,5 s e desfazê-lo; a bengala o desfaz. Só a lanterna não basta (as janelas de luz têm 2 s). O plano não fecha esses dois atalhos; o playtest diz se incomodam.
5. **A sala das figuras cresce de 2,8 × 2,1 m para 4,9 × 3,5 m** (Tarefa 7): sete figuras do tamanho do Gasto pedem 4,2 m de banco, e a mesa e as três cadeiras ficam.
6. **O rastro `giz_figuras` (que levava a uma pilha) sai**; no lugar entra o `giz_vitrine`, do armário até a chave (Tarefa 7). A pilha continua lá.
7. **Sustos que se repetem:** o spec diz "cada tipo uma vez por noite" e também "uma figura por visita" e "no máximo duas vezes" para o catálogo. O plano lê assim: os fortes e os de roteiro são únicos; `figura_some` (teto 3) e `catalogo_muda` (teto 2) são fracos e respeitam só o intervalo de 20 s (Tarefa 5).
8. **Susto de roteiro pedido durante o 03:33 pula a encenação, nunca o progresso** (Tarefa 5).
9. **A fresta aceita toque e segurar:** um toque em `E` entra e outro sai; segurar mantém enquanto a tecla estiver apertada (Tarefa 13).
10. **Na noite 1 a lanterna não pisca de ocasião:** o pisca que hoje pode vir com a tensão alta fica guardado para o beco, para a cena não ser gasta antes (Tarefa 17). As noites 2 a 5 seguem como estão.

---

## Tarefa 1: Base — ledger, peças de cena, flags da noite, alvos nos `DEF`

Refatoração sem mudança de jogo: nada muda de lugar.

**Files:**
- Create: `.superpowers/sdd/2026-11-10-janghyang-noite-1/progress.md`, `Janghyang/scripts/setpieces/` (pasta)
- Modify: `Janghyang/scripts/areas/registry.gd` (`_EMPTY`), `Janghyang/scripts/main.gd` (`_build_catalog_targets` 686–700, `begin_night` 920), `Janghyang/scripts/areas/casa.gd`, `passagem.gd` e as outras áreas que têm alvo hoje (`DEF.targets`)
- Test: `Janghyang/tests/test_registry.gd`

**Interfaces:**
- Produces: tudo o que está em §0.3. `main._build_setpieces() -> void` (chamado depois das áreas montadas); `main.setpiece(id: StringName) -> Node3D` (ou `null`).

- [ ] **Passo 1:** criar o ledger com `T1: start | baseline unit 2616/0 selftest 457/0 bot 81.2 s lint ok` depois de rodar os quatro gates.
- [ ] **Passo 2: testes que falham** em `test_registry.gd`:
  - `test_new_def_keys_default_empty`: toda área de `Registry.defs()` tem `setpieces` (Array), `targets` (Array) e `locks` (Dictionary).
  - `test_targets_are_catalog_items_in_their_area`: todo `targets[i].item` existe em `CatalogData.ITEMS`; nenhum item aparece duas vezes no conjunto das áreas; todo `at` cai num cômodo da própria área (ou a entrada tem `node`).
  - `test_all_of_todays_targets_moved`: os itens que `main._build_catalog_targets()` monta hoje estão todos em algum `DEF.targets` (lista literal no teste, copiada do código atual).
  - `test_setpieces_are_well_formed`: toda entrada tem `id` e `script`; o script instanciado tem `on_night`; nenhum `id` repetido.
- [ ] **Passo 3:** rodar a unidade; esperado: falha em "has setpieces".
- [ ] **Passo 4:** implementar. `_build_catalog_targets()` passa a percorrer `Registry.defs()` (mesmas posições e tamanhos de hoje, copiados para os `DEF`); `_build_setpieces()` instancia cada entrada; `begin_night` zera `night_flags` e chama `on_night(night)` em todo nó do grupo `Setpiece`.
- [ ] **Passo 5:** gates: unidade verde (mais que 2616), selftest **457/0**, bot `BOT RESULT ok`, lint ok.
- [ ] **Commit:** `refactor: move catalog targets to area defs and add setpiece contract`

## Tarefa 2: Segurança em degraus e a regra `raio_relogio` (§5, §6.5, §8.1)

Só a capacidade. Os dados da noite 1 mudam na Tarefa 15.

**Files:**
- Modify: `Janghyang/scripts/safety_model.gd`, `Janghyang/scripts/gastos.gd` (`rule` 364, `world_at` 369, `safe_points` 400), `Janghyang/scripts/main.gd` (quem acorda Elias depois de uma captura não solta)
- Test: `Janghyang/tests/test_safety_model.gd`

**Interfaces:**
- Produces: `static func Safety.rule_of(safety: Variant, is_done: Callable) -> StringName` (aceita `StringName` ou `Array` de `{"after": StringName, "rule": StringName}`; vale o último degrau cujo `after` está feito). Regra `&"raio_relogio"`: seguro se `world.level == Registry.HOME` e a distância **no plano** até `world.clock` é ≤ `ANCHOR_RADIUS` (4.0). `world_at` passa a levar `"clock": Vector3` (posição de `EntryClock`). `gastos.rule()` usa `rule_of(night.safety, main.step_done)`. `main.wake_point() -> Vector3`.

- [ ] **Passo 1: testes que falham:**

```gdscript
func test_rule_of_steps(t) -> void:
	var steps := [{"after": &"", "rule": &"casa_toda"}, {"after": &"achar_passagem", "rule": &"raio_relogio"}]
	t.eq(Safety.rule_of(steps, func(_id): return false), &"casa_toda", "before the panel")
	t.eq(Safety.rule_of(steps, func(id): return id == &"achar_passagem"), &"raio_relogio", "after it")
	t.eq(Safety.rule_of(&"relogio_entrada", func(_id): return false), &"relogio_entrada", "a single rule passes through")

func test_raio_relogio(t) -> void:
	var w := {"level": &"casa", "clock": Vector3(3.1, 1.0, 8.88), "anchors": []}
	t.ok(Safety.is_safe(Vector3(1.8, 0.2, 8.3), &"raio_relogio", w), "the spawn is inside")
	t.ok(Safety.is_safe(Vector3(3.1, 0.0, 4.9), &"raio_relogio", w), "3.98 m, height ignored")
	t.ok(not Safety.is_safe(Vector3(3.1, 0.0, 4.8), &"raio_relogio", w), "4.08 m is out")
	t.ok(not Safety.is_safe(Vector3(6.7, 0.0, 0.3), &"raio_relogio", w), "the panel is out")
	w.level = &"passagem"
	t.ok(not Safety.is_safe(Vector3(3.1, 0.0, 8.0), &"raio_relogio", w), "only at home")
	t.ok(not Safety.is_safe(Vector3(3.1, 0.0, 8.0), &"raio_relogio", {"level": &"casa"}), "no clock, no refuge")
```

  - `test_wake_point_is_safe_under_every_step` (Review Focus 2): para toda noite de `Noites.NOITES` e todo degrau de `safety`, o ponto que `wake_point()` devolveria para cada área da noite é `is_safe` sob a regra daquele degrau, quando a regra tem algum ponto seguro. A conta pura fica em `static func Safety.wake_for(rule: StringName, area_safe: Vector3, home_safe: Vector3) -> Vector3`: sob `raio_relogio` devolve sempre `home_safe` (`casa.DEF.safe`, a 1,4 m do relógio); nas outras regras, `area_safe`, como hoje.
- [ ] **Passo 2:** rodar; esperado: falha em "rule_of" (função não existe).
- [ ] **Passo 3:** implementar as três peças da interface. `main.wake_point()` chama `wake_for` com a regra corrente; `_track_place` (linha 1414) passa a fazer `player.respawn_point = wake_point()` em vez de ler `LEVEL_SAFE` direto, e o ponto é recalculado também quando uma flag da noite ou uma tarefa muda a regra (Elias pode estar parado quando o painel cai).
- [ ] **Passo 4:** gates (unidade, selftest 457/0, bot ok, lint).
- [ ] **Commit:** `feat: stepped night safety and entry clock radius rule`

## Tarefa 3: Degraus de Gasto com nível, flag e nascimento (§6.5, §8.2)

Só a capacidade; os dados entram nas Tarefas 15 e 17.

**Files:**
- Modify: `Janghyang/scripts/gastos.gd` (`wanted` 335, `night_stalkers` 350, `on_level` 412)
- Test: `Janghyang/tests/test_night_stalkers.gd`

**Interfaces:**
- Consumes: `main.step_done` (Tarefa 1).
- Produces: `static func night_stalkers(steps: Array, is_done: Callable, level: StringName = &"") -> int`. Um degrau pode ter `"levels": Array[StringName]`: fora deles o degrau não conta (vale o anterior que conta). Um degrau pode ter `"birth": {"level": StringName, "at": Vector3}`: quando a contagem sobe com Elias nesse nível, o Gasto novo nasce no ponto do grafo mais próximo de `at` em vez de "longe e fora de vista"; vale uma vez por noite. `wanted()` passa `main.step_done` e o nível corrente.

- [ ] **Passo 1: testes que falham:**

```gdscript
const STEPS := [
	{"after": &"", "n": 0},
	{"after": &"figura_saiu", "n": 1, "levels": [&"casa"]},
	{"after": &"beco_apagou", "n": 1, "birth": {"level": &"passagem", "at": Vector3(6.45, 0.0, -0.65)}},
]
func test_levels_and_flags(t) -> void:
	var none := func(_id): return false
	var out := func(id): return id == &"figura_saiu"
	var beco := func(id): return id in [&"figura_saiu", &"beco_apagou"]
	t.eq(Gastos.night_stalkers(STEPS, none, &"casa"), 0, "nothing before the figure leaves")
	t.eq(Gastos.night_stalkers(STEPS, out, &"casa"), 1, "one in the house")
	t.eq(Gastos.night_stalkers(STEPS, out, &"passagem"), 0, "it does not follow into the passage")
	t.eq(Gastos.night_stalkers(STEPS, beco, &"passagem"), 1, "the dead end has one")
	t.eq(Gastos.night_stalkers(STEPS, beco, &"casa"), 1, "and it follows him home")
func test_old_nights_unchanged(t) -> void:
	for n in [2, 3, 4, 5]:
		var s: Array = Noites.NOITES[n - 1].stalkers
		t.eq(Gastos.night_stalkers(s, func(_id): return false), int(s[0].n), "night %d as before" % n)
```

  - `test_birth_point_is_the_nearest_graph_point`: função pura `static func birth_index(points: Array, at: Vector3) -> int`; com os pontos da passagem (x = 2.05, 4.25, 6.45, 8.65 em z −0.65) e `at = (6.45, 0, -0.65)` devolve o índice 2.
- [ ] **Passo 2:** rodar; esperado: falha por número de argumentos em `night_stalkers`.
- [ ] **Passo 3:** implementar. Quando `wanted()` cai (Elias trocou de nível e o degrau não conta), o Gasto sobrando some sem ser visto, como já acontece em `_process` 521–524.
- [ ] **Passo 4:** o teste antigo da noite 1 ("0 antes da coroa, 1 depois") continua verde: os dados ainda não mudaram.
- [ ] **Passo 5:** gates.
- [ ] **Commit:** `feat: stalker steps gated by level and night flags, with birth point`

## Tarefa 4: O Gasto no escuro — `passing`, isca, apagão da lanterna, corpo que barra (§6.6, §8.2)

**Files:**
- Modify: `Janghyang/scripts/stalker_model.gd` (`update` 62), `Janghyang/scripts/gastos.gd` (`_process` 512–559, `_lit`, `goal_of`, `_show`), `Janghyang/scripts/main.gd` (`_tick_light` 1144)
- Test: `Janghyang/tests/test_stalker_model.gd`

**Interfaces:**
- Produces:
  - `StalkerModel.update(..., breath_held := true, passing := false)`: com `passing`, `near`, `hidden` e `breath_held` verdadeiros, o Gasto **não** entra na espera de `HIDE_GIVE_UP`: segue para `goal`. Sem fôlego, vale a regra de hoje (`HIDE_FOUND` 3 s → `&"caught"`). Em campo aberto, `passing` não muda nada.
  - `StalkerModel.hold_step() -> void`: zera o relógio do passo (o Gasto não anda neste tick; olhar e achar continuam correndo).
  - `gastos.lure(at: Vector3, seconds: float) -> void`: por `seconds`, todo Gasto tem como meta o ponto do grafo mais próximo de `at`, com `passing = true`; acaba antes se ele chegar. `gastos.lured() -> bool`. Enquanto atraído e Elias **não** cego, `gastos` chama `hold_step()` a cada tick: ele só anda no escuro, um ponto por apagão.
  - `main.lantern_dim: float` (0..1, padrão 1.0): `_tick_light` multiplica a energia da lanterna por ele. `main.lantern_dark() -> bool` (`lantern_dim < 0.2`). `gastos._lit` trata a lanterna como apagada quando `lantern_dark()`; fósforo e vela continuam valendo.
  - Em `_process`, quando `blind`, `in_view` vai vazio para `update` (escolha 1 de §0.5).
  - O corpo do Gasto barra Elias quando o ponto está sob teto baixo (pose `agachado` em `_show`), e nunca é ligado a menos de `Staging.CLEAR` (0.6) dele.

- [ ] **Passo 1: testes que falham** (linha de quatro pontos, 2,2 m entre eles, como a passagem):
  - `test_passing_walks_by_a_hidden_elias`: `at = 2`, `goal = 0`, `near`, `hidden`, `breath_held`, `passing`, `blind`; depois de `STEP_TIME_BLIND` devolve `&"moved"` e `at == 1`.
  - `test_passing_without_breath_still_finds`: igual, `breath_held = false`; depois de `HIDE_FOUND` devolve `&"caught"`.
  - `test_not_passing_waits_as_today`: `passing = false`; não anda e devolve `&"gave_up"` aos `HIDE_GIVE_UP`.
  - `test_passing_still_catches_in_the_open`: `near`, `hidden = false`, `passing`; no passo devolve `&"caught"`.
  - `test_hold_step_keeps_it_still`: 10 s de ticks não visto e não cego, com `hold_step()` antes de cada um: `at` não muda; sem `hold_step()`, anda em `STEP_TIME`.
  - `test_flame_stare_still_undoes`: `seen = true` por `STARE_TIME` com `passing` ligado devolve `&"undone"` (escolha 4 de §0.5, presa de propósito).
- [ ] **Passo 2:** rodar; esperado: falha por argumento `passing` desconhecido.
- [ ] **Passo 3:** implementar o modelo; rodar a unidade.
- [ ] **Passo 4: selftest** (novo bloco `_escuro`, na noite 2, que já tem Gasto): `escuro: com a lanterna apagada o Gasto pisa num ponto à frente de Elias`; `escuro: lantern_dim 0 conta como lanterna apagada`; `escuro: com fósforo aceso o apagão não cega`; `isca: o Gasto vai ao ponto da isca e para`; `corpo: Elias não atravessa um Gasto na passagem` (anda contra ele 2 s e o x não passa).
- [ ] **Passo 5:** gates. Se alguma checagem antiga das noites 2 a 5 depender de "ponto à vista no escuro não é pisado", ela é reescrita aqui e o caso vai para o ledger como `Ruling:`.
- [ ] **Commit:** `feat: stalkers pass a hidden player when lured and move freely in the dark`

## Tarefa 5: Diretor de sustos e sons novos (§8.8, §9)

**Files:**
- Modify: `Janghyang/scripts/scare_director.gd` (`KINDS` 17, `request` 34), `Janghyang/scripts/dread.gd`, `Janghyang/scripts/sfx_bank.gd` (`KINDS`, `make`)
- Test: `Janghyang/tests/test_scare_director.gd`, `Janghyang/tests/test_sfx_bank.gd`

**Interfaces:**
- Produces:
  - `KINDS` ganha `&"bola_quica"`, `&"olho_fresta"`, `&"figura_painel"`, `&"reflexo_fica"`, `&"figura_some"`, `&"catalogo_muda"`.
  - `func force(kind: StringName) -> bool`: susto de roteiro. Devolve `false` durante o 03:33, para tipo desconhecido ou já usado na noite; senão marca o tipo como usado, zera `_since_strong`, `_since_weak` e `_quiet` e devolve `true`. Não olha tensão nem silêncio.
  - `var muted: Array[StringName]`: `request` devolve `false` para tipo mudo; `force` não olha. `main.begin_night` (linha 952, junto do `director.new_night()`) põe ali o `night.mute_scares`, ou `[]`.
  - `dread.scripted(kind: StringName) -> bool` (chama `director.force`).
  - `SfxBank.KINDS` ganha `&"interruptor"` (clique grave, ~0,12 s), `&"quique"` (madeira no assoalho, ~0,08 s), `&"arrastar"` (raspado grave em laço, 1,5 s), `&"caixa_frase"` (4,0 s de melodia que para sempre na mesma nota; mesmo timbre da caixa de hoje), `&"madeira"` (estalo de tábua, ~0,3 s).

- [ ] **Passo 1: testes que falham:**
  - `test_new_kinds_are_known`: os seis em `KINDS`.
  - `test_force_passes_cold`: depois de `new_night()`, sem silêncio e com tensão 0, `force(&"bola_quica")` é `true`.
  - `test_force_refused_in_the_hour` (Review Focus 5): `set_hour(true)` → `false`, e o tipo **não** fica usado (`set_hour(false)` → `true`).
  - `test_force_only_once`: a segunda chamada do mesmo tipo é `false`.
  - `test_force_makes_room`: logo depois de um `force`, `request(&"pose", false, 1.0)` é `false`; depois de `update(WEAK_GAP, false)` é `true`. Um forte (`request(&"olho_fresta", true, 1.0)`) só passa depois de `STRONG_GAP`.
  - `test_strong_new_kinds_once_weak_ones_repeat`: `olho_fresta` forte não passa duas vezes na noite; `figura_some` fraco passa de novo depois de `WEAK_GAP` + `QUIET_BEFORE`.
  - `test_muted_kind_is_refused_but_force_passes`: com `muted = [&"lanterna_pisca"]`, silêncio e tensão 1.0, `request(&"lanterna_pisca", true, 1.0)` é `false` e o tipo não fica usado; `force(&"lanterna_pisca")` é `true`.
  - `test_max_db_is_the_rule`: `MAX_DB == 0.0` e `PEAK == 0.5`.
  - `test_new_sounds_are_clipped`: para cada um dos cinco, `SfxBank.make(kind, 1)` tem amostras, pico ≤ `PEAK`, e o mesmo `seed` dá o mesmo som (molde dos testes que já existem na suíte).
- [ ] **Passo 2:** rodar; esperado: falha em "new kinds are known".
- [ ] **Passo 3:** implementar. O comentário do topo do `scare_director.gd` troca "D10: no volume bursts" por "regra de Pedro, 2026-11-10".
- [ ] **Passo 4:** gates.
- [ ] **Commit:** `feat: scripted scares in the director and five new synthesized sounds`

## Tarefa 6: Abertura — a luz de fora apaga (§6.1, item 6)

**Files:**
- Create: `Janghyang/scripts/setpieces/luz_de_fora.gd`
- Modify: `Janghyang/scripts/areas/casa.gd` (janela 214–216, luzes 222–230, `DEF.setpieces`), `Janghyang/scripts/areas/tampo.gd` (lâmpada ~55), `Janghyang/scripts/main.gd` (`_house_goes_dark` 970), `Janghyang/scripts/story/noites.gd` (noite 1: `"setpieces": [&"luz_de_fora"]`)
- Test: selftest

**Interfaces:**
- Consumes: contrato de peça (Tarefa 1); som `interruptor` (Tarefa 5); `night_card.letter_closed`.
- Produces: grupo `OutsideLight` (a lâmpada da bancada em `tampo.gd`, se o nó existir na noite, e uma luz quente `Color(1.0, 0.78, 0.5)` atrás de cada janela da casa); `setpiece(&"luz_de_fora").is_out() -> bool`.

Decisão (§14): o efeito é feito **nas janelas da casa**. Cada malha com `mat_window` ganha uma luz `OutsideLight` do lado de fora. Se a lâmpada gigante da oficina estiver montada, entra no mesmo grupo e apaga junto.

- [ ] **Passo 1: checagens de selftest que falham** (bloco novo `_abertura`): `abertura: antes da carta há luz de fora` (alguma `OutsideLight` com energia > 0); `abertura: guardar a carta apaga a luz de fora` (todas em 0 depois de 0,6 s); `abertura: os vidros ficam pretos` (emissão do vidro em 0); `abertura: só a lâmpada da sala de brincar fica` (`PlayroomLamp` > 0, as outras `HouseLight` em 0, como hoje); `abertura: na noite 2 a peça não mexe nas luzes`.
- [ ] **Passo 2:** rodar o selftest; esperado: falha em "há luz de fora".
- [ ] **Passo 3:** implementar. Ao `letter_closed`: toca `interruptor` uma vez, em −18 dB, na direção da oficina; 0,25 s depois as `OutsideLight` vão a zero em 0,4 s e o vidro escurece junto (material próprio da peça, para não pintar a janela da oficina nas outras noites); então roda o `_house_goes_dark()` de hoje. Depois, silêncio: a peça não toca mais nada.
- [ ] **Passo 4:** gates (selftest > 457, bot ok).
- [ ] **Commit:** `feat: the outside light goes out when the letter is put away`

## Tarefa 7: A sala das figuras cresce; banco, armário, chave e giz (§6.2, §14, itens 1 e 4)

A partir daqui o bot fica suspenso (§0.1.1).

**Files:**
- Create: `Janghyang/scripts/setpieces/vitrine.gd`, `Janghyang/scripts/setpieces/chave_vitrine.gd`
- Modify: `Janghyang/scripts/areas/casa.gd` (`DEF.rooms` `figuras`; paredes 119, 144–150; piso e teto 94, 102; sala 368–392; casinha 256–259; `DEF.targets`, `chalk`, `catalog`, `setpieces`), `Janghyang/scripts/catalog_data.gd`, `Janghyang/scripts/main.gd` (`chalk_target` 1108), `Janghyang/scripts/story/noites.gd`, `context/arquitetura.md`, `context/decisoes.md`
- Test: `Janghyang/tests/test_registry.gd`, `Janghyang/tests/test_catalog.gd`, selftest

**Interfaces:**
- Consumes: `set_night_flag`, `targets`, contrato de peça.
- Produces: cômodo `figuras` com `Rect2(10.5, 5.6, 4.9, 3.5)`; nó `Bench` (banco de 4,2 m contra a parede norte, assento em z ≈ 5.95, sete lugares em x = 11.3 + 0.6·i, i = 0..6, olhando para o sul); `DEF.bench = {"seats": [...sete Vector3...], "face": Vector3(0, 0, 1)}`; flag de catálogo `&"vitrine_aberta"`; flag da noite `&"chave_vitrine"`; rastro `giz_vitrine`; tarefa `&"cat_casinha"`.

- [ ] **Passo 1:** conferir que o vão está vazio: nenhum nó de nenhuma área com caixa dentro de x 10.5–15.4, z 5.6–7.0, y 0–2.7 nem de x 13.3–15.4, z 7.0–9.1 (script descartável no scratchpad, percorrendo a cena montada). Se houver algo, parar e registrar `Ruling:` antes de mexer.
- [ ] **Passo 2: testes que falham:**
  - `test_figure_room_holds_the_bench` (`test_registry.gd`): o `rect` de `figuras` é `Rect2(10.5, 5.6, 4.9, 3.5)`; não sobrepõe nenhum outro cômodo; os sete `bench.seats` caem dentro dele, a ≥ 0,55 m um do outro.
  - `test_chalk_trails_stay_inside_rooms`: para todo rastro de todo `DEF.chalk`, cada ponto e o meio de cada trecho caem num cômodo da área; `leads_to` é um pickup, um item de catálogo ou o `id` de uma peça de cena.
  - `test_casinha_waits_for_the_cabinet` (`test_catalog.gd`): `can_catalog(&"casinha")` é falso até `set_flag(&"vitrine_aberta", true)`.
  - Selftest (`_vitrine`): `vitrine: sem a chave o armário não abre e a casinha não entra no caderno`; `vitrine: a chave fica no fim do giz, dentro da cabana` (o último ponto de `giz_vitrine` está a ≤ 0,5 m da chave e dentro de `HideCabana`); `vitrine: com a chave, E abre e a casinha pode ser catalogada`; `vitrine: na noite 2 o armário já está aberto`; `sala: as três figuras sentadas e os relógios de bolso continuam catalogáveis`.
- [ ] **Passo 3:** rodar; esperado: falha no `rect`.
- [ ] **Passo 4: geometria.** A parede z = 7.0 entre x 10.5 e 13.3 e a parede x = 13.3 saem; a parede sul do quarto (z = 5.6) passa a ser a parede norte da sala; entra a parede leste x = 15.4 de z 5.6 a 9.1; a parede do corredor x = 10.5 de z 5.32 a 7.56 fica inteira; piso e teto vão a x 10.5–15.4, z 5.6–9.1. A mesa, a vela, as três cadeiras, os ocupantes, a `Figure` e os adereços de `_build_story_props` **não se movem**. Tudo o que estava encostado nas paredes que saem vai para a parede nova: `house_mirror.KNOCK_POINTS[5]` (`(13.2, 1.3, 8.0)`, face da parede x = 13.3) passa a `(15.28, 1.3, 8.0)`, e as âncoras de `crack_thing` e a luz da sala são conferidas do mesmo jeito. Checagem de selftest: `sala: nenhum ponto de batida nem âncora de fresta fica a mais de 0,3 m de uma parede`.
- [ ] **Passo 5: armário e chave.** Armário de 1,1 × 1,6 × 0,5 m encostado na parede leste em `(15.1, 0, 8.2)`, porta de vidro para oeste (`_hinge`), casinha numa prateleira a y 0.6; o alvo `casinha` vai para lá. `vitrine.gd`: sem a chave, `get_prompt()` devolve `"abrir o armário"` e `interact()` só toca `click` (trancado); com `step_done(&"chave_vitrine")`, o prompt é `"destrancar o armário"`, a porta abre e `catalog.set_flag(&"vitrine_aberta", true)`. `chave_vitrine.gd`: chave de latão em `(1.78, 0.02, 3.5)`, meio debaixo da almofada da cabana; prompt `"pegar a chave"`; `interact()` levanta a flag, grava a nota de catálogo e some. A chave não vai para a mão.
- [ ] **Passo 6: giz e dados.** `giz_figuras` sai do `DEF.chalk`; entra `{"id": &"giz_vitrine", "points": [(14.6, 8.2), (12.9, 7.2), (10.9, 8.0), (9.4, 8.4), (6.0, 8.4), (3.9, 8.4), (2.4, 7.7), (1.8, 6.9), (1.8, 5.4), (1.78, 3.9)] em y 0.006, "leads_to": &"chave_vitrine"}`; `chalk_target` passa a resolver também `Setpiece_<id>`. `DEF.catalog` ganha `&"casinha": &"cat_casinha"`. `ITEMS.casinha.gate = &"vitrine_aberta"`. Textos novos (rascunho, D9): item `&"vitrine"`: "armário de porta de vidro, trancado. Lá dentro, a casinha." (alvo na porta do armário); nota `&"chave_vitrine"`: "chave pequena, de latão, debaixo da almofada da cabana. O giz do menino ia até ela." Noite 1: `setpieces` ganha `&"vitrine"` e `&"chave_vitrine"`. A caixa onde a casinha ficava na sala de brincar (casa.gd 256–259) sai; a primeira pose do pai (`staging`, linha 39) passa a olhar o menino: `"face": Vector3(5.6, 0.4, 2.9)`.
- [ ] **Passo 7:** `context/arquitetura.md`: o `rect` novo de `figuras`, a pasta `scripts/setpieces/` e as chaves novas de `DEF`. `context/decisoes.md`: `(i)` para o crescimento da sala e a troca do rastro de giz (escolhas 5 e 6 de §0.5).
- [ ] **Passo 8:** gates (unidade, selftest, lint). As checagens de `_capitulo` e `_giz` que assumem a casinha na sala de brincar e o `giz_figuras` são reescritas aqui.
- [ ] **Commit:** `feat: figure room grows to hold the bench, locked cabinet and chalk trail to its key`

## Tarefa 8: O desenho que só a chama mostra (§6.2, item 1)

**Files:**
- Create: `Janghyang/scripts/wax_model.gd`, `Janghyang/scripts/setpieces/desenho_cera.gd`, `Janghyang/tests/test_wax_model.gd`
- Modify: `Janghyang/scripts/areas/casa.gd` (desenho 236–237; `DEF.targets`, `pickups`, `setpieces`), `Janghyang/scripts/catalog_data.gd`, `Janghyang/scripts/story/noites.gd`
- Test: `Janghyang/tests/test_wax_model.gd`, `Janghyang/tests/test_catalog.gd`, selftest

**Interfaces:**
- Consumes: `main.light` (`burning()`), grupo `CandleLight`, `catalog.set_flag`.
- Produces:
  - `WaxModel.REVEAL := 2.5` (metros). `static func shows(flames: Array, at: Vector3) -> bool`: verdadeiro se alguma chama acesa está a ≤ `REVEAL` de `at`. A lanterna não entra na conta.
  - `static func refill_due(matches: int, flame_near: bool, cataloged: bool, box_active: bool, box_seen: bool) -> bool`: verdadeiro quando o desenho não foi catalogado, Elias não tem fósforo, não há chama perto do desenho, a caixa da cabeceira está vazia e ninguém está olhando para ela.
  - Flag de catálogo `&"chama_no_desenho"` (atualizada a cada frame pela peça; `true` fixo fora da noite 1); nó `DrawingWax`.

- [ ] **Passo 1: testes que falham:**

```gdscript
func test_only_a_flame_shows_it(t) -> void:
	var at := Vector3(14.7, 1.5, 0.06)
	t.ok(not Wax.shows([], at), "no flame, blank paper")
	t.ok(Wax.shows([Vector3(14.6, 1.2, 1.0)], at), "a match in the hand")
	t.ok(not Wax.shows([Vector3(11.0, 0.3, 5.0)], at), "the candle across the room is too far")

func test_box_refills_while_the_drawing_is_missing(t) -> void:   # Review Focus 1
	t.ok(Wax.refill_due(0, false, false, false, false), "out of flame, unseen: one more match")
	t.ok(not Wax.refill_due(0, false, false, false, true), "never while he looks at the box")
	t.ok(not Wax.refill_due(1, false, false, false, false), "he still has one")
	t.ok(not Wax.refill_due(0, true, false, false, false), "a candle burns by the drawing")
	t.ok(not Wax.refill_due(0, false, true, false, false), "already in the notebook")
	t.ok(not Wax.refill_due(0, false, false, true, false), "the box is not empty")
```

  - `test_drawing_waits_for_the_flame` (`test_catalog.gd`): `can_catalog(&"desenho")` segue a flag `&"chama_no_desenho"`, ligada e desligada.
  - Selftest (`_desenho`): `desenho: sob a lanterna o papel está em branco e Q não cataloga`; `desenho: com fósforo aceso a cera aparece e Q cataloga`; `desenho: o fósforo apaga e a cera some de novo`; `desenho: a caixa da cabeceira volta com um fósforo quando Elias fica sem chama`; `desenho: na noite 2 a cera está sempre à vista`.
- [ ] **Passo 2:** rodar; esperado: falha por `wax_model.gd` inexistente.
- [ ] **Passo 3:** implementar o modelo.
- [ ] **Passo 4: lugar.** O papel sai da parede do painel e vai para a parede norte do quarto, à cabeceira: papel em `(14.7, 1.5, 0.06)`, traço de cera (`DrawingWax`) em `(14.7, 1.5, 0.03)`, alvo `desenho` no mesmo ponto. Mesa de cabeceira de 0,5 × 0,6 × 0,5 m em `(14.7, 0.3, 0.35)`; em cima, o pickup `{"id": &"fosforo_cabeceira", "kind": &"fosforo", "at": Vector3(14.6, 0.62, 0.35), "n": 3}` e um toco de vela queimado (só malha, sem interação). A noite 1 ganha o pickup e a peça `&"desenho_cera"`. `ITEMS.desenho.gate = &"chama_no_desenho"`.
- [ ] **Passo 5:** a peça liga `DrawingWax.visible` e a flag com `Wax.shows` (chamas: o fósforo na mão enquanto `light.burning()`, e toda `CandleLight` acesa) e, quando `refill_due`, reativa a caixa com `n = 1`.
- [ ] **Passo 6:** gates.
- [ ] **Commit:** `feat: wax drawing in the bedroom only shows under a flame`

## Tarefa 9: O relógio aponta para cada pista (§6.2, §11)

**Files:**
- Modify: `Janghyang/scripts/story/noites.gd` (noite 1: `goals`, `phases`)
- Test: `Janghyang/tests/test_noites.gd`, selftest (`_watch`)

**Interfaces:**
- Consumes: tarefas `cat_relogio`, `cat_desenho`, `cat_casinha`; `main.watch_goal()`.
- Produces: `goals` da noite 1, nesta ordem: `cat_relogio` em `(3.1, 1.0, 8.6)`, `cat_desenho` em `(14.7, 1.5, 0.4)`, `cat_casinha` em `(14.6, 0.6, 8.2)`, `achar_passagem` em `(6.7, 0.6, 0.3)`, `coroa` em `(0.75, 0.2, -0.65)`. Fase 1: `[&"cat_relogio", &"cat_desenho", &"cat_casinha", &"achar_passagem"]`.

- [ ] **Passo 1: testes que falham:** `test_night1_goals_walk_the_clues_in_order` (as cinco tarefas, nessa ordem; todo `at` cai num cômodo da área do goal); `test_every_chapter1_clue_has_a_goal` (toda pista do capítulo 1 tem tarefa em `casa.DEF.catalog` e essa tarefa está em `goals`). Selftest: `watch: aponta para o relógio da entrada, depois o desenho, depois a casinha, depois a cena`; `registro: a coluna meta muda a cada pista` (`playtest_log.sample().meta` acompanha `watch_goal().task`, de modo que `perdido` conta cada pista em separado).
- [ ] **Passo 2:** rodar; falha em "goals in order".
- [ ] **Passo 3:** mudar os dados. Nenhum código: `watch_goal()` já percorre `goals`.
- [ ] **Passo 4:** gates.
- [ ] **Commit:** `feat: pocket watch points at each chapter one clue in order`

## Tarefa 10: A bola quica (§6.2, item 8)

**Files:**
- Create: `Janghyang/scripts/bounce_model.gd`, `Janghyang/scripts/setpieces/bola_quica.gd`, `Janghyang/tests/test_bounce_model.gd`
- Modify: `Janghyang/scripts/areas/casa.gd` (`Ball` 296; `DEF.setpieces`), `Janghyang/scripts/story/noites.gd`
- Test: `Janghyang/tests/test_bounce_model.gd`, selftest

**Interfaces:**
- Consumes: `dread.scripted(&"bola_quica")`; som `quique`; a troca de cômodo de `_track_place`.
- Produces: `BounceModel.HOPS := 5`, `STOP := 0.6`. `static func far_end(ends: Array, elias: Vector3) -> Vector3` (a ponta mais longe dele). `static func hops(from: Vector3, elias: Vector3) -> Array` de `{"t": float, "at": Vector3, "height": float, "db": float}`: cinco quiques em 2,4 s, alturas `0.5 · 0.6^k`, volume `−6 − 5k` dB, o último a `STOP` de Elias, na linha entre `from` e ele.

- [ ] **Passo 1: testes que falham:** `test_bounces_fall_and_fade` (alturas e dB estritamente decrescentes; todo dB ≤ `Director.MAX_DB`; tempos crescentes até 2,4 s); `test_ball_stops_short_of_him` (o último `at` fica a 0,6 m ± 0,01 de Elias, nunca mais perto); `test_it_comes_from_the_far_end` (com as pontas `(9.45, 0, 0.5)` e `(9.45, 0, 6.9)` e Elias em z 1.2, sai de z 6.9; em z 6.0, sai de z 0.5). Selftest (`_bola`): `bola: a primeira entrada no corredor traz a bola até 0,6 m de Elias`; `bola: a segunda entrada não repete`; `bola: catalogável onde parou`; `bola: pedida no 03:33, aparece parada ao lado dele, sem quicar`.
- [ ] **Passo 2:** rodar; falha por arquivo inexistente.
- [ ] **Passo 3:** implementar. Na noite 1 a bola começa escondida na ponta do corredor (`ends` no `DEF` da peça). Na primeira vez que o cômodo de Elias vira `corredor`: se `dread.scripted(&"bola_quica")` der `true`, a bola segue `hops` e toca `quique` em cada um; se der `false`, ela é posta no último `at`, calada (escolha 8 de §0.5). Depois disso vale o `ball.gd` de hoje.
- [ ] **Passo 4:** gates.
- [ ] **Commit:** `feat: the wooden ball bounces out of the dark corridor`

## Tarefa 11: O banco esvazia (§6.2, §8.3, item 4)

**Files:**
- Create: `Janghyang/scripts/bench_model.gd`, `Janghyang/scripts/setpieces/banco.gd`, `Janghyang/tests/test_bench_model.gd`
- Modify: `Janghyang/scripts/areas/casa.gd` (`DEF.bench`, `setpieces`), `Janghyang/scripts/story/noites.gd`
- Test: `Janghyang/tests/test_bench_model.gd`, selftest

**Interfaces:**
- Consumes: `Mannequin.build(Gastos.STYLE, 1.02, &"gasto")`, `set_pose`, `set_seat`, `set_look`; `main.is_seen`; `Staging.CLEAR`; `dread.director.request(&"figura_some", false, tension)`.
- Produces (o modelo é puro; quem pergunta ao mundo é a peça):
  - `const N := 7`, `MAX_AWAY := 3`, `CLEAR := 0.6`, `DOOR_CLEAR := 2.5`.
  - `func _init(seats: Array, away: Array)` — `away`: `[{"at": Vector3, "face": Vector3, "pose": StringName}]`.
  - `var spots: Array` — por figura, `{"at", "face", "pose", "seated": bool}`.
  - `func seated() -> int`.
  - `func on_leave_room() -> void` — arma **uma** saída, se `stage == &"busca"` e menos de `MAX_AWAY` saíram. Chamar de novo sem a saída ter acontecido não arma outra.
  - `func pending() -> int` (índice da figura armada ou −1); `func target_of(i: int) -> Dictionary`.
  - `static func may_land(at: Vector3, elias: Vector3, hideouts: Array, door: Vector3, seen: bool) -> bool` — falso se visto, a menos de `CLEAR` de Elias, dentro de um esconderijo (`AABB`) ou a menos de `DOOR_CLEAR` da porta.
  - `func move(i: int) -> void` — a figura `i` passa para o destino dela.
  - `var stage: StringName = &"busca"` (as Tarefas 12 e 18 leem e mudam).
- `DEF.bench.away` (nesta ordem): sentada na beira da cama `(12.0, 0, 3.0)` olhando para oeste, pose `sentado`; de pé no fim do corredor `(9.45, 0, 0.5)` olhando para o sul; de pé no canto da sala de brincar `(0.5, 0, 0.5)`, de cara para o canto.

- [ ] **Passo 1: testes que falham:**
  - `test_seven_sit_at_first`: `seated() == 7`, `pending() == -1`.
  - `test_one_leaves_per_visit`: `on_leave_room()` duas vezes seguidas arma uma só; depois de `move`, `seated() == 6`; a visita seguinte arma a próxima.
  - `test_at_most_three_leave`: depois de três, `on_leave_room()` não arma mais; `seated() == 4`.
  - `test_they_go_where_the_def_says`: a primeira vai para a cama, sentada; a segunda para o fim do corredor; a terceira para o canto, de costas para a sala.
  - `test_never_lands_on_elias_hideout_or_door` (Review Focus 4): `may_land` é falso com Elias a 0,5 m do destino, com o destino dentro de um `AABB` de esconderijo, a 2,4 m da porta, ou visto; verdadeiro a 0,7 m, fora de esconderijo, a 2,6 m, não visto.
  - `test_def_places_are_legal`: os três `away` e os sete `seats` de `casa.DEF.bench` ficam a ≥ 2,5 m de `DoorFront`, fora de `HideCabana` e `HideCama`, e dentro de um cômodo da casa.
  - Selftest (`_banco`): `banco: sete sentadas na primeira visita`; `banco: Elias sai e volta, faltam uma e ela está na cama do menino`; `banco: ninguém se move enquanto é visto` (Elias olhando o banco pela porta, 10 s: `seated()` não muda); `banco: com Elias parado no destino a figura espera` (não pousa em cima dele); `banco: a cabeça vira para Elias quando ele não olha`; `banco: na noite 2 o banco está vazio`.
- [ ] **Passo 2:** rodar; falha por arquivo inexistente.
- [ ] **Passo 3:** implementar o modelo; unidade verde.
- [ ] **Passo 4:** a peça `banco.gd` constrói as sete figuras (só malha, sem colisão, como as da cena), chama `on_leave_room()` quando o cômodo de Elias deixa de ser `figuras`, e a cada tick, se há `pending()`: confere `may_land` para o assento **e** para o destino (os dois sem ser vistos), pede licença ao diretor (`figura_some`, fraco) e só então chama `move`. Recusado, tenta de novo no tick seguinte. A cada frame, figura que não está sendo vista vira a cabeça para Elias (`set_look`, no máximo 70° para cada lado).
- [ ] **Passo 5:** gates.
- [ ] **Commit:** `feat: seven porcelain figures on the bench leave one by one while unseen`

## Tarefa 12: O catálogo muda sozinho (§6.9, §8.7, item 7)

**Files:**
- Modify: `Janghyang/scripts/catalog.gd`, `Janghyang/scripts/catalog_data.gd`, `Janghyang/scripts/setpieces/banco.gd`, `Janghyang/scripts/areas/casa.gd` (`DEF.targets`)
- Test: `Janghyang/tests/test_catalog.gd`, selftest

**Interfaces:**
- Consumes: `BenchModel.seated()`; `notebook.is_open()`; `dread.director.request(&"catalogo_muda", false, tension)`.
- Produces: item `&"banco_figuras"` com `"text": "banco comprido contra a parede, %s figuras de porcelana sentadas lado a lado. Nenhuma olha para a outra."` (rascunho, D9) e alvo no meio do banco. `Catalog.RECOUNT_MAX := 2`; `Catalog.COUNT_WORDS := {7: "sete", 6: "seis", 5: "cinco", 4: "quatro"}`; `var counts: Dictionary` (item → número atual, posto pela peça; `catalog(item)` troca o `%s` do texto por `COUNT_WORDS[counts[item]]` quando o item tem contagem); `func recount(item: StringName, n: int, notebook_open: bool) -> bool`: reescreve o texto da entrada com o número novo e devolve `true` só se a entrada existe, o caderno está fechado, `n` é menor que o número escrito e a entrada foi reescrita menos de `RECOUNT_MAX` vezes. A entrada guarda `"count"` e `"rewrites"`, que sobrevivem a `to_dict`/`from_dict`.

- [ ] **Passo 1: testes que falham:**

```gdscript
func test_the_entry_counts_the_bench(t) -> void:
	var c = Catalog.new()
	c.counts[&"banco_figuras"] = 7
	t.ok(Catalog.format(c.catalog(&"banco_figuras")).contains("sete figuras"), "seven when he writes it")
func test_recount_rules(t) -> void:
	var c = Catalog.new()
	c.counts[&"banco_figuras"] = 7
	c.catalog(&"banco_figuras")
	t.ok(not c.recount(&"banco_figuras", 6, true), "never with the notebook open")
	t.ok(c.recount(&"banco_figuras", 6, false), "closed: seven becomes six")
	t.ok(Catalog.format(c.entries[-1]).contains("seis figuras"), "in his hand, no erasure")
	t.ok(not c.recount(&"banco_figuras", 7, false), "it never counts up")
	t.ok(c.recount(&"banco_figuras", 5, false), "a second time")
	t.ok(not c.recount(&"banco_figuras", 4, false), "at most twice a night")
func test_recount_before_cataloguing_does_nothing(t) -> void:
	t.ok(not Catalog.new().recount(&"banco_figuras", 6, false), "no entry, no change")
```

  - `test_recount_survives_roundtrip`: depois de `to_dict`/`from_dict`, o texto e o teto continuam valendo.
  - Selftest: `catalogo: o banco catalogado com seis sentadas diz seis`; `catalogo: uma figura sai, o caderno fechado, a entrada passa a dizer uma a menos ao abrir`; `catalogo: com o caderno aberto a entrada não muda na frente dele`.
- [ ] **Passo 2:** rodar; falha em "recount".
- [ ] **Passo 3:** implementar. A peça `banco` atualiza `catalog.counts` a cada `move` e, quando o número cai com a entrada já escrita e o caderno fechado, pede `catalogo_muda` ao diretor antes de chamar `recount`; recusado, tenta no tick seguinte.
- [ ] **Passo 4:** gates.
- [ ] **Commit:** `feat: the bench entry in the notebook rewrites itself as figures leave`

## Tarefa 13: Atrás da parede — a presença e a fresta (§6.2, §8.4, itens 5 e 11)

**Files:**
- Create: `Janghyang/scripts/presence_model.gd`, `Janghyang/scripts/peek_model.gd`, `Janghyang/scripts/setpieces/presenca.gd`, `Janghyang/scripts/setpieces/fresta.gd`, `Janghyang/tests/test_presence_model.gd`, `Janghyang/tests/test_peek_model.gd`
- Modify: `Janghyang/scripts/player.gd` (`_interact`), `Janghyang/scripts/areas/casa.gd` (`DEF.setpieces`), `Janghyang/scripts/story/noites.gd`
- Test: as duas suítes novas, selftest

**Interfaces:**
- Consumes: `main._on_listen`, `player.facing_wall`, `ListenModel.PERIOD` e `WALL_REACH`; sons `porcelain_muffled` e `arrastar`; `dread.director.request(&"olho_fresta", true, tension)`; `step_done(&"achar_passagem")`.
- Produces:
  - `PresenceModel.SPEED := 0.25` (m/s), `STOP := 1.0`, `X_MIN := 0.8`, `X_MAX := 9.0`; `var x := 8.6`; `func update(dt: float, listening: bool, ear_x: float) -> Dictionary` devolve `{"x": float, "drag": bool}`: só anda e só arrasta enquanto `listening`; anda em direção a `ear_x` e para a `STOP` dele; `func stop() -> void` (o painel quebrou: nunca mais arrasta).
  - `PeekModel.SECOND_AFTER := 120.0` (s); `func look(now: float, eye_allowed: bool, panel_broken: bool) -> StringName`: primeira olhada `&"forma"`; depois, antes de `SECOND_AFTER` ou sem licença, `&"escuro"`; com tempo e licença, `&"olho"` (uma vez só); depois do olho, ou com o painel quebrado, `&"nada"`.
  - Em `player.gd`: um objeto que tenha `hold_begin()` e `hold_end()` é "de segurar". `E` apertado chama `hold_begin()`; soltar `E` depois de mais de 0,3 s, apertar `E` de novo, andar, ser agarrado ou abrir o caderno chama `hold_end()`. `player.peeking: bool`.
  - A fresta: risco escuro de 0,02 × 0,25 m na parede norte da sala de brincar em `(3.2, 1.1, 0.01)`; câmera de espiar em `(3.2, 1.0, -0.1)`, virada para leste ao longo da passagem, com o mouse limitado a ±15°.

- [ ] **Passo 1: testes que falham:**
  - `test_drag_only_while_listening`: `update(1.0, false, 3.0).drag` é falso e `x` não muda; com `true`, arrasta e `x` cai 0,25.
  - `test_it_crawls_toward_the_ear_and_stops_short`: 60 s escutando em `ear_x = 3.0` → `x` termina em 4.0 e `drag` passa a falso (parou, não há o que arrastar).
  - `test_silent_after_the_panel`: depois de `stop()`, `drag` é sempre falso.
  - `test_first_look_is_the_far_shape`, `test_eye_needs_time_and_leave` (a 60 s com licença: `&"escuro"`; a 130 s sem licença: `&"escuro"`; a 130 s com licença: `&"olho"`), `test_after_the_eye_nothing`, `test_nothing_once_the_panel_is_broken` (mesmo na primeira olhada).
  - Selftest (`_parede`): `parede: escutando na parede norte, o arrastar toca; soltando L, para em 0,1 s`; `parede: longe da parede norte não há arrastar`; `fresta: E na fresta troca a câmera e soltar devolve`; `fresta: o controle não é tirado` (andar durante a olhada devolve a câmera e Elias anda); `test_peek_ends_when_grabbed` como checagem `fresta: ser agarrado no meio da olhada devolve a câmera e a luta começa` (Review Focus 5); `fresta: abrir o caderno devolve a câmera`.
- [ ] **Passo 2:** rodar; falha por arquivos inexistentes.
- [ ] **Passo 3:** implementar os dois modelos; unidade verde.
- [ ] **Passo 4:** `presenca.gd`: ativa na noite 1 enquanto o painel está de pé, fora do 03:33, com Elias escutando (`L`) a ≤ `WALL_REACH` da parede norte da sala de brincar. Toca `porcelain_muffled` a cada `PERIOD` e `arrastar` em laço a −14 dB, os dois no ponto `(x, 0.3, -0.65)`; o laço corta em 0,1 s quando `drag` vira falso. Não cumpre tarefa nenhuma (§10).
- [ ] **Passo 5:** `fresta.gd` e o segurar no `player.gd`. `&"forma"`: um manequim do Gasto agachado em `(8.6, 0, -0.65)`, mal iluminado, que some quando a olhada acaba. `&"olho"`: uma esfera de porcelana de 5 cm com íris, a 8 cm da câmera; não pisca, não recua; some quando a olhada acaba. `&"escuro"` e `&"nada"`: só a passagem escura. Nenhum som em nenhum dos quatro.
- [ ] **Passo 6:** gates.
- [ ] **Commit:** `feat: something drags behind the playroom wall and looks back through the crack`

## Tarefa 14: O reflexo que fica (§6.2, item 12)

**Files:**
- Create: `Janghyang/scripts/stay_model.gd`, `Janghyang/scripts/setpieces/reflexo_fica.gd`, `Janghyang/tests/test_stay_model.gd`
- Modify: `Janghyang/scripts/mirror_reflection.gd`, `Janghyang/scripts/areas/casa.gd` (`DEF.setpieces`), `Janghyang/scripts/story/noites.gd` (noite 1: `"mute_scares": [&"duplo_espelho"]`)
- Test: `Janghyang/tests/test_stay_model.gd`, selftest

**Interfaces:**
- Consumes: sinal `main.cataloged`; `WaxModel.shows`; `main.in_bedroom`; `dread.director.request(&"reflexo_fica", true, tension)`.
- Produces: `StayModel` com `var state: StringName` (`&"normal"` → `&"armado"` → `&"fica"` → `&"feito"`); `func arm() -> void`; `func update(in_front: bool, in_room: bool, flame: bool, allowed: Callable) -> StringName`. Armado: se a chama apaga ou Elias sai do quarto, `&"feito"` (a ocasião passou); se Elias sai da frente do espelho e `allowed.call()` devolve `true`, `&"fica"`. Em `&"fica"`: Elias volta para a frente ou sai do quarto → `&"feito"`. `MirrorReflection.stay(on: bool) -> void`: o reflexo para de copiar Elias, fica de pé onde estava e vira a cabeça para onde ele está. "Na frente" = dentro de `Rect2(13.9, 0.0, 1.5, 3.2)` (dado da peça no `DEF`).

- [ ] **Passo 1: testes que falham:** `test_arms_only_once`; `test_stays_when_he_steps_away_with_the_flame_lit` (armado, `in_front = false`, chama acesa, licença → `&"fica"`); `test_no_leave_no_scare` (licença negada: continua `&"armado"` e `allowed` é chamado de novo no tick seguinte); `test_flame_out_ends_it`; `test_back_in_front_releases_it`; `test_leaving_the_room_releases_it`; `test_done_is_final`. Selftest: `reflexo: catalogar o desenho com a chama acesa arma a peça`; `reflexo: sem som` (nenhum `play_at` entre `&"fica"` e `&"feito"`). O tipo `duplo_espelho` existe no diretor, mas nenhum código o pede hoje (conferido em 2026-11-10): a peça nova usa `reflexo_fica`, e o `mute_scares` acima é só guarda, coberto pelo teste de mudo da Tarefa 5.
- [ ] **Passo 2:** rodar; falha por arquivo inexistente.
- [ ] **Passo 3:** implementar modelo, `stay()` e a peça (que chama `arm()` quando `cataloged` traz `desenho`).
- [ ] **Passo 4:** gates.
- [ ] **Commit:** `feat: the bedroom reflection stays behind after the drawing is catalogued`

## Tarefa 15: O painel — só cede no fim da cena, cara a cara, e a casa deixa de ser segura (§5, §6.3–6.5, itens 3 e 9)

**Files:**
- Create: `Janghyang/scripts/panel_figure_model.gd`, `Janghyang/scripts/setpieces/figura_painel.gd`, `Janghyang/tests/test_panel_figure_model.gd`
- Modify: `Janghyang/scripts/breakable.gd`, `Janghyang/scripts/main.gd` (`begin_night` 920, `_tick_staging` 1302), `Janghyang/scripts/areas/passagem.gd` (`DEF.locks`, `setpieces`), `Janghyang/scripts/story/noites.gd` (noite 1: `safety`, `stalkers`)
- Test: `Janghyang/tests/test_breakable.gd`, `Janghyang/tests/test_panel_figure_model.gd`, `Janghyang/tests/test_night_stalkers.gd`, `Janghyang/tests/test_noites.gd`, selftest

**Interfaces:**
- Consumes: `Safety.rule_of` e `raio_relogio` (Tarefa 2); degraus com `levels` e flag (Tarefa 3); `dread.scripted(&"figura_painel")`; som `madeira`; `HollowPanel.shattered`.
- Produces:
  - `Breakable.locked: bool` (padrão `false`): trancado, `hit()` treme, devolve `&"crack"` (soa oco) e **não** conta a batida.
  - `passagem.DEF.locks = {"HollowPanel": 1}`. `main` tranca os nós de `locks` cujo capítulo é da noite em `begin_night` e destranca quando `ch.staging.done()`.
  - `PanelFigure.NEAR := 3.0`; `var state: StringName` (`&"oculta"`, `&"parada"`, `&"saiu"`); `func reveal() -> void`; `func update(dist: float, seen: bool) -> StringName` (em `&"parada"`, passa a `&"saiu"` quando `dist > NEAR` e não vista); `func hit() -> void` (a bengala: `&"saiu"` na hora); `func grabs() -> bool` (sempre `false`).
  - Flag da noite `&"figura_saiu"`.
  - Noite 1: `"safety": [{"after": &"", "rule": &"casa_toda"}, {"after": &"achar_passagem", "rule": &"raio_relogio"}]` e `"stalkers": [{"after": &"", "n": 0}, {"after": &"figura_saiu", "n": 1, "levels": [&"casa"]}]` (o degrau da coroa sai aqui e volta na Tarefa 17).

- [ ] **Passo 1: testes que falham:**
  - `test_locked_never_breaks` (Review Focus 5): trancado, 20 chamadas de `hit()` devolvem `&"crack"`, `hits == 0`, `broken == false`.
  - `test_unlocked_breaks_in_hits_needed`: destrancado depois disso, quebra em `hits_needed` batidas.
  - `test_it_stands_while_he_is_close` (2,9 m, não vista → `&"parada"`); `test_it_stands_while_seen` (5 m, vista → `&"parada"`); `test_it_leaves_when_far_and_unseen` (3,1 m, não vista → `&"saiu"`); `test_it_never_grabs`; `test_the_stick_sends_it_away`.
  - `test_night_stalkers.gd`: a noite 1 passa a `0` antes de `figura_saiu`, `1` na casa depois, `0` na passagem (substitui "0 antes da coroa, 1 depois").
  - `test_noites.gd`: `test_night1_house_is_safe_only_until_the_panel` (os dois degraus de `safety`); `test_last_pose_is_the_boy_at_the_panel` (a última pose do menino em `casa.DEF.staging` é `agachado` em `(6.7, 0, 0.35)` com `reach` em `(6.7, 0.5, 0.0)`: já é assim hoje, o teste só prende).
  - Selftest (`_painel`): `painel: antes do fim da cena soa oco e não quebra`; `painel: depois da última pose quebra em três batidas`; `painel: ao quebrar há uma figura atrás dele, parada, e nenhum som além da madeira`; `painel: a 2 m dela, 10 s de costas, Elias não é agarrado`; `painel: a mais de 3 m e sem olhar, o buraco fica vazio e a flag figura_saiu sobe`; `painel: depois disso a sala de brincar não é mais segura e o raio do relógio é`; `painel: de volta à casa antes da coroa há um Gasto nela`; `painel: quebrado durante o 03:33, a figura não aparece e a flag sobe assim mesmo`; `painel: capturado depois dele, Elias acorda ao lado do relógio da entrada`.
- [ ] **Passo 2:** rodar; falha em "locked never breaks".
- [ ] **Passo 3:** `breakable.gd` e a trava em `main.gd`.
- [ ] **Passo 4:** modelo e peça. No `shattered`: toca `madeira` (−6 dB) e, se `dread.scripted(&"figura_painel")`, mostra um manequim do Gasto (`Gastos.STYLE`, 1.02, corpo `gasto`), pose `agachado`, em `(6.7, 0, -0.9)`, de frente para o buraco, só malha; a cabeça segue Elias (`set_look`) enquanto `&"parada"`. Ao passar a `&"saiu"`, some e levanta `figura_saiu`. Se o diretor recusar (03:33), a flag sobe sem figura.
- [ ] **Passo 5:** mudar os dados da noite 1 e reescrever as checagens de `_safety`, `_nights` e `_capture` que assumem casa segura a noite toda.
- [ ] **Passo 6:** gates.
- [ ] **Commit:** `feat: the panel yields after the scene, a figure waits behind it and the house stops being safe`

## Tarefa 16: A passagem — poço fechado, caixa de música, nicho e giz (§6.6, §8.6, itens 1 e 2)

**Files:**
- Create: `Janghyang/scripts/phrase_model.gd`, `Janghyang/scripts/setpieces/caixa_passagem.gd`, `Janghyang/tests/test_phrase_model.gd`
- Modify: `Janghyang/scripts/areas/passagem.gd` (parede norte, `LadderShaft`, `DEF.chalk`, `targets`, `setpieces`), `Janghyang/scripts/areas/casa.gd` (`MusicBox` 262–, que muda de arquivo), `Janghyang/scripts/main.gd` (`_track_place` 1405), `Janghyang/scripts/story/noites.gd`
- Test: `Janghyang/tests/test_phrase_model.gd`, `Janghyang/tests/test_registry.gd`, selftest

**Interfaces:**
- Consumes: `main._hideout`; som `caixa_frase`; `night.closed`.
- Produces:
  - Nó `ShaftHatch` (tampa de madeira que fecha o poço em y ≈ `CRAWL_TOP`); com `&"ShaftHatch"` em `night.closed` ele existe e o `LadderShaft` fica desligado. Noite 1: `"closed": [&"ShaftHatch"]`.
  - `MusicBox` em `(8.4, 1.0, -1.15)`, num vão entre dois caibros; alvo `caixa_musica` no mesmo ponto.
  - `PhraseModel.ON := 4.0`, `OFF := 9.0`; `static func starts(t0: float, t1: float) -> bool` (uma frase começa em `(t0, t1]`; a primeira aos `OFF` segundos).
  - `giz_passagem`: pontos `(7.2, -0.9)`, `(7.8, -1.0)`, `(8.3, -1.1)` em y 0.006, `leads_to: &"caixa_musica"`.
  - Nicho: recuo na parede norte de x 3.15 a 4.05, z −1.37 a −2.25, 1,0 m de altura, com almofada e três riscos de giz (`_chalk`); esconderijo `HideNicho`, centro `(3.6, 0.5, -1.8)`, tamanho `(0.9, 1.0, 0.85)`. **Sem cômodo novo no atlas.** O centro fica a 1,93 m do ponto 2.05 do grafo e a 1,32 m do ponto 4.25: um Gasto parado no 4.25 está "perto"; no 2.05, não.

- [ ] **Passo 1: testes que falham:** `test_phrase_then_silence` (em 0–13 s começa exatamente uma frase, aos 9 s; a seguinte aos 22 s); `test_passage_trail_leads_to_the_music_box` (`test_registry.gd`); `test_niche_is_near_one_point_only` (com `Gastos.NEAR` e os pontos da passagem, o centro do nicho fica dentro do raio de x 4.25 e fora do de x 2.05). Selftest (`_passagem`): `passagem: na noite 1 o poço está tampado e Elias não sobe`; `passagem: na noite 2 não há tampa`; `passagem: a caixa toca 4 s e cala 9 s, e para quando é catalogada`; `passagem: a caixa só toca com Elias na passagem e fora do 03:33`; `passagem: de olhos fechados o giz leva à caixa` (acessibilidade, §10); `nicho: agachado lá dentro Elias conta como escondido`; `nicho: dentro dele o nível continua passagem e o relógio de bolso não dá erro`.
- [ ] **Passo 2:** rodar; falha por arquivo inexistente.
- [ ] **Passo 3:** implementar. A parede norte vira dois trechos mais a verga sobre o nicho. Se `_track_place` hoje perde o nível quando Elias está fora de todo cômodo, passa a manter o último.
- [ ] **Passo 4:** a peça toca `caixa_frase` a −10 dB na caixa a cada começo de frase, enquanto a caixa não foi catalogada. Fora da noite 1 a caixa fica lá, calada (o susto antigo `caixa_musica` do `dread.gd` continua tocando no nó `MusicBox`, onde ele estiver).
- [ ] **Passo 5:** gates.
- [ ] **Commit:** `feat: passage gets the music box, the boy's niche and a closed shaft on night one`

## Tarefa 17: O beco (§6.6, §10, itens 2 e 10)

**Files:**
- Create: `Janghyang/scripts/beco_model.gd`, `Janghyang/scripts/setpieces/beco.gd`, `Janghyang/tests/test_beco_model.gd`
- Modify: `Janghyang/scripts/areas/passagem.gd` (`DEF.setpieces`), `Janghyang/scripts/story/noites.gd` (noite 1: terceiro degrau de `stalkers`)
- Test: `Janghyang/tests/test_beco_model.gd`, selftest

**Interfaces:**
- Consumes: `main._complete(&"coroa")` (a coroa foi pega); `dread.scripted(&"lanterna_pisca")`; `main.lantern_dim`; `gastos.lure`, `gastos.lured`; `birth` (Tarefa 3); `passing` e `hold_step` (Tarefa 4); `settings.reduce_flash`; `NoiseModel.BREATH_MAX` (8.0).
- Produces:
  - `BecoModel.ON := 2.0`, `OFF := 1.5`, `RAMP := 0.15`, `RAMP_SOFT := 0.6`, `MAX_DARKS := 6`, `LURE := 14.0`.
  - `static func dark(t: float) -> bool`: `t` em segundos desde a coroa; escuro em `[0, OFF)`, depois claro por `ON`, e assim por diante. **Não depende de `reduce_flash`.**
  - `static func dim(t: float, soft: bool) -> float`: 0 no escuro, 1 no claro, rampa linear de `RAMP` (ou `RAMP_SOFT` com `soft`) nas bordas, sempre dentro da janela clara; nunca passa de 1.0.
  - `static func over(t: float, lured: bool, grabbed: bool) -> bool`: acaba quando a isca acabou, Elias foi agarrado ou passaram `MAX_DARKS` apagões.
  - Flag `&"beco_apagou"` (levantada no primeiro apagão). Noite 1, terceiro degrau: `{"after": &"beco_apagou", "n": 1, "birth": {"level": &"passagem", "at": Vector3(6.45, 0.0, -0.65)}}`.
  - Noite 1: `mute_scares` ganha `&"lanterna_pisca"`. Hoje o `dread.gd` (linha 117) pede esse tipo como forte quando a tensão passa de 0,8; se ele viesse antes da coroa, o tipo ficaria usado e o beco seria pulado. Mudo, o pisca fica guardado para o beco (escolha 10 de §0.5).

O roteiro, com as regras que já existem: a coroa é pega em t = 0 e a lanterna apaga; no primeiro escuro o Gasto nasce no ponto 6.45, ao lado do painel. Atraído para a coroa, ele só anda no escuro, um ponto por apagão (1,2 s depois de a luz cair): chega ao 4.25 em t = 4,7 s, ao 2.05 em t = 8,2 s, e agarra quem ainda estiver na coroa em t = 11,7 s. Quem está no nicho precisa de fôlego só enquanto ele está no 4.25: 3,5 s de um fôlego de 8 s.

- [ ] **Passo 1: testes que falham.** A simulação usa o `StalkerModel` de verdade sobre os quatro pontos da passagem, com `hold_step()` nos ticks claros, e um Elias de roteiro (posição em x por tempo, olhando ou não, escondido ou não, com ou sem fôlego); "perto" é a distância a `Gastos.NEAR`.
  - `test_night1_keeps_the_flicker_for_the_dead_end` (`test_noites.gd`, Review Focus 5): `mute_scares` da noite 1 contém `&"lanterna_pisca"`; nas noites 2 a 5 não.
  - `test_dark_windows`: `dark(0.0)`, `dark(1.49)`, `not dark(1.5)`, `not dark(3.49)`, `dark(3.5)`.
  - `test_under_three_flashes_a_second`: em qualquer janela de 1 s há no máximo uma passagem de claro para escuro; `dim` nunca passa de 1.0 (§10).
  - `test_reduce_flash_keeps_the_same_dark_windows` (Review Focus 3): `dark(t)` é igual com e sem `soft` para t de 0 a 20 s em passos de 0,05; com `soft`, `dim` nunca varia mais de 0,1 entre dois passos.
  - `test_the_figure_comes_one_point_per_dark`: nascido no índice 2, está no 1 em t = 4,7 ± 0,1 e no 0 em t = 8,2 ± 0,1, com Elias olhando ou não nas janelas claras.
  - `test_staying_at_the_crown_gets_him_caught`: Elias parado em x 0.75 → `&"caught"` entre 10 e 13 s.
  - `test_the_niche_and_one_breath_save_him`: Elias reage aos 2 s, engatinha a 1,2 m/s até x 3.6, esconde-se e prende o fôlego enquanto o Gasto está perto → nunca `&"caught"`, e o tempo de fôlego fica ≤ 6 s (8 s menos 2 s de folga).
  - `test_slow_player_still_reaches_the_niche` (Review Focus 3): o mesmo, reagindo aos 5 s → não é agarrado.
  - `test_no_breath_is_found` (Review Focus 3): no nicho sem prender o fôlego → `&"caught"` em `HIDE_FOUND` depois de ele chegar ao 4.25.
  - `test_looking_back_freezes_it`: depois da passagem dele, Elias sai do nicho e vai até x 6.7 a 1,2 m/s, olhando para trás nos primeiros 0,5 s → não é agarrado.
  - `test_lingering_in_the_niche_is_not_safe`: quem fica no nicho 20 s depois de a isca acabar é achado ou vê o Gasto desistir, nunca fica em paz para sempre.
- [ ] **Passo 2:** rodar; falha por arquivo inexistente.
- [ ] **Passo 3:** implementar o modelo. Se a simulação não fechar com os valores acima, ajustar **só** `ON`, `OFF`, `LURE` e a posição x do nicho (Tarefa 16), nessa ordem, e registrar `Ruling:` com os valores finais. O limite que não muda: fôlego exigido ≤ 6 s, e piscar abaixo de 3 por segundo.
- [ ] **Passo 4:** a peça. Quando `coroa` é feita na noite 1: se `dread.scripted(&"lanterna_pisca")` for `true`, começa o ciclo (`main.lantern_dim = BecoModel.dim(t, settings.reduce_flash)`), levanta `beco_apagou` no primeiro escuro e chama `gastos.lure(<posição da coroa>, LURE)`; quando `over`, `lantern_dim` volta a 1.0. Se for `false` (03:33), só levanta a flag. Nenhum som novo: o Gasto no beco faz o tique de porcelana de sempre.
- [ ] **Passo 5: selftest** (`_beco`): `beco: pegar a coroa apaga a lanterna e há um Gasto ao lado do painel quando ela volta`; `beco: a cada apagão ele está um ponto mais perto`; `beco: no nicho, sem respirar, ele passa e Elias sai pelo painel`; `beco: parado na coroa, Elias é agarrado, solta-se com os cliques e continua com a coroa`; `beco: sem se soltar, acorda ao lado do relógio da entrada com a coroa`; `beco: com reduzir piscar a lanterna nunca muda mais de 10% por frame e o Gasto chega no mesmo tempo`; `beco: com um fósforo aceso, encarar 3,5 s o desfaz` (escolha 4 de §0.5); `beco: não acontece duas vezes na noite`.
- [ ] **Passo 6:** gates.
- [ ] **Commit:** `feat: the dead end, the flickering lantern and the niche that takes one breath`

## Tarefa 18: A travessia e a vigília (§6.7, §6.8, itens 3 e 4)

**Files:**
- Modify: `Janghyang/scripts/bench_model.gd`, `Janghyang/scripts/setpieces/banco.gd`, `Janghyang/scripts/areas/casa.gd` (`DEF.bench.crossing`)
- Test: `Janghyang/tests/test_bench_model.gd`, selftest

**Interfaces:**
- Consumes: `BenchModel` (Tarefa 11); `step_done(&"coroa")`; `Safety.is_safe` com a regra corrente; `Staging.UNSEEN` (1.5); sinal `hora_started`.
- Produces:
  - `BenchModel.RING := 4.3`, `HOP := 2.2`.
  - `func set_stage(s: StringName) -> void`: `&"travessia"` manda todas as figuras ainda sentadas, menos uma, para os lugares de `crossing` (cada uma espera `may_land`, como na busca; aqui o teto de três não vale). `&"vigilia"` dá a cada figura fora do banco um ponto do anel.
  - `static func ring_points(clock: Vector3, candidates: Array, door: Vector3) -> Array`: dos candidatos, os que ficam a `RING` ± 0,05 do relógio e a ≥ `DOOR_CLEAR` da porta.
  - `func creep(i: int, elias: Vector3, seen: bool, unseen_for: float) -> bool`: na vigília, a figura `i`, não vista há ≥ `UNSEEN`, dá um salto de no máximo `HOP` em direção ao ponto dela; nunca pousa a menos de `RING` do relógio nem a menos de `CLEAR` de Elias; no ponto, vira-se para ele.
  - `var frozen: bool` (ligado no `hora_started`: ninguém se move mais).
  - `DEF.bench.crossing`: `(5.0, 0, 3.2)`, `(3.4, 0, 5.6)`, `(7.4, 0, 4.6)`, `(8.9, 0, 3.8)`, `(6.2, 0, 6.2)`, `(4.6, 0, 1.6)`, de pé, viradas para o painel.

- [ ] **Passo 1: testes que falham:**
  - `test_crossing_empties_all_but_one`: com 5 sentadas, `set_stage(&"travessia")` e os saltos feitos, `seated() == 1`; nenhum lugar repetido.
  - `test_crossing_spots_are_legal`: os seis `crossing` ficam a ≥ 2,5 m de `DoorFront`, fora dos esconderijos, dentro de `brincar` ou `corredor`, a ≥ 0,6 m um do outro, e nenhum a menos de 1,0 m da linha reta do painel `(6.7, 0, 0.6)` à porta da sala de brincar `(1.8, 0, 7.0)`: o caminho fica livre.
  - `test_ring_stays_outside_the_radius_and_off_the_door` (Review Focus 4): todo ponto de `ring_points` fica a > `Safety.ANCHOR_RADIUS` do relógio e a ≥ 2,5 m da porta; nenhum salto de `creep`, de qualquer ponto de partida de `crossing`, pousa a ≤ 4,0 m do relógio nem a < 0,6 m de Elias, com Elias em qualquer ponto do raio.
  - `test_they_only_creep_unseen`: `creep` com `seen = true` ou `unseen_for < 1.5` devolve `false`.
  - `test_frozen_at_the_hour`: com `frozen`, `creep` e `move` não mudam nada.
  - Selftest (`_travessia`): `travessia: ao sair do painel com a coroa há figuras de pé na sala de brincar e uma só no banco`; `travessia: uma das figuras de pé é o Gasto e tem o mesmo corpo das outras` (mesma malha, mesma escala); `travessia: do painel ao raio do relógio o caminho está livre`; `vigilia: dentro do raio Elias não é agarrado`; `vigilia: desviando o olhar, as figuras chegam à beira do raio e param viradas para ele`; `vigilia: nenhuma entra no raio nem fica a menos de 2,5 m da porta da rua, e a porta abre`; `vigilia: quando o 03:33 começa ninguém mais se move`.
- [ ] **Passo 2:** rodar; falha em "set_stage".
- [ ] **Passo 3:** implementar. A peça `banco` chama `set_stage(&"travessia")` quando `coroa` é feita e `set_stage(&"vigilia")` na primeira vez que Elias, depois da coroa, está em ponto seguro; os candidatos do anel são calculados uma vez (de 20° em 20° em volta de `EntryClock`, só os que caem num cômodo da casa a ≥ 0,4 m de parede). Nenhum som: a vigília é muda.
- [ ] **Passo 4:** gates.
- [ ] **Commit:** `feat: standing figures on the way back and a silent ring around the entry clock`

## Tarefa 19: Selftest de ponta a ponta e o bot novo (§12, §13)

**Files:**
- Modify: `Janghyang/scripts/selftest.gd`, `Janghyang/tests/bot_noite1.gd` (`_run` 296–420)
- Test: os próprios

**Interfaces:**
- Consumes: tudo. Os helpers do bot que já existem: `_walk`, `_reach`, `_catalog`, `_key`, `_tap`, `_look_at`.
- Produces: `BOT RESULT ok` e o tempo do piso novo.

- [ ] **Passo 1: selftest** (bloco `_noite1`): `noite1: as doze peças de cena da noite existem e nenhuma outra noite as liga`; `noite1: nenhum som da noite toca acima de 0 dB` (percorre todo `play_at` feito pelas peças numa noite inteira acelerada); `noite1: quatro dos sete sustos novos são mudos` (reflexo, olho, figura do painel, catálogo: zero `play_at`); `noite1: cada susto de roteiro acontece uma vez`; `noite1: as noites 2 a 5 começam com a mesma segurança e os mesmos Gastos de antes`.
- [ ] **Passo 2: o bot novo**, nesta ordem: guarda a carta → cataloga o relógio da entrada → entra no corredor (a bola vem) e cataloga a bola → quarto: pega os fósforos da cabeceira, risca um, cataloga o desenho → sala das figuras: tenta o armário trancado → segue o giz até a cabana, pega a chave → volta, abre o armário, cataloga a casinha → sala de brincar: espera as quatro poses sem olhar para a cena → bate no painel três vezes → abaixa, passa pela figura, vai para leste → cataloga a caixa de música → espera a cena do capítulo 2 → vai até a coroa e pega → volta até o nicho, agacha, prende a respiração (`H`) até o Gasto passar → sai, vai ao painel → atravessa a sala de brincar olhando para a figura mais próxima a cada 2 s → entra no raio do relógio → espera → dá corda.
- [ ] **Passo 3:** rodar o bot até `BOT RESULT ok` três vezes seguidas com o mesmo tempo (± 2 s). Se o tempo ficar fora de 4 a 6 minutos (§12), **não** forçar: anotar o valor medido no ledger e levar a Pedro.
- [ ] **Passo 4:** rodar o bot uma quarta vez com `reduce_flash` ligado; tem de fechar também.
- [ ] **Passo 5:** gates completos (os quatro).
- [ ] **Commit:** `test: rewrite the night one bot and end-to-end self-checks for the new night`

## Tarefa 20: Binários, roteiro do playtest e memória do projeto (§13)

**Files:**
- Modify: `Janghyang/build/linux/Janghyang`, `Janghyang/build/windows/Janghyang.exe` (refeitos), `context/discussoes/playtest-1.md`, `context/decisoes.md`, `context/arquitetura.md`, `context/historico.md`, `context/achados.md` (se houver), `docs/superpowers/plans/2026-11-08-janghyang-demo.md` (Tarefa 26)

- [ ] **Passo 1:** exportar de `Janghyang/`: `godot --headless --path . --export-release "Linux" build/linux/Janghyang` e `--export-release "Windows" build/windows/Janghyang.exe`. Rodar o selftest no binário Linux (`build/linux/Janghyang --headless -- --selftest`); o número tem de bater com o do editor.
- [ ] **Passo 2:** 20 s de `build/linux/Janghyang -- --playtest --night=1`: o CSV grava a cada 5 s com `meta = cat_relogio` e sem erro no log.
- [ ] **Passo 3: `playtest-1.md`** (linhas novas com data e `(i)`/`(e)`; as antigas ganham `~superseded`, nada se apaga): o piso novo do bot no lugar dos 81 s; o teto de 30 minutos (§12, escolha da IA à espera de Pedro); o que observar nos trechos novos — se a pessoa risca o fósforo no quarto sem ajuda, se segue o giz até a chave, se escuta a parede e olha a fresta, o que faz diante da figura do painel, se acha o nicho e prende a respiração, se olha para trás na travessia, o que faz na vigília; a linha dos binários novos. O aviso "É um jogo de terror sem sustos de volume" fica como está.
- [ ] **Passo 4: `context/`**: em `decisoes.md`, uma linha `(i)` por `Ruling:` do ledger e pelas escolhas de §0.5; em `arquitetura.md`, o que mudou de estrutura (peças de cena, chaves de `DEF` e de noite, modelos novos); em `historico.md`, o bloco da sessão; na Tarefa 26 do plano da demo, a nota de que a noite nova está pronta.
- [ ] **Passo 5:** `python3 lint.py` e os quatro gates.
- [ ] **Commit:** `chore: rebuild binaries and update the playtest script for the new night one`

---

## Cobertura do spec

| Spec | Tarefa |
|---|---|
| §5 R12 na noite 1, quando o Gasto entra | 2, 3, 15 |
| §5 D10 fechada, `MAX_DB = 0` como regra | 5, 19 |
| §5 e §6.3 o painel só cede na última pose | 15 |
| §6.1 a luz de fora (6) | 6 |
| §6.2 relógio aponta para as três pistas | 9 |
| §6.2 a bola (8) | 10 |
| §6.2 o desenho e os fósforos (1) | 8 |
| §6.2 o reflexo que fica (12) | 14 |
| §6.2 a casinha trancada, a chave, o giz (1) | 7 |
| §6.2 o banco esvazia (4) | 11 |
| §6.2 atrás da parede, a fresta (5, 11) | 13 |
| §6.4 cara a cara (9), §6.5 a casa deixa de ser segura (3) | 15 |
| §6.6 poço fechado, caixa de música, nicho | 16 |
| §6.6 o beco (2, 10) | 4, 17 |
| §6.7 a travessia, §6.8 a vigília | 18 |
| §6.9 o catálogo muda (7) | 12 |
| §8.1–8.8 | 2, 3, 11, 13, 7, 16, 12, 5 |
| §9 orçamento e sons | 5, 19 |
| §10 acessibilidade | 13 (toque ou segurar), 16 (giz até a caixa), 17 (reduzir piscar) |
| §11 orientação, `perdido` por pista | 9 |
| §12 duração | 19 (medida), 20 (roteiro) |
| §13 testes, bot, binários, playtest | 1–20 |
| §14 o que fica para quem constrói | fechado em cada tarefa; ajustes viram `Ruling:` |
