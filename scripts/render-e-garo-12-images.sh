#!/bin/zsh
set -euo pipefail

# e 가로 12 황금기사 극한 공식 이미지 가공 스크립트.
# 원본(*-source.*)은 보존하고, 기기 사진·RUSH 화면 크롭과 한국어 번역본을 별도 PNG로 만든다.
#
# 원본 출처(サンセイR&D 공식):
#   machine-source.png : https://www.sansei-rd.co.jp/p_garo_archive/images/archive/machine/main12.png
#   rush-source.jpg    : https://www.sansei-rd.co.jp/p_garo_archive/images/archive/ekisyou/main12_a02.jpg
#   spec-source.png    : 제품 PDF(products23/e_garo12_ok/assets/pdf/e_garo12_ok.pdf) 4쪽을 2400px 폭으로 렌더
#   flow-source.png    : 같은 PDF 5쪽(ゲームフロー)을 2400px 폭으로 렌더
# PDF 렌더는 macOS PDFKit(Swift, PDFPage.thumbnail)을 사용했다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/e-garo-12"

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
NAVY="0.03 0.03 0.12"
RED="0.82 0.05 0.03"
BLUE="0.02 0.05 0.35"

# 기기 사진: 위쪽 투명 여백 제거
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/machine-source.png" \
  --cmd image.crop --params '{"x":0,"y":375,"width":432,"height":625,"targetWidth":432,"targetHeight":625,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine.png" --format png >/dev/null

# LT 카드용 화면: 가로 vs 누에 배틀(5:4 → 4:3)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/rush-source.jpg" \
  --cmd image.crop --params '{"x":0,"y":32,"width":1280,"height":960,"targetWidth":1280,"targetHeight":960,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

