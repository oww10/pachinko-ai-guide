#!/bin/zsh
set -euo pipefail

PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-godzilla-vs-evangelion-2"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[115,18,926,100],"radii":22,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":4,"color":"#ff6a20","opacity":100,"align":"inside"},"name":"한국어 전체 플로우 제목"}' \
  --cmd type.create --params '{"x":578,"y":84,"text":"고지라 대 에반게리온 2 · 전체 게임 플로우","font":"NanumGothic","size":42,"color":"#ffffff","align":"center","name":"한국어 전체 플로우 제목"}' \
  --out "$ASSET_DIR/flow-overview-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/normal-source.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[28,18,844,72],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#28c5ff","opacity":100,"align":"inside"},"name":"통상시 제목"}' \
  --cmd type.create --params '{"x":450,"y":67,"text":"통상시 · 희귀역과 규정 게임 수","font":"NanumGothic","size":32,"color":"#ffffff","align":"center","name":"통상시 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[42,334,816,106],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#28c5ff","opacity":100,"align":"inside"},"name":"통상시 설명"}' \
  --cmd type.create --params '{"box":[72,350,756,78],"text":"희귀역·규정 G수 → 전조 또는 CZ\nG침식역 성립 후 소역 변이와 보너스를 노린다","font":"NanumGothic","size":23,"color":"#ffffff","align":"center","name":"통상시 설명"}' \
  --out "$ASSET_DIR/flow-normal-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/bonus-source.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[28,18,844,72],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#f8b31e","opacity":100,"align":"inside"},"name":"보너스 제목"}' \
  --cmd type.create --params '{"x":450,"y":67,"text":"보너스 · 종료 후 AT 도전","font":"NanumGothic","size":32,"color":"#ffffff","align":"center","name":"보너스 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[42,334,816,106],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#f8b31e","opacity":100,"align":"inside"},"name":"보너스 설명"}' \
  --cmd type.create --params '{"box":[72,350,756,78],"text":"평균 약 73매 · 에바 보너스 AT 기대 약 41%\n고지라 보너스 AT 기대 약 64%","font":"NanumGothic","size":23,"color":"#ffffff","align":"center","name":"보너스 설명"}' \
  --out "$ASSET_DIR/flow-bonus-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/at-source.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[28,18,844,72],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#ff4b24","opacity":100,"align":"inside"},"name":"AT 제목"}' \
  --cmd type.create --params '{"x":450,"y":67,"text":"AT · 고지에바 RUSH","font":"NanumGothic","size":34,"color":"#ffffff","align":"center","name":"AT 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[42,334,816,106],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#ff4b24","opacity":100,"align":"inside"},"name":"AT 설명"}' \
  --cmd type.create --params '{"box":[72,350,756,78],"text":"순증 약 5.2매/G · 초기 50G 이상\n임팩트 배틀 → 진격 찬스 성공 시 추가 G수가 10배","font":"NanumGothic","size":23,"color":"#ffffff","align":"center","name":"AT 설명"}' \
  --out "$ASSET_DIR/flow-at-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/upper-source.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[28,18,844,72],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#ffb000","opacity":100,"align":"inside"},"name":"상위 제목"}' \
  --cmd type.create --params '{"x":450,"y":67,"text":"카이저 기도라 결전 · G각성 RUSH","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"상위 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[42,370,816,112],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":3,"color":"#ffb000","opacity":100,"align":"inside"},"name":"상위 설명"}' \
  --cmd type.create --params '{"box":[72,385,756,82],"text":"AT 종료 후 일부에서 4G 결전\n승리하면 상한 성능이 강화된 상위 AT로 진입","font":"NanumGothic","size":23,"color":"#ffffff","align":"center","name":"상위 설명"}' \
  --out "$ASSET_DIR/flow-upper-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/machine-source.png" \
  --cmd image.crop --params '{"x":0,"y":0,"width":380,"height":598,"targetWidth":760,"targetHeight":1196,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine-hero.png" --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/kv-source.jpg" \
  --cmd image.crop --params '{"x":260,"y":50,"width":1400,"height":788,"targetWidth":1200,"targetHeight":675,"resample":"lanczos"}' \
  --out "$ASSET_DIR/at-screen.png" --format png >/dev/null

echo "L Godzilla vs Evangelion 2 PhotoCraft assets written to $ASSET_DIR"
