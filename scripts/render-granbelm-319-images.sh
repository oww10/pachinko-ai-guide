#!/bin/zsh
set -euo pipefail

# e 그랑벨룸 319ver. 공식 가이드북(기본 정보·게임 플로우) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 1500px 폭 미리보기 기준으로 적고 K배(원본 폭)로 환산한다. 원본은 72DPI라 size는 px 그대로.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/granbelm-319"
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
cap 605 20 290 80 40 "기본 정보" "제목"
cap 465 148 990 102 44 "노리기 쉬운 1/319 직행 LT 타입!" "헤드라인"
cap 530 312 160 36 20 "대당첨 확률" "확률 라벨"
cap 795 312 240 36 20 "RUSH(LT) 돌입률" "돌입률 라벨"
cap 672 580 165 36 20 "RUSH 연속률" "연속률 라벨"
cap 960 580 210 36 20 "첫 대당첨 출옥" "출옥 라벨"
cap 425 822 1000 178 44 "초아드레날린 BOOST로\nBIG 출옥 & 반복되는 상승 찬스!" "BOOST 문구"
cap 38 1008 1350 34 13 "※소당첨 시 V 입상이 RUSH 돌입 조건  ※액정 표시에 따르지 않으면 본래 성능으로 유희할 수 없습니다  ※출옥은 지급 개수  ※1 저지 발생률 약 1/62, ST130회 연속률(RESTART 포함) 약 77%" "하단 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 550 20 400 80 40 "게임 플로우" "제목"
cap 65 168 90 24 12 "대당첨 확률" "확률 라벨"
cap 170 190 100 40 24 "통상시" "통상시"
cap 58 303 180 40 24 "첫 대당첨" "첫 대당첨"
cap 70 383 100 100 14 "7R 대당첨\n통상\n1050개\n49.5%" "7R 통상"
cap 170 383 100 100 14 "7R 대당첨\nRUSH(LT)\n1050개\n50.5%" "7R RUSH"
cap 72 553 180 56 16 "THE WITCH\n챌린지" "위치 챌린지"
cap 110 618 125 26 15 "배틀 고지" "배틀 고지"
cap 120 788 110 26 15 "일발 고지" "일발 고지"
cap 292 622 70 26 16 "돌입률" "돌입률"
cap 1160 172 85 26 15 "ST 횟수" "ST 횟수"
cap 1310 170 80 26 15 "연속률" "연속률"
cap 645 255 235 45 24 "RUSH 중 대당첨" "RUSH 중 대당첨"
cap 895 272 125 24 14 "[저지 성공 시]" "저지 성공"
cap 920 305 100 48 13 "4500개 이상\n12.5%" "파이 4500"
cap 862 362 80 50 13 "1500개\n50%" "파이 1500"
cap 940 383 105 52 13 "3000개 이상\n37.5%" "파이 3000"
cap 662 500 170 26 13 "프린세스의 3000 BONUS" "3000 BONUS"
cap 712 638 75 26 16 "3000개" "3000개"
cap 915 638 70 26 16 "4500개" "4500개"
cap 580 553 70 44 13 "성공률\n1/2 이상!" "성공률"
cap 520 628 100 22 13 "저지 발생률" "저지 발생률"
cap 1058 556 62 26 14 "상승률" "상승률 1"
cap 1125 300 280 85 24 "출옥 상승\n초아드레날린 BOOST" "BOOST 제목"
cap 1130 642 240 28 17 "[BOOST 상승 내역]" "상승 내역"
cap 1135 722 85 70 13 "상승\n1500개 이상\n50%" "상승 1500"
cap 1238 675 82 70 13 "상승\n4500개 이상\n25%" "상승 4500"
cap 1228 765 95 70 13 "상승\n3000개 이상\n25%" "상승 3000"
cap 1322 818 95 26 14 "재상승률" "재상승률"
cap 432 703 62 42 12 "실패 시\n약 1/3" "실패 시"
cap 665 712 175 40 24 "뒷 RUSH" "뒷 RUSH"
cap 868 722 170 24 12 "[뒷 RUSH 중 저지 성공 시]" "뒷 RUSH 저지"
cap 640 752 225 42 13 "RUSH 돌입 시·계속 시에도\n돌입 찬스!" "돌입 찬스"
cap 922 758 95 50 13 "4500개 이상\n12.5%" "뒷 4500"
cap 893 855 115 52 13 "3000개 이상\n87.5%" "뒷 3000"
cap 1058 795 62 26 14 "상승률" "상승률 2"
cap 400 900 190 42 14 "ST 회복 & 뒷 RUSH\n돌입 찬스!" "ST 회복"
cap 38 990 640 46 11 "※소당첨 시 V 입상이 RUSH 돌입 조건  ※액정 표시에 따르지 않으면 본래 성능으로 유희할 수 없습니다\n※출옥은 지급 개수  ※3000개는 1500개×2, 4500개는 1500개×3\n※1 저지 발생률 약 1/62, ST130회 연속률(RESTART 포함) 약 77%" "하단 각주"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(비율 2339:1653 → 1200×848)
for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":848,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
