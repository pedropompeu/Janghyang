# Licenças dos assets

Spec §14.2: todo arquivo em `assets/` tem sua linha aqui. O bruto fica em
`arte/fontes/` (fora do git), o script que o edita em `arte/blender/`, e o
resultado aqui. Sem o arquivo, o jogo volta ao bloco.

Origem comum das figuras: Human Base Meshes v1.4.1 (Blender Studio),
<https://mirror.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip>,
sha256 `811f43accbb31a88266d932f8f5563b2d13586fca0ba2693aad1f5fe582b3515`.

| arquivo | origem | autor | licença | data | edição |
|---|---|---|---|---|---|
| models/figura_adulto.glb | Human Base Meshes v1.4.1, `body_male_realistic` | Blender Studio e comunidade | CC0 | 2026-11-09 | `arte/blender/figuras.py figura_adulto`: roupa esculpida (casaco, calça, sapato, cabelo), esqueleto de 16 ossos, altura 1,77 m |
| models/figura_menino.glb | Human Base Meshes v1.4.1, `body_male_realistic` | Blender Studio e comunidade | CC0 | 2026-11-09 | `arte/blender/figuras.py figura_menino`: proporções de menino (cabeça maior, membros mais finos), rosto suavizado |
| models/gasto.glb | Human Base Meshes v1.4.1, `body_male_realistic` | Blender Studio e comunidade | CC0 | 2026-11-09 | `arte/blender/figuras.py gasto`: sem olhos, dedos longos, rachaduras fundas |
| textures/figura_adulto.png | Human Base Meshes v1.4.1 (malha base) | Blender Studio e comunidade | CC0 | 2026-11-09 | `arte/blender/figuras.py`: oclusão de ambiente e craquelê de porcelana assados |
| textures/figura_menino.png | Human Base Meshes v1.4.1 (malha base) | Blender Studio e comunidade | CC0 | 2026-11-09 | `arte/blender/figuras.py`: oclusão de ambiente e craquelê de porcelana assados |
| textures/gasto.png | Human Base Meshes v1.4.1 (malha base) | Blender Studio e comunidade | CC0 | 2026-11-09 | `arte/blender/figuras.py`: oclusão de ambiente e craquelê pesado assados |
