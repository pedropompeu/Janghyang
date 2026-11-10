# Janghyang — a noite 1 refeita: mais desafio, mais horror, mais susto (design)

- **Data:** 2026-11-10
- **Direção:** Pedro Pompeu. Desenvolvimento e arte: IA (Claude).
- **Base:** [`2026-11-08-janghyang-direcao-design.md`](2026-11-08-janghyang-direcao-design.md)
  (o spec do jogo). Este documento **refaz só a noite 1**. O que não for dito aqui continua
  valendo de lá.
- **Decisões de origem:** `context/decisoes.md#noite-1-2026-11-10`.
- **Toca no plano:** `docs/superpowers/plans/2026-11-08-janghyang-demo.md`. A Tarefa 26
  (playtest 1) passa a esperar esta noite; o plano de construção desta noite vem depois da
  aprovação deste documento.

Legenda: **[Pedro]** = decidido por Pedro em 2026-11-10. **[escolha da IA]** = proposta da IA
que Pedro ainda não revisou; pode ser trocada sem custo antes do plano.

---

## 1. Por que este documento existe

A noite 1 de hoje fecha em 81 s para quem sabe o caminho. As cinco pistas estão todas na
entrada e na sala de brincar, o painel pode ser quebrado antes de a cena acabar, nenhum Gasto
aparece antes da coroa e, depois dela, a volta é uma caminhada curta seguida de uns 40 s
parado, esperando o 03:33. Quatro cômodos da casa só guardam pilhas e velas.

Pedro pediu **"mais desafios, mais horror e mais sustos"** na noite 1 e aprovou os doze itens
propostos com **"pode fazer todos, sem estouro de volume"**. Este documento põe os doze itens
na ordem da noite, diz onde cada um cai no código e separa o que Pedro decidiu do que a IA
escolheu.

## 2. A noite em uma frase

Elias procura as pistas por uma casa que escurece e se rearruma pelas costas dele, ouve
alguma coisa atrás da parede a noite inteira, abre essa parede com as próprias mãos e
descobre que soltou o que estava lá dentro.

## 3. Objetivos, não-objetivos e anti-objetivos

**Objetivos**

1. A noite 1 usa a casa toda: toda pista fica atrás de um obstáculo e cada cômodo do térreo
   tem uma razão para ser visitado.
2. O medo começa no primeiro minuto e cresce até o fim. Não existe mais trecho em que nada
   ameaça.
3. A noite ensina, sem texto fora do papel, quatro ações antes de precisar delas: fósforo e
   vela, escutar pela parede (`L`), esconder-se e prender a respiração (`H`).
4. Um jogador de primeira vez continua sem passar de 3 minutos sem saber para onde ir (spec
   §15).

**Não-objetivos**

- Mexer nas noites 2 a 5, nos capítulos (títulos, hipóteses, páginas do diário) ou na ordem
  das peças do relógio.
- Novas áreas. Tudo acontece na casa (`casa`) e na passagem (`passagem`).
- Novas ações de jogador. A noite usa as que já existem; só "olhar pela fresta" e "usar a
  chave" entram como interações de objeto (`E`).

**Anti-objetivos** (o que faria a noite fracassar mesmo funcionando)

- Susto com estouro de volume. **[Pedro]**
- O mesmo susto duas vezes na noite, ou um susto que vira rotina.
- O Gasto virar inimigo de ação: correria, combate, reflexo. A ferramenta do jogador continua
  sendo **olhar**.
- Uma captura que o jogador não tinha como evitar.
- O jogador perdido por culpa de um obstáculo que não se explica sozinho.

## 4. Regras que continuam valendo

- Texto só em papel; a casa não fala; nenhum susto com voz.
- Nada acontece durante o 03:33.
- Sem morte, sem game over. Ser pego custa tempo (R11).
- Os Gastos só se movem sem ser vistos; sob a luz, giram mas não andam
  (`decisoes#gira-nao-anda`).
- A porta da rua nunca tranca e nenhuma figura a bloqueia (`keep_clear: [&"DoorFront"]`).
- Nenhum susto tira o controle por mais de 2 s; a captura é a única exceção.
- Sem HUD, sem minimapa, sem marcador.
- Custo zero, assets CC0, Blender por script; GL Compatibility; modelos `RefCounted` via
  `preload`, sem `class_name`.
