# FAZ DE CONTA — o relojoeiro (design)

- **Data:** 2026-10-27
- **Autor da direção:** Pedro Pompeu. Desenvolvimento: IA (Claude), em brainstorming com Pedro.
- **Base:** [`context/discussoes/modelo-arquitetural-dinamico-3d.md`](../../../context/discussoes/modelo-arquitetural-dinamico-3d.md)
  (design anterior do FAZ DE CONTA) + o conto em
  [`fontes/2026-10-27-pedro-conto-relojoeiro.md`](../../../fontes/2026-10-27-pedro-conto-relojoeiro.md).
- **Código existente:** blockout Godot 4.7.2 em `faz-de-conta/` (ver `faz-de-conta/README.md`).

Legenda: **[Pedro]** = decidido por Pedro nesta conversa. **[IA]** = proposta da IA que Pedro
aprovou. **[escolha da IA]** = decisão da IA ainda não revisada por Pedro.

---

## 1. Por que este documento existe

Pedro jogou o blockout e gostou do espaço. Nada o incomodou. O problema que ele apontou:
**"hoje ele só abre portas e mexe em objetos aleatórios, não tem uma história e nem um
objetivo"** [Pedro]. O design anterior dizia que o jogo não tinha objetivo e que a curiosidade
guiava. Isso foi inferência da IA, não pedido de Pedro, e o próprio documento listava "sem
objetivo" como risco.

Pedro trouxe um conto (Elias, catalogador do espólio do relojoeiro Inácio Varela) e pediu para
criar a partir dele, **junto com o FAZ DE CONTA**: **a maquete é uma peça do espólio** [Pedro].

Este documento junta as duas coisas e define o próximo slice jogável.

## 2. O jogo em uma frase

Você é Elias, contratado para catalogar o espólio de um relojoeiro morto. Ao dar corda no
relógio da maquete de uma casa, você passa a estar dentro dela. Você cataloga a casa por
dentro até descobrir o que aconteceu com Inácio, enquanto a casa grava tudo o que você faz e,
às 03:33, devolve tudo de uma vez.

## 3. O que vale do design anterior (continua de pé)

O que segue valendo do FAZ DE CONTA original:

- Single-player, primeira pessoa, contemplativo com tensão, horror doméstico e psicológico.
- **Sem competição, vitória, game over, dano, morte, combate, perseguição ou cronômetro visível.**
- **A porta da rua está sempre aberta e nunca tranca.** Sair é sempre possível.
- A casa ama e quer que você fique. Ela imita, devolve e guarda. Não caça.
- O **sistema de espelho** da casa (contar o verbo do jogador e devolvê-lo com um grau de
  erro), o roteiro de som de oito pontos com gêmeos visuais, a regra "um gesto por vez" e a
  rede de segurança sem falha. Ver `#comportamento` e `#som` no documento base. Essas tabelas
  continuam como referência de implementação.
- A casa não fala. Ela responde por som, luz e movimento.
- Estética de maquete 1:20 (basswood, tecido, latão, papelão), sem trilha e sem susto alto.
- O espaço do blockout atual (cômodos, laço, F1–F4, portas). Pedro: "não tem nada que me
  incomoda, gostei".

## 4. O que muda

| Antes | Agora |
|---|---|
| Sem história; o jogador é "você" | O jogador é **Elias**, catalogador contratado [Pedro] |
| Sem objetivo; curiosidade como bússola | Objetivo: **catalogar a casa e descobrir a verdade sobre Inácio** [Pedro] |
| Sem texto | Existe texto **apenas em objetos**: diários de Inácio e o caderno de Elias. A casa continua sem falar [escolha da IA] |
| A maquete é a casa e pronto | A maquete é **peça do espólio** de Inácio [Pedro] |
| Ateliê de um arquiteto pelas janelas | A **oficina da mansão de Inácio** pelas janelas. A mansão em escala real **não é jogável** [Pedro] |
| O boneco é "uma cópia sua" | O boneco é o **duplo de Elias** (o do conto), em escala de brinquedo [IA] |
| As figuras são moradores anteriores | As figuras são **versões antigas de Inácio** e de **catalogadores anteriores** [IA] |
| Escalada lenta, sem evento central | **03:33**: o relógio da maquete para e a casa devolve seus ecos [Pedro] |
| Fim: sair ou ficar | Fim: sair **com a verdade** e escolher se o relógio fica com corda [IA] |

## 5. A história

### 5.1 O que o jogador sabe no início

