# 파치스펙 AI

일본 파칭코·파치슬롯 기종 정보를 한국어로 탐색하고, 선택한 기종 데이터를 바탕으로 Gemini에 질문할 수 있는 정적 웹사이트입니다.

- 공개 사이트: <https://oww10.github.io/pachinko-ai-guide/>
- 정적 프런트엔드: GitHub Pages
- AI 프록시: Cloudflare Worker
- 데이터 저장: 저장소의 JSON 파일(DB 없음)

## 로컬 실행

```sh
python3 -m http.server 4173 --directory dist
```

브라우저에서 `http://127.0.0.1:4173`을 엽니다. 파일을 직접 열면 브라우저의 `fetch` 제한 때문에 JSON을 불러올 수 없습니다.

## 기종 상세 디자인 재사용

새 기종에 현재 상세 화면의 이미지·분기 플로우·원그래프 디자인을 동일하게 적용하려면 [`docs/machine-detail-design-system.md`](docs/machine-detail-design-system.md)를 따릅니다. 복사용 `visualGuide` JSON은 [`docs/templates/machine-detail-visual-guide.template.json`](docs/templates/machine-detail-visual-guide.template.json)에 있습니다.

## 운영 범위

- 파칭코 10개와 슬롯 3개 기종 목록
- 한국어·일본어·제조사 검색
- 기종 종류·연도·검증 상태 필터
- 파칭코 RUSH·배분과 슬롯 CZ·AT·설정별 기계할 상세 보기
- 기종별 게임 플로우, 공식 이미지 기반 한국어 안내 이미지
- 기종별 Gemini 질문
- DB와 별도 애플리케이션 서버 없음

## Gemini 연결 구조

- 표시 모델: `gemini-3.5-flash-lite`
- 프런트엔드: `dist/`
- 보안 프록시: `worker/`
- API 키는 브라우저나 Git에 넣지 않고 Cloudflare Worker의 `GEMINI_API_KEY` Secret으로만 등록합니다.
- 별도 DB는 사용하지 않습니다.
- 무료 등급 요청은 Google 제품 개선에 사용될 수 있습니다.

현재 `dist/assets/config.js`는 배포된 Worker를 사용하는 `live` 모드입니다.

```js
window.PACHI_AI_CONFIG = Object.freeze({
  mode: "live",
  endpoint: "https://pachinko-ai-gemini.pachinko-ai-gemini-worker.workers.dev/api/ask"
});
```

`worker/wrangler.jsonc`의 `ALLOWED_ORIGIN`에는 로컬 미리보기와 GitHub Pages Origin만 허용합니다. 다른 도메인을 연결할 때는 이 값도 함께 갱신합니다.

## 새 기종 추가

1. `dist/data/pachinko/` 또는 `dist/data/slots/`에 기종 JSON을 추가합니다.
2. 같은 폴더의 `index.json`에 ID를 추가합니다.
3. 이미지 자산은 `dist/assets/images/official/{machine-id}/`에 둡니다.
4. 상세 화면은 [`docs/machine-detail-design-system.md`](docs/machine-detail-design-system.md)의 `visualGuide` 규칙을 사용합니다.
5. 한국어 안내 이미지가 필요하면 `scripts/`의 PhotoCraft 재생성 스크립트 패턴을 따릅니다.
6. 숫자·명칭은 공식 제조사 자료를 우선하고, 보조 출처와 구분해 JSON의 `sources`에 기록합니다.

전체 운영·배포 절차는 [`docs/project-handoff.md`](docs/project-handoff.md)를 참고합니다.

## 로컬 검사

```sh
node --check dist/assets/app.js
find dist/data -name '*.json' -print0 | xargs -0 -n1 jq empty
cd worker
npm test
npm run check
```

API 키를 채팅, 소스 파일, `.env`, 커밋에 입력하지 않습니다. Worker의 `GEMINI_API_KEY` Secret으로만 관리합니다.
