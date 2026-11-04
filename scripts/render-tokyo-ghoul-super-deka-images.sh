#!/bin/zsh
set -euo pipefail

PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/tokyo-ghoul-super-deka"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-original.jpg" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,20,610,110],"radii":16,"fill":[0.01,0.03,0.10,0.94],"stroke":{"width":3,"color":"#4478ff","opacity":100,"align":"inside"},"name":"통상시 패널"}' \
  --cmd type.create --params '{"x":375,"y":93,"text":"통상시","font":"NanumGothic","size":48,"color":"#ffffff","align":"center","name":"통상시"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[45,435,300,105],"radii":14,"fill":[0.20,0.01,0.02,0.94],"stroke":{"width":2,"color":"#ff4b4b","opacity":100,"align":"inside"},"name":"도안 당첨 패널"}' \
  --cmd type.create --params '{"box":[65,458,260,65],"text":"도안 당첨","font":"NanumGothic","size":32,"color":"#ffffff","align":"center","name":"도안 당첨"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[395,435,310,105],"radii":14,"fill":[0.01,0.10,0.24,0.94],"stroke":{"width":2,"color":"#55b9ff","opacity":100,"align":"inside"},"name":"실패 패널"}' \
  --cmd type.create --params '{"box":[415,448,270,76],"text":"실패 시\n통상시 복귀","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"실패 시 통상 복귀"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[55,575,640,118],"radii":16,"fill":[0.22,0.01,0.02,0.94],"stroke":{"width":3,"color":"#ff4444","opacity":100,"align":"inside"},"name":"초당첨 패널"}' \
  --cmd type.create --params '{"box":[78,596,594,78],"text":"HYPER 구울 BONUS · 초당첨","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"초당첨"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[110,735,530,190],"radii":18,"fill":[0.02,0.02,0.03,0.90],"stroke":{"width":3,"color":"#ffd04a","opacity":100,"align":"inside"},"name":"초당첨 결과 패널"}' \
  --cmd type.create --params '{"box":[140,766,470,126],"text":"연출 성공  7500개 + RUSH\n비돌파      3000개 + 통상 복귀","font":"NanumGothic","size":29,"color":"#ffffff","align":"center","name":"초당첨 결과"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[90,1195,570,125],"radii":16,"fill":[0.25,0.12,0.00,0.94],"stroke":{"width":3,"color":"#ffcf35","opacity":100,"align":"inside"},"name":"진입률 패널"}' \
  --cmd type.create --params '{"box":[115,1218,520,80],"text":"성공 · 총 RUSH 진입 약 50%","font":"NanumGothic","size":30,"color":"#ffffff","align":"center","name":"RUSH 진입률"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[55,1360,640,115],"radii":16,"fill":[0.18,0.11,0.00,0.95],"stroke":{"width":3,"color":"#ffe24a","opacity":100,"align":"inside"},"name":"RUSH 제목 패널"}' \
  --cmd type.create --params '{"box":[78,1385,594,70],"text":"HYPER 구울 RUSH","font":"NanumGothic","size":38,"color":"#ffffff","align":"center","name":"RUSH 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[380,1505,315,155],"radii":15,"fill":[0.03,0.03,0.04,0.93],"stroke":{"width":2,"color":"#ffe24a","opacity":100,"align":"inside"},"name":"RUSH 사양 패널"}' \
  --cmd type.create --params '{"box":[405,1530,265,105],"text":"ST 5회\n당첨 약 1/7.7","font":"NanumGothic","size":30,"color":"#ffffff","align":"center","name":"RUSH 사양"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[60,1840,630,175],"radii":18,"fill":[0.16,0.01,0.02,0.94],"stroke":{"width":3,"color":"#ff5353","opacity":100,"align":"inside"},"name":"구울 맥스 루프 패널"}' \
  --cmd type.create --params '{"box":[88,1868,574,120],"text":"ALL 3000개 + 구울 MAX 루프\n성공할 때마다 3000개 추가 · 약 50% 반복","font":"NanumGothic","size":28,"color":"#ffffff","align":"center","name":"구울 맥스 루프"}' \
  --out "$ASSET_DIR/flow-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-original.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,18,652,105],"radii":16,"fill":[0.02,0.02,0.03,0.95],"stroke":{"width":3,"color":"#ffd348","opacity":100,"align":"inside"},"name":"초당첨 배분 제목"}' \
  --cmd type.create --params '{"x":396,"y":87,"text":"초당첨 배분 · 도안 당첨 시","font":"NanumGothic","size":34,"color":"#ffffff","align":"center","name":"초당첨 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[85,300,285,190],"radii":16,"fill":[0.00,0.12,0.35,0.94],"stroke":{"width":3,"color":"#4f9cff","opacity":100,"align":"inside"},"name":"3000 배분 패널"}' \
  --cmd type.create --params '{"box":[110,326,235,138],"text":"3000개\n약 50%\n통상 복귀","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"3000 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[422,300,285,190],"radii":16,"fill":[0.30,0.08,0.01,0.94],"stroke":{"width":3,"color":"#ffd348","opacity":100,"align":"inside"},"name":"7500 배분 패널"}' \
  --cmd type.create --params '{"box":[447,326,235,138],"text":"7500개\n약 50%\nRUSH 진입","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"7500 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[205,790,382,100],"radii":16,"fill":[0.02,0.02,0.03,0.95],"stroke":{"width":3,"color":"#ff5b4d","opacity":100,"align":"inside"},"name":"RUSH 배분 제목"}' \
  --cmd type.create --params '{"x":396,"y":857,"text":"RUSH 당첨 배분","font":"NanumGothic","size":34,"color":"#ffffff","align":"center","name":"RUSH 당첨 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[80,1110,290,185],"radii":16,"fill":[0.35,0.03,0.01,0.94],"stroke":{"width":3,"color":"#ff6655","opacity":100,"align":"inside"},"name":"RUSH 3000 패널"}' \
  --cmd type.create --params '{"box":[105,1140,240,125],"text":"3000개\n약 50%","font":"NanumGothic","size":38,"color":"#ffffff","align":"center","name":"RUSH 3000"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[415,1005,315,360],"radii":16,"fill":[0.25,0.16,0.00,0.94],"stroke":{"width":3,"color":"#ffd348","opacity":100,"align":"inside"},"name":"RUSH 상위 배분 패널"}' \
  --cmd type.create --params '{"box":[442,1032,261,305],"text":"9000개+α  12.5%\n\n9000개      12.5%\n\n6000개        25%","font":"NanumGothic","size":29,"color":"#ffffff","align":"center","name":"RUSH 상위 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[80,1430,650,120],"radii":16,"fill":[0.02,0.02,0.03,0.94],"stroke":{"width":2,"color":"#ffffff","opacity":80,"align":"inside"},"name":"루프 설명 패널"}' \
  --cmd type.create --params '{"box":[105,1455,600,72],"text":"3000개마다 약 50%로 추가 3000개 루프","font":"NanumGothic","size":28,"color":"#ffffff","align":"center","name":"루프 설명"}' \
  --out "$ASSET_DIR/spec-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-original.jpg" \
  --cmd image.crop --params '{"x":0,"y":1320,"width":750,"height":754,"targetWidth":1200,"targetHeight":1206,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