Elias foi contratado por carta para catalogar o espólio de Inácio Varela, relojoeiro recluso,
numa mansão nas falésias. O jogo **começa dentro da maquete** [Pedro]: Elias acaba de dar corda
no relógio do telhado dela e está de pé na entrada, em escala de brinquedo. Pela janela se vê a
oficina enorme, a bancada e a chuva das falésias.

O jogo não explica como Elias entrou. O caderno dele começa com a última entrada escrita
antes: "Item 214 — maquete de casa sob redoma, relógio no telhado, parado. Dei corda para
testar o mecanismo." [escolha da IA]

### 5.2 A verdade sobre Inácio [IA, aprovada por Pedro]

Na ordem em que o jogador a descobre:

1. **Inácio estava morrendo** e sabia a hora exata: **03:33**. Ele lia a falha sob a mansão. Os
   relógios-âncora do conto começaram como uma forma de adiar esse minuto.
2. **A maquete é a casa da infância dele,** não a mansão. Por isso tem quarto de brincar, bola,
   cabana e caixa de música. O relógio no telhado foi feito para nunca chegar às 03:33. O nome
   do jogo vem daí: fazer de conta que ainda é criança e que não vai morrer.
3. **Ele entrou e deu certo, mais ou menos.** Não morreu, mas o relógio se desgasta. A cada
   03:33 ele revive a própria morte, dá corda e recomeça. Isso se repetiu milhares de vezes, e
   os ecos dele se acumularam até virar a casa. **A casa é Inácio**, sozinho há décadas. É por
   isso que ela brinca, imita e ama sem limite.
4. **As figuras de escala** são as versões mais antigas dele, gastas até virarem bonecos. São os
   sussurros do conto.
5. **Catalogadores anteriores** foram atraídos pela casa. A carta que contratou Elias está na
   letra de Inácio e tem **data de depois da morte dele**. Algumas figuras não são Inácio.
6. **O duplo de Elias** é o mesmo processo começando com ele.

O que se diz em voz alta (frase final para o jogador, nunca falada pela casa): **"eu sou o
próximo Inácio"**, e a porta continua aberta.

### 5.3 O fim [IA, aprovada por Pedro]

O jogador sai pela porta com a verdade. Antes de sair, ele decide:

- **Deixar o relógio com corda:** Inácio continua vivo, sozinho, esperando o próximo catalogador.
- **Deixar o relógio parar:** Inácio finalmente chega às 03:33.

Nenhuma das duas é vitória. É uma decisão entre misericórdia e companhia.

**O que acontece com Elias: "algo dele fica para sempre na maquete" [Pedro].**

O corpo de Elias acorda na bancada e ele vai embora. Mas o **duplo e os ecos dele ficam na
maquete**: ele virou uma figura, como os catalogadores anteriores. Por isso a escolha do
relógio pesa sobre os dois. O que fica de Elias tem um destino ou outro, e em nenhum dos dois
ele volta [escolha da IA a partir da resposta de Pedro]:

- **Com corda:** Inácio continua vivo e **não está mais sozinho**. O pedaço de Elias vira
  companhia, em loop, para sempre.
- **Sem corda:** Inácio chega às 03:33 e tudo para. O pedaço de Elias **fica parado junto**,
  para sempre, no último minuto de Inácio.

**O que o duplo escreve no caderno durante o 03:33:** Elias catalogado como peça, no mesmo
tom das entradas do jogador. Exemplo: "Item 240 — catalogador. A mão direita gasta de um lado
só." [escolha da IA]

**Imagem final:** Elias, em escala real, olha para a maquete pela redoma. Há uma figura nova
sentada lá dentro, com o rosto dele e um caderno no colo. A última entrada do caderno muda
conforme a escolha. Os textos são exemplos de tom [escolha da IA]:

- **Com corda:** "Item 214 — maquete de casa. Dei corda. Dentro, uma figura nova. Ele não está
  mais sozinho."
- **Sem corda:** "Item 214 — maquete de casa. Deixei parar às 03:33. As figuras pararam de
  olhar para mim. A minha não."
- **Saída antes do fragmento 3,** sem escolha: o relógio segue com a corda que tinha.
  "Item 214 — maquete de casa. Funciona. Não sei por que há uma figura a mais." Os ecos já
  gravados ficam do mesmo jeito.

## 6. Como se joga

### 6.1 O loop

**Entrar → catalogar uma peça → a peça abre um fragmento da verdade → a casa responde e
grava → o relógio corre → 03:33 → ver os ecos → seguir catalogando ou sair.**

