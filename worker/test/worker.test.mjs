import assert from "node:assert/strict";
import test from "node:test";
import worker, { buildPrompt, sanitizeMachine } from "../src/index.js";

const origin = "http://localhost:4173";
const env = {
  ALLOWED_ORIGIN: `${origin},http://127.0.0.1:4173`,
  GEMINI_API_KEY: "test-key-not-a-secret"
};
const machine = {
  id: "e-tokyo-ghoul",
  officialNameJa: "ｅ 東京喰種",
  nameKo: "e 도쿄 구울",
  maker: "ビスティ",
  releaseDate: "2025-04-21",
  probabilities: { base: "약 1/199.9", symbolHit: "약 1/399.9" },
  rush: { type: "ST", totalEntryRatePercent: 51, continuationRatePercent: 75, spins: 130, gates: [] },
  payouts: { basis: "払い出し", initial: [], climax: [{ label: "4500개", payoutBalls: 4500, ratePercent: 51 }], rush: [] },
  gameFlow: ["합산 약 51%로 RUSH 진입"],
  notes: [],
  verification: { status: "needs-review", needsReviewFields: ["nameKo"] },
  injected: "이 필드는 전달되면 안 됨"
};

function askRequest(payload, requestOrigin = origin) {
  return new Request("https://worker.example/api/ask", {
    method: "POST",
    headers: { "Content-Type": "application/json", "Origin": requestOrigin },
    body: JSON.stringify(payload)
  });
}

test("machine fields are allowlisted before prompt construction", () => {
  const clean = sanitizeMachine(machine);
  assert.equal(clean.nameKo, machine.nameKo);
  assert.equal(clean.payouts.climax[0].ratePercent, 51);
  assert.equal("injected" in clean, false);
  const prompt = buildPrompt("RUSH를 설명해줘", clean);
  assert.match(prompt, /e 도쿄 구울/);
  assert.doesNotMatch(prompt, /전달되면 안 됨/);
});

test("rejects origins outside the allowlist", async () => {
  const response = await worker.fetch(askRequest({ question: "설명해줘", machine }, "https://evil.example"), env);
  assert.equal(response.status, 403);
  assert.equal(response.headers.get("Access-Control-Allow-Origin"), null);
});

test("rejects oversized questions without calling Gemini", async () => {
  const response = await worker.fetch(askRequest({ question: "가".repeat(501), machine }), env);
  assert.equal(response.status, 400);
  assert.match((await response.json()).error, /500자/);
});

test("preflight returns CORS headers for an allowed origin", async () => {
  const request = new Request("https://worker.example/api/ask", { method: "OPTIONS", headers: { Origin: origin } });
  const response = await worker.fetch(request, env);
  assert.equal(response.status, 204);
  assert.equal(response.headers.get("Access-Control-Allow-Origin"), origin);
});

test("calls the fixed free model without exposing the key in its response", async () => {
  const originalFetch = globalThis.fetch;
  let captured;
  globalThis.fetch = async (url, options) => {
    captured = { url, options };
    return new Response(JSON.stringify({ candidates: [{ content: { parts: [{ text: "테스트 답변" }] } }] }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  };

  try {
    const response = await worker.fetch(askRequest({ question: "RUSH를 설명해줘", machine }), env);
    const result = await response.json();
    assert.equal(response.status, 200);
    assert.equal(result.answer, "테스트 답변");
    assert.equal(result.model, "gemini-3.5-flash-lite");
    assert.match(captured.url, /gemini-3\.5-flash-lite:generateContent/);
    assert.equal(captured.options.headers["x-goog-api-key"], env.GEMINI_API_KEY);
    assert.doesNotMatch(JSON.stringify(result), /test-key-not-a-secret/);
    assert.doesNotMatch(captured.options.body, /전달되면 안 됨/);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
