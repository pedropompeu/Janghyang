# Janghyang — slice Godot 4.7

## O slice em 6 linhas

1. Elias, catalogador, entra numa maquete de casa sob uma redoma, em cima da bancada de um relojoeiro.
2. Ele cataloga o que encontra (`Q`) e dá corda ao relógio da entrada; a casa imita, longe dele, os gestos que ele faz.
3. Para o 03:33 chegar, ele junta as quatro peças do relógio de bolso do menino: a coroa (passagem atrás do desenho), os ponteiros (alto da torre do sótão), o mostrador (gaveta sob a bancada) e a caixa (oficina da Relojoaria Varela). Lá fora da casa, os Gastos — manequins de porcelana — o seguem.
4. Às 03:33 o relógio para, a casa devolve os trajetos dele como ecos, três coisas saem das frestas e um duplo escreve no caderno dele.
5. Depois do 03:33 aparece a verdade sobre Inácio e, pela porta da rua, o corpo gigante de Elias curvado sobre a bancada.
6. Ele sai pela beira do tampo; conforme deu corda ou deixou parar, algo dele fica na maquete — e a última entrada do caderno diz o quê.

Não há combate, dano, cronômetro visível, HUD de objetivo nem game over. Os
objetivos moram no caderno (`M`, página dos lotes). A porta da rua está sempre
aberta; sair por ela **não** encerra o jogo. Só a beira do tampo encerra.

## A história em cinco lotes

| Lote | Onde | O que fazer | Gastos |
|---|---|---|---|
| I. A casa da rua do Porto | casa | catalogar o relógio e o desenho; quebrar o painel oco sob o desenho (`B`); pegar a coroa | nenhum |
| II. O sótão | passagem → escada → sótão → torre | subir, entrar no mecanismo, pegar os ponteiros lá no alto | 1 |
| III. A gaveta | alçapão no piso do quarto → gaveta | quebrar o alçapão, descer, pegar o mostrador | 2 |
| IV. A relojoaria | vidro rachado da redoma → bancada → Relojoaria Varela | quebrar a redoma, chegar à loja, pegar a caixa na oficina | 2 |
| V. 03:33 | casa | voltar com as quatro peças; o relógio chega ao 03:33 (ou depois de 60 min) | nenhum |

**Os Gastos.** O térreo da casa é refúgio: nenhum Gasto entra. Fora dele, eles
só se movem quando ninguém olha, um ponto de espreita mais perto de Elias a cada
vez, nunca para um ponto que ele vê. Olhados, congelam; olhados por 3,5 s com
luz (lanterna ou lâmpada), se desfazem e voltam bem mais tarde, longe. Um golpe
de vareta faz o mesmo na hora. Agachado num esconderijo, Elias os despista.
De olhos fechados (`V`) ou no escuro eles somem da vista — e andam quatro vezes
mais rápido. Se um deles alcança
Elias, não há morte: tudo escurece, ele acorda caído na entrada daquele andar e
o duplo escreve no caderno onde ele foi segurado.

**Fazer de conta.** Segurando `V` (ou o botão direito), Elias fecha os olhos e a
casa volta como era, em sépia: aparecem o giz do menino — setas, portas
desenhadas, marcas de altura — que apontam as passagens.

## Requisitos

- Godot **4.7.2.stable** (ou 4.7.x compatível), renderer GL Compatibility.
- Rodar a partir da pasta `Janghyang/`.

## Rodar

```bash
cd Janghyang
godot --path .                 # jogar
godot --path . -- --labels     # jogar com as labels de leitura do blockout
godot --path . -- --tour       # demonstração: Elias anda sozinho, bate, quebra o painel, faz de conta, abre o plano, F9
```

## Controles

