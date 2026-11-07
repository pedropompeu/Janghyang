---
tipo: contexto
projeto: memoria-de-projeto
descricao: Log de decisões fechadas, com data, razão e o que cada uma fecha.
estado: estavel
criado: 2026-09-12
---

# Decisões

> **Ler antes de reabrir qualquer discussão.** Este arquivo existe pra não decidir duas
> vezes — e, mais importante, pra que a alternativa descartada continue registrada com o
> motivo pelo qual caiu.
>
> Decisão que ainda está sendo tomada **não mora aqui**: mora em [`discussoes/`](discussoes/).

## Método e Governança {#metodo}

- [2026-09-12] (d) **Autonomia assistida para as IAs.**
  **Por quê:** Acelera o desenvolvimento diário permitindo que as IAs implementem detalhes técnicos de código e documentem com `(i)`, enquanto Pedro Pompeu retém a validação `(d)` de arquitetura, regras de negócio e inclusão de dependências.
  **Fecha:** Incertezas sobre até onde a IA pode ir sem autorização prévia.
  **Descartado:** Autonomia cega (onde a IA altera arquitetura sem aviso) e microgerenciamento restritivo (onde a IA precisa de aprovação para qualquer linha de código).

- [2026-09-12] (d) **Padrão de Commits: Conventional Commits em inglês e sem co-autoria.**
  **Por quê:** Padroniza o histórico do Git no padrão internacional (`feat:`, `fix:`, `chore:`, `refactor:`) e mantém autoria limpa sem a linha `Co-Authored-By`.
  **Fecha:** Formatação e idioma de mensagens de commit para todas as IAs.
  **Descartado:** Commits em português ou mensagens livres despadronizadas.

## Sistema e Arquitetura {#infraestrutura}

- [2026-09-12] (d) **Adoção da memória de projeto versionada em arquivos (`context/` e `fontes/`).**
  **Por quê:** Garante persistência contextual de longo prazo entre diferentes sessões e ferramentas de IA (Claude, Antigravity, Cursor) sem inflar a janela de contexto e com rastro de auditoria.
  **Fecha:** Elimina a necessidade de reexplicar decisões e arquitetura a cada nova sessão de IA.
  **Descartado:** Prompts monolíticos gigantescos e dependência de memória proprietária volátil.

- [2026-09-12] (d) **Foco híbrido: produtos próprios da holding e demandas sob medida para clientes.**
  **Por quê:** O ecossistema engloba tanto plataformas proprietárias (ViaXen, PomPay, NarraVox) quanto soluções sob demanda para clientes, exigindo rigor técnico e separação clara de escopos.
  **Fecha:** Modelo operacional do repositório e da orquestração de IAs.
  **Descartado:** Tratar todos os repositórios como projetos descartáveis de cliente ou exclusivamente internos.

## Jogo — FAZ DE CONTA {#jogo}

- [2026-10-20] (d) **Engine do slice: Godot 4.7.**
  **Por quê:** É 3D, leve, gratuito e já está instalado (`4.7.2.stable`); dobras, portas e colisão são baratas de iterar, e o slice pode ser exportado para desktop sem serviço externo.
  **Fecha:** A escolha de engine/stack para o slice e para o blockout.
  **Descartado:** Three.js (bom para protótipo no navegador, mas exige stack web e não é o alvo do slice) e Unity (mais pesado, sem ganho para este escopo).

