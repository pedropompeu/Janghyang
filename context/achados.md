---
tipo: contexto
projeto: memoria-de-projeto
descricao: Bugs, furos e dívidas encontrados, com severidade, local, reprodução e fix.
estado: estavel
criado: 2026-09-12
relacionado:
  - context/arquitetura.md
---

# Achados

> Lista de riscos técnicos, bugs e dívidas conhecidas. Deve ser lida **antes de dizer que algo está pronto** ou antes de modificar componentes críticos.

## Formato obrigatório {#formato}

- [2026-09-12] (d) **Achado sem reprodução é opinião.** Todo achado leva severidade, localização, reprodução e fix recomendado.
- [2026-09-12] (d) **A severidade se justifica em consequência, não em categoria.** A consequência prática para o usuário/negócio precede o jargão técnico.

```markdown
### [ID] Título curto, em consequência, não em jargão

- **Severidade:** crítico | alto | médio | baixo — e a frase que a justifica em consequência
- **Onde:** caminho/do/arquivo.ext:123
- **Reprodução:** os passos exatos. Se estático, especificar o motivo
- **Por que importa:** o que acontece na prática com o usuário ou sistema
- **Fix recomendado:** o que fazer, com custo aproximado
- **Estado:** aberto | reportado | corrigido | verificado
```

- [2026-09-12] (i) Registrar achados com impacto direto impede que correções cosméticas passem na frente de falhas funcionais.

## O que NÃO é achado {#nao-achado}

> Comportamento declarado como intencional, decisão já tomada e limitação conhecida de ambiente. Registrar aqui evita reabrir discussões já resolvidas.

