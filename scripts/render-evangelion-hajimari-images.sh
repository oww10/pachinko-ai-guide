#!/bin/zsh
set -euo pipefail

# e 신세기 에반게리온 ~はじまりの記憶~ 공식 이미지 가공 스크립트.
# 원본(*_pc.*)은 보존하고, RUSH 화면 크롭과 한국어 번역본(flow-ko, spec-ko, chart1-ko, chart2-ko)을 만든다.
#
# 원본 출처(eva-project.jp 공식, https://www.eva-project.jp/hajimarinokioku/img/):
#   img-kv_pc.jpg                  : 대표 이미지(가공 없이 사용)
#   img-flow2_pc.png               : 게임 플로우
#   img-spec1~6_pc.png             : 스펙 패널 6장(spec-ko.png 한 장으로 합성)
#   img-specgraph1/2_pc.png        : 특도 1/2 배분 원그래프
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/evangelion-hajimari"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

cd "$ASSET_DIR"

panel() {
  print -r -- "{\"kind\":\"roundedRect\",\"rect\":[$1,$2,$3,$4],\"radii\":10,\"fill\":[$5,$6,$7,1],\"stroke\":{\"width\":2,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$8\"}"
}
line() {
  print -r -- "{\"x\":$1,\"y\":$2,\"text\":\"$5\",\"font\":\"NanumGothic\",\"size\":$3,\"color\":\"$4\",\"align\":\"center\",\"name\":\"$6\"}"
}
block() {
  print -r -- "{\"box\":[$1,$2,$3,$4],\"text\":\"$7\",\"font\":\"NanumGothic\",\"size\":$5,\"color\":\"$6\",\"align\":\"center\",\"name\":\"$8\"}"
}
add_panel() { cmds+=(--cmd shape.create --params "$(panel "$@")"); }
add_line()  { cmds+=(--cmd type.create --params "$(line "$@")"); }
add_block() { cmds+=(--cmd type.create --params "$(block "$@")"); }

W="#ffffff"
Y="#ffd84a"
NAVY="0.05 0.05 0.12"
RED="0.55 0.03 0.03"

# RUSH 카드용 화면: IMPACT 모드
"$PHOTOCRAFT_BIN" run img-flow2_pc.png \
  --cmd image.crop --params '{"x":503,"y":1340,"width":330,"height":262,"targetWidth":330,"targetHeight":262,"resample":"lanczos"}' \
  --out rush-screen.png --format png >/dev/null

