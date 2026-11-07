# FAZ DE CONTA — o relojoeiro: plano de implementação do slice

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transformar o blockout de `faz-de-conta/` numa visita completa de 20–30 min. Elias cataloga a maquete por dentro, a casa grava e devolve gestos, às 03:33 os ecos dele aparecem, a verdade sobre Inácio chega por páginas curtas e a saída pela beira do tampo fecha com a escolha do relógio. Algo de Elias fica para sempre na maquete.

**Architecture:**
- A lógica de jogo mora em scripts `RefCounted` puros, sem `class_name` e carregados por `preload("res://scripts/x.gd")`. São eles: relógio, visita, catálogo, gravador de ecos, espelho, frestas, duplo e fim. Esses scripts são testados por um harness unitário headless.
- Os nós de cena (relógio da entrada, alvos de catálogo, caderno, ecos, evento 03:33, fim) só leem e escrevem esses modelos.
- `main.gd` continua gerando toda a geometria e faz a fiação nas funções `_build_*`.
- O autoteste de circulação (`selftest.gd`) ganha checagens a cada tarefa.

**Tech Stack:** Godot 4.7.2.stable, renderer GL Compatibility e GDScript. O som é sintetizado em `AudioStreamWAV` por código. Sem assets externos e sem dependências novas.

**Spec:** `docs/superpowers/specs/2026-10-27-faz-de-conta-relojoeiro-design.md`. A seção 5.3 está na versão com "algo dele fica para sempre na maquete".

## Global Constraints

- Godot **4.7.2**, renderer GL Compatibility. Projeto em `faz-de-conta/`; a geometria continua gerada por `scripts/main.gd`.
- **Sem novas dependências, plugins ou middleware de áudio.** O som é sintetizado em GDScript.
- O autoteste `godot --headless --path . -- --selftest` termina verde ao fim de **toda** tarefa e ganha checagens novas para o que foi construído.
- Sem HUD de objetivo: **não há contador "x de y"**, checklist nem marcador de objetivo. O texto de história existe **só** no caderno e nas páginas, como papel.
- **A porta da rua (`DoorFront`) está sempre aberta e nunca tranca**, inclusive durante o 03:33.
- Nenhum eco, figura ou duplo se move em direção ao jogador de forma intencional, toca o jogador ou bloqueia o caminho até a porta. **Nada disso tem colisão.**
- Os ecos e a casa **só repetem o que o jogador fez**; nunca inventam um gesto. A única exceção prevista é a bola como convite.
- As páginas de diário têm **no máximo 4 linhas** cada.
- O 03:33 acontece **uma vez** por visita.
- Sem gore, jump scare ou sting alto. O pico de qualquer som sintetizado fica em **≤ 0.5** de full-scale.
- O diretório **não é um repositório Git**, então as tarefas não têm passo de commit; cada tarefa termina num checkpoint. Se o Git for introduzido, use Conventional Commits em inglês, **sem** `Co-Authored-By` nem menção à IA.
- Texto visível ao jogador fica em pt-BR, com acentos. Identificadores e rótulos do selftest ficam em inglês, como no código atual.
- Scripts de lógica **não declaram `class_name`**. Quem usa faz `const X = preload("res://scripts/x.gd")`. Por quê: assim o harness rodado com `-s` não depende do cache de classes do editor.
- Achados novos (bug, risco, débito) vão para `context/achados.md` assim que aparecem. As decisões `(i)` deste plano são registradas na Tarefa 15.

### Checkpoint padrão (CP)

Rodar a partir de `/home/usuario/Dev/Jogo/faz-de-conta`:

```bash
godot --headless --path . -s res://tests/run_unit.gd      # a partir da Tarefa 3
godot --headless --path . -- --selftest
cd /home/usuario/Dev/Jogo && python lint.py
```

Resultado esperado:
- `UNIT RESULT: N checks, 0 failures` com código de saída 0.
- `SELFTEST RESULT: N checks, 0 failures` com código de saída 0.
- O lint passa sem erros.

Abra também o jogo uma vez (`godot --path .`) e confirme que ele carrega e anda.

## Review Focus

1. **Sair durante o 03:33.** Com os ecos ativos, o caminho entrada → porta → beira do tampo continua livre e a `ExitEdge` encerra a visita com `&"incompleto"`. Testes: Tarefa 10 (circulação durante e depois do evento) e Tarefa 14 (saída durante HORA).
2. **Jogador que nunca cataloga o boneco.** Ele chega ao 03:33 por tempo, até `MAX_PRE_HORA + HURRY_SPRING / DRAIN_CALM + 1` s, sem depender de nenhum item. Teste: Tarefa 6, `test_time_gate_without_doll`.
3. **Dobra sobre o jogador agachado.** O F1 não se move com o jogador dentro do volume da cabana, e o jogador não se levanta sob a dobra. Teste: Tarefa 1, bloco "cabana" do selftest.
4. **Spam de corda.** Cada corda rende no mínimo `WIND_FLOOR`, o total nunca passa de `SPRING_MAX` e o 03:33 acontece até `HARD_LIMIT`. Testes: Tarefa 3, `test_wind_diminishes_to_floor`, e Tarefa 6, `test_wind_spam_cannot_prevent_hora`.
5. **Sessão muito longa.** O gravador respeita `MAX_SAMPLES` e os trechos escolhidos apontam só para amostras retidas. Teste: Tarefa 8, `test_cap_and_segments_in_range`.

---

### Task 1: Agachar e cabana entrável (fecha `achados#a-001`)

**Files:**
- Modify: `faz-de-conta/scripts/player.gd` (input, `_physics_process`)
- Modify: `faz-de-conta/scripts/foldable.gd` (`interact`)
- Modify: `faz-de-conta/scripts/main.gd:325-328` (F1 `rot_b`), `_build_furniture` (almofada e cobertor da cabana), `_build_ui` (texto de ajuda)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Produces:
  - `player.crouched: bool`
  - `player.set_crouched(on: bool) -> bool`: retorna o estado efetivo pedido; `false` quando não pôde levantar.
  - Em `foldable.gd`: `var can_toggle: Callable`. Quando ele é válido e retorna `false`, `interact()` não faz nada.
  - Em `foldable.gd`: `signal toggled(at_b: bool)`, emitido ao fim do tween.
- Valores:
  - O agachamento é ligado e desligado pela tecla **C**.
  - Cápsula agachada com `height` 1.0, centro em y 0.5; câmera em y 0.92; velocidade agachada 1.3.
  - F1 `rot_b` muda de `-65°` para `Vector3(0, 0, deg_to_rad(-45.0))`.
  - Almofada e cobertor da cabana vão para x 1.5.
  - Guarda do F1: `func() -> bool: return not (player.position.x < 2.1 and player.position.z < 7.0)`.
  - Para levantar, o jogador consulta a cápsula do selftest (raio 0.28, altura 1.6) centrada em `global_position + Vector3(0, 0.85, 0)`, máscara 1, excluindo a si mesmo.

- [ ] **Step 1: Escrever o teste que falha.** Em `selftest.gd`:
  - Adicione `var crouch_shape: CapsuleShape3D`, com raio 0.28 e altura 1.0, criado em `_ready`.
  - Adicione os helpers `_hits_shape(pos, shape)`, `_expect_clear_shape(pos, shape, label)` e `_check_segment_shape(a, b, shape, label)`, que generalizam os helpers atuais.
  - Insira o bloco abaixo depois do bloco "folds" e antes de "final state":

```gdscript
	print("SELFTEST: cabana")
	await _toggle("F1")
	_expect_blocked(Vector3(1.5, 0.85, 3.5), "folded F1 still blocks a standing player")
	_expect_clear_shape(Vector3(1.5, 0.52, 3.5), crouch_shape, "crouched player fits inside the cabana")
	_check_segment_shape(Vector3(2.6, 0.52, 3.5), Vector3(1.5, 0.52, 3.5), crouch_shape, "crouched path into the cabana")
	var saved: Vector3 = main.player.global_position
	main.player.global_position = Vector3(1.5, 0.0, 3.5)
	main.player.set_crouched(true)
	await get_tree().physics_frame
	_record(not main.player.set_crouched(false), "cannot stand up under folded F1", "")
	_record(main.player.crouched, "player stays crouched under folded F1", "")
	_node("F1").interact()
	await get_tree().create_timer(1.3).timeout
	_expect_at("F1", true, "F1 refuses to move with the player inside the cabana")
	main.player.global_position = saved
	await get_tree().physics_frame
	_record(main.player.set_crouched(false), "player stands up outside the cabana", "")
	await _toggle("F1")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar `godot --headless --path . -- --selftest`. Esperado: erro de método inexistente `set_crouched` ou `FAIL crouched player fits inside the cabana`.
- [ ] **Step 3: Implementar.**
  - Em `player.gd`, implementar `set_crouched(on: bool) -> bool`. Ele troca a altura e a posição do `CollisionShape3D`, muda a altura-alvo da câmera (que o head bob passa a usar no lugar de 1.62) e muda a velocidade.
  - Em `foldable.gd`, adicionar `can_toggle` e `toggled`.
  - Em `main.gd`, aplicar F1 −45°, ligar `F1.can_toggle` à guarda, mover almofada e cobertor e acrescentar "C agachar" ao texto de ajuda.
- [ ] **Step 4: Rodar e ver passar.** Rodar o mesmo comando. Esperado: as checagens do bloco "cabana" passam e as 53 antigas continuam passando.
- [ ] **Step 5: Checkpoint.** Rodar o CP sem a linha do unit. Registrar em `context/achados.md` a linha `~superseded 2026-10-27` no A-001, apontando para esta tarefa.

---

### Task 2: O espaço: nascer na entrada, tampo sob a redoma, oficina gigante e beira do tampo

**Files:**
- Modify: `faz-de-conta/scripts/main.gd`: `_build_atelier` (602-693), `_build_player` (694-735), `_add_labels`/`_ready` (labels atrás de `--labels`)
- Modify: `faz-de-conta/scripts/player.gd` (respawn)
- Test: `faz-de-conta/scripts/selftest.gd` (segmentos do laço)

**Interfaces:**
- Produces:
  - Em `main.gd`: `const SPAWN := Vector3(1.8, 0.2, 8.3)` e `const GIANT := 12.0`.
  - Em `main.gd`: `signal exit_edge_reached`.
  - Nós `Tampo` (o antigo `Atelier`), `WestTampo` (o antigo `WestAtelier`), `Redoma`, `Oficina` e `ExitEdge` (`Area3D`).
  - Em `player.gd`: `var respawn_point: Vector3`, usado no reset de queda no lugar de `Vector3(2.0, 0.25, 11.2)`.
- Valores:
  - O jogador nasce em `SPAWN` com `rotation.y = 0`, olhando para o norte, para dentro da casa.
  - `Tampo` e `WestTampo`:
    - Removem as chamadas `_ceiling` e trocam o piso para `mat_wood` (o tampo da bancada).
    - Trocam o material das paredes por vidro da redoma: um material novo `mat_glass`, `#9fb4c0` com alpha 0.18, transparência ligada e rugosidade 0.05.
    - **A colisão continua idêntica.**
  - Removem-se a mesa, a cadeira, a luminária e o caderno do ateliê. No lugar entram, sem colisão, uma engrenagem gigante deitada (cilindro r 1.2, h 0.3 em (11.0, 0.15, 11.0)) e um lápis gigante (caixa 0.25×0.25×4.0 em (6.5, 0.12, 11.6)).
  - `Redoma`: painéis visuais sem colisão em x −3.4..15.6, z −0.2..12.7, topo em y 3.6, com `mat_glass`.
  - `Oficina`, toda sem colisão e em escala `GIANT`:
    - a borda da bancada em z 13.5, descendo até y −9.6;
    - a parede ao fundo em z −40;
    - uma janela com chuva a 12× no norte;
    - uma luz quente de luminária gigante em (6, 18, 16).
  - `ExitEdge`:
    - `Area3D` em x 0..15.4, z 11.9..12.5, y 0..2.5, com `collision_mask = 1`.
    - Ao receber `body_entered` do `player`, emite `exit_edge_reached`.
  - Os `Label3D` de blockout só aparecem com o argumento de usuário `--labels`.

