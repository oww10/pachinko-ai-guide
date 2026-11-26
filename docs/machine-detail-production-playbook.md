# 파치스펙 AI 상세페이지 제작 플레이북

마지막 갱신: 2026-11-26

**새 파칭코 기종을 추가하거나 기존 기종을 보강할 때는 이 문서의 "표준 절차"와 "완료 기준"을 따른다.** 한 기종의 상세페이지는 항상 [리제로 오니가카리 2](../dist/data/pachinko/e-rezero-onigakari-2.json)와 같은 화면 구성(핵심 숫자 · 분기 다이어그램 · 원그래프 · STEP 설명 · 공식 이미지 번역)을 목표로 한다. `visualGuide.mainImage`만 넣는 간소 구조는 쓰지 않는다.

## 0. 문서 지도

| 순서 | 문서 | 언제 읽나 |
|---|---|---|
| 1 | 이 문서 | 기종 작업을 시작할 때 항상 |
| 2 | [디자인 시스템](machine-detail-design-system.md) | JSON 필드 규격, `tone` 값, 이미지 크기를 확인할 때 |
| 3 | [이미지 출처·재사용 절차](image-sourcing-workflow.md) | 이미지를 쓰기 전, 출처를 기록할 때 |
| 4 | [운영·인수인계](project-handoff.md) | 로컬 확인, 배포, 장애 대응 |
| 5 | [시작용 JSON 템플릿](templates/machine-detail-visual-guide.template.json) | 새 기종 JSON의 뼈대 |

**기준 구현** (복사해서 시작할 때 이 파일들을 본다)

| 유형 | 기종 ID | 특징 |
|---|---|---|
| 확변 루프 + 공식 번역 이미지 | `p-super-sea-okinawa-6` | 2개 번역본, 원그래프 2개 + 표(`extraTables`) |
| 甘デジ ST + 시단 | `pa-super-sea-okinawa-6-enako` | 서포트 회수별 이동표 3개, 번역본 2개 |
| 확변 루프 | `p-big-sea-story-5` | 가장 단순한 구조 |
| RUSH + 번역 이미지 4장 | `e-rezero-onigakari-2` | 원래 기준(부록 A) |
| 다단계 RUSH | `e-fever-gundam-seed-climax`, `e-tokyo-ghoul-super-deka-cho-ichigeki`, `e-lycoris-recoil` | `climax`, `modeB` 등 추가 배열 |

번역 스크립트 기준 예시: `scripts/render-super-sea-okinawa-6-enako-images.sh`

## 1. 표준 절차 (한 기종)

기종마다 `feat/<기종-id>` 브랜치에서 작업한다. 모든 단계는 **목록 제시 → 오너 승인 → 실행**을 따르고, 배포는 매번 별도 승인을 받는다.

1. **p-town 기종 페이지 읽기**: `https://p-town.dmm.com/machines/<ID>`. 본문이 길어 요약만 오면 "記載なし"로 잘못 나오는 항목이 많다. 반드시 `offset`으로 끝까지 읽고 요약과 본문이 다르면 본문을 따른다.
2. **제조사 공식 대조**: 3장의 경로로 기종명·型式名·導入日·확률·배분을 대조한다. 공식에 없는 값은 `secondary`로 표시하고 `needsReviewFields`에 남긴다. 검색 요약에만 있는 값은 근거로 쓰지 않는다.
3. **대당첨 비율 이미지 판독**: `https://p-town.dmm.com/upload/machines/<ID>/hit_rate.jpg`를 받아 `scripts/split-tall-image.py`로 1,000px씩 잘라 조각마다 직접 읽는다. 표마다 비율 합계가 100%인지 확인한다. 이미지는 스크래치패드에만 둔다.
4. **기기 사진**: P-WORLD 기종 DB ID를 찾아 `python3 scripts/fetch-pworld-machine-photo.py <ID> dist/assets/images/official/<폴더>/machine.png`. 폴더를 먼저 만든다. 사진이 해당 기종인지 직접 열어 확인한다.
5. **JSON 작성**: 2장의 필수 항목을 모두 채운다. `dist/data/pachinko/<id>.json`을 만들고 `index.json`의 맨 위에 등록한다.
6. **공식 이미지 번역(공식 이미지가 있을 때)**: 4장 방법으로 원본을 보존하고 PhotoCraft 한국어 번역본을 만든다. 공식 이미지를 구하지 못하면 번역본 없이 자체 도식만 두고 `notes`에 이유를 적는다.
7. **썸네일·캐시**: `python3 scripts/make-card-thumbs.py` 실행 후 `git status`에서 기존 썸네일이 바뀌지 않았는지 확인한다. 바뀌었으면 되돌린다. `dist/index.html`의 `?v=` 번호를 올린다.
8. **검증**: 5장 방법으로 확인한다.
9. **배포(승인 후)**: 6장 순서를 따른다.

