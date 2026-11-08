# Janghyang — direção: história, foco e o que fazer (design)

- **Data:** 2026-11-08
- **Direção:** Pedro Pompeu. Desenvolvimento e arte: IA (Claude).
- **Base:** [`2026-10-27-faz-de-conta-relojoeiro-design.md`](2026-10-27-faz-de-conta-relojoeiro-design.md)
  (a história e o slice) e [`2026-10-28-faz-de-conta-expansao-design.md`](2026-10-28-faz-de-conta-expansao-design.md)
  (as seis áreas, os Gastos, o mapa e a mobilidade). Este documento **reorienta** os dois. O que
  não for dito aqui continua valendo de lá.
- **Decisões de origem:** R1–R15 em `context/decisoes.md#rumo-2026-11-08`; escolhas brutas em
  `fontes/2026-11-08-pedro-escolhas-rumo.md`.
- **Substitui:** o plano `docs/superpowers/plans/2026-11-07-janghyang-lancamento.md` como rumo
  do produto. As correções técnicas dele (A-005 a A-019, fases 0 a 3) passam para o plano novo.

Legenda: **[Pedro, Rn]** = decidido por Pedro, com o número da decisão. **[escolha da IA]** =
proposta da IA que Pedro ainda não revisou. Toda [escolha da IA] pode ser trocada sem custo
antes do plano.

---

## 1. Por que este documento existe

Pedro jogou o que existe e disse que falta **história, foco, direcionamento e coisas para
fazer**, e que o mapa é limitado. Pediu também gráficos melhores. O jogo de hoje tem 15 cômodos
em seis áreas, os Gastos, o caderno, a vareta e o 03:33, mas o jogador anda sem saber por quê,
a história chega em páginas soltas e a casa é um refúgio onde nada assusta.

As escolhas de 2026-11-08 mudam o centro: o jogo passa a ser **horror de sobrevivência
psicológico**, contado **em capítulos**, ao longo de **várias noites e várias maquetes**, com um
**relógio de bolso que aponta o caminho** e assets de verdade no lugar dos blocos.

## 2. O jogo em uma frase

Elias passa noites dentro das maquetes de um relojoeiro morto, procurando as peças de um
relógio de bolso enquanto versões gastas de Inácio o caçam no escuro, e a cada noite a casa
conta mais da vida de Inácio e é menos segura.

## 3. O que muda

| Antes | Agora |
|---|---|
| Horror doméstico contemplativo; "não é survival horror" | **Horror de sobrevivência com incursões**, terror psicológico, sem matança; o jogador vive assustado [Pedro, R3] |
| Uma visita contínua, fases I a V | **Noites**, cada uma com capítulos; cada noite termina num 03:33 (§5) [Pedro, R6; forma: escolha da IA] |
| A história em páginas de diário espalhadas | **Um capítulo por área**: encenação das figuras e página de hipótese no caderno (§6) [Pedro, R4; forma: escolha da IA] |
| O jogador lê os lotes e adivinha o caminho | **O relógio de bolso é a bússola**, apresentado antes de ser preciso (§7) [Pedro, R5] |
| A planta mostra os cômodos visitados | **Planta em tempo real**, revelada pelo que Elias viu, com as anotações dele (§8) [Pedro, R7] |
| Vareta, lanterna, esconder, agachar | **Onze ações** de sobrevivência e investigação (§9) [Pedro, R8 e R15] |
| Ser pego = abraço, acorda no ponto seguro | **Luta para se soltar** antes do abraço (§10) [Pedro, R11] |
| O térreo é refúgio para sempre | **A casa é segura no começo** e deixa de ser a cada noite (§11) [Pedro, R12] |
| Tudo montado à mão em `main.gd` | **Registro de áreas, maquetes e noites** por dados; área nova não toca `main.gd` (§12) [Pedro, R6; desenho: escolha da IA] |
| Blocos e cores chapadas; "nenhum asset importado" | **Assets CC0 editados no Blender** pela IA, texturas realistas de maquete (§14) [Pedro, R9, R13, R14] |
| Lançamento completo em 2027-04-15 | **Demo pública** em 2027-04-15, se estiver pronta e com história jogável; jogo completo sem data (§15) [Pedro, R2] |

**Continua valendo:** a porta da rua nunca tranca; texto só em papel; a casa não fala; nada
acontece durante o 03:33, que é a hora dos ecos; sem morte e sem game over; os Gastos só se
movem sem ser vistos; o final (dar corda ou deixar parar) e a verdade sobre Inácio do design de
2026-10-27.

## 4. O foco: viver assustado procurando coisas para se salvar

Quatro pilares. Toda mecânica nova responde a pelo menos um deles; o que não responde sai.

1. **Medo constante, não matança** [Pedro, R3]. Ninguém mata nada. Os Gastos se desfazem e
   voltam. O medo vem de não saber onde estão, da luz que acaba e da casa que muda.
2. **Buscar e procurar para se salvar** [Pedro, R3]. Pilhas, fósforos, peças de mecanismo,
   o brinquedo de corda, o caminho do giz. Procurar é o que o jogador faz a maior parte do tempo,
   e procurar faz barulho, gasta luz e expõe as costas.
