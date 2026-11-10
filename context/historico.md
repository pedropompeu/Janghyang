---
tipo: contexto
projeto: jogo
descricao: Checkpoint cronológico das sessões de FAZ DE CONTA, com o que foi feito, verificado, o que ficou aberto e o próximo passo.
estado: estavel
criado: 2026-10-20
relacionado:
  - context/arquitetura.md
  - context/achados.md
  - context/discussoes/modelo-arquitetural-dinamico-3d.md
---

# Histórico de sessões {#historico}

> Registro para retomar o trabalho depois de uma pausa. Não substitui decisões
> fechadas (essas vão para [`decisoes.md`](decisoes.md)) nem o documento de design
> em [`discussoes/`](discussoes/).

## 2026-10-20 — Blockout Godot do slice {#sessao-2026-10-20}

- [2026-10-20] (d) Pedro pediu pausa no fim do dia e salvamento do histórico da sessão.
- [2026-10-20] (e) ← `faz-de-conta/` O blockout jogável em Godot 4.7.2 está construído e roda a partir de `faz-de-conta/`.
- [2026-10-20] (e) ← `godot --headless --path . -- --selftest` O autoteste terminou com `SELFTEST RESULT: 53 checks, 0 failures`.
- [2026-10-20] (e) ← `lint.py` A memória de projeto foi validada sem achados.

### O que ficou pronto

