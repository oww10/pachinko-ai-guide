#!/bin/zsh
set -euo pipefail

PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
ASSET_DIR="/Users/oww/koggi-company/prototypes/pachinko-ai-guide/dist/assets/images/official/onirezero2"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

panel='{"kind":"roundedRect","rect":[525,20,550,95],"radii":18,"fill":[0.055,0.02,0.10,0.92],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"한국어 제목 패널"}'
title='{"x":800,"y":92,"text":"기본 정보","font":"NanumGothic","size":40,"color":"#ffffff","align":"center","name":"한국어 제목"}'

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/basic.jpg" \
  --cmd shape.create --params "$panel" \
  --cmd type.create --params "$title" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[58,164,445,345],"radii":14,"fill":[0.035,0.04,0.09,0.88],"stroke":{"width":2,"color":"#ffd84a","opacity":90,"align":"inside"},"name":"기본 스펙 번역 패널"}' \
  --cmd type.create --params '{"x":82,"y":213,"text":"대당첨 확률","font":"NanumGothic","size":24,"color":"#ffffff","name":"대당첨 확률"}' \
  --cmd type.create --params '{"x":82,"y":264,"text":"통상시 / RUSH 중","font":"NanumGothic","size":21,"color":"#ffe775","name":"상태 구분"}' \
  --cmd type.create --params '{"x":82,"y":317,"text":"RUSH 진입률","font":"NanumGothic","size":24,"color":"#ffffff","name":"RUSH 진입률"}' \
  --cmd type.create --params '{"x":82,"y":367,"text":"RUSH 회전 수","font":"NanumGothic","size":24,"color":"#ffffff","name":"RUSH 회전 수"}' \
  --cmd type.create --params '{"x":82,"y":418,"text":"RUSH 계속률","font":"NanumGothic","size":24,"color":"#ffffff","name":"RUSH 계속률"}' \
  --cmd type.create --params '{"x":82,"y":469,"text":"카운트 / 상구 수","font":"NanumGothic","size":22,"color":"#ffffff","name":"기타 스펙"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[330,516,370,58],"radii":12,"fill":[0.055,0.02,0.10,0.92],"stroke":{"width":2,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"당첨 배분 패널"}' \
  --cmd type.create --params '{"x":515,"y":558,"text":"대당첨 배분","font":"NanumGothic","size":26,"color":"#ffffff","align":"center","name":"대당첨 배분"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[204,580,135,42],"radii":10,"fill":[0.04,0.12,0.30,0.94],"stroke":{"width":2,"color":"#78c8ff","opacity":100,"align":"inside"},"name":"통상시 배지"}' \
  --cmd type.create --params '{"x":272,"y":611,"text":"통상시","font":"NanumGothic","size":18,"color":"#ffffff","align":"center","name":"통상시"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[683,580,140,42],"radii":10,"fill":[0.22,0.03,0.05,0.94],"stroke":{"width":2,"color":"#ff8a9a","opacity":100,"align":"inside"},"name":"RUSH 중 배지"}' \
  --cmd type.create --params '{"x":753,"y":611,"text":"RUSH 중","font":"NanumGothic","size":18,"color":"#ffffff","align":"center","name":"RUSH 중"}' \
  --out "$ASSET_DIR/basic-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow.jpg" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[530,16,540,100],"radii":18,"fill":[0.055,0.02,0.10,0.92],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"한국어 제목 패널"}' \
  --cmd type.create --params '{"x":800,"y":90,"text":"게임 플로우","font":"NanumGothic","size":42,"color":"#ffffff","align":"center","name":"게임 플로우"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[78,143,255,55],"radii":12,"fill":[0.04,0.12,0.30,0.94],"stroke":{"width":2,"color":"#78c8ff","opacity":100,"align":"inside"},"name":"통상시 제목"}' \
  --cmd type.create --params '{"x":205,"y":184,"text":"통상시","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"통상시"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[424,143,275,55],"radii":12,"fill":[0.03,0.18,0.08,0.94],"stroke":{"width":2,"color":"#78ff9c","opacity":100,"align":"inside"},"name":"보너스 제목"}' \
  --cmd type.create --params '{"x":562,"y":184,"text":"BONUS","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"보너스"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[824,143,290,55],"radii":12,"fill":[0.25,0.03,0.05,0.94],"stroke":{"width":2,"color":"#ff8a9a","opacity":100,"align":"inside"},"name":"RUSH 제목"}' \
  --cmd type.create --params '{"x":969,"y":184,"text":"RUSH","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"RUSH"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,790,1450,178],"radii":18,"fill":[0.025,0.03,0.07,0.90],"stroke":{"width":3,"color":"#ffd84a","opacity":90,"align":"inside"},"name":"게임 흐름 번역 요약"}' \
  --cmd type.create --params '{"box":[105,815,1390,130],"text":"통상시 당첨 → Re:제로 BONUS 또는 챌린지 BONUS → 성공 시 RUSH 진입\n백경 토벌 성공 또는 7도안 당첨 → 3000 BONUS 후 RUSH 직행\nRUSH: ST 144회 · 계속률 약 77% · Re:Start / 300개 / 1500개 / 6000개","font":"NanumGothic","size":24,"color":"#ffffff","align":"center","name":"게임 흐름 한국어 요약"}' \
  --out "$ASSET_DIR/gameflow-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/bonus.jpg" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[35,118,650,160],"radii":18,"fill":[0.09,0.03,0.06,0.91],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"3000 보너스 번역"}' \
  --cmd type.create --params '{"box":[65,145,590,105],"text":"백경 격파 또는 7도안\n3000개 + RUSH","font":"NanumGothic","size":32,"color":"#ffffff","align":"center","name":"3000 보너스 한국어"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[720,118,840,160],"radii":18,"fill":[0.09,0.03,0.06,0.91],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"챌린지 번역"}' \
  --cmd type.create --params '{"box":[760,145,760,105],"text":"그 외 도안 당첨\n자력으로 RUSH 획득","font":"NanumGothic","size":32,"color":"#ffffff","align":"center","name":"챌린지 한국어"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[785,705,735,220],"radii":18,"fill":[0.035,0.03,0.09,0.91],"stroke":{"width":3,"color":"#ff94f0","opacity":100,"align":"inside"},"name":"보너스 결과 번역"}' \
  --cmd type.create --params '{"box":[825,738,655,150],"text":"Re:제로 BONUS\n→ RUSH 직행\n챌린지 BONUS\n→ 연출 성공 시 RUSH","font":"NanumGothic","size":28,"color":"#ffffff","align":"center","name":"보너스 결과 한국어"}' \
  --out "$ASSET_DIR/bonus-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/rush-st.jpg" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[45,178,500,155],"radii":18,"fill":[0.055,0.02,0.10,0.91],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"ST 회전 번역"}' \
  --cmd type.create --params '{"box":[75,215,440,85],"text":"ST 144회","font":"NanumGothic","size":48,"color":"#ffffff","align":"center","name":"ST 144회"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[1040,176,510,180],"radii":18,"fill":[0.055,0.02,0.10,0.91],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"계속률 번역"}' \
  --cmd type.create --params '{"box":[1070,208,450,110],"text":"계속률\n약 77%","font":"NanumGothic","size":42,"color":"#ffffff","align":"center","name":"계속률"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[950,650,600,270],"radii":18,"fill":[0.055,0.02,0.10,0.91],"stroke":{"width":3,"color":"#ffd84a","opacity":100,"align":"inside"},"name":"6000개 번역"}' \
  --cmd type.create --params '{"box":[990,690,520,185],"text":"RUSH 중 대당첨의\n25%\n6000개","font":"NanumGothic","size":38,"color":"#ffffff","align":"center","name":"6000개"}' \
  --out "$ASSET_DIR/rush-st-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/basic-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":806,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/basic-ko.png" --in-place --format png >/dev/null

for translated in gameflow-ko.png bonus-ko.png rush-st-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":771,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
