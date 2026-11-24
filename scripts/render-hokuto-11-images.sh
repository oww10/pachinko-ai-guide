#!/bin/zsh
set -euo pipefail

# e 북두의 권 11 폭흉성 공식 이미지 가공 스크립트.
# 원본(*-source.jpg, key-visual.jpg)은 보존하고, RUSH 화면 크롭과 한국어 번역본을 별도 PNG로 만든다.
#
# 원본 출처(Sammy 공식 https://www.sammy.co.jp/japanese/product/pachinko/hok_ke11/):
#   key-visual.jpg : img/cover_pc.jpg (공식 사이트에는 기기 사진이 없어 키 비주얼을 대신 사용)
#   spec-source.jpg: img/spec.jpg (기본 정보)
#   flow-source.jpg: img/guide/gu_06.jpg (디지털 소책자 6쪽 · ゲームフロー)
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/hokuto-11"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# panel x y w h r g b name → 불투명 번역 패널(색 지정)
panel() {
  print -r -- "{\"kind\":\"roundedRect\",\"rect\":[$1,$2,$3,$4],\"radii\":12,\"fill\":[$5,$6,$7,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$8\"}"
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
NAVY="0.05 0.02 0.08"
RED="0.55 0.02 0.05"
BLUE="0.10 0.35 0.75"
DARK="0 0 0"

# flow-source.jpg는 CMYK 300dpi라 PhotoCraft에서 글자 크기·좌표가 어긋나므로 임시 RGB 72dpi PNG로 변환해 사용한다.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
sips -s format png -s dpiWidth 72 -s dpiHeight 72 "$ASSET_DIR/flow-source.jpg" --out "$TMP_DIR/flow-rgb.png" >/dev/null

# RUSH 카드용 화면: 소책자 6쪽의 TRIPLE HYPER BONUS 4500 화면(300×225 → 600×450 확대)
"$PHOTOCRAFT_BIN" run "$TMP_DIR/flow-rgb.png" \
  --cmd image.crop --params '{"x":385,"y":320,"width":300,"height":225,"targetWidth":600,"targetHeight":450,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

# 한국어 번역본 1: 게임 플로우(원본 2000×1315)
cmds=()
add_panel 740 40 520 100 ${=NAVY} "제목 패널";                 add_line 1000 118 70 $W "게임 플로우" "제목"
add_panel 108 450 172 52 ${=NAVY} "도안 당첨 확률 패널";       add_line 194 488 20 $W "도안 당첨 확률" "도안 당첨 확률"
add_panel 128 688 98 168 ${=DARK} "통상시 패널";                add_block 128 694 98 160 46 $W "통\n상\n시" "통상시"
add_panel 345 526 395 74 ${=NAVY} "4500 RUSH 패널";            add_line 542 580 34 $W "4,500개 + RUSH 진입!?" "4500 RUSH"
add_panel 405 866 152 54 ${=NAVY} "1500 패널";                 add_line 481 906 36 $W "1,500개" "1500"
add_panel 590 848 168 80 ${=NAVY} "연출 성공 패널";            add_block 590 856 168 70 20 $W "연출 성공 시\nRUSH 진입!?" "연출 성공"
add_panel 72 1010 192 36 ${=NAVY} "각성 찬스 패널";            add_line 168 1036 20 $W "권왕 각성 찬스" "각성 찬스"
add_panel 122 1178 96 44 ${=NAVY} "300 패널";                  add_line 170 1212 28 $W "300개" "300"
add_panel 460 1128 338 94 ${=NAVY} "각성 상승 패널";           add_block 460 1144 338 76 20 $W "권왕 각성 시 1,500개 상승\n+ RUSH 진입!?" "각성 상승"
add_panel 792 446 150 40 ${=NAVY} "RUSH 진입률 패널";          add_line 867 476 20 $W "RUSH 진입률" "RUSH 진입률"
add_panel 1158 322 530 155 ${=DARK} "출옥 50 패널";             add_block 1158 332 530 140 54 $W "출옥의 약 50%가\n6,000개 or 4,500개" "출옥 50"
add_panel 1748 205 244 100 ${=NAVY} "신 어태커 패널";          add_block 1748 214 244 90 26 $W "스트레스 프리\nNEW 어태커 탑재!" "신 어태커"
add_panel 1018 562 135 42 ${=DARK} "ST 횟수 패널";             add_line 1085 594 22 $W "ST 횟수" "ST 횟수"
add_panel 1012 670 148 40 ${=DARK} "잔여 보류 패널";           add_line 1086 700 18 $W "+잔여 보류 4개" "잔여 보류"
add_panel 1183 590 140 44 ${=DARK} "4500 하단 패널";           add_line 1253 623 28 $W "4,500개" "4500 하단"
add_panel 1353 590 140 44 ${=DARK} "1500 하단 패널";           add_line 1423 623 28 $W "1,500개" "1500 하단"
add_panel 1523 590 155 44 ${=DARK} "ST 리셋 패널";             add_line 1600 623 28 $W "ST 리셋" "ST 리셋"
add_panel 1168 644 500 72 ${=DARK} "두 RUSH 패널";             add_block 1168 650 500 64 17 $W "권왕과 구세주, 고를 수 있는 2가지 RUSH!\n도입 후 일정 기간이 지나면 새로운 RUSH가 2개 출현!?" "두 RUSH"
add_panel 1718 543 120 38 ${=DARK} "계속률 패널";             add_line 1778 572 24 $W "계속률" "계속률"
add_panel 1258 852 366 96 ${=NAVY} "극투 설명 패널";           add_block 1258 860 366 86 30 $W "『극투』 발생으로 궁극의\n상승 배틀로!!" "극투 설명"
add_panel 1552 946 354 128 ${=DARK} "6000 이상 패널";          add_line 1729 1056 70 $W "6,000개~" "6000 이상"
add_panel 1378 1148 105 74 ${=DARK} "최대 패널";               add_line 1430 1204 44 $W "최대" "최대"
add_panel 1892 1098 76 114 ${=DARK} "12000 개 패널";           add_line 1930 1180 60 $W "개" "12000 개"
add_panel 18 1248 1462 64 ${=DARK} "각주 패널"
add_block 18 1262 1462 46 16 $W "※출옥은 지급 기준 ※대당첨 출옥·시단 진입은 V 통과가 조건 ※도안 당첨 확률은 도안 당첨 연출과 권왕 각성 성공의 합산값\n※계속률 약 75%…시단 10회+잔여 보류 4개 합산 ※12,000개…당첨 시 보류 4개가 모두 당첨이고 마지막 보류가 6,000개일 때 (6,000개=1,500×4회, 4,500개=1,500×3회, 1,800개=300+1,500)" "각주"

"$PHOTOCRAFT_BIN" run "$TMP_DIR/flow-rgb.png" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 한국어 번역본 2: 기본 정보 스펙(원본 2000×1315)
cmds=()
add_panel 190 318 205 46 ${=NAVY} "도안 확률 패널";            add_line 292 352 27 $W "도안 당첨 확률" "도안 당첨 확률"
add_panel 598 318 205 46 ${=NAVY} "RUSH 진입 패널";            add_line 700 352 27 $W "RUSH 진입률" "RUSH 진입률"
add_panel 895 262 470 95 ${=NAVY} "특도 2 50 패널";            add_block 895 270 470 85 28 $W "특도 2 대당첨 출옥의\n약 50%가 (전동 서포트 중)" "특도 2 50"
add_panel 1234 440 176 95 ${=RED} "개 이상 패널";              add_line 1322 512 54 $W "개 이상" "개 이상"
add_panel 143 665 212 75 ${=RED} "도안 라벨 패널";             add_block 143 672 212 66 24 $W "도안 당첨 확률\n(통상시)" "도안 라벨"
add_panel 143 745 212 75 ${=RED} "RUSH 중 라벨 패널";         add_block 143 752 212 66 24 $W "RUSH 중 확률\n(C 시단 포함)" "RUSH 중 라벨"
add_panel 143 825 212 75 ${=RED} "ST 라벨 패널";               add_line 249 872 30 $W "ST 횟수" "ST 라벨"
add_panel 143 905 212 80 ${=RED} "계속률 라벨 패널";           add_block 143 914 212 66 24 $W "RUSH 계속률\n(C 시단 포함)" "계속률 라벨"
add_panel 143 990 212 95 ${=RED} "상구 라벨 패널";             add_line 249 1046 24 $W "상구 수 / 카운트" "상구 라벨"
add_panel 143 1092 212 106 ${=RED} "출옥 라벨 패널";           add_line 249 1152 28 $W "대당첨 출옥" "출옥 라벨"
add_panel 360 830 445 70 ${=NAVY} "ST 값 패널";                add_line 583 878 40 $W "10회 + 잔여 보류 4개" "ST 값"
add_panel 360 990 445 100 ${=NAVY} "상구 값 패널";             add_block 360 996 445 90 21 $W "1(헤소·전동 튤립·우입상구) &\n2(좌외 입상구) & 6(좌중·좌내 입상구) &\n15(하 어태커·상 어태커) / 10C" "상구 값"
add_panel 360 1092 445 106 ${=NAVY} "출옥 값 패널";            add_block 360 1102 445 92 36 $W "6,000개  4,500개\n1,800개  1,500개  300개" "출옥 값"
add_panel 945 660 232 72 ${=NAVY} "특도 1 패널";               add_line 1061 708 30 $W "특도 1 (헤소)" "특도 1"
add_panel 1445 660 268 72 ${=NAVY} "특도 2 패널";              add_line 1579 708 30 $W "특도 2 (전동 튤립)" "특도 2"
add_panel 900 915 170 100 ${=BLUE} "1500 39 패널";             add_block 900 925 170 88 36 $W "1,500개\n약 39%" "1500 39"
add_panel 1178 733 195 125 ${=NAVY} "4500 5 패널";             add_block 1178 758 195 72 22 $W "4,500개 RUSH 진입\n약 5%" "4500 5"
add_panel 1168 880 196 115 ${=NAVY} "1800 4 패널";             add_block 1168 902 196 85 24 $W "1,800개 RUSH 진입\n약 4%" "1800 4"
add_panel 1055 1010 198 135 ${=NAVY} "1500 52 패널";          add_block 1055 1046 198 90 24 $W "1,500개 RUSH 진입\n약 52%" "1500 52"
add_panel 1620 740 250 115 ${=NAVY} "6000 10 패널";            add_block 1620 750 250 100 40 $W "6,000개\n약 10%" "6000 10"
add_panel 1440 835 170 80 ${=NAVY} "ST 20 패널";               add_block 1440 842 170 72 28 $W "ST 리셋\n약 20%" "ST 20"
add_panel 1428 972 175 115 ${=NAVY} "1500 30 패널";            add_block 1428 1000 175 80 30 $W "1,500개\n약 30%" "1500 30"
add_panel 1622 968 190 120 ${=NAVY} "4500 40 패널";           add_block 1622 996 190 88 32 $W "4,500개\n약 40%" "4500 40"
add_panel 90 1250 1860 56 ${=DARK} "각주 패널"
add_block 90 1252 1860 52 16 $W "※출옥은 지급 기준 ※대당첨 출옥·시단 진입은 V 통과가 조건 ※도안 당첨 확률은 도안 당첨 연출과 권왕 각성 성공의 합산값 ※계속률 약 75%…시단 10회+잔여 보류 4개 합산\n※6,000개…1,500×4회, 4,500개…1,500×3회, 1,800개…300+1,500 ※특도 2(전동 튤립)는 전동 서포트 중 배분이며, 잔여 보류 당첨 시는 약 80%가 1,500개, 약 20%가 ST 리셋" "각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격)
for translated in flow-ko.png spec-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":789,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
