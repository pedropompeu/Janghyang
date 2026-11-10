# Human Base Meshes v1.4.1 (bruto, fora do git)

- Origem: <https://mirror.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip>
- Autor: Blender Studio e comunidade · Licença: CC0
- Baixado em 2026-11-09 como `bundle.zip`, sha256
  `811f43accbb31a88266d932f8f5563b2d13586fca0ba2693aad1f5fe582b3515`
- Extraído em `extraido/` (ignorado pelo git, junto com o zip).

Para refazer as figuras de `Janghyang/assets/` (rodar da raiz do repo):

```bash
mkdir -p arte/fontes/human-base-meshes/extraido
curl -L -o arte/fontes/human-base-meshes/bundle.zip <url acima>
sha256sum arte/fontes/human-base-meshes/bundle.zip   # confere com o hash acima
unzip -q arte/fontes/human-base-meshes/bundle.zip -d arte/fontes/human-base-meshes/extraido
blender -b --factory-startup --disable-autoexec \
  arte/fontes/human-base-meshes/extraido/human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend \
  --python arte/blender/figuras.py -- figura_adulto figura_menino gasto
```

`--preview DIR` no fim também renderiza vistas de conferência em `DIR`.
