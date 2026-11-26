#!/bin/zsh
set -euo pipefail

# P 슈퍼 해이야기 IN 오키나와 6 공식 가이드북(기본 정보·게임 플로우) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 미리보기(2296px 폭) 기준으로 적고 K배(원본 2339px)로 환산한다. 원본은 72DPI라 size는 px 그대로.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/super-sea-okinawa-6"
K=1.0187

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

k() { printf '%.0f' $(( $1 * K )) }

# cap x y w h size text name → 반투명 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$(k $1) y=$(k $2) w=$(k $3) h=$(k $4) size=$(k $5) text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":10,\"fill\":[0.02,0.05,0.16,1],\"stroke\":{\"width\":2,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

# ── 번역본 1: 기본 정보 ──
cmds=()
cap 925 22 455 148 64 "기본 정보" "제목"
cap 870 255 1360 205 56 "오키해 전통의 확변 루프 스펙이\n진베에타임으로 더욱 강화!" "헤드라인"
cap 975 500 140 40 24 "대당첨 확률" "확률 라벨"
cap 1318 500 125 40 24 "확변 비율" "확변 비율 라벨"
cap 1608 500 215 40 24 "대당첨 출옥(10R)" "출옥 라벨"
cap 1995 500 100 40 28 "시단" "시단 라벨"
cap 1880 715 345 30 19 "※진베에타임 중 통상 대당첨만 200회" "시단 각주"
cap 1440 797 205 40 28 "대당첨 도안" "도안 제목"
cap 925 868 100 70 32 "짝수" "짝수"
cap 925 960 100 70 32 "홀수" "홀수"
cap 1150 1118 80 40 26 "헤소" "헤소"
cap 1555 1118 120 40 26 "전동 튤립" "전동 튤립"
cap 898 1165 50 260 30 "대\n당\n첨\n내\n역" "대당첨 내역"
cap 988 1178 180 160 24 "10R 통상\n대당첨\n40%\n출옥 1500개" "헤소 통상"
cap 1232 1178 162 160 24 "10R 확변\n대당첨\n40%\n출옥 1500개" "헤소 확변"
cap 1112 1358 155 165 24 "2R 확변\n대당첨\n20%\n출옥 60개" "헤소 2R"
cap 1418 1178 180 160 24 "10R 통상\n대당첨\n40%\n출옥 1500개" "전동 통상"
cap 1638 1178 180 160 24 "10R 확변\n대당첨\n52%\n출옥 1500개" "전동 확변"
cap 1448 1358 150 165 24 "2R 확변\n대당첨\n8%\n출옥 60개" "전동 2R"
cap 1645 1345 235 45 26 "2R 확변※으로 돌입!" "돌입 안내"
cap 1648 1392 180 70 22 "※오키해 BONUS\n(10R)도 포함" "오키해 BONUS 안내"
cap 1935 1280 205 70 24 "진베에타임 중\n통상 대당첨 후" "진베에타임 안내"
cap 1995 1348 110 42 30 "시단" "진베에타임 시단"
cap 112 1322 365 42 30 "이어폰 잭 탑재!" "이어폰 제목"
cap 108 1370 380 125 28 "이어폰·헤드폰을 연결해\n즐기면 몰입감이\n크게 향상!" "이어폰 설명"
cap 90 1538 985 32 19 "※출옥은 지급 개수  ※통상시 전동 튤립에서 2R 확변 또는 오키해 BONUS로 진베에타임에 돌입하는 경우가 있음" "하단 각주"
cap 2030 1508 190 28 17 "※자사 시험 사격치 기준" "시험 사격치 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 870 22 570 148 60 "게임 플로우" "제목"
cap 55 255 1650 125 62 "평소의 오키해에 진베에타임을 플러스!" "헤드라인"
cap 322 468 375 65 34 "확변 대당첨" "확변 대당첨"
cap 322 1012 375 65 34 "통상 대당첨" "통상 대당첨"
cap 112 895 70 160 36 "통\n상\n시" "통상시"
cap 80 750 172 36 22 "대당첨 확률" "확률 라벨"
cap 940 420 235 34 24 "확변·시단 중" "확변 시단 중"
cap 845 485 190 65 28 "2R 확변\n대당첨" "2R 확변 칩"
cap 1062 478 235 75 24 "오키해 BONUS\n(10R 확변 대당첨)" "BONUS 칩"
cap 860 575 410 55 34 "진베에타임 돌입!?" "돌입 안내"
cap 855 683 375 60 32 "2R 확변 대당첨" "2R 제목"
cap 855 1058 375 58 32 "오키해 BONUS" "BONUS 제목"
cap 1385 412 215 75 30 "신규\n탑재" "신규 탑재"
cap 1445 578 170 65 36 "확변" "확변 라벨"
cap 1445 1133 170 65 36 "시단" "시단 라벨"
cap 1880 588 280 38 26 "토털 계속 기대값" "계속 기대값"
cap 1935 768 185 28 18 "※시단 중 재당첨 포함" "재당첨 포함"
cap 1420 982 262 108 26 "진베에타임이\n끝날 때까지" "진베에타임 종료"
cap 1685 995 455 95 70 "200회 시단!" "200회 시단"
cap 1990 1155 100 40 28 "시단" "시단 200 라벨"
cap 1960 1390 200 38 22 "대당첨 기대값" "대당첨 기대값"
cap 180 1352 112 52 18 "시단 100회\n종료" "100회 종료"
cap 585 1262 80 38 26 "시단" "시단 100 라벨"
cap 708 1500 170 30 22 "시단 200회 종료" "200회 종료"
cap 92 1535 900 30 20 "※통상시 전동 튤립에서 2R 확변 대당첨 또는 오키해 BONUS로 진베에타임에 돌입하는 경우가 있음" "하단 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격: 비율 2339:1654 → 1200×849)
for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":849,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