O verbo novo é **catalogar**. Os verbos antigos (dobrar, bater, rolar, olhar, esconder o
boneco, parar) continuam sendo brinquedos. São também o material que a casa vai gravar e
devolver.

### 6.2 Catalogar e o caderno [escolha da IA]

- Elias carrega um **caderno de catálogo**. `E` interage como hoje. Uma interação nova
  (sugestão: `Q` ou segurar `E`) **cataloga** a peça que está na mira.
- Catalogar é **examinar**: a câmera chega perto, Elias escreve uma linha curta no caderno
  ("Item 231 — bola de madeira, faia, gasta de um lado só"). Algumas peças revelam uma
  **página do diário de Inácio** ligada a elas.
- O caderno abre com uma tecla (sugestão: `Tab`) e mostra as entradas escritas e as páginas de
  diário encontradas. É o **único lugar com texto**, sempre como objeto do mundo (papel,
  caligrafia), nunca como HUD sobreposto.
- **Não há contador "x de y"**, checklist ou marcador de objetivo. O caderno tem páginas
  numeradas em branco à frente, e é isso que diz ao jogador que há mais para encontrar.
- Algumas peças só podem ser catalogadas **depois** de uma brincadeira. A cabana só aparece
  como item depois de dobrada; o boneco só depois de virado. Assim o objetivo puxa o jogador
  para os brinquedos em vez de competir com eles.

### 6.3 O relógio da maquete [escolha da IA]

- Existe **um relógio grande na entrada da maquete**, o eco do relógio do saguão no conto, ao
  lado da porta da rua.
- Ele **corre durante a visita** e o jogador pode **dar corda** nele (interação). Dar corda é
  sempre possível e sempre funciona. O custo é que **cada corda dura menos** que a anterior.
- O relógio é o único "tempo" do jogo e é diegético: ponteiros visíveis, tique-taque audível
  (som 9, ver 6.6). Não há cronômetro na tela.
- **03:33 chega de qualquer jeito** no slice. A corda adia, não impede. No slice, o 03:33
  acontece **uma vez**, num ponto controlado pelo progresso (ver 7).

### 6.4 O 03:33 [Pedro: entra, sem perseguição; o central é "a estranheza de ver a si mesmo repetido"]

Quando o relógio para:

1. **Silêncio.** Todo o som da casa corta por ~2 s. Só fica a respiração do jogador e a chuva
   distante, abafada.
2. **Os ecos.** A casa gravou **tudo o que Elias fez desde que entrou**: trajetória, para onde
   olhava, o que tocou, dobrou, abriu, onde parou ou se agachou. Agora **várias versões de Elias
   reaparecem ao mesmo tempo**, cada uma refazendo um trecho dessa gravação em loop. Quem passou
   dez minutos na cabana encontra várias versões de si agachadas lá dentro. Quem correu pelo
   corredor vê uma fila de si mesmo correndo. **É o coração do jogo.** O horror vem do que o
   próprio jogador fez.
3. **O tempo anda para trás** em detalhes: a bola rola de volta, uma dobra se desfaz sozinha, a
   poeira sobe.
4. **As coisas das frestas.** Algumas figuras (dentes de porcelana, ponteiros enferrujados)
   aparecem nos cantos. **Não se aproximam**, não seguem, não bloqueiam. A cada vez que o
   jogador olha de novo, estão em outro lugar, sempre longe.
5. **O duplo** (o boneco de Elias) está sentado com o caderno, **escrevendo na letra de Elias**.
   Depois do 03:33 o caderno tem entradas que o jogador não escreveu.
6. **Dar corda de novo** no relógio da entrada encerra o 03:33. Os ecos param onde estão e
   **ficam como figuras imóveis** na casa pelo resto da visita.

**Regras duras do 03:33:**

- Nenhum eco, figura ou duplo **se move em direção ao jogador** de forma intencional, toca o
  jogador ou bloqueia o caminho até a porta.
- Os ecos **só repetem o que o jogador fez**. Eles nunca inventam um gesto. É a mesma regra do
  sistema de espelho.
- A porta da rua continua aberta durante o 03:33.

### 6.5 Como a verdade chega

