#!/bin/zsh
set -euo pipefail

# P 신세기 에반게리온 ~미래로의 포효~ 공식 이미지 가공 스크립트.
# 원본(*-source.png)은 보존하고, 기기 사진·IMPACT MODE 화면 크롭과 한국어 번역본을 별도 PNG로 만든다.
#
# 원본 출처(eva-project.jp 공식, https://www.eva-project.jp/asuhenohoukou/img/):
#   gameflow_01.png -> flow-source.png  (게임 플로우)
#   spec_01.png     -> spec-source.png  (기본 스펙)
#   spec_02.png     -> chart-source.png (특도 1/2 배분 원그래프)
#   spec_04.png     -> machine-source.png (筐体, 참고용)
#   visual_05.png   -> 대표 이미지 mainImage로 그대로 사용
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/evangelion-mirai"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

cd "$ASSET_DIR"
[[ -f flow-source.png ]] || cp gameflow_01.png flow-source.png
[[ -f spec-source.png ]] || cp spec_01.png spec-source.png
[[ -f chart-source.png ]] || cp spec_02.png chart-source.png
[[ -f machine-source.png ]] || cp spec_04.png machine-source.png

# panel x y w h r g b name → 불투명 번역 패널
panel() {
  print -r -- "{\"kind\":\"roundedRect\",\"rect\":[$1,$2,$3,$4],\"radii\":10,\"fill\":[$5,$6,$7,1],\"stroke\":{\"width\":2,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$8\"}"
}
# line x baselineY size color text name → 가운데 정렬 한 줄
line() {
  print -r -- "{\"x\":$1,\"y\":$2,\"text\":\"$5\",\"font\":\"NanumGothic\",\"size\":$3,\"color\":\"$4\",\"align\":\"center\",\"name\":\"$6\"}"
}
# block x y w h size color text name → 박스 안 여러 줄
block() {
  print -r -- "{\"box\":[$1,$2,$3,$4],\"text\":\"$7\",\"font\":\"NanumGothic\",\"size\":$5,\"color\":\"$6\",\"align\":\"center\",\"name\":\"$8\"}"
}
add_panel() { cmds+=(--cmd shape.create --params "$(panel "$@")"); }
add_line()  { cmds+=(--cmd type.create --params "$(line "$@")"); }
add_block() { cmds+=(--cmd type.create --params "$(block "$@")"); }

W="#ffffff"
NAVY="0.05 0.05 0.12"
RED="0.55 0.03 0.03"
BLUE="0.02 0.08 0.3"

# 대표 이미지: 공식 비주얼 visual_05.png(초호기, 투명 배경)를 그대로 사용(가공 없음)

# RUSH 카드용 화면: IMPACT MODE
"$PHOTOCRAFT_BIN" run flow-source.png \
  --cmd image.crop --params '{"x":18,"y":928,"width":374,"height":300,"targetWidth":374,"targetHeight":300,"resample":"lanczos"}' \
  --out rush-screen.png --format png >/dev/null

