#!/bin/zsh
set -euo pipefail

# 스마스로 몽키턴V 공식 특설 사이트(www1.yamasa.co.jp/mnktrn5/)의 기본 사양·게임 플로우 이미지 한국어 번역 스크립트.
# 원본(spec-source.png, flow-source.png, 900×500)은 보존하고 spec-ko.png, flow-ko.png만 새로 만든다.
# 좌표는 원본 900×500 기준으로 적고, 글자가 선명하도록 2배(1800×1000) 작업본에 K=2배로 그린 뒤 1200×667로 줄인다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/l-monkeyturn-v"
WORK_DIR="${TMPDIR:-/tmp}/monkeyturn-v-work"
K=2

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

mkdir -p "$WORK_DIR"
for src in spec flow; do
  sips -z 1000 1800 "$ASSET_DIR/$src-source.png" --out "$WORK_DIR/$src-2x.png" >/dev/null
done

k() { printf '%.0f' $(( $1 * K )) }

# cap x y w h size text name → 반투명 패널 + 가운데 정렬 문구(\n이 있으면 여러 줄)
cap() {
  local x=$(k $1) y=$(k $2) w=$(k $3) h=$(k $4) size=$(k $5) text="$6" name="$7"
  cmds+=(--cmd shape.create --params "{\"kind\":\"roundedRect\",\"rect\":[$x,$y,$w,$h],\"radii\":6,\"fill\":[0.02,0.05,0.16,1],\"stroke\":{\"width\":2,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$name 패널\"}")
  if [[ "$text" == *'\n'* ]]; then
    local pad=$(( size / 4 ))
    cmds+=(--cmd type.create --params "{\"box\":[$(( x + pad )),$(( y + pad )),$(( w - 2 * pad )),$(( h - 2 * pad ))],\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  else
    local cx=$(( x + w / 2 )) base=$(( y + h / 2 + size * 35 / 100 ))
    cmds+=(--cmd type.create --params "{\"x\":$cx,\"y\":$base,\"text\":\"$text\",\"font\":\"NanumGothic\",\"size\":$size,\"color\":\"#ffffff\",\"align\":\"center\",\"name\":\"$name\"}")
  fi
}

# ── 번역본 1: 기본 사양 ──
cmds=()
cap 508 62 156 30 20 "레어 역 ※순압" "레어 역 제목"
cap 512 97 88 20 13 "약 체리" "약 체리"
cap 609 97 88 20 13 "강 체리" "강 체리"
cap 707 97 88 20 13 "보트" "보트"
cap 512 170 88 20 13 "약 찬스메" "약 찬스메"
cap 609 170 88 20 13 "강 찬스메" "강 찬스메"
cap 707 170 88 20 13 "궁극목" "궁극목"
cap 598 259 96 26 15 "AT 초당첨" "AT 초당첨 헤더"
cap 699 259 96 26 15 "출옥률" "출옥률 헤더"
cap 512 288 78 24 15 "설정1" "설정1"
cap 512 318 78 24 15 "설정2" "설정2"
cap 512 346 78 24 15 "설정4" "설정4"
cap 512 374 78 24 15 "설정5" "설정5"
cap 512 402 78 24 15 "설정6" "설정6"
cap 700 428 100 18 11 "※시뮬레이션 값" "시뮬레이션 각주"
cap 118 434 166 22 14 "스마스로 몽키턴 V" "기기명"

"$PHOTOCRAFT_BIN" run "$WORK_DIR/spec-2x.png" "${cmds[@]}" --out "$ASSET_DIR/spec-ko.png" --format png >/dev/null

# ── 번역본 2: 게임 플로우 ──
cmds=()
cap 50 132 58 30 15 "통상" "통상"
cap 150 132 158 31 14 "전조「우출 모드」" "우출 모드"
cap 150 240 166 22 13 "익숙한 전조 스테이지" "전조 스테이지"
cap 142 289 172 22 14 "CZ「초발 챌린지」" "초발 챌린지"
cap 150 396 160 28 14 "기대도 약 50%" "기대도 50"
cap 362 62 232 36 20 "AT「SG 러시」" "SG 러시"
cap 682 50 76 62 12 "순증\n약 2.5매" "순증 2.5"
cap 773 50 72 70 12 "1세트\n40G+α" "1세트 40G"
cap 515 116 135 22 14 "주회 모드" "주회 모드"
cap 560 152 100 22 13 "전속 모드" "전속 모드"
cap 672 152 150 22 13 "압도 배틀" "압도 배틀"
cap 372 242 170 22 11 "G수 상승·특화 존 추첨" "G수 추첨"
cap 548 242 130 22 11 "상승 특화 존" "상승 특화"
cap 682 242 146 22 11 "보수를 건 상승 배틀" "보수 배틀"
cap 418 288 108 22 14 "SG 레이스" "SG 레이스"
cap 380 404 170 22 12 "시나리오 관리형 계속 레이스" "계속 레이스"
cap 590 288 180 38 18 "AT「아오시마 SG」" "아오시마 SG"
cap 590 400 130 40 12 "아오시마가 활약하는\nSG 러시!!" "아오시마 설명"
cap 722 378 60 56 11 "순증\n약 4매" "순증 4"
cap 786 378 66 56 10 "계속 기대도\n약 83%" "계속 83"

"$PHOTOCRAFT_BIN" run "$WORK_DIR/flow-2x.png" "${cmds[@]}" --out "$ASSET_DIR/flow-ko.png" --format png >/dev/null

# 번역본 가로 1200px로 통일(원본 900:500 비율 → 1200×667)
for translated in spec-ko.png flow-ko.png; do
  "$PHOTOCRAFT_BIN" run "$ASSET_DIR/$translated" \
    --cmd image.imageSize --params '{"width":1200,"height":667,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
    --out "$ASSET_DIR/$translated" --in-place --format png >/dev/null
done

echo "Korean PhotoCraft images written to $ASSET_DIR"
