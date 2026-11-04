const MODEL = "gemini-3.5-flash-lite";
const MAX_QUESTION_LENGTH = 500;
const MAX_BODY_BYTES = 48_000;
const GEMINI_ENDPOINT = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

const SYSTEM_INSTRUCTION = `당신은 한국어 파칭코·파치슬롯 기종 정보 도우미입니다.
제공된 구조화 데이터 안에서만 답하고, 데이터에 없는 내용은 모른다고 말하세요.
확정 수치와 needs-review 항목을 명확히 구분하세요.
당첨을 예측하거나 수익을 보장하지 말고, 사행성을 조장하지 마세요.
초보자가 이해할 수 있는 짧은 한국어로 답하세요.`;

function allowedOrigins(env) {
  return String(env.ALLOWED_ORIGIN || "")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function corsHeaders(origin, env) {
  const headers = {
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Cache-Control": "no-store",
    "Content-Type": "application/json; charset=utf-8",
    "Vary": "Origin"
  };
  if (allowedOrigins(env).includes(origin)) headers["Access-Control-Allow-Origin"] = origin;
  return headers;
}

function jsonResponse(payload, status, origin, env) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: corsHeaders(origin, env)
  });
}

export function sanitizeMachine(machine) {
  if (!machine || typeof machine !== "object") return null;
  const clean = {
    id: String(machine.id || "").slice(0, 120),
    officialNameJa: String(machine.officialNameJa || "").slice(0, 200),
    nameKo: String(machine.nameKo || "").slice(0, 200),
    maker: String(machine.maker || "").slice(0, 120),
    releaseDate: String(machine.releaseDate || "").slice(0, 20),
    machineType: String(machine.machineType || "pachinko").slice(0, 20),
    probabilities: machine.probabilities && typeof machine.probabilities === "object"
      ? Object.fromEntries(Object.entries(machine.probabilities).slice(0, 10).map(([key, value]) => [String(key).slice(0, 40), value === null ? null : String(value).slice(0, 80)]))
      : {},
    slot: machine.slot && typeof machine.slot === "object"
      ? {
          type: String(machine.slot.type || "").slice(0, 160),
          netIncrease: String(machine.slot.netIncrease || "").slice(0, 80),
          baseGames: String(machine.slot.baseGames || "").slice(0, 80),
          initialATCoins: String(machine.slot.initialATCoins || "").slice(0, 80),
          czCeiling: String(machine.slot.czCeiling || "").slice(0, 80),
          atCeiling: String(machine.slot.atCeiling || "").slice(0, 80),
          resetCeiling: String(machine.slot.resetCeiling || "").slice(0, 80)
        }
      : {},
    settings: Array.isArray(machine.settings)
      ? machine.settings.slice(0, 6).map((row) => ({
          setting: Number.isFinite(row?.setting) ? row.setting : null,
          czProbability: String(row?.czProbability || "").slice(0, 40),
          atProbability: String(row?.atProbability || "").slice(0, 40),
          payoutRate: String(row?.payoutRate || "").slice(0, 40)
        }))
      : [],
    rush: machine.rush && typeof machine.rush === "object"
      ? {
          nameJa: machine.rush.nameJa ?? null,
          type: machine.rush.type ?? null,
          entryRatePercent: machine.rush.entryRatePercent ?? null,
          totalEntryRatePercent: machine.rush.totalEntryRatePercent ?? null,
          continuationRatePercent: machine.rush.continuationRatePercent ?? null,
          spins: machine.rush.spins ?? null,
          remainingHolds: machine.rush.remainingHolds ?? null,
          timeShortSpins: machine.rush.timeShortSpins ?? null,
          gates: Array.isArray(machine.rush.gates) ? machine.rush.gates.slice(0, 8).map((value) => String(value).slice(0, 240)) : []
        }
      : {},
    payouts: {
      basis: String(machine.payouts?.basis || "").slice(0, 40),
      initial: sanitizePayouts(machine.payouts?.initial),
      climax: sanitizePayouts(machine.payouts?.climax),
      rush: sanitizePayouts(machine.payouts?.rush),
      modeB: sanitizePayouts(machine.payouts?.modeB),
      ultimateDrive: sanitizePayouts(machine.payouts?.ultimateDrive)
    },
    gameFlow: Array.isArray(machine.gameFlow) ? machine.gameFlow.slice(0, 10).map((value) => String(value).slice(0, 300)) : [],
    notes: Array.isArray(machine.notes) ? machine.notes.slice(0, 8).map((value) => String(value).slice(0, 300)) : [],
    verification: {
      status: String(machine.verification?.status || "unknown").slice(0, 40),
      needsReviewFields: Array.isArray(machine.verification?.needsReviewFields)
        ? machine.verification.needsReviewFields.slice(0, 20).map((value) => String(value).slice(0, 120))
        : []
    }
  };
  return clean.id && clean.nameKo ? clean : null;
}