# 한국어 번역본 1: 게임 플로우(원본 1106×1255)
cmds=()
add_panel 440 8 225 56 ${=NAVY} "통상시 패널";         add_line 552 50 36 $W "통상시" "통상시"
add_panel 60 302 230 28 ${=NAVY} "모드 선택 패널";     add_line 175 324 18 $W "선택 가능한 2가지 모드" "모드 선택"
add_panel 40 335 122 68 ${=NAVY} "노멀 패널";          add_block 40 342 122 56 20 $W "노멀\n모드" "노멀"
add_panel 190 335 122 68 ${=NAVY} "심플 패널";         add_block 190 342 122 56 20 $W "심플\n모드" "심플"
add_panel 362 318 195 62 ${=RED} "신 배경 패널";       add_line 460 360 30 $W "신 배경" "신 배경"
add_panel 614 318 195 62 ${=RED} "신 예고 패널";       add_line 712 360 30 $W "신 예고" "신 예고"
add_panel 866 318 195 62 ${=RED} "신 기체 패널";       add_line 964 360 30 $W "신 기체" "신 기체"
add_panel 140 452 110 38 ${=NAVY} "전회전 패널";       add_line 195 480 24 $W "전회전" "전회전"
add_panel 408 452 120 38 ${=NAVY} "135 패널";          add_line 468 480 24 $W "135 정렬" "135 정렬"
add_panel 645 452 130 38 ${=NAVY} "홀수 패널";         add_line 710 480 24 $W "홀수 도안" "홀수 도안"
add_panel 915 452 130 38 ${=NAVY} "짝수 패널";         add_line 980 480 24 $W "짝수 도안" "짝수 도안"
add_panel 90 698 130 38 ${=RED} "10R 확변 패널";       add_line 155 726 22 $W "10R 확변" "10R 확변"
add_panel 316 545 208 42 ${=RED} "폭주 패널";          add_line 420 578 28 $W "폭주 BONUS" "폭주 BONUS"
add_panel 360 698 130 38 ${=RED} "3R 확변 패널1";      add_line 425 726 22 $W "3R 확변" "3R 확변1"
add_panel 628 698 130 38 ${=RED} "3R 확변 패널2";      add_line 693 726 22 $W "3R 확변" "3R 확변2"
add_panel 905 698 130 38 ${=BLUE} "3R 통상 패널";      add_line 970 726 22 $W "3R 통상" "3R 통상"
add_panel 145 745 120 68 ${=NAVY} "전용 R 패널1";      add_block 145 750 120 60 20 "#ffd84a" "전용\n라운드" "전용1"
add_panel 410 745 120 68 ${=NAVY} "전용 R 패널2";      add_block 410 750 120 60 20 "#ffd84a" "전용\n라운드" "전용2"
add_panel 806 568 32 126 ${=RED} "확변 기대 패널";     add_block 806 572 32 120 17 $W "확\n변\n기\n대" "확변 기대"
add_panel 850 904 252 44 ${=NAVY} "찬스타임 제목 패널"; add_line 976 937 26 $W "찬스타임" "찬스타임"
add_panel 880 1080 170 36 ${=NAVY} "시단 패널";        add_line 965 1107 24 $W "시단 100회" "시단"
add_panel 785 1000 38 80 ${=NAVY} "대당첨 패널";       add_block 785 1004 38 72 18 $W "대\n당\n첨" "대당첨"
add_panel 440 860 238 62 ${=NAVY} "ST 패널";           add_line 559 912 46 "#ffd84a" "ST 163회" "ST"
add_panel 410 925 310 66 ${=NAVY} "ALL 패널";        add_line 565 980 50 "#ffd84a" "ALL 1500개" "ALL"
add_panel 410 988 310 30 ${=NAVY} "특도2 주석 패널";    add_line 565 1011 18 $W "※특도 2   ※출옥은 지급 구슬 수" "특도2 주석"
add_panel 425 1026 285 125 ${=NAVY} "계속률 패널";     add_block 425 1040 285 100 44 "#ffd84a" "계속률\n약 81%" "계속률"
add_panel 20 1180 380 40 ${=NAVY} "연출 선택 패널";    add_line 210 1210 22 $W "연출 밸런스를 선택 가능!" "연출 선택"
add_panel 405 1152 325 82 ${=NAVY} "ST 계속률 주석 패널"
add_block 405 1156 325 76 15 $W "※ST 계속률 약 80.7%에 잔여 보류\n인계 약 1.2%를 포함한 수치입니다" "ST 계속률 주석"
add_panel 745 1190 358 60 ${=NAVY} "확률 변동 주석 패널"
add_block 745 1194 358 54 16 $W "※확률 변동은 특정 라운드에서의\nV 입상이 조건" "확률 변동 주석"

"$PHOTOCRAFT_BIN" run flow-source.png "${cmds[@]}" --out flow-ko.png --format png >/dev/null