- Testes de unidade, selftest e lint verdes em cada passo.
- Conteúdo de área mora no `DEF` da área (R6): acrescentar o que este documento pede não deve
  exigir casos especiais no `main.gd`.

## 5. O que muda nas regras

| Regra | Antes | Agora |
|---|---|---|
| **R12 na noite 1** **[Pedro]** | A casa inteira é segura a noite toda; nenhum Gasto entra no térreo. | A casa é segura **até o painel quebrar**. Depois, o único ponto seguro é o raio do relógio da entrada. |
| **D10** **[Pedro]** | Em aberto, default "não". | **Fechada: sem estouro de volume.** `MAX_DB = 0` no `scare_director.gd` passa de default a regra. |
| **Quando o Gasto entra** **[escolha da IA]** | Depois da coroa. | Quando o painel quebra (§6.5). |
| **O painel** **[escolha da IA]** | Pode ser quebrado antes do fim da cena. | Só cede depois da última pose da cena do capítulo 1. |

## 6. A noite, na ordem

Os números entre parênteses são os doze itens aprovados (§7).

### 6.1 Abertura: a luz de fora apaga (6)

Elias acorda na entrada com a carta, como hoje. Quando ele guarda a carta, a lâmpada gigante
da bancada da oficina se apaga: a luz quente que entrava pelas janelas some, os vidros ficam
pretos e a casa escurece. Sobra acesa só a lâmpada da sala de brincar, como hoje. O som é um
clique grave e distante de interruptor, e depois silêncio.

O apagão deixa de ser um efeito da casa e passa a ter causa: alguém, lá fora, apagou a luz.

### 6.2 O capítulo 1 espalhado pela casa (1, 4, 5, 8, 11, 12)

As três pistas do capítulo 1 saem da sala de brincar. O relógio de bolso aponta para cada
uma, em ordem **[escolha da IA]**: relógio da entrada, desenho, casinha.

**Relógio da entrada.** Fica onde está. É a primeira pista, a dois passos de onde Elias
acorda, e é o lugar para onde ele vai voltar correndo no fim.

**A bola (8).** No caminho para o quarto, quando Elias chega pela primeira vez à boca do
corredor escuro, a bola de madeira vem quicando de dentro do escuro e para aos pés dele.
Ninguém a jogou. É assim que a pista `bola` é encontrada. O som são os quiques de madeira,
cada um mais fraco que o anterior.

**O desenho no quarto, que só a chama mostra (1).** O desenho de Inácio vai para a parede
acima da cama. Sob a lanterna o papel parece em branco: é lápis de cera, e a luz fria o
apaga. Sob um fósforo ou uma vela, a cera brilha e o desenho aparece. Só então dá para
catalogar. Na mesa de cabeceira, logo abaixo do papel, ficam uma caixa de fósforos e um toco
de vela já queimado: é a dica, sem texto. **[escolha da IA]** O fósforo dura 20 s; quem demora
precisa de outro.

**O reflexo que fica (12).** O espelho do quarto mostra Elias, como hoje. Depois que o
desenho é catalogado, com a chama ainda acesa, Elias sai da frente do espelho e o reflexo
**não sai**: continua lá, de pé, e vira a cabeça para acompanhá-lo. Some quando Elias volta
para a frente do espelho ou sai do quarto. Sem som.

**A sala das figuras e a casinha trancada (1, 4).** A casinha vai para a sala das figuras,
dentro de um armário de porta de vidro, trancado. Dá para ver, não dá para pegar. Na mesma
sala, num banco comprido contra a parede, estão **sete figuras de porcelana sentadas lado a
lado**. Do armário sai um rastro de giz do menino (visível de olhos fechados, como os outros)
que atravessa a casa e termina debaixo da almofada da cabana, onde está a chave.
**[escolha da IA]** A cabana é um esconderijo: o rastro leva o jogador a entrar num
esconderijo antes de precisar de um.