## 2. 필수 데이터 항목

| 항목 | 규칙 |
|---|---|
| `visualGuide.mainImage` | 기기 외관 1장. `credit`·`sourceUrl`은 실제로 받은 출처(P-WORLD 사진이면 P-WORLD) |
| `keyStats` | **정확히 3개.** 값이 길면 카드에서 줄바꿈이 어색하므로 짧게(`82%` + 라벨에 "약") |
| `flowDiagram` | 통상시 → 초당첨 결과 카드 → RUSH/ST → 결과 카드. `tone`은 `return`·`rush`·`premium`·`reset` |
| `steps` | 3개(통상시 / 초당첨 판정 / RUSH·ST) |
| `distributionCharts` | `source`는 `payouts`에 실제로 있는 배열 키여야 한다. 표시용 키는 `initial`·`rush`·`climax`·`modeB`·`ultimateDrive`. 공통 JS를 고치지 않으면 `extraTables`는 표로만 표시되고 원그래프로 만들 수 없다(원그래프 2~3개까지) |
| `payouts` | `initial` = 초기 당첨(헤소), `rush` = 전동 튤립·RUSH 중. 이동 조건별 표는 `extraTables`. 합계는 각 표 100% |
| `translatedImages` | 공식 이미지가 있을 때만. 기본 정보 → 게임 플로우 순 |
| `sources` | 공식/보조를 `type`으로 구분. 이미지 출처도 별도 항목 |
| `verification` | `status`, `checkedAt`, `needsReviewFields`. `nameKo`는 항상 검수 대상 |

**공식 이미지가 없는 기종의 표시(2026-11-26 `app.js` 수정)**: `translatedImages`에 `url`이 있는 항목이 하나도 없으면 "공식 이미지 · 한국어 번역본" 갤러리와 PhotoCraft 번역 문구는 나오지 않고, `steps`가 "게임 진행 단계" 텍스트 카드(1열)로 표시된다. 따라서 이미지가 없는 기종은 `steps`의 `description`을 빠짐없이 채운다. 이미지가 있으면 기존 갤러리가 그대로 나온다.

**근거 없는 원그래프는 만들지 않는다.** 출옥 배분이 공식·p-town 어디에도 없으면 원그래프를 생략하고(`payouts`는 빈 배열 가능) `notes`에 이유를 적는다. 예: `e-toaru3`.

기종 구조별 표현

- **확변 루프(대해·오키나와)**: 초기 → 확변(다음 대당첨까지) 루프. `loopNote`에 시단·진베에타임 설명
- **ST + 시단(甘デジ)**: 서포트 회수(25/50/120)를 결과 카드의 `route`로 표시, 회수별 이동은 `extraTables`
- **LT·ST**: `rush.spins`, `continuationRatePercent`를 채우고 상위 상태가 있으면 `secondaryRush`
- 숫자는 `probabilities`·`rush`·`payouts`와 일치시킨다. 공식 표기(약 1/319)와 p-town 표기(1/319.6)가 다르면 JSON은 p-town 소수값, `notes`에 차이를 적는다.

