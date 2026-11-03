# 기종 상세 화면 디자인 시스템

이 문서는 리제로 오니가카리 2 상세 화면을 기준으로 다른 기종에도 같은 정보 구조와 시각 디자인을 적용하기 위한 제작 규칙이다. 기준 구현은 `dist/data/pachinko/e-rezero-onigakari-2.json`이며, 새 기종은 JavaScript나 CSS를 수정하지 않고 기종 JSON과 이미지 자산만 추가하는 것을 원칙으로 한다.

## 1. 상세 화면의 고정 순서

모든 기종 상세 화면은 아래 순서를 유지한다.

1. 기종명, 제조사, 출시일, 형식 배지
2. 핵심 스펙
3. **게임 플로우 한눈에 보기**
   - 기기 외관과 핵심 수치 3개
   - 통상시 → 초당첨 결과 → RUSH → RUSH 중 결과 분기
   - 공식 이미지의 한국어 핵심 번역본
   - 초기 당첨 및 RUSH 배분 원그래프
4. 텍스트 플레이 흐름
5. 배분표
6. 확인 출처와 검수 상태
7. 해당 기종 AI 질문 버튼

데스크톱에서는 분기를 가로로 비교하고, 640px 이하에서는 한 열의 세로 흐름으로 자동 전환한다. 모바일용 별도 마크업을 만들지 않는다.

## 2. 파일 배치 규칙

기종 ID는 영문 소문자 kebab-case로 통일한다.

```text
dist/
├── data/pachinko/
│   ├── index.json
│   └── <machine-id>.json
└── assets/images/official/<asset-folder>/
    ├── machine.png
    ├── rush-screen.png
    ├── basic.jpg
    ├── gameflow.jpg
    ├── bonus.jpg
    ├── rush-st.jpg
    ├── basic-ko.png
    ├── gameflow-ko.png
    ├── bonus-ko.png
    └── rush-st-ko.png
```

- `machine.png`: 투명 배경을 권장하는 기기 전면 이미지
- `rush-screen.png`: RUSH 카드에 사용할 대표 플레이 화면
- 원본 JPG: 공식 사이트에서 보존한 원본
- `*-ko.png`: 원본을 덮어쓰지 않고 별도로 만든 한국어 핵심 번역 오버레이
- 브라우저에서 확장자와 실제 포맷이 달라지지 않게 한다. WebP 파일의 이름만 `.png`로 바꾸면 안 된다.

현재 기준 크기는 기기 이미지 400×619px, RUSH 이미지 400×300px, 번역 이미지 가로 1200px이다. 정확히 같은 크기는 필수가 아니지만 기기 이미지는 세로형, RUSH 이미지는 4:3 또는 16:9, 번역 이미지는 가로 1200px 이상을 권장한다.

## 3. 데이터 계약

새 기종은 기존 기종 JSON을 복사한 뒤 기본 스펙과 `visualGuide`를 교체한다. 시작용 구조는 [`templates/machine-detail-visual-guide.template.json`](templates/machine-detail-visual-guide.template.json)에 있다.

### `keyStats`

기기 이미지 옆에 표시하는 핵심 수치다. 정확히 3개를 권장한다.

```json
"keyStats": [
  { "value": "1/349.9", "label": "통상시 대당첨" },
  { "value": "55%", "label": "RUSH 진입" },
  { "value": "77%", "label": "RUSH 계속률" }
]
```

### `flowDiagram`

게임 분기 다이어그램을 만드는 데이터다. `initialOutcomes`와 `rushOutcomes`의 항목 수에 맞춰 데스크톱 열 수가 자동 조정된다.

각 결과의 `tone`은 아래 값만 사용한다.

| 값 | 용도 | 표시색 |
|---|---|---|
| `return` | 통상 복귀, 실패 경로 | 노랑 |
| `rush` | RUSH 진입 또는 계속 | 청록 |
| `premium` | 최상위 보너스 | 보라 |
| `reset` | ST 리셋, 재시작 | 초록 |

설명이 두 줄이어야 하면 `description`에 `\n`을 넣는다. 화살표는 `route`에 `↩`, `↻` 같은 문자로 표시할 수 있다.

### 이미지 객체

`mainImage`는 필수이고 `rushScreen`은 권장한다. 모든 이미지에는 화면 낭독용 `alt`를 작성한다.

```json
"mainImage": {
  "url": "./assets/images/official/<folder>/machine.png",
  "alt": "제조사와 기종명을 포함한 기기 외관 설명",
  "caption": "기기 외관",
  "credit": "제조사 공식 제품 사이트",
  "sourceUrl": "https://공식-제품-페이지"
}
```

`translatedImages`는 공식 이미지의 한국어 번역 갤러리다. 첫 항목은 데스크톱에서 두 열 전체 폭으로 표시된다. 가장 포괄적인 기본 정보 또는 전체 플로우 이미지를 첫 번째에 둔다.

`steps`는 번역 이미지가 없을 때 갤러리 대체 데이터로도 쓰이므로 유지한다. 단계는 통상시, 초당첨 판정, RUSH 순으로 3개를 권장한다.

### 다단계 RUSH 기종

상위 RUSH와 일반 RUSH를 오가는 기종은 `flowDiagram.secondaryRush`, `secondaryOutcomes`를 추가한다. 이 필드가 있으면 첫 번째 RUSH 결과 아래에 두 번째 RUSH 상태와 분기가 자동으로 표시된다.

배분 원그래프가 3개 이상이면 `payouts`에 `climax` 같은 기종별 배열을 추가하고 `visualGuide.distributionCharts`로 표시 순서를 지정한다.

