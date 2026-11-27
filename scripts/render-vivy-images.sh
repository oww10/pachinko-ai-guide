#!/bin/zsh
set -euo pipefail

# 스마스로 Vivy -Fluorite Eye's Song- 大都技研 공식 사이트 기본 정보(info9_basic.jpg, 2800×1800)·게임 플로우(info1_gameflow.jpg, 2800×1881)
# 한국어 번역 스크립트. 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 미리보기(기본 정보 2396폭, 게임 플로우 2334폭) 기준이며 K배(1.1686, 1.2)로 원본 2800폭에 환산한다. 72DPI라 size는 px 그대로.
# 마지막에 가로 1200px로 줄인다. 이미지 안의 게임 화면 로고·일러스트 문자는 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-vivy"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

k() { printf '%.0f' $(( $1 * K )) }

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$(k $1) y=$(k $2) w=$(k $3) h=$(k $4) size=$(k $5) text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":10,\"fill\":[0.02,0.12,0.35,1],\"stroke\":{\"width\":4,\"color\":\"#8fe3ff\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

# ── 번역본 1: 기본 정보 ──
K=1.1686
cmds=()
cap 930 35 540 135 100 "기본 정보" "제목"
cap 455 252 170 55 40 "배당표" "배당표"
cap 660 574 70 36 26 "1매" "1매A"
cap 660 664 70 36 26 "1매" "1매B"
cap 625 750 130 36 24 "1매 or 13매" "1매 or 13매"
cap 640 840 100 36 24 "리플레이" "리플레이"
cap 405 908 260 26 16 "※겉보기상 배당의 일부입니다" "배당 각주"
cap 1000 250 250 55 40 "릴 배열" "릴 배열"
cap 435 995 190 55 42 "스펙" "스펙"
cap 318 1103 95 40 26 "설정" "헤더 설정"
cap 428 1103 160 40 24 "초당첨 확률" "헤더 확률"
cap 610 1103 130 40 26 "출옥률" "헤더 출옥률"
cap 320 1156 90 34 24 "설정1" "설정1"
cap 320 1200 90 34 24 "설정2" "설정2"
cap 320 1244 90 34 24 "설정3" "설정3"
cap 320 1288 90 34 24 "설정4" "설정4"
cap 320 1332 90 34 24 "설정5" "설정5"
cap 320 1376 90 34 24 "설정6" "설정6"
cap 610 1428 165 26 17 "※시뮬레이션 값" "시뮬레이션 각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
K=1.2
cmds=()
cap 800 45 730 135 100 "게임 플로우" "제목"
cap 1925 145 345 55 17 "통상 시는 왼쪽부터 누르세요.\n누르는 순서 내비가 나오면 내비를 따르세요." "주의 문구"
cap 205 225 160 48 34 "통상시" "통상시"
cap 175 450 255 75 26 "규정 포인트 도달로\nAT 당첨 찬스!" "규정 포인트"
cap 170 550 280 48 32 "아카이브 모드" "아카이브 모드"
cap 195 750 215 38 24 "AT 전조 스테이지" "AT 전조"
cap 160 852 290 48 32 "액세스 찬스" "액세스 찬스"
cap 165 1048 275 115 24 "포인트 특화 존!\n세트 계속을 거듭하면\nCZ로!?" "포인트 특화 존"
cap 150 1180 300 80 28 "액세스 찬스\nEX(CZ)" "액세스 찬스 EX"
cap 760 225 660 55 38 "프로젝트 싱귤래리티(AT)" "AT 제목"
cap 990 318 740 135 46 "레어 역·리플레이 카운터로\n싱귤래리티 배틀을 노려라!" "AT 헤드라인"
cap 1750 340 190 100 28 "차매수\n관리형 AT" "차매수 관리형"
cap 2040 312 90 38 26 "순증" "순증"
cap 1955 362 250 80 52 "약 3.2매" "순증 값"
cap 700 492 510 52 34 "싱귤래리티 배틀(AT CZ)" "배틀 제목"
cap 680 558 480 42 28 "승리하면 상승 특화 존 찬스!" "배틀 설명"
cap 1180 562 170 32 20 "AT 중 배틀 확률" "배틀 확률 라벨"
cap 1180 590 170 55 40 "약 1/33" "배틀 확률 값"
cap 960 658 400 85 26 "레어 역으로 승리!?\n대응 역이면 특화 존 농후!?" "레어 승리"
cap 1125 770 200 110 24 "배틀 중\n레어 역 재생으로\n승리는 눈앞!?" "배틀 재생"
cap 1400 640 95 150 36 "배틀\n승리" "배틀 승리"
cap 1540 495 480 50 34 "싱귤래리티 찬스" "찬스 제목"
cap 1540 567 320 38 26 "3종류 보수 중에서 결정!" "보수 3종류"
cap 2050 640 150 85 30 "차매수\n상승" "차매수 상승"
cap 2030 790 160 85 30 "상승\n특화 존" "상승 특화 존"
cap 695 955 190 48 34 "보너스" "보너스"
cap 1262 1035 170 78 28 "에피소드\n보너스" "에피소드 보너스"
cap 795 1110 320 38 24 "레어 역으로 차매수 상승!" "레어 차매수"
cap 1880 1035 305 85 28 "종료 후는\n상승 특화 존으로!?" "종료 후"
cap 700 1192 500 70 32 "플로라이트 아이즈 스트라이크" "플로라이트 제목"
cap 1170 1285 600 85 26 "레어 역 보류 획득 특화 존!\n레어 역 보류를 여러 개 얻으면 AT 성능이 부스트!!" "플로라이트 설명"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(원본 2800:1800 → 1200×771, 2800:1881 → 1200×806)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-ko.png" --cmd image.imageSize --params '{"width":1200,"height":771,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out "$ASSET_DIR/spec-ko.png" --in-place --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-ko.png" --cmd image.imageSize --params '{"width":1200,"height":806,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out "$ASSET_DIR/flow-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