## 3. 제조사별 공식 확인 경로

| 제조사 | 경로와 방법 | 확인된 기종 |
|---|---|---|
| 三洋物産 (SANYO) | 제품 목록 `https://www.sanyobussan.co.jp/products/pachinko.html`에서 제품 폴더를 찾는다(예: `pk_supersea_okinawa6/`). 폴더 안에 가이드북 PDF(`<폴더>_guidebook_PC.pdf`)가 있고 3쪽 基本情報, 4쪽 ゲームフロー가 스펙·플로우다. 型式名·導入日은 `information/pdf/sanyo_press_release_*.pdf` 첫 쪽. 추측한 `spec/` 하위 주소는 404 | 沖縄6, 沖縄6 Withえなこ, 大海5 |
| サンスリー | 같은 사이트 `products/pk_granbelm/`. 제품 페이지에 가이드북 PDF 3종(`pk_granbelm_guidebook_319_PC.pdf` 등, 버전별)이 있고 이미지 PDF라 `scripts/render-pdf-pages.swift`로 렌더링해 읽는다. 3쪽 基本情報, 4쪽 ゲームフロー | e 그랑벨룸 319 (번역 완료) |
| SANKYO | `sankyo-fever.jp`는 **Incapsula 봇 차단**(2026-11-26 확인)으로 헤드리스 Chrome도 빈 페이지만 받는다. 우회하지 않는다. 공식 이미지는 구하지 못하므로 자체 도식만 만들고 `notes`에 이유를 적는다. p-town 페이지의 "메이커 공식 사이트" 링크는 포털(`sankyo-fever.co.jp`)만 가리킨다 | 요괴워치 (자체 도식만) |
| Sammy | 제품 페이지에 스펙 이미지가 직접 올라와 있다: `https://www.sammy.co.jp/japanese/product/pachinko/<폴더>/img/spec_1.jpg`(2000px, 基本情報). 페이지 HTML에서 `img/*.jpg` 경로를 찾는다. `tokusetu.png` 등 일부는 같은 경로에서 404 | e 수왕 (번역 완료) |
| 藤商事 | `fujimarukun.co.jp/products/<id>/` 본문에 확률·突入率·継続率이 있다. 페이지의 `spec_image`는 **기기 사진(500×750)뿐**이고 스펙·플로우 이미지는 없다. 배분은 공식에 없는 경우가 있다 | e 금서목록 3 (자체 도식만) |
| 京楽 | `kyoraku.co.jp`가 2026-11-26에 접속되지 않았다(타임아웃, IPv4 포함 3회). 접속이 되면 제품 페이지에서 스펙 이미지를 찾는다. 공식 스펙을 못 읽으면 p-town 판독값을 `secondary`로 쓰고 자체 도식만 만든다 | SAO 밤하늘 (자체 도식만) |
| 대도기연 | 공식 제품 자료 이미지(리제로) | e 리제로 2 |
| p-town | 스펙·보더·하마리 표는 본문, 배분은 `hit_rate.jpg` | 전 기종 |
| P-WORLD | 기기 사진. ID는 검색 결과의 `machine/database/<ID>`로 찾는다. 신작은 인접 ID를 스캔 | 전 기종 |

- hazuse·Fields는 403이므로 우회하지 않는다. 로그인·봇 차단 페이지는 우회하지 않는다.
- 공식 페이지에 기기 사진이 없으면(영상 썸네일·배너뿐) P-WORLD 사진을 쓰고 공식 이미지라고 표기하지 않는다.
- p-town 보더는 제조사 공식 값이 아니라 p-town 산출값이다. 조건(전지원 중 출옥 -5% 등)을 `border.condition`에 적는다.

## 4. 이미지 처리 방법