- [ ] **Step 1: Escrever o teste que falha.** Em `selftest.gd`, trocar o primeiro e o último segmento do laço e adicionar as checagens de espaço:

```gdscript
	print("SELFTEST: space")
	_record(main.player.global_position.distance_to(main.SPAWN) < 0.3, "player spawns at the entry", str(main.player.global_position))
	_record(main.get_node_or_null("ExitEdge") is Area3D, "tampo edge trigger exists", "")
	_record(main.get_node_or_null("Atelier") == null and main.get_node_or_null("Tampo") != null, "atelier became the tampo", "")
	_expect_clear(Vector3(1.8, 0.85, 8.3), "spawn point is clear")
	# laço: substitui "atelier -> front door" e "front door -> atelier"
	_check_segment(Vector3(1.8, 0.85, 8.3), Vector3(1.7, 0.85, 7.9), "spawn -> entry")
	# ... segmentos existentes de "entry -> playroom door" até "entry -> front door" ...
	_check_segment(Vector3(1.7, 0.85, 9.4), Vector3(2.0, 0.85, 12.0), "front door -> tampo edge")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o selftest. Esperado: `FAIL player spawns at the entry` e erro no acesso a `main.SPAWN`.
- [ ] **Step 3: Implementar** as mudanças de `main.gd` e `player.gd` com os valores acima. Os modos `--shot*` continuam funcionando; o modo `atelier` passa a enquadrar o tampo.
- [ ] **Step 4: Rodar e ver passar.** Rodar o selftest. Esperado: 0 falhas.
- [ ] **Step 5: Checkpoint.** Rodar o CP e abrir o jogo. Pela porta da rua devem aparecer o tampo, o vidro da redoma e a oficina gigante. Andar até a beira do tampo ainda não faz nada visível.

---

### Task 3: Harness unitário, `WindClockModel` e o relógio da entrada

**Files:**
- Create: `faz-de-conta/tests/run_unit.gd` (harness)
- Create: `faz-de-conta/tests/test_wind_clock.gd`
- Create: `faz-de-conta/scripts/wind_clock_model.gd`
- Create: `faz-de-conta/scripts/entry_clock.gd`
- Modify: `faz-de-conta/scripts/main.gd` (`_build_furniture`: o relógio; `var clock_model`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Produces:
  - Harness:
    - `tests/run_unit.gd` estende `SceneTree`. Em `_init()`, carrega cada `res://tests/test_*.gd` e chama todo método `test_*` passando o próprio runner.
    - O runner oferece `ok(cond: bool, label: String)`, `eq(actual, expected, label: String)` e `near(actual: float, expected: float, eps: float, label: String)`.
    - Um arquivo que não carrega conta como falha `could not load <path>`.
    - Imprime `UNIT RESULT: %d checks, %d failures` e chama `quit(0 or 1)`.
  - `wind_clock_model.gd` (`RefCounted`):
    - Constantes: `SPRING_MAX := 600.0`, `FIRST_WIND := 180.0`, `WIND_FACTOR := 0.7`, `WIND_FLOOR := 15.0`, `STALL_SPRING := 5.0`.
    - Variáveis: `var spring := 600.0`, `var winds := 0`, `var drain_rate := 1.0`, `var can_stop := false`.
    - `tick(dt: float) -> bool`: retorna `true` só no tick em que o relógio para. Com `can_stop == false`, a corda nunca desce de `STALL_SPRING`.
    - `wind() -> float`: rende `maxf(WIND_FLOOR, FIRST_WIND * pow(WIND_FACTOR, winds))`, limitado a `SPRING_MAX`, e retorna quanto entrou. Um relógio parado volta a andar.
    - `clamp_spring(max_value: float) -> void`
    - `force_stop() -> void`
    - `is_stopped() -> bool`
    - `display_minutes() -> float`: retorna `(1.0 - spring / SPRING_MAX) * 33.0`, ou seja, 0 = 03:00 e 33 = 03:33.
    - `audio_tick_period() -> float`: retorna `1.0 + 0.25 * (1.0 - spring / SPRING_MAX)`. É o tique dessincronizando enquanto a animação do pêndulo fica fixa em 1.0 s.
  - `entry_clock.gd` (`StaticBody3D`, camada 1):
    - `var model` (o `WindClockModel`) e `signal wound(amount: float)`.
    - `get_prompt() -> String` retorna `"dar corda"`.
    - `interact()` chama `model.wind()` e emite `wound`.
    - Os ponteiros e o pêndulo leem o modelo em `_process`.
  - Em `main.gd`: `var clock_model`.
- Valores:
  - O relógio de caixa fica em (3.1, 1.0, 8.88), corpo 0.5×2.0×0.28, ao lado da porta da rua, encostado na fachada.
  - O relógio precisa deixar livres os segmentos "entry east turn" e "passage -> entry".
  - Nesta tarefa, `main` chama `clock_model.tick(delta)` com `drain_rate` 1.0 e `can_stop` false. A Tarefa 6 assume esse controle.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_wind_clock.gd`:

```gdscript
extends RefCounted
const WindClock = preload("res://scripts/wind_clock_model.gd")

func test_starts_full_at_three(t) -> void:
	var c = WindClock.new()
	t.near(c.spring, 600.0, 0.001, "starts wound")
	t.near(c.display_minutes(), 0.0, 0.001, "shows 03:00")

func test_wind_diminishes_to_floor(t) -> void:
	var c = WindClock.new()
	c.spring = 0.0
	t.near(c.wind(), 180.0, 0.001, "first wind 180")
	t.near(c.wind(), 126.0, 0.001, "second wind 126")
	t.near(c.wind(), 88.2, 0.01, "third wind 88.2")
	for i in 200:
		var got: float = c.wind()
		t.ok(got >= 15.0 - 0.001 or c.spring >= 600.0 - 0.001, "wind %d never below floor" % i)
		t.ok(c.spring <= 600.0 + 0.001, "spring never above max")

func test_stall_without_permission(t) -> void:
	var c = WindClock.new()
	var stopped := false
	for i in 2000:
		stopped = c.tick(1.0) or stopped
	t.ok(not stopped, "cannot stop while can_stop is false")
	t.near(c.spring, 5.0, 0.001, "stalls at STALL_SPRING")
	t.ok(not c.is_stopped(), "stalled is not stopped")

func test_stops_once_when_allowed(t) -> void:
	var c = WindClock.new()
	c.can_stop = true
	c.spring = 2.0
	t.ok(not c.tick(1.0), "still running after 1 s")
	t.ok(c.tick(1.5), "reports the stop")
	t.ok(not c.tick(1.0), "reports it only once")
	t.near(c.display_minutes(), 33.0, 0.001, "stopped shows 03:33")

func test_tick_desyncs_as_spring_runs_out(t) -> void:
	var c = WindClock.new()
	t.near(c.audio_tick_period(), 1.0, 0.001, "in sync when full")
	c.spring = 0.0
	t.near(c.audio_tick_period(), 1.25, 0.001, "late when empty")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar `godot --headless --path . -s res://tests/run_unit.gd`. Esperado: no começo, o harness ainda não existe e o Godot reporta erro ao abrir o script. Depois do harness pronto, aparece `FAIL could not load res://tests/test_wind_clock.gd` ou erro de preload.
- [ ] **Step 3: Implementar** `tests/run_unit.gd`, `scripts/wind_clock_model.gd` e `scripts/entry_clock.gd`, e montar o relógio em `main.gd`. A caixa e o mostrador usam `_box`. Os ponteiros são caixas finas filhas de um `Node3D` pivô. O ponteiro dos minutos gira `display_minutes() * 6°`; o das horas fica fixo apontando para o 3.
- [ ] **Step 4: Teste de mundo** em `selftest.gd`, depois de "space":

```gdscript
	_expect_blocked(Vector3(3.1, 0.85, 8.88), "entry clock is solid")
	_record(main.get_node_or_null("EntryClock") != null and main.get_node("EntryClock").get_prompt() == "dar corda", "entry clock can be wound", "")
```

- [ ] **Step 5: Rodar o unit e o selftest e ver passar.** Esperado: `UNIT RESULT: ... 0 failures` e o selftest com 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP completo.

---

### Task 4: Catálogo: dados, modelo, alvos, tecla Q e zoom de exame

