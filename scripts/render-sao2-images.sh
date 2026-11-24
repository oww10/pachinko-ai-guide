#!/bin/zsh
set -euo pipefail

# L 소드 아트 온라인 2 공식 이미지 가공 스크립트.
# 원본(*-source.jpg)은 보존하고, 기기·AT 화면 크롭과 한국어 번역본(*-ko.png)을 별도 PNG로 만든다.
PHOTOCRAFT_BIN="${PHOTOCRAFT_CLI:-/Users/oww/.local/bin/photocraft-cli}"
PROJECT_ROOT="${0:A:h:h}"
ASSET_DIR="$PROJECT_ROOT/dist/assets/images/official/sao2"

if [[ ! -x "$PHOTOCRAFT_BIN" ]]; then
  echo "PhotoCraft CLI not found: $PHOTOCRAFT_BIN" >&2
  exit 1
fi

# panel x y w h r g b name → 불투명 번역 패널(색 지정)
panel() {
  print -r -- "{\"kind\":\"roundedRect\",\"rect\":[$1,$2,$3,$4],\"radii\":14,\"fill\":[$5,$6,$7,1],\"stroke\":{\"width\":3,\"color\":\"#ffd84a\",\"opacity\":100,\"align\":\"inside\"},\"name\":\"$8\"}"
}
# line x baselineY size color text name → 가운데 정렬 한 줄 문구
line() {
  print -r -- "{\"x\":$1,\"y\":$2,\"text\":\"$5\",\"font\":\"NanumGothic\",\"size\":$3,\"color\":\"$4\",\"align\":\"center\",\"name\":\"$6\"}"
}
# block x y w h size color text name → 박스 안 여러 줄 문구(\n 사용)
block() {
  print -r -- "{\"box\":[$1,$2,$3,$4],\"text\":\"$7\",\"font\":\"NanumGothic\",\"size\":$5,\"color\":\"$6\",\"align\":\"center\",\"name\":\"$8\"}"
}
add_panel() { cmds+=(--cmd shape.create --params "$(panel "$@")"); }
add_line()  { cmds+=(--cmd type.create --params "$(line "$@")"); }
add_block() { cmds+=(--cmd type.create --params "$(block "$@")"); }

W="#ffffff"

# 기기 외관: 기본 정보 이미지(원본 2917×1875)의 筐体 영역
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/basic-source.jpg" \
  --cmd image.crop --params '{"x":1740,"y":330,"width":870,"height":1470,"targetWidth":676,"targetHeight":1142,"resample":"lanczos"}' \
  --out "$ASSET_DIR/machine.png" --format png >/dev/null

# AT 카드용 화면: AT 소개 이미지(원본 2917×1875)의 장면 영역(글자가 없는 구간)
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/at-source.jpg" \
  --cmd image.crop --params '{"x":190,"y":275,"width":398,"height":222,"targetWidth":398,"targetHeight":222,"resample":"lanczos"}' \
  --out "$ASSET_DIR/at-screen.png" --format png >/dev/null