| 작업 | 도구 | 주의 |
|---|---|---|
| PDF 쪽 → PNG | `swift scripts/render-pdf-pages.swift <pdf> <폴더> [px] [쪽,쪽]` | 읽기용은 1500px, 번역 원본은 PDF 안 이미지 원래 크기(보통 2339px) |
| 긴 이미지 분할 | `python3 scripts/split-tall-image.py <이미지> <폴더> [높이]` | `sips -c --cropOffset`은 쓰지 않는다(오프셋이 어긋나고 끝에서 조용히 원본을 저장) |
| 한국어 번역 | PhotoCraft CLI, 기준 `scripts/render-super-sea-okinawa-6-enako-images.sh` | 아래 번역 규칙 |
| JSON 부분 수정 | `Edit`/텍스트 치환 | `json.dump`로 다시 쓰면 한 줄 배열 서식이 펼쳐져 diff가 폭증한다 |

**번역 규칙**

- 원본은 `spec-source.jpg`, `flow-source.jpg`로 보존하고 번역본은 `spec-ko.png`, `flow-ko.png`(1200×849)로 만든다. 번역 스크립트는 `scripts/render-<기종>-images.sh`로 남긴다.
- 기준 스크립트의 `cap x y w h size text name`이 반투명 패널과 가운데 정렬 문구를 한 번에 만든다. 좌표는 미리보기 이미지에서 읽고 `K = 원본 폭 / 미리보기 폭`으로 환산한다. 읽은 좌표는 10~30px 어긋나므로 결과를 열어 보고 2~3번 보정한다.
- 원본이 72DPI면 `size`는 px 그대로, 150DPI면 `px ÷ (150/72)`로 넣는다(`sips -g dpiWidth`로 확인).
- NanumGothic에는 `甘` 같은 한자 글리프가 없다. 번역 문구에 일본식 한자를 쓰지 말고 한국어로 풀어 쓴다(`아마데지`).
- 원문이 패널 밖으로 남는 잔상은 패널을 넓혀서 덮는다. 로고·기기·게임 화면은 가리지 않는다. 회전된 문구는 패널을 비스듬히 두지 않고 수평 패널로 대체한다.
- 번역에 쓴 수치와 구조는 JSON과 일치해야 한다. 번역 중 불일치를 찾으면 이미지 작업 전에 출처를 다시 확인한다.

## 5. 검증

```sh
jq empty dist/data/pachinko/<id>.json dist/data/pachinko/index.json
node --check dist/assets/app.js
python3 scripts/make-card-thumbs.py   # 기존 썸네일 변동 없는지 git status 확인
```

- 배분 표의 `ratePercent` 합계가 각 표 100%인지 스크립트로 확인한다.
- 화면은 `python3 -m http.server 4173 --directory dist` 후 `http://127.0.0.1:4173/?machine=<id>`.
- **Chrome 확장이 로컬 주소를 못 열면** headless Chrome을 쓴다. 접이식 섹션이 닫혀 있으므로 스크래치패드에 `dist` 복사본을 만들어 `index.html`에 아래 스크립트를 넣고 캡처한다(저장소는 건드리지 않는다).
  `<script>new MutationObserver(()=>document.querySelectorAll('details').forEach(d=>d.open=true)).observe(document,{childList:true,subtree:true});</script>`
- 데스크톱은 `--window-size=1200,6600 --virtual-time-budget=10000 --screenshot=...`, 모바일 390px은 390px 폭 iframe을 담은 래퍼 HTML을 캡처한다(`--window-size=390`은 실제 390px 레이아웃이 아니다).
- 확인할 것: 핵심 숫자 3개, 분기 카드 열 수, 원그래프 범례, 번역 이미지 가독성, 출처 링크, 모바일 줄바꿈.

## 6. 배포 (승인 후)