- [2026-09-12] (d) Comportamentos esperados e tradeoffs documentados em [[decisoes#infraestrutura]] não constituem achados.

## Abertos

### [A-001] A cabana do F1 não cabe o jogador em pé {#a-001}

- [2026-10-20] (e) ← `faz-de-conta/scripts/main.gd:325` e `faz-de-conta/scripts/main.gd:703` A parede F1 dobra 65° para dentro; o bordo livre fica a ~1,08 m do chão, e a cápsula do jogador tem 1,70 m.
- **Severidade:** médio — a batida da cena 1 promete uma cabana para sentar, mas o jogador não consegue entrar nela; a dobra vira imagem, não verbo.
- **Onde:** `faz-de-conta/scripts/main.gd:325` (F1), `faz-de-conta/scripts/main.gd:703` (cápsula), `faz-de-conta/scripts/selftest.gd` (checagem “folded F1 blocks the low cabana volume”).
- **Reprodução:** rode `godot --path .` em `faz-de-conta/`, vá ao quarto de brincar, olhe para a parede oeste e aperte `E`; tente caminhar para o vão triangular sob a parede. A colisão impede; o teste headless confirma o bloqueio em (1,5; 0,85; 3,5).
- **Por que importa:** a cabana é o primeiro gesto de intimidade do slice. Se o jogador só pode olhar, a casa parece um cenário, não um lugar que se habita. Também enfraquece o contraste com a casa que depois usa a dobra contra o jogador.
- **Fix recomendado:** decidir entre (a) crouch/sentada no avatar, (b) parede mais baixa ou dobra maior para liberar ~1,8 m, ou (c) assumir a cabana como imagem e não prometer “sentar”. Custo: (a) controle e câmera; (b) muda a silhueta do F1; (c) muda o roteiro. Validar com Pedro antes de fechar a regra.
- [2026-10-20 ~superseded 2026-10-27] ~~**Estado:** aberto.~~ → **Estado:** resolvido. (e)
- [2026-10-27] (e) ← `faz-de-conta/scripts/player.gd` (`set_crouched`), `faz-de-conta/scripts/main.gd` (F1 a −45°, guarda `can_toggle`) Fix (a): o jogador agacha com `C` (cápsula 1,0 m, olho a 0,92 m), F1 dobra a −45°, não se move com o jogador na cabana e ele não levanta sob a dobra. Selftest: bloco "cabana", `SELFTEST RESULT: 60 checks, 0 failures`. Tarefa 1 do plano `docs/superpowers/plans/2026-10-27-faz-de-conta-relojoeiro.md`.
- [2026-10-28] (e) ← `faz-de-conta/scripts/selftest.gd` (bloco "cabana") O `~superseded` de 2026-10-27 se confirma ao fim do plano: a cabana segue entrável agachado e a guarda de F1 segue de pé com 146 checks verdes. Decisão em [[decisoes#jogo]].

### [A-005] A checagem "entry clock is solid" passa mesmo sem o relógio {#a-005}

- [2026-10-27] (e) ← `faz-de-conta/scripts/selftest.gd` (bloco "space") A sonda em (3,1; 0,85; 8,88) com raio 0,28 m alcança a fachada em z ≈ 9,03; antes de o relógio existir, a checagem já passava.
- **Severidade:** baixo — se o relógio perder a colisão, o selftest não avisa e o jogador atravessa o relógio sem que nenhum teste acuse.
- **Onde:** `faz-de-conta/scripts/selftest.gd`, linha `_expect_blocked(Vector3(3.1, 0.85, 8.88), "entry clock is solid")`.
- **Reprodução:** estática; observada no RED da Tarefa 3: a checagem passou antes de `_build_entry_clock` existir.
- **Por que importa:** é um teste que não pode falhar pelo motivo que nomeia.
- **Fix recomendado:** sondar à frente do relógio, longe da fachada (ex.: z 8,6), ou sondar com uma forma menor; ver falhar sem o relógio. Custo: minutos.
- **Estado:** aberto.
- [2026-11-07] (e) ← `Janghyang/scripts/selftest.gd:105`, `Janghyang/scripts/main.gd` (`_build_entry_clock`). Mutante com `clock.collision_layer = 0` em cópia descartável: com a sonda antiga (z 8,88) a checagem continuava `PASS`; com a sonda nova (z 8,6) passa a `FAIL entry clock is solid — expected a blocker at (3.1, 0.85, 8.6)`. Original com a sonda nova: `241 checks, 0 failures`.
- [2026-11-07 ~superseded 2026-11-07] ~~**Estado:** aberto.~~ → **Estado:** corrigido na U11 do plano de lançamento. (e)

### [A-006] O selftest trava em vez de sair quando há erro de script {#a-006}

- [2026-10-27] (e) ← `faz-de-conta/scripts/selftest.gd` Um erro de execução GDScript (ex.: propriedade inexistente em `main`) interrompe `_run` antes de `quit()`; o Godot headless fica aberto indefinidamente.
- **Severidade:** baixo — só afeta o desenvolvimento: um RED vira uma espera longa em vez de uma falha clara.
- **Onde:** `faz-de-conta/scripts/selftest.gd` (`_run`).
- **Reprodução:** referencie `main.SPAWN` antes de `SPAWN` existir e rode `godot --headless --path . -- --selftest`; o processo não termina.
- **Por que importa:** sem `timeout`, a verificação fica pendurada e pode ser lida como lentidão.
- **Fix recomendado:** sempre rodar com `timeout 150`; opcionalmente, um timer de guarda no selftest que chama `quit(1)`. Custo: minutos.
- [2026-10-27 ~superseded 2026-11-07] ~~**Estado:** aberto (contornado com `timeout`).~~ → **Estado:** corrigido na U10 do plano de lançamento. (e)
- [2026-11-07] (e) ← `Janghyang/scripts/selftest.gd` (`GUARD_S`, `_on_guard`, `_ready`) Cópia com erro de execução injetado em `_run`: antes da correção, o processo não terminava (saída 124 do `timeout 60`); depois, sai com código 1 e imprime `SELFTEST GUARD: no result after 120 s`. Selftest real: `241 checks, 0 failures`, código 0, 43 s.

### [A-007] Loops de áudio tocando no `quit()` deixam playbacks vazados {#a-007}

- [2026-10-28] (e) ← `faz-de-conta/scripts/sfx_bank.gd` Com chuva e respiração em loop, sair do jogo (captura `--shot-clock`) imprime `WARNING: 5 ObjectDB instances were leaked at exit`, todos `AudioStreamWAV` e `AudioStreamPlaybackWAV`. Parar os players em `_exit_tree` não resolveu.
- **Severidade:** baixo — acontece só na saída do processo; o jogador não percebe nada.
- **Onde:** `faz-de-conta/scripts/main.gd` (`_wire_sound`, `_loop_3d`), `faz-de-conta/scripts/sfx_bank.gd`.
- **Reprodução:** `DISPLAY=:0 timeout 30 godot --path . --resolution 1280x720 -- --shot-clock`; o aviso aparece no fim do log.
- **Por que importa:** o aviso polui a saída e pode esconder um vazamento real no futuro.
- **Fix recomendado:** no headless (testes), `sfx.silent` não toca nada e a saída fica limpa. Para a janela, falta encerrar o áudio antes do `quit()` (parar os players e esperar um frame). Custo: minutos.
- **Estado:** aberto (contornado no headless).

### [A-013] Em sessão muito longa, os ecos retocados no final "corda" derivam de trecho {#a-013}

- [2026-10-28] (e) ← revisão final do plano do relojoeiro; `faz-de-conta/scripts/echo.gd` (`sample_at`), `faz-de-conta/scripts/echo_recorder.gd` (`pop_front` ao passar de `MAX_SAMPLES`) O eco guarda índices no gravador vivo; a gravação volta depois do 03:33 e, passados 30 min de amostras, o `pop_front` desloca os índices.
- **Severidade:** baixo — o eco continua sendo um trajeto do jogador (nada inventado), só não o trecho escolhido no 03:33.
- **Onde:** `faz-de-conta/scripts/echo.gd:26-47`.
- **Reprodução:** chegar ao 03:33 perto de 1200 s, ficar mais de 10 min depois, dar corda e sair.
- **Por que importa:** "a casa devolve o que você fez" fica impreciso em sessões longas.
- **Fix recomendado:** copiar as ~80 amostras de cada eco em `Echo.setup`.
- **Estado:** aberto (minor adiado na revisão final).
- [2026-11-07] (e) ← `Janghyang/tests/test_echo.gd` RED com a API antiga: após 18 000 amostras no gravador, o eco lido em `t=2,0 s` devolvia x = 15,2 em vez de 5,2 (deslocamento de 1000 amostras descartadas). GREEN: `Echo.load_window` copia a janela; `sample_at` virou método de instância. Unidade `1060 checks, 0 failures`; selftest `241/0`.
- [2026-11-07 ~superseded 2026-11-07] ~~**Estado:** aberto (minor adiado na revisão final).~~ → **Estado:** corrigido na U13 do plano de lançamento. (e)

### [A-014] Quem nunca sentou o boneco antes do 03:33 não consegue mais catalogá-lo {#a-014}

- [2026-10-28] (e) ← revisão final; `faz-de-conta/scripts/doll.gd` (duplo ignora `E`) O item `boneco` exige o boneco sentado; depois que ele vira o duplo, `doll_sat` não pode mais ser marcado.
- **Severidade:** baixo — não bloqueia o 03:33 (há o gatilho por tempo) nem os finais; só deixa um item do catálogo inalcançável.
- **Onde:** `faz-de-conta/scripts/doll.gd`, `faz-de-conta/scripts/main.gd` (`_wire_catalog`).
- **Reprodução:** não tocar no boneco até o 03:33; depois tentar `Q` nele.
- **Por que importa:** é a peça de Inácio que o jogador mais vê.
- **Fix recomendado:** o duplo contar como sentado, ou `Q` valer direto nele. Validar com Pedro (regra de catálogo).
- **Estado:** aberto (minor adiado na revisão final).

### [A-016] No GL Compatibility, luzes do mundo não iluminam um SubViewport de mundo compartilhado {#a-016}

- [2026-10-28] (e) ← capturas `--shot-corridor` com `faz-de-conta/scripts/hands.gd` na versão `SubViewport` Mãos pretas com `transparent_bg` ligado e desligado. Só a luz ambiente do `Environment` da câmera do `SubViewport` funcionava; uma `OmniLight3D` com `light_cull_mask` da camada 13 também não chegou.
- **Severidade:** médio — pegadinha do motor, não um bug do jogo.
- **Onde:** Godot 4.7.2, renderizador GL Compatibility; `SubViewport` com `own_world_3d = false`.
- **Reprodução:** um `SubViewport` com `Camera3D` própria, `cull_mask` só na camada 13 e malhas iluminadas por `OmniLight3D` do mundo; a captura sai com as malhas pretas.
- **Por que importa:** qualquer viewmodel ou overlay 3D futuro cai no mesmo problema.
- **Fix recomendado:** desenhar na câmera principal com `no_depth_test` e `render_priority` (aplicado em `hands.gd`), ou trocar de renderizador (precisa de Pedro).
- **Estado:** contornado.

### [A-015] O lápis do duplo soa no banco vazio {#a-015}

- [2026-10-28] (e) ← revisão final; `faz-de-conta/scripts/hour_event.gd:104` `play_pencil_pattern(DOUBLE_SEAT)` toca aos 6, 12 e 18 s mesmo se o boneco ainda não foi para o banco.
- **Severidade:** baixo — pode até ler como intencional (algo escreve ali), mas não é o que o spec descreve.
- **Onde:** `faz-de-conta/scripts/hour_event.gd` (`_write_next`).
- **Reprodução:** ficar olhando o banco durante o 03:33.
- **Por que importa:** som sem corpo no slice que promete "nada inventado".
- **Fix recomendado:** escrever a entrada sempre, tocar o lápis só com o duplo sentado.
- **Estado:** aberto (minor adiado na revisão final).
- [2026-11-07] (e) ← `Janghyang/scripts/hour_event.gd` (`_write_next`, `_double_sitting`), `Janghyang/scripts/sfx_bank.gd` (`pencil_count`). RED: com o duplo ainda fora do banco, `_write_next()` tocou o lápis (`FAIL ... — 1`). GREEN: o lápis só toca com `doll.is_double()`; a entrada é escrita sempre. Selftest `243 checks, 0 failures` (os 2 checks novos passam).
- [2026-11-07 ~superseded 2026-11-07] ~~**Estado:** aberto (minor adiado na revisão final).~~ → **Estado:** corrigido na U14 do plano de lançamento. (e)

### [A-017] O tour reiniciou a cena duas vezes numa rodada, sem causa achada {#a-017}

- [2026-10-29] (e) ← `godot --path . -- --tour` Numa rodada, a legenda "Tour automático: só assista" apareceu três vezes, logo depois de "O painel oco embaixo do desenho"; o único `reload_current_scene` está na tecla `R` de `player.gd`.
- **Severidade:** baixo — só a demonstração foi afetada; a rodada seguinte, instrumentada, foi até o fim sem reinício.
- **Onde:** `faz-de-conta/scripts/player.gd:90`, `faz-de-conta/scripts/tour.gd`
- **Reprodução:** não reproduzido. O tour roda no `DISPLAY=:0` real; uma tecla `R` vinda do teclado de verdade explicaria o reinício.
- **Por que importa:** se for um evento sintético perdido, a demonstração recomeça sozinha diante de quem assiste.
- **Fix recomendado:** se voltar, logar `event` no ramo do `R` (5 min) e conferir se vem de `parse_input_event`.
- **Estado:** aberto — diagnóstico instalado na U12 (`[reload] R via <evento>` em `player.gd`). Fecha quando o log aparecer numa rodada real de `--tour` ou numa sessão de Pedro.
- [2026-11-07] (e) ← `Janghyang/scripts/player.gd` (ramo do `R`): com um evento de `R` injetado num selftest de cópia descartável, o log `[reload] R via InputEventKey: keycode=82 (R) ... pressed=true, echo=false` aparece antes do reload.

## Fechados

### [A-019] A decisão de 2026-10-28 dava o 03:33 aos 1200 s e com 5 itens; o código e o spec dizem outra coisa {#a-019}

- [2026-11-07] (e) ← `context/decisoes.md:70` contra `Janghyang/scripts/visit_state.gd:9-10` (`MAX_PRE_HORA = 3600.0`, `HARD_LIMIT = 3780.0`) e spec de expansão §5 ("03:33 só começa na fase V", limite de 60 min).
- **Severidade:** baixo — o jogo está certo; quem lê a decisão antiga (ou um teste escrito a partir dela) cai num gate que não existe mais.
- **Onde:** `context/decisoes.md:70` (sem `~superseded` no fato antigo).
- **Reprodução:** ler `decisoes.md:70` e comparar com `visit_state.gd:9-10`.
- **Por que importa:** o registro decisório contradiz o código, e a memória do projeto é a referência para decidir o que muda.
- **Fix recomendado:** marcar o trecho antigo com `~superseded` apontando para 2026-10-29 e para o spec de expansão §5. Custo: minutos.
- **Estado:** corrigido na U16 do plano de lançamento. A cobertura já existe em `tests/test_visit_state.gd` (`test_pieces_gate`, `test_catalog_alone_no_longer_opens_the_gate`, `test_time_limit_is_an_hour`); nenhum teste novo foi necessário. (e)

### [A-018] O selftest lia o andar de Elias antes do `_process` do main rodar {#a-018}

- [2026-10-29] (e) ← `faz-de-conta/scripts/selftest.gd` "back in the house, no Gasto" falhava em duas de três rodadas: o sinal `process_frame` sai antes do `_process` dos nós, então um único `await process_frame` depois de mover Elias às vezes chegava antes do `_track_place`.
- **Severidade:** baixo — teste instável, não o jogo.
- **Onde:** `faz-de-conta/scripts/selftest.gd`, seção "story".
- **Reprodução:** mover o jogador e checar `main.level` depois de um só `await process_frame`.
- **Por que importa:** um teste que pisca vira ruído e esconde falha real.
- **Fix recomendado:** esperar dois `process_frame`. Aplicado nos dois pontos da seção.
- **Estado:** verificado (três rodadas seguidas com 230/0).


### [A-009] Sair durante um 03:33 ativo deixava a hora correndo atrás do final {#a-009}

- [2026-10-28] (e) ← revisão final; `faz-de-conta/scripts/ending.gd`, `faz-de-conta/scripts/hour_event.gd` O desfecho saía `incompleto`, mas ninguém chamava `end()`: ecos andando e com passos, coisas das frestas ativas, o duplo escrevendo atrás da imagem final. O selftest de saída rodava depois do `end()` e não via isso.
- **Severidade:** médio — a imagem final de "incompleto" ficava em movimento e com som, contra a tabela da Tarefa 15.
- **Onde:** `ending._behind_black`, `hour_event.halt`.
- **Reprodução:** chegar ao 03:33 (ou `F9`) e sair pela beira do tampo antes de o relógio acabar.
- **Por que importa:** é o Review Focus 1 do plano.
- **Fix recomendado:** `hour_event.halt()` congela ecos, desativa as coisas e para a escrita, sem página da cabana nem gigante; o final chama isso atrás do preto. Selftest "leaving during 03:33 ends the hour behind the black", "crack things stop when Elias leaves", "the double stops writing once Elias has left" (RED→GREEN).
- **Estado:** verificado.

### [A-010] O duplo no banco mantinha colisão {#a-010}

- [2026-10-28] (e) ← revisão final; `faz-de-conta/scripts/doll.gd` (`become_double`) O boneco é `StaticBody3D` e seguia sólido no banco, contra a regra "o duplo não tem colisão".
- **Severidade:** baixo no jogo (o banco já é sólido ali), médio como regra quebrada.
- **Onde:** `faz-de-conta/scripts/doll.gd`.
- **Reprodução:** depois do 03:33, consulta de ponto no corpo do duplo.
- **Por que importa:** regra dura do plano.
- **Fix recomendado:** `collision_layer = 0` em `become_double`. Selftest "the double has no collision" (RED→GREEN).
- **Estado:** verificado.

### [A-011] O relógio parava depois da saída em "corda" e "incompleto" {#a-011}

- [2026-10-28] (e) ← revisão final; `faz-de-conta/scripts/visit_state.gd` (`update` voltava cedo em `FIM`) Nada mais avançava o relógio depois da saída; a tabela da Tarefa 15 diz que o tique segue.
- **Severidade:** médio — o final "corda" ficava sem o tique prometido.
- **Onde:** `faz-de-conta/scripts/visit_state.gd`.
- **Reprodução:** dar corda e sair; os ponteiros paravam.
- **Por que importa:** o tique é o som que distingue "corda" de "parar".
- **Fix recomendado:** em `FIM`, `clock.tick(dt)` (no "parar" o `force_stop` mantém parado). Unit `test_clock_keeps_running_after_exit` (RED→GREEN).
- **Estado:** verificado.

### [A-012] A ajuda na tela tinha uma linha em inglês e não listava `B` {#a-012}

- [2026-10-28] (e) ← revisão final; `faz-de-conta/scripts/main.gd` (`help_label`) "The front door is open. Exit is a choice." aparecia ao jogador.
- **Severidade:** baixo — fere a regra de texto em pt-BR.
- **Onde:** `faz-de-conta/scripts/main.gd` (`_build_ui`).
- **Reprodução:** abrir o jogo.
- **Por que importa:** regra dura do plano.
- **Fix recomendado:** "A porta da rua está aberta. Sair é uma escolha." e `B bater`. Selftest "help text is pt-BR and lists every verb" (RED→GREEN).
- **Estado:** verificado.

### [A-008] O harness de unit contava "0 failures" quando um teste dava erro de script {#a-008}

- [2026-10-28] (e) ← `faz-de-conta/tests/run_unit.gd` Um erro em tempo de execução (ou um preload de dependência que não compila) aborta o método `test_*` em silêncio; o runner seguia e imprimia `UNIT RESULT: N checks, 0 failures` com exit 0. Visto na Tarefa 8: `echo_recorder.gd` não compilava e o unit saiu verde.
- **Severidade:** médio — um teste quebrado parece um teste verde; o portão de TDD deixa passar exatamente o código que não roda.
- **Onde:** `faz-de-conta/tests/run_unit.gd` (`_init`).
- **Reprodução:** um `test_*.gd` que acessa `{}.missing.value`; antes do fix, o resultado era `0 failures`.
- **Por que importa:** o unit é o portão de cada tarefa do plano.
- **Fix recomendado:** um `Logger` registrado com `OS.add_logger` conta erros; se a contagem sobe durante um método de teste, ele vira falha. Aplicado; a sonda passou a falhar com `raised a script error`.
- **Estado:** verificado.

### [A-002] O banco da entrada bloqueava o laço e a saída {#a-002}

- [2026-10-20] (e) ← `faz-de-conta/scripts/selftest.gd` O banco em (2,7; 0,2; 8,5) ocupava a abertura passagem→entrada; o teste travou em (3,44; 0,85; 8,3).
- **Severidade:** alto — o jogador conseguia entrar no corredor, mas não voltar à entrada/ateliê pela passagem; sem game over, restava `R`.
- **Onde:** `faz-de-conta/scripts/main.gd:589` (banco), abertura em `faz-de-conta/scripts/main.gd:323` (`_wall_x(house, 3.5, 7.0, 7.7, ...)`).
- **Reprodução:** percorra o laço até o corredor, desça pela passagem em direção à entrada; o banco tapa o vão de 1,4 m. O selftest anterior falhava em “passage -> entry” e “entry east turn”.
- **Por que importa:** o laço é o argumento do slice; um móvel que o fecha por acidente transforma a peça em soft-lock.
- **Fix recomendado:** mover o banco para a parede oeste, fora do eixo da abertura. Aplicado em (0,7; 0,2; 8,5); o selftest passa o laço completo.
- **Estado:** verificado.

### [A-003] A porta dos fundos aberta bloqueava o caminho oeste do quarto {#a-003}

- [2026-10-20] (e) ← `faz-de-conta/scripts/selftest.gd` Com a porta dos fundos aberta para dentro a +70°, a folha ocupava o corredor oeste do quarto; o teste travou em (11,5; 0,85; 4,0) contra `DoorBedroomBack`.
- **Severidade:** médio — o jogador ainda podia fechar a porta ou dar a volta pela cabeceira, mas o caminho direto do laço ficava bloqueado sem sinal claro.
- **Onde:** `faz-de-conta/scripts/main.gd:352` (`DoorBedroomBack`), caminho oeste do quarto em `main.gd` (cama em x 12,1–14,3).
- **Reprodução:** abra a porta da frente do quarto, entre, abra a porta dos fundos e tente seguir para o norte pela faixa oeste; a folha da porta fecha a passagem.
- **Por que importa:** a porta dos fundos existe para fechar o laço sem atravessar a cama; se ela bloqueia a própria circulação, o laço perde a função.
- **Fix recomendado:** no blockout ela abre para o corredor (`rot_b = -70°`), deixando o quarto livre. O corredor fica com ~0,7 m de folga quando a porta está aberta; o jogador pode fechá-la. Validar em playtest se o aperto é horror ou fricção.
- **Estado:** verificado (navegação); o atrito do corredor segue como pergunta de design.

### [A-004] F1 dobrava para um vazio preto {#a-004}

- [2026-10-20] (e) ← `faz-de-conta/blockout-fold.png` Com F1 dobrada, a parede oeste sumia e o jogador via o vazio preto do fora da casa; parecia uma parede faltando, não um exterior.
- **Severidade:** baixo — não bloqueava o jogo, mas confundia a leitura da dobra e do ateliê.
- **Onde:** `faz-de-conta/scripts/main.gd` (antiga parede oeste sem exterior), `_build_atelier` (strip oeste).
- **Reprodução:** rode o quarto de brincar, aperte `E` em F1 e olhe para oeste; o fundo era a cor de limpeza.
- **Por que importa:** a dobra é o gesto que abre a casa; se o fora não existe, a casa parece um set fechado e o ateliê perde a escala de maquete.
- **Fix recomendado:** adicionar o strip oeste do ateliê com janela de chuva; o jogador vê um cômodo, mas não entra. Aplicado; a arte final ainda precisa resolver esse exterior.
- **Estado:** verificado.