**O banco esvazia (4).** Cada vez que Elias volta à sala das figuras, falta uma figura no
banco. A que saiu está em algum lugar da casa: sentada na cama do menino, de pé no fim do
corredor, virada para a parede num canto da sala de brincar. Elas nunca são vistas se
movendo. Quando Elias não está olhando, a cabeça de cada uma vira para onde ele está.

**Atrás da parede (5, 11).** Desde o primeiro minuto há alguma coisa na passagem, atrás da
parede norte da sala de brincar. Quem encosta e segura `L` ouve: o tique abafado de porcelana
que já existe e, por baixo, algo que se arrasta e **para quando Elias para de escutar**. A
parede tem uma fresta. Na primeira olhada, só escuro e uma forma pálida, longe. Na segunda
olhada, mais tarde na noite, um olho de porcelana está encostado na fresta, olhando de volta.
Não pisca, não recua. Quando Elias solta e olha de novo, não há nada.

### 6.3 A cena ensina a saída (regra nova do painel)

Com as três pistas catalogadas, a cena do capítulo 1 acontece na sala de brincar, em quatro
poses, como hoje. A diferença: **o painel só cede depois da última pose**, e a última pose é o
menino encostado no painel, com a mão espalmada na madeira. A cena passa a ser a instrução.
Antes disso o painel soa oco, mas não quebra.

### 6.4 Cara a cara no painel (9)

Quando a madeira cede, há uma figura de pé exatamente atrás dela, a um palmo do rosto de
Elias, parada porque está sendo vista. Sem som além da madeira quebrando. Para entrar na
passagem, Elias precisa se abaixar, passar por ela e **dar as costas**.

É a mesma coisa que ele ouviu a noite toda e a dona do olho na fresta.

### 6.5 A casa deixa de ser segura (3)

A figura do painel é o Gasto da noite 1. **[escolha da IA]** Como funciona:

- Enquanto Elias está a menos de 3 m dela, ela não o agarra: gira a cabeça, e só. Sem isso, o
  susto do painel terminaria sempre em captura.
- Quando Elias se afasta pela passagem e olha para trás, o buraco do painel está vazio. Ela
  saiu para a casa.
- A partir daí, a segurança da noite muda de `casa_toda` para **só o raio de 4 m do relógio
  da entrada**. Quem voltar à casa antes da coroa (para buscar fósforo, por exemplo) já
  encontra um Gasto solto nela.
- O jogador não é avisado. Descobre quando vê uma figura onde não havia nenhuma.

### 6.6 A passagem: a caixa de música e o beco (1, 2, 10)

A passagem tem 10 m de comprimento, 1,3 m de largura e 1,3 m de altura. O painel fica mais ou
menos no meio. A coroa está no fundo oeste, sem saída. O poço que sobe para o sótão, no fundo
leste, fica fechado na noite 1, de modo que o painel é a única saída.

**A caixa de música (1).** Sai da sala de brincar e vai para o lado leste da passagem, num
vão entre os caibros, fora da linha de visão de quem engatinha. Ela toca sozinha: alguns
segundos de melodia, que param sempre na mesma nota, e um silêncio mais longo. O relógio
aponta para a coroa, a oeste; o som vem do leste. Achar a caixa pede parar no escuro e
esperar a próxima vez que ela tocar.

**A cena do capítulo 2.** Com a bola e a caixa catalogadas, a cena acontece como hoje: o
menino engatinha para oeste e se ajoelha ao lado da coroa.

**O beco (2, 10).** No meio do caminho até a coroa há um nicho na parede norte, o esconderijo
do menino: uma almofada e riscos de giz. Elias passa por ele na ida. Quando pega a coroa, no
fundo do beco:

1. A lanterna pisca e apaga por um instante. Quando volta, há uma figura na passagem, perto
   do painel, entre Elias e a saída.
2. A cada piscada ela está mais perto. O escuro conta como "não vista".
3. Não há espaço para passar por ela. A saída é voltar até o nicho, entrar e **prender a
   respiração** (`H`) enquanto ela passa em direção ao fundo do beco.
4. Com ela às costas, Elias sai do nicho e engatinha até o painel. Olhar para trás a congela;
   andar sem olhar a deixa vir.