| Tecla | Ação |
|---|---|
| `W A S D` | mover |
| mouse | olhar |
| `E` | interagir com a mão esquerda: dobra, porta, bola, caixa de música, boneco, relógio (dar corda) |
| `Q` | catalogar o que está na mira |
| `Tab` | abrir/fechar o caderno |
| `M` | caderno aberto nos lotes (tarefas) e no plano dos andares visitados |
| `V` / botão direito (segurar) | fazer de conta: olhos fechados, a casa como era, o giz do menino |
| `Shift` | correr |
| `Espaço` | pular |
| `C` | agachar/levantar (a passagem só se atravessa agachado) |
| `B` | golpe com a vareta de tília; bate na superfície à frente se ela estiver a até 1,5 m. Painel oco, alçapão, vidro e xícaras racham e quebram em três golpes; um Gasto quebra num. Golpe no ar só faz o zunido; `B` no meio do golpe é ignorado |
| `F` | ligar/desligar a lanterna (na mão esquerda; o feixe sai dela) |
| `R` | reiniciar a cena (funciona também depois do final) |
| `Esc` | opções: pausa o jogo e abre a folha de opções (de novo `Esc` fecha) |
| `F9` | **só em build de debug:** deixa o relógio acabar agora, para chegar ao 03:33 |

## Opções

`Esc` pausa e abre uma folha no papel do caderno. Cada mudança vale na hora; ao
fechar, tudo fica salvo em `user://opcoes.cfg` (no Linux,
`~/.local/share/godot/app_userdata/<projeto>/opcoes.cfg`) e volta na próxima vez.

| Opção | Faixa | Padrão |
|---|---|---|
| Sensibilidade do mouse | 0,3× a 2,7× | 1,0× |
| Inverter o eixo vertical | sim/não | não |
| Campo de visão | 60° a 90° | 70° |
| Brilho (exposição) | 60% a 180% | 100% |
| Volume geral / Música / Sons da casa e do mundo | 0% a 100% | 100% |
| Tela cheia | sim/não | não |

A folha também tem **Padrões**, **Reiniciar** e **Sair do jogo**. Selftest, tour
e capturas não leem nem gravam esse arquivo.

## Verificação automática

```bash
cd Janghyang
timeout 60  godot --headless --path . -s res://tests/run_unit.gd   # unit: modelos puros
timeout 150 godot --headless --path . -- --selftest               # cena: colisão, laço, 03:33, final
cd .. && python lint.py                                             # integridade de context/
```

- O **unit** roda todo `test_*` de `tests/test_*.gd` sobre os modelos `RefCounted`
  (relógio, visita, catálogo, gravador, espelho, ecos, frestas, duplo, final,
  lotes, plano, Gastos, mobilidade, trilha, opções). Hoje: 1059 checks.
- O **selftest** monta a cena real e confere estados iniciais, portas, o laço com
  uma cápsula do tamanho do jogador, as dobras, a cabana, o catálogo, o 03:33
  (ecos, coisas das frestas, duplo), as provas sobre Inácio, a saída e o que fica
  na maquete; e a expansão: quebráveis, pontos de espreita de cada andar, peça →
  lote → fase, Gastos aparecendo fora da vista, abraço e volta ao ponto seguro,
  fazer de conta, profundidade da trilha, a página do plano e as opções. Hoje: 241 checks.
  Os dois harnesses contam erro de script como falha.
- Nenhum dos dois substitui o playtest: não avaliam ritmo, medo, som nem leitura
  da luz.

## O clima da casa

A tensão (0 a 1) acompanha a visita. Sobe enquanto o relógio corre, chega ao pico
no 03:33, continua alta depois dele e solta quando Elias sai. Com ela:

- as lâmpadas da casa baixam (nunca apagam);
- a neblina engrossa e a luz ambiente cai;
- um zumbido grave e a respiração de Elias sobem, sempre baixos;
- as bordas da tela escurecem, com um grão leve;
- as mãos tremem um pouco.

Rangidos vêm de cômodos a pelo menos 4 m. A partir de 0,3 de tensão, a lâmpada
mais próxima falha às vezes; perto do pico, a lanterna também. Não há susto,
perseguição nem som alto: o medo vem do ambiente.

## Telas de revisão

```bash
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-<modo>
```

Modos: `playroom`, `atelier`, `corridor`, `fold`, `notebook`, `mirror`, `clock`,
`top`, `hour`, `double`, `giant`, `ending`, `dread` (o corredor com a casa
perto do 03:33), `leste` (a bancada a leste da redoma), `shop` (fachada da
Relojoaria Varela), `dome` (o vidro rachado visto de fora), `plano` (o caderno
nos lotes e no plano), `gasto` (um Gasto na gaveta, sob a lanterna), `opcoes`
(a folha de opções). Cada um salva `blockout-<modo>.png`
na raiz do projeto e fecha o Godot.