3. **Saber para onde ir, nunca como chegar** [Pedro, R5]. O relógio aponta a meta. O caminho,
   o perigo e o que pegar no meio do trajeto ficam com o jogador.
4. **A história é o motivo de continuar** [Pedro, R4]. Cada área fecha um capítulo da vida de
   Inácio. O jogador avança porque quer saber, não só porque tem tarefa.

**O loop de uma noite** [escolha da IA]:

> dar corda na maquete → acordar na entrada → abrir o relógio e ver a direção → atravessar a
> casa procurando luz e passagem → chegar à área do capítulo → investigar (catalogar, lupa,
> consertar) enquanto os Gastos rondam → assistir à encenação → escrever a hipótese → pegar a
> peça → voltar → 03:33 → acordar na oficina.

## 5. Noites e maquetes [Pedro, R6; estrutura: escolha da IA]

### 5.1 O que é uma noite

- Uma noite é uma sessão de **30 a 50 minutos** com começo, capítulos e fim.
- **Começa** com Elias dando corda na maquete na oficina real e acordando dentro dela, na
  entrada da casa. A casa é sempre a porta de entrada, mesmo quando a meta está em outra maquete.
- **Termina** com um 03:33 quando as metas da noite estão cumpridas, ou no limite de 60 minutos.
  Durante o 03:33, como hoje: o relógio para, os ecos aparecem e nada caça Elias. Dar corda
  encerra a noite e Elias acorda na bancada da oficina real.
- **Entre noites:** uma tela de papel com a página de hipótese da noite e a data no caderno.
  É aqui que o jogo salva. Só se salva entre noites.
- **O que fica de uma noite para outra:** peças, itens de mão (espelho, lupa, estetoscópio),
  atalhos abertos, a planta, as anotações e o catálogo. Pilhas, fósforos e o brinquedo de corda
  **não** passam: cada noite começa com pouca luz.
- **O 03:33 completo,** com a escolha final, só acontece na última noite. Nas outras, o 03:33 é
  curto (cerca de 90 s) e mostra um eco novo ligado ao capítulo da noite.
- **Como a noite usa o estado de hoje** [escolha da IA]: as fases I a V do `quest_model.gd`
  passam a ser as metas de cada noite em `noites.gd` (§12). A regra de hoje para liberar o 03:33
  (as quatro peças mais a tarefa "voltar", via `visit.on_pieces_ready`, decisão de 2026-10-29)
  vira uma regra por noite: **cumprir as metas da noite e voltar ao térreo** libera o 03:33
  curto. Na noite 5, o gatilho é o de hoje: as quatro peças montadas e "voltar". O
  `visit_state.gd` passa a ser o estado de uma noite e é recriado a cada noite. O que passa de
  uma noite para outra fica num estado de campanha separado, que é o que se salva.

### 5.2 As maquetes

| Maquete | O que é | Áreas | Como se chega |
|---|---|---|---|
| **Item 214 — a casa da rua do Porto** | a de hoje: a casa da infância de Inácio | casa, passagem, sótão, torre, gaveta | começo |
| **Item 215 — Relojoaria Varela** | a de hoje, sobre o tampo | tampo, loja, oficina dos fundos | o vidro trincado da redoma |
| **Item 216 — a mansão das falésias** (nova) | a mansão onde Elias está sentado agora, em miniatura | saguão, arquivo, a oficina | do tampo, pela régua até uma terceira redoma no fim da bancada |

- Os **15 cômodos atuais** ficam como estão [Pedro, R6]. Os **3 novos** são os da mansão:
  - **o saguão:** o relógio de pêndulo de ébano do conto, parado às 03:33;
  - **o arquivo:** os fichários dos catalogadores anteriores;
  - **a oficina:** a bancada em miniatura, com uma figura de Elias sentada, a mão na corda de
    uma maquete ainda menor.
- A mansão é a maquete do lugar onde o corpo de Elias está. É o horror da última noite: a
  maquete contém quem a está olhando.
- **Crescer depois** é acrescentar maquetes (Item 217 em diante) e áreas pelo registro (§12),
  sem redesenhar as noites que já existem.

## 6. Os capítulos [Pedro, R4; conteúdo: escolha da IA]

Cada área conta **um capítulo** da vida de Inácio, da infância à morte, na ordem em que o
jogador chega. A verdade final continua a de 2026-10-27 (os fragmentos 1 a 6). Os capítulos
distribuem esses fragmentos e acrescentam a vida entre eles. **Todo o conteúdo novo de história
abaixo é escolha da IA e precisa da leitura de Pedro.**

### 6.1 Como um capítulo chega

1. **Pistas:** três ou quatro objetos da área que, catalogados (e às vezes vistos com a lupa),
   dão uma entrada no catálogo.
2. **A encenação:** quando as pistas estão catalogadas, as figuras da área encenam a cena, em
   silêncio e de forma mecânica, como autômatos. A encenação só anda quando Elias **não olha**:
   cada vez que ele olha de novo, as figuras estão numa pose adiante. O jogador monta a cena
   olhando e desviando o olhar. Não há texto nem voz.
