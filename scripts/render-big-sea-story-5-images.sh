#!/bin/zsh
set -euo pipefail

# P 대해이야기 5 공식 이미지 가공 스크립트.
# 원본(*-source.jpg)은 보존하고, 기기 사진·보너스 화면 크롭과 한국어 번역본을 별도 PNG로 만든다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/big-sea-story-5"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# panel x y w h name  → 반투명 번역 패널
panel() {
  print -r -- "{\"kind\":\"roundedRect\",\"rect\":[$1,$2,$3,$4],\"radii\":12,\"fill\":[0.02,0.05,0.16,1],\"stroke\":{\"width\":2,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$5\"}"
}
# line x baselineY size text name → 가운데 정렬 한 줄 문구
line() {
  print -r -- "{\"x\":$1,\"y\":$2,\"text\":\"$4\",\"font\":\"NanumGothic\",\"size\":$3,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$5\"}"
}
# block x y w h size text name → 박스 안 여러 줄 문구(\n 사용)
block() {
  print -r -- "{\"box\":[$1,$2,$3,$4],\"text\":\"$6\",\"font\":\"NanumGothic\",\"size\":$5,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$7\"}"
}

# 기기 사진: 스펙 이미지 우측 기기 영역(리사이클 안내 제외)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" \
  --cmd image.crop --params '{"x":1222,"y":225,"width":650,"height":1035,"targetWidth":650,"targetHeight":1035,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine.png" --format png >/dev/null

# 확변 카드용 화면: BIG 3000 BONUS
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/big-source.jpg" \
  --cmd image.crop --params '{"x":262,"y":590,"width":452,"height":350,"targetWidth":452,"targetHeight":350,"resample":"lanczos"}' \
  --out "$ASSET_DIR/rush-screen.png" --format png >/dev/null

# 한국어 번역본 1: 공식 스펙 표
cmds=()
add_panel() { cmds+=(--cmd shape.create --params "$(panel "$@")"); }
add_line()  { cmds+=(--cmd type.create --params "$(line "$@")"); }
add_block() { cmds+=(--cmd type.create --params "$(block "$@")"); }

add_panel 62 240 292 62 "형식명 패널";          add_line 208 282 28 "형식명" "형식명"
add_panel 62 317 292 62 "대당첨 확률 패널";     add_line 208 358 28 "대당첨 확률" "대당첨 확률"
add_panel 368 317 810 62 "대당첨 확률 값 패널"; add_line 773 360 30 "약 1/319.6 (통상시)    약 1/31.9 (확변 중)" "대당첨 확률 값"
add_panel 62 394 292 94 "상구 수 패널";         add_line 208 452 28 "상구 수" "상구 수"
add_panel 368 394 810 94 "상구 수 값 패널";     add_block 385 406 776 72 24 "3(헤소) & 2(전동 튤립) & 15(대입상구) & 5(좌상·우상 입상구) &\n1(좌하·우하 입상구) & 1(상좌·상우 입상구)" "상구 수 값"
add_panel 62 506 292 60 "카운트 패널";          add_line 208 546 26 "카운트·라운드" "카운트·라운드"
add_panel 368 506 810 60 "카운트 값 패널";      add_line 773 548 30 "10카운트 · 10라운드" "카운트 값"
add_panel 62 582 292 58 "확변 비율 패널";       add_line 208 621 28 "확변 비율" "확변 비율"
add_panel 62 658 292 60 "확변 유형 패널";       add_line 208 697 28 "확변 유형" "확변 유형"
add_panel 368 658 810 60 "확변 유형 값 패널";   add_line 773 699 30 "다음 대당첨까지" "확변 유형 값"
add_panel 62 735 292 60 "시단 패널";            add_line 208 775 28 "시단" "시단"
add_panel 62 812 292 438 "대당첨 내역 패널";    add_line 208 1010 28 "대당첨 내역" "대당첨 내역"
add_line 208 1052 21 "(헤소·전동 튤립 공통)" "헤소 전동 튤립 공통"
add_panel 383 947 190 172 "통상 대당첨 패널";   add_block 392 962 172 140 26 "10R\n통상 대당첨\n출옥 1500개" "통상 대당첨"
add_panel 972 947 190 172 "확변 대당첨 패널";   add_block 981 962 172 140 26 "10R\n확변 대당첨\n출옥 1500개" "확변 대당첨"
add_panel 62 1268 292 58 "비고 패널";           add_line 208 1307 28 "비고" "비고"
add_panel 368 1268 810 58 "비고 값 패널";       add_line 773 1305 24 "해물어 시리즈 전용 틀 「크리스탈 쉘」 오션 블루 ver." "비고 값"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# 한국어 번역본 2: 특징 요약
cmds=()
add_panel 60 292 930 74 "타이틀 패널";           add_line 525 346 50 "대해 5는 모두 BIG!" "타이틀"
add_panel 1395 255 375 80 "BIG 3000 라벨 패널";  add_line 1582 308 30 "BIG 3000 보너스" "BIG 3000 라벨"
add_panel 1425 545 350 95 "BIG 3000 설명 패널"; add_block 1432 565 336 60 22 "대해 시리즈 첫\n빅 대당첨!" "BIG 3000 설명"
add_panel 1145 598 320 95 "프리미엄 라벨 패널"; add_line 1305 660 30 "BIG 프리미엄" "프리미엄 라벨"
add_panel 1195 890 270 110 "프리미엄 설명 패널"; add_block 1205 915 250 60 22 "여러 가지가\n커진다!?" "프리미엄 설명"
add_panel 1485 665 330 80 "스펙 라벨 패널";    add_line 1650 722 30 "BIG 스펙" "스펙 라벨"
add_panel 1488 765 175 48 "확변 비율 라벨 패널"; add_line 1575 800 24 "확변 비율" "확변 비율 라벨"
add_panel 1688 765 195 48 "출옥 라벨 패널";    add_line 1785 800 24 "대당첨 출옥" "출옥 라벨"
add_panel 1500 962 385 52 "10R 패널";           add_line 1692 998 28 "대당첨은 모두 10R!" "모두 10R"
add_panel 478 1086 218 60 "확률 라벨 패널";    add_line 587 1126 24 "대당첨 확률" "대당첨 확률 라벨"
add_panel 762 1086 160 60 "시단 라벨 패널";    add_line 842 1126 24 "시단" "시단 라벨"
add_panel 990 1078 275 34 "내역 제목 패널";    add_line 1127 1103 22 "대당첨 내역" "내역 제목"
add_panel 1008 1182 108 40 "통상 라벨 패널";    add_line 1062 1210 20 "10R 통상" "10R 통상"
add_panel 1136 1182 108 40 "확변 라벨 패널";    add_line 1190 1210 20 "10R 확변" "10R 확변"
add_panel 1065 1290 215 62 "공통 패널";         add_line 1172 1328 19 "(헤소·전동 튤립 공통)" "공통"
add_panel 1308 1078 540 34 "도안 제목 패널";    add_line 1578 1103 22 "대당첨 도안" "도안 제목"
add_panel 1308 1120 78 98 "짝수 패널";          add_line 1347 1180 30 "짝수" "짝수"
add_panel 1308 1226 78 96 "홀수 패널";          add_line 1347 1284 30 "홀수" "홀수"
add_panel 1685 1120 185 98 "짝수 결과 패널";    add_block 1695 1138 165 64 24 "통상 또는\n확변" "짝수 결과"
add_panel 1685 1226 185 96 "홀수 결과 패널";    add_line 1777 1286 30 "확변" "홀수 결과"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/feature-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/feature-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격)
for translated in spec-ko.png feature-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":852,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
