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
  **Por quê:** corda inicial de 180 s, cada volta rende 70% da anterior (mínimo 15 s, teto 600 s); gasto de 0,45/s, que dobra para 0,9/s no ato do duplo. O 03:33 vem quando o boneco e mais 5 itens de Elias estão catalogados, ou aos 1200 s (`MAX_PRE_HORA`) ~superseded 2026-11-07: o gate mudou, ver [2026-10-29] (as quatro peças juntas, `visit.on_pieces_ready`) e o spec de expansão §5 (limite de 60 min, `MAX_PRE_HORA = 3600.0`, `visit_state.gd:9`); a corda é então limitada a 20 s (`HURRY_SPRING`) e ninguém passa de 1380 s (`HARD_LIMIT`) ~superseded 2026-11-07: hoje 3780 s (`visit_state.gd:10`). Depois do 03:33, a corda fica em até 30 s para a escolha; a trava (`STALL_SPRING` 5 s) impede que corda tardia evite a parada.
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

- [2026-10-29 ~superseded 2026-11-08] (i) ~~**O térreo da casa é refúgio: nenhum Gasto entra nele, nem durante o 03:33.**~~ → seguro só no começo; ver R12 em [[decisoes#rumo-2026-11-08]].
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

- [2026-11-07] (i) **O lápis do duplo só soa com o duplo sentado no banco; a entrada é sempre escrita.** `_write_next` toca o lápis só se `doll.is_double()`; o flush de `end()` segue a mesma regra, então pode escrever sem som.
  **Por quê:** A-015. O som sem corpo contradizia "nada inventado" (spec de expansão).
  **Fecha:** som do lápis durante o 03:33.
  **Descartado:** tocar o lápis sempre (defeito); suprimir também a escrita enquanto o duplo não senta (perderia entradas do caderno).

- [2026-11-07] (i) **A saída do jogo passa por `main.shutdown()`: para os loops (`SfxBank.stop_all`), espera um frame e chama `quit()`.** Os players de loop se registram em `SfxBank.register_loop`. Fechar a janela (`NOTIFICATION_WM_CLOSE_REQUEST`, com `auto_accept_quit = false`), "Sair do jogo" e a captura `--shot-clock` usam o mesmo caminho.
  **Por quê:** A-007. O aviso `ObjectDB instances were leaked` vinha de playbacks de loop vivos no `quit()`; parar em `_exit_tree` não resolveu.
  **Fecha:** vazamento de áudio na saída (gate headful: 0, linha de base 5).
  **Descartado:** confiar em `_exit_tree` (testado sem efeito); silenciar só no headless (não cobre a janela).

- [2026-11-07] (e) **Checagem de colisão de nome nas lojas (U03): sem título igual a "Janghyang" nem "잔향" em Steam, itch.io e GOG.** Busca direta nas lojas, com a ferramenta de busca interna de cada uma:
  | Loja | "janghyang" | "잔향" |
  |---|---|---|
  | Steam | 0 resultados — https://store.steampowered.com/search/?term=janghyang | 0 resultados — https://store.steampowered.com/search/?term=%EC%9E%94%ED%96%A5 |
  | itch.io | 4 projetos, nenhum com título Janghyang (nomes parecidos: "Call it Fate", "BLOK", "The Mysterious valley", "What's Life") — https://itch.io/search?q=janghyang | 0 projetos — https://itch.io/search?q=%EC%9E%94%ED%96%A5 |
  | GOG | 0 resultados — https://www.gog.com/en/games?query=janghyang | 0 resultados — https://www.gog.com/en/games?query=%EC%9E%94%ED%96%A5 |
  Vizinho de tema, não de nome: "Gwihyang: Homecoming" (귀향, horror coreano, Steam) — https://store.steampowered.com/app/3060970 (registrado para a leitura de posicionamento, não é colisão).
  **Ressalva:** a busca cobre o título e as grafias testadas; não cobre grafias alternativas (ex.: "Jang Hyang") nem a forma com Hanja. A busca web padrão e estendida não achou nada relevante; o resultado vale pelas buscas internas das lojas.
  **Por quê:** U03 do plano de lançamento (nome Janghyang, D3).

- [2026-11-07] (e) **Checagem de domínio e handles (U04, parcial): domínios .com e .io sem registro; handles @janghyang ocupados no X, Instagram, YouTube e itch.io; Steam Community livre.**   | Item | Resultado | Fonte |
  |---|---|---|
  | janghyang.com | sem registro (WHOIS: "No match") | whois, 2026-11-07 |
  | janghyang.io | sem registro (WHOIS: "Domain not found") | whois, 2026-11-07 |
  | janghyang.games | **inconclusivo**: o WHOIS usado não suporta .games; DNS não resolve (ausência de resolução não prova registro livre) | whois, getent |
  | X (@janghyang) | ocupado: perfil "jang (@janghyang)" | https://x.com/janghyang |
  | Instagram (@janghyang) | ocupado: perfil "hyang (@janghyang)" (página com login) | https://www.instagram.com/janghyang/ |
  | YouTube (@janghyang) | ocupado: canal "소리가 쌓이는 곳", 1 inscrito, 2 vídeos | https://www.youtube.com/@janghyang |
  | itch.io (janghyang) | ocupado: perfil de usuário, sem posts recentes, sem jogo listado na página | https://itch.io/profile/janghyang |
  | Steam Community (janghyang) | livre: "Não foi possível encontrar o perfil especificado" | https://steamcommunity.com/id/janghyang |
  **Não verificado nesta unidade:** INPI e USPTO (classe de jogos eletrônicos); Facebook, TikTok e a conferência de grafia do handle (busca de handles não cobriu variações). Pendentes.
  **Leitura:** nenhuma das contas achadas é de um jogo com o mesmo nome; são contas de pessoas ou canais sem relação aparente. Colisão de handle é risco de marca para a página da loja e para as redes (U63), não de título. **Decisão de nome (d) só se Pedro julgar o risco de handle inaceitável** (D3).
  **Por quê:** U04 do plano de lançamento.

> **Bloco de 2026-11-07 — escolhas delegadas.** O Pedro pediu "resolva e escolha tu". As escolhas abaixo são do modelo, seguindo a recomendação de cada decisão do plano (`docs/superpowers/plans/2026-11-07-janghyang-lancamento.md`, seção 2). Por isso estão marcadas `(i)`, não `(d)`: **não são validação do Pedro**. Os itens com custo financeiro ou aceitação de risco de marca continuam como `(d)` pendente, e cada um está marcado abaixo.

- [2026-11-07] (i) **D6 (A-014): o duplo conta como sentado para o catálogo (opção a).** Por quê: o item `boneco` exige `doll_sat`, e o duplo já está sentado no banco; a flag tem que ficar verdadeira ao virar duplo. Fecha: U20, commit `67ccc48`; `Doll.become_double` emite `toggled(false)`. Descartado: `Q` valer direto no duplo (mexe em interação e amplia a superfície de bug).

- [2026-11-07 ~superseded 2026-11-08] (i) **D2: escopo congelado a partir de 2026-11-21 (fim da U38).** → reaberta por Pedro; ver [[decisoes#rumo-2026-11-08]]. Por quê: prazo de lançamento em 2027-04-15 e risco de escopo aberto; a fase 3 (rotas e regressão) é a última que pode mexer em rota ou regra. Fecha: depois de 2026-11-21, só correção, texto e polimento, sem mecânica, área ou Gasto novo. Descartado: congelar só no lançamento (deixa as fases 4 e 5 abertas a mecânica nova); congelar já (bloqueia U30–U38).

- [2026-11-07] (i) **D1: plataforma PC (Windows e Linux) via Steam e itch.io, com lançamento simultâneo.** Por quê: recomendação do plano; cobre os dois canais de jogo indie de horror e a demo no itch.io. Fecha: U60–U66 preparam as duas lojas. **Custo pendente (d):** a taxa de registro da Steam tem valor a confirmar na página oficial antes de qualquer pagamento, e o pagamento depende de aprovação explícita do Pedro. Descartado: uma só loja (perde um dos canais do plano).

- [2026-11-07] (i) **D3: nome Janghyang mantido; handles de rede tratados em U63.** Por quê: U03 não achou colisão de título em Steam, itch.io e GOG; os handles `@janghyang` estão ocupados no X, Instagram, YouTube e itch.io (U04). Colisão de handle é risco de marca para a página de loja, não de título. Fecha: o nome segue; na U63 a conta de loja usa um slug verificado como livre. **Aceite formal do risco de handle (d) pendente** do Pedro antes de criar contas. Descartado: trocar o nome agora (sem colisão de título, custo alto); usar handle ocupado sem verificar.

- [2026-11-07] (i) **D4: idiomas pt-BR como base e inglês no lançamento.** Por quê: recomendação do plano; o texto atual está só em pt-BR (D4), e o inglês amplia o alcance de lançamento. Fecha: U62 traduz catálogo, caderno, finais e ajuda. **Custo pendente (d):** revisão de falante nativo do inglês. Descartado: só pt-BR (perde o mercado de jogos em inglês).

- [2026-11-07] (i) **D5: modelo premium com demo; preço decidido depois dos playtests.** Por quê: recomendação do plano; a demo reduz a compra às cegas. Fecha: U63 escreve a página com demo. **Preço (d) pendente** do Pedro, depois de U50–U52. Descartado: gratuito (não paga o esforço); preço fixo agora (sem dados de playtest).

- [2026-11-07] (i) **D8: o default de 2026-10-20 segue como teste de design; a revisão vencida em 2026-11-03 fica para 2026-11-21.** Por quê: o teste "divertido sem objetivo?" continua valendo com o blockout jogável, e não houve revisão com o Pedro. Fecha: a pendência de lint (`modelo-arquitetural-dinamico-3d.md`, linha (i) de 2026-11-07). A linha antiga recebe `~superseded`, sem apagar. Descartado: remover o default (apaga o teste); deixar a data vencida (lint vermelho).

- [2026-11-07] (e) **D7 segue aberta.** A aprovação visual das capturas de luz (U40, U41) é decisão de olho do Pedro e não pode ser delegada ao modelo. Bloqueia U40 e U41; o resto da fase 4 não depende dela.

- [2026-11-07 ~superseded 2026-11-08] (d) ~~**D2 aprovada por Pedro: escopo congelado.**~~ Por quê: Pedro respondeu "aprovado tudo" à proposta do U38. Fecha: a partir de 2026-11-07, sem mecânica, área ou Gasto novo até o lançamento; só correção, texto e polimento. Confirma a entrada (i) de D2 acima. Descartado: manter o escopo aberto até o lançamento. → reaberta por Pedro em 2026-11-08 ("Reabrir só para conteúdo"); ver [[decisoes#rumo-2026-11-08]].

- [2026-11-07] (e) **U04 (registros, domínio e redes): nova rodada, ainda parcial.** INPI ← https://www.gov.br/inpi/pt-br/servicos/marcas/ : busca na web não achou marca "Janghyang" na classe 9; a base oficial do INPI não foi consultada (sem acesso à busca de marcas). USPTO ← https://tmexpress.com/how-to-trademark-video-game/ : busca na web não achou registro de "Janghyang" para jogos; a base TESS/USPTO não foi consultada. Facebook: busca na web não achou página de jogo "Janghyang". TikTok: busca na web não achou @janghyang; o parecido é @janghyeyeong (canal de YouTube de outra pessoa, não é o mesmo handle). janghyang.games: WHOIS local responde "TLD is not supported" para .games e o DNS não resolve o domínio (`getent hosts`); status inconclusivo, não é prova de disponibilidade. **Leitura:** nenhuma colisão direta encontrada na web; a checagem oficial de INPI e USPTO e o status de janghyang.games continuam pendentes e exigem consulta manual nas bases. **Por quê:** U04 do plano de lançamento.

### Rumo de 2026-11-08 {#rumo-2026-11-08}

> **Escolhas de Pedro na página "Rumo do Janghyang".** Fonte crua em `fontes/2026-11-08-pedro-escolhas-rumo.md`. Cada linha abaixo é `(d)` porque registra a opção que Pedro marcou e a nota que ele escreveu. A forma de fazer é `(i)` e vai para o documento de direção. O que ele não disse e muda o que se constrói está em aberto em [[rumo-2026-11]].

- [2026-11-08 ~superseded 2026-11-08] (d) ~~**R1: escopo reaberto só para conteúdo.**~~ → Pedro abriu tudo; ver R10 abaixo. Por quê: Pedro marcou "Reabrir só para conteúdo" depois de dizer que falta história, foco, rumo, mapa e coisas a fazer. Fecha: `substitui` a D2 de 2026-11-07 (acima, `~superseded`); história, áreas e tarefas novas voltam a entrar antes da demo. `tensiona` R6, R8 e R9, que pedem estrutura de maquetes, mecânicas novas e assets, ou seja, mais do que conteúdo. O limite está em aberto em [[rumo-2026-11#escopo]]. Descartado: manter congelado; reabrir tudo.

- [2026-11-08] (d) **R2: em 2027-04-15 sai uma demo pública, não o jogo completo, e só se estiver pronta e com história jogável.** Por quê: nota de Pedro: "Desde que esteja pronto e com uma história jogavel". Fecha: `substitui` o alvo de lançamento completo de `docs/superpowers/plans/2026-11-07-janghyang-lancamento.md`, que precisa ser refeito; o jogo completo fica sem data. Descartado: jogo completo em abril; adiar sem data.

- [2026-11-08] (d) **R3: o centro é horror de sobrevivência com incursões, terror psicológico, sem matança, e o jogador vive assustado.** Por quê: notas de Pedro: "nao é um jogo de matança é um terror psicologico, precisamos de sustos e buscar e procurar coisas para se salvar"; "Quero um Horror de sobrevivencia com incursões, nao quero matança, mas quero que o jogador viva assustado". Fecha: os Gastos e o medo constante passam ao centro; procurar coisas para se salvar vira tarefa. `substitui` o (i) de 2026-10-20 "não de perseguição, combate ou survival horror" em [[modelo-arquitetural-dinamico-3d#brief]]. `tensiona` o descarte de jump scare (2026-10-28), o térreo como refúgio (2026-10-29) e "sem morte nem game over" (expansão de 2026-10-28); os três estão em aberto em [[rumo-2026-11#medo]]. Descartado: investigação contemplativa; casa-refúgio e incursões como híbrido formal (era a recomendação do modelo).

- [2026-11-08] (d) **R4: a história chega em um capítulo por área.** Por quê: Pedro marcou "Um capítulo por área". Fecha: cada área conta um capítulo da vida de Inácio; a forma (encenação das figuras, página de hipótese no caderno) é `(i)` no documento de direção. Continua valendo: texto só em papel. Descartado: diários espalhados; narração de Elias com voz.

- [2026-11-08] (d) **R5: o relógio de bolso é a bússola, e o jogo ensina isso antes.** Por quê: nota de Pedro: "Precisa ter um direcionamento antes, para que a pessoa entenda que existe um relogio de busca uma bussola". Fecha: o relógio de bolso guia até a próxima peça, e um momento de introdução apresenta o relógio antes de o jogador precisar dele. Descartado: só o caderno; objetivo na tela.

- [2026-11-08] (d) **R6: o mapa cresce por várias maquetes e várias noites, começando com os 15 cômodos atuais mais 3, e acrescentar área nova precisa ser fácil.** Por quê: nota de Pedro: "Quero algo que seja possivel escalar, podemos trabalhar com 15 comodos + 3, mas a ideia de aumentar é extremamente importante e precisa ser de maneira facil esse aumento". Fecha: mudança de arquitetura aprovada por Pedro; a estrutura do jogo passa a aceitar maquetes e noites, e adicionar área deixa de exigir mexer no `main.gd`. O desenho técnico é `(i)` e vai ao documento de direção. Descartado: manter e aprofundar; três áreas na bancada sem estrutura de maquetes (era a recomendação do modelo).

- [2026-11-08] (d) **R7: a planta do caderno mostra em tempo real onde Elias está, só com o que ele já explorou, mais as anotações dele.** Por quê: Pedro marcou "Planta com anotações de Elias" com a nota "Planta em tempo real de onde ele está, mas só aparecendo o que ele já explorou". Fecha: evolui o plano do `M` (2026-10-29), que mostra só os cômodos visitados. Continua valendo: sem minimapa no HUD; a planta mora no caderno. Descartado: planta como está; maquete 3D consultável.

- [2026-11-08] (d) **R8: entram relógios-âncora, catálogo como investigação, consertar mecanismos, furtividade mais rica e seguir o giz, e o modelo pode propor mais ações.** Por quê: Pedro marcou as cinco opções, com a nota "Pode pensar em mais acoes". Fecha: as cinco ações; candidatas novas `(i)` em [[rumo-2026-11#acoes]], cada uma à espera do aceite de Pedro. Descartado: nada.

- [2026-11-08] (d) **R9: o visual se abre para assets editáveis e moldáveis, com texturas mais realistas e foco em originalidade, não em polimento.** Por quê: nota de Pedro: "A palavra certa n é polir e sim trabalhar melhor a originalidade ao visual, dando texturas mais realisticas, trazer assets editaveis e moldaveis para a nossa realidade". Fecha: `substitui` a restrição global "nenhum asset importado" do plano de lançamento de 2026-11-07; o fato de [[arquitetura]] de 2026-10-20 (o código não usa assets externos) continua verdadeiro até o primeiro asset entrar. O renderer segue GL Compatibility: Pedro não escolheu Forward+. Custo e origem dos assets estão em aberto em [[rumo-2026-11#assets]]. Descartado: polir dentro das regras (era a recomendação do modelo); trocar para Forward+.

- [2026-11-08] (d) **R10: escopo todo aberto antes da demo; mecânica nova entra quando o modelo propõe e Pedro aceita.** Por quê: perguntado sobre o limite entre "só conteúdo" (R1) e as escolhas R6, R8 e R9, Pedro respondeu "Tudo aberto". Fecha: `substitui` R1; resolve a tensão de R1 com R6, R8 e R9. Descartado: conteúdo mais R5–R9 e nada além; só conteúdo de verdade.

- [2026-11-08] (d) **R11: ser pego por um Gasto faz a tela piscar e se mover, e o jogador precisa clicar várias vezes no mouse para se soltar; o custo é tempo.** Por quê: resposta de Pedro: "Perde tempo, a tela começa a piscar e se movimentar, o jogador precisa clicar repetidas vezes no mouse para sair". Fecha: a captura ganha uma luta para se soltar antes do abraço de 2026-10-29. Continua valendo: sem morte e sem game over. Default `(i)`: se o jogador não se soltar, acontece o abraço atual (acorda no ponto seguro). Descartado: perder um item (era a recomendação do modelo); manter como está; morte e recomeço.

- [2026-11-08] (d) **R12: a casa é segura no começo e deixa de ser a cada capítulo; perto do fim, nenhum lugar é seguro.** Por quê: Pedro escolheu "Seguro até certo ponto". Fecha: `substitui` o térreo como refúgio permanente (2026-10-29, acima, `~superseded`). Continua valendo: a porta da rua nunca tranca. Descartado: sempre seguro; nunca seguro.

- [2026-11-08] (d) **R13: os assets são gratuitos e editados aqui, e o artista é a própria IA.** Por quê: resposta de Pedro: "Seguimos com os gratuitos e editados, e nosso artista contratado é a propria IA." Fecha: origem e custo de R9; custo financeiro zero; o modelo cria e ajusta modelos e texturas. A licença de cada asset (CC0 ou equivalente) é registrada quando ele entra. Descartado: compra pontual de pacotes; contratar artista.

- [2026-11-08] (d) **R14: o Blender entra como ferramenta de produção dos assets.** Por quê: perguntado se instalava o Blender ou fazia tudo por código e no Godot, Pedro respondeu "pode instalar o blender". Fecha: os assets de R9 e R13 são feitos ou ajustados no Blender, por script, e exportados em glTF para o Godot. O Blender não entra no jogo exportado. Instalação em [[arquitetura#stack]]. Descartado: gerar tudo só por código e no Godot.

- [2026-11-08] (d) **R15: entram as seis ações candidatas: luz escassa (pilhas e fósforos), brinquedo de corda como isca, escutar pelas paredes, lupa de relojoeiro, barricar portas internas e espelho de mão.** Por quê: Pedro respondeu "entram todas as ações". Fecha: as ações de [[rumo-2026-11#acoes]] somam-se às cinco de R8. Continua valendo: a porta da rua nunca tranca. Descartado: nada.
- [2026-11-08] (d) **Documento de direção aprovado.** Por quê: Pedro respondeu "aprovado, pode escrever o plano". Fecha: `docs/superpowers/specs/2026-11-08-janghyang-direcao-design.md` passa a ser o spec do jogo; as [escolha da IA] marcadas nele valem até Pedro dizer o contrário. Descartado: nada.
- [2026-11-08] (i) **Plano da demo substitui o plano de lançamento de 2026-11-07.** Por quê: o spec aprovado muda alvo (demo com as noites 1 e 2), escopo (onze ações, registro de áreas, campanha) e assets. Fecha: `docs/superpowers/plans/2026-11-08-janghyang-demo.md`, 47 tarefas em série; U30, U31, U32, U40–U42, U50–U52, U03, U04 e U61–U66 entram nele (§0.3); U38 e D2 ficam obsoletas. Descartado: emendar o plano antigo (a ordem e o formato das tarefas mudaram demais).
- [2026-11-08] (i) **D9–D12 abertas no plano da demo:** texto dos capítulos (D9), estouro de volume (D10, revisar 2026-11-22), o que sai primeiro se faltar tempo (D11: isca e barricada) e quem joga os playtests (D12). Por quê: são regra de jogo ou dependem de Pedro. Fecha: cada uma tem default no §0.4 do plano. Descartado: decidir pela IA.
- [2026-11-08] (i) **Teclas novas: relógio no `T`, giz no `G`, escutar segurando `L`, prender a respiração segurando `H`, roda do mouse troca o item da mão esquerda.** Por quê: o `Q` já cataloga, e o §19 do spec deixa as teclas para quem constrói. Fecha: §1 do plano da demo. Descartado: relógio no `Q` (conflita com catalogar).
- [2026-11-08] (d) **Plano da demo executado em formato misto.** Por quê: Pedro respondeu "pode seguir com o formato misto". Fecha: modelos isolados com construtor novo por tarefa; integração na sessão principal; o OpenCode revisa cada tarefa e um revisor Claude revisa cada marco; regra 7 do §0.1 do plano. Descartado: tudo nativo; tudo por subagente.
- [2026-11-08] (d) **Só modelos gratuitos para os agentes externos, sempre.** Por quê: Pedro respondeu "só os gratuitos, sempre". Fecha: no OpenCode, só modelos `-free` (hoje `opencode/deepseek-v4.1-flash-free`); no Gemini CLI, só a cota gratuita. Descartado: modelos pagos do OpenCode Zen.
- [2026-11-08] (d) **Claude Code como gestor; OpenCode (DeepSeek free) e Gemini CLI como construtores que se revisam.** Por quê: proposta de Pedro, fechada com "pode fechar o arranjo". Fecha: regra 7 do §0.1 do plano da demo. Os construtores fazem os modelos isolados e não fazem commit, e quem constrói não revisa. A integração fica com a sessão principal, que roda os gates e faz o commit. Descartado: os três construindo a mesma tarefa (o plano é em série e isso triplica o trabalho).
- [2026-11-08 ~superseded 2026-11-08] (i) ~~**Migração do registro concluída; `main.gd` não conhece área por nome.** Por quê: a Tarefa 8 do plano da demo fecha o anti-objetivo de área nova exigir mexer no `main.gd`; o teste `test_main_knows_no_area_by_name` guarda isso. Fecha: toda área nova entra só com um arquivo em `scripts/areas/` e uma linha em `Registry.AREAS`; a ordem do registro vale para busca de cômodo e abas da planta. Descartado: manter `ROOM_ORDER`/`LEVEL_ORDER` para preservar a ordem antiga das abas (sótão antes do mecanismo).~~ → precisão: `main.gd` não constrói nem mapeia área por nome; a casa é `Registry.HOME`, e só a rota de depuração "gasto" ainda cita `&"gaveta"` (ferramenta de teste, não regra). Os testes `test_main_knows_no_area_by_name` e `test_every_helper_an_area_calls_is_declared` guardam isso.
- [2026-11-08] (i) **Uma fase termina na última tarefa dela, não na peça de mesmo índice.** Por quê: as fases das noites não seguem a ordem das quatro peças (a noite 1 tem dois capítulos e só a coroa); nas fases de hoje a última tarefa de I a IV é a peça, então o comportamento antigo não muda (os testes antigos do `test_quest_model.gd` passaram sem alteração). Fecha: `QuestModel._first_open_phase`. Descartado: um campo `ends_on` por fase.
- [2026-11-08] (i) **As noites 1 a 4 terminam numa fase "Antes do 03:33" com `voltar_terreo` e `dar_corda`, e a noite 2 ganha a tarefa `alcapao`.** Por quê: o §5.1 pede "cumprir as metas e voltar ao térreo" para o 03:33 curto, e o plano conta os Gastos da noite 2 a partir do alçapão da torre; os textos são rascunho (D9). Fecha: `quest_model.TASKS` e `noites.gd`. Descartado: deixar o fim da noite fora do caderno.
- [2026-11-08] (i) **O save é JSON com envelope `{version, state}` e o estado por `JSON.from_native`; grava por `.tmp` e renomeia.** Por quê: o envelope deixa checar a versão sem decodificar (um arquivo ruim nunca chega ao decodificador do motor, que só registraria erro), `from_native` devolve `StringName`, `int` e `Vector3` sem conversão à mão, e o `.tmp` impede que uma queda no meio do save estrague o anterior. Fecha: `campaign_model.gd`. Descartado: `var_to_str` (pode criar objetos) e JSON simples com conversão por campo.
- [2026-11-08] (i) **O capítulo 7 fica na casa enquanto a mansão (item 216) está fora do plano; as pistas dos capítulos 2 a 7 são provisórias.** Por quê: o teste exige que toda área e pista de capítulo exista hoje; a passagem não tem objetos de catálogo, então o capítulo 2 usa a caixa de música e a bola até a Tarefa 23 criar as pistas dele. Fecha: `noites.gd` até as Tarefas 23 e 34. Descartado: capítulos sem pistas.
- [2026-11-08] (i) **Na noite curta o gate do 03:33 é "metas cumpridas e Elias no térreo", e uma vez aberto não fecha; a captura segura o gate e o limite de tempo.** Por quê: o §5.1 pede metas e volta ao térreo para o 03:33 curto, e um 03:33 que começasse com Elias nas mãos de um Gasto seria impossível de fugir; a noite vazia mantém o comportamento de hoje, então os testes antigos ficam iguais. Fecha: `visit_state.gd`. Descartado: exigir as peças nas noites curtas; fechar o gate se Elias sai do térreo.
- [2026-11-08] (i) **Revisão da T10: `get_night` devolve cópia, `last(demo)` é testável, e a campanha valida elementos, guarda o teto da noite e nunca sobrescreve um `*.bad.json` ([[achados#a-021]]).** Por quê: a tabela `NOITES` e a fase final compartilhada não podem mudar por quem lê uma noite; o corte da demo depende da feature do preset, que só existe na Tarefa 45. Fecha: `noites.gd`, `campaign_model.gd`, `catalog.gd`. Descartado: a regra de fase incremental (a regra antiga, pelas peças, já pulava fase do mesmo jeito; não é regressão) e apagar `QuestModel.stalkers()` agora (o `main` ainda usa as fases de hoje; a contagem por noite é da Tarefa 12/13).
- [2026-11-08] (i) **O jogo é jogado em noites: sem argumentos, carrega `user://campanha.json` e começa na noite salva; `--night N` começa numa campanha limpa na noite N (com as peças das noites anteriores) e nunca toca o save; selftest, tour e fotos seguem na visita de hoje (noite vazia).** Por quê: o §5.1 pede save só entre noites; os testes e o tour não podem escrever no save do jogador, e o selftest antigo depende das fases de hoje até o 03:33, quando passa para a noite 5 sem mudar o que confere. Fecha: o boot do `main.gd` (Tarefa 12). Descartado: o selftest inteiro na noite 5, que mudaria as checagens da história e dos Gastos.
- [2026-11-08] (i) **`begin_night(n)` recria quest (com as peças carregadas), relógio (`WindClockModel.reset()`), visita, gravador de ecos e a hora (`hour_event.reset()`), aplica catálogo, planta e itens de mão da campanha, esconde as peças já ganhas e acorda Elias no `SPAWN`; `end_night()` guarda o que passa, avança a noite (menos na última desta build), salva e mostra o card.** Por quê: uma noite é uma sessão (§5); o card é o único lugar onde o jogo salva. Na última noite da demo a campanha fica nela, porque não há noite seguinte para acordar. Fecha: o laço das noites até os atalhos (Tarefa 29), que aplicam `campaign.shortcuts`, e o reset do mundo ([[achados#a-022]]). Descartado: reconstruir a cena a cada noite (perde o mundo construído por código e custa segundos).
- [2026-11-08] (i) **O 03:33 curto (noites 1 a 4) é só o silêncio e os ecos da noite: sem duplo escrevendo, sem voltar o tempo, sem coisas das frestas e sem página da cabana; acaba na corda ou em 90 s e chama `_night_over()`.** Por quê: o §5 guarda a escolha e a verdade para a noite 5; o eco do capítulo vem com os capítulos (Tarefa 23 em diante). Fecha: `hour_event.begin(short)`. Descartado: reaproveitar o 03:33 inteiro em toda noite.
- [2026-11-08] (i) **Ponte dos Gastos por noite: `gastos.on_night(night)` e `Gastos.night_stalkers(steps, is_done)` (vale o último `after` cumprido); nenhum Gasto com o card aberto; o refúgio da casa e o `MAX := 2` ficam até a Tarefa 13.** Por quê: a tabela `stalkers` de `noites.gd` já existe e a revisão da T10 pediu que a T12 a usasse; trocar o refúgio por pontos de segurança é o escopo da Tarefa 13. Fecha: `wanted()` até a Tarefa 13. Descartado: esperar a T13 e jogar as noites com as fases de hoje.
- [2026-11-08] (i) **O card entre noites ignora entrada por 600 ms e o card de fim da demo não fecha nem consome teclas (o Esc vai às configurações).** Por quê: o E que dá corda no relógio abriria e fecharia o card no mesmo toque; no fim da demo o jogador precisa sair pelo menu. Fecha: `night_card_ui.gd` até o texto final (D9).
- [2026-11-08] (i) **A casa deixa de ser um nível refúgio (`REFUGE` sai de `gastos.gd`): a segurança é por ponto, em `scripts/safety_model.gd` (`is_safe(point, rule, world)`), com a regra da noite (`casa_toda`, `relogio_entrada`, `comodos_com_luz`, `so_ancoras`) e os âncoras com corda (raio de 4 m; `level` opcional prende o âncora à sua área). Um Gasto nunca pisa nem volta num ponto seguro, a busca contorna esses pontos, ninguém pega Elias num ponto seguro e quem estava num ponto que acabou de ficar seguro vai embora (`send_away`). `MAX := 3`.** Por quê: §11 e R12 do documento de direção pedem segurança que muda por noite, não um andar mágico. Fecha: Tarefa 13. Descartado: manter o refúgio com exceções por noite (dois sistemas para a mesma regra).
- [2026-11-08] (i) **Na noite 2 (`relogio_entrada`) a casa segura enquanto o relógio da entrada tem corda (`clock_model.spring > STALL_SPRING`); `entry_wound` é `null` (segue a mola) e só os testes o fixam.** Por quê: o §11 diz "segura enquanto o relógio da entrada tem corda"; uma flag ligada no primeiro toque ficava verdadeira para sempre. Fecha: noite 2. Descartado: flag `entry_wound = true` no handler do relógio.
- [2026-11-08] (i) **Na noite 3 (`comodos_com_luz`) um ponto é seguro se o cômodo dele tem uma `HouseLight` visível (`lit_rooms()` pelo `atlas.room_at`), seja qual for o brilho que o medo dá a ela.** Por quê: contar todo `OmniLight3D` vazava a luz da oficina (alcance 45) para a casa toda, e o medo apaga as lâmpadas sem desligá-las. Fecha: noite 3. Descartado: alcance da luz e energia acima de um limiar.
- [2026-11-08] (i) **O grafo de espreita liga os cômodos pelas portas: cada `Door*` (`AnimatableBody3D`) dá dois pontos de portal, 0,6 m para fora de cada lado, e os raios de visada e de encaixe ignoram as portas. Portas listadas em `keep_clear` do `DEF` (na casa, `DoorFront`) não deixam ponto a menos de `KEEP_CLEAR` (= `NEAR + 0,6`); esses pontos viram passagem: os vizinhos se ligam entre si antes de o ponto sair.** Por quê: o grafo antigo era só o quarto de brincar; e o brincar só sai pela entrada, a 1,5 m da porta da rua, então cortar o ponto separava o brincar do resto. Fecha: grafo da casa. Descartado: cortar os pontos sem ponte; tirar a porta da rua do `keep_clear`.
- [2026-11-08] (i) **Noite vazia (a visita de hoje, usada por selftest, tour e fotos) não chama Gasto na casa: `wanted()` devolve 0 com `night` vazia e `level == Registry.HOME`.** Por quê: sem o refúgio, a casa da visita ficaria cheia de Gastos e quebraria os roteiros que não são noites. Fecha: visita de hoje. Descartado: uma regra `casa_toda` implícita para a noite vazia.
- [2026-11-08] (i) **Mão esquerda e bolsos em `scripts/hands_model.gd`: o relógio é sempre de Elias (não ocupa bolso); `T` abre e fecha o relógio e fechar devolve o item de antes, se ele ainda estiver no bolso; a roda do mouse gira só pelos bolsos (`vareta`, `espelho`, `fosforo`, `lupa`, `estetoscopio`, `brinquedo`) com a mão vazia entre o último e o primeiro, nunca o relógio; o clique esquerdo emite `left_used(item)` só com algo na mão; `B` só golpeia com a mão esquerda vazia ou com a vareta.** Por quê: §6 "Mãos e bolsos" e a tabela de teclas do plano; o relógio tem tecla própria. Fecha: Tarefa 14. Descartado: o relógio como item de bolso na roda.
- [2026-11-08] (i) **O item da mão esquerda aparece como bloco colorido na mão esquerda (`hands.gd`, `ITEM_COLORS`, `held_item()`), e a mão sobe também quando segura algo; a página "bolsos" é uma linha a lápis no alto da página direita do caderno (`bolsos — relógio · fósforo ×2 · …`, `pockets_text`).** Por quê: blocos até os assets (Tarefas 35 e 39), sem grade de inventário na tela (§6). Fecha: Tarefa 14. Descartado: uma terceira página do caderno com tecla própria.
- [2026-11-08] (i) **Cada noite dá a Elias um `hands_model` novo com os itens da campanha; `end_night` leva `main.pockets` mais o que está nos bolsos do modelo (a campanha filtra pelos `CARRIED_ITEMS`).** Por quê: os pickups ainda não existem (Tarefa 27); o modelo é a fonte quando eles chegarem. Fecha: ponte entre `main.pockets` e o modelo. Descartado: trocar `main.pockets` pelo modelo agora (o selftest das noites usa a lista).
- [2026-11-08] (i) **A captura (`scripts/capture_model.gd`) avisa `broke_free` no próprio `update` em que o décimo clique chega, e o teste da Tarefa 15 conta o aviso uma vez entre os dez updates.** Por quê: o teste do plano lia o aviso num update a mais, o que contradiz o "uma vez" da interface. Fecha: teste dos 10 cliques. Descartado: atrasar o aviso para o update seguinte.
- [2026-11-08] (i) **Na luta: segurar o botão só conta no modo "segurar para se soltar" (e ali os cliques também contam, vale o maior progresso); um segundo agarrão durante o `STAGGER` é ignorado; `Tab` e `M` não abrem o caderno enquanto Elias está preso; o clique esquerdo chega ao `push` mesmo travado (sinal `player.pushed`, antes do `input_locked`).** Por quê: §10 e a interface da Tarefa 15. Fecha: regras da luta. Descartado: pausar os Gastos durante o `STAGGER`.
- [2026-11-08] (i) **`capture_fx.gd` é um `CanvasLayer` (camada 4): véu escuro que vai a no máximo 35% do caminho até `LIGHTEST` (0,75; 0,72; 0,66), alfa até 0,55, 2,5 Hz (reduzido: 1 Hz e metade da profundidade e da sacudida); a cabeça gira para o Gasto e a câmera treme por `h_offset`/`v_offset`; cada clique estende a mão (`hands.reach()`) e toca o som novo `crack` do `sfx_bank` (pico 0,42).** Por quê: §10 e §15 (acessibilidade): nunca branco, nunca rápido. Fecha: o visual da luta. Descartado: shader de tela; tremer o nó do jogador (a física o moveria).
- [2026-11-08] (i) **Ao se soltar, o Gasto se desfaz como sob a vareta (`hit()` e o estalo `shatter`) e o `main` chama `pocket_watch.lose_spring()` só se o relógio de bolso existir (Tarefa 17); no abraço, o efeito para e segue o `hug` de antes.** Por quê: o relógio de Elias ainda não existe. Fecha: Tarefa 15. Descartado: um relógio de bolso provisório.
- [2026-11-08] (i) **A bússola (`scripts/compass_model.gd`) inclina o ponteiro (`tilt` 1 ou -1) quando o alvo fica pelo menos `TILT_STEP` = 0,75 m acima ou abaixo de Elias, e aponta direto para a meta na mesma área ou para o `at` do primeiro link da rota BFS; a rota trata cada link nos dois sentidos, fechado ou não, e fica vazia com área vazia ou já no destino.** Por quê: o plano fixa o -1/0/1 mas não o limiar; 0,75 m ignora degraus e rampas e pega escada e alçapão. Fecha: Tarefa 16. Descartado: comparar só o sinal de `dy` (tremeria em chão irregular); pesar distância nos links (a rota mais curta em saltos basta para 3 a 5 áreas).
- [2026-11-08] (i) **Na noite 1, o relógio aberto na entrada aponta para a meta `achar_passagem` (6,7; 0,6; 0,3), o painel oco logo abaixo do desenho do menino (6,7; 1,6; 0,1), e não para uma meta nova `cat_desenho`.** Por quê: as duas ficam a centímetros uma da outra e, vistas da entrada, a menos de 10°; uma meta a mais quebraria `test_goals_follow_the_chapters`. Fecha: o "aponta o desenho" da Tarefa 17. Descartado: acrescentar a meta do desenho às noites.
- [2026-11-08] (i) **"Além da beira oeste" (Tarefa 17) quer dizer fora de todo cômodo do atlas (x < -3,2, a oeste da `beira_oeste`): a área fica vazia e o ponteiro gira a `SPIN` = 0,5 volta/s.** Por quê: o modelo (Tarefa 16) gira quando a área é vazia; a `beira_oeste` em si é parte da casa. Fecha: o caso "sem caminho" do relógio. Descartado: criar uma área própria para a beira.
- [2026-11-08] (i) **Relógio de bolso (`scripts/pocket_watch.gd`): cada luta multiplica o período do tique por `SPRING_LOSS` 1,3, até `SPRING_WORST` 2,0, e a noite seguinte restaura a corda; o tique toca a -6 dB aberto e -14 dB no bolso e começa 0,5 s depois do início da noite, fora do compasso do relógio da entrada; com um Gasto a menos de 6 m o ponteiro treme (±0,3 rad) e gira, sem apontar; os blocos ficam no `HANDS_LAYER` com `no_depth_test`, sem marcador no mundo.** Por quê: §7 e a interface da Tarefa 17; o plano não fixa os números. Fecha: Tarefa 17. Descartado: perda de corda permanente na campanha; tremer apontando (daria a direção mesmo com o Gasto perto).
- [2026-11-08] (i) **A carta da noite 1 usa o card de papel (`night_card_ui.show_letter`) com um sinal próprio `letter_closed`; ao fechá-la, as luzes da casa piscam três vezes e apagam, menos a `PlayroomLamp`; toda noite começa com as luzes acesas e mata os tweens do apagão.** Por quê: o `closed` do card inicia a noite seguinte, e o tween não pode vazar para a noite 2. Fecha: a apresentação da noite 1. Descartado: um card novo só para a carta.
- [2026-11-08] (i) **Mutantes aceitos como equivalentes: "no door exclude links" e "no door exclude fits" (Tarefa 13, nenhuma porta começa aberta e os portais já ligam os cômodos) "models move while held" (Tarefa 15, o `input_locked` já faz o `_process` do jogador sair), "push counts free" (o `grab` zera os cliques e o `progress` fora da luta é 0) e "hold any mode" (o `_held_for` só cresce no `hold_mode`). "grab keeps old clicks" e "crack loud" eram reais e ganharam testes (`test_a_new_fight_starts_from_no_clicks`, `test_the_crack_is_a_small_give`: o `encode` do banco corta em ±0,5 e escondia o pico).** Por quê: nenhum comportamento observável muda no jogo atual. Fecha: esses três mutantes. Descartado: testes que dependem de estados que o jogo não cria.
- [2026-11-08] (i) **O caderno trava o corpo, não o mundo: `main.world_frozen()` (abraço ou noite encerrada) é o único sinal que para os Gastos; o `input_locked` continua só para Elias.** Por quê: §8 (caderno sem pausa) e [[achados#a-026]]. Fecha: a pausa do caderno. Descartado: pausar a árvore com o caderno aberto.
- [2026-11-08] (i) **Planta (`scripts/plan_model.gd`, `scripts/fog_grid.gd`): névoa por célula de 0,5 m sobre a união dos cômodos de cada área, salva em bits e base64 no `campaign.plan`; anotações por id (o mesmo id move a anotação em vez de duplicar), dos tipos `gasto`, `item`, `barricada`, `ancora` e `giz`; um tipo desconhecido é ignorado.** Por quê: §8 pede névoa e marcas a lápis que sobrevivem entre noites, com um save pequeno. Fecha: o modelo da planta. Descartado: guardar posições soltas; uma grade única para a casa toda.
- [2026-11-08] (i) **O revelador (`scripts/plan_revealer.gd`) varre 4 vezes por segundo: 9 raios planos no FOV horizontal até 6 m (ou o alcance da lanterna, se menor), um passo de 0,25 m e uma tolerância de 0,3 m para o raio parar antes do alvo; ele anota os Gastos em vista (`gasto_<i>`) e os nós do grupo `PlanItem` com metas `item_id` e `label` (grupo que a Tarefa 27 passa a preencher).** Por quê: o plano não fixa os números; a tolerância evita que o próprio colisor do alvo esconda o alvo. Fecha: o que Elias vê entra na planta. Descartado: revelar o cômodo inteiro ao entrar.
- [2026-11-08] (i) **Abas da planta: uma por área que tenha um cômodo visitado, uma névoa aberta ou uma anotação, e sempre a área atual, na ordem do registro; ela abre na área atual, as abas são clicáveis, a seta mostra a posição e o olhar de Elias e a página se redesenha a cada 0,25 s.** Por quê: §8 (planta viva). Fecha: o desenho da Tarefa 18. Descartado: trocar de aba pelo teclado.
- [2026-11-08] (i) **Luz (`scripts/light_model.gd`): pilha de `BATTERY` 240 s, fósforo de `MATCH` 20 s (um por vez, gasto ao riscar), vela de `CANDLE` 120 s; abaixo de `LOW` 30 s a lanterna pisca por um padrão de senos até 0,25; ao zerar troca sozinha para a reserva e, sem reserva, apaga.** Por quê: o plano fixa os números e o §6 pede luz escassa sem HUD. Fecha: Tarefa 19. Descartado: medidor de bateria na tela.
- [2026-11-08] (i) **Os achados de luz ficam nos DEFs das áreas (`pickups`: `{id, kind, at, n?}`) e cada noite lista os seus em `noites.gd`; a vela é uma fonte fixa que se acende com fósforo (clique a menos de 1,6 m ou E), não um item de bolso.** Por quê: o teste exige que a soma da rota de cada noite passe dos 1800 s e que cada achado esteja dentro da sua área. Fecha: Tarefa 19. Descartado: velas carregáveis; achados aleatórios.
- [2026-11-08] (i) **Posições: casa com 3 pilhas, 3 velas e 2 caixas de 4 fósforos; passagem 1/1/1; sótão 3/3/2; mecanismo 1/1/1 acima de y 5,3; nenhum dentro da torre do térreo nem do alçapão do quarto (x 14,45–15,4; z 0–1). Noites 1 e 2 somam cerca de 1920 s de luz cada; noites 3 a 5 ficam sem achados até as tarefas delas.** Por quê: o limite de 1800 s com margem pequena mantém a escassez. Fecha: Tarefa 19. Descartado: achados para as noites 3 a 5 agora.
- [2026-11-08] (i) **A bateria só drena no modo autônomo (`_tick_light` no bloco autônomo do `_process`); o selftest chama `_tick_light` direto.** Por quê: o selftest não é autônomo e mede os passos sem o relógio da noite. Fecha: Tarefa 19.
- [2026-11-08] (i) **Velas acesas e o brilho do fósforo ficam no grupo `CandleLight`, separado de `HouseLight`; `lit_rooms` conta os dois e `gastos.add_lamp` põe as velas no olhar das lâmpadas.** Por quê: o selftest da noite 2 conta exatamente 9 `HouseLight`, e a regra `comodos_com_luz` deve valer para uma vela acesa. Fecha: Tarefa 19. Descartado: velas em `HouseLight`.
- [2026-11-08] (i) **A pilha de reserva vive em dois lugares em sincronia: `light.spare` e o item `pilha` dos bolsos (`hands.use_one` ao trocar); o começo da noite lê `spare` dos bolsos, e o achado pego sai do `PlanItem` com `plan_model.forget_item`.** Por quê: a página dos bolsos e a campanha (`carry`) já conhecem os itens; um contador só no modelo da luz se perderia entre noites. Fecha: Tarefa 19.
- [2026-11-08] (i) **O check de bolsos da Tarefa 14 passa a esperar um fósforo depois do clique: riscar gasta o fósforo.** Por quê: com a Tarefa 19 o clique esquerdo com fósforo chama `strike_match()`. Fecha: Tarefa 19.
- [2026-11-08] (i) **O ruído é ouvido por Gasto: `gastos.hear` marca cada Gasto de pé a menos do raio (distância 3D ao corpo) e só ele vai ao ponto de espreita mais perto do ruído por `NOISE_MEMORY` 10 s; os outros seguem Elias.** Por quê: um objetivo único faria Gastos surdos irem ao ruído; com a memória por Gasto, fazer barulho e se afastar quieto engana só quem ouviu. Fecha: Tarefa 20. Descartado: objetivo comum a todos.
- [2026-11-08] (i) **Escondido sem prender a respiração, o Gasto perto acha Elias em `HIDE_FOUND` 3 s contados a cada `update` (não no passo de 5 s); prendendo, vale o `HIDE_GIVE_UP` de 8 s por passos; soltar a respiração recomeça a conta de 3 s do zero.** Por quê: no ritmo do passo, 3 s virariam 5 s. Fecha: Tarefa 20.
- [2026-11-08] (i) **Respiração: segurar `H` prende; passar de 8 s dá o ofego (som `breath` e ruído LOUD na posição de Elias) e 4 s de descanso, em que apertar não prende; soltar zera a conta; o resto do descanso passa para o mesmo tique.** Por quê: o plano fixa 8 s e 4 s. Fecha: Tarefa 20.
- [2026-11-08] (i) **Níveis ligados agora: passo agachado QUIET, andar NORMAL, correr LOUD, a batida da vareta LOUD no ponto batido, a corda do relógio da entrada LOUD, o tique do relógio aberto QUIET com raio de 3 m. "Consertar" fica para quando houver conserto (mecanismos, Tarefa 23 em diante); o golpe no ar não faz ruído.** Por quê: ainda não existe ação de conserto no código. Fecha: Tarefa 20.
