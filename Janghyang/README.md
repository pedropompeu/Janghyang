# Janghyang — demo em construção (Godot 4.7)

Elias, catalogador, entra numa maquete de casa sob uma redoma, na bancada de um
relojoeiro morto, Inácio. O jogo se divide em **noites**: cada noite é uma
sessão em que Elias dá corda na maquete, acorda dentro da casa, joga os
capítulos da noite e termina num 03:33. O que ele leva de uma noite para outra
(peças, páginas do caderno, hipóteses) fica salvo na campanha.

**Estado em 2026-11-08:** a noite 1 está jogável **em blocos** (sem assets
finais) e pronta para o primeiro playtest humano. A noite 2 tem os capítulos 3 e 4
em rascunho, e as noites 3 a 5 são rascunhos que mantêm o fluxo e o final
testáveis. A demo pública termina depois da noite 2. O que falta está em
[`../context/historico.md`](../context/historico.md) (fila numerada no fim) e no
plano `../docs/superpowers/plans/2026-11-08-janghyang-demo.md`.

Não há HUD, minimapa, marcador de objetivo nem game over. Quem guia é o
**relógio de bolso** de Elias, que aponta para a meta da noite, e o **caderno**.

## Uma noite

1. Elias acorda na casa. O relógio da entrada marca o tempo até o 03:33.
2. Cada capítulo tem **pistas** para catalogar (`Q`). Com todas, a **encenação**
   abre: figuras de manequim refazem uma cena e só se mexem quando ninguém está
   olhando. Quando a cena termina, o caderno ganha uma página com **três
   hipóteses**. A errada fica riscada, e a certa fica escrita.
3. A recompensa do capítulo (uma passagem, uma peça do relógio do menino) leva
   adiante. Depois da peça, os **Gastos** (manequins de porcelana) aparecem fora do
   refúgio. Eles só andam quando ninguém olha.
4. Se um Gasto alcança Elias, há uma **luta**: cliques rápidos (10 em 4 s na
   noite 1) para se soltar. Perder é um abraço: tudo escurece e ele acorda no
   ponto seguro. Ninguém morre.
5. De volta ao térreo, Elias dá corda e vem o 03:33 curto. O cartão da noite
   mostra o que ele achou e a hipótese que escreveu.

**A noite 1:** capítulo 1, *A casa da rua do Porto* (pistas: o desenho, o relógio
da entrada e a casinha; recompensa: achar a passagem). Capítulo 2, *O menino que
escutava* (pistas: a caixa de música e a bola; recompensa: a coroa). Um Gasto
depois da coroa. A casa toda é refúgio.

## Requisitos

- Godot **4.7.2.stable**, renderer GL Compatibility.
- Rodar a partir da pasta `Janghyang/`.

## Rodar

```bash
cd Janghyang
godot --path .                         # jogar (continua a campanha salva em user://campanha.json)
godot --path . -- --night=2            # começa uma campanha nova na noite 2 (também: --night 2)
godot --path . -- --playtest           # joga gravando o CSV do playtest (ver abaixo)
godot --path . -- --labels             # com as labels de leitura do blockout
godot --path . -- --tour               # demonstração: Elias anda sozinho
```

**Binário Linux** (fora do git, em `build/`):

```bash
godot --headless --path . --export-release "Linux" build/linux/Janghyang
build/linux/Janghyang -- --playtest
```

## Controles

| Tecla | Ação |
|---|---|
| `W A S D` / mouse | mover / olhar |
| `Shift` | correr (cansa: depois de uma corrida a respiração pesa e faz barulho) |
| `C` ou `Ctrl` | agachar/levantar; agachado num esconderijo, os Gastos perdem Elias |
| `Espaço` | pular |
| `E` | interagir: portas, dobras, bola, caixa de música, boneco, dar corda |
| `Q` | catalogar o que está na mira |
| `T` | abrir/fechar o relógio de bolso (a bússola, na mão esquerda) |
| roda do mouse | trocar o item da mão esquerda (relógio, vareta, espelho, fósforo, lupa, estetoscópio, brinquedo, conforme Elias tem) |
| botão esquerdo | usar o item da mão esquerda; numa luta, empurrar o Gasto |
| `V` / botão direito (segurar) | fazer de conta: olhos fechados, a casa como era, o giz do menino |
| `G` | riscar uma marca de giz na parede (até 20 aparecem na planta) |
| `L` (segurar, de frente para a parede) | escutar: a casa abafa e cada Gasto audível estala onde está; com o estetoscópio, ouve através dos andares |
| `H` (segurar) | prender a respiração; segurar demais acaba num arquejo alto |
| `B` | golpe com a vareta (racha painel oco, alçapão, vidro; quebra um Gasto) |
| `F` | lanterna (gasta pilha) |
| `Tab` / `M` | caderno / caderno na planta e nos capítulos |
| `R` | reiniciar a cena |
| `Esc` | opções (pausa) |
| `F9` | **só em debug:** o relógio acaba agora |

## Opções

`Esc` pausa e abre uma folha no papel do caderno. Cada mudança vale na hora, e ao
fechar tudo é salvo em `user://opcoes.cfg`.

