const DATA_ROOT = "./data/pachinko";
const accents = ["#42e9ff", "#ff4fd8", "#ffca62", "#8cf5ba", "#9f8cff"];
const AI_CONFIG = window.PACHI_AI_CONFIG || { mode: "mock", endpoint: "" };

const state = {
  machines: [],
  query: "",
  year: "all",
  status: "all",
  aiBusy: false,
  lastAIRequestAt: 0
};

const elements = {
  list: document.querySelector("#machine-list"),
  count: document.querySelector("#result-count"),
  search: document.querySelector("#machine-search"),
  searchForm: document.querySelector("#search-form"),
  clearSearch: document.querySelector("#clear-search"),
  empty: document.querySelector("#empty-state"),
  yearFilters: document.querySelector("#year-filters"),
  statusFilter: document.querySelector("#status-filter"),
  machineDialog: document.querySelector("#machine-dialog"),
  dialogContent: document.querySelector("#dialog-content"),
  aiDialog: document.querySelector("#ai-dialog"),
  aiMachineSelect: document.querySelector("#ai-machine-select"),
  aiMessages: document.querySelector("#ai-messages"),
  aiForm: document.querySelector("#ai-question-form"),
  aiQuestion: document.querySelector("#ai-question"),
  aiSubmit: document.querySelector("#ai-submit"),
  aiCharacterCount: document.querySelector("#ai-character-count"),
  aiError: document.querySelector("#ai-error"),
  aiModeBadge: document.querySelector("#ai-mode-badge")
};

const probabilityLabels = {
  base: "기본 확률",
  symbolHit: "도안 당첨",
  charge: "차지",
  highState: "고확률",
  rushHit: "RUSH 중"
};

const confidenceLabels = {
  official: "공식",
  "multi-source": "복수 자료",
  secondary: "전문 매체",
  "needs-review": "재확인 필요"
};

function escapeHtml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function formatDate(dateString) {
  return new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).format(new Date(`${dateString}T00:00:00`));
}

function normalize(value) {
  return String(value ?? "").normalize("NFKC").toLocaleLowerCase("ko-KR");
}

function machineSearchText(machine) {
  return normalize([
    machine.nameKo,
    machine.officialNameJa,
    machine.maker,
    machine.brand,
    ...(machine.aliases || [])
  ].join(" "));
}

function currentResults() {
  const query = normalize(state.query.trim());
  return state.machines.filter((machine) => {
    const matchesQuery = !query || machineSearchText(machine).includes(query);
    const matchesYear = state.year === "all" || machine.releaseDate.startsWith(state.year);
    const matchesStatus = state.status === "all" || machine.verification.status === state.status;
    return matchesQuery && matchesYear && matchesStatus;
  });
}

function accentFor(machine) {
  const total = [...machine.id].reduce((sum, char) => sum + char.charCodeAt(0), 0);
  return accents[total % accents.length];
}

function valueOrDash(value, suffix = "") {
  return value === null || value === undefined ? "—" : `${value}${suffix}`;
}

function renderYearFilters() {
  const years = [...new Set(state.machines.map((machine) => machine.releaseDate.slice(0, 4)))]
    .sort((a, b) => b.localeCompare(a));
  elements.yearFilters.innerHTML = ["all", ...years].map((year) => `
    <button class="filter-pill ${year === state.year ? "is-active" : ""}"
      type="button" data-year="${escapeHtml(year)}" aria-pressed="${year === state.year}">
      ${year === "all" ? "전체" : escapeHtml(year)}
    </button>
  `).join("");
}

