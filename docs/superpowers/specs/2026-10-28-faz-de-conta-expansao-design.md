# FAZ DE CONTA — expansão: a casa por dentro da casa (design)

- **Data:** 2026-10-28
- **Direção:** Pedro Pompeu. Desenvolvimento: IA (Claude). Pedro pediu para seguir sem perguntas.
- **Base:** [`2026-10-27-faz-de-conta-relojoeiro-design.md`](2026-10-27-faz-de-conta-relojoeiro-design.md)
  (o slice do relojoeiro, já construído). Este documento **amplia** aquele. O que não for dito
  aqui continua valendo de lá.

Legenda: **[Pedro]** = pedido de Pedro nesta conversa. **[escolha da IA]** = decisão da IA,
ainda não revisada por Pedro (ele pediu para seguir sem perguntas).

---

## 1. Por que este documento existe

Pedro jogou o slice (mãos, vareta e clima de terror) e disse:

> "o mapa está muito pequeno e não conta uma história, quero criar tarefas, fases, monstros
> humanoides que aparecem e desaparecem, bater em coisas, quero melhorar a mobilidade, uma música
> assustadora, não só o tu tu tu tu tu […] ele está muito bom, mas sem propósito… vamos colocar umas
> passagens secretas, umas portas que abrem e fazem barulho. Vários ambientes (quero um mapa para
> saber onde estou)… vamos pensar fora da caixa" [Pedro]

> "precisa ser imersivo, preciso acreditar que estou no lugar do personagem" [Pedro]

O critério acima de todos é **imersão**: o jogador tem que acreditar que é Elias.

## 2. O que este pedido derruba do design anterior

Pedro pediu explicitamente coisas que o design de 2026-10-27 proibia. Elas ficam **superadas**
por este documento:

| Antes (2026-10-27) | Agora |
|---|---|
| Nada caça o jogador; sem perseguição | **Monstros humanoides que aparecem e desaparecem** [Pedro]. Eles se aproximam quando não são vistos (§6) |
| Sem trilha | **Música assustadora** [Pedro], procedural e adaptativa (§9) |
| Sem combate | **Bater em coisas** [Pedro]: a vareta quebra paredes ocas, porcelana e vidro, e desfaz os monstros (§7). Não há vida, dano nem morte |
| Sem HUD de objetivo, catálogo nunca vira checklist | **Tarefas e fases** [Pedro], escritas pelo próprio Elias no caderno (§5) |
| Só os cômodos do blockout | **Vários ambientes**, mapa maior [Pedro] (§4) |
| Texto só em papel | Continua só em papel. O **mapa** [Pedro] é uma planta desenhada a lápis no caderno (§8) |

**Continua valendo:**

- Sem game over, morte, dano ou cronômetro visível.
- A porta da rua nunca tranca. A casa não fala.
- Gore e jump scare com estouro de volume continuam fora [escolha da IA].

O susto vem de **presença**: algo que estava longe e agora está perto. Não vem de barulho alto.

## 3. A ideia central: fazer de conta

O título vira mecânica [escolha da IA]. Segurando **botão direito do mouse** (ou `V`), Elias
**fecha os olhos e faz de conta**, como Inácio menino fazia.

- A tela escurece pelas pálpebras. A casa reaparece como **lembrança**:
  - luz de tarde, cor sépia;
  - a caixa de música tocando limpa.
- Na lembrança aparecem coisas que só existiam no passado:
  - **marcas de giz** do menino Inácio (setas, X, uma porta desenhada na parede);
  - brinquedos fora do lugar;
  - as riscas de altura no batente.
- **O giz mostra as passagens secretas** e as paredes ocas. É assim que o jogador descobre por
  onde seguir sem marcador de objetivo.
- **O custo:** de olhos fechados, Elias não vê os Gastos (§6). Eles andam muito mais rápido
  enquanto ele faz de conta. Abrir os olhos pode mostrar um deles bem mais perto.

