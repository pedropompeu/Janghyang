---
tipo: contexto
projeto: jogo
descricao: Roteiro do primeiro playtest humano (noite 1), o que observar e o que perguntar no fim.
estado: aberta
criado: 2026-11-08
relacionado:
  - context/decisoes.md
  - context/historico.md
---

# Playtest 1: roteiro da noite 1 {#playtest-1}

> Discussão **em aberto** até as sessões da Tarefa 26. Os CSVs e as notas de Pedro vão
> brutos para `fontes/`. A leitura deles é a Tarefa 27 (triagem), não esta página.

## A pergunta {#pergunta}

- [2026-11-08] (e) ← `docs/superpowers/specs/2026-11-08-janghyang-direcao-design.md` §15: o
  playtest prova, com gente jogando, que medo, busca e bússola funcionam juntos. O critério é
  que um jogador de primeira vez **nunca fique mais de 3 minutos sem saber para onde ir**.
- [2026-11-08] (i) **Bloqueia:** a noite 2 e os assets (spec §15, ordem 3 e 4). Não bloqueia as
  correções que o próprio playtest apontar.

## Como rodar {#rodar}

- [2026-11-08] (i) Binário Linux: `build/linux/Janghyang -- --playtest` (ou o editor com
  `-- --playtest`). Começa na noite 1 do save novo; para forçar: `-- --playtest --night=1`.
- [2026-11-08] (i) O registro grava a cada 5 s em `user://playtest/<data-hora>.csv`
  (no Linux, `~/.local/share/godot/app_userdata/Janghyang — blockout/playtest/`, pelo `config/name` do projeto). Colunas:
  `t, noite, area, comodo, meta, dist, relogio_aberto, caderno_aberto, capturas, perdido`.
  `perdido` vira 1 depois de 180 s na mesma meta sem chegar 2 m mais perto do melhor ponto.
- [2026-11-08] (i) De 3 a 5 pessoas, uma por vez, com fone de ouvido, luz da sala apagada.
  Pedro senta atrás, sem tela própria, com papel e um cronômetro.

## O que se diz à pessoa {#instrucao}

- [2026-11-08] (i) **Nenhuma instrução além da carta.** Antes de começar, só isto: "É um jogo
  de terror sem sustos de volume. Joga como quiser; eu não vou ajudar, mas pode pensar em voz
  alta." Se a pessoa perguntar algo durante o jogo, a resposta é "o que você acha?".
- [2026-11-08] (i) Exceção: se a pessoa passar de 10 minutos parada sem saber nem andar,
  Pedro diz só quais teclas movem (WASD, mouse) e anota o minuto.

## O que observar {#observar}

Anotar o minuto de cada coisa (o CSV dá o resto):

- [2026-11-08] (i) **O primeiro uso do relógio** (T): quando abre pela primeira vez, se foi
  por ter lido a carta, por acaso ou nunca. Se entende que o ponteiro aponta, e se segue.
- [2026-11-08] (i) **Onde se perde:** cada vez que a pessoa para, gira no lugar ou volta pelo
  mesmo corredor. Conferir depois com as linhas `perdido = 1` do CSV.
- [2026-11-08] (i) **O medo dito em voz alta:** frases, sustos no corpo (recuar, tirar a mão do
  mouse), risadas nervosas. Qual susto foi (lâmpada, lanterna, figura, Gasto) e o que vinha
  antes (silêncio ou barulho).
- [2026-11-08] (i) **A busca:** se acha as pistas do capítulo 1, se abre o caderno, se percebe
  que as figuras andam quando não estão sendo olhadas, e qual hipótese escolhe primeiro.
- [2026-11-08] (i) **As ações:** quais descobre sozinha (giz G, escutar L, esconder, prender a
  respiração, planta) e quais nunca usa.
- [2026-11-08] (i) **A captura:** se entende que precisa clicar para se soltar, quantas vezes
  é pega, e o que diz depois do primeiro abraço.
- [2026-11-08] (i) **O tempo da noite 1:** do primeiro passo ao cartão da noite. A meta da
  spec é de 60 a 90 minutos para o jogo inteiro; a noite 1 não deve passar de 20.

## Perguntas finais {#perguntas}

Depois do cartão da noite (ou aos 30 minutos, o que vier primeiro), nesta ordem, sem explicar
nada antes:

1. O que você estava procurando?
2. Para que serve o relógio?
3. Teve algum momento em que você não sabia para onde ir? Onde?
4. O que te deu mais medo? E o que não deu medo nenhum, mas deveria?
5. O que você acha que aconteceu com o menino?
6. Teve alguma coisa que você tentou fazer e o jogo não deixou?
7. Você jogaria a noite 2 agora?

## Default adotado enquanto não fecha {#default}

- [2026-11-08] (i) **As sessões usam o binário em blocos, sem os assets (D7 em espera).** O
  playtest testa medo, busca e bússola; a aparência entra depois (spec §15, ordem 4).
  `revisar: 2027-01-15`.
