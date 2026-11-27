#!/bin/zsh
set -euo pipefail

# スマスロ マギアレコード ユニバーサル 공식 디지털 가이드 게임 플로우(magireco_01.jpg, 1754×1258) 한국어 번역 스크립트.
# 원본(flow-source.jpg)은 보존하고 flow-ko.png만 새로 만든다.
# 좌표는 원본 기준(K=1)이며 72DPI라 size는 px 그대로. 마지막에 1200×861로 줄인다.
# 이미지 안의 게임 화면 로고(마기아 어택·마기아 챌린지 등 일러스트 문자)와 가이드 쪽수 표기(P4 등)는 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-magireco"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$1 y=$2 w=$3 h=$4 size=$5 text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":8,\"fill\":[0.30,0.05,0.30,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

cmds=()
cap 690 100 370 75 54 "게임 플로우" "제목"
cap 335 197 440 40 30 "통상 스테이지 <전 4종>" "통상 스테이지"
cap 95 342 165 30 22 "고슈 버거" "고슈 버거"
cap 292 342 120 30 22 "미즈나 신사" "미즈나 신사"
cap 455 342 110 30 22 "과자 가게" "과자 가게"
cap 640 342 130 30 22 "미카즈키 장" "미카즈키 장"
cap 815 330 45 70 18 "AT\n직격" "AT 직격"
cap 238 395 235 32 20 "규정 포인트 도달·레어 역" "규정 포인트"
cap 668 397 70 30 20 "성립" "성립"
cap 150 463 85 36 28 "전조" "전조"
cap 140 626 105 30 22 "조정소" "조정소"
cap 462 462 235 36 28 "찬스 존" "찬스 존"
cap 385 616 175 30 20 "마기아 챌린지" "마기아 챌린지"
cap 610 616 150 30 20 "쿠로에 챌린지" "쿠로에 챌린지"
cap 768 512 75 55 16 "보너스\n농후!?" "보너스 농후"
cap 370 715 145 40 30 "보너스" "보너스"
cap 440 755 68 58 14 "내비\n8회" "벨 내비"
cap 192 922 150 32 22 "빅 보너스" "빅 보너스"
cap 540 922 150 32 22 "미타마 보너스" "미타마 보너스"
cap 100 958 70 50 15 "50G\n고정" "50G 고정"
cap 372 958 62 50 16 "AT\n농후!?" "AT 농후1"
cap 440 950 70 70 13 "30G간\n매G\n상승" "30G 상승"
cap 728 958 62 50 16 "AT\n농후!?" "AT 농후2"
cap 170 1124 195 32 22 "에피소드 보너스" "에피소드 보너스"
cap 515 1124 200 32 22 "아리나 뮤지엄" "아리나 뮤지엄"
cap 1030 200 565 40 28 "마기아 러시 <게임 수 관리형 AT>" "마기아 러시"
cap 1045 252 480 38 26 "마기아 어택으로 초기 G수 결정" "마기아 어택 설명"
cap 995 535 195 34 24 "마기우스 배틀" "마기우스 배틀"
cap 1385 535 165 34 24 "우이 찬스" "우이 찬스"
cap 1262 585 42 60 16 "승\n리" "승리"
cap 1010 766 170 30 20 "배틀은 4종류" "배틀 4종류"
cap 1330 760 195 32 20 "보수는 3종류" "보수 3종류"
cap 990 858 580 48 32 "스토리 컴플리트 or 규정 매수 획득" "스토리 컴플리트"
cap 900 975 450 175 56 "엔브리오·이브\n각성" "엔브리오 이브"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-ko.png" --cmd image.imageSize --params '{"width":1200,"height":861,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out "$ASSET_DIR/flow-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft image written to $ASSET_DIR"