- [2026-10-20] (e) Primeira pessoa, casa caminhável, F1–F4, cinco portas, entrada, quarto de brincar, corredor, quarto de dormir, sala das figuras, passagem, ateliê e porta da rua aberta.
- [2026-10-20] (e) Portas e dobras com colisão por estado; F3 começa deitada e libera a passagem; as portas do quarto e das figuras começam fechadas.
- [2026-10-20] (e) Capturas de revisão: `faz-de-conta/blockout-playroom.png`, `blockout-corridor.png`, `blockout-atelier.png`, `blockout-fold.png` e `blockout-top.png`.
- [2026-10-20] (e) Documentação de execução, controles, telas e limites em `faz-de-conta/README.md`.
- [2026-10-20] (e) Arquitetura do projeto Godot registrada em [[arquitetura#jogo-godot]]; desenho e limites do blockout em [[modelo-arquitetural-dinamico-3d#blockout]].

### Mudanças feitas durante a validação

- [2026-10-20] (i) O banco da entrada foi movido para a parede oeste; na posição antiga ele bloqueava o retorno passagem→entrada → [[achados#a-002]].
- [2026-10-20] (i) A porta dos fundos passou a abrir para o corredor; aberta para dentro, bloqueava o caminho oeste do quarto → [[achados#a-003]].
- [2026-10-20] (i) F1 não abre mais para o vazio: existe um strip oeste do ateliê com janela, visível quando a parede dobra → [[achados#a-004]].
- [2026-10-20] (i) O abajur do ateliê foi corrigido (a base era um cilindro padrão gigante) e ganhou cúpula, cadeira e mesa legíveis.
- [2026-10-20] (i) As linhas laranja de costura das dobras foram removidas do corredor; as labels F1–F4 continuam marcando as dobras.

### Em aberto

- [2026-10-20 ~superseded 2026-10-27] (i) ~~**A cabana do F1 não é entrável:** a folga é de ~1,1 m e a cápsula do jogador tem 1,7 m. Falta decidir entre crouch/sentada, parede mais baixa ou cabana apenas visual~~ → resolvido em [[historico#sessao-2026-10-27]] e [[achados#a-001]].
- [2026-10-20] (i) A porta dos fundos aberta para o corredor deixa ~0,7 m de folga; validar em playtest se o aperto é horror ou fricção.
- [2026-10-20] (i) **Não há áudio** no blockout. O roteiro de som existe no documento de design, mas nenhum som foi produzido ou integrado.
- [2026-10-20] (i) **Não há comportamento da casa** — ela ainda não aprende dobras, passos, melodia ou postura, e não devolve gestos.
- [2026-10-20] (i) O blockout valida o espaço em poucos minutos; o slice de 15–20 minutos com as três cenas, som e respostas da casa ainda não está implementado.

### Próximo passo

1. [2026-10-20 ~superseded 2026-10-27] (i) ~~Pedro joga o blockout e responde: a cabana do F1 deve ser entrável? A porta dos fundos abre para o quarto ou para o corredor? A escala, a velocidade e o laço parecem certos?~~ → Pedro jogou e aprovou o blockout; ver [[historico#sessao-2026-10-27]].
2. [2026-10-20 ~superseded 2026-10-27] (i) ~~Fechar a decisão da cabana no documento de design e, se for entrável, implementar crouch/sentada no controlador.~~ → feito na Tarefa 1 de 2026-10-27.
3. [2026-10-20] (i) Implementar a primeira camada de som diegético e os pares visuais dos oito pontos, sem trilha e sem sustos.
4. [2026-10-20] (i) Implementar o comportamento-espelho mínimo (dobra e passos) antes do boneco e da escalada da cena 2.
5. [2026-10-20] (i) Rodar `godot --headless --path . -- --selftest`, `python lint.py` e refazer as capturas ao fim da próxima sessão.

### Comandos para retomar

```bash
cd /home/usuario/Dev/Jogo/faz-de-conta
godot --path .
godot --headless --path . -- --selftest
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-playroom
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-top
cd /home/usuario/Dev/Jogo && python lint.py
```

- [2026-10-20] (e) O diretório não é um repositório Git; não houve commit nem push.

## 2026-10-27 — História, design e início da construção {#sessao-2026-10-27}

- [2026-10-27] (d) Pedro jogou o blockout e gostou ("não tem nada que me incomoda"); faltavam história e objetivo.
- [2026-10-27] (d) Pedro trouxe o conto do relojoeiro (`fontes/2026-10-27-pedro-conto-relojoeiro.md`) e aprovou o design que junta FAZ DE CONTA e o conto → [[decisoes#jogo]].
- [2026-10-27] (e) ← `docs/superpowers/specs/2026-10-27-faz-de-conta-relojoeiro-design.md` Design aprovado: Elias cataloga a maquete do espólio de Inácio Varela, dá corda no relógio da entrada, vive o 03:33 sem perseguição, descobre a verdade sobre Inácio e sai pela beira do tampo deixando algo seu na maquete.
- [2026-10-27] (e) ← `docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md` Plano de implementação em 15 tarefas, executado em linha com TDD.
- [2026-10-27] (d) Pedro pediu pausa no fim do dia, documentação do que foi feito e retomada amanhã a partir da próxima tarefa.

### O que ficou pronto

- [2026-10-27] (e) ← `faz-de-conta/scripts/player.gd`, `main.gd` **Tarefa 1 — agachar e cabana entrável:** `C` agacha (cápsula 1,0 m, olho 0,92 m); F1 dobra a −45° e não se move com o jogador dentro; ele não levanta sob a dobra → [[achados#a-001]].
- [2026-10-27] (e) ← `faz-de-conta/scripts/main.gd` (`_build_tampo`, `_build_oficina`) **Tarefa 2 — o espaço:** Elias nasce na entrada (`SPAWN` 1,8; 0,2; 8,3) olhando para dentro; o antigo ateliê virou o `Tampo` da bancada, com paredes de vidro (`mat_glass`) e a mesma colisão; `Redoma` de vidro sobre a maquete; `Oficina` gigante (escala 12×) sem colisão, com janela de chuva e luminária; `ExitEdge` na beira sul do tampo emite `exit_edge_reached`; as labels de blockout só aparecem com `--labels`; o reset de queda usa `respawn_point`.
- [2026-10-27] (e) ← `faz-de-conta/tests/run_unit.gd`, `tests/test_wind_clock.gd`, `scripts/wind_clock_model.gd`, `scripts/entry_clock.gd` **Tarefa 3 — harness unitário e relógio da entrada:** harness headless para os modelos puros; `WindClockModel` (corda que rende cada vez menos, trava sem parar até ser autorizado, mostra 03:00→03:33, tique que atrasa); relógio de caixa ao lado da porta da rua com prompt "dar corda", ponteiro dos minutos e pêndulo.

### Verificado

- [2026-10-27] (e) ← `godot --headless --path . -- --selftest` `SELFTEST RESULT: 66 checks, 0 failures`.
- [2026-10-27] (e) ← `godot --headless --path . -s res://tests/run_unit.gd` `UNIT RESULT: 414 checks, 0 failures`.
- [2026-10-27] (e) ← `python lint.py` "nada a reportar".
- [2026-10-27] (e) ← `faz-de-conta/blockout-atelier.png` Captura refeita: mostra o tampo, a engrenagem e o lápis gigantes e o vidro da redoma.

### Em aberto

- [2026-10-27] (i) A oficina gigante aparece escura atrás do vidro; avaliar no jogo se a luminária precisa de mais energia para ser lida.
- [2026-10-27] (i) O relógio da entrada ainda não foi visto numa captura; conferir posição e leitura dos ponteiros ao abrir o jogo.
- [2026-10-27] (i) Achados novos de teste: [[achados#a-005]] e [[achados#a-006]].
- [2026-10-27] (i) Não há git no projeto; as tarefas terminam em checkpoint (selftest + unit + lint), sem commit. O ledger de execução (`progress.md`) e o backup pré-plano estão em `.superpowers/sdd/2026-10-27-faz-de-conta-relojoeiro/`.

### Próximo passo

1. [2026-10-27] (i) Retomar o plano na **Tarefa 4 (catálogo, `Q`, itens a partir de 214)** e seguir até a 15, uma por vez, com TDD e checkpoint.
2. [2026-10-27] (i) Ao fim das 15 tarefas: revisão final do conjunto com o Review Focus do plano, uma passada de correções e o relatório das decisões tomadas.
3. [2026-10-27] (i) Antes de retomar, abrir o jogo uma vez (`godot --path .`) para ver o tampo, a redoma e o relógio.

### Comandos para retomar

```bash
cd /home/usuario/Dev/Jogo/faz-de-conta
godot --path .                                          # jogar (acrescente -- --labels para as labels)
timeout 150 godot --headless --path . -- --selftest     # 66 checks
timeout 60 godot --headless --path . -s res://tests/run_unit.gd   # 414 checks
cd /home/usuario/Dev/Jogo && python lint.py
```

## 2026-10-28 — Plano do relojoeiro concluído (Tarefas 4–15) {#sessao-2026-10-28}

### O que ficou pronto

- [2026-10-28] (e) ← `docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md` Tarefas 4 a 15: catálogo (`Q`) e caderno (`Tab`), atos da visita, som sintetizado, gravador de ecos, espelho da casa e do quarto, o 03:33 (ecos, tempo voltando, coisas das frestas, duplo escrevendo), provas sobre Inácio, corpo gigante de Elias, a saída pela beira do tampo com três desfechos e a figura nova que fica na maquete.
- [2026-10-28] (e) ← `faz-de-conta/README.md` README reescrito: o slice em 5 linhas, controles, comandos de teste e capturas.
- [2026-10-28] (e) ← `.superpowers/sdd/2026-10-27-faz-de-conta-relojoeiro/progress.md` Cada divergência do plano está registrada como `Ruling:` no ledger.

### Verificado

- [2026-10-28] (e) ← `godot --headless --path . -s res://tests/run_unit.gd` `UNIT RESULT: 676 checks, 0 failures` (depois das correções da revisão final).
- [2026-10-28] (e) ← `godot --headless --path . -- --selftest` `SELFTEST RESULT: 151 checks, 0 failures` (idem).
- [2026-10-28] (e) ← revisão final (revisor novo, Opus) Veredito "com correções": [[achados#a-009]], [[achados#a-010]], [[achados#a-011]] e [[achados#a-012]] corrigidos com teste; [[achados#a-013]], [[achados#a-014]] e [[achados#a-015]] ficaram abertos.
- [2026-10-28] (e) ← `python lint.py` "nada a reportar".
- [2026-10-28] (e) ← `faz-de-conta/blockout-hour.png`, `blockout-double.png`, `blockout-giant.png`, `blockout-ending.png` Capturas do 03:33, do duplo no banco, do gigante e da imagem final (figura nova vista pela porta da rua).

### Em aberto

- [2026-10-28] (i) Playtest humano dos três finais (sair cedo; sem corda depois do 03:33; com corda depois da página da cabana), do reconhecimento dos próprios trajetos nos ecos e do `F9`.
- [2026-10-28] (i) O gigante e a oficina ficam muito escuros na captura `giant`; avaliar a luz da oficina no jogo.

### Próximo passo

1. [2026-10-28] (i) Pedro joga os três finais e diz se a imagem final, os textos e o ritmo do relógio funcionam.

### Comandos para retomar

```bash
cd /home/usuario/Dev/Jogo/faz-de-conta
godot --path .                                                    # jogar (F9 em debug leva ao 03:33)
timeout 150 godot --headless --path . -- --selftest               # 151 checks
timeout 60 godot --headless --path . -s res://tests/run_unit.gd   # 676 checks
cd /home/usuario/Dev/Jogo && python lint.py
```

## 2026-10-28 — Mãos, vareta e clima de terror {#sessao-2026-10-28-maos}

### O que ficou pronto

- [2026-10-28] (e) ← `faz-de-conta/scripts/hands.gd` Elias tem mãos em primeira pessoa:
  - a direita segura uma vareta de tília e bate com `B`, num golpe com recuo;
  - a esquerda segura a lanterna e alcança o que `E` toca;
  - balançam ao andar, atrasam ao virar e baixam com o caderno e no final.
- [2026-10-28] (e) ← `faz-de-conta/scripts/dread.gd` A casa tem humor: luzes que baixam, neblina, zumbido, respiração, vinheta com grão, rangidos distantes e piscadas; tudo segue a tensão da visita. Ver [[decisoes#jogo]].
- [2026-10-28] (e) ← `faz-de-conta/scripts/sfx_bank.gd` Novos sons sintetizados: `creak` e `swish`. O `knock` virou toque de vareta.
- [2026-10-28] (e) ← `faz-de-conta/README.md` Controles, a seção "O clima da casa", o modo `dread` e a estrutura atualizados.

### Verificado

- [2026-10-28] (e) ← `cp.sh` `UNIT RESULT: 763 checks, 0 failures`; `SELFTEST RESULT: 173 checks, 0 failures`; lint "nada a reportar".
- [2026-10-28] (e) ← `faz-de-conta/blockout-corridor.png`, `blockout-dread.png`, `blockout-playroom.png` As mãos aparecem iluminadas pela casa. O corredor em tensão 0,9 fica mais escuro e com as bordas fechadas, mas ainda legível.

### Em aberto

- [2026-10-28] (i) Playtest da sensação: peso e tempo do golpe, volume do zumbido e dos rangidos, quanto escuro é escuro demais, se a vinheta incomoda.
- [2026-10-28] (i) As mãos são caixas de blockout; a arte final fica para depois.

### Próximo passo

1. [2026-10-28] (i) Pedro joga uma visita inteira e diz se o golpe e o clima funcionam; os números ficam em `dread_model.gd` e as poses no topo de `hands.gd`.

### Comandos para retomar

```bash
cd /home/usuario/Dev/Jogo/faz-de-conta
godot --path .                                                    # jogar
timeout 150 godot --headless --path . -- --selftest               # 173 checks
timeout 60 godot --headless --path . -s res://tests/run_unit.gd   # 763 checks
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-dread   # corredor em tensão
cd /home/usuario/Dev/Jogo && python lint.py
```

## [2026-10-28] Expansão "propósito e imersão" — PAUSADA no meio

- [2026-10-28] (d) Pedro pediu a expansão (mapa maior, história, tarefas, fases, monstros humanoides, bater em coisas, mobilidade, música, passagens secretas, portas que rangem, vários ambientes, mapa) e disse "precisa ser imersivo… pode seguir trabalhando sem fazer perguntas". Spec: `docs/superpowers/specs/2026-10-28-faz-de-conta-expansao-design.md`.
- [2026-10-28] (d) Pedro pediu pausa para dormir; retomar amanhã daqui.

### Pronto (testado, unit 1009/0)

- [2026-10-28] (e) Modelos: `stalker_model.gd`, `mobility_model.gd`, `atlas.gd`, `quest_model.gd`, `score_model.gd`, `score.gd` (ainda não instanciado), `breakable.gd`, `ladder.gd`, `piece.gd`, `turning_gear.gd`; portão do 03:33 por peças ou 60 min em `visit_state.gd`; itens e notas novos em `catalog_data.gd`.
- [2026-10-28] (e) Correr (Shift), pular (Espaço), escadas, fazer de conta (V/botão direito) já existem no `player.gd`.
- [2026-10-28] (e) Ambientes escritos mas AINDA NÃO chamados em `main.gd`: `scripts/areas/passagem.gd`, `sotao.gd` (sótão + torre do relógio), `gaveta.gd` (gaveta sob a bancada, dedal, mostrador).

### Estado no momento da pausa

- [2026-10-28] (e) Unit 1009/0; lint limpo; selftest 173 com 2 falhas ESPERADAS ("every item … has a target"): os itens novos do catálogo só ganham alvo quando os ambientes forem montados.
- [2026-10-28] (e) Removido temporariamente de `main.gd` o `preload` de `scripts/areas/leste.gd` (arquivo ainda não existe), para o jogo abrir.

### Próximo passo (em ordem)

1. [2026-10-28] (i) Escrever `scripts/areas/leste.gd` (Relojoaria Varela: loja, balcão-esconderijo, xícaras quebráveis, relógios de parede + alvo `relogios_varela`, manequim de vitrine, letreiro, oficina dos fundos com a peça `caixa`) e recolocar o `preload` `AreaLeste`.
2. [2026-10-28] (i) Em `main.gd`: abrir a parede norte do quarto de brincar + `HollowPanel`; dividir o piso do quarto + `Trapdoor`; vidro leste do tampo + `CrackedGlass`; furo no tampo da oficina; ajustar a redoma; chamar os quatro `Area*.build(self)` depois de `_build_oficina`; esconderijos da cabana e do vão da cama; diminuir o retângulo da passagem no `atlas.gd` para `Rect2(0.3,-1.3,10.1,1.3)`.
3. [2026-10-28] (i) Bater em quebráveis no handler de `bater`; depois `gastos.gd` (monstros + abraço/captura), `pretend.gd` (pálpebras, sépia, giz), ligar quest/atlas/score, página do mapa (M) e dos lotes no caderno, texto de ajuda, selftests novos, tour, README, docs de contexto, lint, relatório final e alarme.

## [2026-10-29] Expansão "propósito e imersão" — retomada e ligada {#sessao-2026-10-29-expansao}

- [2026-10-29] (d) Pedro disse "vamos voltar a trabalhar": retomar a expansão do ponto da pausa de [[historico#sessao-2026-10-28-maos]] em diante, sem perguntas (vale o pedido de 2026-10-28).

### O que ficou pronto

- [2026-10-29] (e) ← `faz-de-conta/scripts/areas/leste.gd` Relojoaria Varela (loja, balcão-esconderijo, xícaras quebráveis, relógios de parede, oficina dos fundos com a caixa) e os quatro `Area*.build(self)` chamados em `main.gd`, com painel oco, alçapão e vidro rachado da redoma.
- [2026-10-29] (e) ← `faz-de-conta/scripts/main.gd` `bater` agora quebra o que é `Breakable` (`_knock_on`, sinal `knock_sounded`) e quebra Gastos (camada 8 no raio do jogador).
- [2026-10-29] (e) ← `faz-de-conta/scripts/gastos.gd`, `pretend.gd` Novos: os Gastos (grafo de espreita amostrado por andar, corpos de porcelana, abraço) e o fazer de conta (pálpebras, sépia, giz, Gastos velados).
- [2026-10-29] (e) ← `faz-de-conta/scripts/main.gd` `_wire_story`: peça → caderno → lote; quebras e catalogações completam lotes; troca de andar move o ponto seguro e os Gastos; `hug()`; `score_inputs()` alimenta a trilha (`score.gd` agora instanciado).
- [2026-10-29] (e) ← `faz-de-conta/scripts/notebook_ui.gd` `M` abre o caderno nos lotes (feitos riscados, só fases alcançadas) e no plano (só cômodos visitados, abas por andar, escala fixa de 20 px/m, um x para Elias).
- [2026-10-29] (e) ← `faz-de-conta/scripts/tour.gd`, `README.md` O tour quebra o painel oco, faz de conta e abre o plano; o README ganhou a história em cinco lotes, os Gastos, as teclas novas e os modos de captura `leste`, `shop`, `dome`, `plano`, `gasto`.

### Verificado

- [2026-10-29] (e) ← `cp.sh` `UNIT RESULT: 1040 checks, 0 failures`; `SELFTEST RESULT: 230 checks, 0 failures` em três rodadas seguidas; lint "nada a reportar".
- [2026-10-29] (e) ← `faz-de-conta/blockout-plano.png`, `blockout-gasto.png`, `blockout-shop.png`, `blockout-dome.png`, `blockout-leste.png` Revisadas a olho: plano legível, Gasto lê como manequim rachado sob a lanterna.
- [2026-10-29] (e) ← `godot --path . -- --tour` O tour roda até o fim sem erro de script.

### Em aberto

- [2026-10-29] (i) Nenhum playtest humano da expansão: ritmo dos Gastos (`STEP_TIME` 5 s, cego 1,2 s), dificuldade da torre e o medo real ainda não foram sentidos por ninguém.
- [2026-10-29] (i) Faltam selftests de rota completa (casa → passagem → sótão → torre; casa → gaveta; tampo → relojoaria) com cápsula, como os do laço.
- [2026-10-29] (i) Ver [[achados#a-017]].

### Próximo passo

1. [2026-10-29] (i) Playtest de Pedro com o caminho do README; anotar onde o Gasto assusta e onde irrita.
2. [2026-10-29] (i) Selftests de rota pelos quatro ambientes.

### Comandos para retomar

```bash
cd /home/usuario/Dev/Jogo/faz-de-conta
godot --path .                                                    # jogar
godot --path . -- --tour                                          # demonstração
timeout 150 godot --headless --path . -- --selftest               # 230 checks
timeout 60 godot --headless --path . -s res://tests/run_unit.gd   # 1040 checks
DISPLAY=:0 godot --path . --resolution 1280x720 -- --shot-gasto   # um Gasto na gaveta
cd /home/usuario/Dev/Jogo && python lint.py
```

### Opções (mesma sessão)

- [2026-10-29] (d) Pedro perguntou "e os settings?" depois do relatório da expansão.
- [2026-10-29] (e) ← `faz-de-conta/scripts/settings_ui.gd` O jogo não tinha opções; agora `Esc` pausa e abre a folha de opções (ver [[decisoes#jogo]]). Captura `blockout-opcoes.png` revisada a olho.
- [2026-10-29] (e) ← `cp.sh` `UNIT RESULT: 1059 checks, 0 failures`; `SELFTEST RESULT: 241 checks, 0 failures`; lint limpo.
- [2026-10-29] (i) Em aberto: testar no jogo de verdade o `Esc` com o caderno aberto e a tela cheia no monitor do Pedro (o selftest roda headless e não cobre janela nem mouse).

## [2026-11-08] Rumo do jogo: diagnóstico e escolhas de Pedro {#sessao-2026-11-08-rumo}

- [2026-11-08] (d) Pedro: "falta uma história, um foco, um direcionamento, o mapa é limitado (tambem mostrar um mapa), falta coisas a serem feitas".
- [2026-11-08] (e) ← `https://claude.ai/artifact/7oxdgaNJ7jCpB5CPPNxedb` Página "Rumo do Janghyang": diagnóstico, planta dos 15 cômodos a partir de `scripts/atlas.gd` e nove decisões com recomendação. Ela guarda as escolhas na coleção `escolhas`.
- [2026-11-08] (e) ← `fontes/2026-11-08-pedro-escolhas-rumo.md` Pedro respondeu as nove; registradas como R1–R9 em [[decisoes#rumo-2026-11-08]].

### Em aberto

- [2026-11-08] (i) Perguntas que mudam o que se constrói: [[rumo-2026-11]].
- [2026-11-08] (i) O plano de lançamento de 2026-11-07 ficou desatualizado em alvo (R2), escopo (R1) e restrição de assets (R9).
- [2026-11-08] (i) Nenhum playtest humano até hoje.

### Próximo passo

1. [2026-11-08 ~superseded 2026-11-08] (i) ~~Pedro responde as perguntas de [[rumo-2026-11]].~~ → respondidas em R10–R15; só os sustos com estouro de volume seguem abertos.
2. [2026-11-08 ~superseded 2026-11-08] (i) ~~Documento de direção: capítulos, maquetes e noites, ações, bússola, planta, pipeline de assets; depois, plano novo no lugar do de 2026-11-07.~~ → escrito; ver [[#sessao-2026-11-08-direcao]].

## [2026-11-08] Documento de direção {#sessao-2026-11-08-direcao}

- [2026-11-08] (d) Pedro: "pode começar o documento de direção".
- [2026-11-08] (e) ← `docs/superpowers/specs/2026-11-08-janghyang-direcao-design.md` Escrito a partir de R1–R15: noites e maquetes, sete capítulos, a bússola, a planta em tempo real, as onze ações, a captura, a curva de segurança da casa, o registro de áreas, os sustos, o fluxo de assets e o recorte da demo (noites 1 e 2).
- [2026-11-08] (i) Tudo marcado [escolha da IA] no documento espera a leitura de Pedro, em especial o conteúdo novo dos capítulos e a mansão como terceira maquete (Item 216, com os 3 cômodos novos).
- [2026-11-08] (e) ← OpenCode (agente `consult`, sessão ses_e443c8982ffex4tasIyPlyBlka) Leitura de construtor: 14 pontos. Doze foram resolvidos no documento como [escolha da IA]: segurança por ponto no lugar de `REFUGE`, sobreposição torre/sótão, caderno sem pausa, termos nível/área/cômodo, gatilho do 03:33 por noite, rota da bússola, `capture_model`, grade da névoa, contrato do registro, encenação, névoa volumétrica ausente em Compatibility e a justificativa do `preload`. O risco da demo (22 semanas para onze ações) ficou no §15, com uma ordem que antecipa o primeiro playtest; o recorte das ações é pergunta para Pedro (§20).

### Próximo passo

1. [2026-11-08 ~superseded 2026-11-08] (i) ~~Pedro lê e aprova o documento de direção, ou pede mudanças.~~ → aprovado; ver [[#sessao-2026-11-08-plano-demo]].
2. [2026-11-08 ~superseded 2026-11-08] (i) ~~Depois da aprovação: plano novo (superpowers:writing-plans) no lugar de `docs/superpowers/plans/2026-11-07-janghyang-lancamento.md`.~~ → escrito; ver [[#sessao-2026-11-08-plano-demo]].

## [2026-11-08] Plano da demo {#sessao-2026-11-08-plano-demo}

- [2026-11-08] (d) Pedro: "aprovado, pode escrever o plano".
- [2026-11-08] (e) ← `docs/superpowers/plans/2026-11-08-janghyang-demo.md` 47 tarefas em nove fases: preparação, registro de áreas, noites e campanha, noite 1 em blocos, playtest 1, noite 2, assets, playtests 2 e 3, lançamento. Marcos M1 2026-11-29 a M5 2027-04-15 (datas sugeridas pela IA).
- [2026-11-08] (e) ← `ls ~/.local/share/godot/export_templates/` Os templates 4.7.2.stable já estão instalados; a U02 do plano antigo está resolvida.
- [2026-11-08] (e) ← `docs/superpowers/plans/2026-11-07-janghyang-lancamento.md` Marcado como superado, com as unidades abertas mapeadas no §0.3 do plano novo.

### Próximo passo

1. [2026-11-08 ~superseded 2026-11-08] (i) ~~Pedro revisa o plano e escolhe o método de execução (subagent-driven ou nativo).~~ → formato misto com Claude como gestor; ver [[decisoes#rumo-2026-11-08]].
2. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 1 do plano: ledger e linha de base.~~ → feita: unidade 1093/0, selftest 282/0, lint ok, templates 4.7.2.stable presentes.
3. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 2: testes herdados U30 e U31.~~ → os testes já existiam desde 2026-11-07 (`e430d7b`, `af3a440`); a prova por mutante pegou os dois (24 caminhos presos; 4 falhas na quebrável).
4. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 3: esqueleto do registro de áreas e contrato dos helpers.~~ → feita: `scripts/areas/registry.gd`, atlas e mapas de `main.gd` mesclados; unidade 1139/0, selftest 282/0; mutantes pegos (aridade de `_box`; torre trocada com o sótão).
5. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 4: migrar a passagem para o registro.~~ → feita: `passagem.gd` com `DEF` (safe fora dela, em `brincar`, via `safe_room`); `main._ready` constrói `Registry.AREAS` em laço; unidade 1161/0, selftest 282/0.
6. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 5: migrar o sótão e a torre.~~ → feita: `mecanismo.gd` novo com a torre (antes em `sotao.gd`); gate da torre é `DoorTower`; unidade 1196/0, selftest 282/0.
7. [2026-11-08 ~superseded 2026-11-08] (i) ~~Endurecer os testes do registro (revisão do OpenCode no T3) e seguir para a Tarefa 6, a gaveta.~~ → feito: `2ddc8c7` (sobreposições fixadas, chaves obrigatórias do `DEF`, mapas de lotes) e Tarefa 6 com a gaveta no registro; unidade 1250/0, selftest 282/0.
8. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 7: migrar o tampo (relojoaria, oficina dos fundos e bancada).~~ → feita: `tampo.gd` com a oficina gigante e o `leste.gd`; a redoma e o vidro rachado ficam para `casa.gd` (maquete item_214); unidade 1285/0, selftest 282/0.
9. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 8: migrar a casa e fechar a migração.~~ → feita: `casa.gd` com a casa, os móveis, o relógio, as peças da verdade e a redoma; `atlas.gd` e `main.gd` leem só o registro; unidade 1368/0, selftest 282/0.
10. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 9: maquetes e rota genérica no selftest.~~ → feita: `scripts/maquetes/registry.gd` e `_routes_by_links()`; unidade 1397/0, selftest 304/0.
11. [2026-11-08 ~superseded 2026-11-08] (i) ~~Revisão do OpenCode sobre a migração (T4–T8), depois a Tarefa 10: as noites como dados e a campanha com save.~~ → revisão aplicada: contrato inverso dos helpers (`_loop_3d`), `Registry.HOME`, `PANEL` na casa, `in_bedroom` pelo atlas ([[achados#a-020]]), materiais mortos fora; unidade 1778/0, selftest 304/0.
12. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 10: as noites como dados e a campanha com save.~~ → feita: `scripts/story/noites.gd` e `scripts/campaign_model.gd`; unidade 1961/0, selftest 304/0.
13. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 11: o estado de uma noite e o 03:33 curto.~~ → feita: `VisitState` recebe a noite, o 03:33 das noites 1 a 4 abre com as metas cumpridas e Elias no térreo e acaba sozinho em 90 s ou na corda (`night_over`); unidade 1990/0, selftest 304/0.
14. [2026-11-08 ~superseded 2026-11-08] (i) ~~Revisão do OpenCode sobre a T10 e Tarefa 12: o laço das noites no `main`.~~ → feitas: revisão aplicada em `d37ed59` ([[achados#a-021]]); o jogo roda em noites, com save entre elas, o card de papel, `--night N` e o 03:33 curto; unidade 2039/0, selftest 324/0.
15. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 13: a casa deixa de ser refúgio fixo (segurança por ponto), com o OpenCode construindo e o Gemini revisando.~~ → feita na sessão principal (os dois sem cota grátis), revisor Claude: segurança por ponto e por noite, portais nas portas ([[achados#a-023]], [[achados#a-024]]); unidade 2071/0, selftest 349/0.
16. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 14: mãos e bolsos.~~ → feita na sessão principal: `hands_model.gd`, `T`, roda e clique esquerdo, página "bolsos" ([[achados#a-025]]); unidade 2106/0, selftest 356/0.
17. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 15: a captura com fuga.~~ → feita na sessão principal: `capture_model.gd`, `capture_fx.gd`, opções de acessibilidade, som `crack` ([[achados#a-026]]); unidade 2155/0, selftest 373/0.
18. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 16: o modelo da bússola.~~ → feita na sessão principal: `compass_model.gd` (rota BFS, mira, tique, tremor); unidade 2183/0.
19. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 17: o relógio de Elias na mão e a apresentação da noite 1.~~ → feita na sessão principal: `pocket_watch.gd`, carta e apagão da noite 1, mutantes da T15 fechados; unidade 2188/0, selftest 393/0. Captura `blockout-watch.png` para o checkpoint D7.
20. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 18: a planta com névoa e o caderno sem pausa (fecha [[achados#a-026]]).~~ → feita na sessão principal: `fog_grid.gd`, `plan_model.gd`, `plan_revealer.gd`, abas clicáveis e o caderno sem pausa; unidade 2224/0, selftest 396/0.
21. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 19: luz escassa.~~ → feita na sessão principal: `light_model.gd`, `light_pickup.gd`, pilhas, fósforos e velas por noite; unidade 2363/0, selftest 408/0.
22. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 20: ruído, esconderijo e respiração.~~ → feita na sessão principal: `noise_model.gd`, `HIDE_FOUND`, Gastos que ouvem e o `H`; unidade 2393/0, selftest 412/0.
23. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 21: o giz.~~ → feita na sessão principal: marcas de Elias com G (limite de 20 na planta) e três trilhas do menino na noite 1; unidade 2402/0, selftest 421/0.
24. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 22: escutar pela parede.~~ → feita na sessão principal: L junto à parede abafa a casa 18 dB, Elias para e cada Gasto audível estala onde está a cada 1,5 s; o estetoscópio na mão ouve através dos andares; unidade 2419/0, selftest 429/0.
25. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 23: capítulos 1 e 2 (pistas, encenação e hipótese).~~ → feita na sessão principal: as pistas abrem a encenação, as figuras andam só sem ser vistas e terminam no painel/na coroa, e o caderno ganha a página com três hipóteses (a errada fica riscada); unidade 2459/0, selftest 442/0.
26. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 24: o diretor de sustos.~~ → feita na sessão principal: um forte por minuto, 20 s entre fracos, 8 s de silêncio antes de qualquer um, nenhum no 03:33, forte do mesmo tipo uma vez por noite; a lâmpada e a lanterna do `dread` pedem licença; unidade 2486/0, selftest 446/0.
27. [2026-11-08 ~superseded 2026-11-08] (i) ~~Tarefa 25: o registro do playtest e o roteiro.~~ → feita na sessão principal: `--playtest` grava o CSV a cada 5 s e marca 3 minutos perdido; roteiro em [[playtest-1]]; export Linux com selftest; unidade 2502/0, selftest 449/0.
28. [2026-11-08] (i) Tarefa 26: Pedro conduz de 3 a 5 sessões do playtest 1 (D12), com `--playtest`, seguindo [[playtest-1]].

## [2026-11-08] Noite 1 em blocos pronta; pausa antes do playtest 1 {#sessao-2026-11-08-pausa-playtest-1}

- [2026-11-08] (e) ← `git log` Tarefas 1 a 25 do plano da demo concluídas e enviadas ao `main` (último commit `80182ba`). Marcos M1 (registro inteiro) e M2 (noite 1 jogável em blocos) fechados antes das datas sugeridas (2026-11-29 e 2026-12-23).
- [2026-11-08] (e) ← `run_unit.gd`, `--selftest`, `lint.py` Unidade 2502/0, selftest 449/0 (também no binário Linux exportado), lint ok.
- [2026-11-08] (e) ← `Janghyang/README.md` Reescrito para o jogo de hoje: noites, capítulos, controles novos (T, G, L, H, roda do mouse), `--night`, `--playtest`, export Linux, sustos, verificação e estrutura.
- [2026-11-08] (d) Pedro: "siga com o recomendado faça o push": os `.uid` dos scripts novos foram versionados, seguindo `4bb6210`.

### Em aberto

- [2026-11-08] (i) **D12, o playtest 1:** quem joga e quando. É o que destrava a T27 (triagem). Pela ordem da spec §15, também destrava as ações da noite 2 (T28 a T33).
- [2026-11-08 ~superseded 2026-11-09] (i) ~~**D9, os textos:** as três hipóteses dos capítulos 1 e 2 foram mostradas a Pedro e esperam a leitura dele; a carta e os títulos seguem em rascunho.~~ → [[historico#sessao-2026-11-09-hipoteses]].
- [2026-11-08] (i) **D7, a aprovação visual:** `blockout-watch.png` espera Pedro; trava as T34 a T40 e a T43.
- [2026-11-08] (i) **D1, D3, D4, D5** (plataforma, nome, idiomas, preço) só travam as T44 a T47; os defaults do plano valem até lá.
- [2026-11-08] (i) **D10, sustos com estouro de volume:** default "não", `revisar: 2026-11-22`.

### Próximo passo

1. [2026-11-08 ~superseded 2026-11-09] (i) ~~Pedro lê as hipóteses (D9) e diz se alguma frase ou a resposta certa muda.~~ → [[decisoes#d9-hipoteses]].
2. [2026-11-08] (i) Pedro decide se as T28 a T33 (noite 2) começam já ou só depois do playtest 1, como manda a ordem da spec §15. Começar já adianta o calendário, mas arrisca retrabalho se o playtest mudar a bússola, a captura ou a luz.
3. [2026-11-08] (i) Pedro conduz o playtest 1 ([[playtest-1]]), com os CSVs e as notas brutos em `fontes/`.

## [2026-11-09] Hipóteses dos capítulos 1 e 2 revisadas {#sessao-2026-11-09-hipoteses}

- [2026-11-09] (d) Pedro aprovou ("pode aplicar") a reescrita das hipóteses dos capítulos 1 e 2, mantendo as respostas certas: [[decisoes#d9-hipoteses]].
- [2026-11-09] (e) ← `run_unit.gd`, `--selftest` Unidade 2502/0, selftest 449/0, sem teste a mudar: os testes leem as frases de `noites.gd`.

### Em aberto

- [2026-11-09] (i) **D9, o resto:** a carta, os títulos e os textos das noites 3 a 5 seguem em rascunho.
- [2026-11-09] (i) **D12, D7, D1, D3, D4, D5 e D10** continuam como em [[historico#sessao-2026-11-08-pausa-playtest-1]].

### Próximo passo

1. [2026-11-09] (i) Pedro decide se as T28 a T33 (noite 2) começam já ou só depois do playtest 1.
2. [2026-11-09] (i) Pedro conduz o playtest 1 ([[playtest-1]]) e aprova o `blockout-watch.png` (D7).

## [2026-11-09] Figuras de porcelana no lugar das caixas {#sessao-2026-11-09-figuras}

- [2026-11-09] (d) Pedro pediu figuras humanas mais reais antes do playtest 1 e mandou pular as perguntas: [[decisoes#figuras-porcelana]].
- [2026-11-09] (e) ← `arte/blender/figuras.py`, `Janghyang/assets/` Três corpos de porcelana (adulto, menino, Gasto) feitos da malha CC0 Human Base Meshes, ligados ao `mannequin.gd` sem mudar a API; sem o `.glb`, voltam as caixas. Mapa em [[arquitetura#assets-figuras]].
- [2026-11-09] (e) ← `run_unit.gd`, `--selftest` Unidade 2545/0, selftest 450/0. Dois bugs achados e corrigidos no caminho: [[achados#a-027]] (material nulo ao soltar uma figura) e [[achados#a-028]] (a figura do final aparecia em pé).
- [2026-11-09] (e) ← medida descartável com vsync desligado Cena do capítulo 1: 268,1 fps com as figuras contra 285,5 com as caixas (−6%); vista de cima sem diferença.
- [2026-11-09] (e) ← shots `figuras`, `figuras_fim`, `gasto`, `giant`, `mirror` e `ending`, conferidos à mão. Os `blockout-*.png` versionados não foram trocados.

### Em aberto

- [2026-11-09 ~superseded 2026-11-09] (i) ~~**Sobras de arte:** [[achados#a-029]] (vinco do sapato, rosto do menino, o pai sentado no ar no capítulo 1).~~ → o pai senta num banquinho; seguem o sapato e o rosto ([[achados#a-029]]).
- [2026-11-09 ~superseded 2026-11-09] (i) ~~**Commit:** as mudanças das hipóteses (sessão anterior) e as figuras esperam o sinal de Pedro.~~ → Pedro: "pode fazer"; commitado em dois commits, hipóteses e figuras.
- [2026-11-09] (i) **D12, D7, D1, D3, D4, D5 e D10** continuam como em [[historico#sessao-2026-11-08-pausa-playtest-1]].

### Próximo passo

1. [2026-11-09 ~superseded 2026-11-09] (i) ~~Pedro olha as figuras e diz se seguem para o playtest 1 ou se algo muda (porcelana, cores, o assento do capítulo 1).~~ → Pedro: "pode fazer, precisamos dar movimento aos personagens".
2. [2026-11-09] (i) Pedro conduz o playtest 1 ([[playtest-1]]).
3. [2026-11-09 ~superseded 2026-11-09] (d) ~~Dar movimento aos personagens: Pedro, "precisamos dar movimento aos personagens". O que se move, e se algo se move à vista, ainda está em conversa.~~ → [[historico#sessao-2026-11-09-movimento]].

## [2026-11-09] Movimento: o passo dos ecos, do reflexo e dos Gastos {#sessao-2026-11-09-movimento}

- [2026-11-09] (d) Pedro aprovou o banquinho e os commits ("pode fazer") e pediu movimento: [[decisoes#movimento]].
- [2026-11-09] (e) ← `git log` Commits `aa4f941` (hipóteses) e `535aaa6` (figuras de porcelana e banquinho), sem push.
- [2026-11-09] (e) ← `mannequin.gd`, `echo.gd`, `mirror_reflection.gd`, `gastos.gd` Passo procedural no manequim; os ecos e o reflexo andam conforme o chão que cobrem, e cada Gasto aparece travado no meio de um passo a cada salto. A encenação não mudou.
- [2026-11-09] (e) ← `run_unit.gd`, `--selftest` Unidade 2610/0, selftest 454/0 ("echoes walk their paths in step", "standing, it is caught mid-step").
- [2026-11-09] (e) ← render descartável de cinco fases do passo e de um Gasto travado, conferido à mão. Custo: 29 µs por figura por frame.

### Em aberto

- [2026-11-09 ~superseded 2026-11-09] (i) ~~**Movimento à vista:** as figuras da encenação continuam imóveis enquanto Elias olha, e o Gasto visto gira para acompanhá-lo ([[achados#a-030]]). Se algo deve se mexer à vista é regra de Pedro.~~ → Pedro: "pode girar mas nao se mexer" ([[decisoes#gira-nao-anda]]); A-030 fechado sem mudança de código.
- [2026-11-09 ~superseded 2026-11-09] (i) ~~**Commit do passo:** espera o sinal de Pedro.~~ → Pedro: "perfeito"; o passo foi commitado, sem push.
- [2026-11-09] (i) **D12, D7, D1, D3, D4, D5 e D10** continuam como em [[historico#sessao-2026-11-08-pausa-playtest-1]].

### Próximo passo

1. [2026-11-09 ~superseded 2026-11-09] (i) ~~Pedro diz se algo se mexe à vista (encenação, o giro do Gasto) e se o passo vai para commit.~~ → o commit está feito; segue em aberto só o movimento à vista ([[achados#a-030]]).
2. [2026-11-09] (i) Pedro conduz o playtest 1 ([[playtest-1]]).

## [2026-11-09] Playtest 1 preparado {#sessao-2026-11-09-playtest-pronto}

- [2026-11-09] (d) Pedro: "pode comitar e fazer o push"; depois, "vamos ao playtest 1".
- [2026-11-09] (e) ← `git push` `582b8c7..ea9b0de` em `origin/main`.
- [2026-11-09] (e) ← binários exportados, selftest no binário 454/0, smoke de 20 s do `--playtest` sem erro: [[playtest-1#rodar]].

### Próximo passo

1. [2026-11-09] (i) Pedro roda as sessões com 3 a 5 pessoas pelo roteiro [[playtest-1]] e põe os CSVs e as notas em `fontes/`; a triagem é a Tarefa 27.

## [2026-11-09] Bot da noite 1 {#sessao-2026-11-09-bot-noite-1}

- [2026-11-09] (d) Pedro: "voce não consegue fazer esse teste?".
- [2026-11-09] (i) A IA não substitui o playtest humano, porque conhece a solução e não sente medo. Em vez disso, fez um bot que joga a noite 1 com as teclas de verdade ([[decisoes]]).
- [2026-11-09] (e) ← `tests/bot_noite1.gd` A noite 1 fecha andando: carta 0,6 s, pistas até 6 s, cena até 19 s, painel 26 s, coroa 32 s, `voltar_terreo` 37 s, uns 40 s esperando o 03:33 no relógio, cartão em 81 s. Entrada 43 s, brincar 29 s, passagem 9 s; 0 capturas; CSV com 18 linhas, nenhuma `perdido`. Antes da correção, 76 s.
- [2026-11-09] (e) ← capturas do bot O pai da pose 1 nascia dentro de Elias; corrigido ([[achados#a-031]]). Binários refeitos ([[playtest-1#rodar]]).
- [2026-11-09] (e) ← rodada do bot Depois da coroa o relógio gira sem meta até o cartão ([[achados#a-032]]).
- [2026-11-09] (i) Vistos de passagem, sem achado: sem olhar a cena, as quatro poses passam em uns 8 s; o painel pode ser quebrado antes do fim da cena e a noite fecha igual; olhar para baixo uma figura ao lado conta como vê-la.

### Em aberto

- [2026-11-09 ~superseded 2026-11-09] (i) ~~**A-032:** Pedro decide se o relógio aponta para o térreo e o relógio da entrada na fase "Antes do 03:33", ou se fica girando e o playtest observa.~~ → Pedro: "b" ([[decisoes#relogio-volta]]); corrigido.
- [2026-11-09 ~superseded 2026-11-09] (i) ~~**Commit:** a correção de A-031, o bot e o `context/` estão sem commit, à espera do sinal de Pedro.~~ → Pedro: "pode comitar e fazer o push" (linhas abaixo).

### Próximo passo

1. [2026-11-09] (i) Pedro conduz o playtest 1 com os binários refeitos ([[playtest-1]]).

- [2026-11-09] (d) Pedro: "b e pode comitar e fazer o push".
- [2026-11-09] (e) ← `tests/bot_noite1.gd` Com o relógio apontando na volta, o bot fecha a noite 1 nos mesmos 81,2 s, com o ponteiro em `point` depois da coroa e no térreo. Unit 2616/0, selftest 457/0, binários refeitos ([[playtest-1#rodar]]).
- [2026-11-09] (e) ← `git push` `ea9b0de..b0bfcf9` em `origin/main`: `0e2f96a` (pose fora de Elias), `7462ea4` (relógio na volta), `693910f` (bot da noite 1), `b0bfcf9` (`context/`).

## [2026-11-09] Pausa: playtest 1 pronto para as sessões {#sessao-2026-11-09-pausa-playtest-1}

- [2026-11-09] (d) Pedro: "quero que faça o comit e o push e que documente o que foi feito para seguirmos amanha".
- [2026-11-09] (e) ← `git log` O que entrou no jogo em 2026-11-09, todo em `origin/main`:
  - hipóteses dos capítulos 1 e 2 reescritas ([[decisoes#d9-hipoteses]]);
  - figuras de porcelana no lugar das caixas e banquinho sob quem senta ([[historico#sessao-2026-11-09-figuras]]);
  - passo procedural dos ecos, do reflexo e dos Gastos, e a regra "pode girar mas não se mexer" ([[historico#sessao-2026-11-09-movimento]], [[decisoes#gira-nao-anda]]);
  - a pose da encenação que esperava Elias sair do lugar ([[achados#a-031]]);
  - o relógio apontando a volta depois da coroa ([[decisoes#relogio-volta]]);
  - o bot da noite 1, `Janghyang/tests/bot_noite1.gd` ([[historico#sessao-2026-11-09-bot-noite-1]]).
- [2026-11-09] (e) ← `run_unit.gd`, `--selftest`, bot, `lint.py` Unit 2616/0, selftest 457/0 (também no binário Linux), bot ok em 81,2 s, lint sem nada a reportar.
- [2026-11-09] (e) ← `Janghyang/build/` (fora do git) Binários do playtest prontos: `Janghyang/build/linux/Janghyang` e `Janghyang/build/windows/Janghyang.exe`. Cada sessão roda `Janghyang -- --playtest --night=1`. Os CSVs e o roteiro estão em [[playtest-1#rodar]]. Se a pasta `build/` sumir, a refação é `godot --headless --path . --export-release "Linux" build/linux/Janghyang` (e `"Windows" build/windows/Janghyang.exe`), a partir de `Janghyang/`.
- [2026-11-09] (e) ← `tests/bot_noite1.gd` Para conferir a noite 1 depois de qualquer mudança, rodar de `Janghyang/` `godot --headless --path . --fixed-fps 60 -s res://tests/bot_noite1.gd -- --playtest --night=1`. Espera-se `BOT RESULT ok`, perto de 81 s.

### Em aberto

- [2026-11-09] (i) **D12, o playtest 1 (T26):** de 3 a 5 pessoas, conduzidas por Pedro pelo roteiro [[playtest-1]]. Destrava a T27 (triagem) e, pela ordem da spec §15, a noite 2 (T28 a T33).
- [2026-11-09] (i) **Noite 2 antes do playtest?** Pedro ainda não decidiu se as T28 a T33 começam já ([[historico#sessao-2026-11-08-pausa-playtest-1]]).
- [2026-11-09] (i) **D7, D9 (resto), D1, D3, D4, D5 e D10** continuam como em [[historico#sessao-2026-11-08-pausa-playtest-1]] e [[historico#sessao-2026-11-09-hipoteses]]. D10 tem `revisar: 2026-11-22`.
- [2026-11-09] (i) **Achados abertos sem pressa para o playtest:** [[achados#a-029]] (sobras de arte das figuras) e os anteriores da lista "Abertos" de [[achados]].

### Próximo passo

1. [2026-11-09] (i) Pedro roda as sessões do playtest 1 com os binários de `build/`. Os CSVs vão brutos para `fontes/YYYY-MM-DD-playtest-1-<pessoa>.csv` e as notas para `fontes/YYYY-MM-DD-playtest-1-notas.md`.
2. [2026-11-09] (i) Com os CSVs e as notas, a T27: comparar o tempo de cada pessoa com o piso do bot (81 s), as linhas `perdido = 1` e as respostas às perguntas finais.
3. [2026-11-09] (i) Se o playtest atrasar, Pedro decide se a noite 2 (T28 a T33) começa antes dele.