function machineCard(machine) {
  const accent = accentFor(machine);
  return `
    <article class="machine-card" tabindex="0" role="button"
      aria-label="${escapeHtml(machine.nameKo)} 상세 보기"
      data-machine-id="${escapeHtml(machine.id)}" style="--card-accent:${accent}">
      <div class="card-top">
        <span class="format-badge">${escapeHtml(machine.format)}</span>
        <span class="date">${escapeHtml(formatDate(machine.releaseDate))}</span>
      </div>
      <p class="maker">${escapeHtml(machine.brand || machine.maker)}</p>
      <h3>${escapeHtml(machine.nameKo)}</h3>
      <p class="official-name" lang="ja">${escapeHtml(machine.officialNameJa)}</p>
      <div class="card-specs">
        <div><small>기본 확률</small><b>${escapeHtml(valueOrDash(machine.probabilities.base))}</b></div>
        <div><small>RUSH 계속률</small><b>${escapeHtml(valueOrDash(machine.rush.continuationRatePercent, "%"))}</b></div>
      </div>
      <span class="review-chip">${machine.verification.status === "verified" ? "검증 완료" : "일부 수치 재확인 필요"}</span>
    </article>
  `;
}

function renderMachines() {
  const results = currentResults();
  elements.count.textContent = results.length;
  elements.list.setAttribute("aria-busy", "false");
  elements.list.innerHTML = results.map(machineCard).join("");
  elements.list.hidden = results.length === 0;
  elements.empty.hidden = results.length !== 0;
  elements.clearSearch.hidden = !state.query && state.year === "all" && state.status === "all";
}

function resetFilters() {
  state.query = "";
  state.year = "all";
  state.status = "all";
  elements.search.value = "";
  elements.statusFilter.value = "all";
  renderYearFilters();
  renderMachines();
}

function detailSpecs(machine) {
  const probabilityItems = Object.entries(machine.probabilities)
    .filter(([, value]) => value)
    .map(([key, value]) => `<div><small>${escapeHtml(probabilityLabels[key] || key)}</small><b>${escapeHtml(value)}</b></div>`);

  const rushItems = [
    ["RUSH 진입", valueOrDash(machine.rush.totalEntryRatePercent ?? machine.rush.entryRatePercent, "%")],
    ["계속률", valueOrDash(machine.rush.continuationRatePercent, "%")],
    ["회전수", valueOrDash(machine.rush.spins, "회")],
    ["잔여 보류", valueOrDash(machine.rush.remainingHolds, "개")]
  ].map(([label, value]) => `<div><small>${label}</small><b>${escapeHtml(value)}</b></div>`);

  return [...probabilityItems, ...rushItems].join("");
}

function payoutRows(items) {
  return items.map((item) => `
    <tr>
      <td>${escapeHtml(item.label)}</td>
      <td>${item.payoutBalls === null ? "—" : `${item.payoutBalls.toLocaleString("ko-KR")}개`}</td>
      <td>${item.ratePercent === null ? "—" : `${item.ratePercent}%`}</td>
      <td>${escapeHtml(item.destination || "종료/통상")}</td>
      <td class="${item.confidence === "needs-review" ? "confidence" : ""}">${escapeHtml(confidenceLabels[item.confidence] || item.confidence)}</td>
    </tr>
  `).join("");
}

function payoutTable(title, items) {
  if (!items.length) return "";
  return `
    <div class="detail-section">
      <h3>${escapeHtml(title)}</h3>
      <div class="payout-wrap">
        <table class="payout-table">
          <thead><tr><th>구분</th><th>출옥</th><th>비율</th><th>이동</th><th>근거</th></tr></thead>
          <tbody>${payoutRows(items)}</tbody>
        </table>
      </div>
    </div>
  `;
}

const chartColors = ["#42e9ff", "#9f8cff", "#ff4fd8", "#ffca62", "#8cf5ba"];

function donutGradient(items) {
  let cursor = 0;
  const segments = items.map((item, index) => {
    const rate = Number(item.ratePercent) || 0;
    const start = cursor;
    cursor += rate;
    return `${chartColors[index % chartColors.length]} ${start}% ${cursor}%`;
  });
  if (cursor < 100) segments.push(`#252b39 ${cursor}% 100%`);
  return `conic-gradient(${segments.join(", ")})`;
}

