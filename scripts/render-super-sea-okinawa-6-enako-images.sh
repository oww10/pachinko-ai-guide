#!/bin/zsh
set -euo pipefail

# PA 슈퍼 해이야기 IN 오키나와 6 With 에나코 공식 가이드북(기본 정보·게임 플로우) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 1500px 폭 미리보기 기준으로 적고 K배(원본 2339px)로 환산한다. 원본은 72DPI라 size는 px 그대로.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/super-sea-okinawa-6-enako"
K=1.5593

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
cap 585 15 340 95 44 "기본 정보" "제목"
cap 600 160 820 125 30 "정통 해유 파치 × 진베에타임\n안심감과 기대감을 겸비한 새로운 오키나와 아마데지 스펙!" "헤드라인"
cap 668 335 110 26 17 "대당첨 확률" "확률 라벨"
cap 870 335 90 26 17 "ST 돌입률" "ST 돌입 라벨"
cap 1052 335 125 26 17 "전동 튤립 서포트" "서포트 라벨"
cap 1262 328 115 40 15 "진베에타임\n계속 기대값" "기대값 라벨"
cap 1240 450 150 36 13 "※ST5회 + 시단 115회\n(잔여 보류 4개 포함)" "기대값 각주"
cap 760 522 170 30 20 "대당첨 도안" "도안 제목"
cap 1058 522 170 30 20 "대당첨 라운드" "라운드 제목"
cap 1250 522 170 30 18 "BIG 에나코 도안" "BIG 에나코"
cap 603 563 70 50 24 "짝수" "짝수"
cap 603 623 70 50 24 "홀수" "홀수"
cap 940 698 130 32 22 "대당첨 내역" "내역 제목"
cap 700 742 210 30 20 "헤소 입상 시" "헤소 제목"
cap 1160 742 160 30 20 "전동 튤립 입상 시" "전동 튤립 제목"
cap 608 788 108 80 13 "4R 대당첨\n출옥 400개\n전동 튤립\n서포트 25회" "헤소 4R 25"
cap 608 903 108 80 13 "4R 대당첨\n출옥 400개\n전동 튤립\n서포트 50회" "헤소 4R 50"
cap 898 788 102 76 13 "10R 대당첨\n출옥 1000개\n전동 튤립\n서포트 120회" "헤소 10R"
cap 898 903 102 76 13 "6R 대당첨\n출옥 600개\n전동 튤립\n서포트 50회" "헤소 6R"
cap 1023 788 110 92 13 "4R 대당첨\n출옥 400개\n전동 튤립 서포트\n25·50·120회" "전동 4R 30"
cap 1023 903 110 80 13 "4R 대당첨\n출옥 400개\n전동 튤립 서포트\n50·120회" "전동 4R 6"
cap 1310 788 108 76 13 "10R 대당첨\n출옥 1000개\n전동 튤립\n서포트 120회" "전동 10R"
cap 1310 903 108 80 13 "6R 대당첨\n출옥 600개\n전동 튤립\n서포트 50·120회" "전동 6R"
cap 62 933 285 32 22 "이어폰 잭 탑재!" "이어폰 제목"
cap 62 967 285 52 16 "이어폰·헤드폰을 연결해 즐기면\n몰입감이 크게 향상!" "이어폰 설명"
cap 520 1003 925 20 12 "※출옥은 지급 개수  ※서포트 25회=ST5+시단20, 50회=ST5+시단45, 120회=ST5+시단115  ※대당첨 계속 중 서포트 회수 강등 없음" "하단 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 550 15 420 95 44 "게임 플로우" "제목"
cap 70 490 65 160 30 "통\n상\n시" "통상시"
cap 285 203 160 55 34 "대당첨" "대당첨 제목"
cap 258 282 222 50 17 "에나코가 너무 귀여워서\n미안 BONUS" "BONUS 제목"
cap 288 470 158 40 22 "출옥 1000개" "1000개"
cap 312 535 150 28 16 "홀수 도안 대당첨" "홀수 도안"
cap 265 712 140 36 22 "출옥 600개" "600개"
cap 410 704 56 38 12 "서포트\n50회" "서포트 50"
cap 312 758 150 28 16 "짝수 도안 대당첨" "짝수 도안"
cap 265 935 140 36 22 "출옥 400개" "400개"
cap 395 922 78 42 12 "서포트\n25·50회" "서포트 25 50"
cap 655 290 265 105 24 "10R 대당첨 후\n진베에타임으로!" "진베에타임 안내"
cap 640 452 250 52 34 "ST·시단" "ST 시단 제목"
cap 642 762 108 26 13 "전동 튤립 서포트" "서포트 25 라벨"
cap 775 762 112 26 13 "전동 튤립 서포트" "서포트 50 라벨"
cap 655 866 215 32 17 "오키나와 아마데지 한정 “신 시단”" "신 시단 제목"
cap 640 905 245 62 14 "한 번 서포트 50회가 되면 이후 서포트가\n끝날 때까지 짝수 도안 대당첨에서도\n서포트 50회로!" "신 시단 설명"
cap 1042 652 135 30 15 "전동 튤립 서포트" "서포트 120 라벨"
cap 1262 652 125 30 15 "계속 기대값" "계속 기대값"
cap 1240 735 150 32 11 "※ST5회 + 시단 115회\n(잔여 보류 4개 포함)" "기대값 각주"
cap 958 822 330 44 26 "진베에타임이 끝날 때까지" "진베에타임 종료"
cap 958 858 515 138 34 "모든 대당첨 후\n전동 튤립 서포트 120회!" "서포트 120회"
cap 58 1003 1020 20 12 "※출옥은 지급 개수  ※서포트 25회=ST5+시단20, 50회=ST5+시단45, 120회=ST5+시단115  ※서포트 중(25·50·120회) 대당첨 후 서포트 회수 강등 없음" "하단 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(디자인 문서 규격: 비율 2339:1654 → 1200×849)
for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":849,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
