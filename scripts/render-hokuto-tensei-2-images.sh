#!/bin/zsh
set -euo pipefail

# 스마스로 북두의 권 전생의 장 2 サミー 공식 가이드북 이미지(특징 보충·게임 플로우, 2000×1310) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 원본 2000×1310 기준(K=1)이며 72DPI라 size는 px 그대로. 마지막에 1200×786으로 줄인다.
# 이미지 안의 게임 화면 로고(투신연무·신권승무 등 일러스트 문자)는 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-hokuto-tensei-2"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$1 y=$2 w=$3 h=$4 size=$5 text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":10,\"fill\":[0.02,0.05,0.16,1],\"stroke\":{\"width\":4,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

# ── 번역본 1: 특징 보충 ──
cmds=()
cap 820 40 360 90 52 "특징 ① 보충" "제목"
cap 75 200 700 215 64 "그 신권승무의\n게임성이 되살아난다!" "헤드라인"
cap 195 435 295 100 28 "1G당 승률" "승률 라벨"
cap 85 628 60 85 45 "약" "약 1/5"
cap 570 725 345 70 26 "승무 정렬 시 승률" "승무 정렬 라벨"
cap 500 975 70 110 45 "약" "약 50"
cap 1385 125 330 100 28 "설정6 출옥률" "출옥률 라벨"
cap 1230 495 70 90 45 "약" "약 114.9"
cap 1365 650 320 95 34 "순증" "순증 라벨"
cap 1200 930 90 90 45 "약" "약 4.0"
cap 1825 945 70 90 55 "매" "매"
cap 90 1135 1820 100 70 "파워업한 신권승무가 영혼을 뜨겁게 한다!!" "하단 문구"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 740 30 530 100 70 "게임 플로우" "제목"
cap 340 248 150 42 30 "통상시" "통상시"
cap 180 300 480 42 28 "규정 아베시·레어 역으로 AT를 노려라!!" "통상 설명"
cap 262 460 82 24 16 "카산드라" "카산드라"
cap 505 345 60 24 16 "황야" "황야"
cap 498 462 100 24 16 "남두의 거성" "남두의 거성"
cap 630 565 85 40 24 "본전조!?" "본전조"
cap 755 405 150 62 22 "규정 아베시\n도달·레어 역" "화살표 문구"
cap 340 640 160 46 32 "천파의 때" "천파의 때"
cap 255 695 330 40 26 "아베시 가산 특화 존!!" "천파 설명"
cap 590 815 130 56 22 "무한 천파도\n건재!" "무한 천파"
cap 340 925 160 46 32 "천명의 때" "천명의 때"
cap 265 985 305 40 26 "규정 아베시 도달 기대!?" "천명 설명"
cap 1300 228 215 66 44 "투신연무" "투신연무"
cap 1760 205 190 28 18 "순증 매수" "순증 매수"
cap 1760 240 190 100 40 "약 4.0매" "약 4.0매"
cap 1165 318 480 42 28 "두 개의 춤이 하늘을 능가한다!!" "AT 설명"
cap 960 342 110 28 20 "게임 수" "게임 수"
cap 1825 515 150 80 24 "신권승무\n재도전!!" "재도전"
cap 1112 622 245 30 18 "오의 승무혼 획득 후 기합을!!" "오의 라벨"
cap 1370 622 240 30 18 "권왕강습 승무혼 특화 존" "권왕강습 라벨"
cap 1625 622 240 30 18 "SP 배틀 게임성 일신!!" "SP 배틀 라벨"
cap 965 655 140 105 24 "다수의\n트리거도\n탑재!!" "트리거 문구"
cap 860 880 70 30 22 "상위" "상위 태그"
cap 1230 850 360 75 40 "이면 투신연무" "이면 투신연무"
cap 1400 930 500 80 36 "각 파트가 대폭 파워업!!" "파워업 문구"
cap 1388 1130 90 32 20 "기대 매수" "기대 매수"
cap 1842 1068 62 62 40 "매" "매"
cap 1495 1246 420 26 15 "※천격 성공~AT 종료 후 천국에서 당첨된 AT의 기대 매수 포함" "각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(원본 2000:1310 → 1200×786)
for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":786,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
