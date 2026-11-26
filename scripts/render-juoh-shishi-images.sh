#!/bin/zsh
set -euo pipefail

# e 수왕 사자의 일격 공식 스펙 이미지(기본 정보) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 2000px 폭 미리보기 기준으로 적고 K배(원본 폭)로 환산한다. 원본은 72DPI라 size는 px 그대로.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/juoh-shishi"
K=1.0

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

# ── 번역본: 기본 정보 ──
cmds=()
cap 735 55 530 158 70 "기본 정보" "제목"
cap 225 312 200 45 30 "대당첨 확률" "확률 라벨"
cap 835 312 130 45 30 "돌입률" "돌입률 라벨"
cap 1380 312 395 45 30 "사바 챈스 기대 출옥" "사바 챈스 라벨"
cap 1262 390 100 62 34 "평균" "평균"
cap 1812 395 60 60 40 "개" "개"
cap 82 615 165 180 28 "대당첨\n확률" "대당첨 확률 셀"
cap 258 605 150 95 28 "통상" "통상 셀"
cap 258 708 150 92 28 "RUSH 중" "RUSH 중 셀"
cap 82 810 330 100 28 "獣王RUSH 돌입률" "돌입률 셀"
cap 82 915 330 100 28 "獣王RUSH 연속률" "연속률 셀"
cap 82 1018 330 100 28 "상구수/카운트" "상구수 셀"
cap 82 1120 330 100 28 "대당첨 출옥" "대당첨 출옥 셀"
cap 418 1020 335 95 20 "1(헤소·전동 튤립·좌외·우 입상구)\n& 6(좌중/좌내 입상구)\n& 15(어태커) / 10C" "상구수 값"
cap 1030 625 230 60 36 "통상시" "통상시 제목"
cap 1490 625 330 60 36 "RUSH 중" "RUSH 중 제목"
cap 975 890 130 140 30 "50%\n통상\n300개" "통상 파이"
cap 1170 890 150 135 30 "50%\nRUSH\n300개" "RUSH 파이"
cap 1465 828 160 102 26 "약 33%\n1,500개" "1500 파이"
cap 1630 880 285 125 28 "약 50%\n사바 챈스\n(평균 9,800개)" "사바 챈스 파이"
cap 1485 1045 170 75 26 "약 17%\n3,000개" "3000 파이"
cap 675 1262 1280 36 17 "※출옥은 지급 개수  ※대당첨 출옥·시단 돌입은 V 통과가 조건  ※3,000개…1,500개×2회  ※평균 9,800개…최저보증 4,500개 + 상승 평균 출옥 약 5,306개" "하단 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(비율 2000:1310 → 1200×786)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":786,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/spec-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