# 한국어 번역본 1: 게임 플로우(원본 1275×1708)
cmds=()
add_panel 455 2 355 50 ${=NAVY} "통상시 패널";                add_line 632 40 34 $W "통상시" "통상시"
add_panel 100 246 255 34 ${=NAVY} "외관 패널";                add_line 227 271 20 $W "제3신도쿄시 외관" "외관"
add_panel 355 246 285 34 ${=NAVY} "작전사령실 패널";          add_line 497 271 19 $W "NERV 본부 중앙작전사령실" "작전사령실"
add_panel 660 246 225 34 ${=NAVY} "실험실 패널";              add_line 772 271 20 $W "NERV 본부 실험실" "실험실"
add_panel 160 488 125 32 ${=NAVY} "아사마산 패널";            add_line 222 512 20 $W "아사마산" "아사마산"
add_panel 365 488 265 32 ${=NAVY} "요격태세 패널";            add_line 497 512 20 $W "제3신도쿄시 요격태세" "요격태세"
add_panel 655 488 235 32 ${=NAVY} "시가지 패널";              add_line 772 512 20 $W "제3신도쿄시 시가지" "시가지"
add_panel 922 232 240 86 ${=RED} "폭주 연출 패널";            add_block 922 238 240 76 24 $W "폭주 연출이\n발생하면…!?" "폭주 연출"
add_panel 160 585 75 38 ${=NAVY} "짝수 패널";                 add_line 197 614 26 $W "짝수" "짝수"
add_panel 475 585 75 38 ${=NAVY} "홀수 패널";                 add_line 512 614 26 $W "홀수" "홀수"
add_panel 735 585 125 38 ${=NAVY} "135 패널";                 add_line 797 614 26 $W "135 정렬" "135 정렬"
add_panel 995 578 130 62 ${=NAVY} "전회전 패널";              add_block 995 580 130 58 22 $W "전회전\n(금 7 정렬)" "전회전"
add_panel 272 762 105 32 ${=NAVY} "승격 패널";                add_line 324 786 20 $W "승격 기대!" "승격 기대"
add_panel 732 846 180 42 ${=NAVY} "폭주 주석 패널"
add_block 732 848 180 40 11 $W "※폭주 BONUS에서 ST 돌입 시\n폭주 모드가 기본 선택" "폭주 주석"
add_panel 125 1006 250 36 ${=NAVY} "찬스타임 패널";           add_line 250 1034 24 $W "찬스타임" "찬스타임"
add_panel 170 1222 160 42 ${=NAVY} "시단 패널";               add_line 250 1255 26 $W "시단 100회" "시단"
add_panel 185 1385 190 70 ${=NAVY} "LT 돌입 패널";            add_block 185 1388 190 66 20 $W "대당첨되면\n반드시 LT 돌입!?" "LT 돌입"
add_panel 530 1132 100 50 ${=NAVY} "157 패널";                add_line 580 1171 36 $W "157회" "157"
add_panel 662 1068 238 150 ${=NAVY} "ALL 2400 패널";          add_block 662 1092 238 120 40 $Y "ALL 2400개\n+α" "ALL 2400"
add_panel 912 1068 240 142 ${=NAVY} "계속률 패널";            add_block 912 1076 240 130 42 $Y "계속률\n약 80%" "계속률"
add_panel 565 1224 545 50 ${=NAVY} "2가지 모드 패널";         add_line 837 1260 30 $W "ST는 선택 가능한 2가지 모드 탑재" "2가지 모드"
add_panel 508 1284 322 44 ${=NAVY} "IMPACT 모드 패널";        add_line 669 1318 28 $W "IMPACT 모드" "IMPACT 모드"
add_panel 845 1284 322 44 ${=NAVY} "폭주 모드 패널";          add_line 1006 1318 28 $W "폭주 모드" "폭주 모드"

"$PHOTOCRAFT_BIN" run img-flow2_pc.png "${cmds[@]}" --out flow-ko.png --format png >/dev/null

# 한국어 번역본 2: 특도 1 배분 원그래프(원본 600×698)
cmds=()
add_panel 170 4 260 80 ${=NAVY} "제목1 패널";                add_line 300 62 44 $W "통상시" "제목1"
add_panel 300 100 260 250 ${=NAVY} "1500 패널";               add_block 300 160 260 150 34 $Y "1500개\nST 157회\n약 0.5%" "1500"
add_panel 15 300 280 270 ${=NAVY} "300 시단 패널";            add_block 15 365 280 150 34 $W "300개\n시단 100회\n약 49.5%" "300 시단"
add_panel 325 410 265 260 ${=RED} "300 ST 패널";              add_block 325 470 265 150 34 $W "300개\nST 157회\n약 50%" "300 ST"
"$PHOTOCRAFT_BIN" run img-specgraph1_pc.png "${cmds[@]}" --out chart1-ko.png --format png >/dev/null

# 한국어 번역본 3: 특도 2 배분 원그래프(원본 600×698)
cmds=()
add_panel 140 4 320 80 ${=NAVY} "제목2 패널";                add_line 300 62 44 $W "우타 중" "제목2"
add_panel 15 105 340 225 ${=NAVY} "4800 패널";               add_block 15 165 340 120 40 $Y "4800개\n약 0.5%" "4800"
add_panel 150 425 340 230 ${=NAVY} "2400 패널";              add_block 150 485 340 120 40 $Y "2400개\n약 99.5%" "2400"
"$PHOTOCRAFT_BIN" run img-specgraph2_pc.png "${cmds[@]}" --out chart2-ko.png --format png >/dev/null