**Files:**
- Create: `faz-de-conta/scripts/catalog_data.gd`, `faz-de-conta/scripts/catalog.gd`, `faz-de-conta/scripts/catalog_target.gd`
- Create: `faz-de-conta/tests/test_catalog.gd`
- Modify: `faz-de-conta/scripts/player.gd` (tecla Q, `CatalogRay`, sinais)
- Modify: `faz-de-conta/scripts/main.gd` (`_build_player`, alvos em `_build_furniture`, `_process` prompt, flags)
- Modify: `faz-de-conta/scripts/doll.gd` (`signal toggled(lying: bool)`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes: `foldable.toggled(at_b)` (Tarefa 1).
- Produces:
  - `catalog_data.gd`:
    - `const FIRST_NUMBER := 215`
    - `const OPENING := {"number": 214, "text": "maquete de casa sob redoma, relógio no telhado, parado. Dei corda para testar o mecanismo."}`
    - `const ITEMS: Dictionary`, com `StringName → {"text": String, "page": StringName, "gate": StringName}`
    - `const PAGES: Dictionary`, com `StringName → String`
  - `catalog.gd` (`RefCounted`):
    - `var entries: Array[Dictionary]`. Cada entrada tem `{"number": int, "text": String, "author": StringName, "item": StringName}`.
    - `var pages: Array[StringName]` e `var flags: Dictionary`.
    - `set_flag(name: StringName, value: bool) -> void`
    - `can_catalog(item: StringName) -> bool`
    - `catalog(item: StringName) -> Dictionary`: retorna `{}` se não puder.
    - `has(item: StringName) -> bool`
    - `count_elias_items() -> int`: exclui a 214 e as entradas do duplo.
    - `next_number() -> int`
    - `add_double_entries(texts: Array[String]) -> void`: entradas com `author = &"duplo"`.
    - `static func format(entry: Dictionary) -> String`: retorna `"Item %d — %s"`.
    - A 214 entra em `_init` com `author &"elias"` e `item &"maquete"`.
  - `catalog_target.gd` (`Area3D`):
    - `@export var item_id: StringName`
    - Configuração: `collision_layer = 2`, `collision_mask = 0`, `monitoring = false`, `monitorable = true`, grupo `catalog_target`.
  - `player.gd`:
    - Filho `Camera3D/CatalogRay` com alcance −2.5 m, máscara 2, `collide_with_areas = true` e `collide_with_bodies = false`.
    - `catalog_target_in_view() -> Area3D`: a área conta só se o `RayCast3D` (máscara 1) não colide ou colide a uma distância maior ou igual à da área menos 0.35.
    - `signal catalog_requested(target: Area3D)`, emitido pela tecla **Q**.
    - `examine() -> void`: tween do FOV 70 → 45 em 0.4 s, segura 1.2 s e volta em 0.4 s.
  - `main.gd`:
    - `var catalog` e `signal cataloged(entry: Dictionary)`.
    - Helper `_catalog_target(parent: Node3D, item: StringName, pos: Vector3, size: Vector3) -> Area3D`.
    - Flags: `F1.toggled` → `&"f1_folded"`; `Doll.toggled` → `&"doll_sat"` (sentado = `not lying`).
    - O prompt ganha uma segunda linha `"[Q]  catalogar"` quando `can_catalog`.

- [ ] **Step 1: Escrever `catalog_data.gd` com o texto exato.** É cópia fixa, escolha da IA dentro do espaço que o spec (12) deixa a quem constrói:

| id | gate | page | text |
|---|---|---|---|
| `relogio_entrada` | — | `p1` | relógio de caixa, ébano tingido, pêndulo de latão. O mostrador só tem marcas entre 03:00 e 03:33. |
| `bola` | — | — | bola de madeira, faia, gasta de um lado só. |
| `caixa_musica` | — | `p2` | caixa de música, manivela de latão. A melodia sempre para na mesma nota. |
| `desenho` | — | — | desenho a lápis de cera: esta casa, um menino, um relógio maior que a casa. Assinado "Inácio, 7 anos". |
| `casinha` | — | — | casinha de brinquedo dentro da casa de brinquedo. Também tem relógio no telhado. |
| `cabana` | `f1_folded` | — | cabana de parede dobrada, almofada, cobertor. Cheiro de cobre. |
| `cama` | — | — | cama de criança, colcha bordada. No travesseiro, a marca de uma cabeça adulta. |
| `espelho` | — | — | espelho oval, moldura de latão. O reflexo demora. |
| `boneco` | `doll_sat` | — | boneco de pano, casaco cinza-azulado igual ao meu. A costura é nova. |
| `vela` | — | — | vela de cera, acesa. Não diminui. |
| `casaco` | — | — | casaco de lã pendurado na entrada. Do meu tamanho, na escala da casa. |
| `figura_inacio_a` | — | `p4` | figura sentada, cabelo branco, relógio de bolso parado às 03:33. |
| `figura_inacio_b` | — | — | figura sentada, mais gasta que a do lado. O mesmo relógio de bolso. |
| `figura_catalogador` | — | `p5` | figura sentada, sem relógio de bolso. No colo, um caderno igual ao meu. |
| `pagina_cabana` | `after_hora` | `p3` | página solta debaixo da almofada da cabana. Letra de Inácio. |

`PAGES`. Cada linha da tabela é uma linha da página, com `\n` entre elas:

| id | text |
|---|---|
| `p1` | O médico diz meses. A falha diz mais: 03:33, numa madrugada de março.<br>Leio a mesma hora em todos os pêndulos.<br>Vou fazer um relógio que nunca chegue lá. |
| `p2` | Refiz de memória a casa da rua do Porto.<br>A cabana, a bola, a caixa a que minha mãe dava corda.<br>Lá dentro eu ainda não tenho idade para morrer. |
| `p3` | Entrei. Deu certo, mais ou menos.<br>Às 03:33 eu morro de novo, dou corda e recomeço.<br>Perdi a conta. A casa ficou cheia de mim.<br>A casa sou eu. |
| `p4` | As mais antigas já nem se mexem.<br>Gastei tanto essas versões que viraram bonecos.<br>Ainda sussurram quando o relógio para. |
| `p5` | Dentro do caderno, a carta que me contratou. Letra de Inácio.<br>Datada de seis anos depois do enterro.<br>Na última linha do caderno: "Item 231 — catalogador." |

- [ ] **Step 2: Escrever os testes que falham** em `tests/test_catalog.gd`:

```gdscript
extends RefCounted
const Catalog = preload("res://scripts/catalog.gd")
const Data = preload("res://scripts/catalog_data.gd")

func test_opening_entry(t) -> void:
	var c = Catalog.new()
	t.eq(Catalog.format(c.entries[0]), "Item 214 — maquete de casa sob redoma, relógio no telhado, parado. Dei corda para testar o mecanismo.", "opening entry text")
	t.eq(c.next_number(), 215, "next is 215")

func test_sequential_and_no_repeat(t) -> void:
	var c = Catalog.new()
	t.eq(c.catalog(&"bola").get("number"), 215, "first catalog is 215")
	t.ok(c.catalog(&"bola").is_empty(), "same item twice is refused")
	t.eq(c.catalog(&"vela").get("number"), 216, "numbering continues")

func test_gates(t) -> void:
	var c = Catalog.new()
	t.ok(not c.can_catalog(&"cabana"), "cabana needs the fold")
	t.ok(not c.can_catalog(&"boneco"), "doll needs to be turned")
	t.ok(not c.can_catalog(&"pagina_cabana"), "page needs the 03:33")
	c.set_flag(&"f1_folded", true)
	t.ok(c.can_catalog(&"cabana"), "fold opens cabana")

func test_pages_follow_items(t) -> void:
	var c = Catalog.new()
	c.catalog(&"relogio_entrada")
	t.ok(c.pages.has(&"p1"), "entry clock reveals page 1")

func test_double_entries(t) -> void:
	var c = Catalog.new()
	c.catalog(&"bola")
	c.add_double_entries(["catalogador. A mão direita gasta de um lado só."])
	t.eq(c.entries[-1].get("author"), &"duplo", "author is the double")
	t.eq(c.entries[-1].get("number"), 216, "double continues numbering")
	t.eq(c.count_elias_items(), 1, "double and 214 do not count")

func test_data_integrity(t) -> void:
	for id in Data.ITEMS:
		var item: Dictionary = Data.ITEMS[id]
		t.ok(String(item.text) != "", "%s has text" % id)
		t.ok(item.page == &"" or Data.PAGES.has(item.page), "%s page exists" % id)
	for p in Data.PAGES:
		t.ok(String(Data.PAGES[p]).split("\n").size() <= 4, "%s has at most 4 lines" % p)
```

- [ ] **Step 3: Rodar e ver falhar.** Rodar o unit. Esperado: `FAIL could not load res://tests/test_catalog.gd`.
- [ ] **Step 4: Implementar** `catalog.gd`, `catalog_target.gd`, a parte do jogador e a fiação em `main.gd`. Os alvos ficam sobre os objetos, com as caixas abaixo; o de `pagina_cabana` só nasce na Tarefa 13:
  - `relogio_entrada` (3.1, 1.2, 8.8)
  - `bola` filho de `Ball`
  - `caixa_musica` (3.35, 0.7, 4.45)
  - `desenho` (6.7, 1.6, 0.1)
  - `casinha` (7.5, 0.3, 1.0)
  - `cabana` (1.0, 0.4, 3.5)
  - `cama` (13.2, 0.5, 3.0)
  - `espelho` (15.25, 1.35, 2.0)
  - `boneco` filho de `Doll`
  - `vela` (11.85, 0.6, 7.7)
  - `casaco` (0.2, 1.2, 7.6)
  - `figura_inacio_a` (11.15, 0.7, 8.35)
  - `figura_inacio_b` (11.85, 0.7, 8.35)
  - `figura_catalogador` (12.55, 0.7, 8.35)
- [ ] **Step 5: Teste de mundo** em `selftest.gd`:

```gdscript
	print("SELFTEST: catalog")
	var targets := get_tree().get_nodes_in_group("catalog_target")
	for tg in targets:
		_record(tg is Area3D and tg.collision_layer == 2, "catalog target %s is an area on layer 2" % tg.item_id, "")
	_record(targets.size() == main.CatalogData.ITEMS.size() - 1, "every item but the cabana page has a target", str(targets.size()))
```

(`main.gd` expõe `const CatalogData = preload("res://scripts/catalog_data.gd")`.)

- [ ] **Step 6: Rodar o unit e o selftest e ver passar.** Esperado: 0 falhas nos dois. Todos os segmentos do laço continuam verdes, porque as áreas ficam fora da máscara 1.
- [ ] **Step 7: Checkpoint.** Rodar o CP. Abrir o jogo, catalogar a bola com Q e ver o zoom.

---

### Task 5: O caderno (Tab), objeto de papel

**Files:**
- Create: `faz-de-conta/scripts/notebook_ui.gd`
- Modify: `faz-de-conta/scripts/player.gd` (`var input_locked := false`, tecla **Tab**)
- Modify: `faz-de-conta/scripts/main.gd` (`_build_ui`; `cataloged` → `notebook.peek`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes: `catalog`, `Catalog.format(entry)` e `CatalogData.PAGES` (Tarefa 4).
- Produces:
  - `notebook_ui.gd` (`CanvasLayer`): `open()`, `close()`, `toggle()`, `is_open() -> bool`, `refresh(catalog) -> void`, `peek(entry: Dictionary) -> void`, `show_final(text: String) -> void` (este último é usado na Tarefa 14), `page_text() -> String` (o texto concatenado das duas páginas visíveis, para teste).
  - `player.input_locked`: quando `true`, ignora movimento, olhar, E, Q, C e B. Tab continua ativo.
- Valores:
  - Visual de caderno aberto, desenhado como papel:
    - fundo `#e9e1cc` com pautas `#b8ae96`;
    - fonte `SystemFont` serifada em itálico;
    - página esquerda com as entradas, página direita com as páginas de diário coladas, em papel `#d8ccad` levemente girado;
    - depois da última entrada, três linhas numeradas em branco (`"Item 2xx —"` seguido de pauta vazia).
  - **Nenhum número de total**, barra ou porcentagem.
  - `peek` mostra uma tira de papel com a nova linha por 2.5 s, no canto inferior.
  - Com o caderno aberto, o cursor fica visível e `input_locked` fica `true`.

- [ ] **Step 1: Escrever o teste que falha** em `selftest.gd`:

```gdscript
	print("SELFTEST: notebook")
	main.notebook.refresh(main.catalog)
	main.notebook.open()
	var text: String = main.notebook.page_text()
	_record(text.contains("Item 214 —"), "notebook shows the opening entry", "")
	_record(text.contains("Item 215 —"), "notebook shows numbered blank lines ahead", "")
	var counter := RegEx.create_from_string("\\d+\\s*(/|de)\\s*\\d+")
	_record(counter.search(text) == null, "notebook has no x-of-y counter", text)
	_record(main.player.input_locked, "notebook locks player input", "")
	main.notebook.close()
	_record(not main.player.input_locked, "closing the notebook unlocks input", "")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o selftest. Esperado: erro de propriedade inexistente `notebook`.
- [ ] **Step 3: Implementar** `notebook_ui.gd` e a fiação: Tab chama `toggle()`, e `cataloged` chama `refresh` e `peek`. Acrescentar "Q catalogar · Tab caderno" ao texto de ajuda.
- [ ] **Step 4: Rodar e ver passar.** Rodar o selftest. Esperado: 0 falhas.
- [ ] **Step 5: Checkpoint.** Rodar o CP. Abrir o jogo, catalogar o relógio e abrir o caderno: a página 1 aparece colada à direita.

---

### Task 6: `VisitState`, os atos da visita e a fiação do relógio

**Files:**
- Create: `faz-de-conta/scripts/visit_state.gd`
- Create: `faz-de-conta/tests/test_visit_state.gd`
- Modify: `faz-de-conta/scripts/main.gd` (`var visit`, `var autonomous := true`, `_process`, sinais)
- Modify: `faz-de-conta/scripts/selftest.gd` (`main.autonomous = false` em `_ready`)

**Interfaces:**
- Consumes: `WindClockModel` (Tarefa 3) e `catalog` (Tarefa 4).
- Produces:
  - `visit_state.gd` (`RefCounted`):
    - `enum Act { CHEGADA, BRINCAR, DUPLO, HORA, DEPOIS, ESCOLHA, FIM }`
    - Constantes: `MIN_ITEMS_FOR_HORA := 5`, `HURRY_SPRING := 20.0`, `MAX_PRE_HORA := 1200.0`, `HARD_LIMIT := 1380.0`, `ESCOLHA_SPRING := 30.0`, `DRAIN_CALM := 0.45`, `DRAIN_DUPLO := 0.9`.
    - Variáveis: `var act: int`, `var elapsed: float`, `var wound_since_escolha := false`, `var clock`, `var catalog`.
    - `_init(clock_model, catalog_model)`
    - `update(dt: float, in_bedroom: bool) -> StringName`: retorna `&"hora_started"` ou `&""`.
    - `on_cataloged(item: StringName) -> void`
    - `on_wind() -> StringName`: retorna `&"hora_ended"` ou `&""`.
    - `on_exit() -> StringName`: retorna `&"corda"`, `&"parar"` ou `&"incompleto"`.
    - `recording_enabled() -> bool`
  - `main.gd`:
    - `signal hora_started` e `signal hora_ended`.
    - Com `autonomous == false`, `_process` não chama `visit.update` e os sistemas autônomos das tarefas seguintes ficam quietos.
- Regras (o spec, seção 7, define o gatilho):
  1. A primeira catalogação leva CHEGADA a BRINCAR. Entrar no quarto (x 10.5..15.4, z 0..5.6) leva a DUPLO a partir de qualquer ato anterior.
  2. O dreno é `DRAIN_CALM` em CHEGADA, BRINCAR, DEPOIS e ESCOLHA, e `DRAIN_DUPLO` em DUPLO.
  3. O gatilho do 03:33 é atingido quando há `catalog.has(&"boneco")` e `count_elias_items() >= MIN_ITEMS_FOR_HORA`, ou quando `elapsed >= MAX_PRE_HORA`. Ao ser atingido pela primeira vez, faz `clock.can_stop = true` e `clock.clamp_spring(HURRY_SPRING)`. As cordas seguintes rendem normalmente.
  4. Com `elapsed >= HARD_LIMIT` antes de HORA, o relógio é parado com `clock.force_stop()`.
  5. Quando `clock.tick` reporta a parada antes de HORA, o ato vira HORA e a função retorna `&"hora_started"`.
  6. Uma corda em HORA leva a DEPOIS, faz `clock.can_stop = false` para sempre e retorna `&"hora_ended"`. **Não existe segundo 03:33.**
  7. Catalogar `pagina_cabana` leva a ESCOLHA e faz `clock.clamp_spring(ESCOLHA_SPRING)`. Uma corda em ESCOLHA marca `wound_since_escolha`.
  8. `on_exit()` só pode ser chamado uma vez e leva o ato a FIM. Retorna `&"incompleto"` se o ato era anterior a ESCOLHA; `&"corda"` se `wound_since_escolha`; senão, `&"parar"`.
  9. `recording_enabled()` é `false` em HORA e em FIM.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_visit_state.gd`. Use o helper local `_run(v, seconds, in_bedroom := false)`, que chama `update(1.0, …)` em laço e retorna o primeiro evento não vazio.

```gdscript
extends RefCounted
const Visit = preload("res://scripts/visit_state.gd")
const WindClock = preload("res://scripts/wind_clock_model.gd")
const Catalog = preload("res://scripts/catalog.gd")

func _new() -> Visit:
	return Visit.new(WindClock.new(), Catalog.new())

func _run(v, seconds: int, in_bedroom := false) -> StringName:
	for i in seconds:
		var ev: StringName = v.update(1.0, in_bedroom)
		if ev != &"":
			return ev
	return &""

func test_acts_advance(t) -> void:
	var v := _new()
	t.eq(v.act, Visit.Act.CHEGADA, "starts at arrival")
	v.catalog.catalog(&"bola"); v.on_cataloged(&"bola")
	t.eq(v.act, Visit.Act.BRINCAR, "first catalog -> play")
	v.update(1.0, true)
	t.eq(v.act, Visit.Act.DUPLO, "bedroom -> double")

func test_no_hora_before_gate(t) -> void:
	var v := _new()
	t.eq(_run(v, 1100), &"", "clock stalls instead of stopping before the gate")
	t.ok(v.clock.spring >= WindClock.STALL_SPRING - 0.001, "spring stalled")

func test_catalog_gate(t) -> void:
	var v := _new()
	for id in [&"boneco", &"bola", &"vela", &"cama", &"casaco"]:
		v.catalog.set_flag(&"doll_sat", true)
		v.catalog.catalog(id); v.on_cataloged(id)
	t.ok(v.clock.spring <= Visit.HURRY_SPRING + 0.001, "gate hurries the clock")
	t.eq(_run(v, 60), &"hora_started", "03:33 follows the gate")

func test_time_gate_without_doll(t) -> void:
	var v := _new()
	var limit := int(Visit.MAX_PRE_HORA + Visit.HURRY_SPRING / Visit.DRAIN_CALM) + 1
	t.eq(_run(v, limit), &"hora_started", "03:33 by time with nothing cataloged")

func test_wind_spam_cannot_prevent_hora(t) -> void:
	var v := _new()
	var got := &""
	for i in int(Visit.HARD_LIMIT) + 2:
		v.clock.wind(); v.on_wind()
		got = v.update(1.0, false)
		if got != &"":
			break
	t.eq(got, &"hora_started", "03:33 arrives by HARD_LIMIT even when winding every second")
	t.ok(v.elapsed <= Visit.HARD_LIMIT + 1.0, "no later than HARD_LIMIT")

func test_hora_ends_on_wind_and_never_returns(t) -> void:
	var v := _new()
	_run(v, 2000)
	t.eq(v.act, Visit.Act.HORA, "in hora")
	t.ok(not v.recording_enabled(), "no recording during hora")
	v.clock.wind()
	t.eq(v.on_wind(), &"hora_ended", "wind ends hora")
	t.eq(v.act, Visit.Act.DEPOIS, "after hora")
	t.ok(v.recording_enabled(), "recording resumes")
	t.eq(_run(v, 5000), &"", "there is no second 03:33")

func test_exit_outcomes(t) -> void:
	var v := _new()
	t.eq(v.on_exit(), &"incompleto", "exit before choice")
	var a := _new(); _run(a, 2000); a.clock.wind(); a.on_wind()
	a.catalog.set_flag(&"after_hora", true); a.catalog.catalog(&"pagina_cabana"); a.on_cataloged(&"pagina_cabana")
	t.eq(a.act, Visit.Act.ESCOLHA, "cabana page opens the choice")
	t.ok(a.clock.spring <= Visit.ESCOLHA_SPRING + 0.001, "clock is almost unwound at the choice")
	t.eq(a.on_exit(), &"parar", "leave without winding")
	var b := _new(); _run(b, 2000); b.clock.wind(); b.on_wind()
	b.catalog.set_flag(&"after_hora", true); b.catalog.catalog(&"pagina_cabana"); b.on_cataloged(&"pagina_cabana")
	b.clock.wind(); b.on_wind()
	t.eq(b.on_exit(), &"corda", "wind then leave")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_visit_state.gd`.
- [ ] **Step 3: Implementar** `visit_state.gd` e a fiação em `main.gd`:
  - `EntryClock.wound` chama `visit.on_wind()`.
  - `cataloged` chama `visit.on_cataloged(entry.item)`.
  - Os eventos retornados viram os sinais `hora_started` e `hora_ended`.
  - Até a Tarefa 10, `hora_started` só imprime `"03:33"` com `print`.
  - `main` deixa de chamar `clock_model.tick` diretamente.
  - Em `selftest.gd`, a primeira linha de `_ready` faz `main.autonomous = false`.
- [ ] **Step 4: Teste de mundo** em `selftest.gd`: `_record(main.visit.act == main.VisitState.Act.CHEGADA, "visit starts at arrival", "")`.
- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP.

---

### Task 7: Som de protótipo, sintetizado

**Files:**
- Create: `faz-de-conta/scripts/sfx_bank.gd`
- Create: `faz-de-conta/tests/test_sfx_bank.gd`
- Modify: `faz-de-conta/scripts/main.gd` (buses, `var sfx`), `faz-de-conta/scripts/entry_clock.gd` (tique), `faz-de-conta/scripts/player.gd` (passos no cruzamento do head bob)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Produces:
  - `sfx_bank.gd` (`Node`):
    - `const KINDS := [&"tick", &"click", &"knock", &"step", &"pencil", &"fold", &"rain", &"hum", &"breath"]`
    - `static func make(kind: StringName, seed: int = 7) -> AudioStreamWAV`: 16 bits, mono, 22050 Hz. `rain`, `hum` e `breath` têm loop; os outros, não.
    - `ensure_buses() -> void`: cria os buses `Casa` e `Mundo` no `AudioServer` se faltarem.
    - `play_at(kind: StringName, pos: Vector3, bus: StringName = &"Casa", volume_db := 0.0) -> void`: usa um pool de 12 `AudioStreamPlayer3D`.
    - `play_pencil_pattern(pos: Vector3) -> void`: 5 traços com intervalos fixos `[0.0, 0.18, 0.31, 0.55, 0.7]`. A Tarefa 12 reutiliza o mesmo padrão.
    - `set_casa_muted(muted: bool) -> void`
  - Camadas:
    - `Mundo`: chuva atrás das janelas e respiração do jogador (loop baixo, −24 dB).
    - `Casa`: tique do relógio, que soa a cada `model.audio_tick_period()` e não toca com `model.is_stopped()`; dobras (`foldable.toggled`); catalogar (`play_pencil_pattern`); passos.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_sfx_bank.gd`:

```gdscript
extends RefCounted
const Sfx = preload("res://scripts/sfx_bank.gd")

func _peak(w: AudioStreamWAV) -> float:
	var d := w.data
	var peak := 0
	for i in range(0, d.size() - 1, 2):
		peak = maxi(peak, absi(d.decode_s16(i)))
	return peak / 32768.0

func test_every_kind_is_wav(t) -> void:
	for k in Sfx.KINDS:
		var w: AudioStreamWAV = Sfx.make(k)
		t.ok(w != null and w.data.size() > 0, "%s has data" % k)
		t.eq(w.format, AudioStreamWAV.FORMAT_16_BITS, "%s is 16-bit" % k)
		t.eq(w.loop_mode != AudioStreamWAV.LOOP_DISABLED, k in [&"rain", &"hum", &"breath"], "%s loop flag" % k)

func test_no_loud_sting(t) -> void:
	for k in Sfx.KINDS:
		t.ok(_peak(Sfx.make(k)) <= 0.5, "%s peak <= 0.5" % k)

func test_deterministic(t) -> void:
	t.eq(Sfx.make(&"knock", 3).data, Sfx.make(&"knock", 3).data, "same seed, same sound")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_sfx_bank.gd`.
- [ ] **Step 3: Implementar** `sfx_bank.gd`. A síntese usa seno, ruído com `RandomNumberGenerator` semeado e envelopes exponenciais. Ligar as camadas.
- [ ] **Step 4: Teste de mundo:** `_record(AudioServer.get_bus_index("Casa") >= 0 and AudioServer.get_bus_index("Mundo") >= 0, "audio buses exist", "")`.
- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP e abrir o jogo. O tique deve ser audível na casa toda, mais alto perto do relógio, e atrasar à medida que a corda acaba.

---

### Task 8: `EchoRecorder`, a casa grava tudo

**Files:**
- Create: `faz-de-conta/scripts/echo_recorder.gd`
- Create: `faz-de-conta/tests/test_echo_recorder.gd`
- Modify: `faz-de-conta/scripts/player.gd` (`signal acted(verb: StringName, collider: Node)`)
- Modify: `faz-de-conta/scripts/main.gd` (`var recorder`; `_physics_process` grava quando `visit.recording_enabled()`; o mapa de verbos)

**Interfaces:**
- Produces:
  - `echo_recorder.gd` (`RefCounted`):
    - Constantes: `SAMPLE_HZ := 10.0`, `MAX_SAMPLES := 18000`, `SEGMENT_LEN := 8.0`, `MAX_ECHOES := 6`, `STILL_SPEED := 0.15`.
    - Uma amostra tem `{"pos": Vector3, "yaw": float, "pitch": float, "crouched": bool, "action": StringName}`.
    - `update(dt: float, pos: Vector3, yaw: float, pitch: float, crouched: bool) -> void`
    - `mark_action(verb: StringName) -> void`: marca a próxima amostra.
    - `sample_count() -> int` e `get_sample(i: int) -> Dictionary`
    - `delayed(seconds: float) -> Dictionary`: retorna `{}` se não houver amostras suficientes.
    - `select_segments() -> Array[Vector2i]`: cada item é `(início, fim exclusivo)`, ordenados pelo início.
    - `stats() -> Dictionary`: `{"crouched_s": float, "still_s": float, "meters": float, "actions": Dictionary}`, com `actions` mapeando verbo → contagem.
  - Mapa de verbos em `player._interact`:
    - `Foldable` cujo nome começa com `Door` → `&"abrir"`; outro `Foldable` → `&"dobrar"`.
    - `Ball` → `&"rolar"`, `Doll` → `&"boneco"`, `MusicBox` → `&"musica"`, `Figure` → `&"vela"`, `EntryClock` → `&"corda"`.
    - A catalogação emite `&"catalogar"`.
- Algoritmo de `select_segments` (o spec, seção 12, deixa a escolha a quem constrói):
  - Janelas não sobrepostas de 80 amostras, alinhadas a partir da amostra retida mais antiga.
  - `score = 3 * ações + segundos_parado + 2 * segundos_agachado + 0.5 * metros`.
  - Pega as `MAX_ECHOES` maiores; em empate, a mais antiga.
  - Com menos de 80 amostras, retorna `[]`.
- Cap: com mais de `MAX_SAMPLES` amostras, descarta as mais antigas, como um anel. Os índices de `get_sample` e dos trechos são relativos às amostras retidas.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_echo_recorder.gd`:

```gdscript
extends RefCounted
const Rec = preload("res://scripts/echo_recorder.gd")

func _feed(r, seconds: float, pos: Vector3, crouched := false, step := Vector3.ZERO) -> void:
	var n := int(seconds * 60.0)
	for i in n:
		pos += step / 60.0
		r.update(1.0 / 60.0, pos, 0.0, 0.0, crouched)

func test_samples_at_10hz(t) -> void:
	var r = Rec.new()
	_feed(r, 1.0, Vector3.ZERO)
	t.eq(r.sample_count(), 10, "one second = 10 samples")

func test_cap_and_segments_in_range(t) -> void:
	var r = Rec.new()
	_feed(r, 2000.0, Vector3.ZERO, false, Vector3(0.5, 0, 0))
	t.eq(r.sample_count(), Rec.MAX_SAMPLES, "recorder respects the cap")
	for seg in r.select_segments():
		t.ok(seg.x >= 0 and seg.y <= r.sample_count() and seg.y - seg.x == 80, "segment inside retained samples")

func test_segments_limit_and_no_overlap(t) -> void:
	var r = Rec.new()
	_feed(r, 120.0, Vector3.ZERO, false, Vector3(1, 0, 0))
	var segs: Array[Vector2i] = r.select_segments()
	t.ok(segs.size() <= Rec.MAX_ECHOES, "at most 6 echoes")
	for i in range(1, segs.size()):
		t.ok(segs[i].x >= segs[i - 1].y, "segments do not overlap")

func test_crouch_and_actions_win(t) -> void:
	var r = Rec.new()
	_feed(r, 8.0, Vector3.ZERO)          # parado em pé
	_feed(r, 8.0, Vector3.ZERO, true)    # agachado
	for i in 6:
		r.mark_action(&"dobrar")
		_feed(r, 8.0 / 6.0, Vector3(5, 0, 0))
	var segs: Array[Vector2i] = r.select_segments()
	t.ok(segs.has(Vector2i(80, 160)), "crouched window chosen")
	t.ok(segs.has(Vector2i(160, 240)), "action window chosen")
	t.eq(r.stats().actions.get(&"dobrar", 0), 6, "actions counted")

func test_delayed(t) -> void:
	var r = Rec.new()
	_feed(r, 2.0, Vector3.ZERO, false, Vector3(1, 0, 0))
	var d: Dictionary = r.delayed(0.5)
	t.near(d.pos.x, r.get_sample(r.sample_count() - 6).pos.x, 0.001, "delayed picks the sample 0.5 s back")
	t.ok(Rec.new().delayed(0.5).is_empty(), "empty recorder has nothing delayed")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_echo_recorder.gd`.
- [ ] **Step 3: Implementar** `echo_recorder.gd` e a fiação. O `main` grava `player.global_position`, `player.rotation.y`, `camera.rotation.x` e `player.crouched`, e conecta `acted` a `recorder.mark_action`.
- [ ] **Step 4: Rodar e ver passar.** Rodar o unit. Esperado: 0 falhas.
- [ ] **Step 5: Checkpoint.** Rodar o CP.

---

### Task 9: O espelho da casa: devolver gestos, bater, reflexo atrasado e boneco

**Files:**
- Create: `faz-de-conta/scripts/mirror_brain.gd`, `faz-de-conta/scripts/house_mirror.gd`, `faz-de-conta/scripts/mannequin.gd`, `faz-de-conta/scripts/mirror_reflection.gd`
- Create: `faz-de-conta/tests/test_mirror_brain.gd`
- Modify: `faz-de-conta/scripts/player.gd` (tecla **B**), `faz-de-conta/scripts/doll.gd` (cores, `set_pose_variant`), `faz-de-conta/scripts/ball.gd` (`push(dir: Vector3)`), `faz-de-conta/scripts/main.gd` (`ELIAS_STYLE`, `is_seen`, montagem)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes: `recorder.delayed` (Tarefa 8), `sfx.play_at` (Tarefa 7) e `player.acted` (Tarefa 8).
- Produces:
  - `mirror_brain.gd` (`RefCounted`):
    - Constantes: `COOLDOWN := 4.0`, `SILENCE_AFTER_PLAYER := 2.0`, `IDLE_INVITE := 60.0`, `KNOCK_GROUP := 1.5`.
    - `register(verb: StringName) -> void`: `&"mover"` só zera o tempo ocioso. Batidas em sequência dentro de `KNOCK_GROUP` somam uma contagem.
    - `update(dt: float) -> Dictionary`: retorna `{}` ou `{"verb": StringName, "count": int, "invite": bool}`.
    - `responses_given() -> int`
  - `house_mirror.gd` (`Node`): `respond(r: Dictionary) -> bool`. Retorna se aplicou; uma resposta que não pôde ser aplicada é consumida mesmo assim.
  - `mannequin.gd` (`Node3D`, só malhas):
    - `build(style: Dictionary, scale_factor := 1.0) -> void`
    - `set_pose(pose: StringName) -> void`, com `&"em_pe"`, `&"agachado"` ou `&"sentado"`
    - `set_look(yaw: float, pitch: float) -> void`
    - `set_render_layer(bit: int) -> void`
    - `add_notebook() -> void`: um caderno no colo, usado nas Tarefas 12 e 15.
  - `main.gd`:
    - `const ELIAS_STYLE := {"coat": Color("#4a5866"), "skin": Color("#d9b99b"), "hair": Color("#4a3a2c"), "trousers": Color("#2b2b30")}`
    - `func is_seen(point: Vector3) -> bool`: o ponto precisa estar no frustum da câmera e não pode haver oclusor de máscara 1 entre a câmera e o ponto.
  - `ball.push(dir: Vector3) -> void`
  - `doll.set_pose_variant(i: int) -> void`, com 3 variantes de rotação.
- Regras de `MirrorBrain`:
  - Responde quando há pendente, passaram `SILENCE_AFTER_PLAYER` desde a última ação e `COOLDOWN` desde a última resposta.
  - Escolhe o verbo pendente com maior contagem; em empate, o mais recente. Depois zera aquele verbo, de modo que **uma ação gera no máximo uma resposta**.
  - Em `&"bater"`, devolve a contagem do último grupo.
  - Depois de `IDLE_INVITE` s sem atividade, retorna uma única vez `{"verb": &"rolar", "count": 1, "invite": true}`.
  - Fora o convite, nunca retorna um verbo que não foi registrado.
- Regras de `HouseMirror.respond`:
  - `&"dobrar"`:
    - Alterna F2 ou F4, o mais distante do jogador, só se a dobradiça estiver a 3 m ou mais dele.
    - **Nunca** mexe em F1, F3 ou em portas.
  - `&"bater"`: toca `knock` `count` vezes, a 0.4 s de intervalo e com a última atrasada 0.2 s (o grau de erro), num ponto de parede a 3 m ou mais do jogador.
  - `&"rolar"`: chama `Ball.push` numa direção aleatória horizontal.
  - `&"boneco"`: muda a variante de pose do boneco **só se** `not is_seen(doll)` por 5 s ou mais. Se nunca ficar 5 s fora de vista, a resposta expira em 30 s.
- Bater:
  - A tecla **B** funciona quando o `RayCast3D` acerta algo a 1.5 m ou menos.
  - Toca `knock` no ponto, emite `acted(&"bater", collider)` e chama `brain.register(&"bater")`.
  - Os verbos `dobrar`, `rolar` e `boneco` também chamam `register`. O movimento do jogador acima de 0.3 m/s chama `register(&"mover")` no máximo uma vez por segundo.
- Reflexo:
  - Um `SubViewport` de 512×512 no espelho (15.32, 1.35, 2.0), com a câmera do espelho espelhada no plano x = 15.32.
  - Um manequim com `ELIAS_STYLE` fica na camada visual 11, posicionado em `recorder.delayed(0.5)`.
  - A `cull_mask` da câmera do jogador exclui a camada 11. O reflexo só fica ativo com o jogador no quarto.
- Boneco: passa a usar `ELIAS_STYLE`, com casaco e cabelo.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_mirror_brain.gd`, com o helper `_run(b, seconds)` que chama `update(0.1)` e coleta as respostas:

```gdscript
extends RefCounted
const Brain = preload("res://scripts/mirror_brain.gd")

func _run(b, seconds: float) -> Array:
	var out := []
	for i in int(seconds * 10.0):
		var r: Dictionary = b.update(0.1)
		if not r.is_empty():
			out.append(r)
	return out

func test_waits_for_silence(t) -> void:
	var b = Brain.new()
	b.register(&"dobrar")
	t.eq(_run(b, 1.9).size(), 0, "no response within 2 s of the action")
	t.eq(_run(b, 0.3).size(), 1, "responds after silence")

func test_one_response_per_action(t) -> void:
	var b = Brain.new()
	b.register(&"dobrar")
	var got := _run(b, 50.0).filter(func(r): return not r.invite)
	t.eq(got.size(), 1, "one action, one response")

func test_cooldown_and_tie_break(t) -> void:
	var b = Brain.new()
	b.register(&"rolar"); b.register(&"dobrar")
	var got := _run(b, 6.0)
	t.eq(got[0].verb, &"dobrar", "tie goes to the most recent")
	t.eq(got.size(), 1, "cooldown holds the second response")
	t.eq(_run(b, 2.0)[0].verb, &"rolar", "second response after cooldown")

func test_knock_count(t) -> void:
	var b = Brain.new()
	for i in 3:
		b.register(&"bater"); _run(b, 0.3)
	var got := _run(b, 3.0)
	t.eq(got[0].count, 3, "house knocks back the same count")

func test_move_is_not_a_gesture_and_invite_once(t) -> void:
	var b = Brain.new()
	b.register(&"mover")
	t.eq(_run(b, 59.0).size(), 0, "moving is never answered")
	var inv := _run(b, 200.0)
	t.eq(inv.size(), 1, "idle invite happens once")
	t.ok(inv[0].invite and inv[0].verb == &"rolar", "invite is the ball")

func test_never_invents(t) -> void:
	var b = Brain.new()
	b.register(&"bater"); b.register(&"dobrar")
	for r in _run(b, 30.0):
		t.ok(r.verb in [&"bater", &"dobrar"] or r.invite, "only answers what the player did")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_mirror_brain.gd`.
- [ ] **Step 3: Implementar** `mirror_brain.gd`, `house_mirror.gd`, `mannequin.gd` e `mirror_reflection.gd`, mais as mudanças em `player`, `ball`, `doll` e `main`. O cérebro só roda com `main.autonomous`.
- [ ] **Step 4: Teste de mundo** em `selftest.gd`, antes de "final state":

```gdscript
	print("SELFTEST: house mirror")
	var f1_before: bool = _node("F1").is_at_b()
	var f3_before: bool = _node("F3").is_at_b()
	_record(main.house_mirror.respond({"verb": &"dobrar", "count": 1, "invite": false}), "house folds back from far away", "")
	await get_tree().create_timer(1.3).timeout
	_record(_node("F2").is_at_b() or _node("F4").is_at_b(), "house used F2 or F4", "")
	_record(_node("F1").is_at_b() == f1_before and _node("F3").is_at_b() == f3_before, "house never touches F1 or F3", "")
	for n in ["F2", "F4"]:
		if _node(n).is_at_b():
			await _toggle(n)
	var saved_m: Vector3 = main.player.global_position
	main.player.global_position = Vector3(8.0, 0.2, 2.6)
	await get_tree().physics_frame
	main.house_mirror.respond({"verb": &"dobrar", "count": 1, "invite": false})
	await get_tree().create_timer(1.3).timeout
	_record(not _node("F2").is_at_b() and not _node("F4").is_at_b(), "house does not fold within 3 m of the player", "")
	main.player.global_position = saved_m
	_record((main.player.get_node("Camera3D").cull_mask & (1 << 10)) == 0, "player camera does not see the reflection layer", "")
```

- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP. Abrir o jogo e testar:
  - bater 3× numa parede e ouvir 3 batidas de volta;
  - dobrar o F2 e ver a casa dobrar o F4 de longe;
  - ver no espelho o reflexo atrasado.

---

### Task 10: 03:33, os ecos de Elias

**Files:**
- Create: `faz-de-conta/scripts/echo.gd`, `faz-de-conta/scripts/hour_event.gd`
- Create: `faz-de-conta/tests/test_echo.gd`
- Modify: `faz-de-conta/scripts/ball.gd` (`roll_back()`), `faz-de-conta/scripts/main.gd` (`hora_started` e `hora_ended` → `hour_event`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes:
  - De `recorder`: `select_segments`, `get_sample` e `stats` (Tarefa 8).
  - De `Mannequin`: `build`, `set_pose` e `set_look` (Tarefa 9).
  - De `sfx`: `set_casa_muted` e `play_at` (Tarefa 7).
- Produces:
  - `echo.gd` (`Node3D`):
    - `static func sample_at(recorder, seg: Vector2i, t: float) -> Dictionary`: posição e ângulos interpolados entre amostras consecutivas, com laço em `(seg.y - seg.x) / SAMPLE_HZ`. `crouched` e `action` vêm da amostra anterior.
    - `setup(recorder, seg: Vector2i, phase: float) -> void`, `freeze() -> void`, `resume() -> void` (usado na Tarefa 15) e `is_frozen() -> bool`.
    - Toca `step` ao se deslocar e `click` em amostras com ação, com o volume em −12 dB.
  - `hour_event.gd` (`Node`):
    - `begin() -> void` e `end() -> void`
    - `var echoes: Array[Node3D]` e `is_active() -> bool`
    - `signal began` e `signal ended`
- Comportamento:
  - `begin()`:
    - Faz `sfx.set_casa_muted(true)` por 2.0 s e depois `false`. O relógio está parado, então o tique não volta. A chuva e a respiração ficam no bus `Mundo`.
    - Cria um eco por trecho de `select_segments()`, com fase `i * 0.37` s, sob o nó `Echoes`.
    - Volta o tempo em detalhes:
      - `Ball.roll_back()` empurra a bola de volta para a posição que ela tinha 10 s antes; o `main` guarda essa posição a cada segundo.
      - Uma dobra que está em B, entre F1, F2 e F4, com a dobradiça a 3 m ou mais do jogador, chama `interact()` e passa pela guarda do F1.
      - Um `CPUParticles3D` cinza com gravidade (0, +0.05, 0), "a poeira sobe", aparece perto do jogador a 3 m ou mais.
  - `end()`: congela todos os ecos, que **ficam como figuras imóveis**.
  - Os ecos são manequins com `ELIAS_STYLE`, nunca têm `CollisionObject3D` e não recebem input.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_echo.gd`:

```gdscript
extends RefCounted
const Rec = preload("res://scripts/echo_recorder.gd")
const Echo = preload("res://scripts/echo.gd")

func _line(r) -> void:
	for i in 600:
		r.update(1.0 / 60.0, Vector3(i / 60.0, 0, 0), 0.0, 0.0, false)

func test_loops_inside_segment(t) -> void:
	var r = Rec.new(); _line(r)
	var seg := Vector2i(0, 80)
	t.near(Echo.sample_at(r, seg, 0.0).pos.x, r.get_sample(0).pos.x, 0.001, "starts at the segment start")
	t.near(Echo.sample_at(r, seg, 8.0).pos.x, r.get_sample(0).pos.x, 0.001, "loops after 8 s")

func test_never_leaves_recorded_path(t) -> void:
	var r = Rec.new(); _line(r)
	var seg := Vector2i(80, 160)
	for k in 100:
		var x: float = Echo.sample_at(r, seg, k * 0.137).pos.x
		t.ok(x >= r.get_sample(80).pos.x - 0.001 and x <= r.get_sample(159).pos.x + 0.001, "echo stays on what the player did")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_echo.gd`.
- [ ] **Step 3: Implementar** `echo.gd`, `hour_event.gd`, `ball.roll_back()` e a fiação: `hora_started` chama `begin` e `hora_ended` chama `end`.
- [ ] **Step 4: Teste de mundo** em `selftest.gd`. Primeiro alimente o `recorder` com o laço inteiro: o caminho do selftest, de `SPAWN` à beira do tampo, a 1.4 m/s, mais 10 s agachado na cabana. Depois:

```gdscript
	print("SELFTEST: 03:33")
	main.hour_event.begin()
	await get_tree().create_timer(0.5).timeout
	_record(main.hour_event.echoes.size() > 0, "echoes appear at 03:33", "")
	_record(main.get_node("Echoes").find_children("*", "CollisionObject3D", true, false).is_empty(), "echoes have no collision", "")
	_expect_at("DoorFront", true, "front door stays open during 03:33")
	_check_segment(Vector3(1.8, 0.85, 8.3), Vector3(1.7, 0.85, 9.4), "spawn -> front door during 03:33")
	_check_segment(Vector3(1.7, 0.85, 9.4), Vector3(2.0, 0.85, 12.0), "front door -> tampo edge during 03:33")
	main.hour_event.end()
	_record(main.hour_event.echoes.all(func(e): return e.is_frozen()), "winding freezes the echoes", "")
	# rodar de novo os segmentos completos do laço, já com os ecos imóveis
```

Torne os segmentos do laço uma função `_loop_segments(suffix: String)`, chamada uma vez no bloco original e outra aqui com `" with frozen echoes"`.

- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP. Abrir o jogo e forçar o evento chamando `main.visit.clock.force_stop()` por um atalho de debug (F9), aceito só com `OS.is_debug_build()`. É preciso reconhecer os próprios trajetos.

---

### Task 11: As coisas das frestas

**Files:**
- Create: `faz-de-conta/scripts/crack_placement.gd`, `faz-de-conta/scripts/crack_thing.gd`
- Create: `faz-de-conta/tests/test_crack_placement.gd`
- Modify: `faz-de-conta/scripts/hour_event.gd` (mostrar em `begin` e esconder em `end`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes: `main.is_seen(point)` (Tarefa 9) e `hour_event.began/ended` (Tarefa 10).
- Produces:
  - `crack_placement.gd` (`RefCounted`):
    - Constantes: `MIN_PLAYER_DIST := 4.0`, `MIN_DOOR_DIST := 2.5`, `FRONT_DOOR := Vector3(1.82, 0.0, 9.1)`.
    - `static func pick(anchors: Array[Vector3], player_pos: Vector3, current: int, seen: Callable) -> int`:
      - escolhe o índice da âncora válida mais distante do jogador, ou −1;
      - uma âncora válida não está vista, fica a 4 m ou mais do jogador, a 2.5 m ou mais da porta e não é a atual.
  - `crack_thing.gd` (`Node3D`, só malhas):
    - Tem dentes de porcelana (caixinhas `#f2efe6`) e ponteiros enferrujados (caixas finas `#6b3a22`).
    - Faz `relocate()` quando deixa de ser vista depois de ter sido vista, ou quando está fora de vista e a menos de 4 m do jogador.
    - **Nunca se move enquanto vista.** Com `pick == -1`, fica `visible = false`.
- Valores:
  - São 3 coisas.
  - Âncoras nos cantos, no chão: (0.3, 0, 0.3), (8.1, 0, 0.3), (8.1, 0, 6.7), (0.3, 0, 6.7), (9.6, 0, 0.3), (15.1, 0, 0.3), (15.1, 0, 5.3), (13.0, 0, 8.9), (10.7, 0, 8.9), (6.5, 0, 8.9).
  - Ficam ativas só durante HORA.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_crack_placement.gd`:

```gdscript
extends RefCounted
const Crack = preload("res://scripts/crack_placement.gd")
var A: Array[Vector3] = [Vector3(0.3, 0, 0.3), Vector3(8.1, 0, 0.3), Vector3(2.0, 0, 8.6), Vector3(15.1, 0, 5.3)]
var never := func(_p): return false

func test_respects_distances(t) -> void:
	var i: int = Crack.pick(A, Vector3(1.0, 0, 1.0), -1, never)
	t.eq(i, 3, "farthest valid anchor")
	t.ok(A[i].distance_to(Vector3(1, 0, 1)) >= 4.0, "never near the player")

func test_never_near_door_or_current_or_seen(t) -> void:
	t.ok(Crack.pick(A, Vector3(14.0, 0, 5.0), -1, never) != 2, "never next to the front door")
	t.ok(Crack.pick(A, Vector3(1.0, 0, 1.0), 3, never) != 3, "always somewhere else")
	var seen_far := func(p): return p.x > 10.0
	t.ok(Crack.pick(A, Vector3(1.0, 0, 1.0), -1, seen_far) != 3, "never where the player is looking")

func test_hides_when_nothing_fits(t) -> void:
	t.eq(Crack.pick(A, Vector3(4.0, 0, 3.0), -1, func(_p): return true), -1, "hide instead of coming close")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_crack_placement.gd`.
- [ ] **Step 3: Implementar** `crack_placement.gd`, `crack_thing.gd` e a fiação no `hour_event`.
- [ ] **Step 4: Teste de mundo:** dentro do bloco "03:33", `_record(main.find_children("CrackThing*", "", true, false).all(func(n): return n.find_children("*", "CollisionObject3D", true, false).is_empty()), "crack things have no collision", "")`.
- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP.

---

### Task 12: O duplo escrevendo

**Files:**
- Create: `faz-de-conta/scripts/double_writer.gd`
- Create: `faz-de-conta/tests/test_double_writer.gd`
- Modify: `faz-de-conta/scripts/hour_event.gd` (o duplo), `faz-de-conta/scripts/doll.gd` (`become_double(seat: Vector3)`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes:
  - De `recorder`: `stats()` (Tarefa 8).
  - De `catalog`: `add_double_entries` (Tarefa 4).
  - De `sfx`: `play_pencil_pattern` (Tarefa 7).
  - `main.is_seen` (Tarefa 9).
- Produces:
  - `double_writer.gd` (`RefCounted`): `static func entries(stats: Dictionary) -> Array[String]`. Retorna três textos sem o prefixo `Item N —`; o número vem do catálogo.
  - `doll.become_double(seat: Vector3) -> void`: move o boneco, com o alvo `boneco` junto, para o banco da entrada. O assento fica em `seat = Vector3(0.7, 0.45, 8.5)`, de frente para o norte. O boneco ganha caderno e lápis, e o lápis anima.
- Texto, cópia fixa. A primeira entrada vem do spec 5.3:
  1. `catalogador. A mão direita gasta de um lado só.`
  2. Escolhida pela estatística dominante, testando nesta ordem:
     - `crouched_s >= 60` → `catalogador. Passa muito tempo agachado, como criança.`
     - Senão, a ação de maior contagem, entre:
       - `dobrar` → `catalogador. Dobra as paredes para ver o que há atrás.`
       - `bater` → `catalogador. Bate nas paredes e espera resposta.`
       - `rolar` → `catalogador. Brinca com a bola quando acha que ninguém vê.`
     - Senão, `still_s >= 120` → `catalogador. Fica parado olhando, por muito tempo.`
     - Senão → `catalogador. Anda pela casa como quem já conhece.`
  3. `catalogador. Entrou pela porta da rua. Ainda não saiu.`
- Comportamento no 03:33:
  - O boneco vira duplo assim que o boneco e o banco estiverem fora de vista. Ele espera, sem nunca se mover à vista.
  - Com 6 s, 12 s e 18 s de HORA, uma entrada vai para o catálogo com `play_pencil_pattern` no banco.
  - Se `end()` vier antes, as entradas restantes entram no `end()`, para que o caderno sempre as tenha depois do 03:33.
  - Depois do 03:33, o duplo continua sentado no banco, imóvel.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_double_writer.gd`:

```gdscript
extends RefCounted
const Writer = preload("res://scripts/double_writer.gd")
func _stats(c := 0.0, s := 0.0, a := {}) -> Dictionary:
	return {"crouched_s": c, "still_s": s, "meters": 100.0, "actions": a}

func test_first_and_last_are_fixed(t) -> void:
	var e: Array[String] = Writer.entries(_stats())
	t.eq(e.size(), 3, "three entries")
	t.eq(e[0], "catalogador. A mão direita gasta de um lado só.", "spec example first")
	t.eq(e[2], "catalogador. Entrou pela porta da rua. Ainda não saiu.", "closing entry")

func test_dominant_behavior(t) -> void:
	t.eq(Writer.entries(_stats(90.0))[1], "catalogador. Passa muito tempo agachado, como criança.", "crouching wins")
	t.eq(Writer.entries(_stats(0.0, 0.0, {&"bater": 5, &"dobrar": 2}))[1], "catalogador. Bate nas paredes e espera resposta.", "most counted action")
	t.eq(Writer.entries(_stats())[1], "catalogador. Anda pela casa como quem já conhece.", "default")

func test_never_invents(t) -> void:
	var e: Array[String] = Writer.entries(_stats(0.0, 0.0, {&"rolar": 1}))
	t.ok(not e[1].contains("Bate") and not e[1].contains("Dobra"), "only what the player did")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_double_writer.gd`.
- [ ] **Step 3: Implementar** `double_writer.gd`, `doll.become_double` e o agendamento no `hour_event`.
- [ ] **Step 4: Teste de mundo**, dentro do bloco "03:33" e depois de `end()`:

```gdscript
	var duplo := main.catalog.entries.filter(func(e): return e.author == &"duplo")
	_record(duplo.size() == 3, "the double wrote three entries", str(duplo.size()))
	_record(main.catalog.entries[-1].number == main.catalog.entries[-2].number + 1, "double entries continue the numbering", "")
	_record(_node("Doll").global_position.distance_to(Vector3(0.7, 0.45, 8.5)) < 0.3, "the double sits on the entry bench", "")
```

Nesta checagem, o selftest roda com o jogador em `SPAWN`, olhando para o norte; o banco fica atrás e à esquerda, e o boneco no quarto, fora de vista. Os segmentos "with frozen echoes" já cobrem o banco ocupado.

- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP.

---

### Task 13: As peças da verdade: relógios de bolso, caderno e carta, página da cabana e o corpo gigante

**Files:**
- Modify: `faz-de-conta/scripts/main.gd` (`_build_furniture`: ocupantes da sala das figuras; `_build_story_props`; `GiantElias`)
- Modify: `faz-de-conta/scripts/hour_event.gd` (no `end`: `catalog.set_flag(&"after_hora", true)` e mostrar a página da cabana)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes:
  - De `Mannequin`: `build(style, 12.0)`, `set_pose(&"sentado")` e `add_notebook` (Tarefa 9).
  - `_catalog_target` (Tarefa 4).
  - `visit` (Tarefa 6).
- Produces:
  - Nós `PocketWatchA` e `PocketWatchB`, cilindros de latão r 0.05 no peito dos ocupantes em x 11.15 e 11.85.
  - `CatalogerNotebook` e `CatalogerLetter`, caixas `mat_cream` no colo do ocupante em x 12.55, que fica **sem** relógio.
  - `CabanaPage`, papel sob a almofada em (1.5, 0.13, 3.5), escondido até `after_hora`. Ao aparecer, cria o alvo `pagina_cabana`.
  - `GiantElias`:
    - É um `Mannequin` com `ELIAS_STYLE`, escala `GIANT` e pose `&"sentado"`, sem colisão.
    - Fica ao sul da redoma, centrado em (2.0, −10.0, 20.0) e virado para o norte, com a mão direita junto ao topo da redoma sobre a entrada: "a mão na corda da maquete".
    - `visible = false` até `hora_ended`. A partir de DEPOIS, aparece pelas janelas e pela porta da rua.

- [ ] **Step 1: Escrever o teste que falha** em `selftest.gd`. O bloco "03:33" já fechou com `end()`:

```gdscript
	print("SELFTEST: truth props")
	_record(main.find_child("PocketWatchA", true, false) != null and main.find_child("PocketWatchB", true, false) != null, "two Inácio figures carry the same pocket watch", "")
	_record(main.find_child("CatalogerLetter", true, false) != null, "the cataloger figure holds the letter", "")
	_record(main.catalog.can_catalog(&"pagina_cabana"), "cabana page appears after 03:33", "")
	var targets2 := get_tree().get_nodes_in_group("catalog_target")
	_record(targets2.size() == main.CatalogData.ITEMS.size(), "every catalog item now has a target", str(targets2.size()))
	var giant := main.get_node_or_null("GiantElias")
	_record(giant != null and giant.visible, "Elias's giant body is seen after 03:33", "")
	_record(giant != null and giant.find_children("*", "CollisionObject3D", true, false).is_empty(), "giant body has no collision", "")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o selftest. Esperado: `FAIL two Inácio figures carry the same pocket watch`.
- [ ] **Step 3: Implementar** os adereços e a fiação. O selftest de "catalog" da Tarefa 4 continua valendo antes do 03:33, com `size - 1`.
- [ ] **Step 4: Rodar e ver passar.** Rodar o selftest. Esperado: 0 falhas.
- [ ] **Step 5: Checkpoint.** Rodar o CP. Abrir o jogo, passar pelo 03:33 com F9, dar corda e olhar pela porta da rua: o corpo enorme de Elias está sentado à bancada.

---

### Task 14: A saída e a escolha (spec 5.3 e 6.7)

**Files:**
- Create: `faz-de-conta/scripts/ending_model.gd`
- Create: `faz-de-conta/tests/test_ending_model.gd`
- Create: `faz-de-conta/scripts/ending.gd`
- Modify: `faz-de-conta/scripts/main.gd` (`exit_edge_reached` → `ending.finish(visit.on_exit())`; `var ended`, `var ending_outcome`)
- Modify: `faz-de-conta/scripts/notebook_ui.gd` (`show_final`)
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes:
  - `exit_edge_reached` (Tarefa 2).
  - `visit.on_exit()` (Tarefa 6).
  - `clock_model.force_stop()` (Tarefa 3).
  - `sfx.set_casa_muted` (Tarefa 7).
  - `notebook.show_final` (Tarefa 5).
  - `hour_event.echoes` (Tarefa 10).
- Produces:
  - `ending_model.gd` (`RefCounted`):
    - `static func final_entry(outcome: StringName) -> String`
    - `static func clock_running(outcome: StringName) -> bool`
    - `static func echoes_mode(outcome: StringName) -> StringName`: `&"loop"` para corda, `&"frozen"` para parar e `&"as_is"` para incompleto.
    - `static func figure_alive(outcome: StringName) -> bool`: só `corda` é `true`.
  - `ending.gd` (`Node`):
    - `finish(outcome: StringName) -> void`: só tem efeito na primeira chamada.
    - `var final_camera: Camera3D`
    - `signal finished(outcome: StringName)`
  - `main.ended: bool` e `main.ending_outcome: StringName`.
- Texto, cópia literal do spec 5.3:
  - `corda`: `Item 214 — maquete de casa. Dei corda. Dentro, uma figura nova. Ele não está mais sozinho.`
  - `parar`: `Item 214 — maquete de casa. Deixei parar às 03:33. As figuras pararam de olhar para mim. A minha não.`
  - `incompleto`: `Item 214 — maquete de casa. Funciona. Não sei por que há uma figura a mais.`
- Sequência de `finish(outcome)`:
  1. Ativa `player.input_locked`; o jogador para.
  2. Faz um fade a preto de 1.0 s num `ColorRect` sem texto.
  3. Aplica o relógio. Para `parar`, chama `clock_model.force_stop()` (o ponteiro fica em 03:33, sem tique) e `sfx.set_casa_muted(true)`; a chuva continua no `Mundo`. Para os outros, o relógio segue com a corda que tinha.
  4. Ativa a `final_camera`: a câmera do corpo gigante, com a posição e o enquadramento definidos na Tarefa 15, e esconde o `GiantElias`, porque a câmera são os olhos dele. Abre o fade.
  5. Depois de 3.0 s, `notebook.show_final(EndingModel.final_entry(outcome))` mostra **só** essa entrada, em papel, na metade inferior da tela.
- Não há "fim de jogo", nota nem créditos. ESC solta o mouse e R recarrega, como hoje.
- Sair pela porta da rua **não** encerra o jogo. Só a `ExitEdge` encerra.

- [ ] **Step 1: Escrever os testes que falham** em `tests/test_ending_model.gd`:

```gdscript
extends RefCounted
const End = preload("res://scripts/ending_model.gd")

func test_final_entries_are_the_spec_texts(t) -> void:
	t.eq(End.final_entry(&"corda"), "Item 214 — maquete de casa. Dei corda. Dentro, uma figura nova. Ele não está mais sozinho.", "with winding")
	t.eq(End.final_entry(&"parar"), "Item 214 — maquete de casa. Deixei parar às 03:33. As figuras pararam de olhar para mim. A minha não.", "letting it stop")
	t.eq(End.final_entry(&"incompleto"), "Item 214 — maquete de casa. Funciona. Não sei por que há uma figura a mais.", "leaving early")

func test_world_after_exit(t) -> void:
	t.ok(End.clock_running(&"corda") and End.clock_running(&"incompleto"), "clock keeps running")
	t.ok(not End.clock_running(&"parar"), "clock stops behind him")
	t.eq(End.echoes_mode(&"corda"), &"loop", "company in a loop")
	t.eq(End.echoes_mode(&"parar"), &"frozen", "stopped together")
	t.eq(End.echoes_mode(&"incompleto"), &"as_is", "echoes stay as they were")
	t.ok(End.figure_alive(&"corda") and not End.figure_alive(&"parar") and not End.figure_alive(&"incompleto"), "only the wound clock keeps him moving")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o unit. Esperado: `could not load res://tests/test_ending_model.gd`.
- [ ] **Step 3: Implementar** `ending_model.gd`, `ending.gd` e `show_final`. Nesta tarefa, a `final_camera` usa provisoriamente a pose da Tarefa 15: `(1.8, 14.0, 22.0)` olhando para `(1.8, 0.5, 8.3)`, com FOV 24.
- [ ] **Step 4: Teste de mundo.** Ele fica no **fim** do `_run`, depois de "final state" e antes de `SELFTEST RESULT`, porque encerra a visita. Como o 03:33 já foi testado e a página da cabana ainda não foi catalogada, a saída esperada é `incompleto`. Isso cobre o Review Focus 1, porque a saída acontece com ecos na casa:

```gdscript
	print("SELFTEST: exit")
	_expect_at("DoorFront", true, "front door is still open before leaving")
	main.player.set_physics_process(true)
	main.player.global_position = Vector3(2.0, 0.2, 12.2)
	for i in 4:
		await get_tree().physics_frame
	main.player.set_physics_process(false)
	_record(main.ended and main.ending_outcome == &"incompleto", "reaching the tampo edge ends the visit", str(main.ending_outcome))
	await get_tree().create_timer(1.2).timeout
	_record(main.ending.final_camera.current, "final camera takes over", "")
```

- [ ] **Step 5: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 6: Checkpoint.** Rodar o CP e jogar os três finais: sair cedo, sair sem corda e sair com corda depois da página da cabana.

---

### Task 15: Algo de Elias fica na maquete: a figura nova e a imagem final pela redoma (spec 5.3), mais docs e lint

**Files:**
- Modify: `faz-de-conta/scripts/ending.gd` (figura nova, ecos por modo, pose final da câmera)
- Modify: `faz-de-conta/README.md` (controles, testes, o que é o slice)
- Modify: `context/arquitetura.md`, `context/decisoes.md`, `context/achados.md`, `context/historico.md`
- Test: `faz-de-conta/scripts/selftest.gd`

**Interfaces:**
- Consumes:
  - De `EndingModel`: `echoes_mode` e `figure_alive` (Tarefa 14).
  - De `Echo`: `resume()` e `freeze()` (Tarefa 10).
  - De `Mannequin`: `build`, `set_pose` e `add_notebook` (Tarefa 9).
  - `sfx.play_pencil_pattern` (Tarefa 7).
  - `ending.finished` (Tarefa 14).
- Produces: o nó `NewFigure`, um `Mannequin` com `ELIAS_STYLE`, em escala 1, pose `&"sentado"`, com caderno no colo e sem colisão.
- Conteúdo, a partir de "algo dele fica para sempre na maquete" [Pedro] e do spec 5.3:
  - A `NewFigure` nasce em `finish()` em **todos** os desfechos.
  - Ela fica sentada no chão da entrada, em `(SPAWN.x, 0.0, SPAWN.z)`, onde Elias começou, com `rotation.y = PI`: o rosto virado para a porta da rua, e portanto para a câmera.
  - A partir do modo:

    | Modo | Ecos | `NewFigure` | Relógio e som |
    |---|---|---|---|
    | `&"loop"` (corda) | Todo eco congelado chama `resume()` | Vira uma página a cada 4 s (o braço gira 25° e volta), com `play_pencil_pattern`: companhia, em loop | O tique segue |
    | `&"frozen"` (parar) | Todos ficam congelados | Imóvel. O manequim do duplo no banco e os ecos também ficam imóveis: "parado junto, para sempre, no último minuto de Inácio" | Ponteiro em 03:33, `Casa` mudo |
    | `&"as_is"` (incompleto) | Ficam como estavam: congelados se houve 03:33, nenhum se não houve | Imóvel | O relógio segue com a corda que tinha |
- Imagem final:
  - A `final_camera` fica em `(1.8, 14.0, 22.0)`, olhando para `(1.8, 0.5, 8.3)`, com FOV 24. São os olhos do Elias em escala real, sobre a bancada.
  - Ela vê, pela redoma e pela porta da rua aberta, a figura nova sentada na entrada.
  - O `GiantElias` fica escondido, porque o corpo "acordou e foi embora" e a câmera é ele.

- [ ] **Step 1: Escrever o teste que falha** em `selftest.gd`, logo depois do bloco "exit":

```gdscript
	print("SELFTEST: what stays")
	var fig := main.get_node_or_null("NewFigure")
	_record(fig != null, "a new figure stays in the maquete", "")
	if fig != null:
		var head: Vector3 = fig.global_position + Vector3(0, 0.9, 0)
		var cam: Camera3D = main.ending.final_camera
		_record(fig.find_children("*", "CollisionObject3D", true, false).is_empty(), "new figure has no collision", "")
		_record(fig.global_position.distance_to(Vector3(main.SPAWN.x, 0.0, main.SPAWN.z)) < 0.2, "new figure sits where Elias arrived", "")
		_record(cam.is_position_in_frustum(head), "final camera frames the new figure", "")
		var q := PhysicsRayQueryParameters3D.create(cam.global_position, head, 1)
		_record(main.get_world_3d().direct_space_state.intersect_ray(q).is_empty(), "new figure is seen through the redoma and the open door", "")
		_record(not main.get_node("GiantElias").visible, "the giant body is gone: the camera is him", "")
		_record(main.hour_event.echoes.all(func(e): return e.is_frozen()), "leaving early keeps the echoes as they were", "")
```

- [ ] **Step 2: Rodar e ver falhar.** Rodar o selftest. Esperado: `FAIL a new figure stays in the maquete`.
- [ ] **Step 3: Implementar** a `NewFigure`, os modos de eco e a câmera final em `ending.gd`, sem tocar no texto da Tarefa 14. Se o raio de visão bater em geometria, o ajuste permitido é só a altura e o z da câmera, com y ≥ 6 e z > 12.7 (fora da redoma). A figura não sai da entrada.
- [ ] **Step 4: Rodar e ver passar.** Rodar o unit e o selftest. Esperado: 0 falhas.
- [ ] **Step 5: Verificação manual dos três finais.**
  - Com corda: a figura vira páginas e os ecos andam em loop.
  - Sem corda: tudo parado às 03:33, só chuva.
  - Cedo: uma figura a mais, o relógio andando.
  - Em todos, nenhum texto além da entrada final em papel.
- [ ] **Step 6: Docs.**
  - `README.md`:
    - controles: WASD, mouse, E, Q, Tab, C, B, F, R, ESC; e F9 só em debug;
    - os comandos de unit e selftest;
    - o slice em 5 linhas.
  - `context/arquitetura.md`: os scripts novos e a regra "lógica pura sem `class_name`, preload". Toda linha com `[2026-10-27] (e)`.
  - `context/decisoes.md`, seção `#jogo`, com uma linha `(i)` para cada decisão deste plano:
    - teclas Q, Tab, C e B;
    - F1 a −45° e a guarda;
    - tempos do relógio e do gatilho (`DRAIN_*`, `HURRY`, `MAX_PRE_HORA`, `HARD_LIMIT`, `STALL`);
    - gravador (10 Hz, 6 ecos, 8 s, pontuação);
    - manequim como representação dos ecos;
    - som sintetizado;
    - textos de catálogo e páginas;
    - figura nova na entrada e câmera final;
    - labels atrás de `--labels`.
  - `context/achados.md`: confirmar o `~superseded` do A-001; o A-003 fica como está (spec 7).
  - `context/historico.md`: entrada do dia.
- [ ] **Step 7: Checkpoint final.** Rodar o CP. Esperado: `UNIT RESULT: N checks, 0 failures`, `SELFTEST RESULT: N checks, 0 failures` e `python lint.py` sem erros.

---

## Autorrevisão

- **Cobertura do spec:**

  | Spec | Tarefa |
  |---|---|
  | 5.1 (nasce na entrada, 214) | 2, 4 |
  | 5.2 (fragmentos 1–6) | 4, 12, 13 |
  | 5.3 (escolha e o que fica de Elias) | 14, 15 |
  | 6.2 (catalogar, caderno, sem contador, gates) | 4, 5 |
  | 6.3 (relógio, corda decrescente) | 3, 6 |
  | 6.4 (silêncio, ecos, tempo para trás, frestas, duplo, corda encerra, regras duras) | 10, 11, 12 |
  | 6.5 "pelas janelas" | 13 |
  | 6.6 (sons 9–11) | 7, 10, 12 |
  | 6.7 (fim na prática) | 14, 15 |
  | 7 (gatilho, espaço, subconjunto de espelho, pendências do blockout) | 1, 2, 6, 9 |
  | 8 técnico (porta em qualquer minuto, laço com ecos imóveis) | 10, 14 |
  | 11 (restrições) | Global Constraints e Tarefa 15 |

  O critério "a casa devolveu ao menos dois gestos antes do 03:33" fica observável por `brain.responses_given()`, mas não vira teste automático: depende do jogador.
- **Tipos:**
  - Os atos e as saídas usam `StringName` em todo o plano.
  - `Catalog.format`, `add_double_entries`, `select_segments() -> Array[Vector2i]`, `Echo.resume()` e `Mannequin.set_pose(&"sentado")` têm o mesmo nome em todas as tarefas que os usam.
- **Proporção:** os blocos de código são testes e texto fixo; os corpos ficam com quem implementa.

## Execution Handoff

Plano salvo em `docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md`.

Recomendação: **Subagent-driven**. As 15 tarefas encadeiam interfaces: relógio → visita → gravador → 03:33 → fim. Um nome errado numa tarefa do meio quebra as seguintes, e o revisor por tarefa pega isso antes de propagar.
