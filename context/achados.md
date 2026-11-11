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
- [2026-11-07] (e) ← U15 do plano de lançamento: `SfxBank.register_loop` / `stop_all` e `main.shutdown()` (para os loops, espera um frame, `quit()`); gate headful `DISPLAY=:0 timeout 30 godot --path . --resolution 1280x720 -- --shot-clock` com 0 vazamentos (linha de base 5). Unidade `1062 checks, 0 failures`; selftest `243/0`.
- [2026-11-07 ~superseded 2026-11-07] ~~**Estado:** aberto (contornado no headless).~~ → **Estado:** corrigido na U15 do plano de lançamento. (e)

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
- **Estado:** aberto (minor adiado na revisão final) ~superseded 2026-11-07 → corrigido na U20 (commit 67ccc48).
- [2026-11-07] (e) ← U20: `become_double` emite `toggled(false)` ao virar o duplo, e o catálogo lê `doll_sat` por esse sinal (`main.gd` `_wire_catalog`). Gates: RED unitário `becoming the double reports it seated` (1 falha); RED no selftest `the double counts as the seated doll for the catalogue (A-014) — false` (1 falha, 244 checks); GREEN unitário 1064/0 e selftest 244/0. Escolha (a) de D6 delegada pelo Pedro e registrada como (i).

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

### [A-026] Os Gastos ficam parados enquanto o caderno está aberto {#a-026}

- [2026-11-08] (i) ← `Janghyang/scripts/gastos.gd` (`_process` volta cedo com `main.player.input_locked`) e `scripts/notebook_ui.gd` (`_set_locked(true)` ao abrir). Visto ao ligar a captura na Tarefa 15.
- **Severidade:** médio — o caderno vira um esconderijo: com ele aberto nenhum Gasto anda, olha ou agarra, e a captura só começa com o caderno fechado.
- **Onde:** `gastos.gd`, `_process`; `notebook_ui.gd`, `open`/`close`.
- **Reprodução:** com um Gasto em jogo, abrir o caderno (`Tab`) e esperar: ninguém se move.
- **Por que importa:** o §8 quer o caderno sem pausa, e o check "a captura fecha o caderno" da Tarefa 15 só passa hoje chamando `_grab` direto.
- **Fix recomendado:** na Tarefa 18 (planta sem pausa), separar "trava o corpo" de "trava o mundo": o caderno trava a câmera e o andar, mas `gastos.gd` passa a olhar um sinal próprio (ex.: `main.world_frozen()`) em vez de `input_locked`. Custo pequeno.
- **Estado:** ~~aberto~~ ~superseded 2026-11-08 → corrigido na Tarefa 18. (i)
- [2026-11-08] (e) ← `scripts/main.gd` `world_frozen()` (`_hugging or ended`) e `scripts/gastos.gd` (`_process` volta cedo só com `main.world_frozen()`): com o caderno aberto Elias fica travado, mas os Gastos andam, olham e agarram; check de selftest "planta: the world goes on with the notebook open".

### [A-025] A lanterna e o item da mão esquerda dividem a mesma mão {#a-025}

- [2026-11-08] (i) ← `Janghyang/scripts/hands.gd` (`_lantern` e `HeldItem` filhos de `_left`) e o §6 do documento de direção ("a lanterna fica na mão direita"). Visto ao fechar a Tarefa 14.
- **Severidade:** baixo — só a leitura visual: com a lanterna acesa e o relógio aberto, os dois blocos aparecem juntos na mão esquerda e a vareta segue na direita.
- **Onde:** `hands.gd`, `_build_rig`; o feixe sai de `_left.position + LENS`.
- **Reprodução:** acender a lanterna (`F`) e abrir o relógio (`T`): lanterna e relógio na mesma mão.
- **Por que importa:** o §6 põe a lanterna na direita para a esquerda ficar com uma coisa por vez; o relógio é o asset mais visto do jogo (§13).
- **Fix recomendado:** passar a lanterna para a mão direita (e a vareta para a esquerda, como item) junto dos assets das mãos (Tarefas 35 e 39); ajustar os checks "the lantern beam comes from the left hand" e "the right hand holds a stick". Custo pequeno.
- **Estado:** aberto. (i)

