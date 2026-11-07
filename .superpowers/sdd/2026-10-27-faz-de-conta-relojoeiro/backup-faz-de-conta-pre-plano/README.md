# FAZ DE CONTA — blockout Godot 4.7

Blockout jogável do slice de **FAZ DE CONTA**: um horror doméstico contemplativo
dentro de uma maquete arquitetônica viva. A casa não quer matar o jogador; quer
que ele fique. A porta da rua está aberta desde o primeiro minuto.

Este projeto é ** scaffolding de teste**, não a arte final. A geometria é feita de
primitivas, as labels e o HUD são andaimes de leitura e não há áudio.

## Requisitos

- Godot **4.7.2.stable** (ou 4.7.x compatível).
- Rodar a partir da pasta `faz-de-conta/`.

## Rodar

```bash
cd faz-de-conta
godot --path .
```

Ou abra `project.godot` no editor do Godot. A cena principal é `main.tscn`, que
instancia `scripts/main.gd`.

## Controles

| Tecla | Ação |
|---|---|
| `W A S D` | mover |
| mouse | olhar |
| `E` | interagir com dobra, porta, bola, caixa de música e boneco |
| `F` | ligar/desligar a lanterna |
| `R` | reiniciar a cena |
| `ESC` | liberar o mouse |
| clique | recapturar o mouse |

Não há combate, dano, cronômetro nem game over. Sair pela porta da rua encerra o
slice; a casa não tranca a porta.

## O que existe no blockout

- **Primeira pessoa** em escala de caminhada, olho a 1,62 m.
- **Quarto de brincar** com mesa, blocos, bola, prateleira, desenho, casinha de
  brinquedo e a parede oeste dobrável **F1**.
- **Corredor** com a porta deitada **F3**, os painéis **F2** e **F4** e o laço
  pelos dois lados do quarto.
- **Quarto de dormir** com cama, boneca, espelho, guarda-roupa e as portas da
  frente e dos fundos.
- **Sala das figuras** com mesa, vela e três cadeiras ocupadas.
- **Entrada**, **passagem** e **ateliê** com mesa, abajur, cadeira, janela de chuva
  e a saída.
- **F1–F4** com colisão que acompanha a dobra; **F3** começa deitada e libera a
  passagem do quarto para o corredor.
- Porta da rua e porta do quarto de brincar abertas; portas do quarto e das
  figuras fechadas; o jogador as abre.
- O ateliê envolve o oeste da casa com um strip de apoio; é o que aparece quando
  F1 dobra para dentro. O jogador não entra nesse strip.
- Sem áudio, sem comportamento adaptativo da casa, sem arte final.

## Telas de revisão

Os PNGs são gerados em resolução 1280×720 e salvos na raiz do projeto. A captura
desliga física/input do jogador e encerra o Godot depois de salvar.

```bash
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-playroom
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-corridor
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-atelier
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-fold
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-top
```

Em um desktop comum, o `DISPLAY=:0` pode ser omitido.

| Arquivo | O que mostra |
|---|---|
| `blockout-playroom.png` | quarto de brincar com F1 em pé, mesa, prateleira e casinha |
| `blockout-corridor.png` | corredor, F3 deitada, F2/F4 e portas do quarto fechadas |
| `blockout-atelier.png` | ateliê, abajur, janela de chuva e porta da rua ao fundo |
| `blockout-fold.png` | F1 dobrada para dentro, revelando o strip oeste |
| `blockout-top.png` | planta 3D do blockout, com tetos ocultos |

## Verificação automática

```bash
godot --headless --path . -- --selftest
```

O autoteste confere estados iniciais, colisão de portas fechadas, abertura das
três portas, o laço completo com uma cápsula do tamanho do jogador, as quatro
dobras e o estado final. Sai com código 0 se tudo passar; imprime `SELFTEST
RESULT: 53 checks, 0 failures` na versão atual.

Ele **não** substitui um playtest humano: não avalia conforto de câmera, ritmo,
medo, som, nem o gesto de sentar na cabana.

## Caminho sugerido para o playtest

1. Comece no ateliê, de frente para a porta da rua.
2. Entre na entrada, visite o quarto de brincar e tente a cabana de F1.
3. Vá ao corredor, levante/abaixe F3, dobre F2/F4.
4. Abra a porta da frente do quarto, atravesse, abra a dos fundos e volte ao
   corredor.
5. Entre na sala das figuras, volte pela passagem e saia pela porta da rua.
6. Repita o laço pelo menos duas vezes e observe o que a casa “guarda”.

## Limitações conhecidas

- **Sem áudio.** O roteiro de som existe no documento de design, mas nenhum som
  foi produzido ou integrado.
- **Sem comportamento da casa.** O blockout não aprende gestos, não devolve
  dobras, não move o boneco e não tem estados de horror.
- **A cabana do F1 não é entrável.** A parede de 2,7 m dobrada a 65° deixa uma
  folga de ~1,1 m no bordo livre; a cápsula do jogador tem 1,7 m. O blockout
  mostra a dobra e o abrigo, mas não permite sentar. Ver
  `../context/achados.md`.
- **Porta dos fundos.** Ela abre para o corredor para não bloquear o caminho
  oeste do quarto; o corredor fica mais estreito quando ela está aberta. É uma
  escolha de blockout a validar em playtest.
- **O strip oeste do ateliê é cenário.** Ele existe para F1 não abrir para o
  vazio; ainda não é uma área jogável.
- **Arte e UI são andaimes.** Nada aqui é a direção visual final.
- **Sem save/export.** R reinicia a cena; não há preset de exportação.

## Estrutura

```
faz-de-conta/
├── project.godot
├── main.tscn
├── scripts/
│   ├── main.gd          # constrói casa, móveis, dobras, portas, luz e UI
│   ├── foldable.gd      # painel/porta com rotação e colisão
│   ├── player.gd        # primeira pessoa, interação e lanterna
│   ├── ball.gd          # bola interativa
│   ├── music_box.gd     # caixa de música interativa
│   ├── doll.gd          # boneca
│   ├── figure.gd        # figuras da sala
│   └── selftest.gd      # verificação headless
└── blockout-*.png       # telas de revisão
```

O documento de design, o roteiro de som e o comportamento proposto da casa estão
em `../context/discussoes/modelo-arquitetural-dinamico-3d.md`.
