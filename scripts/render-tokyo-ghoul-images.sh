#!/bin/zsh
set -euo pipefail

# e 도쿄 구울 공식 이미지 가공 스크립트.
# 원본(*-source.*)은 보존하고, 기기 사진·RUSH 화면 크롭과 한국어 번역본을 별도 PNG로 만든다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/tokyo-ghoul"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# panel x y w h r g b name → 불투명 번역 패널(색 지정)
panel() {
  print -r -- "{\"kind\":\"roundedRect\",\"rect\":[$1,$2,$3,$4],\"radii\":14,\"fill\":[$5,$6,$7,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$8\"}"
}
# line x baselineY size color text name → 가운데 정렬 한 줄 문구
line() {
  print -r -- "{\"x\":$1,\"y\":$2,\"text\":\"$5\",\"font\":\"NanumGothic\",\"size\":$3,\"color\":\"$4\",\"align\":\"center\",\"name\":\"$6\"}"
}
# block x y w h size color text name → 박스 안 여러 줄 문구(\n 사용)
block() {
  print -r -- "{\"box\":[$1,$2,$3,$4],\"text\":\"$7\",\"font\":\"NanumGothic\",\"size\":$5,\"color\":\"$6\",\"align\":\"center\",\"name\":\"$8\"}"
}
add_panel() { cmds+=(--cmd shape.create --params "$(panel "$@")"); }
add_line()  { cmds+=(--cmd type.create --params "$(line "$@")"); }
add_block() { cmds+=(--cmd type.create --params "$(block "$@")"); }

W="#ffffff"

# 기기 사진: 공식 筐体 이미지를 사이트용 크기로 축소
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/machine-source.png" \
  --cmd image.imageSize --params '{"width":676,"height":918,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine.png" --format png >/dev/null

# RUSH 카드용 화면: HYPER 6000 BONUS
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-source.jpg" \
  --cmd image.crop --params '{"x":1078,"y":5040,"width":775,"height":625,"targetWidth":775,"targetHeight":625,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

# 한국어 번역본 1: 공식 게임 플로우(원본 2096×5796)
cmds=()
add_panel 540 165 700 195 0.0 0.05 0.35 "통상시 패널";          add_line 890 295 80 $W "통상시" "통상시"
add_panel 1495 618 390 76 0.02 0.03 0.08 "차지 제목 패널";      add_line 1690 676 42 $W "喰種 차지" "차지 제목"
add_panel 245 1405 330 84 0.0 0.0 0.0 "도안 당첨 패널";        add_line 410 1478 50 $W "도안 당첨" "도안 당첨"
add_panel 990 1405 190 84 0.0 0.0 0.0 "실패 패널";             add_line 1085 1478 50 $W "실패" "실패"
add_panel 1768 1178 130 1716 0.92 0.0 0.0 "차지 설명 패널"
add_block 1768 1190 130 1690 80 $W "차\n지\n에\n서\n도\n러\n시\n진\n입\n가\n능\n성\n!\n?" "차지 설명"
add_panel 500 2712 760 80 0.0 0.0 0.0 "게임성 패널";          add_line 880 2772 44 $W "2가지 게임성 중 선택" "게임성"
add_panel 292 3214 548 60 0.1 0.0 0.2 "연타 패널";             add_line 566 3254 25 $W "연타 성공 시 HYPER 喰種RUSH 획득!" "연타 성공"
add_panel 1030 3214 490 60 0.1 0.0 0.1 "역물 패널";            add_line 1275 3254 25 $W "역물 낙하 시 HYPER 喰種RUSH 획득!" "역물 낙하"
add_panel 425 3550 290 130 0.0 0.0 0.0 "성공 패널";            add_line 570 3660 84 $W "성공" "성공"
add_panel 1222 3498 162 62 0.1 0.1 0.0 "진입률 패널";          add_line 1303 3548 36 $W "진입률" "진입률"
add_panel 1020 3714 620 56 0.0 0.0 0.0 "차지 포함 패널";       add_line 1330 3756 32 $W "※차지에서의 진입 포함" "차지 포함"
add_panel 1350 4395 630 175 0.0 0.0 0.0 "ST 패널";             add_line 1665 4520 80 "#ffe83a" "ST 130회" "ST 130회"
add_panel 1035 4745 345 112 0.45 0.0 0.0 "계속률 패널";         add_line 1207 4825 56 $W "계속률" "계속률"
add_panel 1190 4850 183 200 0.45 0.0 0.0 "약 패널";            add_line 1281 4975 84 $W "약" "약"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/gameflow-ko.png" --format png >/dev/null

# 한국어 번역본 2: 공식 초당첨·RUSH 중 배분 원그래프(원본 1344×848)
cmds=()
add_panel 220 4 220 96 1 1 1 "특도 1 패널";                    add_line 330 78 52 "#111111" "특도 1" "특도 1"
add_panel 870 4 220 96 1 1 1 "특도 2 패널";                    add_line 980 78 52 "#111111" "특도 2" "특도 2"
add_panel 38 280 280 270 0.0 0.0 0.98 "49 패널";               add_block 38 296 280 240 52 $W "1500개\n약 49%\n통상으로" "49 슬라이스"
add_panel 335 280 285 255 0.98 0.0 0.0 "50 패널";              add_block 335 292 285 235 52 $W "1500개\n약 50%\nST 130회" "50 슬라이스"
add_panel 210 585 225 108 0.35 0.0 0.0 "300 패널";             add_line 322 655 50 $W "300개" "300개"
add_panel 185 696 275 150 1 1 1 "1 퍼센트 패널";                add_block 185 706 275 128 46 "#e00000" "약 1%\nST 130회" "1 퍼센트"
add_panel 985 112 335 178 0.25 0.12 0.0 "6000 패널";           add_block 985 120 335 160 52 $W "6000개\n약 3%" "6000"
add_panel 885 318 185 130 0.85 0.85 0.85 "ST 배지 패널";       add_block 885 336 185 100 34 "#111111" "ST\n130회" "ST 배지"
add_panel 690 478 350 195 0.25 0.12 0.0 "3000 패널";           add_block 690 492 350 170 52 $W "3000개\n약 97%" "3000"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec2-source.png" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":3318,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/gameflow-ko.png" --in-place --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":757,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/spec-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
