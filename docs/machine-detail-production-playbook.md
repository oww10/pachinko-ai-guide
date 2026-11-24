# 파치스펙 AI 상세페이지 제작 플레이북

새 기종을 [리제로 오니가카리 2 상세페이지](../dist/data/pachinko/e-rezero-onigakari-2.json)와 같은 스타일로 만들 때의 작업 순서다. 화면의 세부 데이터 계약은 [디자인 시스템](machine-detail-design-system.md), 실제 이미지 수집 이력과 출처 기록은 [이미지 출처 절차](image-sourcing-workflow.md)를 따른다. 이미지 가공 도구의 정확한 이름은 **PhotoCraft**다.

## 1. 기준 화면과 파일

- 데이터 기준: `dist/data/pachinko/e-rezero-onigakari-2.json`
- 새 기종 시작 구조: `docs/templates/machine-detail-visual-guide.template.json`
- 번역 가공 기준: `scripts/render-korean-official-images.sh` — 리제로 전용 좌표·문구이므로 새 기종용 복사본을 만든다.
- 이미지 배치 기준: `dist/assets/images/official/onirezero2/` — 새 기종은 별도 폴더를 쓴다.
- 공통 렌더러와 스타일: `dist/assets/app.js`, `dist/assets/styles.css` — 기종별 제작에서는 JSON과 이미지로 내용을 채운다.

## 2. 원본 조사와 이미지 준비

1. 파치마가 같은 전문 기종 페이지에서 기기 외관, 통상시, 보너스·초당첨, RUSH, 스펙·게임 플로우 이미지 후보를 찾는다. 리제로 최초 화면은 이 방식으로 パチマガスロマガFREE 이미지 네 개를 직접 참조했다. 발견 페이지와 이미지 직접 URL을 각각 기록한다.
2. 제조사 공식 자료에서 제품명, 확률, 배분, 게임 흐름을 대조한다. 이미지의 **실제 게시자와 실제 수집 출처**도 따로 기록한다. 리제로 현재 화면은 최초 이미지가 아니라 이후 교체한 대도기연 자료를 사용한다.
3. 기기 외관 1장, RUSH 대표 화면 1장, 일본어 스펙·플로우·보너스·RUSH 설명 원본을 고른다. 이미지가 여러 조각이면 읽는 순서대로 합성할지, 갤러리 여러 항목으로 둘지 정한다. 원본의 수치·로고·게임 화면은 번역 과정에서 임의로 바꾸지 않는다.
4. 이미지별 이용 조건과 공개 범위를 확인한다. 이미지 이용 방침은 프로젝트 오너의 결정에 따르며, 권리자의 요청이 있으면 해당 이미지를 즉시 제거한다. 배포는 그때마다 오너 승인을 받는다.

## 3. PhotoCraft 한국어 번역 이미지

1. 확인한 원본을 새 기종 이미지 폴더에 원본 파일로 보존한다. `basic-source.jpg`, `flow-source.png`처럼 `*-source.*`를 권장한다. 사이트용 크롭·형식 변환본과 한국어 번역본은 각각 별도 파일로 둔다. 확장자와 실제 파일 형식은 일치시킨다.
2. 원본에 적힌 일본어 핵심 안내를 항목별로 짧게 번역한다. 확률, ST 회전 수, RUSH 진입·계속률, 당첨 배분을 JSON 데이터와 대조한다. 숫자나 결과 경로가 맞지 않으면 이미지 작업 전에 출처를 다시 확인한다.
3. `scripts/render-korean-official-images.sh`를 새 기종 이름으로 복사해 입력 이미지, 출력 경로, 패널 좌표, 한국어 문구를 바꾼다. **PhotoCraft CLI의 `shape.create`로 반투명 패널**, `type.create`로 한국어 문구를 얹는다. 리제로 스크립트는 `basic.jpg` → `basic-ko.png`, `gameflow.jpg` → `gameflow-ko.png`, `bonus.jpg` → `bonus-ko.png`, `rush-st.jpg` → `rush-st-ko.png`를 만든다.
4. 원본의 주요 그림·얼굴·로고·수치·화살표를 가리지 않게 패널을 배치한다. 작은 장식 문구까지 모두 번역하기보다 플레이 흐름을 이해하는 데 필요한 문구를 우선한다. 원문이 투명 영역에 남아 대비가 바뀔 때 드러나는지도 확인한다.
5. PhotoCraft의 `image.imageSize`로 번역 갤러리의 표시 폭을 맞춘다. 리제로 기준 기본 정보는 1200×806, 나머지 세 장은 1200×771 PNG다. 새 기종은 원본 비율을 유지하며 필요한 크기를 정한다. 번역 결과가 원본을 덮어쓰지 않았는지 확인한다.
6. 번역본의 제목·수치·게임 흐름을 원본과 나란히 검수하고 스크립트를 남겨 재생성 가능하게 한다. 번역 이미지를 JSON의 `visualGuide.translatedImages`에 **기본 정보 → 게임 플로우 → 보너스 → RUSH** 순으로 연결한다. 기종에 해당 단계가 없으면 억지로 채우지 않는다.

