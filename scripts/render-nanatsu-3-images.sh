#!/bin/zsh
set -euo pipefail

# e 七つの大罪3 Sammy 공식 사이트 기본 정보(spec_1.jpg, 2000×1310)·가이드북 게임 플로우(gu_06.jpg, 2000×1310) 한국어 번역 스크립트.
# 원본(spec-source.jpg, flow-source.jpg)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 원본 기준(K=1)이며 72DPI라 size는 px 그대로. 마지막에 1200×786으로 줄인다.
# 공식 기본 정보 이미지의 '大当り出玉' 행은 3,100개로 되어 있으나 같은 이미지의 PERFECT BONUS 표·각주 계산식은 3,900개라 3,900개로 표기한다.
# 이미지 안의 게임 화면 로고(Sins BONUS·SEVEN RUSH 등)는 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/nanatsu-3"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$1 y=$2 w=$3 h=$4 size=$5 text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":8,\"fill\":[0.16,0.02,0.20,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
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
cap 510 20 410 100 76 "기본 정보" "제목"
cap 85 155 830 62 44 "초당첨 시에는 반드시 시단 100회의 안정감!" "초당첨 문구"
cap 355 440 930 76 52 "RUSH 중에는 최대 7,500개의 ‘강욕’!" "RUSH 문구"
cap 130 550 300 72 46 "대당첨 확률" "대당첨 확률 라벨"
cap 100 622 355 138 90 "약 1/319" "대당첨 확률 값"
cap 475 552 345 70 46 "RUSH 계속률" "계속률 라벨"
cap 510 622 275 138 90 "약 75%" "계속률 값"
cap 875 535 345 80 34 "PERFECT BONUS\n평균 획득 출옥" "퍼펙트 라벨"
cap 825 622 440 138 90 "약 3,400개" "퍼펙트 값"
cap 118 820 138 150 30 "대당첨\n확률" "표 대당첨"
cap 258 822 205 48 28 "통상시" "표 통상시"
cap 258 872 205 48 20 "SEVEN RUSH 챌린지 중" "표 챌린지"
cap 258 925 205 48 26 "SEVEN RUSH 중" "표 RUSH 중"
cap 468 825 518 46 34 "약 1/319.7" "값 통상"
cap 468 875 518 46 34 "약 1/196.2" "값 챌린지"
cap 468 927 518 46 34 "약 1/1" "값 RUSH"
cap 118 977 345 50 28 "SEVEN RUSH 돌입률" "돌입률 라벨"
cap 468 977 518 50 34 "약 40%" "돌입률 값"
cap 118 1029 345 50 28 "SEVEN RUSH 계속률" "계속률2 라벨"
cap 468 1029 518 50 34 "약 75%" "계속률2 값"
cap 118 1080 345 75 28 "상품구 수/카운트" "상품구 라벨"
cap 468 1080 518 75 21 "1(헤소·전동 튤립·좌외 입상구·작동구)&\n6(좌중/좌내 입상구)&15(상/하 어태커)/10C" "상품구 값"
cap 118 1160 345 75 28 "대당첨 출옥" "출옥 라벨"
cap 468 1160 518 75 30 "7,500개 6,300개 5,100개 3,900개\n2,700개 1,500개 450개" "출옥 값"
cap 1018 822 280 45 30 "통상시" "통상시 필"
cap 1325 822 565 45 30 "SEVEN RUSH 중" "RUSH 필"
cap 1040 985 245 90 26 "450개+시단 100회\n100%" "초당첨 원"
cap 1330 898 150 118 16 "챌린지 BONUS\n1,500개\n(RUSH 종료)\n약 25%" "원 25"
cap 1478 925 135 100 20 "PERFECT\nBONUS\n약 72.8%" "원 72.8"
cap 1395 1048 170 100 17 "챌린지 BONUS\n1,500개\n(RUSH 계속)\n약 2.2%" "원 2.2"
cap 1632 905 245 62 22 "PERFECT BONUS\n획득 출옥" "표 제목"
cap 1648 974 125 34 24 "7,500개" "표 7500"
cap 1648 1012 125 34 24 "6,300개" "표 6300"
cap 1648 1050 125 34 24 "5,100개" "표 5100"
cap 1648 1088 125 34 24 "3,900개" "표 3900"
cap 1648 1126 125 34 24 "2,700개" "표 2700"
cap 1790 974 85 32 20 "약 0.1%" "비율 0.1"
cap 1790 1012 85 32 20 "약 1.5%" "비율 1.5"
cap 1790 1050 85 32 20 "약 9.8%" "비율 9.8"
cap 1790 1088 85 32 20 "약 33.1%" "비율 33.1"
cap 1790 1126 85 32 20 "약 55.5%" "비율 55.5"
cap 1010 1185 885 60 44 "PERFECT BONUS는 1회로 최대 7,500개" "하단 문구"
cap 75 1268 1730 38 14 "※출옥은 지급 기준 ※대당첨 출옥·시단 돌입은 V 통과가 조건입니다 ※RUSH 평균 획득 출옥 약 3,400개는 챌린지 BONUS 실패 시 획득 출옥을 제외\n※7,500개…1,500×5회, 6,300개…1,500×4회+300×1회, 5,100개…1,500×3회+300×2회, 3,900개…1,500×2회+300×3회, 2,700개…1,500×1회+300×4회" "각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 515 40 450 85 66 "게임 플로우" "제목"
cap 118 585 70 185 38 "통\n상\n시" "통상시"
cap 235 340 190 48 32 "약 1/319.6" "확률 화살표"
cap 580 528 165 42 30 "3R: 450개" "3R"
cap 585 622 155 45 28 "반드시 돌입!?" "반드시 돌입"
cap 590 782 150 40 30 "챌린지" "챌린지"
cap 830 718 195 75 24 "시단 100회\n돌파율 약 40%" "시단 돌파율"
cap 475 1125 385 45 28 "2종류의 고지 모드를 선택 가능!" "고지 모드"
cap 940 850 85 42 28 "돌파" "돌파"
cap 1700 540 190 110 36 "계속률\n약 75%" "계속률"
cap 1225 662 335 52 34 "대당첨 확률 약 1/1" "RUSH 확률"
cap 1140 728 235 105 28 "4개의 모드를\n자유롭게 선택!!" "모드 선택"
cap 1708 742 120 32 20 "오만 BATTLE" "오만 BATTLE"
cap 1482 952 150 32 20 "대죄 VACATION" "대죄 VACATION"
cap 1230 1160 645 62 48 "연출 성공 시 2,700~7,500개!?" "연출 성공"
cap 235 1210 880 40 24 "실패 후에는 1,500개를 획득하고 통상시로(1,500개 → RUSH 계속도 있음)" "실패 후"
cap 75 1268 1650 40 14 "※출옥은 지급 기준 ※대당첨 출옥·시단 돌입은 V 통과가 조건입니다 ※RUSH 평균 획득 출옥 약 3,400개는 챌린지 BONUS 실패 시 획득 출옥을 제외\n※7,500개…1,500×5회, 6,300개…1,500×4회+300×1회, 5,100개…1,500×3회+300×2회, 3,900개…1,500×2회+300×3회, 2,700개…1,500×1회+300×4회" "각주"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/flow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(원본 2000:1310 → 1200×786)
for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":786,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