A ida, o nicho e a volta precisam caber num fôlego (8 s) com folga para quem nunca prendeu a
respiração. Se o jogador for pego, vale a captura de sempre (R11): cliques para se soltar e,
se não se soltar, acorda no ponto seguro, com a coroa.

### 6.7 A travessia (3, 4)

Do painel ao raio do relógio da entrada são uns 9 m, dos quais 5 fora de qualquer lugar
seguro. O banco da sala das figuras já está quase vazio: há figuras de pé pela sala de
brincar e pela boca do corredor. Todas param quando vistas. Uma delas é o Gasto, que saiu da
passagem atrás de Elias; as outras não fazem nada. **O jogador não tem como saber qual é**
só de olhar: descobre qual chegou mais perto quando olha de novo.

### 6.8 A vigília

Dentro do raio do relógio, Elias está seguro e espera a hora de dar corda, como hoje. A
espera deixa de ser vazia: cada vez que ele desvia o olhar, as figuras estão um pouco mais
perto, até pararem em roda na beira do raio, de frente para ele. Nenhuma entra, e a porta da
rua fica livre. Quando o 03:33 começa, vale a regra: nada acontece. **[escolha da IA]**

### 6.9 O catálogo muda sozinho (7)

Quando Elias cataloga o banco da sala das figuras, a entrada diz "sete figuras de porcelana".
Depois que uma figura sai, na próxima vez que o caderno é aberto a mesma entrada diz "seis",
na letra dele, sem rasura. Acontece **no máximo duas vezes na noite**, e só com o caderno
fechado. **[escolha da IA]** A proposta aprovada dava o exemplo "duas viram três"; aqui o
número acompanha o banco, para que o caderno confirme o que o jogador acha que viu.

## 7. Os doze itens e onde cada um cai

| # | Item | Onde na noite | Onde no código |
|---|---|---|---|
| 1 | Pista atrás de obstáculo | §6.2, §6.6 | `areas/casa.gd` (`DEF.catalog`, `pickups`, `chalk`), `areas/passagem.gd`, `main.gd` ~688–691 (as posições saem de lá para os `DEF`), `catalog.gd` (catalogar o desenho exige chama) |
| 2 | O beco de 1,3 m | §6.6 | `areas/passagem.gd` (nicho, `_hideout`), `gastos.gd` (ponto de nascimento), `noise_model.gd`, `stalker_model.gd` |
| 3 | A casa deixa de ser segura | §6.5, §6.7 | `story/noites.gd` (`safety`, `stalkers`), `safety_model.gd` |
| 4 | O banco esvazia | §6.2, §6.7 | modelo novo + `areas/casa.gd` (`DEF` do banco e dos lugares), `figure.gd`, `mannequin.gd`, `staging_model.gd` |
| 5 | Presença atrás da parede | §6.2 | `listen_model.gd`, `sfx_bank.gd`, `areas/casa.gd` (a fresta) |
| 6 | A luz de fora apaga | §6.1 | `main._house_goes_dark`, `areas/tampo.gd` (a lâmpada da bancada), `mat_window` |
| 7 | O catálogo muda | §6.9 | `catalog_data.gd`, `catalog.gd`, `double_writer.gd` |
| 8 | A bola quica | §6.2 | `ball.gd`, `areas/casa.gd`, `dread.gd` |
| 9 | Cara a cara no painel | §6.4 | `areas/passagem.gd` (`breaks`), `chapter_model.gd`, `gastos.gd` |
| 10 | Lanterna que pisca no beco | §6.6 | `light_model.gd` (`flicker`), `dread.gd` (`lanterna_pisca`), `stalker_model.gd` |
| 11 | O olho na fresta | §6.2 | `crack_thing.gd`, `crack_placement.gd`, `dread.gd` |
| 12 | O reflexo que fica | §6.2 | `house_mirror.gd`, `mirror_reflection.gd`, `dread.gd` (`duplo_espelho`) |

## 8. O que precisa existir de novo

1. **Segurança em degraus dentro da noite.** Hoje `safety` é uma regra só por noite. Precisa
   aceitar degraus como `stalkers` já aceita (`[{"after": &"", ...}, {"after":
   &"achar_passagem", ...}]`) e uma regra nova: seguro só a `ANCHOR_RADIUS` do relógio da
   entrada. As noites 2 a 5 continuam com a regra única de hoje.
