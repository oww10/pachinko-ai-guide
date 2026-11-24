# 파치스펙 AI 운영·인수인계

마지막 확인: 2026-11-09

## 1. 운영 현황

- 공개 URL: <https://oww10.github.io/pachinko-ai-guide/>
- GitHub 저장소: <https://github.com/oww10/pachinko-ai-guide>
- 기본 브랜치: `main`
- 배포 방식: `main` 푸시 → GitHub Actions → GitHub Pages
- Worker: `pachinko-ai-gemini`
- Worker URL: `https://pachinko-ai-gemini.pachinko-ai-gemini-worker.workers.dev`
- 데이터: 파칭코 10기종, 슬롯 3기종
- DB: 사용하지 않음

## 2. 구조

```text
dist/                         GitHub Pages에 그대로 배포되는 정적 사이트
├── assets/                   CSS, JavaScript, 설정, 이미지
└── data/
    ├── pachinko/             파칭코 기종 JSON과 index.json
    └── slots/                슬롯 기종 JSON과 index.json
docs/                         디자인 시스템과 운영 문서
scripts/                      PhotoCraft 이미지 재생성 스크립트
worker/                       Gemini 보안 프록시 Cloudflare Worker
.github/workflows/            GitHub Pages 자동 배포
```

브라우저는 기종 `index.json`을 읽고 개별 JSON을 필요할 때 가져옵니다. 질문 시에는 선택한 기종의 허용 필드와 질문만 Worker에 보내며, Worker가 입력을 정제한 뒤 Gemini를 호출합니다.

## 3. 새 기종 제작 절차

### 데이터

1. 공식 제품명, 제조사, 도입일, 기본 확률과 게임 흐름을 공식 자료로 확인합니다.
2. 파칭코는 `dist/data/pachinko/`, 슬롯은 `dist/data/slots/`에 `{machine-id}.json`을 만듭니다.
3. 해당 `index.json`의 `machines` 배열에 ID를 추가합니다.
4. 상세 시각화는 [`machine-detail-design-system.md`](machine-detail-design-system.md)를 따릅니다.
5. 모든 외부 정보는 JSON의 `sources`에 공식/보조 출처를 구분해 기록합니다.

다음 기종의 실제 작업 순서와 리제로 기준 레이아웃·PhotoCraft 번역 단계는 [`machine-detail-production-playbook.md`](machine-detail-production-playbook.md)에 정리했습니다.

### 이미지

- 리제로 2 최초 제작 때 사용한 전문 매체 이미지와 이후 공식 자료 교체 이력, 다음 기종의 이미지별 출처 기록 방식은 [`image-sourcing-workflow.md`](image-sourcing-workflow.md)를 따릅니다.
- 원본과 결과물은 `dist/assets/images/official/{machine-id}/`에 함께 둡니다.
- 원본은 `*-source.*`, 사이트용 결과는 의미가 드러나는 파일명으로 구분합니다.
- 일본어 안내를 한국어로 덧씌운 이미지는 PhotoCraft CLI 스크립트를 `scripts/`에 남겨 재생성 가능하게 합니다.
- PNG가 현재 브라우저·배포 환경에서 가장 안정적으로 확인됐습니다.
- 공식 사이트에 공개된 이미지도 자유 이용이 자동 보장되지는 않습니다. 공개 전 제조사 이용약관, 보도자료 사용 조건, 출처 표기 필요 여부를 별도로 확인합니다.
- 원문의 로고·캐릭터·게임 화면을 수정해 자체 저작물처럼 표시하지 않습니다.

### 구현 원칙

- 새 기종 때문에 공통 JavaScript나 CSS를 수정하기보다 JSON의 `visualGuide`로 표현합니다.
- 파칭코와 슬롯의 용어를 혼용하지 않습니다. 예: 슬롯의 BONUS/CZ/AT와 파칭코의 초당/RUSH.
- 수치가 공식 확인되지 않은 필드는 추정값으로 채우지 않고 `null` 또는 설명 문구로 남깁니다.

## 4. 로컬 확인

```sh
python3 -m http.server 4173 --directory dist
```

`http://127.0.0.1:4173`에서 확인합니다. 파일을 직접 열면 `fetch` 제한으로 JSON 로딩이 실패합니다.

```sh
node --check dist/assets/app.js
find dist/data -name '*.json' -print0 | xargs -0 -n1 jq empty
cd worker
npm test
npm run check
```

모바일에서는 최소한 다음을 확인합니다.

- 기종 목록과 상세 dialog의 스크롤
- 게임 플로우 이미지의 가독성
- AI 질문 입력 시 iOS Safari와 인앱 브라우저의 자동 확대 여부
- 한국어·일본어 검색
- AI 정상 응답과 한도 초과·오류 메시지

## 5. 배포

### 정적 사이트

`main`에 푸시하면 `.github/workflows/deploy-pages.yml`이 `dist/`를 GitHub Pages에 배포합니다.

```sh
git add README.md docs/ dist/ scripts/ worker/
git commit -m "Describe the change"
git push origin main
```

Actions 성공 후 공개 URL에서 변경된 캐시 버전, JSON, 대표 이미지를 확인합니다.

### Worker

Worker 코드를 바꾸었을 때만 별도로 배포합니다.

```sh
cd worker
npm test
npm run check
npx wrangler deploy
```

API 키를 교체할 때는 터미널에서 아래 명령을 실행하고 프롬프트에 직접 입력합니다.

```sh
npx wrangler secret put GEMINI_API_KEY
```

키는 문서, 채팅, 셸 기록에 값이 드러나는 인자, Git 파일에 남기지 않습니다.

## 6. 장애 확인

### 기종이 보이지 않음

- 종류별 `index.json`에 ID가 있는지 확인
- ID와 JSON 파일명이 같은지 확인
- JSON 문법 검사
- 브라우저 개발자 도구에서 404 확인

### 이미지가 보이지 않음

- JSON 경로가 `./assets/...` 형식인지 확인
- 대소문자와 확장자 확인
- GitHub Pages의 실제 이미지 URL이 200인지 확인
- WebP 문제가 재현되면 PNG로 변환하고 JSON 참조도 함께 바꿈

### Gemini가 응답하지 않음

- `dist/assets/config.js`가 `live`이고 Worker `/api/ask`를 가리키는지 확인
- Worker의 `ALLOWED_ORIGIN`에 현재 사이트 Origin이 있는지 확인
- `GEMINI_API_KEY` Secret 존재 여부 확인
- 429는 무료 등급 한도, 503은 인증/설정, 502는 상류 응답 실패 가능성을 우선 확인
- Worker 로그에 질문 전문이나 API 키를 추가로 출력하지 않음

## 7. 현재 남은 운영 과제

- 모든 공식 이미지의 공개 사용 조건과 출처 표기 방식 재점검
- 새 기종 추가 전 수치 검증 체크리스트 적용
- Gemini 무료 등급의 모델명·한도·데이터 사용 정책이 바뀌는지 정기 확인
- 사용자 증가 시 Worker 남용 방지를 위한 사용량 제한 또는 Turnstile 검토
- 서비스 명칭, 면책 문구, 개인정보 처리 안내의 공개용 최종 검수

## 8. 기준 구현

- 파칭코 상세: `e-rezero-onigakari-2`
- 파칭코 시각화 확장: `e-fever-gundam-seed-climax`, `e-tokyo-ghoul-super-deka-cho-ichigeki`, `e-lycoris-recoil`
- 슬롯 상세: `l-tokyo-ghoul`
- 슬롯 전체 흐름·한국어 이미지: `l-godzilla-vs-evangelion-2`