# 번역본 4: 스펙 패널 6장을 합성하고 일본어 문구를 한국어 패널로 덮는다(PIL)
python3 -I - "$ASSET_DIR" <<'PY'
import sys
from PIL import Image, ImageDraw, ImageFont
d = sys.argv[1]
font_path = "/System/Library/AssetsV2/com_apple_MobileAsset_Font7/bad9b4bf17cf1669dde54184ba4431c22dcad27b.asset/AssetData/NanumGothic.ttc"
def font(size):
    return ImageFont.truetype(font_path, size)
NAVY = (13, 13, 31, 255)
GOLD = (255, 216, 74, 255)
WHITE = (255, 255, 255, 255)

def cover(img, box, lines, size, color=WHITE):
    dr = ImageDraw.Draw(img)
    x, y, w, h = box
    dr.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=NAVY, outline=GOLD, width=2)
    f = font(size)
    lh = int(size * 1.25)
    total = lh * len(lines)
    ty = y + (h - total) // 2
    for ln in lines:
        tw = dr.textlength(ln, font=f)
        dr.text((x + (w - tw) / 2, ty), ln, font=f, fill=color)
        ty += lh

def load(n):
    return Image.open(f"{d}/img-spec{n}_pc.png").convert("RGBA")

p = {n: load(n) for n in range(1, 7)}
cover(p[1], (60, 48, 552, 150), ["도안 정렬 확률", "(통상시·시단 중)"], 44)
cover(p[1], (0, 372, 672, 80), ["※대당첨 확률 약 1/349.9", "※도안 정렬 대당첨과 차지 돌입 대당첨의 합산"], 24)
cover(p[2], (60, 50, 552, 158), ["도안 정렬 확률", "(ST 중)"], 46)
cover(p[3], (60, 285, 190, 90), ["시단"], 54)
cover(p[3], (498, 110, 90, 95), ["회"], 60)
cover(p[3], (498, 285, 90, 95), ["회"], 60)
cover(p[4], (110, 48, 450, 80), ["ST 돌입률"], 52)
cover(p[4], (0, 340, 672, 84), ["※도안 정렬 대당첨·차지 돌입 대당첨·", "찬스타임 인계의 합산에 대한 비율"], 24)
cover(p[5], (55, 48, 562, 90), ["우타 중 출옥"], 50)
cover(p[6], (110, 48, 450, 90), ["ST 계속률"], 52)

order = [1, 2, 3, 4, 5, 6]
cell_w = 672
heights = {1: 452, 2: 452, 3: 452, 4: 424, 5: 424, 6: 424}
rows_h = [452, 424]
sheet = Image.new("RGBA", (cell_w * 2 + 24, sum(rows_h) * 3 // 2 + 0), (13, 13, 31, 255))
# 3행×2열: (1,2) (3,4) (5,6)
layout = [(1, 2), (3, 4), (5, 6)]
y = 0
for a, b in layout:
    h = max(heights[a], heights[b])
    sheet.paste(p[a], (0, y))
    sheet.paste(p[b], (cell_w + 24, y))
    y += h + 12
sheet = sheet.crop((0, 0, sheet.width, y - 12))
sheet.convert("RGB").resize((1200, int(sheet.height * 1200 / sheet.width)), Image.LANCZOS).crop((0, 0, 1200, 1170)).save(f"{d}/spec-ko.png")
PY

# 번역본 가로 1200px로 통일(디자인 문서 규격)
"$PHOTOCRAFT_BIN" run flow-ko.png --cmd image.imageSize --params '{"width":1200,"height":1607,"units":"px","scaleStyles":true,"resample":"lanczos"}' --out flow-ko.png --in-place --format png >/dev/null

echo "Korean overlays written to $ASSET_DIR"