3. **A página de hipótese:** Elias escreve no caderno o que acha que aconteceu. O jogador
   escolhe, entre três frases que Elias rascunhou, a que as pistas sustentam. A frase certa vira
   página passada a limpo. A errada fica riscada e não custa nada além de tempo. A encenação
   continua lá para ser revista.
4. **A peça ou o âncora** da noite está onde a encenação termina.

**Como isso se apoia no código** [escolha da IA]:

- As pistas de cada capítulo são uma lista de ids de catálogo em `noites.gd`. O capítulo abre a
  encenação quando todas estão no catálogo, usando o sinal `cataloged` que já existe.
- A encenação é uma sequência de poses discretas por figura. Ela avança uma pose quando o grupo
  de figuras fica 1,5 s fora da vista (`is_seen`, o mesmo teste dos Gastos) e para na última.
- A página de hipótese é uma página do caderno (`notebook_ui.gd`) com três frases. A certa fica
  passada a limpo e a errada, riscada.

### 6.2 Os sete capítulos

| Noite | Cap. | Área | O capítulo | O que se descobre | Ação ensinada | Meta |
|---|---|---|---|---|---|---|
| 1 | 1 | **casa** | *A casa da rua do Porto* | a maquete é a casa da infância de Inácio (fragmento 2) | bússola, catalogar, luz escassa, giz | achar o que o desenho do menino esconde |
| 1 | 2 | **passagem** | *O menino que escutava* | o menino ouvia, pela parede, o pai consertar relógios; aprendeu que tudo que tem corda para | escutar pelas paredes, esconder | **a coroa** |
| 2 | 3 | **sótão** | *Os lençóis* | o primeiro relógio que Inácio fez foi para a mãe doente, para adiar a hora dela; não adiou | lupa, espelho de mão, barricar | abrir o alçapão da torre |
| 2 | 4 | **torre** | *A hora marcada* | Inácio sabia a hora da própria morte, 03:33, e fez o relógio do telhado para nunca chegar lá (fragmento 1) | consertar mecanismos, relógio-âncora | **os ponteiros** |
| 3 | 5 | **gaveta** | *As versões gastas* | as figuras e os Gastos são versões antigas de Inácio, gastas de tanto loop (fragmento 4) | brinquedo de corda como isca, fósforos no breu | **o mostrador** |
| 4 | 6 | **relojoaria** | *A carta* | Inácio chamou catalogadores depois de morto; a carta de Elias tem data posterior à morte (fragmento 5) | todas, sob pressão | **a caixa** |
| 5 | 7 | **mansão** | *03:33* | ele entrou e virou a casa (fragmento 3); o duplo é Elias começando (fragmento 6) | nenhuma nova; nenhum lugar seguro | o 03:33 completo e a escolha |

- **Uma reviravolta da bússola:** no arquivo, a lupa mostra iniciais de outra pessoa gravadas
  por dentro da tampa do relógio de Elias. Ele não foi o primeiro a ser guiado por ele.
- **O duplo** (o de hoje, que escreve no caderno) aparece a partir da noite 2 e escreve cada
  vez mais. Na noite 5, as páginas de hipótese passam a ser escritas na letra dos dois.
- **Pelas janelas,** a oficina real é visível em todas as noites. Na noite 2, do alto da torre,
  Elias vê o próprio corpo sentado na bancada pela primeira vez.

## 7. A bússola: o relógio de bolso de Elias [Pedro, R5; mecânica: escolha da IA]

### 7.1 Que relógio é

O relógio de bolso de **Inácio** é o objeto desmontado (coroa, ponteiros, mostrador, caixa) que
Elias monta ao longo das noites. A bússola é **outro** relógio: o de Elias, que veio junto com a
carta. Relógios são âncoras e se atraem. O ponteiro dos segundos do relógio de Elias sente as
partes do outro.

### 7.2 Como funciona

- Uma tecla própria (sugestão: `Q`) **abre o relógio** na mão esquerda. Ele ocupa a mão: com o
  relógio aberto, Elias não usa espelho, fósforo nem vareta.
- Aberto, o ponteiro dos segundos **para de andar e aponta** para a meta da noite.
  - Mesma área: aponta em linha reta.
  - Meta em outra área ou andar: aponta para a ligação que leva até lá (escada, alçapão,
    parede oca, redoma), e o relógio inclina para cima ou para baixo. A ligação é a primeira do
    **caminho mais curto** no grafo de áreas, montado com os `links` dos `DEF` (§12). Os links
    valem nos dois sentidos, e um link fechado (parede ainda não quebrada, mecanismo parado)
    também conta, porque abrir o caminho faz parte de chegar.
  - Sem caminho, o ponteiro gira devagar, sem parar.
- O tique **acelera** conforme Elias se aproxima.
- Com um Gasto a menos de cerca de 6 m, o ponteiro **treme e gira**: a bússola também avisa do
  perigo, mas sem dizer onde.
- **Custo:** com o relógio aberto, o tique é audível para os Gastos num raio pequeno. Abrir o
  relógio é seguro na casa no começo e arriscado no fim.