# 한국어 번역본 1: 공식 게임 플로우(원본 2917×1958)
cmds=()
add_panel 2328 160 510 84 0.1 0.1 0.1 "경고 문구 패널"
add_block 2328 171 510 73 11 $W "통상시는 왼쪽 먼저 누르기 권장\n순서 내비가 나오면 내비에 따르세요" "경고 문구"
add_panel 1015 62 888 156 0 0.35 0.1 "제목 패널"
add_line 1459 180 53 $W "게임 플로우" "제목"
add_panel 185 312 255 65 0 0.1 0.45 "통상시 패널"
add_line 312 363 24 $W "통상시" "통상시"
add_panel 131 610 562 52 0 0 0 "규정 게임수 패널"
add_line 412 647 14 $W "규정 게임 수 도달로 CZ 당첨 기대!" "규정 게임수"
add_panel 200 698 425 50 0.02 0.04 0.2 "슈팅 차지 패널"
add_line 412 735 17 $W "슈팅 차지" "슈팅 차지"
add_panel 131 816 562 52 0 0 0 "게임수 가산 패널"
add_line 412 853 14 $W "게임 수 대량 가산 기회!?" "게임수 가산"
add_panel 160 1072 530 70 0 0.35 0.1 "스코드론 패널"
add_line 425 1123 20 $W "스코드론 배틀 (CZ)" "스코드론"
add_panel 588 1190 188 42 0.3 0.05 0.5 "CZ 기대도 패널"
add_line 681 1219 11 $W "승리 기대도" "CZ 기대도"
add_panel 262 1360 412 45 0 0 0 "정지 기대도 패널"
add_line 469 1393 14 $W "정지로 승리 기대도 UP!" "정지 기대도"
add_panel 294 1475 250 42 0.02 0.04 0.2 "광야의 결투 패널"
add_line 419 1508 16 $W "광야의 결투" "광야의 결투"
add_panel 138 1665 575 120 0 0 0 "광야 설명 패널"
add_block 138 1688 575 97 14 $W "CZ 실패 시 일부에서 돌입!\n40G 에피소드 후 AT로!!" "광야 설명"
add_panel 902 522 335 135 0.8 0.32 0 "AT 스펙 패널"
add_block 902 546 335 111 11 $W "순증 약 3.6매\n초기 매수 150매+α\n차매수 관리형 AT" "AT 스펙"
add_panel 902 698 738 140 0.8 0.32 0 "추첨 패널"
add_block 902 711 738 127 21 $W "희귀역 & 액정 게임 수로\n스나이퍼 찬스를 추첨!" "추첨"
add_panel 1119 835 350 92 0.02 0.04 0.2 "스나이퍼 찬스 패널"
add_line 1294 894 17 $W "스나이퍼 찬스" "스나이퍼 찬스"
add_panel 1528 900 160 38 0.3 0.05 0.5 "SC 기대도 패널"
add_line 1608 926 10 $W "승리 기대도" "SC 기대도"
add_panel 1012 1185 538 50 0 0 0 "소역 찬스 패널"
add_line 1281 1222 16 $W "소역을 많이 뽑을수록 찬스!" "소역 찬스"
add_panel 982 1255 148 38 0.8 0.32 0 "승리 보수 패널"
add_line 1056 1284 13 $W "승리 보수" "승리 보수"
add_panel 1038 1465 212 45 0 0 0 "차매수 상승 패널"
add_line 1144 1498 14 $W "차매수 상승" "차매수 상승"
add_panel 1362 1532 175 45 0 0 0 "특화 상승 패널"
add_line 1450 1565 13 $W "특화 상승" "특화 상승"
add_panel 862 1585 825 192 0.8 0.32 0 "권리 획득 패널"
add_block 862 1623 825 155 22 $W "최대 3전 승리로\n데스건 배틀 권리 획득!?" "권리 획득"
add_panel 1910 304 406 80 0.3 0.05 0.5 "데스건 배틀 패널"
add_line 2113 360 22 $W "데스건 배틀" "데스건 배틀"
add_panel 2495 425 135 35 0.3 0.05 0.5 "DGB 기대도 패널"
add_line 2562 450 10 $W "승리 기대도" "DGB 기대도"
add_panel 2375 638 425 48 0 0 0 "승률 업 패널"
add_line 2588 672 14 $W "상위 AT 후 승률 UP!?" "승률 업"
add_panel 1950 890 775 78 0.6 0 0 "이행 패널"
add_line 2338 944 20 $W "승리하면 둘 중 하나로 이행!?" "이행"
add_panel 1931 1008 375 52 0.02 0.04 0.2 "울티마 패널"
add_line 2119 1044 13 $W "울티마 나이트 배틀" "울티마"
add_panel 1950 1215 375 88 0 0 0 "매 게임 패널"
add_block 1950 1221 375 81 14 $W "매 게임\n차매수 상승!" "매 게임"
add_panel 2481 1010 138 52 0.02 0.04 0.2 "절검 패널"
add_line 2550 1050 18 $W "절검" "절검"
add_panel 2402 1220 400 50 0 0 0 "최강 트리거 패널"
add_line 2602 1255 13 $W "본기 최강 트리거!" "최강 트리거"
add_panel 2356 1332 462 95 0 0 0 "에피소드 패널"
add_block 2356 1344 462 83 13 $W "에피소드\n마더즈 로자리오" "에피소드"
add_panel 1906 1652 919 130 0.6 0 0 "소화 후 패널"
add_line 2366 1735 23 $W "소화 후에는 다시 데스건 배틀로!" "소화 후"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/gameflow-ko.png" --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/gameflow-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":805,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/gameflow-ko.png" --in-place --format png >/dev/null