1. `main`이 원격과 같은지 확인(`git ls-remote origin refs/heads/main`).
2. `feat/<기종-id>` 브랜치에 필요한 파일만 `git add` 후 커밋. 공개 저장소이므로 내부 방침 문구와 `.company/` 링크를 넣지 않는다.
3. `main`에 `--no-ff` 병합 → **`main`만** 푸시(`--all` 금지).
4. `gh run watch <id> --exit-status`로 Deploy GitHub Pages 성공 확인. "No artifacts named github-pages"로 실패하면 `gh run rerun <id>` 또는 1~2분 간격으로 `gh workflow run "Deploy GitHub Pages" --ref main`.
5. 공개 사이트에서 JSON·이미지·썸네일이 200인지, `index.json`에 등록됐는지, `?v=` 번호가 올랐는지 확인한다. 정적 파일은 `max-age=600`이라 최대 10분 지연될 수 있다.

## 7. 완료 기준

- [ ] 공식 자료로 기종명·型式名·導入日과 핵심 확률을 대조했다(못 한 항목은 `needsReviewFields`)
- [ ] 대당첨 비율 이미지를 조각마다 읽었고 표마다 합계가 100%다
- [ ] `keyStats` 3개, `flowDiagram`, `steps` 3개, 원그래프(근거가 있을 때)가 있다
- [ ] 공식 이미지가 있으면 `spec-source`/`flow-source`와 번역본, 번역 스크립트가 저장소에 있다. 없으면 이유가 `notes`에 있다
- [ ] 이미지별 실제 출처가 `credit`·`sourceUrl`·`sources`에 있다(공식이 아닌 이미지를 공식으로 표기하지 않는다)
- [ ] `jq`·`node --check` 통과, 데스크톱·모바일 화면을 직접 확인했다
- [ ] 기존 썸네일이 바뀌지 않았고 `?v=` 번호를 올렸다
- [ ] 배포 후 공개 URL을 확인했다

## 부록 A. 리제로 기준 상세 (이미지 번역 4장 구성)

아래는 리제로 오니가카리 2를 기준으로 정리한 원래의 제작 순서다. 새 기종은 위 표준 절차를 먼저 따르고, 이 부록은 4장짜리 번역 갤러리를 만들 때 참고한다.

### A.1 기준 화면과 파일

- 데이터 기준: `dist/data/pachinko/e-rezero-onigakari-2.json`
- 새 기종 시작 구조: `docs/templates/machine-detail-visual-guide.template.json`
- 번역 가공 기준: `scripts/render-korean-official-images.sh` — 리제로 전용 좌표·문구이므로 새 기종용 복사본을 만든다.
- 이미지 배치 기준: `dist/assets/images/official/onirezero2/` — 새 기종은 별도 폴더를 쓴다.
- 공통 렌더러와 스타일: `dist/assets/app.js`, `dist/assets/styles.css` — 기종별 제작에서는 JSON과 이미지로 내용을 채운다.

### A.2 원본 조사와 이미지 준비

1. 파치마가 같은 전문 기종 페이지에서 기기 외관, 통상시, 보너스·초당첨, RUSH 이미지 후보를 찾는다. 리제로 최초 화면은 이 방식으로 パチマガスロマガFREE 이미지 네 개를 직접 참조했다. 발견 페이지와 이미지 직접 URL을 각각 기록한다.
2. 제조사 공식 자료에서 제품명, 확률, 배분, 게임 흐름을 대조한다. 이미지의 **실제 게시자와 실제 수집 출처**도 따로 기록한다. 리제로 현재 화면은 최초 이미지가 아니라 이후 교체한 대도기연 자료를 사용한다.
3. 기기 외관 1장, RUSH 대표 화면 1장, 일본어 스펙·플로우·보너스·RUSH 설명 원본을 고른다. 이미지가 여러 조각이면 읽는 순서대로 합성하거나 갤러리 여러 항목으로 둔다. 원본의 수치·로고·게임 화면은 번역 과정에서 임의로 바꾸지 않는다.
4. 이미지별 이용 조건과 공개 범위를 확인한다. 이미지 이용 방침은 프로젝트 오너의 결정에 따르며, 권리자의 요청이 있으면 해당 이미지를 즉시 제거한다. 배포는 그때마다 오너 승인을 받는다.

### A.3 PhotoCraft 한국어 번역 이미지