- **Nunca** marca a meta na tela. Não há seta, contorno nem brilho no objeto.

### 7.3 A apresentação (antes de o jogador precisar)

Na noite 1, antes da primeira tarefa [Pedro, R5: "precisa ter um direcionamento antes"]:

1. Elias acorda na entrada. O único som é um tique alto **no bolso dele**, fora de compasso com
   o relógio da entrada.
2. A carta está na mão. É a primeira coisa que se lê, em papel, na letra de Inácio: "O relógio
   que segue com esta carta sabe onde estão as partes do outro. Abra-o quando não souber para
   onde ir."
3. As luzes da entrada piscam e só fica acesa a lâmpada do quarto de brincar.
4. O jogador abre o relógio: o ponteiro aponta para o quarto de brincar, onde está o desenho do
   menino, a poucos metros e à vista. O jogador **confere** que o ponteiro diz a verdade.
5. Catalogar o desenho fecha a lição. Daí em diante, o relógio é a resposta para "para onde eu
   vou?".

## 8. A planta em tempo real [Pedro, R7; mecânica: escolha da IA]

- `M` abre o caderno na planta, como hoje. **O jogo não pausa** com o caderno aberto: os Gastos
  continuam se movendo e o tempo da noite corre. Ler a planta é um risco. Elias fica parado
  segurando o caderno, como hoje (`notebook_ui.gd` trava o movimento e solta o mouse). A mudança
  é que o mundo deixa de parar. O "tempo real" é o da planta: o ponto e a névoa mostram o estado
  atual no instante em que o caderno abre, e o ponto gira se Elias for empurrado. Só o `Esc`
  pausa.
- **Névoa por célula, não por cômodo:** a planta revela o que Elias **viu**, em células de cerca
  de 0,5 m, dentro do campo de visão e do alcance da luz. Paredes aparecem quando vistas. Um
  cômodo visitado no escuro fica pela metade. Cada nível guarda uma grade de bits sobre o
  retângulo dos cômodos dele. A gaveta, a maior, tem 18 × 14 m, ou cerca de mil células. A grade
  é atualizada umas poucas vezes por segundo, por amostragem de raios curtos no campo de visão,
  e vai no save entre noites [escolha da IA].
- **Ponto de lápis com seta** para onde Elias olha, já previsto no spec de 2026-10-28.
- **Anotações automáticas de Elias**, em lápis, no lugar onde aconteceram:
  - "visto aqui" com a hora, onde um Gasto foi visto;
  - pilhas, fósforos ou peças que ele **viu e não pegou**;
  - portas barricadas e relógios-âncora, com a corda que ele lembra (cheia, metade, quase nada);
  - as marcas de giz que o próprio Elias desenhou (§9, seguir o giz).
- **Uma aba por área,** abrindo na área onde Elias está, como no spec de 2026-10-28.
- Sem minimapa, sem marcador de objetivo, sem HUD [Pedro, R7].

## 9. As onze ações [Pedro, R8 e R15; regras: escolha da IA]

Cada ação existe por um dos pilares do §4. Os números são pontos de partida para afinar no
playtest.

| # | Ação | Regra | Ligação com a história |
|---|---|---|---|
| 1 | **Relógios-âncora** [R8] | relógios de corda espalhados pelas áreas. Dar corda num âncora (segurar 2 s, faz barulho) cria um raio de cerca de 4 m onde os Gastos não entram enquanto a corda dura (90 s no começo, menos a cada noite). O relógio da entrada é o âncora da casa | os relógios do conto empurram a realidade; Inácio os fez para adiar o minuto |
| 2 | **Catálogo como investigação** [R8] | catalogar dá pistas; as pistas abrem a encenação e a página de hipótese (§6.1) | Elias é catalogador; a verdade chega pelo trabalho dele |
| 3 | **Consertar mecanismos** [R8] | mecanismos parados bloqueiam caminhos (o elevador da torre, a porta de mola da gaveta, a vitrine da relojoaria). Falta uma engrenagem ou um pino, que se procura na área. Encaixar e girar até engrenar leva alguns segundos e faz barulho | Inácio era relojoeiro; consertar é o verbo dele, e Elias começa a ter as mãos dele |
| 4 | **Furtividade mais rica** [R8] | ruído com três níveis: andar agachado (quase nada), andar, correr ou consertar (alto). Os Gastos ouvem e vão até o último ruído. Esconderijos novos por área. Dentro do esconderijo, segurar a respiração (segurar uma tecla, até 8 s) deixa o Gasto passar | as figuras ouvem a casa, porque são a casa |
| 5 | **Seguir o giz** [R8] | trilhas de giz do menino Inácio levam a segredos: pilhas, atalhos, pistas. Elias também carrega giz e pode marcar paredes; a marca vai para a planta | o desenho do menino já esconde a passagem; o giz é a brincadeira dele |
| 6 | **Luz escassa** [R15] | a lanterna gasta pilha (cerca de 4 min por pilha) e pisca quando está no fim. Fósforos acendem por 20 s e podem acender velas e lamparinas, que ficam acesas como luz fixa por um tempo. A luz congela os Gastos, então luz é sobrevivência | a casa é de brinquedo; a luz de verdade é rara |
| 7 | **Brinquedo de corda como isca** [R15] | dar corda num brinquedo (rato, soldado) e soltá-lo: ele anda e faz barulho por 15 s, e os Gastos vão até ele. Dá para recuperá-lo, se for seguro | brinquedos de Inácio criança; a casa ama brincar |
| 8 | **Escutar pelas paredes** [R15] | encostar o ouvido na parede (segurar uma tecla perto dela) abafa o resto do som e mostra, pelo som, onde os Gastos estão do outro lado. Com o estetoscópio de relojoeiro (achado no sótão), atravessa pisos e funciona de mais longe | o capítulo 2: o menino que escutava pela parede |
| 9 | **Lupa de relojoeiro** [R15] | olhar de perto um objeto catalogado mostra detalhes escondidos (gravações, datas, iniciais). Elias copia o que vê para o caderno, e é lá que o texto aparece (texto só em papel) | instrumento de Inácio; revela a reviravolta da bússola (§6.2) |
| 10 | **Barricar portas internas** [R15] | empurrar um móvel contra uma porta interna. A porta segura um Gasto por um tempo (cerca de 30 s de pancadas, audíveis) e depois cede. **A porta da rua nunca tranca nem se barrica** | a casa tenta entrar onde Elias se fecha |
| 11 | **Espelho de mão** [R15] | segurar o espelho mostra o que está atrás sem virar. Um Gasto visto no espelho **conta como visto**: não se move. Mas o espelho não ilumina, então não o desfaz. Às vezes o espelho mostra o duplo onde não há ninguém | o espelho já existe na casa; a estranheza de se ver repetido (2026-10-27) |