# 한국어 번역본 2: 공식 기본 정보 · 스펙표(원본 2917×1875)
cmds=()
add_panel 1154 34 614 175 0 0.35 0.1 "제목 패널"
add_line 1461 161 53 $W "기본 정보" "제목"
add_panel 536 310 231 58 0.02 0.04 0.2 "배당표 패널"
add_line 651 355 21 $W "배당표" "배당표"
add_panel 806 475 85 46 0.02 0.04 0.2 "3매 패널"
add_line 849 511 18 $W "3매" "3매"
add_panel 762 631 173 49 0.02 0.04 0.2 "1매 15매 패널"
add_line 849 663 11 $W "1매 or 15매" "1매 15매"
add_panel 762 784 163 49 0.02 0.04 0.2 "3매 15매 패널"
add_line 844 817 11 $W "3매 or 15매" "3매 15매"
add_panel 789 959 119 46 0.02 0.04 0.2 "리플레이 패널"
add_line 849 992 13 $W "리플레이" "리플레이"
add_panel 616 1093 314 32 0.02 0.04 0.2 "배당 주석 패널"
add_line 773 1116 9 $W "※보이는 배당의 일부입니다" "배당 주석"
add_panel 1230 310 268 61 0 0.35 0.1 "릴 배열 패널"
add_line 1364 357 21 $W "릴 배열" "릴 배열"
add_panel 536 1224 243 67 0.8 0.32 0 "스펙 패널"
add_line 657 1273 21 $W "스펙" "스펙"
add_panel 385 1339 97 46 0.6 0 0 "설정 헤더 패널"
add_line 433 1371 12 $W "설정" "설정 헤더"
add_panel 489 1339 131 46 0.6 0 0 "초당첨 헤더 패널"
add_line 555 1371 12 $W "초당첨" "초당첨 헤더"
add_panel 631 1339 151 46 0.6 0 0 "AT 초당첨 헤더 패널"
add_line 706 1370 11 $W "AT 초당첨" "AT 초당첨 헤더"
add_panel 789 1339 124 46 0.6 0 0 "기계할 헤더 패널"
add_line 851 1371 12 $W "기계할" "기계할 헤더"
add_panel 743 1730 187 32 0.8 0.32 0 "시뮬레이션 주석 패널"
add_line 836 1752 9 $W "※시뮬레이션 값" "시뮬레이션 주석"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/basic-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/basic-ko.png" --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/basic-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":771,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/basic-ko.png" --in-place --format png >/dev/null

# 한국어 번역본 3: 공식 CZ 스코드론 배틀(원본 2917×1875)
cmds=()
add_panel 655 30 1602 192 0 0.35 0.1 "제목 패널"
add_line 1456 166 53 $W "스코드론 배틀 (CZ)" "제목"
add_panel 822 262 1607 292 0.1 0.1 0.1 "헤드라인 패널"
add_block 822 335 1607 219 27 $W "바레트 서클에 불릿 찬스를 정지시켜\n베히모스를 격파하라!" "헤드라인"
add_panel 2520 309 286 85 0.3 0.05 0.5 "기대도 패널"
add_line 2663 363 15 $W "기대도" "기대도"
add_panel 201 584 365 73 0 0.1 0.45 "전반 패널"
add_line 383 636 20 $W "전반 파트" "전반"
add_panel 1619 584 402 73 0 0.35 0.1 "저지 패널"
add_line 1820 636 20 $W "저지 파트" "저지"
add_panel 700 730 664 128 0.02 0.04 0.2 "탄흔 설명 패널"
add_block 700 753 664 105 15 $W "바레트 서클에 정지나\n희귀역으로 탄흔 증가!" "탄흔 설명"
add_panel 205 1152 1088 54 0.02 0.04 0.2 "탄흔 기대도 패널"
add_line 749 1188 13 $W "탄흔이 많을수록 격파 기대도 UP!! 탄흔 1개당 기대도 약 10% 가산!?" "탄흔 기대도"
add_panel 209 1544 1079 102 0.02 0.04 0.2 "AT 농후 패널"
add_block 209 1562 1079 84 12 $W "바레트 서클에 그림 정지나 탄흔 10개 적립 시 AT 농후!?\n추가로 잔여 G수 +5G & 스나이퍼 찬스 스톡 추첨!!" "AT 농후"
add_panel 1619 1110 645 105 0.02 0.04 0.2 "최종 공방 패널"
add_block 1619 1133 645 82 11 $W "베히모스와의 최종 공방!\n배틀 중 희귀역으로 재추첨!?" "최종 공방"
add_panel 2311 1087 392 117 0.6 0 0 "쏘아라 패널"
add_line 2507 1172 35 $W "쏘아라!" "쏘아라"
add_panel 1812 1546 721 93 0.02 0.04 0.2 "광야 설명 패널"
add_block 1812 1561 721 78 12 $W "CZ 실패 시 일부에서 「광야의 결투」 발생!?\n발생 시 AT+α!?" "광야 설명"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/cz-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/cz-ko.png" --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/cz-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":771,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/cz-ko.png" --in-place --format png >/dev/null