1. 확인한 원본을 새 기종 이미지 폴더에 `basic-source.jpg`, `flow-source.png`처럼 `*-source.*`로 보존한다. 사이트용 크롭·형식 변환본과 한국어 번역본은 각각 별도 파일로 둔다. 확장자와 실제 파일 형식은 일치시킨다.
2. 원본에 적힌 일본어 핵심 안내를 항목별로 짧게 번역한다. 확률, ST 회전 수, RUSH 진입·계속률, 당첨 배분을 JSON 데이터와 대조한다.
3. `scripts/render-korean-official-images.sh`(또는 위 기준 스크립트)를 새 기종 이름으로 복사해 입력 이미지, 출력 경로, 패널 좌표, 한국어 문구를 바꾼다. PhotoCraft CLI의 `shape.create`로 반투명 패널, `type.create`로 한국어 문구를 얹는다. 리제로 스크립트는 `basic.jpg` → `basic-ko.png`, `gameflow.jpg` → `gameflow-ko.png`, `bonus.jpg` → `bonus-ko.png`, `rush-st.jpg` → `rush-st-ko.png`를 만든다.
4. 원본의 주요 그림·얼굴·로고·수치·화살표를 가리지 않게 패널을 배치한다. 작은 장식 문구까지 모두 번역하기보다 플레이 흐름을 이해하는 데 필요한 문구를 우선한다.
5. PhotoCraft의 `image.imageSize`로 번역 갤러리의 표시 폭을 맞춘다. 리제로 기준 기본 정보는 1200×806, 나머지 세 장은 1200×771 PNG다. 새 기종은 원본 비율을 유지하며 필요한 크기를 정한다(오키나와 6 계열은 1200×849).
6. 번역본의 제목·수치·게임 흐름을 원본과 나란히 검수하고 스크립트를 남겨 재생성 가능하게 한다. 번역 이미지를 JSON의 `visualGuide.translatedImages`에 **기본 정보 → 게임 플로우 → 보너스 → RUSH** 순으로 연결한다. 기종에 해당 단계가 없으면 억지로 채우지 않는다.

### A.4 리제로와 같은 상세페이지 레이아웃

공통 렌더러 `visualGameFlow()`가 `visualGuide.mainImage`, `steps`, `flowDiagram`을 읽는다. 이 세 항목이 없으면 시각 가이드 전체가 표시되지 않는다. 화면은 다음 순서로 구성된다.

| 순서 | 화면 구성 | 채울 데이터 |
|---|---|---|
| 1 | 기종명·제조사·출시일·형식과 핵심 스펙 | 기종 JSON의 기본 필드 |
| 2 | `게임 플로우 한눈에 보기`: 기기 이미지와 핵심 숫자 3개 | `visualGuide.mainImage`, `keyStats` |
| 3 | 통상시 → 초당첨 결과 카드 → RUSH → RUSH 결과 카드와 복귀 화살표 | `visualGuide.flowDiagram`; 결과 비율·경로·색상 톤을 실제 기종에 맞춤 |
| 4 | 일본어 원본의 한국어 번역 이미지 갤러리 | `visualGuide.translatedImages`; 가장 포괄적인 기본 정보나 전체 플로우를 첫 장에 배치 |
| 5 | 초기 당첨·RUSH 배분 원그래프 | `payouts.initial`, `payouts.rush`, 필요 시 `distributionCharts` |
| 6 | 텍스트 플레이 흐름·배분표·출처·검수 상태·AI 질문 | `gameFlow`, `payouts`, `sources`, `verification` 및 공통 렌더러 |

기기 이미지 옆에는 `keyStats` 3개를 둔다. 새 기종의 숫자를 그대로 복사하지 말고 `probabilities`·`rush`·`payouts`와 일치시킨다. 분기 카드의 `tone`은 `return`, `rush`, `premium`, `reset` 중에서 실제 결과에 맞게 고른다. 당첨 배분 합계와 원그래프 범례가 일치해야 한다.