**Mãos e bolsos** [escolha da IA]: a lanterna fica na mão direita. A mão esquerda segura uma
coisa por vez: relógio, espelho, fósforo, lupa ou vareta. Os bolsos são uma página do caderno
("bolsos"), com o que Elias carrega desenhado a lápis. Não há grade de inventário na tela.

## 10. A captura [Pedro, R11; números: escolha da IA]

1. Um Gasto alcança Elias. A câmera é **puxada e sacode**, a tela **pisca** em escuro e
   porcelana estala no ouvido.
2. O jogador **clica várias vezes** para se soltar: cerca de 10 cliques em 4 s na noite 1,
   subindo até cerca de 16 na noite 5. As mãos de Elias aparecem empurrando, e cada clique
   empurra um pouco.
3. **Soltou:** o Gasto se desfaz como numa pancada de vareta e volta depois, longe. Elias
   cambaleia por 2 s. O custo é tempo, e o relógio de Elias perde corda (o tique fica mais
   lento até a próxima noite).
4. **Não soltou:** acontece o abraço de hoje (2026-10-29): preto, frio, acorda deitado no ponto
   seguro da área, e o duplo escreve a linha no caderno [Pedro, R11: default].
5. **Sem morte, sem game over.** Perder custa tempo e nervo, nunca progresso.

**Onde mora no código** [escolha da IA]: hoje o `stalker_model.gd` passa direto de "alcançou"
para `caught`, sem estado no meio. Entra um modelo novo, `capture_model.gd` (`RefCounted`, com
testes de unidade), com os estados livre, agarrado, soltou e abraço. Enquanto Elias está
agarrado:

- o Gasto que o pegou fica parado e os outros também;
- o movimento, o caderno e as interações ficam travados;
- só os cliques (ou o segurar) contam.

`gastos.gd` chama o abraço de hoje só quando o modelo termina em abraço.

**Acessibilidade** [escolha da IA]: o piscar fica abaixo de 3 vezes por segundo e nunca usa
branco cheio. Nas opções do `Esc`, "reduzir piscar" e "segurar em vez de clicar".

## 11. A casa que deixa de ser segura [Pedro, R12; curva: escolha da IA]

A segurança deixa de ser uma lista fixa de áreas (`gastos.gd` `REFUGE`) e passa a ser um dado
**por noite**, mais os relógios-âncora.

| Noite | A casa |
|---|---|
| 1 | segura: nenhum Gasto entra no térreo |
| 2 | segura enquanto o relógio da entrada tem corda; sem corda, um Gasto pode entrar |
| 3 | segura só nos cômodos com luz acesa; o relógio da entrada dura metade |
| 4 | um Gasto mora na casa; só os âncoras com corda são seguros |
| 5 | nenhum lugar é seguro; os âncoras seguram por pouco tempo |

**Continua valendo:** a porta da rua nunca tranca e nenhum Gasto a bloqueia; o caminho de volta
para casa sempre existe; nada acontece durante o 03:33.

**O que muda no código** [escolha da IA]: hoje a segurança é por **nível**. `REFUGE` em
`gastos.gd` faz o nível `casa` não ter grafo de espreita, e `wanted()` devolve zero nele. A
segurança passa a ser por **ponto**:

- todo nível, a casa inclusive, tem grafo de espreita;
- uma função `is_safe(point, night)` decide, a partir dos dados da noite, se um ponto está
  protegido: a casa inteira (noite 1), a casa com o relógio da entrada com corda (noite 2), um
  cômodo com luz acesa (noite 3) ou o raio de um âncora com corda (todas as noites);
