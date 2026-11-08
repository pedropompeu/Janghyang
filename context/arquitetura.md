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
- [2026-10-20] (e) ← `faz-de-conta/` O blockout não usa assets externos: geometria, materiais, luz e UI são gerados por código GDScript.
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
- [2026-11-08] (e) ← `Janghyang/scripts/areas/registry.gd`, `scripts/atlas.gd`, `scripts/main.gd` Registro de áreas (Tarefa 3): `registry.gd` lista as áreas por `preload` em `AREAS` (cada uma com `const DEF` e `static func build(main)`), guarda o contrato `HELPERS` (helper de `main.gd` → aridade, conferido por `tests/test_registry.gd`) e expõe `defs`, `def`, `has_area`, `rooms`, `levels`, `safe_points`, `merged(key)` e `links`. `atlas.gd` passou a ter `LEGACY_ROOMS`/`LEGACY_LEVELS` e `static func rooms()`/`levels()`, que põem os cômodos de uma área registrada no lugar dos legados, sem mudar a ordem. Em `main.gd`, `LEVEL_SAFE`, `ROOM_TASKS`, `BREAK_TASKS` e `CATALOG_TASKS` viraram `var`: o mapa `_LEGACY_*` com o do registro por cima. Contagens: unit 1139/0, selftest 282/0.
- [2026-11-08] (e) ← `Janghyang/scripts/areas/passagem.gd`, `registry.gd`, `atlas.gd` Tarefa 4: a passagem é a primeira de `Registry.AREAS` e o `main._ready` constrói o registro num laço, na posição da antiga chamada. O `DEF` ganhou `safe_room` (cômodo de outra área onde fica o safe, quando a área não deixa ficar em pé). `atlas.gd` tem `ROOM_ORDER` (ordem de busca: torre antes do sótão) e `LEVEL_ORDER` (ordem das abas da planta), que somem na Tarefa 8. Contagens: unit 1161/0, selftest 282/0.
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