# 한국어 번역본 4: 공식 AT Bullet of Bullets(원본 2917×1875)
cmds=()
add_panel 1321 274 1485 268 0.1 0.1 0.1 "헤드라인 패널"
add_block 1321 322 1485 219 32 $W "희귀역이나 규정 액정 게임 수 도달로\n스나이퍼 찬스 당첨을 노려라!" "헤드라인"
add_panel 834 280 365 61 0 0.35 0.1 "상승형 패널"
add_line 1017 322 15 $W "차매수 상승형 AT" "상승형"
add_panel 840 371 414 73 0 0.35 0.1 "순증 패널"
add_line 1047 421 18 $W "순증 약 3.6매" "순증"
add_panel 883 485 408 73 0 0.35 0.1 "초기 매수 패널"
add_line 1087 533 16 $W "초기 매수 150매+α" "초기 매수"
add_panel 195 584 280 73 0 0.1 0.45 "희귀역 패널"
add_line 335 637 21 $W "희귀역" "희귀역"
add_panel 2167 584 414 73 0 0.1 0.45 "액정 게임수 패널"
add_line 2374 636 20 $W "액정 게임 수" "액정 게임수"
add_panel 152 706 469 79 0.02 0.04 0.2 "상승 추첨 패널"
add_block 152 711 469 74 13 $W "상승·스나이퍼 찬스·\n상태 이행을 추첨!" "상승 추첨"
add_panel 426 989 408 55 0.02 0.04 0.2 "상승 기대도 패널"
add_line 630 1027 15 $W "상승 당첨 기대도" "상승 기대도"
add_panel 1254 677 511 55 0.02 0.04 0.2 "SC 고확률 패널"
add_line 1510 717 16 $W "스나이퍼 찬스 고확률" "SC 고확률"
add_panel 1157 1004 700 55 0.02 0.04 0.2 "체류 중 패널"
add_line 1507 1042 14 $W "체류 중 희귀역은 스나이퍼 찬스 기대!?" "체류 중"
add_panel 2222 962 402 97 0.02 0.04 0.2 "규정 G수 패널"
add_block 2222 977 402 82 12 $W "규정 G수 도달로 SC 추첨!\n20G마다 찬스 도래!?" "규정 G수"
add_panel 207 1150 463 85 0 0.35 0.1 "바레트 브레이크 패널"
add_line 438 1208 20 $W "바레트 브레이크" "바레트 브레이크"
add_panel 992 1150 438 85 0 0.35 0.1 "시논 어택 패널"
add_line 1211 1209 21 $W "시논 어택" "시논 어택"
add_panel 1820 1144 572 91 0.8 0.32 0 "라스트 어택 패널"
add_line 2106 1205 20 $W "라스트 어택 찬스" "라스트 어택"
add_panel 213 1605 463 110 0.02 0.04 0.2 "키리토 패널"
add_block 213 1621 463 93 14 $W "키리토가 화면을 가르며\n추가 상승 발생!?" "키리토"
add_panel 950 1601 584 110 0.02 0.04 0.2 "시논 설명 패널"
add_block 950 1622 584 88 12 $W "프리즈나 그림 정렬로 발생!?\n누름 순서로 상승 매수 승격!!" "시논 설명"
add_panel 1743 1270 935 54 0.02 0.04 0.2 "소화 후 돌입 패널"
add_line 2211 1306 12 $W "차매수 소화 후 돌입! 스나이퍼 찬스 고확률!" "소화 후 돌입"
add_panel 1729 1595 1071 124 0.02 0.04 0.2 "LA 설명 패널"
add_block 1729 1624 1071 95 12 $W "1~4G째는 희귀역 성립으로 스나이퍼 찬스,\n최종 G는 바레트 서클에 정지해도 스나이퍼 찬스!?" "LA 설명"
add_panel 2611 1364 97 37 0.3 0.05 0.5 "LA 기대도 패널"
add_line 2660 1390 11 $W "기대도" "LA 기대도"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/at-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/at-ko.png" --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/at-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":771,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/at-ko.png" --in-place --format png >/dev/null

