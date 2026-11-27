#!/bin/zsh
set -euo pipefail

# P北斗の拳 暴凶星 Sammy 공식 사이트 기본 정보(spec-pc.png, 1980×977) 한국어 번역 스크립트.
# 원본(spec-source.png)은 보존하고 spec-ko.png만 새로 만든다.
# 좌표는 원본 기준(K=1)이며 72DPI라 size는 px 그대로. 마지막에 가로 1200px로 줄인다.
# 이미지 안의 게임 화면 로고와 사진은 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/hokuto-bokyosei"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$1 y=$2 w=$3 h=$4 size=$5 text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":8,\"fill\":[0.28,0.03,0.03,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

cmds=()
cap 770 60 430 115 80 "기본 정보" "제목"
cap 585 258 830 95 66 "패도를 극한 강권 스펙" "헤드라인"
cap 725 392 195 38 28 "대당첨 확률" "라벨 확률"
cap 715 435 215 68 40 "약 1/319.7" "값 확률"
cap 1010 370 140 40 30 "초당첨" "라벨 초당첨"
cap 985 415 175 100 26 "1,500개 or\n3,000개" "값 초당첨"
cap 1200 392 200 40 30 "RUSH의 50%" "라벨 RUSH"
cap 1215 440 180 68 44 "3,000개" "값 RUSH"
cap 345 595 190 38 28 "스펙표" "표 제목"
cap 152 640 260 40 20 "대당첨 확률(좌타 시)" "표 라벨1"
cap 420 640 285 40 24 "약 1/319.7" "표 값1"
cap 152 690 260 42 17 "대당첨+소당첨 확률(우타 시)" "표 라벨2"
cap 420 690 285 42 24 "약 1/10.7" "표 값2"
cap 152 735 260 90 22 "상구/카운트" "표 라벨3"
cap 420 735 285 90 16 "1(헤소·전동 튤립·우입상구)&\n4(좌외/좌중 입상구)&\n5(좌내 입상구)&\n15(어태커)/10C" "표 값3"
cap 152 835 260 40 22 "시단 횟수" "표 라벨4"
cap 420 835 285 40 24 "10회 or 1,000회" "표 값4"
cap 152 880 260 55 22 "대당첨 출옥" "표 라벨5"
cap 420 880 285 55 18 "10R: 1,500개 2R※: 약 200개" "표 값5"
cap 560 940 150 22 13 "※2R째는 숏 개방" "표 각주"
cap 850 595 135 80 20 "3,000개 이상\n+RUSH 5%" "원 5"
cap 785 682 100 65 24 "1,500개\n40%" "원 40"
cap 920 720 100 85 20 "1,500개\n+RUSH\n55%" "원 55"
cap 1105 590 135 90 18 "약 200개\n+RUSH\n약 19.3%" "원 19.3"
cap 1135 720 105 90 18 "1,500개\n+RUSH\n약 30.6%" "원 30.6"
cap 1252 675 140 100 20 "3,000개 이상\n+RUSH\n약 50.1%" "원 50.1"
cap 755 905 300 42 28 "특도 1(헤소)" "특도1"
cap 1095 905 295 42 28 "특도 2(전동 튤립)" "특도2"
cap 725 950 1250 26 14 "※출옥은 지급 기준 ※대당첨 출옥·시단 돌입은 V 통과가 조건입니다. ※3,000개…1,500개×2회 ※1 전동 튤립 서포트 중의 배분. 잔여 보류로 당첨 시에는 1,500개입니다." "각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.png" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-ko.png" --cmd image.imageSize --params '{"width":1200,"height":592,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out "$ASSET_DIR/spec-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft image written to $ASSET_DIR"