2. **Ponto de nascimento e adormecimento do Gasto.** O degrau de `stalkers` ganha onde o Gasto
   nasce (atrás do painel) e a regra de §6.5: não agarra enquanto Elias estiver a menos de 3 m
   do painel recém-quebrado, e sai para a casa quando ele se afasta sem olhar. Depois da coroa, ele reaparece na passagem, perto do painel, sem
   ser visto chegando.
3. **O banco de sete figuras.** Um modelo puro que decide qual figura sai, para onde vai e
   quando: só sem ser vista, nunca dentro de Elias (A-031), nunca num esconderijo, nunca na
   porta da rua, no máximo uma mudança por visita à sala. As figuras do banco e o Gasto da
   noite usam o mesmo corpo, para a travessia de §6.7 funcionar.
4. **A fresta.** Uma interação de segurar (`E`) na parede norte da sala de brincar. Segurar
   mantém o olhar; soltar devolve. O controle nunca é tirado.
5. **O armário trancado e a chave.** Um objeto que bloqueia um alvo de catálogo até uma chave
   ser pega. A chave é um estado da noite, não um item de mão.
6. **O nicho da passagem.** Um esconderijo do contrato atual (`_hideout`), num recuo da parede
   norte.
7. **O catálogo que se reescreve.** Uma entrada cujo texto depende de quantas figuras restam
   no banco, lido quando o caderno abre.
8. **Sustos de roteiro.** A bola, o painel e o beco fazem parte do progresso e **têm de
   acontecer**. O `scare_director` precisa de um caminho que os garanta (fora do 03:33) e
   ainda zere os intervalos, para os sustos de ocasião darem espaço a eles.

## 9. Sustos: orçamento e som

- **Sem estouro de volume.** **[Pedro]** Todo som novo passa pelo banco de efeitos, cortado em
  `PEAK`, e toca no máximo em `MAX_DB` (0 dB). O medo vem do silêncio antes, não do volume
  depois: quatro dos sete sustos novos são **mudos** (o reflexo, o olho, a figura do painel,
  o catálogo).
- **Cada tipo uma vez por noite.** Tipos novos no `scare_director`: `bola_quica`,
  `olho_fresta`, `figura_painel`, `reflexo_fica`, `figura_some`, `catalogo_muda`. O
  `lanterna_pisca` e o `duplo_espelho` já existem; o `duplo_espelho` vira o item 12.
- **De roteiro** (garantidos): a luz de fora, a bola, o painel, o beco.
  **De ocasião** (pedem licença ao diretor e podem não vir): o olho, o reflexo, o catálogo, as
  mudanças do banco. O olho e o reflexo são fortes: pedem tensão ≥ 0,6 e um minuto desde o
  último forte.
- **Nenhum durante o 03:33.** A vigília (§6.8) acaba quando o 03:33 começa.
- **Sons novos:** o interruptor da oficina, os quiques da bola, o arrastar atrás da parede, a
  caixa de música intermitente, a madeira do painel. Todos sintetizados como os de hoje, sem
  arquivo externo.

## 10. Acessibilidade

- A lanterna que pisca no beco segue os limites do §10 do spec: menos de 3 piscadas por
  segundo, nunca branco total.
- Com a opção **"reduzir piscar"** ligada, a lanterna escurece e volta devagar em vez de
  piscar. A figura avança do mesmo jeito.
- Nada na noite exige ouvir para avançar sem ter outro caminho: a caixa de música também pode
  ser achada pelo rastro de giz do menino (`giz_passagem`), e a presença atrás da parede é
  ambiente, não tarefa. **[escolha da IA]**
- O aviso dito à pessoa antes do playtest ("É um jogo de terror sem sustos de volume")
  continua verdadeiro.

## 11. Orientação

Espalhar as pistas arrisca o critério dos 3 minutos. O que segura:

- O relógio de bolso aponta para cada pista do capítulo 1, em ordem, e não só para o painel e
  a coroa. `goals` da noite 1 ganha as três pistas. **[escolha da IA]**