데스크톱은 분기 카드를 가로로 비교하고 **640px 이하에서는 세로 한 열**로 읽는다. 긴 일본어 명칭, 비율, 이미지 캡션이 잘리지 않는지 두 폭에서 확인한다. 기기 이미지는 세로형, RUSH 이미지는 4:3 또는 16:9를 권장하며 CSS로 원본 비율을 깨지 않는다. 새 기종마다 별도 HTML·CSS를 만들지 않는다.

현재 공통 UI의 갤러리 제목과 출처 문구는 **공식 이미지**를 전제로 한다. 전문 매체 이미지를 내부 검토에 쓰더라도 공식 이미지라고 표기하지 않는다.

## 부록 B. 슬롯 기종 추가 요령

슬롯은 `machineType: "slot"`이고 `settings`(설정 1~6의 CZ 합산·AT 초당첨·기계할), `slot`(순증·베이스·천장), `analysis`(비공식 해석)를 쓴다. 기준 구현은 `l-tokyo-ghoul`, 최근 예시는 `l-lycoris-recoil`·`l-ragnador`·`l-kabaneri-umito`. 규격은 [디자인 시스템](machine-detail-design-system.md) 참조.

1. **p-town 기종 페이지를 끝까지 읽는다.** 슬롯은 설정별 CZ·AT·기계할 표가 없는 경우가 많다(기계할은 범위만, 설정별 값은 개별 항목 표). 요약이 "記載なし"라고 해도 본문에 천장·설정 판별이 있다.
2. **설정별 표는 분석 사이트 2곳 이상을 직접 읽어 교차 확인한다.** 후보: なな徹(`nana-press.com/kaiseki/machine/<번호>/`의 스펙 정보 페이지), 1geki.jp, パチセブン, ちょんぼりすた. 검색 요약의 숫자는 근거로 쓰지 않는다. 사이트 간 값이 다르면 다수결로 정하되 `notes`에 차이를 적는다(예: 라그나도르 설정6 AT 1/258.3 vs 1/256.3). p-town의 기계할 범위(최소·최대)와 양끝이 일치하는지 확인한다.
3. **공개 값이 없는 열은 추측하지 않고 `"—"`로 둔다.** 이 경우 `slot.settingsPrimaryLabel`로 열 제목에 "(미공개)"를 표시하고(`CZ 합산 (미공개)`), `slot.czEntry`에 "자료 없음"을 적는다. `czProbability`가 `"—"`이면 `CZ까지 투자` 계산은 자동으로 `—`가 된다. 정의가 불명확한 값(예: 카바네리의 '初当り')은 설정 표에 넣지 말고 `analysis` 표에 따로 둔다.
4. **P-WORLD 사진 ID 찾기**: 기종 페이지 제목은 UTF-8이므로 `iconv` 없이 읽는다. 범위 스캔 예: `seq 10381 2 10545 | xargs -P 12 -I{} sh -c 't=$(curl -sL -m 12 -A "$UA" "https://www.p-world.co.jp/machine/database/{}" | grep -oE "<title>[^<]*" | head -1 | cut -c8-60); echo "{} $t"'` 후 기종명으로 grep. 사진은 슬롯도 `scripts/fetch-pworld-machine-photo.py`로 받는다(폴더를 먼저 만든다). `zsh`에서는 `set -- $var`가 단어 분리를 하지 않으므로 배열을 쓴다.
5. `keyStats` 값은 짧게 쓴다(`6.0매/G` + 라벨 `순증(약)`). 값이 길면 핵심 숫자 카드에서 줄바꿈된다.
6. 공식 스펙 이미지를 구하지 못하면 `translatedImages: []`로 두고 `steps`를 채운다(텍스트 "게임 진행 단계" 카드로 표시). 원그래프(`distributionCharts`)는 배분 데이터가 없으므로 `[]`.
7. `slots/index.json`의 `machines` 맨 위에 등록하고 `updatedAt`을 갱신한다. 썸네일은 `scripts/make-card-thumbs.py`.
