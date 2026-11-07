extends RefCounted
## Fixed copy for the catalogue: Elias's lines and Inácio's diary pages.
## Text is player-facing (pt-BR); ids stay in English-free snake_case.

const FIRST_NUMBER := 215

const OPENING := {"number": 214, "text": "maquete de casa sob redoma, relógio no telhado, parado. Dei corda para testar o mecanismo."}

const ITEMS := {
	&"relogio_entrada": {"text": "relógio de caixa, ébano tingido, pêndulo de latão. O mostrador só tem marcas entre 03:00 e 03:33.", "page": &"p1", "gate": &""},
	&"bola": {"text": "bola de madeira, faia, gasta de um lado só.", "page": &"", "gate": &""},
	&"caixa_musica": {"text": "caixa de música, manivela de latão. A melodia sempre para na mesma nota.", "page": &"p2", "gate": &""},
	&"desenho": {"text": "desenho a lápis de cera: esta casa, um menino, um relógio maior que a casa. Assinado \"Inácio, 7 anos\".", "page": &"", "gate": &""},
	&"casinha": {"text": "casinha de brinquedo dentro da casa de brinquedo. Também tem relógio no telhado.", "page": &"", "gate": &""},
	&"cabana": {"text": "cabana de parede dobrada, almofada, cobertor. Cheiro de cobre.", "page": &"", "gate": &"f1_folded"},
	&"cama": {"text": "cama de criança, colcha bordada. No travesseiro, a marca de uma cabeça adulta.", "page": &"", "gate": &""},
	&"espelho": {"text": "espelho oval, moldura de latão. O reflexo demora.", "page": &"", "gate": &""},
	&"boneco": {"text": "boneco de pano, casaco cinza-azulado igual ao meu. A costura é nova.", "page": &"", "gate": &"doll_sat"},
	&"vela": {"text": "vela de cera, acesa. Não diminui.", "page": &"", "gate": &""},
	&"casaco": {"text": "casaco de lã pendurado na entrada. Do meu tamanho, na escala da casa.", "page": &"", "gate": &""},
	&"figura_inacio_a": {"text": "figura sentada, cabelo branco, relógio de bolso parado às 03:33.", "page": &"p4", "gate": &""},
	&"figura_inacio_b": {"text": "figura sentada, mais gasta que a do lado. O mesmo relógio de bolso.", "page": &"", "gate": &""},
	&"figura_catalogador": {"text": "figura sentada, sem relógio de bolso. No colo, um caderno igual ao meu.", "page": &"p5", "gate": &""},
	&"pagina_cabana": {"text": "página solta debaixo da almofada da cabana. Letra de Inácio.", "page": &"p3", "gate": &"after_hora"},
	&"lencois": {"text": "móveis cobertos com lençóis no sótão. Debaixo de um deles, a mesma cama do quarto, de novo.", "page": &"", "gate": &""},
	&"pendulo": {"text": "pêndulo da torre, maior que eu. Bate fora do compasso do relógio da entrada.", "page": &"", "gate": &""},
	&"dedal": {"text": "dedal de costura do tamanho de uma cabana. Dentro, um cobertor e a marca de uma cabeça.", "page": &"", "gate": &""},
	&"relogios_varela": {"text": "relógios na vitrine da Relojoaria Varela, cada um numa hora. Nenhum passa das 03:32.", "page": &"", "gate": &""},
}

## The four pieces of Inácio's pocket watch: Elias notes each one as he
## picks it up, and the diary page that was with it.
const NOTES := {
	&"coroa": {"text": "coroa de relógio de bolso, latão serrilhado. Estava no fim da passagem, onde o menino a deixou.", "page": &"p6"},
	&"ponteiros": {"text": "par de ponteiros de aço azulado, presos atrás do mostrador da torre. Apontavam para as 03:33.", "page": &"p7"},
	&"mostrador": {"text": "mostrador de esmalte, rachado entre o 3 e o 4. Guardado numa caixa de relógio maior que eu.", "page": &"p8"},
	&"caixa": {"text": "caixa de relógio de bolso, prata, gravada: \"I. V. — para não chegar lá\".", "page": &"p9"},
}

const PAGES := {
	&"p1": "O médico diz meses. A falha diz mais: 03:33, numa madrugada de março.\nLeio a mesma hora em todos os pêndulos.\nVou fazer um relógio que nunca chegue lá.",
	&"p2": "Refiz de memória a casa da rua do Porto.\nA cabana, a bola, a caixa a que minha mãe dava corda.\nLá dentro eu ainda não tenho idade para morrer.",
	&"p3": "Entrei. Deu certo, mais ou menos.\nÀs 03:33 eu morro de novo, dou corda e recomeço.\nPerdi a conta. A casa ficou cheia de mim.\nA casa sou eu.",
	&"p4": "As mais antigas já nem se mexem.\nGastei tanto essas versões que viraram bonecos.\nAinda sussurram quando o relógio para.",
	&"p5": "Dentro do caderno, a carta que me contratou. Letra de Inácio.\nDatada de seis anos depois do enterro.\nNa última linha do caderno: \"Item 231 — catalogador.\"",
	&"p6": "Eu tinha sete anos e uma porta só minha atrás da parede.\nMeu pai riscou de giz: \"a porta do Inácio\".\nLá dentro o tempo não entrava. Eu achava.",
	&"p7": "Aos catorze fui ser aprendiz do velho Varela.\nEle dizia que o ponteiro não mostra a hora: empurra.\nSubi na torre da igreja para ver o mecanismo por dentro. Nunca mais desci de verdade.",
	&"p8": "Guardo na gaveta o que não deu certo.\nMostradores sem número, molas que perderam a força, o anel dela.\nUma gaveta inteira de anos que eu não contei.",
	&"p9": "Comprei a loja quando Varela morreu e fiz dela maquete também,\npara ele ter onde ficar. Os relógios da vitrine não concordam entre si.\nNenhum deles chega às 03:33. Eu cuidei disso.",
}