- Todo obstáculo tem a solução à vista: fósforos embaixo do desenho; o rastro de giz saindo
  do armário trancado; a última pose da cena com a mão no painel.
- O registro de playtest continua marcando `perdido` aos 180 s na mesma meta. Com as metas
  novas, ele passa a medir cada pista em separado.

## 12. Duração

O piso do bot vai subir de 81 s para algo entre 4 e 6 minutos (a medir). Para uma pessoa de
primeira vez, a meta passa a ser **de 20 a 30 minutos** **[escolha da IA]**. O roteiro do
playtest dizia "a noite 1 não deve passar de 20"; o spec diz 30 a 50 por noite. A noite 1
continua sendo a mais curta.

## 13. Testes, bot, binários e playtest

- **Unidade:** cada modelo novo de §8 entra com teste (segurança em degraus, banco de
  figuras, fresta, catálogo que se reescreve, adormecimento do Gasto).
- **Selftest:** as checagens da noite 1 que assumem pistas na sala de brincar, casa segura a
  noite toda e Gasto só depois da coroa precisam ser reescritas.
- **Bot:** `tests/bot_noite1.gd` é reescrito para o caminho novo (fósforo no quarto, chave,
  armário, cena até a última pose, painel, caixa de música, coroa, nicho com fôlego,
  travessia, vigília) e continua tendo de terminar em `BOT RESULT ok`. O tempo dele vira o
  piso novo.
- **Binários:** os de 2026-11-09 em `Janghyang/build/` ficam obsoletos e são refeitos no fim.
- **Playtest 1:** as sessões esperam esta noite. O roteiro (`context/discussoes/playtest-1.md`)
  ganha o que observar nos trechos novos e o novo teto de tempo.

## 14. O que fica para quem constrói

- A forma dos degraus de `safety` e do ponto de nascimento em `noites.gd`.
- Os lugares exatos das figuras fora do banco, da fresta, do nicho, do armário e da chave.
- Se sete figuras do corpo do Gasto, sentadas, cabem na sala das figuras (2,8 × 2,1 m, já com
  mesa e três cadeiras). Se não couberem, a sala cresce; mudança de `rooms` vai para
  `context/arquitetura.md`.
- Como a lâmpada da oficina é vista de dentro da casa na noite 1. Se a oficina gigante não
  estiver montada nessa hora, o efeito é feito com a luz e os vidros das janelas da casa.
- Confirmar que o poço para o sótão está fechado na noite 1. Se estiver aberto, fechá-lo com
  um alçapão até a noite 2; senão o beco tem duas saídas.
- Os tempos: melodia e silêncio da caixa de música, velocidade do Gasto engatinhando,
  distância do nicho, duração de cada piscada. O limite é o de §6.6: cabe num fôlego, com
  folga.
- Onde o Gasto fica entre o painel e a coroa, e como ele reaparece na passagem sem ser visto.
- Os textos novos do catálogo (banco, armário, chave), como rascunho da IA sob D9.
- A API do `scare_director` para os sustos de roteiro.

## 15. Escolhas da IA para Pedro conferir

1. O desenho só aparece sob chama (fósforo ou vela); a lanterna o apaga. (§6.2)
2. A chave do armário fica debaixo da almofada da cabana, no fim do rastro de giz. (§6.2)
3. O Gasto entra quando o painel quebra, não depois da coroa, e não agarra a menos de 3 m do
   painel recém-quebrado. (§6.5)
4. O painel só cede na última pose da cena. (§6.3)
5. O relógio de bolso aponta para cada pista do capítulo 1. (§11)
6. O catálogo conta as figuras do banco para baixo (sete, seis), em vez de "duas viram três".
   (§6.9)
7. Na vigília, as figuras fazem roda na beira do raio do relógio. (§6.8)
8. A caixa de música também pode ser achada pelo giz, para quem não ouve. (§10)
9. Meta de 20 a 30 minutos para a noite 1. (§12)
10. As sete figuras ficam sentadas num banco comprido, não numa prateleira: elas têm o tamanho
    do Gasto, para a travessia funcionar. (§6.2, §8)