- um Gasto não salta para um ponto de espreita protegido nem alcança Elias num ponto protegido;
- `wanted()` passa a vir da noite, e não do nível.

**Os Gastos por noite** [escolha da IA]: noite 1, nenhum até pegar a coroa, depois 1; noite 2,
1 a 2; noites 3 e 4, 2; noite 5, 3. O teto atual é `MAX := 2` em `gastos.gd`; a noite 5 pede 3.

## 12. A estrutura que cresce [Pedro, R6; desenho: escolha da IA]

Pedro pediu que acrescentar área seja fácil e não exija mexer em `main.gd`. Hoje cada área
nova toca em quatro lugares: o `preload` e a chamada de build no `main.gd`, os mapas
`LEVEL_SAFE`, `ROOM_TASKS`, `BREAK_TASKS` e `CATALOG_TASKS`, os `ROOMS` do `atlas.gd` e as
fases do `quest_model.gd`.

### 12.1 O desenho

- **Os termos:**
  - **nível** é o que o código já chama de `level` (`casa`, `passagem`, `sotao`, `mecanismo`,
    `gaveta`, `tampo`), com um ponto seguro cada (`LEVEL_SAFE`);
  - **área** é um nível no registro: um arquivo, um `DEF`;
  - **cômodo** é um `room` do atlas, e um nível tem vários;
  - **maquete** agrupa níveis.

  A torre (`mecanismo`) continua sendo um nível separado do sótão. As abas da planta seguem a
  ordem do registro.
- **Cada área é um arquivo** em `scripts/areas/<id>.gd` com um `const DEF` (dados) e o
  `static func build(main)` que já existe:

  ```gdscript
  const DEF := {
      "id": &"gaveta",
      "maquete": &"item_214",
      "rooms": [{"id": &"gaveta", "name": "gaveta", "rect": Rect2(-1, -1, 18, 14), "y": Vector2(-3.6, -0.5)}],
      "safe": Vector3(14.9, -3.0, 1.9),        # hoje em LEVEL_SAFE
      "links": [{"to": &"casa", "at": Vector3(...)}],  # para a bússola e as rotas
      "tasks": {&"gaveta": &"descer_gaveta"},  # hoje em ROOM_TASKS
      "breaks": {}, "catalog": {},             # hoje em BREAK_TASKS e CATALOG_TASKS
      "anchors": [], "hideouts": [],
  }
  static func build(main) -> Node3D: ...
  ```

- **Um registro** em `scripts/areas/registry.gd` lista as áreas por `preload`, uma linha por
  área, num `const AREAS := [...]`. O `main.gd` constrói as áreas na ordem da lista, e a ordem
  é também a das abas. Acrescentar uma área é **criar o arquivo e acrescentar uma linha** no
  registro. Não se usa varredura de diretório: no export, os scripts são remapeados e
  compilados, e enumerar `res://` com `DirAccess` para carregá-los é frágil.
- **Durante a migração,** o `main.gd` pode continuar montando à mão o que ainda não migrou (a
  casa, o tampo, a oficina), lado a lado com as áreas do registro. O atlas e os mapas de tarefas
  juntam as duas fontes até a última área migrar.
- **Maquetes** em `scripts/maquetes/registry.gd`: id, nome, número de item, onde fica na
  bancada (transform), a redoma e as áreas dela.
- **Noites** em `scripts/story/noites.gd`, só dados: os capítulos, as metas da bússola, as
  peças, as tarefas (o que hoje são as `PHASES` do `quest_model.gd`), a segurança da casa, a
  quantidade de Gastos e a duração dos âncoras.
- O `main.gd` passa a **percorrer os registros**: constrói as áreas, junta os `rooms` no atlas e
  os mapas de tarefas a partir dos `DEF`. Os helpers de construção (`_box`, `_wall_x`,
  `_breakable`, `_hideout` e os outros) continuam no `main.gd` por enquanto, como uma biblioteca
  que as áreas usam.
- **Os helpers de `main` viram contrato:** a lista dos helpers que as áreas usam fica escrita
  no `registry.gd` e é testada (cada um existe em `main` e tem a assinatura esperada). Assim, a
  migração não quebra uma área em silêncio. Tirar os helpers do `main.gd` para uma biblioteca
  própria é um passo posterior, fora deste documento.
- **Um teste de unidade valida todos os `DEF`:** ids únicos, `safe` dentro de um cômodo da área,
  tarefas existentes nas noites e `links` que apontam para áreas registradas. **Sobreposição de
  cômodos** é permitida, como hoje (a torre dentro do sótão, `atlas.gd`), desde que as faixas
  `y` se separem ou a ordem do registro diga quem ganha. O teste confere que todo ponto de
  sobreposição resolve para um cômodo só.
- **Um teste de rota genérico** no selftest anda da entrada de cada área até a meta da noite,
  pelos `links`, no lugar dos testes de rota escritos à mão para cada área.

### 12.2 A migração