```json
"distributionCharts": [
  { "title": "초기 당첨 배분", "source": "initial", "centerValue": "52%", "centerLabel": "CLIMAX 진입" },
  { "title": "CLIMAX 중 배분", "source": "climax", "centerValue": "51%", "centerLabel": "4500개" },
  { "title": "일반 RUSH 중 배분", "source": "rush", "centerValue": "50%", "centerLabel": "CLIMAX 승격" }
]
```

### 수치 연결 규칙

- 원그래프는 `payouts.initial`과 `payouts.rush`를 그대로 사용한다.
- 각 배분 배열의 `ratePercent` 합계는 원칙적으로 100이어야 한다.
- 초기 원그래프 중앙값은 `rush.totalEntryRatePercent`, 없으면 `rush.entryRatePercent`를 사용한다.
- RUSH 원그래프 중앙은 가장 큰 `payoutBalls` 항목과 그 비율을 사용한다.
- 공식 수치와 보조 매체 수치가 다르면 임의로 확정하지 말고 `verification.needsReviewFields`에 남긴다.

## 4. 공식 이미지 번역 규칙

한국어 이미지는 원본의 수치, 인물, 로고, 게임 화면을 변형하지 않고 이해에 필요한 일본어 핵심 안내만 반투명 패널로 덧입힌다.

- 원본은 그대로 보존하고 결과는 `*-ko.png`로 출력한다.
- 번역은 직역보다 짧고 명확한 한국어를 우선한다.
- 작은 장식 문구나 게임 화면 속 UI까지 전부 교체하려 하지 않는다.
- 공식 제작물임을 오해하지 않도록 상세 화면에 “한국어 번역본”과 원본 링크를 함께 표시한다.
- `credit`, `sourceUrl`, `sources`에 제조사와 원본 페이지를 반드시 기록한다.

현재 PhotoCraft CLI 재현 스크립트는 `scripts/render-korean-official-images.sh`이다. 리제로 전용 좌표와 문구가 들어 있으므로 새 기종에서는 복사본을 만들고 입력 파일, 패널 좌표, 번역 문구, 출력 경로를 바꾼다.

```sh
/Users/oww/.local/bin/photocraft-cli --version
PHOTOCRAFT_CLI=/Users/oww/.local/bin/photocraft-cli \
  ./scripts/render-korean-official-images.sh
```

주요 PhotoCraft 명령은 `shape.create`(번역 패널), `type.create`(한국어 문구), `image.imageSize`(최종 크기 통일)이다.

## 5. 새 기종 추가 절차

1. 공식 제품 페이지와 검증 가능한 보조 출처를 확보한다.
2. 기존 JSON을 `<machine-id>.json`으로 복사하고 기본 스펙, 배분, 출처를 수정한다.
3. `visualGuide`를 템플릿에 맞게 작성한다.
4. 공식 이미지를 `dist/assets/images/official/<asset-folder>/`에 저장한다.
5. PhotoCraft로 한국어 핵심 번역 이미지를 별도 생성한다.
6. `dist/data/pachinko/index.json`의 `machines` 배열에 새 파일을 추가한다.
7. 아래 자동 검사와 수동 화면 검수를 수행한다.

## 6. 검수 체크리스트

### 데이터

- [ ] 기종 ID와 JSON 파일명이 일치한다.
- [ ] 출시일, 확률, 진입률, 계속률, ST 회전 수를 출처와 대조했다.
- [ ] 초기 당첨 배분과 RUSH 배분의 각 합계가 100이다.
- [ ] 게임 플로우와 배분표가 서로 모순되지 않는다.
- [ ] 공식 출처와 확인일이 기록되어 있다.

### 이미지와 문구

- [ ] 모든 로컬 이미지 경로가 열리고 실제 파일 포맷과 확장자가 같다.
- [ ] 모든 이미지에 의미 있는 `alt`가 있다.
- [ ] 원본과 한국어 번역본을 모두 보존했다.
- [ ] 번역 패널이 중요한 수치, 얼굴, 게임 화면을 가리지 않는다.
- [ ] 제조사 크레딧과 원본 링크가 표시된다.

### 화면

- [ ] 데스크톱에서 분기 카드가 한 행에 정렬된다.
- [ ] 모바일에서 분기가 읽는 순서대로 한 열에 정렬된다.
- [ ] 긴 기종명, 일본어, 숫자가 잘리거나 겹치지 않는다.
- [ ] 원그래프 범례와 배분표의 비율이 같다.
- [ ] 이미지 링크, 출처 링크, AI 질문 버튼이 동작한다.
- [ ] 키보드 포커스와 화면 낭독용 라벨이 있다.

## 7. 자동 검사

```sh
jq empty dist/data/pachinko/index.json dist/data/pachinko/<machine-id>.json
node --check dist/assets/app.js
git diff --check

cd worker
npm test
npm run check
```

로컬 확인은 저장소 루트에서 다음과 같이 실행한다.

```sh
python3 -m http.server 4173 --directory dist
```

`http://127.0.0.1:4173/?machine=<machine-id>`로 직접 들어가 데스크톱과 모바일 폭을 모두 확인한다.

## 8. 변경 금지 원칙

- 기종마다 별도 HTML 또는 CSS를 만들지 않는다.
- 공식 이미지를 외부 URL로 직접 연결하지 않는다.
- 근거 없는 확률이나 배분을 채우지 않는다.
- 원본 이미지를 한국어 번역본으로 덮어쓰지 않는다.
- 새 기종 하나 때문에 공통 컴포넌트의 순서나 색 체계를 임의로 바꾸지 않는다.

공통 디자인을 바꿔야 한다면 먼저 리제로 기준 화면과 새 기종 화면을 함께 비교해, 모든 기종에 유효한 변경인지 확인한 뒤 `dist/assets/app.js`와 `dist/assets/styles.css`를 한 번만 수정한다.