| Fragmento | Onde mora (proposta) |
|---|---|
| 1. Inácio sabia a hora da morte | página de diário ao catalogar o relógio da entrada |
| 2. A maquete é a casa da infância | desenho infantil no quarto de brincar + página ligada à caixa de música |
| 3. Ele entrou e virou a casa | página encontrada **depois do 03:33**, na cabana, ao lado dos ecos de Elias |
| 4. As figuras são versões dele | catalogar as figuras sentadas: as que são Inácio têm o mesmo relógio de bolso |
| 5. Catalogadores anteriores e a carta | uma figura **sem** relógio de bolso tem um caderno igual ao de Elias; a carta de contratação, com data posterior à morte, está dentro dele. Catalogadores anteriores viram figuras, não viram Inácio [escolha da IA] |
| 6. O duplo é você começando | as entradas escritas pelo duplo no caderno durante o 03:33 |
| Pelas janelas | a oficina real: em algum momento, Elias vê **o próprio corpo sentado na bancada**, imóvel, com a mão na corda da maquete [escolha da IA] |

O jogador não precisa encontrar tudo para sair. A porta sempre funciona. Quem sai cedo sai
com uma verdade incompleta. A escolha final (6.7) só aparece para quem chegou ao fragmento 3
[escolha da IA].

### 6.6 Som

Vale o roteiro do documento base (oito pontos, três camadas, silêncio como material, sem
sting). Acrescentar:

| # | Objeto | Camada física | O que a casa devolve |
|---|---|---|---|
| 9 | **Relógio da entrada** | tique-taque de latão, audível na casa toda, mais alto perto | o tique se dessincroniza da animação conforme a corda acaba; às 03:33, para |
| 10 | **Ecos de Elias** | passos, cliques e dobras do jogador, já gravados | tocam todos juntos, levemente fora de tempo entre si |
| 11 | **Escrita do duplo** | lápis no papel | o mesmo ritmo de escrita de quando o jogador catalogou |

### 6.7 O fim, na prática [escolha da IA]

- Quando o jogador chega à porta da rua depois do fragmento 3, o relógio da entrada está
  quase sem corda.
- **Dar corda e sair** = Inácio continua. **Sair sem dar corda** = o relógio para atrás dele
  e Inácio chega às 03:33.
- Ao sair, a câmera atravessa a porta para a oficina em escala real (só uma imagem, não
  jogável). Ela fecha com a **última entrada do caderno**, que muda conforme a escolha. É a
  única tela de fim. Não há "fim de jogo", nota ou créditos de vitória.

## 7. O slice a construir

**Objetivo do slice:** uma visita completa, com começo, 03:33, verdade e escolha, de **20 a
30 min**, no espaço do blockout atual [escolha da IA: o slice é um arco completo e curto, não
um pedaço do meio].

| Bloco | Tempo aprox. | O que acontece |
|---|---|---|
| Chegada | 0–3 min | entrada, relógio, caderno, janela para a oficina, porta aberta; primeira catalogação |
| Brincar e catalogar | 3–12 min | quarto de brincar, dobra, cabana, bola, caixa de música; a casa devolve gestos (sistema de espelho); fragmentos 1–2 |
| O duplo | 12–16 min | quarto de dormir, boneco de Elias, espelho; o relógio fica sem corda mais rápido |
| 03:33 | 16–20 min | o relógio para; ecos, coisas das frestas, duplo escrevendo; dar corda encerra |
| Depois | 20–28 min | figuras, carta, fragmentos 3–5; casa cheia de ecos imóveis |
| Escolha | 28–30 min | porta, relógio, corda ou não, saída |

**Gatilho do 03:33:** depois de o jogador ter catalogado **o boneco** e mais um número mínimo de
peças, ou depois de um tempo máximo de visita, o que vier primeiro. A corda que o jogador dá
antes disso adia minutos, não o evento [escolha da IA].

**O espaço [escolha da IA, a partir de "começa dentro da maquete, mansão só pelas janelas"]:**

- O jogador **nasce na entrada**, do lado de dentro. Hoje ele nasce no ateliê, em
  `main.gd`.
- O **ateliê do blockout continua existindo** com a mesma geometria, mas passa a ser **o lado
  de fora da maquete**: o tampo da bancada de Inácio, dentro da redoma. Atrás do vidro da
  redoma, em escala gigante, fica a oficina, que não é jogável. O strip oeste que F1 revela é
  o mesmo tampo. As janelas da casa dão para esse tampo e para a oficina ao fundo.
- **Passar pela porta da rua não encerra o jogo.** Pisar no tampo é reversível, e o jogador
  pode voltar, como no documento base. A saída de verdade é chegar à **beira do tampo**, um
  gatilho no fim do ateliê, que dispara o fim (6.7). O laço do autoteste passa a começar
  na entrada.