Fazer de conta é ao mesmo tempo **bússola, quebra-cabeça e risco**.

## 4. O mapa: seis ambientes [escolha da IA]

A maquete deixa de ser uma casa e vira **a bancada inteira de Inácio**. É tudo em escala de
brinquedo, e a oficina gigante segue visível pelo vidro.

| # | Ambiente | Onde | Como se chega | Caráter |
|---|---|---|---|---|
| 1 | **A casa** (térreo) | a de hoje | começo | quente, conhecida; o laço atual |
| 2 | **A passagem** | atrás da parede norte do quarto de brincar | parede oca que o giz mostra; quebrar com a vareta; entrar agachado | estreita, poeira, escuro |
| 3 | **O sótão** | em cima da casa, sob o telhado de duas águas | escada de mão no fim da passagem | baixo, lençóis sobre móveis, brinquedos velhos |
| 4 | **O mecanismo** | a torre do relógio no telhado | alçapão no sótão | engrenagens que giram como plataformas, pêndulo, subida vertical, o mostrador visto por dentro |
| 5 | **A gaveta** | dentro da bancada, embaixo da casa | alçapão oco no quarto de dormir, escada para baixo | peças de relógio gigantes, molas, parafusos como colunas, dedal para se esconder, breu |
| 6 | **O tampo e a relojoaria** | a bancada a leste da redoma, e uma segunda maquete: a **Relojoaria Varela** | quebrar o vidro trincado da redoma | aberto, ferramentas gigantes, régua como ponte, centenas de relógios fora de sincronia |

A beira sul do tampo continua sendo a saída (fim do jogo).

## 5. A história em fases

### 5.1 O objetivo

A carta que contratou Elias pede: **"Catalogue a maquete. O relógio de bolso dela está
desmontado pela casa: caixa, mostrador, ponteiros e coroa. Monte-o."** [escolha da IA]

O relógio de bolso é o de Inácio, o mesmo que as figuras usam, parado às 03:33. Montá-lo é o
que traz o 03:33. O jogador está ajudando Inácio a morrer sem saber, ou ajudando a casa a
prendê-lo. A escolha final (com corda / sem corda) continua a mesma do design anterior.

### 5.2 As fases

Cada fase tem 2 a 4 tarefas. Elias as escreve como **lotes** no caderno e risca o que fez.
Não há contador "x de y". Cada fase termina ao encontrar uma peça do relógio de bolso.

| Fase | Título (no caderno) | Tarefas | Peça | Os Gastos |
|---|---|---|---|---|
| I | A casa da rua do Porto | catalogar o relógio da entrada; catalogar o desenho do menino; achar o que o desenho esconde | **a coroa**, no fim da passagem | nenhum até pegar a coroa; depois **o primeiro aparece** |
| II | O sótão | subir ao sótão; abrir o mecanismo; pegar os ponteiros lá no alto | **os ponteiros**, no topo da torre | 1 |
| III | A gaveta | achar o alçapão do quarto; descer à gaveta; pegar o mostrador | **o mostrador**, dentro de uma caixa de relógio gigante | 2 |
| IV | A relojoaria | quebrar o vidro da redoma; atravessar a bancada; pegar a caixa | **a caixa**, na oficina dos fundos da relojoaria | 2 |
| V | 03:33 | voltar para casa; o relógio para (03:33, ecos, como hoje); dar corda; ler a página da cabana; escolher e sair | — | nenhum durante o 03:33 |

Regras:

- **03:33 só começa na fase V** [escolha da IA]. Isso substitui o gatilho antigo (boneco + 5
  peças, ou 20 min). O limite de segurança por tempo sobe para **60 min**.
- Os brinquedos, o espelho, o boneco e o catálogo livre continuam existindo e dando entradas.
  Tarefas são o fio; catalogar continua sendo o verbo.