| Opção | Faixa | Padrão |
|---|---|---|
| Sensibilidade do mouse | 0,3× a 2,7× | 1,0× |
| Inverter o eixo vertical | sim/não | não |
| Campo de visão | 60° a 90° | 70° |
| Brilho (exposição) | 60% a 180% | 100% |
| Volume geral / Música / Sons da casa e do mundo | 0% a 100% | 100% |
| Tela cheia | sim/não | não |
| Reduzir piscadas (a luta pisca a 1 Hz e com metade da força) | sim/não | não |
| Segurar para se soltar (em vez de clicar) | sim/não | não |

Selftest, tour e capturas não leem nem gravam esse arquivo.

## O clima e os sustos

A tensão (0 a 1) acompanha a noite e sobe até o 03:33. Com ela, as lâmpadas
baixam, a neblina engrossa, o zumbido e a respiração sobem, as bordas da tela
escurecem e as mãos tremem. Os rangidos vêm de cômodos a pelo menos 4 m.

Os **sustos** pedem licença a um diretor (`scare_director.gd`): no máximo um
forte por minuto, pelo menos 20 s entre os fracos, 8 s de silêncio antes de
qualquer um, e nenhum no 03:33. O mesmo tipo de susto forte só acontece uma vez
por noite. **Não há estouro de volume** (é a decisão D10, ainda aberta): nenhum
som passa do pico do banco.

## Playtest

O roteiro está em [`../context/discussoes/playtest-1.md`](../context/discussoes/playtest-1.md).
Com `--playtest`, o jogo grava uma linha a cada 5 s em `user://playtest/<data-hora>.csv`
(no Linux, `~/.local/share/godot/app_userdata/Janghyang — blockout/playtest/`):

`t, noite, area, comodo, meta, dist, relogio_aberto, caderno_aberto, capturas, perdido`

`perdido` vira 1 depois de 180 s na mesma meta sem chegar 2 m mais perto.

## Verificação automática

```bash
cd Janghyang
timeout 60  godot --headless --path . -s res://tests/run_unit.gd   # unit: modelos puros
timeout 500 godot --headless --path . -- --selftest               # cena real, todas as noites
cd .. && python3 lint.py                                            # integridade de context/
```

- **Unit:** roda todo `test_*` de `tests/test_*.gd` sobre os modelos `RefCounted`.
  Hoje são 2502 checks.
- **Selftest:** monta a cena real e confere a casa, o laço, as noites, os
  capítulos e as encenações, a bússola, a captura, a luz, o giz, a escuta, os
  sustos, o 03:33, o final e o registro do playtest. Hoje são 449 checks, que
  também passam no binário Linux exportado.
- Os dois contam erro de script como falha. Nenhum substitui o playtest humano.

## Telas de revisão

```bash
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-<modo>
```

Modos: `playroom`, `atelier`, `corridor`, `fold`, `notebook`, `mirror`, `clock`,
`top`, `hour`, `double`, `giant`, `ending`, `dread`, `leste`, `shop`, `dome`,
`plano`, `gasto`, `opcoes`, `watch`. Cada um salva `blockout-<modo>.png` na raiz
do projeto e fecha o Godot.

## Estrutura

```
Janghyang/
├── project.godot, main.tscn, export_presets.cfg
├── scripts/
│   ├── main.gd                 # monta a cena, liga tudo, começa e termina as noites
│   ├── story/noites.gd         # (dados) as cinco noites: capítulos, metas, peças, Gastos, luz
│   ├── areas/                  # registro de áreas: casa, passagem, sotao, mecanismo, gaveta, tampo, leste
│   ├── maquetes/registry.gd    # (dados) as maquetes
│   ├── campaign_model.gd       # (lógica) o que passa de uma noite para outra; save
│   ├── chapter_model.gd, staging_model.gd   # capítulos, pistas, encenação, hipóteses
│   ├── compass_model.gd, pocket_watch.gd    # o relógio-bússola
│   ├── capture_model.gd, capture_fx.gd      # a luta com o Gasto
│   ├── light_model.gd, light_pickup.gd      # luz escassa: pilhas, fósforos, velas
│   ├── noise_model.gd, listen_model.gd      # barulho, respiração, escutar pela parede
│   ├── fog_grid.gd, plan_model.gd, plan_revealer.gd   # a planta com névoa
│   ├── scare_director.gd, dread_model.gd, dread.gd    # tensão e sustos
│   ├── safety_model.gd         # refúgio por noite
│   ├── lost_model.gd, playtest_log.gd       # registro do playtest (--playtest)
│   ├── player.gd, hands.gd, hands_model.gd  # primeira pessoa, mãos, itens da esquerda
│   ├── gastos.gd, stalker_model.gd, mannequin.gd
│   ├── quest_model.gd, atlas.gd, catalog*.gd, notebook_ui.gd, night_card_ui.gd
│   ├── hour_event.gd, echo*.gd, crack_*.gd, double_writer.gd, ending*.gd
│   ├── settings_model.gd, settings_ui.gd, sfx_bank.gd (som sintetizado)
│   ├── tour.gd, selftest.gd
│   └── … (dobras, espelhos, peças, escadas, trilha)
├── tests/                      # run_unit.gd + test_*.gd
└── blockout-*.png
```

Scripts de lógica são `RefCounted` puros, sem `class_name`, carregados por
`preload` e testados no unit. Os nós da cena só leem e escrevem neles. Os arquivos
`.uid` e `.import` do Godot são versionados.

**Documentos:**
- direção: `../docs/superpowers/specs/2026-11-08-janghyang-direcao-design.md`;
- plano da demo: `../docs/superpowers/plans/2026-11-08-janghyang-demo.md`;
- memória do projeto: `../context/index.md`.
