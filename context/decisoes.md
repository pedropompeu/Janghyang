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
- [2026-11-08 ~superseded 2026-11-08] (i) ~~**Migração do registro concluída; `main.gd` não conhece área por nome.**~~ → precisão: `main.gd` não constrói nem mapeia área por nome; a casa é `Registry.HOME`, e só a rota de depuração "gasto" ainda cita `&"gaveta"` (ferramenta de teste, não regra). Os testes `test_main_knows_no_area_by_name` e `test_every_helper_an_area_calls_is_declared` guardam isso.
- [2026-11-08] (i) **Migração do registro concluída; `main.gd` não conhece área por nome.** Por quê: a Tarefa 8 do plano da demo fecha o anti-objetivo de área nova exigir mexer no `main.gd`; o teste `test_main_knows_no_area_by_name` guarda isso. Fecha: toda área nova entra só com um arquivo em `scripts/areas/` e uma linha em `Registry.AREAS`; a ordem do registro vale para busca de cômodo e abas da planta. Descartado: manter `ROOM_ORDER`/`LEVEL_ORDER` para preservar a ordem antiga das abas (sótão antes do mecanismo).