function sanitizePayouts(items) {
  if (!Array.isArray(items)) return [];
  return items.slice(0, 20).map((item) => ({
    label: String(item?.label || "").slice(0, 200),
    payoutBalls: Number.isFinite(item?.payoutBalls) ? item.payoutBalls : null,
    ratePercent: Number.isFinite(item?.ratePercent) ? item.ratePercent : null,
    destination: item?.destination === null ? null : String(item?.destination || "").slice(0, 200),
    confidence: String(item?.confidence || "unknown").slice(0, 40)
  }));
}

export function buildPrompt(question, machine) {
  return `아래 기종 데이터에 근거해 사용자의 질문에 답하세요.

[기종 데이터]
${JSON.stringify(machine, null, 2)}

[사용자 질문]
${question}`;
}

function extractGeminiText(payload) {
  const parts = payload?.candidates?.[0]?.content?.parts;
  if (!Array.isArray(parts)) return "";
  return parts.map((part) => typeof part?.text === "string" ? part.text : "").join("").trim();
}

async function handleAsk(request, env, origin) {
  if (!env.GEMINI_API_KEY) {
    return jsonResponse({ error: "Gemini API 설정이 완료되지 않았습니다." }, 503, origin, env);
  }

  const contentLength = Number(request.headers.get("Content-Length") || 0);
  if (contentLength > MAX_BODY_BYTES) {
    return jsonResponse({ error: "요청 데이터가 너무 큽니다." }, 413, origin, env);
  }

  let body;
  try {
    const rawBody = await request.text();
    if (new TextEncoder().encode(rawBody).byteLength > MAX_BODY_BYTES) {
      return jsonResponse({ error: "요청 데이터가 너무 큽니다." }, 413, origin, env);
    }
    body = JSON.parse(rawBody);
  } catch {
    return jsonResponse({ error: "JSON 요청 형식이 올바르지 않습니다." }, 400, origin, env);
  }

  const question = typeof body?.question === "string" ? body.question.trim() : "";
  if (!question || question.length > MAX_QUESTION_LENGTH) {
    return jsonResponse({ error: "질문은 1자 이상 500자 이하로 입력해 주세요." }, 400, origin, env);
  }
  const machine = sanitizeMachine(body?.machine);
  if (!machine) {
    return jsonResponse({ error: "기종 정보가 올바르지 않습니다." }, 400, origin, env);
  }

  const geminiRequest = {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": env.GEMINI_API_KEY
    },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: SYSTEM_INSTRUCTION }] },
      contents: [{ role: "user", parts: [{ text: buildPrompt(question, machine) }] }],
      generationConfig: {
        temperature: 0.2,
        maxOutputTokens: 600
      }
    })
  };

  let geminiResponse;
  for (let attempt = 0; attempt < 3; attempt += 1) {
    geminiResponse = await fetch(GEMINI_ENDPOINT, geminiRequest);
    if (geminiResponse.status !== 503 || attempt === 2) break;
    await new Promise((resolve) => setTimeout(resolve, 300 * (attempt + 1)));
  }

  if (!geminiResponse.ok) {
    if (geminiResponse.status === 429) {
      return jsonResponse({ error: "무료 Gemini 사용 한도에 도달했습니다. 잠시 후 다시 시도해 주세요.", upstreamStatus: 429 }, 429, origin, env);
    }
    if (geminiResponse.status === 401 || geminiResponse.status === 403) {
      return jsonResponse({ error: "Gemini API 인증 설정을 확인해 주세요.", upstreamStatus: geminiResponse.status }, 503, origin, env);
    }
    return jsonResponse({ error: "Gemini가 응답하지 않았습니다. 잠시 후 다시 시도해 주세요.", upstreamStatus: geminiResponse.status }, 502, origin, env);
  }

  const payload = await geminiResponse.json();
  const answer = extractGeminiText(payload);
  if (!answer) {
    return jsonResponse({ error: "안전 필터 또는 빈 응답으로 답변을 만들지 못했습니다." }, 422, origin, env);
  }
  return jsonResponse({ answer, model: MODEL }, 200, origin, env);
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get("Origin") || "";
    if (!allowedOrigins(env).includes(origin)) {
      return jsonResponse({ error: "허용되지 않은 요청 출처입니다." }, 403, origin, env);
    }
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders(origin, env) });
    }
    const url = new URL(request.url);
    if (request.method !== "POST" || url.pathname !== "/api/ask") {
      return jsonResponse({ error: "지원하지 않는 요청입니다." }, 404, origin, env);
    }

    try {
      return await handleAsk(request, env, origin);
    } catch (error) {
      console.error("Gemini proxy error", error);
      return jsonResponse({ error: "일시적인 서버 오류가 발생했습니다." }, 500, origin, env);
    }
  }
};