# 한국어 번역본 2: 스펙 요약(원본 1106×1126)
cmds=()
add_panel 45 45 340 85 ${=NAVY} "대당첨 확률 패널";      add_line 215 100 40 $W "대당첨 확률" "대당첨 확률"
add_panel 400 30 125 46 ${=RED} "저확률 패널";           add_line 462 64 26 $W "저확률 시" "저확률"
add_panel 400 102 125 46 ${=RED} "고확률 패널";          add_line 462 136 26 $W "고확률 시" "고확률"
add_panel 45 190 340 85 ${=NAVY} "시단 횟수 패널";       add_line 215 245 40 $W "시단 횟수" "시단 횟수"
add_panel 580 200 505 62 ${=NAVY} "시단 주석 패널"
add_block 580 204 505 56 20 $W "※고베이스 중 특도 1에서 통상 당첨 시 500회" "시단 주석"
add_panel 575 320 525 62 ${=NAVY} "ST 주석 패널"
add_block 575 324 525 56 20 $W "※확률 변동은 특정 라운드에서의 V 입상이 조건" "ST 주석"
add_panel 45 313 340 85 ${=NAVY} "ST 횟수 패널";        add_line 215 368 40 $W "ST 횟수" "ST 횟수"
add_panel 45 435 340 85 ${=NAVY} "ST 돌입률 패널";       add_line 215 490 40 $W "ST 돌입률" "ST 돌입률"
add_panel 580 425 515 100 ${=NAVY} "돌입률 주석 패널"
add_block 580 428 515 94 18 $W "※ST 돌입 비율 59% + 시단 100회 인계 약 26.9%\n+ 잔여 보류 인계 약 1.2%를 포함한 수치" "돌입률 주석"
add_panel 45 558 340 85 ${=NAVY} "ST 계속률 패널";       add_line 215 613 40 $W "ST 계속률" "ST 계속률"
add_panel 580 560 520 65 ${=NAVY} "계속률 주석 패널"
add_block 580 563 520 60 18 $W "※ST 계속률 약 80.7% + 잔여 보류 인계 약 1.2%를 포함" "계속률 주석"
add_panel 45 680 340 85 ${=NAVY} "상구 패널";            add_line 215 735 40 $W "상구" "상구"
add_panel 45 800 340 85 ${=NAVY} "카운트 패널";          add_line 215 855 40 $W "카운트" "카운트"
add_panel 45 925 340 85 ${=NAVY} "라운드 패널";          add_line 215 980 40 $W "라운드" "라운드"
add_panel 403 922 68 54 ${=RED} "3R 패널";              add_line 437 962 32 $W "3R" "3R"
add_panel 668 922 98 54 ${=RED} "10R 패널";             add_line 717 962 32 $W "10R" "10R"
add_panel 45 1040 340 80 ${=NAVY} "유타임 패널";         add_line 215 1090 36 $W "유 타임" "유 타임"
add_panel 405 1048 200 66 ${=RED} "비탑재 패널";         add_line 505 1098 44 $W "비탑재" "비탑재"
add_panel 400 984 175 26 ${=NAVY} "출옥 주석 패널";      add_line 487 1003 17 $W "※출옥은 지급 구슬 수" "출옥 주석"

"$PHOTOCRAFT_BIN" run spec-source.png "${cmds[@]}" --out spec-ko.png --format png >/dev/null

# 한국어 번역본 3: 특도 1/2 배분(원본 1106×540)
cmds=()
add_panel 108 8 95 40 ${=RED} "특도1 패널";              add_line 154 38 26 $W "특도 1" "특도 1"
add_panel 648 8 100 40 ${=RED} "특도2 패널";              add_line 697 38 26 $W "특도 2" "특도 2"
add_panel 292 15 200 192 ${=NAVY} "1500 패널";           add_block 292 22 200 180 28 "#ffd84a" "1500개\n10R 확변\n약 3%\nST 163회" "1500"
add_panel 68 126 168 186 ${=BLUE} "450 통상 패널";       add_block 68 150 168 156 26 $W "450개\n3R 통상\n41%\n시단 100회" "450 통상"
add_panel 275 248 168 172 ${=RED} "450 확변 패널";       add_block 275 256 168 158 26 $W "450개\n3R 확변\n56%\nST 163회" "450 확변"
add_panel 408 392 234 148 ${=NAVY} "돌입률 패널";        add_block 408 410 234 120 42 "#ffd84a" "돌입률\n약 70%" "돌입률"
add_panel 705 135 262 264 ${=NAVY} "ALL 1500 패널";      add_block 705 160 262 230 44 "#ffd84a" "ALL 1500개\n10R 확변\nST 163회" "ALL 1500"
add_panel 190 495 180 30 ${=NAVY} "출옥 좌 주석";        add_line 280 518 18 $W "※출옥은 지급 구슬 수" "출옥 좌"
add_panel 745 495 180 30 ${=NAVY} "출옥 우 주석";        add_line 835 518 18 $W "※출옥은 지급 구슬 수" "출옥 우"

"$PHOTOCRAFT_BIN" run chart-source.png "${cmds[@]}" --out chart-ko.png --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격)
"$PHOTOCRAFT_BIN" run flow-ko.png --cmd image.imageSize --params '{"width":1200,"height":1362,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out flow-ko.png --in-place --format png >/dev/null
"$PHOTOCRAFT_BIN" run spec-ko.png --cmd image.imageSize --params '{"width":1200,"height":1222,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out spec-ko.png --in-place --format png >/dev/null
"$PHOTOCRAFT_BIN" run chart-ko.png --cmd image.imageSize --params '{"width":1200,"height":586,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out chart-ko.png --in-place --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