- As páginas de diário novas (uma por ambiente) contam a vida de Inácio de criança a morte, na
  ordem das fases.

## 6. Os Gastos (os monstros) [Pedro pediu; o comportamento é escolha da IA]

**O que são:** versões de Inácio e de catalogadores anteriores, gastas de tanto loop. Têm
corpo de manequim, rosto de porcelana rachado sem olhos, mãos compridas. São os sussurros do
conto. Não são zumbis nem bichos. São gente que virou peça.

**Como se movem:** **só quando ninguém olha.** Não andam na frente do jogador:

- Eles saltam entre **pontos de espreita**: portas, cantos, o fim de corredores. Cada salto os
  leva um ponto mais perto, por um grafo de pontos por ambiente.
- Olhar para eles com luz (lanterna ou lâmpada da casa) os **congela**.
- Encarar por alguns segundos faz um deles **se desfazer**: racha e some. Ele volta depois,
  em outro lugar, longe.
- Uma **pancada de vareta** faz o mesmo na hora, com estalo de porcelana.
- Com os olhos fechados (fazer de conta) ou a lanterna desligada no escuro, eles avançam
  rápido.

**Aparecer e desaparecer** [Pedro] é literal:

- surgem na beira da visão;
- somem quando o jogador olha de novo;
- reaparecem um ponto mais perto.

**Se um deles alcança Elias:** **o abraço**. Não há morte.

1. A tela fica preta; frio, porcelana estalando no ouvido.
2. Elias acorda deitado no último ponto seguro da fase.
3. O duplo escreve no caderno uma linha sobre isso. Exemplo: "Item —, catalogador, segurado no
   corredor. Frio."
4. A casa ganha tensão.

Perder custa **tempo e nervo, nunca progresso**.

**Esconder-se:** agachado dentro de um esconderijo, o Gasto não consegue chegar ao último
ponto. Esconderijos: a cabana, debaixo da cama, o dedal na gaveta, o balcão da relojoaria.
Depois de um tempo ele desiste e volta.

**Sinais:** porcelana tiquetaqueando perto, a trilha engrossa (§9) e o coração de Elias acelera.
O jogador **ouve** antes de ver.

**Regras duras:**

- Nunca aparecem no campo de visão do jogador. Só se movem fora dele.
- Nunca bloqueiam a porta da rua.
- Nada acontece durante o 03:33, que continua sendo dos ecos.
- O caminho de volta para casa sempre existe.

## 7. Bater em coisas [Pedro]

A vareta já bate. Agora o que ela acerta responde:

| Alvo | Som | Resultado |
|---|---|---|
| parede comum | toc seco (hoje) | a casa devolve as batidas (espelho) |
| **parede oca** | toc grave, com eco | 3 pancadas: racha, quebra, abre a passagem (cacos de reboco) |
| **alçapão oco** | toc grave de tábua | 3 pancadas: abre |
| **porcelana / vidro** (vasos, xícaras, cúpulas, o vidro trincado da redoma) | tilintar | quebra em cacos |
| **um Gasto** | estalo de porcelana | ele se desfaz e volta mais tarde, longe |
| porta emperrada | baque | 2 pancadas destravam (nunca a da rua) |

## 8. O mapa no caderno [Pedro: "quero um mapa para saber onde estou"]

- `M` abre o caderno direto na **planta**. `Tab` continua abrindo o caderno.
- A planta é **desenhada a lápis por Elias**: só aparecem os cômodos em que ele já entrou, com
  nome na letra dele.
- Um **ponto de lápis** marca onde ele está, com uma setinha para onde olha.
- Uma aba por andar/ambiente: casa, passagem, sótão, mecanismo, gaveta, tampo, relojoaria. Abre
  sempre na aba de onde Elias está.
- Os lotes (tarefas) ficam em outra página do caderno, com o que já foi feito riscado.

## 9. Som e música [Pedro: "uma música assustadora, não só o tu tu tu"]

