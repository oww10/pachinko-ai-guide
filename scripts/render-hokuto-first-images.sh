#!/bin/zsh
set -euo pipefail

# スマスロ北斗の拳(초대) サミー 공식 사이트 기본 정보(spec-pc.png, 2000×987)·BATTLE BONUS 특징(feature-pc_04.png, 2000×887)
# 한국어 번역 스크립트. 원본(spec-source.png, feature-source.png)은 보존하고 spec-ko.png, feature-ko.png만 새로 만든다.
# 좌표는 원본 기준(K=1)이며 72DPI라 size는 px 그대로. 마지막에 가로 1200px로 줄인다.
# 이미지 안의 게임 화면 로고·일러스트 문자는 번역하지 않는다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-hokuto-first"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# cap x y w h size text name → 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$1 y=$2 w=$3 h=$4 size=$5 text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":8,\"fill\":[0.02,0.05,0.16,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
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
cap 800 55 400 140 90 "기본 정보" "제목"
cap 850 248 200 50 34 "릴 배열" "릴 배열"
cap 1180 255 180 42 30 "베이스" "베이스 라벨"
cap 1130 300 270 62 40 "약 34.7G/50매" "베이스 값"
cap 1520 255 130 42 30 "타입" "타입 라벨"
cap 1290 415 180 40 30 "AT 확률" "AT 확률 제목"
cap 1200 460 76 26 20 "설정1" "설정1"
cap 1290 460 76 26 20 "설정2" "설정2"
cap 1378 460 76 26 20 "설정4" "설정4"
cap 1462 460 76 26 20 "설정5" "설정5"
cap 1548 460 76 26 20 "설정6" "설정6"
cap 1128 488 70 28 16 "AT 합산" "AT 합산"
cap 1128 523 70 28 14 "북두 확률" "북두 확률"
cap 1385 552 255 22 12 "※설정 L은 하단 패널이 상시 명멸합니다." "설정 L 각주"
cap 1290 622 180 40 30 "역 구성" "역 구성 제목"
cap 1440 670 190 36 26 "배틀 보너스" "배틀 보너스1"
cap 1440 718 190 36 26 "배틀 보너스" "배틀 보너스2"
cap 1485 762 140 34 24 "스이카(6매)" "스이카"
cap 1470 808 160 34 24 "체리(2매)" "체리"
cap 1500 855 125 34 24 "벨(11매)" "벨"
cap 1520 900 110 34 24 "리플레이" "리플레이"
cap 1460 940 190 22 12 "※겉보기상 역 구성의 일부입니다." "역 구성 각주"
cap 352 800 310 62 15 "크기 810×475×425.4/436.8mm\n소비 전력 60W/대 · 전압 100V" "사양 문구"
cap 683 802 112 22 14 "유효 라인" "유효 라인"
cap 452 895 140 32 20 "에코 기능 탑재" "에코 제목"
cap 460 928 205 40 13 "소비 전력을 줄인 에코 기능 탑재\n절전 음량 설정도 가능" "에코 설명"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-source.png" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: BATTLE BONUS 특징 ──
cmds=()
cap 390 20 1210 100 64 "초대를 계승한 안심감과 새로운 자력감" "상단 문구"
cap 405 295 510 70 46 "초대를 계승한 안심감" "안심감 제목"
cap 1060 295 530 70 46 "성능을 끌어올리는 자력감" "자력감 제목"
cap 370 370 580 58 36 "계속률: 66%·79%·84%·89%" "계속률"
cap 770 418 175 18 12 "※V스톡 제외 계속률" "계속률 각주"
cap 370 445 580 58 36 "1세트: 약 110매" "1세트"
cap 1040 372 580 58 36 "레이 공투 & 토키 공투 추첨" "공투 추첨"
cap 1040 445 580 58 36 "기초 계속률 상승 추첨" "계속률 상승 추첨"
cap 520 745 950 140 56 "어느 한쪽이 패배할 때까지 계속되는\n배틀 보너스가 스마스로로 부활!" "하단 문구"
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/feature-source.png" "${cmds[@]}" --out "$ASSET_DIR/feature-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(원본 2000:987 → 1200×592, 2000:887 → 1200×532)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/spec-ko.png" --cmd image.imageSize --params '{"width":1200,"height":592,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out "$ASSET_DIR/spec-ko.png" --in-place --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/feature-ko.png" --cmd image.imageSize --params '{"width":1200,"height":532,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out "$ASSET_DIR/feature-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
