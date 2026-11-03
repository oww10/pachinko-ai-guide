# 파치스펙 AI — 정적 프로토타입

일본 파칭코 기종 정보를 한국어로 탐색하는 정적 웹 프로토타입입니다.

## 로컬 실행

```sh
python3 -m http.server 4173 --directory dist
```

브라우저에서 `http://127.0.0.1:4173`을 엽니다. 파일을 직접 열면 브라우저의 `fetch` 제한 때문에 JSON을 불러올 수 없습니다.

공개 사이트: `https://oww10.github.io/pachinko-ai-guide/`

## 현재 범위

- 10개 파칭코 기종 목록
- 한국어·일본어·제조사 검색
- 연도·검증 상태 필터
- 스펙, RUSH, 배분, 출처 상세 보기
- DB와 서버 런타임 없음
- 기종별 Gemini 질문 UI와 연결 전 테스트 응답
- Gemini API 키를 숨기는 Cloudflare Worker 소스

## Gemini 연결 구조

- 모델: `gemini-3.5-flash-lite`
- 프런트엔드: `dist/`
- 보안 프록시: `worker/`
- API 키는 브라우저나 Git에 넣지 않고 Cloudflare Worker의 `GEMINI_API_KEY` Secret으로만 등록합니다.
- 별도 DB는 사용하지 않습니다.
- 무료 등급 요청은 Google 제품 개선에 사용될 수 있습니다.

현재 `dist/assets/config.js`는 안전한 `mock` 모드입니다. Worker를 배포한 뒤에만 아래처럼 엔드포인트를 설정합니다.

```js
window.PACHI_AI_CONFIG = Object.freeze({
  mode: "live",
  endpoint: "https://YOUR-WORKER.workers.dev/api/ask"
});
```

프로덕션 배포 전 `worker/wrangler.jsonc`의 `ALLOWED_ORIGIN`을 실제 사이트 주소로 교체해야 합니다.

## 로컬 검사

```sh
node --check dist/assets/app.js
cd worker
npm test
npm run check
```

실제 API 키 등록과 Worker 배포는 별도 승인 단계입니다. 키를 채팅, 소스 파일, `.env`, 커밋에 입력하지 않습니다.
