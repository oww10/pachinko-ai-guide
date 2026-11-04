#!/bin/zsh
set -euo pipefail

PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-tokyo-ghoul"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow_img_01.webp" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[210,28,1330,220],"radii":26,"fill":[0.03,0.02,0.05,0.94],"stroke":{"width":5,"color":"#d94b57","opacity":100,"align":"inside"},"name":"한국어 플로우 제목"}' \
  --cmd type.create --params '{"x":875,"y":165,"text":"L 도쿄 구울 · 전체 게임 플로우","font":"NanumGothic","size":72,"color":"#ffffff","align":"center","name":"한국어 플로우 제목"}' \
  --cmd image.crop --params '{"x":0,"y":0,"width":1750,"height":5000,"targetWidth":1050,"targetHeight":3000,"resample":"lanczos"}' \
  --out "$ASSET_DIR/flow-overview-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow_img_02.webp" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,28,1320,105],"radii":18,"fill":[0.03,0.02,0.05,0.94],"stroke":{"width":3,"color":"#e74f5a","opacity":100,"align":"inside"},"name":"통상시 제목"}' \
  --cmd type.create --params '{"x":730,"y":96,"text":"통상시 · CZ와 AT를 노리는 구간","font":"NanumGothic","size":42,"color":"#ffffff","align":"center","name":"통상시 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[105,585,1250,185],"radii":20,"fill":[0.02,0.02,0.04,0.94],"stroke":{"width":3,"color":"#b63a47","opacity":100,"align":"inside"},"name":"통상시 설명"}' \
  --cmd type.create --params '{"box":[150,610,1160,140],"text":"희귀역·규정 게임 수 → CZ\n레미니센스 성공 약 50% · 대식가 리제 약 75%\n에피소드 보너스는 AT 직행","font":"NanumGothic","size":28,"color":"#ffffff","align":"center","name":"통상시 설명"}' \
  --cmd image.crop --params '{"x":0,"y":0,"width":1460,"height":802,"targetWidth":1000,"targetHeight":549,"resample":"lanczos"}' \
  --out "$ASSET_DIR/flow-normal-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow_img_05.webp" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,28,1320,105],"radii":18,"fill":[0.03,0.02,0.05,0.94],"stroke":{"width":3,"color":"#e74f5a","opacity":100,"align":"inside"},"name":"AT 제목"}' \
  --cmd type.create --params '{"x":730,"y":96,"text":"AT ‘도쿄 구울 咬’","font":"NanumGothic","size":45,"color":"#ffffff","align":"center","name":"AT 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[105,1450,1250,260],"radii":20,"fill":[0.02,0.02,0.04,0.94],"stroke":{"width":3,"color":"#b63a47","opacity":100,"align":"inside"},"name":"AT 설명"}' \
  --cmd type.create --params '{"box":[155,1485,1150,190],"text":"초기 약 150매 · 순증 약 4.0매/G\n희귀역으로 매수 추가와 구울 대결 추첨\n대결 승리 시 BITES · 10번째까지 아리마 등장","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"AT 설명"}' \
  --cmd image.crop --params '{"x":0,"y":0,"width":1460,"height":1801,"targetWidth":1000,"targetHeight":1234,"resample":"lanczos"}' \
  --out "$ASSET_DIR/flow-at-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow_img_06.webp" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,28,1320,105],"radii":18,"fill":[0.03,0.02,0.05,0.94],"stroke":{"width":3,"color":"#e74f5a","opacity":100,"align":"inside"},"name":"특화 제목"}' \
  --cmd type.create --params '{"x":730,"y":96,"text":"BITES · 특화 구간","font":"NanumGothic","size":45,"color":"#ffffff","align":"center","name":"특화 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[105,620,1250,195],"radii":20,"fill":[0.02,0.02,0.04,0.94],"stroke":{"width":3,"color":"#b63a47","opacity":100,"align":"inside"},"name":"특화 설명"}' \
  --cmd type.create --params '{"box":[155,650,1150,140],"text":"BITES: 소역으로 보상 등급 상승\n백족 각성 기대 약 300매 · 외눈박이 올빼미 약 500매\n보상 획득 후 AT 복귀","font":"NanumGothic","size":29,"color":"#ffffff","align":"center","name":"특화 설명"}' \
  --cmd image.crop --params '{"x":0,"y":0,"width":1460,"height":852,"targetWidth":1000,"targetHeight":584,"resample":"lanczos"}' \
  --out "$ASSET_DIR/flow-special-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow_img_07.webp" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,28,1320,105],"radii":18,"fill":[0.03,0.02,0.05,0.94],"stroke":{"width":3,"color":"#e74f5a","opacity":100,"align":"inside"},"name":"상위 제목"}' \
  --cmd type.create --params '{"x":730,"y":96,"text":"아리마 저지먼트 · 상위 구간","font":"NanumGothic","size":41,"color":"#ffffff","align":"center","name":"상위 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[105,900,1250,205],"radii":20,"fill":[0.02,0.02,0.04,0.94],"stroke":{"width":3,"color":"#b63a47","opacity":100,"align":"inside"},"name":"상위 설명"}' \
  --cmd type.create --params '{"box":[155,930,1150,145],"text":"아리마 저지먼트: 5G · 성공 기대 약 61%\n성공 시 ‘CCG의 사신’ · 실패 시 AT 종료\n강력한 추가 보상 구간으로 연결","font":"NanumGothic","size":29,"color":"#ffffff","align":"center","name":"상위 설명"}' \
  --cmd image.crop --params '{"x":0,"y":0,"width":1460,"height":1156,"targetWidth":1000,"targetHeight":792,"resample":"lanczos"}' \
  --out "$ASSET_DIR/flow-upper-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec_img_01.webp" \
  --cmd image.crop --params '{"x":8,"y":82,"width":300,"height":555,"targetWidth":600,"targetHeight":1110,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine-hero.png" --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow_img_05.webp" \
  --cmd image.crop --params '{"x":120,"y":170,"width":1220,"height":686,"targetWidth":1200,"targetHeight":675,"resample":"lanczos"}' \
  --out "$ASSET_DIR/at-screen.png" --format png >/dev/null

echo "L Tokyo Ghoul PhotoCraft assets written to $ASSET_DIR"