A trilha é **procedural**: gerada em código na carga, como os sons de hoje. É **adaptativa**,
feita de camadas que sobem e descem:

| Camada | O que é | Sobe quando |
|---|---|---|
| **drone** | grave desafinado com ar, uma tonalidade por ambiente | sempre; mais grave quanto mais fundo (gaveta) |
| **canção de ninar** | a melodia da caixa de música, lenta, desafinada, com notas que faltam | longe dos Gastos, em silêncio |
| **cordas** | cluster dissonante que incha devagar | um Gasto perto ou visto |
| **coração** | pulso grave, acelera | Gasto muito perto; correndo |
| **lembrança** | a mesma canção, limpa e em tom maior | fazendo de conta |

O que mais muda o som:

- **Portas:** abrir range devagar; fechar bate. Cada porta tem uma afinação levemente
  diferente.
- **Passos por superfície:** madeira, metal no mecanismo, tecido nos tapetes. Há também som de
  pouso depois do pulo.
- **Reverb por ambiente:** sótão abafado, gaveta grande e oca, mecanismo metálico.

## 10. Mobilidade [Pedro]

| Tecla | Ação |
|---|---|
| `Shift` | correr. O fôlego acaba e a respiração fica pesada (sem barra) |
| `Espaço` | pular (curto, peso de gente) |
| `C` / `Ctrl` | agachar. Passa por buracos baixos e entra em esconderijos |
| escadas de mão | `W`/`S` sobem e descem quando encostado |
| plataformas que giram | as engrenagens do mecanismo carregam Elias |

Câmera com peso: inclina de leve ao andar de lado, afunda no pouso e abre o FOV ao correr.

## 11. Imersão: o que não pode faltar [Pedro: "acreditar que estou no lugar do personagem"]

- **Nada na tela que Elias não veria.** Ficam só o ponto de mira e o prompt da tecla, e o prompt
  some sozinho depois de algumas vezes que a mesma ação foi usada [escolha da IA].
- A ajuda de teclas aparece só no começo (como hoje).
- Mãos visíveis em tudo: a vareta bate, a mão esquerda alcança e a lanterna treme com o medo.
- Tudo o que guia é diegético: giz, sons, luz, o caderno.

## 12. Não-objetivos

- Arte final (continua blockout com primitivas, mais caprichado).
- Save entre sessões.
- Voz ou narração.
- Inimigos com vida, armas, dano.
- Novas dependências: tudo continua gerado em código, inclusive a música.

## 13. Anti-objetivos (fracasso mesmo funcionando)

- **Um Gasto se move na frente do jogador.** Isso mata o "aparecem e desaparecem".
- O abraço vira tela de game over ou tira progresso.
- Tarefa vira marcador flutuante ou seta na tela.
- O mapa mostra o que Elias ainda não viu.
- A música vira trilha de filme de ação. Ela tem que ser quase parada.
- Ficar preso: sem saída de uma área, ou cair sem volta.

## 14. Restrições

- Godot 4.7.2, GL Compatibility, tudo gerado por código em `faz-de-conta/`. Sem `class_name`;
  `preload`.
- Novos ambientes em scripts próprios (`scripts/areas/*.gd`), não em `main.gd`.
- Modelos puros (`RefCounted`) para fases, Gastos, atlas do mapa e mixagem da trilha, com teste
  unitário.
- O selftest continua verde e ganha o laço novo (casa → passagem → sótão → mecanismo; casa →
  gaveta; tampo → relojoaria).
- `python lint.py` e `context/` atualizados ao concluir.

## 15. O que fica com quem constrói

Fica com quem constrói [escolha da IA]:

- geometria exata dos ambientes;
- texto das páginas e das tarefas;
- números de ritmo: velocidade dos Gastos, fôlego, pulo;
- quantos pontos de espreita por ambiente;
- a melodia da canção de ninar.