A ordem fica com quem constrói, com uma regra: **cada passo deixa os 1093 testes de unidade e
os 282 do selftest verdes**. A sugestão é começar pelas áreas que já são arquivos (passagem,
sótão, gaveta, leste), depois tirar o tampo e a oficina do `main.gd` e deixar a casa por último,
porque é a maior.

## 13. Os sustos [Pedro, R3; regras: escolha da IA]

- **Tipos:** a lâmpada que queima perto; a figura que mudou de pose entre duas olhadas; a caixa
  de música que toca sozinha; o tique do relógio da entrada que para por um segundo; o duplo no
  espelho de mão; pancadas na porta barricada; a lanterna que pisca sem a pilha estar no fim.
- **Ritmo:** um diretor de sustos ligado à tensão que já existe. No máximo um susto forte por
  minuto. Silêncio de verdade entre eles: o susto só funciona se a casa ficar quieta antes.
- **Volume:** **sem estouro de volume** até Pedro decidir (é a única pergunta aberta, em
  `context/discussoes/rumo-2026-11.md#medo`). O susto vem do que se vê e do silêncio que se
  quebra, não do volume.
- **Nunca:** susto que tira o controle do jogador por mais de 2 s, exceto na captura; susto que
  fala; susto no 03:33.

## 14. Os assets [Pedro, R9, R13, R14; fluxo: escolha da IA]

### 14.1 A direção de arte

A originalidade vem de levar a sério que **tudo é maquete** [Pedro, R9: originalidade, não
polimento]. As texturas são realistas, mas **de maquete**, não de casa de verdade:

- madeira balsa com grão aberto e marcas de lixa;
- papelão nas paredes internas, com a borda do corte à mostra;
- papel de parede impresso, desbotado e descolando nas juntas;
- tinta à mão com pincelada visível, cola seca escorrida nos cantos, pregos e alfinetes;
- porcelana com craquelê nas figuras e nos Gastos;
- latão oxidado e aço azulado nos mecanismos;
- poeira que se acumula onde a mão de Inácio não chegava.

De perto, o jogador sempre percebe que está dentro de um objeto feito à mão. A oficina real,
pela janela, tem a escala e a textura de uma sala de verdade, e o contraste é parte do medo.

**Uma paleta por maquete:** a casa da rua do Porto em ocre, verde-musgo e creme; a relojoaria
em latão e veludo vinho; a mansão em ébano, cinza de falésia e azul de madrugada.

### 14.2 O fluxo

| Etapa | Onde | Regra |
|---|---|---|
| Origem | Poly Haven, ambientCG e outras fontes CC0; ou feito do zero no Blender | **só CC0 ou equivalente** [Pedro, R13]; custo zero |
| Bruto | `arte/fontes/` na raiz do repo, fora de `Janghyang/` | o download original, intocado |
| Edição | `arte/blender/<asset>.py`, rodado com `blender -b --factory-startup --python` | **toda edição é um script**, para o asset ser refeito e ajustado depois. Nada de `.blend` editado à mão sem script |
| Exportação | `Janghyang/assets/models/*.glb` e `Janghyang/assets/textures/` | glTF [Pedro, R14]; o Blender não entra no jogo exportado |
| Licença | `Janghyang/assets/LICENCAS.md`: arquivo, origem (URL), autor, licença, data e o que foi editado | registrada quando o asset entra [Pedro, R13]. Um teste de unidade falha se um arquivo em `assets/` não tiver linha |
| Uso | cada área carrega o `.glb` no `build` | se o asset faltar, a área cai para o bloco de hoje, para os testes headless continuarem rodando |

### 14.3 Limites do renderer

O renderer continua **GL Compatibility** [Pedro, R9: Forward+ não foi escolhido]. Isso exige:

- texturas de 1K, ou 2K só nos objetos que vão à mão (relógio, lupa, espelho);
- poucas luzes dinâmicas por objeto, com luz falsa pintada na textura onde der;
- **névoa volumétrica (`VolumetricFog`, `FogVolume`) não existe em Compatibility:** a névoa e a
  poeira no ar vêm da névoa de profundidade comum, de partículas e de planos com shader;
- **verificar no Godot 4.7.2**, antes de depender delas, as funções de suporte incerto em
  Compatibility: decalques, lightmaps assados e oclusão de ambiente. Se faltarem, a sujeira e a
  sombra de contato vão pintadas na textura.

### 14.4 O que vem primeiro (a demo)

1. O **relógio de bolso de Elias**, na mão: é o asset mais visto do jogo.
2. As **figuras e os Gastos** (manequim de porcelana, rosto rachado, mãos compridas), a partir
   de um manequim CC0 editado.
3. **Materiais da casa:** piso, paredes, forro, papel de parede, portas.
4. **Itens de mão:** lanterna, pilhas, fósforos, espelho, lupa, estetoscópio, giz, vareta,
   brinquedo de corda.
5. **Móveis da casa e do sótão**, os lençóis, o relógio da entrada.
6. As **engrenagens e o pêndulo** da torre.

## 15. A demo de 2027-04-15 [Pedro, R2; recorte: escolha da IA]

- **Conteúdo:** as noites 1 e 2 inteiras. São as áreas casa, passagem, sótão e torre, e os
  capítulos 1 a 4.