# 한국어 번역본 5: 공식 상위 구간 데스건 배틀·FULL DIVE(원본 2917×1875)
cmds=()
add_panel 195 43 755 144 0.3 0.05 0.5 "제목 좌 패널"
add_line 572 138 32 $W "데스건 배틀" "제목 좌"
add_panel 2234 158 487 149 0 0.35 0.1 "제목 우 패널"
add_line 2478 254 29 $W "(상위 AT)" "제목 우"
add_panel 813 273 207 97 0.3 0.05 0.5 "기대도 패널"
add_line 917 334 16 $W "기대도" "기대도"
add_panel 85 580 968 97 0.3 0.05 0.5 "승리 패널"
add_line 569 647 26 $W "배틀에 승리해 상위 AT를 잡아라!" "승리"
add_panel 91 919 457 51 0 0 0 "배틀 중 패널"
add_line 320 955 14 $W "배틀 중 희귀역은 찬스!" "배틀 중"
add_panel 243 1077 645 67 0.8 0.32 0 "최종 G 패널"
add_line 566 1125 19 $W "최종 G 연출 성공으로 상위 AT!" "최종 G"
add_panel 657 1461 390 183 0.8 0.32 0 "전력 패널"
add_block 657 1483 390 161 26 $W "전력으로\n쏘아라!!" "전력"
add_panel 207 1637 718 128 0 0 0 "연출 실패 패널"
add_block 207 1659 718 107 16 $W "연출에 실패해도 바레트 서클에\n특정 도안이 정지하면…!?" "연출 실패"
add_panel 1169 761 1157 280 0.8 0.32 0 "특화 존 패널"
add_block 1169 803 1157 238 36 $W "돌입 시 특화 존 시작!\nAT 성능이 대폭 강화!" "특화 존"
add_panel 2173 438 152 58 0.7 0.05 0.3 "순증 패널"
add_line 2249 480 16 $W "순증" "순증"
add_panel 2076 492 414 178 0.7 0.05 0.3 "7.2매 패널"
add_line 2283 605 33 $W "약 7.2매" "7.2매"
add_panel 1242 1327 420 103 0 0 0 "직상승 패널"
add_block 1242 1339 420 91 15 $W "차매수 직상승은\n전부 3자리 이상!?" "직상승"
add_panel 2045 1288 609 55 0 0 0 "특화 돌입 패널"
add_line 2350 1326 14 $W "상승 특화 존 돌입 시," "특화 돌입"
add_panel 2344 1394 450 61 0 0 0 "선택률 패널"
add_line 2569 1435 14 $W "의 선택률이 UP!" "선택률"
add_panel 1175 1516 1668 250 0.6 0 0 "소화 후 패널"
add_block 1175 1555 1668 210 32 $W "차매수 소화 후에는 다시 데스건 배틀로!\nBullet of Bullets FULL DIVE 후에는 승률 UP!?" "소화 후"

"$PHOTOCRAFT_BIN" run "$ASSET_DIR/upper-source.jpg" "${cmds[@]}" --out "$ASSET_DIR/upper-ko.png" --format png >/dev/null
"$PHOTOCRAFT_BIN" run "$ASSET_DIR/upper-ko.png" \
  --cmd image.imageSize --params '{"width":1200,"height":771,"units":"px","scaleStyles":true,"resample":"lanczos"}' \
  --out "$ASSET_DIR/upper-ko.png" --in-place --format png >/dev/null

echo "Korean PhotoCraft images written to $ASSET_DIR"