### [A-023] A luz da oficina faz qualquer canto da casa contar como iluminado para os Gastos {#a-023}

- [2026-11-08] (i) ← `Janghyang/scripts/gastos.gd` (`_lamp_lit`, usado por `seen`/`blind`). Visto na revisão da Tarefa 13.
- **Severidade:** médio — um Gasto que devia ficar parado no escuro pode ser tratado como "na luz" (e o contrário) longe de qualquer lâmpada, e o medo da espreita fica imprevisível.
- **Onde:** `_lamp_lit(p)` aceita todo `OmniLight3D` visível com energia acima de 0,25 a menos de 60% do alcance; a luz da oficina tem alcance 45, então cobre uns 27 m.
- **Reprodução:** estática. Com Elias na casa, `_lamp_lit` de um ponto do corredor dá verdadeiro só pela luz da oficina.
- **Por que importa:** a regra de segurança da noite 3 já usa só as `HouseLight` por cômodo; a percepção dos Gastos devia seguir a mesma leitura de luz.
- **Fix recomendado:** limitar `_lamp_lit` às luzes da mesma área (ou ao grupo `HouseLight` dentro de casa) e com alcance efetivo menor; custo pequeno, mais um check no selftest.
- **Estado:** aberto. (i)

### [A-024] A noite 3 ainda não tem interruptor e o relógio da entrada não usa `entry_clock_scale` {#a-024}

- [2026-11-08] (i) ← `Janghyang/scripts/story/noites.gd` (`entry_clock_scale` 0,5 na noite 3) e `Janghyang/scripts/gastos.gd` (`lit_rooms`). Visto ao fechar a Tarefa 13.
- **Severidade:** baixo — só afeta o equilíbrio das noites 2 e 3, que ainda são rascunho.
- **Onde:** nenhum código lê `entry_clock_scale`; e nenhuma `HouseLight` é desligada pelo jogador, então na noite 3 todo cômodo com lâmpada é seguro.
- **Reprodução:** estática. `rg entry_clock_scale scripts` só acha `noites.gd`; na noite 3, `lit_rooms()` sempre devolve os nove cômodos com lâmpada.
- **Por que importa:** o §11 faz da noite 3 a noite em que a luz é escolha, e o relógio da entrada devia durar metade; sem isso a noite 3 fica mais fácil que a 2.
- **Fix recomendado:** aplicar `entry_clock_scale` na corda do `WindClockModel` em `begin_night` e dar interruptores às `HouseLight` (ou apagar algumas por noite) quando a tarefa de luz chegar; custo pequeno cada.
- **Estado:** aberto. (i)

### [A-022] Entre noites o mundo não volta ao começo, mas as marcas dele no catálogo vão para o save {#a-022}

- [2026-11-08] (i) ← `Janghyang/scripts/main.gd` (`begin_night`, `end_night`) e `Janghyang/scripts/catalog.gd` (`to_dict` leva `flags`). Visto ao fechar a Tarefa 12.
- **Severidade:** baixo — só os rascunhos das noites 1 e 2 rodam, e nenhum lote delas depende de dobra, porta ou quebra; mas a partir dos atalhos (Tarefa 29) a diferença vira progresso perdido ou duplicado.
- **Onde:** na mesma sessão, dobras, portas, quebráveis, bola e boneca ficam como Elias deixou na noite anterior. Ao reabrir o jogo pelo save, o mundo volta ao padrão, mas `catalog.flags` (`f1_folded`, `doll_sat`, `after_hora`) chega do save como estava.
- **Reprodução:** estática. Na noite 1, dobrar o F1 e fechar a noite: o save leva `f1_folded = true`. Reabrir na noite 2: o F1 está em pé e o catálogo acha que está dobrado.
- **Por que importa:** o §5.1 diz o que passa de uma noite à outra (peças, itens de mão, atalhos, planta, catálogo, capítulos); o resto da casa deveria começar igual em toda noite, com ou sem reabrir o jogo.
- **Fix recomendado:** um `reset_world()` chamado por `begin_night` que devolve dobras, portas e quebráveis ao estado inicial, menos os atalhos de `campaign.shortcuts`; e o save do catálogo sem as flags de adereço (ou com elas recalculadas pelo mundo). Dono natural: Tarefa 29, que cria `campaign.shortcuts`. Custo: uma tarde.
- **Estado:** aberto. (i)