- **Por que essas duas:** juntas, contam uma história com começo e fim (Inácio criança,
  Inácio sabendo a hora da morte) e terminam num gancho: do alto da torre, Elias vê o próprio
  corpo na bancada, e o 03:33 da noite 2 mostra um eco que ainda não faz sentido.
- **Todas as onze ações** entram na demo, porque são o jogo. A relojoaria, a gaveta e a mansão
  ficam para depois.
- **A estrutura do §12 entra inteira na demo,** porque é o que faz as outras noites serem
  baratas de acrescentar.
- **A demo só sai se** [Pedro, R2: "desde que esteja pronto e com uma história jogável"]:
  - for jogável do começo ao fim sem travar, com o selftest verde;
  - tiver passado por **pelo menos três playtests humanos** (até hoje não houve nenhum),
    com as correções feitas;
  - um jogador de primeira vez nunca ficar mais de 3 minutos sem saber para onde ir;
  - a duração ficar entre 60 e 90 minutos.

**O maior risco** [leitura do OpenCode, adotada pela IA]: são cerca de 22 semanas até
2027-04-15 para construir onze mecânicas, a encenação, os assets e a estrutura nova antes de
provar, com gente jogando, que medo, busca e bússola funcionam juntos. Se o primeiro playtest
vier tarde, o retrabalho também vem tarde.

**A ordem que reduz o risco** [escolha da IA]:

1. o registro (§12) e a noite 1 jogável, com a bússola, a planta, a captura, a luz escassa, o
   giz, o escutar e o esconder, ainda em blocos;
2. o **primeiro playtest humano**, no começo de janeiro de 2027;
3. a noite 2, com as outras ações (consertar, âncora, lupa, espelho, barricar, isca);
4. os assets por cima do que já foi testado;
5. o segundo e o terceiro playtests.

## 16. Não-objetivos

- Combate, matar, armas, pontuação de mortes.
- Morte, game over, recomeçar a noite.
- HUD, minimapa, marcador de objetivo, barra de vida, grade de inventário na tela.
- Voz, narração ou texto fora do papel.
- O jogo completo em 2027-04-15.
- Trocar para Forward+.
- Assets pagos, artista contratado.
- Console, multijogador.

## 17. Anti-objetivos (fracasso mesmo funcionando)

- **A bússola resolve tudo:** o jogador anda com o relógio aberto e nunca explora. Se o
  playtest mostrar isso, o custo do tique sobe ou o relógio aponta com menos precisão.
- **Survival genérico:** a busca vira coleta de loot numa grade. Itens são poucos, raros e
  todos têm história.
- **Os Gastos viram inimigo de ação:** o jogador passa a enfrentá-los em vez de evitá-los.
  A vareta continua rara e cara em barulho.
- **Susto barato:** o mesmo susto duas vezes, ou sustos tão frequentes que viram ruído.
- **Asset de loja:** a casa fica parecendo um pacote genérico de casa mal-assombrada e perde a
  cara de maquete feita à mão.
- **A estrutura não cresce:** acrescentar a área seguinte exige mexer no `main.gd`.
- **A história vira leitura:** capítulos que só fazem sentido lendo muito texto. A encenação
  tem que contar sozinha, e a página só confirma.

## 18. Restrições

- Godot 4.7.2, GL Compatibility, viewport 1280×720.
- Tudo o que é jogo continua gerado em código. Os assets entram como `.glb` e texturas, mas a
  montagem das áreas é código.
- Modelos de dados em `RefCounted` carregados por `preload`, sem `class_name` (padrão atual).
- O Blender 4.5.15 LTS é ferramenta de produção, fora do jogo exportado.
- Custo financeiro zero [Pedro, R13].
- Os testes de unidade e o selftest ficam verdes a cada passo.
- Texto só em papel; a casa não fala; a porta da rua nunca tranca; nada acontece no 03:33.

## 19. O que fica com quem constrói

- A ordem da migração para o registro (§12.2) e o formato exato dos `DEF`.
- Teclas e mapeamento das ações novas, com as opções do `Esc` atualizadas.
- Todos os números do §9, do §10 e do §11, para afinar no playtest.
- A geometria dos três cômodos novos da mansão e a ponte do tampo até ela.
- Que fontes CC0 usar para cada asset, desde que a licença seja registrada.
- O desenho do diretor de sustos e a ligação com a tensão que já existe.
- O formato do save entre noites (sugestão: `user://`, como as opções).
- Como a planta guarda a névoa por célula.

## 20. Perguntas em aberto

| Pergunta | Default enquanto não fecha | Quem decide |
|---|---|---|
| Os sustos podem ter estouro de volume? | não | Pedro (revisar: 2026-11-22) |
| O conteúdo novo dos capítulos (§6.2) e a mansão como terceira maquete | como está aqui, à espera da leitura | Pedro |
| A demo leva as onze ações, ou só parte delas? Se faltar tempo, quais podem sair primeiro? | as onze, na ordem do §15; se faltar, saem antes a isca e a barricada | Pedro |
| As noites terminarem sempre num 03:33 curto | sim | Pedro |
