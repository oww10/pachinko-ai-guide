#!/bin/zsh
set -euo pipefail

PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/lycoris-recoil"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-02.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[70,18,684,100],"radii":16,"fill":[0.02,0.04,0.10,0.95],"stroke":{"width":3,"color":"#55d9e7","opacity":100,"align":"inside"},"name":"한국어 사양 제목"}' \
  --cmd type.create --params '{"x":412,"y":84,"text":"핵심 사양 · 당첨 배분","font":"NanumGothic","size":36,"color":"#ffffff","align":"center","name":"한국어 사양 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[78,570,668,590],"radii":20,"fill":[0.01,0.04,0.10,0.93],"stroke":{"width":3,"color":"#49cbd9","opacity":100,"align":"inside"},"name":"핵심 사양 패널"}' \
  --cmd type.create --params '{"box":[115,612,594,500],"text":"통상시 대당첨        약 1/259.7\n\nRUSH 중 당첨         약 1/97.1\n\nRUSH 진입률              50%\n\nRUSH 계속률            약 75%\n\nST 회전 수               132회\n\nULTIMATE DRIVE 루프       50%","font":"NanumGothic","size":29,"color":"#ffffff","align":"center","name":"핵심 사양 한국어"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[55,1255,220,300],"radii":16,"fill":[0.20,0.01,0.04,0.94],"stroke":{"width":3,"color":"#ff687b","opacity":100,"align":"inside"},"name":"모드 A 패널"}' \
  --cmd type.create --params '{"box":[78,1290,174,220],"text":"모드 A\n\n750개\n100%\n\n당첨 후\n모드 재추첨","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"모드 A"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[300,1255,220,300],"radii":16,"fill":[0.20,0.13,0.01,0.94],"stroke":{"width":3,"color":"#ffd95b","opacity":100,"align":"inside"},"name":"모드 B 패널"}' \
  --cmd type.create --params '{"box":[323,1290,174,220],"text":"모드 B\n\n3000개 50%\n\n6000개 + UD\n50%","font":"NanumGothic","size":25,"color":"#ffffff","align":"center","name":"모드 B"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[545,1255,220,300],"radii":16,"fill":[0.02,0.16,0.16,0.94],"stroke":{"width":3,"color":"#55f2e2","opacity":100,"align":"inside"},"name":"UD 패널"}' \
  --cmd type.create --params '{"box":[568,1290,174,220],"text":"UD\n\n6000개 50%\n9000개 25%\n9001개+ 25%\n\nRUSH 복귀","font":"NanumGothic","size":23,"color":"#ffffff","align":"center","name":"UD 배분"}' \
  --out "$ASSET_DIR/spec-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-01.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[65,18,694,105],"radii":16,"fill":[0.02,0.05,0.10,0.95],"stroke":{"width":3,"color":"#55d9e7","opacity":100,"align":"inside"},"name":"통상 플로우 제목"}' \
  --cmd type.create --params '{"x":412,"y":88,"text":"통상시 → 초당첨","font":"NanumGothic","size":39,"color":"#ffffff","align":"center","name":"통상 플로우 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[112,500,600,590],"radii":20,"fill":[0.05,0.02,0.07,0.91],"stroke":{"width":3,"color":"#ff8caa","opacity":100,"align":"inside"},"name":"초당첨 결과 패널"}' \
  --cmd type.create --params '{"box":[150,545,524,500],"text":"S 도안 · 1500개 + RUSH\n\n7 도안/승격 · 600개 + RUSH\n\n600개 챌린지\n성공 시 RUSH · 실패 시 통상 복귀\n\n친아나고 BONUS · 310개\n빛나면 RUSH · 실패 시 통상 복귀\n\n전체 RUSH 진입률 50%","font":"NanumGothic","size":28,"color":"#ffffff","align":"center","name":"초당첨 결과 한국어"}' \
  --out "$ASSET_DIR/flow-initial-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-02.png" \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[65,20,694,105],"radii":16,"fill":[0.13,0.01,0.03,0.95],"stroke":{"width":3,"color":"#ff6578","opacity":100,"align":"inside"},"name":"RUSH 플로우 제목"}' \
  --cmd type.create --params '{"x":412,"y":90,"text":"SPECIAL LycoReco RUSH","font":"NanumGothic","size":35,"color":"#ffffff","align":"center","name":"RUSH 플로우 제목"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[100,165,624,360],"radii":20,"fill":[0.08,0.01,0.03,0.91],"stroke":{"width":3,"color":"#ff7082","opacity":100,"align":"inside"},"name":"RUSH 사양 패널"}' \
  --cmd type.create --params '{"box":[140,205,544,280],"text":"ST 132회 · 당첨 약 1/97.1\n계속률 약 75%\n\n모드 A 당첨: 750개\n모드 B 당첨: 3000개 또는\n6000개 + ULTIMATE DRIVE","font":"NanumGothic","size":28,"color":"#ffffff","align":"center","name":"RUSH 사양 한국어"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[105,555,614,125],"radii":16,"fill":[0.02,0.12,0.12,0.93],"stroke":{"width":3,"color":"#56e3d7","opacity":100,"align":"inside"},"name":"RUSH 복귀 패널"}' \
  --cmd type.create --params '{"box":[135,585,554,70],"text":"UD 종료 후에도 RUSH로 복귀","font":"NanumGothic","size":31,"color":"#ffffff","align":"center","name":"RUSH 복귀"}' \
  --cmd shape.create --params '{"kind":"roundedRect","rect":[85,1080,654,375],"radii":20,"fill":[0.18,0.10,0.01,0.93],"stroke":{"width":3,"color":"#ffd957","opacity":100,"align":"inside"},"name":"UD 구조 패널"}' \
  --cmd type.create --params '{"box":[125,1125,574,285],"text":"ULTIMATE DRIVE\n\n진입 시 6000개 획득\n3000개 추가가 50%로 반복\n\n실패하면 출옥을 마치고\nSPECIAL LycoReco RUSH로 복귀","font":"NanumGothic","size":29,"color":"#ffffff","align":"center","name":"UD 구조 한국어"}' \
  --out "$ASSET_DIR/flow-rush-ko.png" --format png

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-pc-02.png" \
  --cmd image.crop --params '{"x":380,"y":150,"width":560,"height":850,"targetWidth":900,"targetHeight":1366,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine.png" --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/rush-pc-01.jpg" \
  --cmd image.crop --params '{"x":300,"y":120,"width":1400,"height":788,"targetWidth":1200,"targetHeight":675,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