- [2026-10-27] (d) **Direção do jogo: FAZ DE CONTA + o conto do relojoeiro, design aprovado.**
  **Por quê:** Pedro achou que faltavam história e objetivo ao blockout. O conto que ele trouxe (`fontes/2026-10-27-pedro-conto-relojoeiro.md`) dá o protagonista (Elias, catalogador), o objetivo (catalogar a maquete e descobrir a verdade sobre Inácio) e o evento central (o 03:33, quando a casa devolve os ecos do jogador). O design foi aprovado por Pedro: **“aprovvo”**.
  **Fecha:** história, objetivo, evento 03:33 sem perseguição, verdade sobre Inácio, final (Elias sai, algo dele fica) e escopo do próximo slice, conforme `docs/superpowers/specs/2026-10-27-faz-de-conta-relojoeiro-design.md` e [[modelo-arquitetural-dinamico-3d#brief]].
  **Descartado:** substituir o FAZ DE CONTA por um jogo novo de relojoeiro; mansão em escala real jogável; 03:33 com perseguição; jogo sem objetivo.

- [2026-10-27] (i) **Ajustes de construção nas Tarefas 2 e 3 do plano do relojoeiro.**
  **Por quê:** o plano deixava detalhes que colidiam com a geometria. O lápis gigante (caixa de 4,0 m ao longo de z) atravessaria o vidro sul, então foi girado para ficar ao longo de x, dentro do tampo. As janelas pequenas do ateliê e do strip oeste saíram, porque paredes de vidro não seguram moldura, e a janela de chuva 12× da oficina as substitui. `ExitEdge` usa `collision_layer = 0` para nunca bloquear raios nem sondas.
  **Fecha:** a forma do tampo, da redoma e da beira de saída no blockout.
  **Descartado:** manter o lápis ao longo de z (atravessa o vidro); manter as janelas pequenas sobre vidro.


- [2026-10-28] (i) **Teclas novas: `Q` catalogar, `Tab` caderno, `C` agachar, `B` bater; `F9` só em build de debug.**
  **Por quê:** `E` já é "interagir" e seguiu como o único verbo de mundo; cada verbo novo do plano ganhou uma tecla própria ao alcance da mão esquerda. `F9` encurta a espera do 03:33 em playtest sem existir no jogo exportado.
  **Fecha:** o mapa de teclas do slice (`faz-de-conta/README.md`).
  **Descartado:** um menu radial em `E`; teclas numéricas.

- [2026-10-28] (i) **F1 dobra a −45° e tem uma guarda (`can_toggle`): não se move com o jogador na cabana.**
  **Por quê:** fecha [[achados#a-001]] pelo caminho (a): agachado (cápsula de 1,0 m), o jogador cabe sob a dobra a −45°; a guarda impede que a casa ou o jogador dobrem F1 sobre ele, o espelho da casa nunca dobra F1, e o 03:33 só desfaz F1 passando pela guarda.
  **Fecha:** a cabana como lugar onde se senta.
  **Descartado:** dobra a −65° (folga de ~1,1 m); parede mais baixa.

- [2026-10-28] (i) **Tempos do relógio e do gatilho do 03:33.**
  **Por quê:** corda inicial de 180 s, cada volta rende 70% da anterior (mínimo 15 s, teto 600 s); gasto de 0,45/s, que dobra para 0,9/s no ato do duplo. O 03:33 vem quando o boneco e mais 5 itens de Elias estão catalogados, ou aos 1200 s (`MAX_PRE_HORA`); a corda é então limitada a 20 s (`HURRY_SPRING`) e ninguém passa de 1380 s (`HARD_LIMIT`). Depois do 03:33, a corda fica em até 30 s para a escolha; a trava (`STALL_SPRING` 5 s) impede que corda tardia evite a parada.
  **Fecha:** o ritmo de uma visita de ~15–23 min.
  **Descartado:** relógio em tempo real; gatilho só por catálogo (um jogador que nunca cataloga o boneco ficaria preso).

- [2026-10-28] (i) **Gravador de ecos: 10 Hz, trechos de 8 s, até 6 ecos, escolhidos por pontuação.**
  **Por quê:** 10 Hz basta para andar e olhar e cabe 30 min em 18 000 amostras. A pontuação é `3·ações + segundos parado + 2·segundos agachado + 0,5·metros`: favorece os momentos em que o jogador fez algo, hesitou ou se escondeu, que são os que ele reconhece como seus.
  **Fecha:** o que a casa devolve no 03:33.
  **Descartado:** gravar a visita inteira; ecos aleatórios.

- [2026-10-28] (i) **Os ecos, o reflexo, o gigante e a figura nova são o mesmo manequim de caixas, sem colisão.**
  **Por quê:** um corpo só, com o estilo de Elias, faz o jogador reconhecer-se em todos eles; caixas cabem no blockout e não exigem modelo nem animação externa.
  **Fecha:** a representação de Elias fora do jogador no slice.
  **Descartado:** sombras/silhuetas planas; um modelo importado.

- [2026-10-28] (i) **Som sintetizado em código, pico ≤ 0,5, em duas camadas (`Casa` e `Mundo`).**
  **Por quê:** não há assets nem dependências novas; senóide, ruído com semente e envelopes bastam para tique, clique, batida, passo, lápis, dobra, chuva, zumbido e respiração. `Casa` emudece no 03:33 e no final "parar"; `Mundo` (chuva) nunca emudece.
  **Fecha:** o som do protótipo.
  **Descartado:** biblioteca de áudio; arquivos `.ogg` gravados.

- [2026-10-28] (i) **Textos de catálogo, páginas e entradas do duplo como estão em `catalog_data.gd` e `double_writer.gd`.**
  **Por quê:** copiados ou derivados do brief e do spec; páginas com no máximo 4 linhas; nenhum contador "x de y" — só três linhas em branco numeradas sugerem que há mais.
  **Fecha:** o texto do slice, para revisão de Pedro.
  **Descartado:** HUD de objetivo; lista de itens faltantes.

- [2026-10-28] (i) **A figura nova senta no chão da entrada, onde Elias chegou, e a câmera final é o olho do gigante sobre a bancada.**
  **Por quê:** `NewFigure` em `(SPAWN.x, 0, SPAWN.z)`, virada para a porta da rua; câmera em `(1,8; 14; 22)` olhando `(1,8; 0,5; 8,3)`, FOV 24, vê a figura pela redoma e pela porta aberta (selftest "what stays"). A figura usa uma pose nova `no_chao` (quadril a 0,1 m), porque `sentado` é de cadeira e deixava as pernas no ar.
  **Fecha:** a imagem final dos três desfechos.
  **Descartado:** créditos, nota ou tela de "fim".

- [2026-10-28] (i) **As labels de leitura do blockout ficam atrás de `--labels`.**
  **Por quê:** o slice tem texto só em papel (catálogo, páginas, entrada final); labels flutuantes quebrariam isso, mas seguem úteis para revisar a planta.
  **Fecha:** a UI padrão do jogo.
  **Descartado:** remover as labels.

- [2026-10-28] (d) **Pedro pediu um jogo mais jogável, com mãos, uma vareta para bater e mais terror no ambiente, e mandou pular as perguntas.**
  **Por quê:** pedido direto ("vamos deixar o jogo mais jogavel, criar mãos e um pedaço de pau para fazer o movimento de bater e entrar com mais terror no ambiente"; "pode pular as perguntas e começar").
  **Fecha:** o escopo desta rodada.
  **Descartado:** nada.

- [2026-10-28 ~superseded 2026-10-28] (i) **"Mais terror" ficou como pavor ambiente, dentro dos anti-objetivos do spec.** → superado pela expansão: Pedro pediu monstros e trilha; ver a decisão "Expansão" abaixo.
  **Por quê:** o spec proíbe susto, sting alto, perseguição e algo que se aproxime do jogador.
  **Fecha:** o clima é feito de luz que baixa, neblina, zumbido, respiração, vinheta, rangidos a 4 m ou mais, piscadas raras e mãos que tremem; a tensão acompanha a visita e solta na saída.
  **Descartado:** jump scare, presença que segue Elias, trilha sonora.

- [2026-10-28] (i) **A vareta é de tília e bater continua sendo bater na superfície, não combate.**
  **Por quê:** é sobra da maquete; o spec veta combate e dano.
  **Fecha:** o golpe dura cerca de 0,4 s e o `bater` só conta no impacto (cerca de 0,2 s). `B` no meio do golpe é ignorado, e golpe no ar só toca o `swish`. O `knock` virou toque de madeira em madeira, que é o mesmo som da resposta da casa: a casa imita a vareta.
  **Descartado:** bater instantâneo; som de nós dos dedos.

- [2026-10-28] (i) **As mãos são desenhadas pela câmera do jogador, com `no_depth_test`, na camada 13.**
  **Por quê:** no GL Compatibility, as luzes do mundo não iluminaram as mãos num `SubViewport` com mundo compartilhado (ficaram pretas, com fundo transparente ou opaco); veja [[achados#a-016]]. Sem teste de profundidade, as mãos recebem a luz real da casa e da lanterna e não atravessam paredes. A camada 13 as tira do espelho e da câmera final.
  **Fecha:** a arquitetura do viewmodel.
  **Descartado:** overlay com `SubViewport` (sem luz) e luz própria para as mãos (também não chegou).

- [2026-10-28] (i) **A lanterna vai na mão esquerda e o feixe sai dela.**
  **Por quê:** a mão direita segura a vareta; dá corpo à lanterna.
  **Fecha:** `F` sobe ou baixa a mão com a lanterna; o `SpotLight3D` acompanha a lente.
  **Descartado:** lanterna presa à câmera.

- [2026-10-28] (d) **Expansão: mapa maior com história, tarefas, fases, monstros humanoides que aparecem e somem, bater em coisas, mobilidade, música assustadora, passagens secretas, portas que rangem, vários ambientes e um mapa. Sem perguntas.**
  **Por quê:** Pedro: "o mapa está muito pequeno e nao conta uma história, quero criar tarefas, fases, mostros humanoides que aparecem e desaparecem, bater em coisas, quero melhorar a mobilidade, uma musica assustadora […] passagens secretas, umas portas que abrem e faz barulho. varios ambientes (quero um mapa para saber onde estou)"; "precisa ser imersivo, preciso acreditar que estou no lugar do personagem. pode seguir trabalhando sem fazer perguntas".
  **Fecha:** supera, no spec de 2026-10-27, os anti-objetivos "nada caça o jogador", "sem trilha", "só os cômodos do blockout" e "catálogo nunca vira checklist". O design está em `docs/superpowers/specs/2026-10-28-faz-de-conta-expansao-design.md`. Continuam valendo: sem morte nem game over, porta da rua nunca tranca, texto só em papel.
  **Descartado:** nada; o critério acima de todos é imersão.

- [2026-10-28] (i) **A expansão se organiza em "fazer de conta" (olhos fechados mostram a lembrança e o giz), quatro peças do relógio de bolso de Inácio em quatro ambientes novos, os Gastos e um caderno com planta e lotes.**
  **Por quê:** o título vira mecânica e dá bússola sem marcador na tela; as peças dão fio às fases sem trocar o final já construído.
  **Fecha:** a estrutura descrita no design de 2026-10-28 (§3–§11), à espera da revisão de Pedro.
  **Descartado:** marcador de objetivo na tela; minimapa no HUD; fases com tela de carregamento.

- [2026-10-28] (i) **Os Gastos só se movem fora da vista, congelam sob luz e o abraço não mata: Elias acorda no último ponto seguro, com uma linha do duplo no caderno.**
  **Por quê:** "aparecem e desaparecem" fica literal; sem morte, o spec segue sem game over e perder custa tempo, não progresso.
  **Fecha:** comportamento dos monstros; nada ocorre durante o 03:33 e a porta da rua nunca é bloqueada.
  **Descartado:** monstro que corre na frente do jogador; vida, dano e morte; jump scare com estouro de volume.

- [2026-10-28] (i) **A música é procedural, sintetizada em GDScript na carga, em camadas adaptativas (drone, canção de ninar desafinada, cordas, coração, lembrança).**
  **Por quê:** a regra de não adicionar dependências e o jogo já gera todo som em código.
  **Fecha:** a trilha.
  **Descartado:** arquivos de áudio externos; música de ação.

- [2026-10-29] (i) **O térreo da casa é refúgio: nenhum Gasto entra nele, nem durante o 03:33.**
  **Por quê:** a casa é o centro emocional e o lugar do 03:33; ter um lugar seguro dá ritmo de saída e volta e mantém a porta da rua sempre livre.
  **Fecha:** onde os Gastos existem (`gastos.gd` `REFUGE`).
  **Descartado:** Gastos em toda parte; Gastos só a partir da fase III.

- [2026-10-29] (i) **Os Gastos se teleportam num grafo de pontos de espreita amostrado da própria geometria de cada andar (grade de 2,2 m centrada no cômodo, elos até 3,4 m com linha livre, maior componente).**
  **Por quê:** os ambientes são gerados em código e mudam; um grafo escrito à mão envelheceria a cada ajuste de parede.
  **Fecha:** a navegação dos Gastos.
  **Descartado:** `NavigationRegion3D` (nova peça de arquitetura e movimento visível); pontos escritos à mão.

- [2026-10-29] (i) **O ponto seguro é por andar (`LEVEL_SAFE`): ao entrar num andar, Elias passa a acordar na entrada dele depois de um abraço.**
  **Por quê:** voltar à casa a cada abraço custaria progresso; o spec diz que perder custa tempo.
  **Fecha:** o respawn.
  **Descartado:** último ponto pisado (pode ser ao lado do Gasto); sempre a casa.

- [2026-10-29] (i) **O abraço escurece em 0,18 s, segura 1,1 s, acorda Elias deitado (câmera rolada 80°) e levanta em 0,8 s; o duplo escreve "catalogador, segurado na/no <cômodo>. Frio."; a tensão leva um susto de 0,25 e os Gastos se espalham.**
  **Por quê:** horror sem morte; a linha do duplo amarra o abraço à história do caderno.
  **Fecha:** a captura.
  **Descartado:** tela de game over; perda de peças.

- [2026-10-29] (i) **`M` abre o caderno numa página dupla: lotes à esquerda (só fases alcançadas, feitos riscados) e plano à direita (só cômodos visitados, escala fixa de 20 px/m).**
  **Por quê:** objetivos e mapa sem HUD, na voz do catalogador; escala fixa mantém a torre pequena e a gaveta grande.
  **Fecha:** a UI de objetivos e mapa.
  **Descartado:** minimapa na tela; marcador de objetivo.

- [2026-10-29] (i) **A tarefa "voltar" se completa ao entrar no térreo com as quatro peças, e só então o 03:33 fica liberado (`visit.on_pieces_ready`); o título de cada fase nova aparece no rodapé 3,6 s depois.**
  **Por quê:** o 03:33 acontece na casa, com Elias dentro; o atraso deixa o som da peça e a entrada do caderno respirarem antes do lote.
  **Fecha:** a transição para a fase V.
  **Descartado:** liberar o 03:33 no momento de pegar a última peça, longe da casa.

- [2026-10-29] (i) **Opções no `Esc`: pausa o jogo e abre uma folha no papel do caderno com sensibilidade, inverter Y, campo de visão, brilho, três volumes e tela cheia; padrões iguais ao jogo afinado; salvas em `user://opcoes.cfg`.**
  **Por quê:** Pedro perguntou "e os settings?" e o jogo não tinha nenhum; o `Esc` só soltava o mouse. Sem HUD, a folha de papel mantém a voz do caderno.
  **Fecha:** o menu de opções e a pausa.
  **Descartado:** remapeamento de teclas (mais UI que ganho num blockout); qualidade gráfica (o GL Compatibility já é o piso); menu inicial separado.

- [2026-11-07] (d) **Objetivo e prazo: projeto profissional, lançamento previsto em 2027-04-15.**
  **Por quê:** Pedro aceitou integrar o FAZ DE CONTA ao escopo de trabalho da holding (`/discuss_clevel`, 2026-11-07) e informou o objetivo e a data.
  **Fecha:** natureza do projeto (profissional, não pessoal nem portfólio) e a data-alvo de lançamento.
  **Descartado:** projeto pessoal; portfólio sem lançamento.
  **Em aberto (não fechado por Pedro):** plataforma de distribuição, `git init` em `~/Dev/Jogo` e migração para `Projetos_holding/`.
  **Atualização 2026-11-07:** `git init` e remoto `origin` feitos após Pedro informar o repositório (ver [[arquitetura#repo]]). Plataforma e migração seguem em aberto.

- [2026-11-07 ~superseded 2026-11-07] (i) ~~**Nome de trabalho: The Watchmaker's Echo.**~~ → rejeitado por Pedro: o nome já existe. Ver candidatos novos no histórico da sessão de 2026-11-07. Texto original, para registro: título localizado opcional para pt-BR: "O Eco do Relojoeiro".
  **Por quê:** cobre o relojoeiro (Elias, Inácio) e o eco do 03:33; palavras latinas fáceis de buscar e de soletrar. Recomendação do OpenCode (sessão ses_e47fee9e1ffeZeuIw2fPKpKqDl), adotada por nós.
  **Fecha:** nome de trabalho de loja, trailer e documentação pública.
  **Descartado:** "faz de conta"; "03:33" como título único (ruim para busca, reduz o jogo a um gatilho); 소꿉놀이 como título global (difícil de buscar e de soletrar no Ocidente, embora seja a melhor tradução do conceito); "The Hour of Echoes" (genérico, risco de colisão maior).
  **Pendente:** checagem manual de colisão em Steam, itch.io, GOG, domínios e redes não foi feita. Validação `(d)` de Pedro.

- [2026-11-07] (d) **Nome do jogo: Janghyang (잔향).**
  **Por quê:** Pedro escolheu entre os candidatos após a rejeição de "The Watchmaker's Echo" (já existente). A busca na web não encontrou jogo com esse nome no Steam; o significado (ressonância que permanece) combina com o eco do 03:33.
  **Fecha:** nome de trabalho do jogo. Grafia em Hangul: 잔향; romanização: Janghyang.
  **Descartado:** "The Watchmaker's Echo" (~superseded acima); "Tickhouse", "Mirrorwound", "Hollowtick" (candidatos da mesma rodada, não escolhidos).
  **Pendente:** checagem de colisão no Steam (busca interna), itch.io, GOG, INPI, USPTO, domínio e redes sociais. Revisão de falante nativo para a grafia e o uso.

- [2026-11-07] (i) **Plataforma-alvo do lançamento: PC (Windows e Linux) via Steam e/ou itch.io.** macOS fica como opcional.
  **Por quê:** Godot 4.7 com export nativo, controles de teclado e mouse já definidos e nenhuma certificação de console no prazo de 2027-04-15.
  **Fecha:** plataforma inicial de distribuição.
  **Descartado:** console no lançamento de 2027 (exige certificação e capacidade de equipe não comprovada).
  **Pendente:** validação `(d)` de Pedro, porque plataforma é decisão de negócio.

- [2026-11-07] (i) **Escopo até 2027-04-15: congelar novas mecânicas e áreas.** O foco vai para fechar os três finais, a legibilidade, as rotas completas (selftests dos quatro ambientes), os playtests e o release. Duração-alvo proposta: 45 a 90 min para a primeira visita completa, a validar em playtest.
  **Por quê:** o maior risco hoje é validação humana e fechamento de produção, não falta de conteúdo. Recomendação do OpenCode (mesma sessão), adotada por nós.
  **Fecha:** o que entra e o que sai do lançamento.
  **Descartado:** continuar expandindo mecânicas antes do playtest; lançar sem playtest dos finais.
  **Pendente:** validação `(d)` de Pedro, porque corte de escopo afeta o produto.

- [2026-11-07] (i) **Selftest tem guarda de tempo de 120 s que encerra com falha.** Um erro de script dentro de `_run` deixa o processo aberto; a guarda chama `quit(1)`.
  **Por quê:** A-006. A execução completa leva 43 s; 120 s deixa margem sem esperar o `timeout` externo.
  **Fecha:** comportamento do `--selftest` quando a execução para no meio.
  **Descartado:** depender só de `timeout 150` na linha de comando (funciona, mas o processo não se explica sozinho).

- [2026-11-07] (i) **O eco copia a própria janela de amostras ao ser montado.** `Echo.load_window(recorder, seg)` copia; `sample_at(t)` é método de instância e não lê mais o gravador.
  **Por quê:** A-013. O gravador descarta as amostras mais antigas ao passar de `MAX_SAMPLES`, e os índices guardados apontavam para o lugar errado.
  **Fecha:** ecos em sessões longas reproduzem o trecho escolhido no 03:33. `index` do eco passa a ser relativo à janela (só é usado para detectar troca de ação).
  **Descartado:** guardar um deslocamento de descarte no gravador (mais estado, mesmo risco de drift).