## 4. 리제로와 같은 상세페이지 레이아웃

공통 렌더러 `visualGameFlow()`가 `visualGuide.mainImage`, `steps`, `flowDiagram`을 읽는다. 이 세 항목이 없으면 시각 가이드 전체가 표시되지 않는다. 화면은 다음 순서로 구성된다.

| 순서 | 화면 구성 | 채울 데이터 |
|---|---|---|
| 1 | 기종명·제조사·출시일·형식과 핵심 스펙 | 기종 JSON의 기본 필드 |
| 2 | `게임 플로우 한눈에 보기`: 기기 이미지와 핵심 숫자 3개 | `visualGuide.mainImage`, `keyStats` |
| 3 | 통상시 → 초당첨 결과 카드 → RUSH → RUSH 결과 카드와 복귀 화살표 | `visualGuide.flowDiagram`; 결과 비율·경로·색상 톤을 실제 기종에 맞춤 |
| 4 | 일본어 원본의 한국어 번역 이미지 갤러리 | `visualGuide.translatedImages`; 가장 포괄적인 기본 정보나 전체 플로우를 첫 장에 배치 |
| 5 | 초기 당첨·RUSH 배분 원그래프 | `payouts.initial`, `payouts.rush`, 필요 시 `distributionCharts` |
| 6 | 텍스트 플레이 흐름·배분표·출처·검수 상태·AI 질문 | `gameFlow`, `payouts`, `sources`, `verification` 및 공통 렌더러 |

기기 이미지 옆에는 `keyStats` 3개를 둔다. 리제로는 통상시 대당첨 `1/349.9`, RUSH 진입 `55%`, 계속률 `77%`다. 새 기종의 숫자를 그대로 복사하지 말고 `probabilities`·`rush`·`payouts`와 일치시킨다. 분기 카드의 `tone`은 `return`, `rush`, `premium`, `reset` 중에서 실제 결과에 맞게 고른다. 당첨 배분 합계와 원그래프 범례가 일치해야 한다.

데스크톱은 분기 카드를 가로로 비교하고 **640px 이하에서는 세로 한 열**로 읽는다. 긴 일본어 명칭, 비율, 이미지 캡션이 잘리지 않는지 두 폭에서 확인한다. 기기 이미지는 세로형, RUSH 이미지는 4:3 또는 16:9를 권장하며 CSS로 원본 비율을 깨지 않는다. 새 기종마다 별도 HTML·CSS를 만들지 않는다.

현재 공통 UI의 갤러리 제목과 출처 문구는 **공식 이미지**를 전제로 한다. 전문 매체 이미지를 내부 검토에 쓰더라도 공식 이미지라고 표기하지 않는다. 실제 게시자·원저작권자와 화면 문구가 다를 경우, 공개 화면에 연결하기 전에 출처 표시 방식을 해결한다.

## 5. 연결·검수·인계

1. 새 기종 JSON에 `visualGuide`와 `sources`, `verification`을 넣고 파칭코면 `dist/data/pachinko/index.json`, 슬롯이면 `dist/data/slots/index.json`에 ID를 추가한다. `mainImage.credit`·`sourceUrl`은 **현재 화면에 표시하는 이미지의 실제 출처**와 맞춘다. 최초 발견 출처는 별도 이미지 조사 기록에 남긴다.
2. `jq empty`로 JSON 문법을 확인하고 `node --check dist/assets/app.js`를 실행한다. 이미지 파일 경로, 실제 형식, `alt`, 번역 스크립트의 입력·출력 파일을 확인한다.
3. 저장소 루트에서 `python3 -m http.server 4173 --directory dist`를 실행해 `http://127.0.0.1:4173/?machine=<machine-id>`를 연다. 데스크톱과 모바일에서 기기 이미지, 세 숫자, 분기, 번역 갤러리, 원그래프, 출처 링크, 스크롤을 확인한다.
4. 변경 파일과 이미지 출처·이용 조건을 인계에 남긴다. 공개 관련 결정은 [프로젝트 인수인계](project-handoff.md)와 최신 재개 기록을 따른다.

**새 기종 완료 기준:** 리제로와 같은 정보 순서와 화면 구조가 유지되고, 일본어 원본과 한국어 번역본이 각각 보존되며, 이미지별 실제 출처·가공 스크립트·검수 결과를 다시 찾을 수 있다.