function donutChart(title, items, centerValue, centerLabel) {
  return `
    <article class="donut-card">
      <h4>${escapeHtml(title)}</h4>
      <div class="donut-layout">
        <div class="donut" style="--donut:${donutGradient(items)}" role="img"
          aria-label="${escapeHtml(items.map((item) => `${item.label} ${item.ratePercent}%`).join(", "))}">
          <div><strong>${escapeHtml(centerValue)}</strong><span>${escapeHtml(centerLabel)}</span></div>
        </div>
        <ul class="donut-legend">
          ${items.map((item, index) => `
            <li><i style="--legend:${chartColors[index % chartColors.length]}"></i>
              <span>${escapeHtml(item.label)}</span><b>${escapeHtml(item.ratePercent)}%</b>
            </li>
          `).join("")}
        </ul>
      </div>
    </article>
  `;
}

function visualGameFlow(machine) {
  const guide = machine.visualGuide;
  if (!guide?.mainImage || !Array.isArray(guide.steps)) return "";
  const sourceUrl = guide.mainImage.sourceUrl;
  const rushImage = guide.steps.find((step) => step.phase.includes("RUSH"))?.image;
  return `
    <div class="detail-section visual-flow-section">
      <div class="visual-section-heading">
        <div><span>VISUAL GUIDE</span><h3>게임 플로우 한눈에 보기</h3></div>
        <p>초당첨에서 RUSH까지의 이동과 출옥 배분을 이미지와 비율로 정리했습니다.</p>
      </div>
      <div class="machine-visual-intro">
        <figure class="machine-product-shot">
          <img src="${escapeHtml(guide.mainImage.url)}" alt="${escapeHtml(guide.mainImage.alt)}"
            loading="lazy" decoding="async">
          <figcaption>${escapeHtml(guide.mainImage.caption)} ·
            <a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener">${escapeHtml(guide.mainImage.credit)} ↗</a>
          </figcaption>
        </figure>
        <div class="flow-key-numbers">
          <p>핵심 구조</p>
          <strong>1/349.9</strong><span>통상시 대당첨</span>
          <strong>55%</strong><span>RUSH 진입</span>
          <strong>77%</strong><span>RUSH 계속률</span>
        </div>
      </div>
      <section class="game-flow-map" aria-label="리제로 오니가카리 2 게임 진행 흐름">
        <header class="flow-stage flow-normal-stage">
          <small>NORMAL</small><strong>통상시</strong><span>대당첨 확률 약 1/349.9</span>
        </header>
        <div class="flow-connector flow-connector-down" aria-hidden="true"><span>초당첨</span></div>
        <div class="flow-branch-group flow-initial-group" role="list" aria-label="초당첨 결과 3가지">
          <article class="flow-outcome is-return" role="listitem">
            <small>45%</small><h4>1500개</h4><p>챌린지 종료 후<br>통상시 복귀</p><span class="flow-route-label">↩ 통상 복귀</span>
          </article>
          <article class="flow-outcome is-rush" role="listitem">
            <small>45%</small><h4>1500개</h4><p>Re:제로 BONUS<br>RUSH 직행</p><span class="flow-route-label">RUSH</span>
          </article>
          <article class="flow-outcome is-premium" role="listitem">
            <small>10%</small><h4>3000개</h4><p>10R × 2회<br>RUSH 직행</p><span class="flow-route-label">RUSH</span>
          </article>
        </div>
        <div class="flow-merge" aria-hidden="true"><span>55% 진입</span></div>
        <article class="flow-stage flow-rush-stage">
          ${rushImage ? `<a class="flow-rush-image" href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener"><img src="${escapeHtml(rushImage.url)}" alt="${escapeHtml(rushImage.alt)}" loading="lazy" decoding="async"><span>이미지 출처 ↗</span></a>` : ""}
          <div><small>ONIGAKARI RUSH</small><h4>鬼がかりRUSH</h4><p>ST 144회 · 당첨 약 1/99.9 · 계속률 약 77%</p></div>
        </article>
        <div class="flow-connector flow-connector-down" aria-hidden="true"><span>RUSH 중 당첨</span></div>
        <div class="flow-branch-group flow-rush-group" role="list" aria-label="RUSH 당첨 결과 4가지">
          <article class="flow-outcome is-reset" role="listitem">
            <small>14%</small><h4>Re:Start</h4><p>출옥 없이<br>ST 144회 재시작</p><span class="flow-route-label">↻ ST 리셋</span>
          </article>
          <article class="flow-outcome is-rush" role="listitem">
            <small>6%</small><h4>300개</h4><p>2R BONUS<br>RUSH 계속</p><span class="flow-route-label">↻ 계속</span>
          </article>
          <article class="flow-outcome is-rush" role="listitem">
            <small>55%</small><h4>1500개</h4><p>10R BONUS<br>RUSH 계속</p><span class="flow-route-label">↻ 계속</span>
          </article>
          <article class="flow-outcome is-premium" role="listitem">
            <small>25%</small><h4>6000개</h4><p>10R × 4회<br>RUSH 계속</p><span class="flow-route-label">↻ 계속</span>
          </article>
        </div>
        <p class="flow-loop-note"><span aria-hidden="true">↖</span> RUSH 중 결과는 모두 RUSH/ST로 복귀</p>
      </section>
      <section class="official-flow-gallery" aria-label="대도기연 공식 게임 안내 이미지">
        <div class="official-gallery-heading">
          <div><small>OFFICIAL VISUALS</small><h4>대도기연 공식 안내 이미지</h4></div>
          <a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener">공식 제품 페이지 ↗</a>
        </div>
        <div class="official-gallery-grid">
          ${guide.steps.map((step) => `
            <figure>
              <a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener">
                <img src="${escapeHtml(step.image.url)}" alt="${escapeHtml(step.image.alt)}" loading="lazy" decoding="async">
              </a>
              <figcaption><small>${escapeHtml(step.phase)}</small><strong>${escapeHtml(step.title)}</strong></figcaption>
            </figure>
          `).join("")}
        </div>
      </section>
      <div class="distribution-charts">
        ${donutChart("초기 당첨 배분", machine.payouts.initial, "55%", "RUSH 진입")}
        ${donutChart("RUSH 중 배분", machine.payouts.rush, "25%", "6000개")}
      </div>
      <p class="visual-source-note">이미지: ${escapeHtml(guide.mainImage.credit)} · 수치: 공개 스펙 자료 대조 · 출옥은 지급 기준</p>
    </div>
  `;
}

function renderDetail(machine) {
  const accent = accentFor(machine);
  const reviewFields = machine.verification.needsReviewFields || [];
  elements.dialogContent.innerHTML = `
    <section class="detail-hero" style="--detail-accent:${accent}">
      <p class="detail-kicker">${escapeHtml(machine.maker)} · ${escapeHtml(formatDate(machine.releaseDate))}</p>
      <h2 id="dialog-title">${escapeHtml(machine.nameKo)}</h2>
      <p class="detail-official" lang="ja">${escapeHtml(machine.officialNameJa)}</p>
      <div class="detail-badges">
        <span>${escapeHtml(machine.format)} 타입</span>
        <span>${escapeHtml(machine.rush.nameJa || machine.rush.type)}</span>
        <span>출옥 기준</span>
        ${machine.modelCode ? `<span>${escapeHtml(machine.modelCode)}</span>` : ""}
      </div>
    </section>
    <div class="detail-body">
      <div class="detail-section">
        <h3>핵심 스펙</h3>
        <div class="spec-table">${detailSpecs(machine)}</div>
      </div>
      ${visualGameFlow(machine)}
      <div class="detail-section">
        <h3>플레이 흐름</h3>
        <ol class="flow-list">${machine.gameFlow.map((step) => `<li>${escapeHtml(step)}</li>`).join("")}</ol>
      </div>
      ${payoutTable("초기 당첨 배분", machine.payouts.initial)}
      ${payoutTable("RUSH 배분", machine.payouts.rush)}
      <div class="detail-section">
        <h3>확인 출처</h3>
        <ul class="source-list">
          ${machine.sources.map((source) => `
            <li><a href="${escapeHtml(source.url)}" target="_blank" rel="noreferrer noopener">
              <b>${escapeHtml(source.title)}</b><span>${source.type === "official" ? "공식 ↗" : "보조 ↗"}</span>
            </a></li>
          `).join("")}
        </ul>
      </div>
      ${reviewFields.length ? `
        <div class="review-box">
          <strong>데이터 검토 안내</strong><br>
          다음 항목은 공개 전 원문과 재확인이 필요합니다: ${escapeHtml(reviewFields.join(", "))}
        </div>
      ` : ""}
      <button class="detail-ai-button" type="button" data-ask-machine="${escapeHtml(machine.id)}">
        <span>✦</span> 이 기종을 Gemini에게 질문하기
      </button>
    </div>
  `;
}

function openMachine(machineId, updateUrl = true) {
  const machine = state.machines.find((item) => item.id === machineId);
  if (!machine) return;
  renderDetail(machine);
  if (!elements.machineDialog.open) elements.machineDialog.showModal();
  if (updateUrl) {
    const url = new URL(window.location.href);
    url.searchParams.set("machine", machine.id);
    history.pushState({ machine: machine.id }, "", url);
  }
}

function closeMachine(updateUrl = true) {
  if (elements.machineDialog.open) elements.machineDialog.close();
  if (updateUrl) {
    const url = new URL(window.location.href);
    url.searchParams.delete("machine");
    history.pushState({}, "", url);
  }
}

function populateAIMachines(selectedId) {
  const currentValue = selectedId || elements.aiMachineSelect.value || state.machines[0]?.id;
  elements.aiMachineSelect.innerHTML = state.machines.map((machine) => `
    <option value="${escapeHtml(machine.id)}" ${machine.id === currentValue ? "selected" : ""}>
      ${escapeHtml(machine.nameKo)}
    </option>
  `).join("");
}

function openAI(machineId) {
  if (!state.machines.length) return;
  populateAIMachines(machineId);
  const isLive = AI_CONFIG.mode === "live" && Boolean(AI_CONFIG.endpoint);
  elements.aiModeBadge.textContent = isLive ? "Gemini 연결" : "테스트 모드";
  elements.aiModeBadge.classList.toggle("is-live", isLive);
  elements.aiError.hidden = true;
  if (!elements.aiDialog.open) elements.aiDialog.showModal();
  window.setTimeout(() => elements.aiQuestion.focus(), 50);
}

function selectedAIMachine() {
  return state.machines.find((machine) => machine.id === elements.aiMachineSelect.value) || state.machines[0];
}

function appendAIMessage(role, text, label) {
  const message = document.createElement("div");
  message.className = `ai-message ${role}`;

  const avatar = document.createElement("span");
  avatar.className = "ai-avatar";
  avatar.textContent = role === "user" ? "나" : "✦";

  const content = document.createElement("div");
  const name = document.createElement("b");
  name.textContent = label || (role === "user" ? "질문" : "Gemini 스펙 도우미");
  const paragraph = document.createElement("p");
  paragraph.textContent = text;
  content.append(name, paragraph);
  message.append(avatar, content);
  elements.aiMessages.append(message);
  elements.aiMessages.scrollTop = elements.aiMessages.scrollHeight;
  return message;
}

function appendPendingMessage() {
  const message = document.createElement("div");
  message.className = "ai-message assistant pending";
  message.innerHTML = '<span class="ai-avatar">✦</span><div><b>답변 작성 중</b><p><i></i><i></i><i></i></p></div>';
  elements.aiMessages.append(message);
  elements.aiMessages.scrollTop = elements.aiMessages.scrollHeight;
  return message;
}

function buildMockAnswer(machine) {
  const entry = valueOrDash(machine.rush.totalEntryRatePercent ?? machine.rush.entryRatePercent, "%");
  const continuation = valueOrDash(machine.rush.continuationRatePercent, "%");
  const flow = machine.gameFlow.slice(0, 3).map((step, index) => `${index + 1}. ${step}`).join("\n");
  const reviewNotice = machine.verification.needsReviewFields.length
    ? "\n\n주의: 일부 배분·표기는 공개 전 원문 재확인이 필요한 초안입니다."
    : "";
  return `[연결 전 테스트 응답]\n${machine.nameKo}의 기본 확률은 ${valueOrDash(machine.probabilities.base)}이며, RUSH 진입률은 ${entry}, 계속률은 ${continuation}입니다.\n\n${flow}${reviewNotice}`;
}

async function requestAI(question, machine) {
  if (AI_CONFIG.mode !== "live" || !AI_CONFIG.endpoint) {
    await new Promise((resolve) => window.setTimeout(resolve, 450));
    return buildMockAnswer(machine);
  }

  const response = await fetch(AI_CONFIG.endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ question, machine })
  });
  const result = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(result.error || "Gemini 요청에 실패했습니다.");
  if (!result.answer) throw new Error("Gemini 응답이 비어 있습니다.");
  return result.answer;
}

function setAIBusy(isBusy) {
  state.aiBusy = isBusy;
  elements.aiSubmit.disabled = isBusy;
  elements.aiQuestion.disabled = isBusy;
  elements.aiMachineSelect.disabled = isBusy;
  elements.aiSubmit.textContent = isBusy ? "답변 중…" : "질문하기";
}

async function submitAIQuestion(question) {
  const normalizedQuestion = question.trim();
  if (!normalizedQuestion || state.aiBusy) return;
  if (normalizedQuestion.length > 500) {
    elements.aiError.textContent = "질문은 500자 이하로 입력해 주세요.";
    elements.aiError.hidden = false;
    return;
  }
  if (AI_CONFIG.mode === "live" && Date.now() - state.lastAIRequestAt < 3000) {
    elements.aiError.textContent = "잠시 후 다시 질문해 주세요.";
    elements.aiError.hidden = false;
    return;
  }

  const machine = selectedAIMachine();
  elements.aiError.hidden = true;
  appendAIMessage("user", normalizedQuestion, machine.nameKo);
  elements.aiQuestion.value = "";
  elements.aiCharacterCount.textContent = "0";
  setAIBusy(true);
  const pending = appendPendingMessage();

  try {
    state.lastAIRequestAt = Date.now();
    const answer = await requestAI(normalizedQuestion, machine);
    pending.remove();
    appendAIMessage("assistant", answer);
  } catch (error) {
    pending.remove();
    elements.aiError.textContent = error.message || "답변을 가져오지 못했습니다.";
    elements.aiError.hidden = false;
  } finally {
    setAIBusy(false);
    elements.aiQuestion.focus();
  }
}

async function loadMachines() {
  try {
    const indexResponse = await fetch(`${DATA_ROOT}/index.json`);
    if (!indexResponse.ok) throw new Error(`index ${indexResponse.status}`);
    const index = await indexResponse.json();
    const machineResponses = await Promise.all(index.machines.map(({ file }) => fetch(`${DATA_ROOT}/${file}`)));
    if (machineResponses.some((response) => !response.ok)) throw new Error("machine data response failed");
    const machines = await Promise.all(machineResponses.map((response) => response.json()));
    state.machines = machines.sort((a, b) => b.releaseDate.localeCompare(a.releaseDate));
    renderYearFilters();
    renderMachines();
    populateAIMachines();

    const initialMachine = new URLSearchParams(window.location.search).get("machine");
    if (initialMachine) openMachine(initialMachine, false);
  } catch (error) {
    console.error(error);
    elements.list.setAttribute("aria-busy", "false");
    elements.list.innerHTML = `
      <div class="empty-state" style="display:block;grid-column:1/-1">
        <h3>기종 데이터를 불러오지 못했습니다</h3>
        <p>정적 서버로 실행했는지 확인한 뒤 새로고침해 주세요.</p>
      </div>
    `;
  }
}

elements.searchForm.addEventListener("submit", (event) => {
  event.preventDefault();
  state.query = elements.search.value;
  renderMachines();
  document.querySelector("#explore").scrollIntoView({ behavior: "smooth" });
});

elements.search.addEventListener("input", () => {
  state.query = elements.search.value;
  renderMachines();
});

elements.yearFilters.addEventListener("click", (event) => {
  const button = event.target.closest("[data-year]");
  if (!button) return;
  state.year = button.dataset.year;
  renderYearFilters();
  renderMachines();
});

elements.statusFilter.addEventListener("change", () => {
  state.status = elements.statusFilter.value;
  renderMachines();
});

elements.list.addEventListener("click", (event) => {
  const card = event.target.closest("[data-machine-id]");
  if (card) openMachine(card.dataset.machineId);
});

elements.list.addEventListener("keydown", (event) => {
  if (event.key !== "Enter" && event.key !== " ") return;
  const card = event.target.closest("[data-machine-id]");
  if (!card) return;
  event.preventDefault();
  openMachine(card.dataset.machineId);
});

document.querySelectorAll("[data-clear], #clear-search").forEach((button) => {
  button.addEventListener("click", resetFilters);
});

document.querySelector("[data-close-dialog]").addEventListener("click", () => closeMachine());
elements.machineDialog.addEventListener("click", (event) => {
  if (event.target === elements.machineDialog) closeMachine();
});
elements.machineDialog.addEventListener("cancel", (event) => {
  event.preventDefault();
  closeMachine();
});

elements.dialogContent.addEventListener("click", (event) => {
  const button = event.target.closest("[data-ask-machine]");
  if (!button) return;
  closeMachine();
  openAI(button.dataset.askMachine);
});

document.querySelectorAll("[data-open-ai]").forEach((button) => {
  button.addEventListener("click", () => openAI());
});
document.querySelector("[data-close-ai]").addEventListener("click", () => elements.aiDialog.close());
elements.aiDialog.addEventListener("click", (event) => {
  if (event.target === elements.aiDialog) elements.aiDialog.close();
});
elements.aiQuestion.addEventListener("input", () => {
  elements.aiCharacterCount.textContent = elements.aiQuestion.value.length;
});
elements.aiQuestion.addEventListener("keydown", (event) => {
  if (event.key === "Enter" && !event.shiftKey) {
    event.preventDefault();
    elements.aiForm.requestSubmit();
  }
});
elements.aiForm.addEventListener("submit", (event) => {
  event.preventDefault();
  submitAIQuestion(elements.aiQuestion.value);
});
document.querySelectorAll("[data-ai-prompt]").forEach((button) => {
  button.addEventListener("click", () => submitAIQuestion(button.dataset.aiPrompt));
});

function preventInAppInputZoom() {
  const userAgent = navigator.userAgent;
  const isIOS = /iPad|iPhone|iPod/.test(userAgent)
    || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
  const isSafari = /Safari/.test(userAgent)
    && !/CriOS|FxiOS|EdgiOS|OPiOS|GSA|DuckDuckGo|Instagram|FBAN|FBAV|KAKAOTALK|NAVER/.test(userAgent);
  const viewport = document.querySelector('meta[name="viewport"]');
  if (!isIOS || isSafari || !viewport) return;

  const defaultContent = viewport.getAttribute("content");
  const lockedContent = `${defaultContent}, maximum-scale=1`;
  const lockZoom = () => viewport.setAttribute("content", lockedContent);
  const restoreZoom = () => window.setTimeout(() => {
    viewport.setAttribute("content", defaultContent);
  }, 250);

  elements.aiQuestion.addEventListener("touchstart", lockZoom, { passive: true });
  elements.aiQuestion.addEventListener("focus", lockZoom);
  elements.aiQuestion.addEventListener("blur", restoreZoom);
}

window.addEventListener("popstate", () => {
  const machineId = new URLSearchParams(window.location.search).get("machine");
  if (machineId) openMachine(machineId, false);
  else closeMachine(false);
});

preventInAppInputZoom();
loadMachines();
