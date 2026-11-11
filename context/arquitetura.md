---
tipo: contexto
projeto: memoria-de-projeto
descricao: Stack e o mapa da estrutura do projeto verificado por leitura em disco.
estado: estavel
criado: 2026-09-12
relacionado:
  - context/achados.md
---

# Arquitetura

> Documentação técnica da estrutura do repositório, validada diretamente contra os arquivos em disco.

## Baseline declarada vs. verificada {#baseline}

- [2026-09-12] (e) ← `lint.py` Estrutura de memória validada pelo linter local sem erros.

| Componente | Declarado | Verificado? | Real |
|---|---|---|---|
| Módulos de Contexto | `context/` | ✅ | 4 arquivos centrais (`index`, `arquitetura`, `achados`, `decisoes`) + `discussoes/` |
| Camada de Fontes Brutas | `fontes/` | ✅ | `fontes/index.md` presente e preparado |
| Script de Verificação | `lint.py` | ✅ | Operacional com Python 3 |

## Stack {#stack}

- [2026-09-12] (e) ← `lint.py` Python 3 para script de linting e validação de consistência.
- [2026-09-12] (e) ← `context/index.md` Documentação estruturada em Markdown puro com convenções tipadas.
- [2026-10-20] (e) ← `godot --version` e `faz-de-conta/project.godot` **Godot 4.7.2.stable**, renderer GL Compatibility, viewport 1280×720, cena principal `main.tscn`.
- [2026-10-20 ~superseded 2026-11-09] (e) ← `faz-de-conta/` ~~O blockout não usa assets externos: geometria, materiais, luz e UI são gerados por código GDScript.~~ → as figuras humanas entraram como `.glb` CC0: [[arquitetura#assets-figuras]].
- [2026-11-08] (e) ← `blender --version` **Blender 4.5.15 LTS** instalado como ferramenta de produção de assets, fora do jogo exportado: pacote oficial de download.blender.org (sha256 conferido) em `~/.local/opt/blender-4.5.15-linux-x64`, com link em `~/.local/bin/blender`. Exporta `.glb` sem janela (`blender -b --python-expr ...`), testado com um cubo. Ver R14 em [[decisoes#rumo-2026-11-08]].

## O mapa {#mapa}

| Área | Onde mora | O que faz | Risco conhecido |
|---|---|---|---|
| Roteamento | `CLAUDE.md`, `GEMINI.md`, `AGENTS.md` | Roteamento rápido para IAs em toda sessão | → [[achados#formato]] |
| Conhecimento | `context/` | Memória destilada consultada sob demanda | Risco de desatualização se linter não for executado |
| Camada Bruta | `fontes/` | Arquivos imutáveis de entrada externa | Risco de perda de rastreabilidade se editado diretamente |
| Linter | `lint.py` | Valida sintaxe, links, âncoras e procedência | N/A |
| Blockout do jogo | `faz-de-conta/` | Projeto Godot 4.7 jogável do slice | É scaffolding: sem áudio, comportamento da casa ou arte final |

## Jogo — FAZ DE CONTA {#jogo-godot}

> Blockout do slice descrito em [[modelo-arquitetural-dinamico-3d#blockout]]. A
> documentação de execução, controles, telas e limitações está em
> `faz-de-conta/README.md`.

| Arquivo | Papel verificado |
|---|---|
| `faz-de-conta/project.godot` | Configuração Godot 4.7; cena `res://main.tscn`; GL Compatibility |
| `faz-de-conta/main.tscn` | Nó `Main` com `scripts/main.gd` |
| `faz-de-conta/scripts/main.gd` | Constrói a casa, móveis, F1–F4, portas, luzes, labels, UI e modos de captura |
| `faz-de-conta/scripts/foldable.gd` | `AnimatableBody3D` com poses A/B, tween de 1,1 s e colisão por estado |
| `faz-de-conta/scripts/player.gd` | Controlador de primeira pessoa, raycast de 3,4 m e lanterna; a cápsula de 1,7 m é montada em `main.gd` |
| `faz-de-conta/scripts/selftest.gd` | Teste headless de estados, colisão e circulação |
| `faz-de-conta/scripts/wind_clock_model.gd` | `RefCounted` puro: corda, rendimento decrescente, trava, 03:00→03:33, período do tique (desde 2026-10-27) |
| `faz-de-conta/scripts/entry_clock.gd` | `StaticBody3D` do relógio da entrada: prompt "dar corda", sinal `wound`, ponteiro e pêndulo lendo o modelo (desde 2026-10-27) |
| `faz-de-conta/tests/run_unit.gd` | Harness unitário `SceneTree`: roda todo `test_*` de `res://tests/test_*.gd` (desde 2026-10-27) |
| `faz-de-conta/tests/test_wind_clock.gd` | Testes do `WindClockModel` (desde 2026-10-27) |
| `faz-de-conta/scripts/ball.gd`, `music_box.gd`, `doll.gd`, `figure.gd` | Interativos de brinquedo e da sala das figuras |
| `faz-de-conta/blockout-*.png` | Telas de revisão: playroom, corridor, atelier, fold e top |

**Comandos verificados:**

```bash
cd faz-de-conta
godot --headless --editor --quit                         # import/parse
godot --headless --path . -- --selftest                 # 53 checks (66 em 2026-10-27)
godot --headless --path . -s res://tests/run_unit.gd    # unit: 414 checks em 2026-10-27
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-playroom
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-corridor
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-atelier
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-fold
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-top
```

- [2026-10-20] (e) ← `godot --headless --path . -- --selftest` O teste terminou com `SELFTEST RESULT: 53 checks, 0 failures`; cobre estados iniciais, bloqueio das portas fechadas, abertura das portas, o laço com cápsula de 0,28 m de raio/1,6 m de altura e o ida-e-volta das quatro dobras.
- [2026-10-20] (i) O autoteste é diagnóstico de colisão, não playtest: não mede conforto, ritmo, som, medo ou a experiência de sentar na cabana.
- [2026-10-27] (e) ← `faz-de-conta/scripts/main.gd` Estrutura do espaço: `_build_tampo` (nós `Tampo`, `WestTampo`, `Redoma`, `ExitEdge`) e `_build_oficina` (nó `Oficina`, escala `GIANT` = 12, sem colisão) substituíram `_build_atelier`; `SPAWN`, `GIANT`, `signal exit_edge_reached` e `var clock_model` vivem em `main.gd`; `main._process` avança o relógio.
- [2026-10-27] (e) ← `docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md` Padrão da construção: lógica pura em scripts `RefCounted` sem `class_name`, carregados por `preload` e testados no harness unitário; os nós da cena só leem e escrevem nos modelos.
- [2026-10-28] (e) ← `faz-de-conta/scripts/` e `faz-de-conta/tests/` Scripts novos do plano do relojoeiro (Tarefas 4–15), todos sem `class_name` e carregados por `preload`:
  - Lógica pura (`RefCounted`, com teste em `tests/`): `visit_state.gd` (atos da visita, gatilho do 03:33, desfecho), `catalog_data.gd` + `catalog.gd` (itens a partir de 214, páginas, entradas do duplo), `echo_recorder.gd` (10 Hz, trechos de 8 s, até 6 ecos, `stats`), `mirror_brain.gd` (gestos que a casa repete), `crack_placement.gd` (onde as coisas das frestas aparecem), `double_writer.gd` (as três entradas do duplo), `ending_model.gd` (texto final e mundo depois da saída). `echo.gd` tem a parte estática `sample_at` testada em `test_echo.gd`.
  - Nós da cena: `catalog_target.gd`, `notebook_ui.gd` (caderno em papel, `peek`, `show_final`), `sfx_bank.gd` (som sintetizado, buses `Casa`/`Mundo`), `mannequin.gd` (corpo de caixas sem colisão: espelho, ecos, gigante, figura nova), `house_mirror.gd`, `mirror_reflection.gd` (espelho do quarto mostra Elias), `echo.gd`, `hour_event.gd` (03:33), `crack_thing.gd`, `ending.gd` (fade, câmera final, figura nova).
- [2026-10-28] (e) ← `faz-de-conta/scripts/main.gd` `main.gd` instancia e liga os nós acima (`_wire_catalog`, `_wire_sound`, `_wire_mirror`, `_wire_hour`, `_wire_ending`), constrói `GiantElias` e os adereços da verdade (`_build_story_props`), e expõe `ended`/`ending_outcome`. Novos modos de captura: `notebook`, `mirror`, `clock`, `hour`, `double`, `giant`, `ending`.
- [2026-10-28] (e) ← `cp.sh` (unit + selftest + lint) Contagens ao fim da Tarefa 15: `UNIT RESULT: 675 checks, 0 failures`, `SELFTEST RESULT: 146 checks, 0 failures`; depois das correções da revisão final, 676 e 151, ambos com 0 falhas; lint "nada a reportar".
- [2026-10-28] (e) ← `faz-de-conta/README.md` A linha "É scaffolding: sem áudio, comportamento da casa ou arte final" do mapa não vale mais para áudio e comportamento: há som sintetizado e a casa reage. Segue sem arte final.
- [2026-10-28] (e) ← `faz-de-conta/scripts/hands.gd`, `dread_model.gd`, `dread.gd` Mãos e clima, sem `class_name`, por `preload`:
  - `hands.gd`: nó filho `Hands` do jogador. Monta as mãos (caixas) sob a `Camera3D`, na camada 13 (`HANDS_LAYER`), com `no_depth_test` e `render_priority` por parte. Expõe `swing()`/`struck`/`recoil()`/`reach()` e move a `SpotLight3D` para a lanterna da mão esquerda.
  - `dread_model.gd`: lógica pura, testada em `tests/test_dread_model.gd`.
  - `dread.gd`: nó `Dread`, exposto como `main.dread`. Escala as 9 luzes do grupo `HouseLight` (criadas por `main._house_light`), muda neblina e ambiente do `WorldEnvironment`, controla a `Breath`, toca o `Hum` no bus `Casa`, desenha a vinheta (`CanvasLayer` 0) e agenda rangidos e piscadas.
- [2026-10-28] (e) ← `faz-de-conta/scripts/player.gd` `_knock()` agora chama `hands.swing()` e emite `swung`. O `bater` só sai em `_land_knock()`, no sinal `struck` (fim do golpe), com `force_raycast_update()` e o alcance `KNOCK_REACH` de 1,5 m.
- [2026-10-28] (e) ← `faz-de-conta/scripts/main.gd` A câmera do espelho e a câmera final excluem a camada 13. `swung` toca `swish`; a lanterna passou para energia 1,3 e ângulo 32; o ambiente base passou para 0,3 e a neblina para 0,012. Novo modo de captura `dread`.
- [2026-10-28] (e) ← `cp.sh` Contagens depois das mãos e do clima: `UNIT RESULT: 763 checks, 0 failures` e `SELFTEST RESULT: 173 checks, 0 failures`.
- [2026-10-28] (e) ← `faz-de-conta/scripts/tour.gd` Modo de demonstração `-- --tour`, criado a pedido de Pedro para ver o jogo se mover. Segura `W` e toca `B`, `F`, `Tab`, `E` e `F9` por `Input.parse_input_event`, gira a cabeça direto e mostra legendas em pt-BR. Se ficar preso, toca `E` duas vezes e depois põe Elias no ponto. Ao terminar, devolve o controle.
- [2026-10-29] (e) ← `faz-de-conta/scripts/` Expansão "propósito e imersão", sem `class_name`, por `preload`:
  - Lógica pura (`RefCounted`, com teste): `quest_model.gd` (cinco lotes, peças, `stalkers()` por fase), `atlas.gd` (cômodos por andar com faixa de altura, `visit`, `where` em pt-BR), `stalker_model.gd` (um Gasto no grafo: só anda sem ser visto, `send_away`), `mobility_model.gd`, `score_model.gd`, `breakable.gd` (`hit()` → `crack`/`break`, `sound_for`).
  - Ambientes: `scripts/areas/passagem.gd`, `sotao.gd` (com a torre), `gaveta.gd`, `leste.gd` (Relojoaria Varela), cada um com `static func build(main)`, chamados por `main.gd`.
  - Nós: `gastos.gd` (nó `Gastos`, `main.gastos`: grafo de espreita amostrado no carregamento depois de um `physics_frame`, até 2 corpos `Mannequin` com hitbox na camada 8 e grupo `Gasto`, sinal `caught`), `pretend.gd` (`CanvasLayer` 3, `main.pretend`), `score.gd` (nó `Score`, lê `main.score_inputs()`).
  - `main.gd`: `LEVEL_SAFE`, `ROOM_TASKS`, `BREAK_TASKS`, `CATALOG_TASKS`; `_wire_story`, `_on_piece`, `_complete`, `_track_place` (no `_process`), `hug`, `score_inputs`, `_knock_on`; `quest`/`atlas` criados antes da UI; o raio do jogador usa máscara `1 | 8`; overlay `_black` na UI.
  - `notebook_ui.gd`: página dupla de lotes e plano (`open_plan`, `toggle_plan`, `plan_text`, `peek_text`); `player.gd` emite `map_requested` em `M`.
- [2026-10-29] (e) ← `cp.sh` Contagens: unit 1040/0, selftest 230/0.
- [2026-10-29] (e) ← `faz-de-conta/scripts/settings_model.gd`, `settings_ui.gd` Opções: modelo puro (padrões, faixas, `ConfigFile`, testado em `tests/test_settings_model.gd`) e folha `CanvasLayer` 20 com `PROCESS_MODE_ALWAYS`, criada em `_wire_story` como `main.settings_ui`. `Esc` (tratado só nela) pausa a árvore; aplica em `player.mouse_sensitivity`, `player.invert_y`, `player.set_base_fov`, `tonemap_exposure` do `WorldEnvironment` e volume dos buses `Master`, `Musica`, `Casa`, `Mundo`; salva em `user://opcoes.cfg` ao fechar. Com `--selftest`, `--tour` ou `--shot*`, `path` fica vazio e o arquivo não é tocado. Contagens: unit 1059/0, selftest 241/0.
- [2026-11-08 ~superseded 2026-11-08] (e) ← `Janghyang/scripts/areas/registry.gd`, `scripts/atlas.gd`, `scripts/main.gd` Registro de áreas (Tarefa 3): `registry.gd` lista as áreas por `preload` em `AREAS` (cada uma com `const DEF` e `static func build(main)`), guarda o contrato `HELPERS` (helper de `main.gd` → aridade, conferido por `tests/test_registry.gd`) e expõe `defs`, `def`, `has_area`, `rooms`, `levels`, `safe_points`, `merged(key)` e `links`. ~~`atlas.gd` passou a ter `LEGACY_ROOMS`/`LEGACY_LEVELS` e `static func rooms()`/`levels()`, que põem os cômodos de uma área registrada no lugar dos legados, sem mudar a ordem. Em `main.gd`, `LEVEL_SAFE`, `ROOM_TASKS`, `BREAK_TASKS` e `CATALOG_TASKS` viraram `var`: o mapa `_LEGACY_*` com o do registro por cima.~~ → os legados somem na Tarefa 8 (entrada abaixo). Contagens: unit 1139/0, selftest 282/0.
- [2026-11-08 ~superseded 2026-11-08] (e) ← `Janghyang/scripts/areas/passagem.gd`, `registry.gd`, `atlas.gd` Tarefa 4: a passagem é a primeira de `Registry.AREAS` e o `main._ready` constrói o registro num laço, na posição da antiga chamada. O `DEF` ganhou `safe_room` (cômodo de outra área onde fica o safe, quando a área não deixa ficar em pé). ~~`atlas.gd` tem `ROOM_ORDER` (ordem de busca: torre antes do sótão) e `LEVEL_ORDER` (ordem das abas da planta), que somem na Tarefa 8.~~ → sumiram na Tarefa 8 (entrada abaixo). Contagens: unit 1161/0, selftest 282/0.
- [2026-11-08] (e) ← `Janghyang/scripts/areas/mecanismo.gd`, `sotao.gd` Tarefa 5: a torre saiu de `sotao.gd` para `mecanismo.gd` (constantes `TOWER`, `HUB`, `LEDGE_Y`, `L3_Y`, `PLATFORM_Y`, `TOWER_TOP`; o nó `Mecanismo` agora é filho direto de `Main`, não de `Sotao`). `sotao.gd` lê `Mecanismo.TOWER` para abrir o teto. Em `AREAS`, `mecanismo` vem antes de `sotao`. O safe da torre fica no sótão (`safe_room`). Contagens: unit 1196/0, selftest 282/0.
- [2026-11-08] (e) ← `Janghyang/scripts/areas/gaveta.gd`, `tampo.gd` Tarefas 6 e 7: gaveta e tampo no registro. `tampo.gd` (maquete `item_215`) constrói a oficina gigante (antes `main._build_oficina`) e chama `leste.gd`, que fica como construtor auxiliar fora de `AREAS`. `_slab_with_holes` (9 argumentos) entrou em `HELPERS`. Contagens: unit 1285/0, selftest 282/0.
- [2026-11-08] (e) ← `Janghyang/scripts/areas/casa.gd`, `registry.gd`, `atlas.gd`, `main.gd` Tarefa 8, migração fechada. Mapa das áreas, na ordem de `Registry.AREAS` (que é a ordem de construção, de busca de cômodo e das abas da planta): `casa` (item_214; os oito cômodos da casa, os móveis, o relógio da entrada, as peças da verdade, a redoma com o `CrackedGlass` e o `ExitEdge`) → `passagem` (item_214) → `mecanismo` (torre; antes do sótão porque fica dentro dele) → `sotao` → `gaveta` → `tampo` (item_215; relojoaria, oficina dos fundos e bancada, via `leste.gd`). A casa não tem links próprios: os links valem nos dois sentidos e as outras áreas apontam para ela. `atlas.gd` lê `rooms()`/`levels()` só do registro (sumiram `LEGACY_ROOMS`, `LEGACY_LEVELS`, `ROOM_ORDER` e `LEVEL_ORDER`); na planta, a aba do mecanismo passou a vir antes da do sótão. `main.gd` lê `LEVEL_SAFE`, `ROOM_TASKS`, `BREAK_TASKS` e `CATALOG_TASKS` direto do registro e só faz preload de `registry.gd`. `_ceiling` (5), `_house_light` (6) e `_style_mat` (1) entraram em `HELPERS`. Contagens: unit 1368/0, selftest 282/0.
- [2026-11-08] (e) ← `Janghyang/scripts/maquetes/registry.gd`, `scripts/selftest.gd` Tarefa 9: pasta nova `scripts/maquetes/`, com `registry.gd` (`MAQUETES`: item 214 "a casa da rua do Porto" com casa, passagem, mecanismo, sótão e gaveta; item 215 "Relojoaria Varela" com o tampo; item 216 "a mansão das falésias", ainda sem áreas), `get_maquete(id)` e `of_area(id)`. `dome` é um `Transform3D` que leva uma caixa unitária (x e z de -0,5 a 0,5, y de 0 a 1) à redoma; a da 214 é a que `casa.gd` constrói, e as da 215 e da 216 são posições provisórias, escolha da IA, até essas redomas serem construídas. O selftest ganhou `_routes_by_links()`: para cada link de `Registry.links()`, abre o `gate` (três batidas numa quebrável, interação numa porta) e passa a cápsula agachada, 5 cm acima do piso, por `[safe] + path + [at]`. As rotas à mão continuam. Contagens: unit 1397/0, selftest 304/0.
- [2026-11-08] (e) ← `Janghyang/scripts/story/noites.gd`, `scripts/campaign_model.gd`, `scripts/quest_model.gd`, `scripts/catalog.gd`, `scripts/atlas.gd` Tarefa 10: pasta nova `scripts/story/`, com `noites.gd` (`NOITES`, as cinco noites como dados: capítulos, metas `{task, area, at}`, peças, fases, segurança, Gastos por etapa, corda dos âncoras, cliques da captura, pickups, final; `DEMO_LAST := 2`, `get_night(n)`, `last()`, que devolve 2 só com a feature `demo`). `campaign_model.gd` guarda o que passa entre noites (peças, itens de mão, atalhos, planta, catálogo, cômodos vistos, capítulos) e é o único save: `user://campanha.json`, JSON `{version, state}` com o estado por `JSON.from_native`, escrito por arquivo `.tmp` e renomeado; save ilegível vai para `*.bad.json`. `QuestModel._init(phases)` recebe as fases da noite; a fase atual é a primeira cuja última tarefa está aberta. `Catalog` e `Atlas` ganharam `to_dict()`/`from_dict()`. O `main` ainda não usa noites (Tarefa 12). Contagens: unit 1961/0, selftest 304/0.
- [2026-11-08] (e) ← `Janghyang/scripts/visit_state.gd` Tarefa 11: `VisitState._init(clock, catalog, night := {})` recebe a noite de `noites.gd`; `is_short()` é verdadeiro fora da noite final. Numa noite curta o 03:33 abre com `on_goals_met()` mais `on_ground_floor(true)` (as peças não contam); na final, ou sem noite, segue abrindo com `on_pieces_ready()`; em ambas, também pelo tempo (`MAX_PRE_HORA`). `update(dt, in_bedroom, holding)`: enquanto um Gasto segura Elias, nada começa (nem pelo limite). O 03:33 curto acaba em `SHORT_HOUR` (90 s) ou na corda, devolvendo `&"night_over"` uma vez e indo a `FIM`. Contagens: unit 1990/0, selftest 304/0.
- [2026-11-09] (e) ← `arte/`, `Janghyang/assets/`, `Janghyang/scripts/asset_loader.gd`, `Janghyang/scripts/mannequin.gd` **Primeiros assets externos: as figuras de porcelana.** {#assets-figuras}
- [2026-11-09] (e) ← `Janghyang/scripts/mannequin.gd` O manequim também anda: `walk(metros, delta)` balança pernas e braços conforme o chão percorrido (só na pose `em_pe`) e `set_stride(fase, amplitude)` trava um passo. Usam: `echo.gd`, `mirror_reflection.gd` e `gastos._show` (passada sorteada a cada salto). Ver [[decisoes#movimento]].
  - `arte/blender/figuras.py` (com `_common.py`) roda no Blender 4.5 sem janela e gera `figura_adulto`, `figura_menino` e `gasto`. `--preview DIR` renderiza vistas de conferência. O comando completo está em `arte/fontes/human-base-meshes/README.md`.
  - `arte/fontes/` guarda o bruto baixado, fora do git: o `.gitignore` da raiz ignora `arte/fontes/**/bundle.zip`, `arte/fontes/**/extraido/` e `__pycache__/`. Só o README de cada fonte é versionado.
  - `Janghyang/assets/models/*.glb` e `assets/textures/*.png` (com mipmaps) são o resultado. `assets/LICENCAS.md` tem uma linha por arquivo (spec §14.2), conferida por `tests/test_licencas.gd`.
  - `scripts/asset_loader.gd` (`RefCounted`, `instance(path)`, `texture(path)`) devolve `null` se o arquivo falta, e quem chama volta ao bloco (`tests/test_asset_loader.gd`).
  - `mannequin.gd` tem dois corpos: o modelo (`BODIES`: `adulto`, `menino`, `gasto`) ou as caixas antigas, quando o `.glb` falta. Os pivôs (`_hips`, `_torso`, `_head`, braços, pernas) ficam nas juntas do modelo, e `_sync()` leva a pose deles aos 16 ossos a cada frame visível. As poses baixas usam IK de duas juntas nas pernas. Há também `has_model()`, `bone_transform()`, `bone_position()` e `sync_pose()`. Testes em `tests/test_mannequin.gd`.
  - A encenação aceita `"body"` em cada figura (`casa.gd`, `passagem.gd`), `gastos.gd` pede o corpo `gasto` e `main.gd` ganhou os modos de captura `figuras` e `figuras_fim`.
  - Contagens: unit 2545/0, selftest 450/0.
- [2026-10-20] (i) O `selftest` exige a cena pronta e espera os tweens de 1,1 s; por isso roda em modo headless, mas não em paralelo com capturas.

## Estado do código em disco {#disco}

- [2026-09-12] (e) `handoff/` contém o kit/template original para referência ou réplica em outros repositórios.
- [2026-09-12] (e) `handoff.md` na raiz detalha a fundamentação teórica e lições aprendidas do sistema.
- [2026-10-20 ~superseded 2026-11-07] (e) ← `faz-de-conta/` O projeto está fora de qualquer repositório Git; não houve commit nem push. → Ver [[arquitetura#repo]].

## Repositório Git {#repo}

- [2026-11-07] (d) Pedro criou o repositório `https://github.com/pedropompeu/Janghyang` e pediu a integração.
- [2026-11-07] (e) ← `git log` Repositório inicializado na raiz `~/Dev/Jogo` (branch `main`), remoto `origin` apontando para o endereço acima. Commit inicial `610b252` com o protótipo inteiro (`faz-de-conta/`, `context/`, `docs/`, `fontes/`, `.superpowers/`), sem cache do Godot.
- [2026-11-07] (e) ← `.gitignore` Ignora `.godot/` (cache regenerado ao abrir o projeto) e `*.tmp`. Os arquivos `.import` são versionados, como o Godot recomenda.
- [2026-11-07] (i) Commit inicial sem linha de co-autoria, conforme a regra do projeto.
- [2026-11-07] (d) **A pasta do jogo passou de `faz-de-conta/` para `Janghyang/`** (`git mv`, ainda sem commit). `project.godot` e os textos de ajuda usam o nome Janghyang. Testes após a renomeação: selftest 241/0, unit 1059/0.
- [2026-11-07] (e) ← `Janghyang/` Caminhos citados em entradas datadas anteriores (`faz-de-conta/...`) são histórico e não foram reescritos. Os nomes dos arquivos em `docs/superpowers/` também continuam, porque são nomes de arquivo já existentes.
- [2026-10-20] (e) ← `faz-de-conta/blockout-playroom.png`, `blockout-corridor.png`, `blockout-atelier.png`, `blockout-fold.png` e `blockout-top.png` foram gerados pelo próprio projeto em 2026-10-20.
- [2026-10-27] (e) ← `faz-de-conta/blockout-atelier.png` Regerada em 2026-10-27: agora enquadra o tampo sob a redoma.
- [2026-10-20] (e) ← `faz-de-conta/scripts/selftest.gd` Os achados de circulação do blockout estão em [[achados#a-002]] e [[achados#a-003]]; a limitação da cabana em [[achados#a-001]].

## Pontos de integração {#integracoes}

- [2026-09-12] (e) Ferramentas de IA suportadas nativamente: Claude Code CLI (`CLAUDE.md`), Antigravity / Gemini CLI (`GEMINI.md` e `AGENTS.md`), Cursor (`.cursorrules`).
- [2026-11-08] (e) ← `Janghyang/scripts/main.gd`, `night_card_ui.gd`, `hour_event.gd`, `gastos.gd` Tarefa 12, o laço das noites:
  - `main.gd`: `var campaign`, `var night`, `var night_card`, `var pockets`, `_save_path`; `static func night_arg(args)` (`--night N`/`--night=N`, limitado a 1..5); `_fresh_campaign_at(n)`; `begin_night(n)`; `_tick_night(delta)` (no lugar do `visit.update` do `_process`); `_night_over()`; `end_night()`. `_complete` chama `visit.on_goals_met()` quando todas as `night.goals` fecham; `_track_place` chama `visit.on_ground_floor(lvl == Registry.HOME)`; `_home_stretch()` marca `voltar_terreo`.
  - `night_card_ui.gd` (novo, `CanvasLayer` 6): papel no estilo do caderno; `static func night_text(night, last)`, `DEMO_END`, `show_night`, `close`, `is_open`, `text`, `signal closed`. Trava o jogador e mostra o mouse.
  - `hour_event.gd`: `begin(short := false)` e `reset()` (libera os ecos). `piece.gd`: `put_away()`. `quest_model.gd`: `_init(phases, carried)`. `wind_clock_model.gd`: `reset()`. `gastos.gd`: `var night`, `on_night`, `static func night_stalkers`.
  - Contagens: unit 2039/0, selftest 324/0 (20 checks `noites:`).
- [2026-11-08] (e) ← `Janghyang/scripts/safety_model.gd`, `scripts/stalker_model.gd`, `scripts/gastos.gd`, `scripts/areas/registry.gd`, `scripts/areas/casa.gd` Tarefa 13, segurança por ponto:
  - `safety_model.gd` (novo, `RefCounted`): `ANCHOR_RADIUS := 4.0`, `static func is_safe(point, rule, world)`; `world = {level, lit, entry_wound, anchors}`.
  - `stalker_model.gd`: `update(..., safe := [], elias_safe := false)`; `next_toward`, `_farthest_from` e `_distances(goal, blocked)` não entram em ponto seguro.
  - `gastos.gd`: sem `REFUGE`; `MAX := 3`, `KEEP_CLEAR`, `PORTAL`; `entry_wound` (null segue a mola), `anchors`, `rule()`, `world_at(p)`, `lit_rooms()`, `is_safe(p)`, `safe_points()`, `static func door_center(d)`, `_door_sides`; o grafo liga cômodos pelos portais das portas e passa por cima dos pontos de `keep_clear`.
  - `registry.gd`: chave nova `keep_clear` no `DEF` (padrão `[]`); `casa.gd` põe `DoorFront`. `main.gd` não liga mais `entry_wound`.
  - Contagens: unit 2071/0, selftest 349/0 (checks `safety:`).
- [2026-11-08] (e) ← `Janghyang/scripts/hands_model.gd`, `scripts/player.gd`, `scripts/hands.gd`, `scripts/notebook_ui.gd`, `scripts/main.gd` Tarefa 14, mãos e bolsos:
  - `hands_model.gd` (novo, `RefCounted`): `LEFT_ITEMS`, `WATCH`, `left`, `pockets`, `take`, `count`, `has`, `hold`, `cycle`, `can_swing`, `use_one`, `toggle_watch`.
  - `player.gd`: `var hands_model`, sinais `left_used(item)` e `left_changed(item)`; roda do mouse, clique esquerdo e `T` (respeitam `input_locked`); `_knock` pede `can_swing()`.
  - `hands.gd`: `ITEM_COLORS`, bloco `HeldItem` na mão esquerda, `held_item()`. `notebook_ui.gd`: `POCKET_NAMES`, `static func pockets_text(pockets)`, `pockets_shown()`. `main.gd`: `hands_model` novo por noite.
  - Contagens: unit 2106/0, selftest 356/0 (checks `hands:`).
- [2026-11-08] (e) ← `Janghyang/scripts/capture_model.gd`, `scripts/capture_fx.gd`, `scripts/gastos.gd`, `scripts/main.gd`, `scripts/player.gd`, `scripts/settings_model.gd`, `scripts/settings_ui.gd`, `scripts/sfx_bank.gd` Tarefa 15, captura com fuga:
  - `capture_model.gd` (novo, `RefCounted`): `State {FREE, GRABBED, BROKE_FREE, HUG}`, `WINDOW 4.0`, `STAGGER 2.0`, `HOLD_TIME 2.5`, `grab`, `push`, `update(dt, held)`, `progress`, `is_grabbed`.
  - `capture_fx.gd` (novo, `CanvasLayer`): `start(head)`, `stop()`, `push()`, `static flicker_color(t, reduced)`, `flicker_hz`, `flicker_depth`.
  - `gastos.gd`: sinais `grabbed(i)` e `broke_free(i)`; `var capture`; `_grab`, `_tick_capture` (no topo do `_process`), `push()`, `is_grabbed()`; `caught` só sai no abraço.
  - `main.gd`: `capture_fx`, `_on_grabbed`, `_on_broke_free`; `Tab`/`M` ignorados na luta. `player.gd`: sinal `pushed`. Settings: `reduce_flash` e `hold_to_escape`. `sfx_bank.gd`: tipo `crack`.
  - Contagens: unit 2155/0, selftest 373/0 (checks `capture:`).
- [2026-11-08] (e) ← `Janghyang/scripts/compass_model.gd`, `tests/test_compass_model.gd` Tarefa 16, o modelo da bússola: statics `route(from, to, links) -> Array` (BFS nos dois sentidos), `aim(pos, area, goal, links) -> Dictionary` (`point` com `at` e `tilt`, ou `spin`), `tick_period(d)` (0,25 s a 2 m, 1,0 s a 25 m), `trembles(d)`; `TREMBLE_RADIUS` 6, `HEARD_RADIUS` 3, `TILT_STEP` 0,75. Ainda sem nó no jogo (Tarefa 17). Contagens: unit 2183/0.
- [2026-11-08] (e) ← `Janghyang/scripts/pocket_watch.gd`, `scripts/main.gd`, `scripts/hands.gd`, `scripts/gastos.gd`, `scripts/areas/casa.gd`, `scripts/catalog_data.gd`, `scripts/night_card_ui.gd` Tarefa 17, o relógio de Elias:
  - `pocket_watch.gd` (novo, `Node3D` filho de `hands.left_hand()`): sinal `ticked(at, open)` (os Gastos ouvem na Tarefa 20); `open`, `close`, `set_goal`, `lose_spring`, `new_night`, `aim_now`, `pointing`, `tick_period`; blocos `Face` e `Needle` (pivô) no `HANDS_LAYER`; o tique sai pelo `sfx` `tick`.
  - `main.gd`: `pocket_watch`, `watch_goal()` (primeira meta da noite não cumprida), carta na noite 1 e `_house_goes_dark` (só a `PlayroomLamp` fica acesa); `_complete` atualiza a meta; `_on_broke_free` gasta a corda; shot `--shot-watch` (`res://blockout-watch.png`).
  - `night_card_ui.gd`: `show_letter`, `is_letter`, sinal `letter_closed`. `catalog_data.gd`: `LETTER`. `gastos.gd`: `nearest(p)`. `hands.gd`: `left_hand()`. `casa.gd`: a primeira luz do quarto de brincar se chama `PlayroomLamp`.
  - Contagens: unit 2188/0, selftest 393/0 (checks `bussola:`).
- [2026-11-08] (e) ← `Janghyang/scripts/fog_grid.gd`, `scripts/plan_model.gd`, `scripts/plan_revealer.gd`, `scripts/notebook_ui.gd`, `scripts/main.gd`, `scripts/gastos.gd` Tarefa 18, a planta viva:
  - `fog_grid.gd` (novo, `RefCounted`): `CELL` 0,5, `reveal(p)`, `seen`, `count`, `cell_center`, `seen_cell`, `to_bytes`/`from_bytes`.
  - `plan_model.gd` (novo): `fog(level)`, `note(level, at, kind, label, time, id)`, `notes_on`, `forget_item`, `levels_drawn`, `to_dict`/`from_dict` (no `campaign.plan`).
  - `plan_revealer.gd` (novo, nó `PlanRevealer` filho do `main`): `scan()`, `reach()`, `half_width()`.
  - `notebook_ui.gd`: `plan`, `open_plan(pos, look)`, `toggle_plan(pos, look)`, `plan_sheet()`, `show_sheet(level)`; desenha névoa, anotações e seta; `plan_text()` inclui as anotações.
  - `main.gd`: `plan_model`, `plan_revealer`, `world_frozen()`; `gastos.gd` para só com `world_frozen()`.
  - Contagens: unit 2224/0, selftest 396/0 (checks `planta:`).
- [2026-11-08] (e) ← `Janghyang/scripts/light_model.gd`, `scripts/light_pickup.gd`, `scripts/main.gd`, `scripts/gastos.gd`, `scripts/story/noites.gd`, `scripts/areas/casa.gd`, `scripts/areas/passagem.gd`, `scripts/areas/sotao.gd`, `scripts/areas/mecanismo.gd` Tarefa 19, a luz escassa:
  - `light_model.gd` (novo, `RefCounted`): `BATTERY` 240, `MATCH` 20, `CANDLE` 120, `LOW` 30; `battery`, `spare`, `hands`; `drain(dt, on)` (`swapped`/`low`/`dead`), `strike()`, `burning()`, `match_left()`, `flicker(t)`; statics `pickup(id)`, `worth(p)`, `route_seconds(night)`.
  - `light_pickup.gd` (novo, `StaticBody3D`, grupo `LightPickup`): pilha, fósforos ou vela; `interact()`, `set_active(on)`, `light_up()`, `put_out()`, `burn_left()`; a vela acesa entra no grupo `CandleLight`.
  - DEFs das áreas: chave `pickups` (`{id, kind, at, n?}`); `noites.gd`: `pickups` por noite (noite 1 casa e passagem; noite 2 sótão e mecanismo).
  - `main.gd`: `light`, `_build_light_pickups()`, `_wire_light()`, `_tick_light(delta)`, `strike_match()`, `light_candle(c)`, `take_light(p)`; `MatchGlow` na mão esquerda. `gastos.gd`: `add_lamp(l)`, `lit_rooms` conta `HouseLight` e `CandleLight`.
  - Contagens: unit 2363/0, selftest 408/0 (checks `luz:`).
- [2026-11-08] (e) ← `Janghyang/scripts/noise_model.gd`, `scripts/stalker_model.gd`, `scripts/gastos.gd`, `scripts/player.gd`, `scripts/main.gd` Tarefa 20, ruído e respiração:
  - `noise_model.gd` (novo, `RefCounted`): `Level {QUIET, NORMAL, LOUD}`, `RADIUS [1.5, 5.0, 10.0]`, `NOISE_MEMORY` 10, `BREATH_MAX` 8, `BREATH_REST` 4; statics `radius(level)`, `heard(src, ear, level)`; `breath(dt, pressed)` (`gasp`), `holding`.
  - `stalker_model.gd`: `HIDE_FOUND` 3,0; `update(..., breath_held := true)`.
  - `gastos.gd`: `hear(at, level, radius := -1.0)`, `goal_of(i)` (o último ruído ouvido por Gasto, senão Elias), `_nearest_point(p)`; passa `player.breath.holding` ao modelo.
  - `player.gd`: sinais `noised(at, level)` e `gasped`; `breath`, `step()`, `step_level()`; `H` prende a respiração; a batida da vareta é LOUD.
  - `main.gd`: `_wire_noise()` (passos, batidas, ofego, corda do relógio da entrada LOUD, tique do relógio aberto QUIET a `Compass.HEARD_RADIUS`).
  - Contagens: unit 2393/0, selftest 412/0 (checks `ruido:`).
- [2026-11-08] (e) ← `Janghyang/scripts/plan_model.gd`, `scripts/player.gd`, `scripts/main.gd`, `scripts/areas/casa.gd`, `scripts/areas/passagem.gd` Tarefa 21, o giz:
  - `plan_model.gd`: `MAX_MARKS` 20; as notas `giz` de todas as folhas numa fila (`_marks`), a 21ª apaga a mais antiga.
  - `player.gd`: `CHALK_REACH` 2,0, sinal `chalked(at, normal)`, `chalk()` (G; só parede, nunca piso, teto ou Gasto).
  - `main.gd`: `chalk_mark(at, normal)` (nó `EliasChalk`, grupo `EliasChalk`, visível de olhos abertos), `_build_chalk_trails()` (nó `ChalkTrails`, setas no grupo `Chalk`), `chalk_target(id)` (pickup ou `Catalog_<id>`).
  - DEFs: chave `chalk` (`{id, points, leads_to}`): `giz_figuras`, `giz_quarto` (casa), `giz_passagem`.
  - Contagens: unit 2402/0, selftest 421/0 (checks `giz:`).
- [2026-11-08] (e) ← `Janghyang/scripts/listen_model.gd`, `scripts/player.gd`, `scripts/gastos.gd`, `scripts/main.gd`, `scripts/sfx_bank.gd` Tarefa 22, escutar pela parede:
  - `listen_model.gd`: `EAR_RANGE` 12, `SCOPE_RANGE` 25, `FLOOR_BAND` 2,5, `PERIOD` 1,5, `DUCK_DB` -18, `WALL_REACH` 0,9; `audible(gasto, ear, scope)` (ouvido: mesmo andar; estetoscópio: atravessa andares) e `beat(dt)`.
  - `player.gd`: L segurado, sinal `listen_changed(on)`, `set_listening(on)` (só liga com parede a até 0,9 m à frente, `facing_wall`), Elias parado enquanto escuta; o raio de parede (`_wall_hit`) passou a ser o mesmo do giz.
  - `gastos.gd`: `positions()` (as cabeças dos Gastos de pé).
  - `main.gd`: `listen`, `_on_listen` (bus `Casa` cai 18 dB e volta), `_tick_listen(dt)` (estalo `porcelain_muffled` no bus `Mundo` onde cada Gasto audível está; sinal `listened(at)`).
  - Contagens: unit 2419/0, selftest 429/0 (checks `escuta:`).
- [2026-11-08] (e) ← `Janghyang/scripts/staging_model.gd`, `scripts/chapter_model.gd`, `scripts/main.gd`, `scripts/notebook_ui.gd`, `scripts/night_card_ui.gd`, `scripts/story/noites.gd`, `scripts/areas/casa.gd`, `scripts/areas/passagem.gd` Tarefa 23, capítulos:
  - `staging_model.gd`: `UNSEEN` 1,5; `update(dt, seen)` avança uma pose a cada 1,5 s sem ser vista (olhar zera a conta); `done()`.
  - `chapter_model.gd`: `clues`, `hypothesis` (3 frases), `right`, `on_cataloged(item)`, `update(dt, seen)` (só com o capítulo aberto), `ready_to_write()`, `choose(i)` (a errada fica riscada), `page()`.
  - DEFs: chave `staging` (`{id, figures: [{style, scale, poses}]}`) na casa (pai e menino, termina no painel) e na passagem (menino, termina na coroa); `registry.gd` com `staging` vazio por padrão.
  - `main.gd`: `chapters`, `_build_staging()` (nós `Staging/Staging_<id>/Figure_<k>`, manequins sem colisão), `_start_chapters()`, `_tick_staging(dt)`, `watch_goal()` aponta para a encenação aberta (`task` `encenacao`), `chapter_pages()` vai no carry do fim da noite.
  - `notebook_ui.gd`: página da hipótese (`_hypothesis_page`, `choose_hypothesis`); `night_card_ui.gd`: o cartão traz a frase escolhida.
  - Contagens: unit 2459/0, selftest 442/0 (checks `capitulo:`).
- [2026-11-08] (e) ← `Janghyang/scripts/scare_director.gd`, `scripts/dread.gd`, `scripts/main.gd` Tarefa 24, o diretor de sustos:
  - `scare_director.gd`: `STRONG_GAP` 60, `WEAK_GAP` 20, `QUIET_BEFORE` 8, `STRONG_TENSION` 0,6, `PEAK` 0,5, `MAX_DB` 0; `KINDS` (os sete tipos da spec §13); `update(dt, loud_now)`, `request(kind, strong, tension)`, `set_hour(active)`, `new_night()`.
  - `dread.gd`: `director`; a cada frame segue a hora (`hour_event.is_active()`) e o barulho (`loud_now()`: captura ou fôlego acima de 0,5); a lâmpada (`lampada`, fraco) e a lanterna (`lanterna_pisca`, forte) pedem licença; o rangido continua ambiente.
  - `main.gd`: `dread.director.new_night()` no começo de cada noite.
  - Contagens: unit 2486/0, selftest 446/0 (checks `sustos:`).
- [2026-11-08] (e) ← `Janghyang/scripts/lost_model.gd`, `scripts/playtest_log.gd`, `scripts/main.gd`, `context/discussoes/playtest-1.md` Tarefa 25, registro do playtest:
  - `lost_model.gd`: `LOST_AFTER` 180, `PROGRESS` 2; `update(dt, goal_distance, goal_id)` avisa uma vez quando passam 180 s na mesma meta sem chegar 2 m mais perto do melhor ponto; `is_lost()`.
  - `playtest_log.gd`: com `--playtest`, uma linha CSV a cada 5 s em `user://playtest/<data-hora>.csv` (`t, noite, area, comodo, meta, dist, relogio_aberto, caderno_aberto, capturas, perdido`); `header()`, `row(d)`, `sample()`, `start(path)`, `stop()`.
  - `main.gd`: `grabs` (capturas da sessão) e `playtest_log` (nó `PlaytestLog`, só com `--playtest`).
  - O export Linux (`build/linux/Janghyang`, fora do git) roda o `--selftest`.
  - Contagens: unit 2502/0, selftest 449/0 (checks `playtest:`).
- [2026-11-09] (e) ← `Janghyang/tests/bot_noite1.gd`, `scripts/staging_model.gd`, `scripts/main.gd` Bot da noite 1 e guarda da encenação:
  - `tests/bot_noite1.gd` (`SceneTree`, fora do `run_unit.gd`, que só carrega `test_*.gd`): joga a noite 1 da carta ao cartão pelas teclas de verdade (W, C, Q, E, B, T e clique preso), sem teleporte e sem `main._complete`. Anda por `AStarGrid2D` de 0,2 m (chão por raio, cápsula de 0,32 m), imprime uma linha `BOT` por marco e termina em `BOT RESULT ok|fail`. Tira o próprio CSV de `user://playtest/` (para `--bot-out=DIR`, padrão `user://bot`) e, com janela e `--bot-shots=DIR`, salva o que Elias vê em cada marco. Comando: `godot --headless --path . --fixed-fps 60 -s res://tests/bot_noite1.gd -- --playtest --night=1 [--bot-out=DIR]` (uns 4 s reais; com janela, `--audio-driver Dummy`, uns 80 s).
  - `staging_model.gd`: `CLEAR` 0,6 e `static clear_of(spots, at)`; `main._staging_clear(id, k)` diz se a pose `k` põe figura a menos de 0,6 m de Elias, e `_tick_staging` trata isso como "visto" ([[achados#a-031]]).
  - Contagens: unit 2616/0, selftest 454/0; binários reexportados, selftest no binário 454/0.
- [2026-11-09] (e) ← `Janghyang/scripts/main.gd`, `scripts/selftest.gd`, `tests/bot_noite1.gd` O relógio na volta ([[decisoes#relogio-volta]]): `main.HOME_TASKS` (`voltar_terreo`, `dar_corda`) e `_home_goal()`, que `watch_goal()` devolve quando as metas da noite acabam. A meta é o `EntryClock` na área `Registry.HOME` e só vale se a tarefa está nas fases da noite. O bot falha se o relógio não apontar depois da coroa e no térreo. Contagens: unit 2616/0, selftest 457/0; binários refeitos, selftest no binário 457/0.
- [2026-11-11] (e) ← `Janghyang/scripts/setpieces/`, `scripts/areas/casa.gd`, `scripts/main.gd`, `scripts/foldable.gd`, `scripts/catalog.gd`, `scripts/catalog_data.gd`, `scripts/house_mirror.gd`, `scripts/story/noites.gd` Noite 1, Tarefas 6 e 7, as peças de cena:
  - Pasta `scripts/setpieces/`: uma peça por arquivo, montada por `main._build_setpieces()` a partir de `DEF.setpieces` (`{id, script, at?}`), nó `Setpiece_<id>` no grupo `Setpiece`, com `on_night(night)`; fora das noites que a listam, a peça fica no estado resolvido. Peças: `luz_de_fora.gd` (Tarefa 6), `vitrine.gd` e `chave_vitrine.gd` (Tarefa 7).
  - A sala das figuras passou de `Rect2(10.5, 7.0, 2.8, 2.1)` para `Rect2(10.5, 5.6, 4.9, 3.5)`: some a parede x 13,3 e a parede z 7,0; parede leste nova em x 15,4. Banco de 4,2 m na parede norte (`casa._build_bench`, chave nova `DEF.bench = {seats: 7 × Vector3, face}`).
  - Armário de vidro trancado em (15,1; 0; 8,2), porta `CabinetDoor` (`foldable.gd`, que ganhou `snap(at_b)`); a casinha saiu do quarto de brincar para a prateleira dele. Item novo `vitrine`; `casinha` ganhou o portão `vitrine_aberta`; `DEF.catalog` ganhou `casinha → cat_casinha`.
  - A chave fica meio debaixo da almofada da cabana (nota `chave_vitrine` em `CatalogData.NOTES`, flag de noite `chave_vitrine`); `catalog.note()` não cola página vazia.
  - Giz: `giz_figuras` deu lugar a `giz_vitrine` (corredor da frente → cabana, até a chave). `main.chalk_target` também resolve peça de cena pelo `at` da DEF. Batida da sala das figuras em `house_mirror.KNOCK_POINTS` foi para (15,28; 1,3; 7,0).
  - Contagens: unit 2944/0, selftest 475/0.
- [2026-11-11] (e) ← `Janghyang/scripts/wax_model.gd`, `scripts/setpieces/desenho_cera.gd`, `scripts/areas/casa.gd`, `scripts/main.gd`, `scripts/catalog_data.gd`, `scripts/story/noites.gd` Noite 1, Tarefa 8, o desenho de cera:
  - `wax_model.gd`: `REVEAL` 2,5 m; `shows(flames, at)`; `refill_due(matches, flame_near, cataloged, box_active, box_seen)`.
  - `desenho_cera.gd` (peça de cena): a cada quadro liga `DrawingWax.visible` e a flag de catálogo `chama_no_desenho` (portão de `ITEMS.desenho`); chamas = o fósforo na mão enquanto `light.burning()` e toda `CandleLight` acesa além da `MatchGlow`. Reativa o pickup `fosforo_cabeceira` com `n = 1` quando `refill_due`. Fora da noite 1, cera sempre à vista.
  - O desenho saiu da parede do painel (6,7; 1,6; 0) para a parede norte do quarto em x 14,05, com mesa de cabeceira, a caixa `fosforo_cabeceira` (3 fósforos) e um toco de vela. Material novo `main.mat_wax_lines`.
  - Contagens: unit 2974/0, selftest 480/0.