**Sistema de espelho no slice [escolha da IA]:** entra só o subconjunto que **não muda a
planta**:

- **Entra:**
  - a casa devolve a **dobra** nas F1–F4 que já existem;
  - a **bola** rola como convite;
  - **bater** na parede, um verbo novo e barato: a casa responde com a mesma contagem;
  - o **boneco/espelho**: reflexo atrasado, o boneco muda de pose.
- **Fica fora:** corredor que alonga, portas que mudam de lugar, a "porta nova" (a sala das
  figuras já existe) e cantarolar (que depende de microfone).
- Os critérios de sucesso pedem que a casa tenha devolvido **ao menos dois gestos** antes do
  03:33.

**Pendências do blockout fechadas por este design:**

- **Cabana do F1 (`achados#a-001`):** precisa ser **entrável**. A imagem de "várias versões de
  você agachadas na cabana" depende disso. O controlador ganha **agachar** (sugestão: `Ctrl`
  ou `C`) [escolha da IA].
- **Porta dos fundos (`achados#a-003`):** fica **abrindo para o corredor**, como está. Pedro
  jogou e não se incomodou [escolha da IA a partir do "nada me incomoda" de Pedro].

## 8. Critérios de sucesso do slice

Ao fim, um jogador de teste consegue dizer, sem ajuda:

1. "Eu estava catalogando a casa": o objetivo foi entendido sem marcador.
2. "Eu vi a mim mesmo fazendo o que eu fiz": os ecos foram reconhecidos como **dele**.
3. Uma frase próxima de "Inácio entrou na maquete e virou a casa", pelo menos para quem
   chegou ao fragmento 3.
4. "A escolha do relógio foi minha."
5. "Em nenhum momento algo veio atrás de mim."

E tecnicamente: a porta da rua funciona em qualquer minuto, inclusive durante o 03:33; o
autoteste de circulação continua passando com os ecos imóveis na casa.

## 9. Não-objetivos

- Mansão em escala real jogável.
- Mais cômodos que os do blockout.
- Arte final. O slice continua sendo blockout com primitivas, agora com som e comportamento.
- Microfone (cantarolar ou respirar de verdade).
- Save entre sessões e múltiplas noites. O jogo completo terá várias visitas, mas o slice é
  uma só.
- Dublagem ou narração.

## 10. Anti-objetivos (fracasso mesmo que funcione)

- **Algo caça o jogador.** Qualquer eco ou figura que pareça seguir, encurralar ou dar susto de
  proximidade quebra a decisão de Pedro.
- **Os ecos parecem genéricos.** Se o jogador não reconhece o próprio caminho e os próprios
  gestos, o centro do jogo some.
- **A verdade chega como despejo de texto.** Páginas de diário curtas (poucas linhas cada),
  nunca uma carta de duas páginas explicando tudo.
- **O catálogo vira checklist** de "encontre 30 itens" com contador.
- **A casa fala** com texto, voz ou legenda.
- **A porta tranca**, mesmo que por um instante.
- Gore, jump scare ou sting alto.

## 11. Restrições

- Godot **4.7.2**, renderer GL Compatibility, projeto em `faz-de-conta/`. Hoje a geometria é
  gerada por `scripts/main.gd`.
- **Sem novas dependências, plugins ou middleware de áudio** sem validação prévia de Pedro.
- O autoteste headless (`godot --headless --path . -- --selftest`) continua verde e ganha
  checagens novas para o que for construído.
- Ao concluir, rodar `python lint.py` e registrar decisões, achados e arquitetura em `context/`
  conforme o protocolo do projeto.
- O diretório não é um repositório Git.

## 12. O que fica com quem constrói

- Como gravar e reproduzir os ecos: taxa de amostragem, quantos ecos simultâneos, como fatiar a
  gravação em trechos e como representar visualmente cada versão de Elias (silhueta,
  manequim, transparência). Restrição: precisam ser reconhecíveis como "eu".
- Como gerar ou obter os sons de protótipo dentro da restrição de dependências.
- Teclas exatas para catalogar, abrir o caderno e agachar.
- Visual do caderno e das páginas de diário (desde que sejam objetos do mundo, não HUD).
- Quantas peças são catalogáveis e o texto exato das entradas e das páginas de diário,
  respeitando a ordem dos fragmentos em 5.2 e o limite de poucas linhas por página.
- Ajuste fino de tempos: duração da corda, gatilho do 03:33, duração do evento.
- Como as coisas das frestas se reposicionam fora da linha de visão, respeitando as regras
  duras de 6.4.
