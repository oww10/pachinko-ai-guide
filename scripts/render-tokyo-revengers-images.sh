#!/bin/zsh
set -euo pipefail

# e 東京リベンジャーズ Sammy 공식 사이트 가이드북 스펙(gu_08.jpg)·게임 플로우(gu_09.jpg, 각 2000×1310) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 원본 기준(K=1)이며 72DPI라 size는 px 그대로. 마지막에 1200×786으로 줄인다.
# 이미지 안의 게임 화면 로고(TOKYO卍BONUS·LT 3.0 PLUS 등)와 사진은 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/tokyo-revengers"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$1 y=$2 w=$3 h=$4 size=$5 text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":8,\"fill\":[0.30,0.03,0.03,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

# ── 번역본 1: 스펙 ──
cmds=()
cap 225 40 290 85 66 "스펙" "제목"
cap 85 212 335 118 66 "완전무결" "헤드 1"
cap 985 212 640 118 60 "으로 시장에 쳐들어간다!" "헤드 2"
cap 195 395 160 34 22 "대당첨 확률" "라벨 확률"
cap 520 395 160 34 22 "RUSH 돌입률" "라벨 돌입"
cap 880 395 160 34 22 "RUSH 계속률" "라벨 계속"
cap 1280 395 150 34 22 "대당첨 출옥" "라벨 출옥"
cap 85 450 360 165 62 "약 1/319" "값 확률"
cap 475 450 275 165 62 "약 61%" "값 돌입"
cap 545 608 145 24 15 "※시단 중 끌어당김 포함" "각주 돌입"
cap 840 450 240 165 62 "약 77%" "값 계속"
cap 1110 450 570 165 62 "최대 4,500개+α" "값 출옥"
cap 158 725 218 150 28 "대당첨\n확률" "표 대당첨"
cap 380 727 180 70 28 "통상시" "표 통상시"
cap 380 802 180 70 22 "바루하라 결전\n(RUSH 중)" "표 결전"
cap 566 727 375 70 40 "약 1/319.7" "표 값 통상"
cap 566 802 375 70 40 "약 1/99.9" "표 값 결전"
cap 158 878 218 75 30 "ST 횟수" "표 ST"
cap 380 878 562 75 40 "144회" "표 ST 값"
cap 158 955 218 75 28 "RUSH 계속률" "표 계속률"
cap 380 955 562 75 40 "약 77%" "표 계속률 값"
cap 158 1032 218 140 26 "상품구 수/\n카운트" "표 상품구"
cap 380 1032 562 140 26 "1(헤소·전동 튤립·우입상구)&\n2(좌외 입상구)&4(좌중/좌내 입상구)&\n15(상/하 어태커)/10C" "표 상품구 값"
cap 1050 718 270 45 30 "통상시" "원 통상시"
cap 1495 718 250 45 30 "RUSH 중" "원 RUSH"
cap 1210 790 235 150 28 "4%\n3,000개+α\n+ST 144회" "원 4"
cap 1055 962 145 125 22 "50%\n300개\n시단 100회" "원 50"
cap 1215 962 140 125 22 "46%\n300개\nST 144회" "원 46"
cap 1655 775 220 130 28 "2.5%\n4,500개+α" "원 2.5"
cap 1465 960 160 115 28 "50%\n1,500개" "원 50R"
cap 1660 960 180 115 28 "47.5%\n3,000개" "원 47.5"
cap 95 1262 1500 30 16 "※돌입률·계속률 모두 V 통과가 조건입니다. ※출옥은 지급 기준 ※3,000개…1,500개×2회 ※4,500개…1,500개×3회" "각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 225 50 440 85 66 "게임 플로우" "제목"
cap 195 268 105 40 28 "통상시" "통상시"
cap 140 383 210 78 56 "약 1/319" "값 통상"
cap 165 465 175 32 20 "충전 당첨 없음!" "충전 없음"
cap 680 262 110 42 30 "대당첨" "대당첨"
cap 535 338 180 30 20 "검은 충동 BONUS" "검은 충동"
cap 525 512 170 38 28 "3,000개+α" "3000+α"
cap 770 512 105 38 28 "300개" "300A"
cap 600 552 270 38 28 "바루하라 결전 직격!?" "결전 직격"
cap 512 618 190 30 20 "리벤저스 BONUS" "리벤저스"
cap 625 760 95 38 26 "300개" "300B"
cap 545 797 405 40 28 "연출 성공 시 바루하라 결전으로!?" "연출 성공"
cap 1040 288 135 28 18 "합산 돌입률" "합산 돌입률"
cap 1005 340 180 85 56 "약 61%" "합산 61"
cap 1405 250 290 58 40 "바루하라 결전" "바루하라 결전"
cap 468 920 100 90 20 "시단\n100회전" "시단"
cap 660 940 125 38 28 "결전 전야" "결전 전야"
cap 820 960 120 30 18 "끌어당김률" "끌어당김률"
cap 775 995 170 62 38 "약 22.2%" "22.2"
cap 820 1082 115 28 18 "대당첨 확률" "대당첨 확률"
cap 770 1118 180 62 38 "약 1/399" "1/399"
cap 1700 375 200 120 24 "2.5%\n4,500개\n+α" "2.5"
cap 1510 520 175 100 28 "50%\n1,500개" "50"
cap 1695 520 190 100 28 "47.5%\n3,000개" "47.5"
cap 1155 935 625 120 52 "ST 144회전 약 77% 계속" "ST 144"
cap 1165 1068 790 170 54 "대당첨의 50%로\n3,000개 이상" "50% 3000"
cap 95 1262 1260 30 15 "※1 RUSH 돌입률 50%와 시단 중 끌어당김 확률 약 22.2%의 합산 ※돌입률·계속률 모두 V 통과가 조건입니다. ※출옥은 지급 기준 ※3,000개…1,500개×2회 ※4,500개…1,500개×3회" "각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":786,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