# 한국어 번역본 1: 게임 플로우(원본 2400×1311)
cmds=()
add_panel 860 18 680 125 ${=NAVY} "제목 패널";                add_line 1200 112 80 $W "게임 플로우" "제목"
add_panel 80 215 320 60 ${=BLUE} "통상시 패널";               add_line 240 262 40 $W "통상시" "통상시"
add_panel 165 298 150 42 ${=BLUE} "대당첨 확률 패널";         add_line 240 330 26 $W "대당첨 확률" "대당첨 확률"
add_panel 128 352 45 52 ${=BLUE} "약 349 패널";               add_line 150 392 36 $W "약" "약 349"
add_panel 120 655 235 44 ${=BLUE} "액정 도안 패널";           add_line 237 688 25 $W "액정 도안 당첨 확률" "액정 도안 당첨 확률"
add_panel 128 710 44 52 ${=BLUE} "약 437 패널";               add_line 150 752 34 $W "약" "약 437"
add_panel 150 1025 170 44 ${=BLUE} "가로 차지 패널";          add_line 235 1056 26 $W "가로 차지" "가로 차지"
add_panel 138 1078 84 56 ${=BLUE} "약 1749 패널";             add_line 180 1120 32 $W "약 1/" "약 1749"
add_panel 150 1124 175 32 ${=BLUE} "특도 1 패널";             add_line 237 1148 17 $W "※특도 1 · 2R 대당첨" "특도 1"
add_panel 545 215 290 60 ${=BLUE} "1st 배틀 패널";            add_line 690 262 40 $W "1st 배틀" "1st 배틀"
add_panel 578 750 230 46 ${=NAVY} "승리 패널";                add_line 693 787 30 $W "승리: 1500개" "승리"
add_panel 578 1040 230 46 ${=NAVY} "패배 패널";               add_line 693 1077 30 $W "패배: 1500개" "패배"
add_panel 1050 222 470 75 ${=NAVY} "극한 7500 패널";          add_line 1285 283 50 $W "극한 7500 배틀" "극한 7500"
add_panel 1105 325 340 46 ${=NAVY} "실질 확률 패널";          add_line 1275 360 28 $W "우타 중 실질 확률 1/1" "실질 확률"
add_panel 1280 885 180 70 ${=BLUE} "1500 통상 패널";          add_block 1280 892 180 60 30 $W "1500개\n통상" "1500 통상"
add_panel 1280 958 295 150 ${=BLUE} "3000 획득 패널";         add_block 1280 975 295 120 34 $W "1st 배틀과 합쳐\n3000개 획득" "3000 획득"
add_panel 1795 338 120 50 ${=NAVY} "계속률 패널";             add_line 1855 374 30 $W "계속률" "계속률"
add_panel 1733 446 55 62 ${=RED} "약 76 패널";                add_line 1760 492 40 $W "약" "약 76"
add_panel 2030 478 115 46 ${=NAVY} "우타 패널";               add_line 2087 512 30 $W "우타" "우타"
add_panel 1990 575 320 185 ${=BLUE} "7500 LT 패널";           add_block 1990 598 320 150 50 $W "7500개\n+LT 계속" "7500 LT"
add_panel 1985 795 300 150 ${=BLUE} "1500 LT 패널";           add_block 1985 818 300 110 46 $W "1500개\n+LT 계속" "1500 LT"
add_panel 1905 1018 285 90 ${=BLUE} "1500 통상 하단 패널";    add_line 2047 1075 40 $W "1500개 통상" "1500 통상 하단"
add_panel 20 1262 660 49 ${=NAVY} "각주 패널"
add_block 20 1266 660 44 16 $W "※출옥은 지급 구슬 수 ※7500개 = 10R×5회 ※3000개 = 10R×2회\n※1 가로 차지(2R 대당첨) 제외 ※2 조건장치 작동 확률과 다름" "각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.png" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 한국어 번역본 2: 스펙 요약(원본 2400×1311)
cmds=()
add_panel 265 112 340 80 ${=NAVY} "대당첨 패널";               add_line 435 172 54 $W "대당첨 확률" "대당첨 확률"
add_panel 118 382 75 95 ${=RED} "약 349 패널";                 add_line 155 458 60 $W "약" "약 349"
add_panel 915 112 580 80 ${=NAVY} "액정 도안 패널";            add_line 1205 172 50 $W "액정 도안 당첨 확률" "액정 도안"
add_panel 880 385 80 90 ${=RED} "약 437 패널";                 add_line 920 455 56 $W "약" "약 437"
add_panel 1060 508 290 46 ${=NAVY} "437 주석 패널";            add_block 1060 510 290 42 17 $W "※가로 차지(2R 대당첨) 제외\n※조건장치 작동 확률과 다름" "437 주석"
add_panel 1665 112 590 80 ${=NAVY} "실질 확률 패널";           add_line 1960 172 50 $W "우타 중 실질 확률" "실질 확률"
add_panel 1695 372 545 105 ${=RED} "루프 타입 패널";           add_line 1968 452 80 $W "루프 타입" "루프 타입"
add_panel 160 712 570 90 ${=NAVY} "출옥 배분 패널";            add_line 445 785 52 $W "우타 중 출옥 배분" "출옥 배분"
add_panel 245 808 420 72 ${=NAVY} "1500 or 패널";              add_line 455 868 58 $W "1500개 or" "1500 or"
add_panel 635 985 115 110 ${=RED} "7500 개 패널";              add_line 692 1070 80 $W "개" "7500 개"
add_panel 890 712 615 90 ${=NAVY} "LT 계속률 패널";            add_line 1197 785 48 $W "魔戒CHANCE LT 계속률" "LT 계속률"
add_panel 915 985 90 110 ${=RED} "약 76 패널";                 add_line 960 1060 72 $W "약" "약 76"
add_panel 1685 700 560 110 ${=NAVY} "LT 중 7500 비율 패널";    add_block 1685 708 560 100 42 $W "魔戒CHANCE LT 중\n7500개 비율" "LT 중 7500 비율"
add_panel 1690 980 90 110 ${=RED} "약 25 패널";                add_line 1735 1055 72 $W "약" "약 25"
add_panel 340 1124 200 30 ${=NAVY} "7500 주석 좌 패널";        add_line 440 1147 17 $W "※7500개 = 10R×5회" "7500 주석 좌"
add_panel 1890 1124 200 30 ${=NAVY} "7500 주석 우 패널";       add_line 1990 1147 17 $W "※7500개 = 10R×5회" "7500 주석 우"
add_panel 25 1283 215 26 ${=NAVY} "출옥 주석 패널";            add_line 132 1303 16 $W "※출옥은 지급 구슬 수" "출옥 주석"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.png" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격)
for translated in flow-ko.png spec-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":656,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