### [A-029] Sobras de arte das figuras de porcelana {#a-029}

- [2026-11-09] (i) ← shots `--shot-figuras`, `--shot-figuras_fim` e as vistas de conferência do Blender (`arte/blender/figuras.py --preview`).
- **Severidade:** baixo — nada quebra; são detalhes que um jogador atento nota de perto.
- **Onde:** `arte/blender/figuras.py` (sapato e rosto do menino); `Janghyang/scripts/areas/casa.gd:39`, `casa.gd:42` e `passagem.gd:44` (pose `sentado` sem assento).
- **Reprodução:** chegar perto de uma figura: há um vinco na ponta do sapato, e o rosto do menino ainda tem traços de adulto. No capítulo 1, o pai senta em `sentado`, e na casa não há cadeira nesse ponto: ele fica sentado no ar.
- **Por que importa:** a porcelana pede acabamento. Sentar no ar lê como erro, não como estranheza da casa.
- **Fix recomendado:** pôr um banco ou uma cadeira sob cada `sentado` da encenação, ou trocar para `no_chao` (minutos). Suavizar o sapato e arredondar o rosto do menino em `figuras.py` (uma hora). Medido junto, para não precisar de nova entrada: com as figuras, a cena do capítulo 1 caiu de 285,5 para 268,1 fps (−6%) e a vista de cima ficou igual (301 → 304). O limite de alerta é 20%.
- [2026-11-09 ~superseded 2026-11-09] ~~**Estado:** aberto.~~ → **Estado:** em parte corrigido. O assento foi resolvido (linha abaixo); seguem o vinco do sapato e o rosto do menino. (e)
- [2026-11-09] (e) ← `Janghyang/scripts/mannequin.gd` (`set_seat`), `scripts/main.gd` (`_apply_pose`) Toda pose `sentado` da encenação traz um banquinho de madeira sob o quadril, que vem e vai com a pose. Selftest: "the sitting father has a stool under him" e "sitting again at the end, the stool came with him". Unidade 2573/0, selftest 452/0.

## Fechados

### [A-033] O abajur gigante da Oficina "acendia" a casa inteira para os Gastos {#a-033}

- [2026-11-11] (e) ← `Janghyang/scripts/selftest.gd` (`_escuro`) Com a lanterna apagada, os quatro pontos da passagem e os 18 do sótão contavam como iluminados. A luz responsável era `/root/Main/Oficina` em (6; 18; 16), energia 1,6 e alcance 45 m: `gastos._lamp_lit` aceita qualquer lâmpada com energia > 0,25 a menos de 60% do alcance, ou seja, 27 m em volta do abajur.
- **Severidade:** alto — o Gasto nunca ficava "cego" nem andava no escuro, e qualquer Gasto olhado contava como visto à luz. O escuro da noite 1 refeita (§6.6, §8.2) não existiria no jogo.
- **Onde:** `Janghyang/scripts/gastos.gd` (`_build_graphs`, lista `_lamps`), luz criada em `Janghyang/scripts/areas/tampo.gd:61`.
- **Reprodução:** antes do fix, na noite 2, ponha Elias na passagem, apague a lanterna e chame `gastos._lamp_lit` num ponto do grafo: devolve verdadeiro.
- **Por que importa:** muda o equilíbrio de todas as noites: antes, olhar para um Gasto em cômodo escuro e fora do cone da lanterna já o congelava; agora não congela.
- **Fix recomendado:** as luzes sob o nó `Oficina` (a sala gigante fora da maquete) ficam fora de `_lamps`. Aplicado na Tarefa 4 da noite 1; checagem `escuro: the workshop's giant lamps do not light the model for the Gastos`. A luz ambiente de `leste.gd:78` (energia 0,35, alcance 16 m) segue contando e merece o mesmo olhar no playtest.
- **Estado:** verificado no selftest; o efeito no equilíbrio das noites 2 a 5 vai para o playtest.