## Caminho sugerido para o playtest

1. Comece na entrada; dê corda ao relógio e catalogue o que achar.
2. Visite o quarto de brincar, dobre F1 e agache na cabana (`C`). Feche os olhos
   (`V`) diante do desenho e quebre o painel oco (`B`). Agache e ache a coroa.
3. Suba pela escada no fim da passagem; o primeiro Gasto vem atrás. Na torre,
   ache os ponteiros. Depois o alçapão do quarto e a gaveta; depois o vidro
   rachado da redoma, a bancada e a Relojoaria Varela. Use `M` para ver o que falta.
4. Faça o laço pelo corredor e pelo quarto; dobre F2/F4, role a bola, bata (`B`).
   Olhe o espelho do quarto.
5. Com as quatro peças, volte para casa e espere o 03:33 (ou `F9` em debug). Reconheça seus trajetos nos ecos.
6. Depois, leia o caderno (`Tab`), ache a página da cabana e olhe pela porta da rua.
7. Saia pela beira do tampo de três jeitos: cedo; sem dar corda depois do 03:33;
   dando corda depois do 03:33.

## Estrutura

```
Janghyang/
├── project.godot, main.tscn
├── scripts/
│   ├── main.gd                # constrói casa, tampo, oficina, móveis, UI; liga tudo
│   ├── player.gd              # primeira pessoa, verbos, agachar, correr, pular, escadas, lanterna
│   ├── areas/                 # passagem, sotao (e torre), gaveta, leste (Relojoaria Varela)
│   ├── quest_model.gd         # (lógica) os cinco lotes e as peças
│   ├── atlas.gd               # (lógica) cômodos por andar, o que Elias já viu
│   ├── stalker_model.gd       # (lógica) um Gasto: onde espreita, quando chega
│   ├── gastos.gd              # os Gastos: grafo de espreita, corpos, abraço
│   ├── pretend.gd             # fazer de conta: pálpebras, sépia, giz
│   ├── score_model.gd, score.gd  # trilha procedural por profundidade e ameaça
│   ├── mobility_model.gd, ladder.gd, breakable.gd, piece.gd, turning_gear.gd
│   ├── hands.gd               # mãos de Elias: vareta (B), lanterna, alcance (E)
│   ├── dread_model.gd         # (lógica) o humor da casa ao longo da visita
│   ├── dread.gd               # luz, neblina, zumbido, respiração, rangidos, vinheta
│   ├── foldable.gd            # dobras e portas
│   ├── ball.gd, music_box.gd, doll.gd, figure.gd, entry_clock.gd
│   ├── wind_clock_model.gd    # (lógica) corda e 03:33
│   ├── visit_state.gd         # (lógica) atos da visita e desfecho
│   ├── catalog_data.gd, catalog.gd, catalog_target.gd
│   ├── notebook_ui.gd         # caderno (Tab) e página dos lotes + plano (M)
│   ├── settings_model.gd      # (lógica) opções: faixas, padrões, arquivo
│   ├── settings_ui.gd         # folha de opções (Esc), pausa, aplica e salva
│   ├── sfx_bank.gd            # som sintetizado, sem assets
│   ├── echo_recorder.gd, echo.gd, mannequin.gd
│   ├── mirror_brain.gd, house_mirror.gd, mirror_reflection.gd
│   ├── hour_event.gd, crack_placement.gd, crack_thing.gd, double_writer.gd
│   ├── ending_model.gd, ending.gd
│   ├── tour.gd                # demonstração automática (--tour)
│   └── selftest.gd
├── tests/                     # run_unit.gd + test_*.gd
└── blockout-*.png
```

Scripts de lógica são `RefCounted` puros, sem `class_name`, carregados por
`preload` e testados no unit; os nós da cena só leem e escrevem neles.

O design está em `../docs/superpowers/specs/2026-10-27-faz-de-conta-relojoeiro-design.md`
(expansão: `../docs/superpowers/specs/2026-10-28-faz-de-conta-expansao-design.md`)
e o plano em `../docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md`.
