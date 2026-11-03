#!/bin/zsh
set -euo pipefail

PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/gundam-seed-climax"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec.jpg" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[250,8,500,92],"radii":16,"fill":[0.02,0.05,0.12,0.94],"stroke":{"width":3,"color":"#49b9ff","opacity":100,"align":"inside"},"name":"한국어 제목 패널"}' \
  --cmd type.create --params '{"x":500,"y":75,"text":"대당첨 배분","font":"NanumGothic","size":38,"color":"#ffffff","align":"center","name":"한국어 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[18,125,290,115],"radii":14,"fill":[0.02,0.08,0.20,0.92],"stroke":{"width":2,"color":"#3f8cff","opacity":100,"align":"inside"},"name":"통상 복귀 패널"}' \
  --cmd type.create --params '{"box":[36,145,254,76],"text":"통상시 복귀\n1500개 · 48%","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"통상 복귀"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[690,125,290,115],"radii":14,"fill":[0.24,0.08,0.01,0.92],"stroke":{"width":2,"color":"#ff9b28","opacity":100,"align":"inside"},"name":"CLIMAX 진입 패널"}' \
  --cmd type.create --params '{"box":[708,145,254,76],"text":"CLIMAX 진입\n1500개 · 52%","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"CLIMAX 진입"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[18,580,465,130],"radii":14,"fill":[0.10,0.02,0.16,0.93],"stroke":{"width":2,"color":"#c88cff","opacity":100,"align":"inside"},"name":"CLIMAX 배분 패널"}' \
  --cmd type.create --params '{"box":[40,600,421,92],"text":"FULLBURST RUSH CLIMAX\n4500개 51% 유지 · 3000개 49% RUSH","font":"NanumGothic","size":22,"color":"#ffffff","align":"center","name":"CLIMAX 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[516,580,465,130],"radii":14,"fill":[0.02,0.12,0.08,0.93],"stroke":{"width":2,"color":"#66f0b0","opacity":100,"align":"inside"},"name":"일반 RUSH 배분 패널"}' \
  --cmd type.create --params '{"box":[538,600,421,92],"text":"FULLBURST RUSH\n3000개 이상 50% CLIMAX · 1500개 50% 유지","font":"NanumGothic","size":22,"color":"#ffffff","align":"center","name":"일반 RUSH 배분"}' \
  --out "$ASSET_DIR/spec-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/hero.jpg" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[75,320,1850,245],"radii":22,"fill":[0.015,0.025,0.08,0.91],"stroke":{"width":3,"color":"#55c7ff","opacity":100,"align":"inside"},"name":"한국어 게임 플로우 패널"}' \
  --cmd type.create --params '{"x":1000,"y":390,"text":"게임 플로우","font":"NanumGothic","size":46,"color":"#ffffff","align":"center","name":"게임 플로우 제목"}' \
  --cmd type.create --params '{"box":[130,420,1740,112],"text":"통상시 → 초당첨 52% → FULLBURST RUSH CLIMAX\nCLIMAX: 4500개 51% 유지 / 3000개 49% RUSH 이동\nRUSH: 3000개 이상 50% CLIMAX 승격 / 1500개 50% 유지","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"게임 플로우 한국어 요약"}' \
  --out "$ASSET_DIR/flow-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":360,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/flow-ko.png" --in-place --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":1391,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/spec-ko.png" --in-place --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/hero.jpg" \
  --cmd image.crop --params '{"x":350,"y":0,"width":1067,"height":600,"targetWidth":1200,"targetHeight":675,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