### [A-032] Depois da coroa o relógio gira sem meta, e o CSV não mede quem se perde na volta {#a-032}

- [2026-11-09] (e) ← `Janghyang/scripts/main.gd` (`watch_goal()` só percorre `night.goals`; `voltar_terreo` e `dar_corda` ficam na fase "Antes do 03:33", `scripts/story/noites.gd:29`, fora das metas) e a rodada de `tests/bot_noite1.gd`: depois de "took the crown", o relógio passa a "points at <null>" e a coluna `meta` do CSV fica vazia até o cartão.
- **Severidade:** baixo — não trava o caminho que o bot fez: o caderno lista "voltar ao térreo da casa" e "dar corda e acordar na oficina", e no térreo o 03:33 vem em uns 44 s e acaba sozinho em 90 s (`SHORT_HOUR`).
- **Onde:** `Janghyang/scripts/main.gd` (`watch_goal`), `Janghyang/scripts/story/noites.gd:29` (`_HOME_STRETCH`).
- **Reprodução:** jogar a noite 1 até pegar a coroa e abrir o relógio (T): o ponteiro gira devagar da passagem até o cartão. Ou o bot: `godot --headless --path . --fixed-fps 60 -s res://tests/bot_noite1.gd -- --playtest --night=1`.
- **Por que importa:** a volta (passagem → térreo → relógio da entrada) é o único trecho da noite 1 em que o relógio não aponta, e o giro lento já quer dizer "sem caminho" na spec (§ bússola, `direcao-design.md:191`), mesmo havendo caminho. É também o único trecho que o "perdido" não mede ([[decisoes]], "sem meta, ninguém se perde"). Quem se perder ali só aparece nas notas de Pedro, não no CSV.
- **Fix recomendado:** decisão de Pedro, entre (a) deixar girar e observar no playtest e (b) na fase "Antes do 03:33", apontar para o térreo e depois para o relógio da entrada, o que também liga o "perdido" ali (cerca de uma hora com testes).
- [2026-11-09 ~superseded 2026-11-09] ~~**Estado:** aberto, à espera de Pedro. A observação entrou no roteiro ([[playtest-1#observar]]).~~ → **Estado:** corrigido pela opção (b) ([[decisoes#relogio-volta]]): depois da coroa, o relógio aponta para o `EntryClock` como `voltar_terreo` e, no térreo, como `dar_corda`. Selftest 457/0 com três checks novos ("noites: with the crown, the watch points the way back to the entry clock", "on the ground floor, the watch points at the clock to wind", "night 5 has no way home for the watch to point"). O bot vê o ponteiro em `point` nos dois trechos, e a coluna `meta` do CSV fica preenchida até o cartão. Binários refeitos, selftest no binário 457/0. (e)

### [A-031] Uma pose da encenação podia nascer dentro do Elias {#a-031}

- [2026-11-09] (e) ← `Janghyang/tests/bot_noite1.gd`, primeira rodada com capturas: o bot catalogou o desenho, deu as costas para a cena e, na pose 1, o pai surgiu a 0,12 m dele, em `(6,4; 0; 1,1)`, com a mão no painel. De frente, nenhuma figura aparecia. Olhando para baixo, só o quadril e as pernas, com a câmera dentro do tronco.
- **Severidade:** médio — quem cataloga o desenho por último vira e acha a figura atravessada no próprio corpo. Isso lê como defeito, não como susto, e justo na cena que ensina que as figuras andam quando ninguém olha.
- **Onde:** `Janghyang/scripts/main.gd` (`_tick_staging`); poses em `Janghyang/scripts/areas/casa.gd:36-48`. As figuras da encenação não têm colisão, e a troca de pose só checava se Elias estava olhando.
- **Reprodução:** antes da correção, o bot (`godot --headless --path . --fixed-fps 60 -s res://tests/bot_noite1.gd -- --playtest --night=1`) dava "looked away (1) [...] nearest figure 0.12 m from Elias". À mão: catalogar o desenho de pé entre o painel e a mesinha e ficar 1,5 s de costas.
- **Fix recomendado:** a próxima pose espera enquanto Elias estiver a menos de `CLEAR` (0,6 m, a cápsula dele mais um corpo) do ponto de qualquer figura nela; a conta de 1,5 s recomeça quando ele sai. Minutos.
- **Estado:** corrigido. `staging_model.clear_of` e `main._staging_clear`, com o teste `test_a_pose_never_lands_on_elias`. Unit 2616/0, selftest 454/0. O bot agora sai do lugar na pose 1, e nenhuma figura aparece a menos de 2,8 m. Binários reexportados, selftest no binário 454/0. (e)

### [A-030] O Gasto visto sob a luz continua girando para acompanhar Elias {#a-030}

- [2026-11-09] (e) ← `Janghyang/scripts/gastos.gd` (`_process` chama `_face(i, pp)` a cada frame, visto ou não); spec `docs/superpowers/specs/2026-10-28-faz-de-conta-expansao-design.md` §"Como se movem" ("Olhar para eles com luz [...] os congela").
- **Severidade:** baixo — não quebra nada; é um Gasto "congelado" que gira no lugar quando Elias anda em volta dele.
- **Onde:** `Janghyang/scripts/gastos.gd`, laço de `_process`, `if not m.is_away(): _face(i, pp)`.
- **Reprodução:** com um Gasto à vista e a lanterna acesa sobre ele, andar em círculo: o corpo gira para ficar de frente para Elias.
- **Por que importa:** contradiz o congelar da spec, e pode ser lido como o Gasto se mexendo à vista. Ou pode ser o arrepio que se quer: decisão de Pedro, junto com a pergunta do movimento à vista ([[historico#sessao-2026-11-09-movimento]]).
- **Fix recomendado:** girar só quando não é visto (`if not seen`), minutos; um teste de selftest que gira a câmera em volta de um Gasto visto e confere `rotation.y`.
- [2026-11-09 ~superseded 2026-11-09] ~~**Estado:** aberto, à espera de Pedro.~~ → **Estado:** fechado sem mudança: o giro é desejado ([[decisoes#gira-nao-anda]]). (d)

### [A-028] A figura que fica no final aparecia em pé em vez de sentada no chão {#a-028}

- [2026-11-09] (e) ← `Janghyang/scripts/ending.gd:85` posa a `NewFigure` (`no_chao`) antes do `add_child`. No Godot 4.7, posar os ossos de um `Skeleton3D` fora da árvore o marca sujo sem agendar o redesenho, e ele passa a ignorar todas as poses seguintes. Visto no shot `--shot-ending` e confirmado num render das quatro poses: só as figuras posadas depois do `add_child` apareciam posadas.
- **Severidade:** alto — é a última imagem do jogo. Elias ficava de pé na entrada com o caderno caído aos pés, e não sentado no chão.
- **Onde:** `Janghyang/scripts/mannequin.gd` (`_notification`); o efeito aparece em `ending.gd:85`.
- **Reprodução:** criar um `Mannequin`, chamar `build` e `set_pose(&"no_chao")` e só depois `add_child`. O corpo desenhado fica em pé. Em headless, `get_bone_global_pose(hips)` continua 0,88 enquanto `get_bone_pose(hips)` diz 0,13.
- **Por que importa:** qualquer figura posada antes de entrar na cena some da pose. Hoje é a figura nova; amanhã pode ser outra.
- **Fix recomendado:** em `NOTIFICATION_POST_ENTER_TREE`, `force_update_all_bone_transforms()`, esvaziar `_last` e chamar `_sync()`. Custo: minutos. Parente do mesmo comportamento: `get_bone_global_pose` não se atualiza fora da árvore, por isso `bone_transform()` compõe as poses locais ([[decisoes#figuras-porcelana]]).
- **Estado:** corrigido. Selftest novo: "new figure is drawn sitting on the floor, not standing". Unidade 2545/0, selftest 450/0, render conferido. (e)

### [A-027] Soltar os materiais de uma figura dava erro de material nulo com outra figura viva {#a-027}

- [2026-11-09] (e) ← `--selftest` com as figuras novas: 7 erros `material_get_instance_shader_parameters: Parameter "material" is null` quando os ecos da noite 1 eram soltos com outras figuras adultas vivas.
- **Severidade:** médio — o selftest falhava em "no script errors during the selftest". O erro saiu no renderer dummy do headless; com janela, ele não foi procurado. Soltar figuras é rotina (ecos, troca de noite).
- **Onde:** `Janghyang/scripts/mannequin.gd` (`_porcelain`, `_porcelain_cache`).
- **Reprodução:** duas figuras com a mesma malha, cada uma com materiais próprios em `set_surface_override_material`; ao soltar uma, a outra gera um erro por superfície. Testado à parte: `material_override`, materiais mantidos vivos, malha duplicada ou material compartilhado não dão o erro.
- **Por que importa:** cada erro de engine reprova o selftest, e um vazamento no renderer real seria pior.
- **Fix recomendado:** cache estático de materiais por parte, cor e arquivo, compartilhado e nunca solto no jogo. Custo: minutos.
- **Estado:** corrigido. Teste unitário "one style, one set of materials"; selftest 450/0 sem o erro. (e)

### [A-020] Elias no sótão sobre o quarto contava como "no quarto" para a visita {#a-020}

- [2026-11-08] (e) ← `Janghyang/scripts/main.gd` (`in_bedroom`, antes `BEDROOM_X/BEDROOM_Z` só em x e z) contra `Janghyang/scripts/areas/casa.gd` (cômodo `quarto`, y −0,4..2,8). Achado da revisão do OpenCode sobre a migração (T4–T9).
- **Severidade:** baixo — a hora pode começar com Elias no sótão, em cima do quarto, sem ele ter voltado ao quarto; o mapa do quarto também existia duas vezes e podia divergir do registro.
- **Onde:** `Janghyang/scripts/main.gd` (`in_bedroom`), usado em `_process` (visita) e em `scripts/mirror_reflection.gd:63`.
- **Reprodução:** estática. `in_bedroom(Vector3(12, 3.4, 2))` dava `true` (x e z dentro do retângulo, sem checar a altura), mas o ponto fica no sótão.
- **Por que importa:** a regra da hora é "Elias no quarto"; o sótão é outro andar. E uma área mudada no registro deixava o retângulo velho para trás.
- **Fix recomendado:** `in_bedroom(pos)` → `atlas.room_at(pos) == &"quarto"`, apagando `BEDROOM_X/BEDROOM_Z`. Custo: minutos.
- **Estado:** corrigido. Unidade 1778/0, selftest 304/0. (e)

### [A-021] O save da campanha podia trocar um save bom por um ruim, ou perder um arquivo ruim {#a-021}

- [2026-11-08] (e) ← `Janghyang/scripts/campaign_model.gd` (`save`, `from_dict`, `load_or_fresh`) e `Janghyang/scripts/catalog.gd` (`from_dict`). Achado da revisão do OpenCode sobre a T10.
- **Severidade:** médio — o save só passa a ser usado na Tarefa 12, então nenhum jogador foi afetado; mas cada caso perde progresso ou derruba o jogo ao carregar.
- **Onde:** `save()` não conferia o erro da escrita antes de renomear o `.tmp`; `from_dict` validava só os contêineres (uma peça `{}` dava erro de script) e aceitava `night` acima de 5; um segundo save ruim sobrescrevia o primeiro `*.bad.json`; `Catalog.from_dict` com `entries` vazio deixava `next_number()` estourar; e o teste guardava `visited` no formato cru do atlas, enquanto `Atlas.from_dict` lê `{"visited": [...]}`.
- **Reprodução:** unitária. `from_dict({... "pieces": [{}]})` levantava erro; `from_dict({... "night": 6})` devolvia `true`; dois `load_or_fresh` com arquivos ruins deixavam só o segundo; `Catalog.new().from_dict({})` e depois `next_number()` falhava.
- **Por que importa:** o save é a única coisa que passa entre noites (§5.1); "nunca apagado" é promessa do plano.
- **Fix recomendado:** checar `f.get_error()` e apagar o `.tmp` numa falha; validar cada elemento e o teto da noite; `*.bad-2.json` e seguintes; catálogo vazio volta à entrada da maquete; `visited` guarda `Atlas.to_dict()`. Custo: minutos.
- **Estado:** corrigido. Unidade 2016/0, selftest 304/0. (e)

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
