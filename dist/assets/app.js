const DATA_SOURCES = [
  { category: "pachinko", root: "./data/pachinko" },
  { category: "slot", root: "./data/slots" }
];
const accents = ["#42e9ff", "#ff4fd8", "#ffca62", "#8cf5ba", "#9f8cff"];
const AI_CONFIG = window.PACHI_AI_CONFIG || { mode: "mock", endpoint: "" };

const state = {
  machines: [],
  query: "",
  category: "all",
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
  categoryFilters: document.querySelector("#category-filters"),
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
  rushHit: "RUSH 중",
  cz: "CZ 합산",
  at: "AT 초당첨",
  episodeBonus: "에피소드 보너스"
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
    const matchesCategory = state.category === "all" || machine.machineType === state.category;
    const matchesYear = state.year === "all" || machine.releaseDate.startsWith(state.year);
    const matchesStatus = state.status === "all" || machine.verification.status === state.status;
    return matchesQuery && matchesCategory && matchesYear && matchesStatus;
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
  const isSlot = machine.machineType === "slot";
  const primarySpec = isSlot ? machine.settings?.[0]?.atProbability : machine.probabilities.base;
  const secondarySpec = isSlot ? machine.settings?.[machine.settings.length - 1]?.payoutRate : valueOrDash(machine.rush.continuationRatePercent, "%");
  return `
    <article class="machine-card" tabindex="0" role="button"
      aria-label="${escapeHtml(machine.nameKo)} 상세 보기"
      data-machine-id="${escapeHtml(machine.id)}" style="--card-accent:${accent}">
      <div class="card-top">
        <span class="format-badge">${escapeHtml(machine.format)} · ${isSlot ? "슬롯" : "파칭코"}</span>
        <span class="date">${escapeHtml(formatDate(machine.releaseDate))}</span>
      </div>
      <p class="maker">${escapeHtml(machine.brand || machine.maker)}</p>
      <h3>${escapeHtml(machine.nameKo)}</h3>
      <p class="official-name" lang="ja">${escapeHtml(machine.officialNameJa)}</p>
      <div class="card-specs">
        <div><small>${isSlot ? "설정1 AT" : "기본 확률"}</small><b>${escapeHtml(valueOrDash(primarySpec))}</b></div>
        <div><small>${isSlot ? "설정6 기계할" : "RUSH 계속률"}</small><b>${escapeHtml(valueOrDash(secondarySpec))}</b></div>
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
  elements.clearSearch.hidden = !state.query && state.category === "all" && state.year === "all" && state.status === "all";
}

function resetFilters() {
  state.query = "";
  state.category = "all";
  state.year = "all";
  state.status = "all";
  elements.search.value = "";
  elements.statusFilter.value = "all";
  renderCategoryFilters();
  renderYearFilters();
  renderMachines();
}

function renderCategoryFilters() {
  const labels = { all: "전체", pachinko: "파칭코", slot: "슬롯" };
  elements.categoryFilters.innerHTML = Object.entries(labels).map(([category, label]) => `
    <button class="filter-pill ${category === state.category ? "is-active" : ""}"
      type="button" data-category="${category}" aria-pressed="${category === state.category}">
      ${label}
    </button>
  `).join("");
}

function detailSpecs(machine) {
  if (machine.machineType === "slot") {
    const items = [
      ["구분", machine.slot?.type],
      ["순증", machine.slot?.netIncrease],
      ["베이스", machine.slot?.baseGames],
      ["AT 초기", machine.slot?.initialATCoins],
      [machine.slot?.primaryCeilingLabel || "CZ 천장", machine.slot?.czCeiling],
      ["AT 천장", machine.slot?.atCeiling]
    ];
    return items.map(([label, value]) => `<div><small>${label}</small><b>${escapeHtml(valueOrDash(value))}</b></div>`).join("");
  }
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

function slotSettingsTable(machine) {
  if (machine.machineType !== "slot" || !Array.isArray(machine.settings)) return "";
  return `
    <div class="detail-section">
      <div class="slot-setting-heading">
        <h3>설정별 확률 · 기계할</h3>
        <span>공개 스펙 기준</span>
      </div>
      <div class="payout-wrap">
        <table class="payout-table slot-settings-table">
          <thead><tr><th>설정</th><th>${escapeHtml(machine.slot?.settingsPrimaryLabel || "CZ 합산")}</th><th>AT 초당첨</th><th>기계할</th></tr></thead>
          <tbody>${machine.settings.map((row) => `
            <tr><td><b>${escapeHtml(row.setting)}</b></td><td>${escapeHtml(row.czProbability)}</td><td>${escapeHtml(row.atProbability)}</td><td>${escapeHtml(row.payoutRate)}</td></tr>
          `).join("")}</tbody>
        </table>
      </div>
    </div>
  `;
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

function flowOutcome(item) {
  const allowedTones = new Set(["return", "rush", "premium", "reset"]);
  const tone = allowedTones.has(item.tone) ? ` is-${item.tone}` : "";
  const description = escapeHtml(item.description || "").replace(/\n/g, "<br>");
  return `
    <article class="flow-outcome${tone}" role="listitem">
      <small>${escapeHtml(item.rate)}</small>
      <h4>${escapeHtml(item.title)}</h4>
      <p>${description}</p>
      <span class="flow-route-label">${escapeHtml(item.route)}</span>
    </article>
  `;
}

function visualGameFlow(machine) {
  const guide = machine.visualGuide;
  if (!guide?.mainImage || !Array.isArray(guide.steps) || !guide.flowDiagram) return "";
  const flow = guide.flowDiagram;
  const sourceUrl = guide.mainImage.sourceUrl;
  const rushImage = guide.rushScreen || guide.steps.find((step) => step.phase.includes("RUSH"))?.image;
  const officialImages = Array.isArray(guide.translatedImages)
    ? guide.translatedImages
    : guide.steps.map((step) => ({ phase: step.phase, title: step.title, ...step.image }));
  const isSlot = machine.machineType === "slot";
  const keyStats = Array.isArray(guide.keyStats) ? guide.keyStats : [
    { value: machine.probabilities.base, label: "통상시 대당첨" },
    { value: `${machine.rush.totalEntryRatePercent ?? machine.rush.entryRatePercent}%`, label: "RUSH 진입" },
    { value: `${machine.rush.continuationRatePercent}%`, label: "RUSH 계속률" }
  ];
  const initialRate = machine.rush.totalEntryRatePercent ?? machine.rush.entryRatePercent;
  const initialCenter = initialRate === null || initialRate === undefined ? "—" : `${initialRate}%`;
  const premiumRush = [...(machine.payouts?.rush || [])].sort((a, b) => (b.payoutBalls || 0) - (a.payoutBalls || 0))[0];
  const distributionCharts = Array.isArray(guide.distributionCharts) ? guide.distributionCharts : [
    { title: "초기 당첨 배분", source: "initial", centerValue: initialCenter, centerLabel: "RUSH 진입" },
    { title: "RUSH 중 배분", source: "rush", centerValue: `${premiumRush?.ratePercent ?? "-"}%`, centerLabel: premiumRush ? `${premiumRush.payoutBalls}개` : "최대 출옥" }
  ];
  return `
    <div class="detail-section visual-flow-section">
      <div class="visual-section-heading">
        <div><span>VISUAL GUIDE</span><h3>게임 플로우 한눈에 보기</h3></div>
        <p>${isSlot ? "통상시에서 CZ·AT와 상위 구간까지의 이동을 이미지와 수치로 정리했습니다." : "초당첨에서 RUSH까지의 이동과 출옥 배분을 이미지와 비율로 정리했습니다."}</p>
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
          ${keyStats.map((item) => `<strong>${escapeHtml(item.value)}</strong><span>${escapeHtml(item.label)}</span>`).join("")}
        </div>
      </div>
      <section class="game-flow-map" aria-label="${escapeHtml(flow.ariaLabel || `${machine.nameKo} 게임 진행 흐름`)}">
        <header class="flow-stage flow-normal-stage">
          <small>${escapeHtml(flow.normal.eyebrow)}</small><strong>${escapeHtml(flow.normal.title)}</strong><span>${escapeHtml(flow.normal.detail)}</span>
        </header>
        <div class="flow-connector flow-connector-down" aria-hidden="true"><span>${escapeHtml(flow.initialConnector)}</span></div>
        <div class="flow-branch-group" style="--branch-count:${flow.initialOutcomes.length}" role="list" aria-label="${escapeHtml(flow.initialAriaLabel)}">
          ${flow.initialOutcomes.map(flowOutcome).join("")}
        </div>
        <div class="flow-merge" aria-hidden="true"><span>${escapeHtml(flow.mergeLabel)}</span></div>
        <article class="flow-stage flow-rush-stage">
          ${rushImage ? `<a class="flow-rush-image" href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener"><img src="${escapeHtml(rushImage.url)}" alt="${escapeHtml(rushImage.alt)}" loading="lazy" decoding="async"><span>이미지 출처 ↗</span></a>` : ""}
          <div><small>${escapeHtml(flow.rush.eyebrow)}</small><h4>${escapeHtml(flow.rush.title)}</h4><p>${escapeHtml(flow.rush.detail)}</p></div>
        </article>
        <div class="flow-connector flow-connector-down" aria-hidden="true"><span>${escapeHtml(flow.rushConnector)}</span></div>
        <div class="flow-branch-group" style="--branch-count:${flow.rushOutcomes.length}" role="list" aria-label="${escapeHtml(flow.rushAriaLabel)}">
          ${flow.rushOutcomes.map(flowOutcome).join("")}
        </div>
        ${flow.secondaryRush ? `
          <div class="flow-connector flow-connector-down" aria-hidden="true"><span>${escapeHtml(flow.secondaryConnector)}</span></div>
          <article class="flow-stage flow-rush-stage is-text-only">
            <div><small>${escapeHtml(flow.secondaryRush.eyebrow)}</small><h4>${escapeHtml(flow.secondaryRush.title)}</h4><p>${escapeHtml(flow.secondaryRush.detail)}</p></div>
          </article>
          <div class="flow-connector flow-connector-down" aria-hidden="true"><span>${escapeHtml(flow.secondaryRushConnector)}</span></div>
          <div class="flow-branch-group" style="--branch-count:${flow.secondaryOutcomes.length}" role="list" aria-label="${escapeHtml(flow.secondaryAriaLabel)}">
            ${flow.secondaryOutcomes.map(flowOutcome).join("")}
          </div>
        ` : ""}
        <p class="flow-loop-note"><span aria-hidden="true">↖</span> ${escapeHtml(flow.loopNote)}</p>
      </section>
      <section class="official-flow-gallery" aria-label="${escapeHtml(machine.maker)} 공식 게임 안내 이미지">
        <div class="official-gallery-heading">
          <div><small>OFFICIAL VISUALS · KOREAN OVERLAY</small><h4>${escapeHtml(machine.maker)} 공식 이미지 · 한국어 번역본</h4></div>
          <a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener">공식 제품 페이지 ↗</a>
        </div>
        <div class="official-gallery-grid">
          ${officialImages.map((item) => `
            <figure>
              <a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noreferrer noopener">
                <img src="${escapeHtml(item.url)}" alt="${escapeHtml(item.alt)}" loading="lazy" decoding="async">
              </a>
              <figcaption><small>${escapeHtml(item.phase)}</small><strong>${escapeHtml(item.title)}</strong></figcaption>
            </figure>
          `).join("")}
        </div>
        <p class="official-translation-note">원본 이미지의 수치와 구성은 유지하고 일본어 핵심 안내를 PhotoCraft로 한국어 덧입힘 처리한 번역본입니다.</p>
      </section>
      <div class="distribution-charts">
        ${distributionCharts.map((chart) => donutChart(
          chart.title,
          machine.payouts[chart.source] || [],
          chart.centerValue,
          chart.centerLabel
        )).join("")}
      </div>
      <p class="visual-source-note">이미지: ${escapeHtml(guide.mainImage.credit)} · 수치: 공개 스펙 자료 대조${isSlot ? " · 기계할은 이론상 장기 평균" : " · 출옥은 지급 기준"}</p>
    </div>
  `;
}

function renderDetail(machine) {
  const accent = accentFor(machine);
  const isSlot = machine.machineType === "slot";
  const reviewFields = machine.verification.needsReviewFields || [];
  elements.dialogContent.innerHTML = `
    <section class="detail-hero" style="--detail-accent:${accent}">
      <p class="detail-kicker">${escapeHtml(machine.maker)} · ${escapeHtml(formatDate(machine.releaseDate))}</p>
      <h2 id="dialog-title">${escapeHtml(machine.nameKo)}</h2>
      <p class="detail-official" lang="ja">${escapeHtml(machine.officialNameJa)}</p>
      <div class="detail-badges">
        <span>${escapeHtml(machine.format)} · ${isSlot ? "스마트 슬롯" : "파칭코"}</span>
        <span>${escapeHtml(machine.rush.nameJa || machine.rush.type)}</span>
        <span>${isSlot ? "AT 타입" : "출옥 기준"}</span>
        ${machine.modelCode ? `<span>${escapeHtml(machine.modelCode)}</span>` : ""}
      </div>
    </section>
    <div class="detail-body">
      <div class="detail-section">
        <h3>핵심 스펙</h3>
        <div class="spec-table">${detailSpecs(machine)}</div>
      </div>
      ${slotSettingsTable(machine)}
      ${visualGameFlow(machine)}
      <div class="detail-section">
        <h3>플레이 흐름</h3>
        <ol class="flow-list">${machine.gameFlow.map((step) => `<li>${escapeHtml(step)}</li>`).join("")}</ol>
      </div>
      ${isSlot ? "" : payoutTable("초기 당첨 배분", machine.payouts.initial)}
      ${!isSlot && Array.isArray(machine.payouts.climax) ? payoutTable("CLIMAX 배분", machine.payouts.climax) : ""}
      ${isSlot ? "" : payoutTable(Array.isArray(machine.payouts.modeB) ? "RUSH 모드 A 배분" : "RUSH 배분", machine.payouts.rush)}
      ${!isSlot && Array.isArray(machine.payouts.modeB) ? payoutTable("RUSH 모드 B 배분", machine.payouts.modeB) : ""}
      ${!isSlot && Array.isArray(machine.payouts.ultimateDrive) ? payoutTable("ULTIMATE DRIVE 배분", machine.payouts.ultimateDrive) : ""}
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
  if (machine.machineType === "slot") {
    const settings = machine.settings || [];
    const settingOne = settings[0];
    const settingSix = settings[settings.length - 1];
    const flow = machine.gameFlow.slice(0, 4).map((step, index) => `${index + 1}. ${step}`).join("\n");
    return `[연결 전 테스트 응답]\n${machine.nameKo}은 ${machine.slot?.type || "AT 슬롯"}입니다. 설정1 AT 초당첨은 ${settingOne?.atProbability || "—"}, 설정6 기계할은 ${settingSix?.payoutRate || "—"}, AT 순증은 ${machine.slot?.netIncrease || "—"}입니다.\n\n${flow}`;
  }
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
    const indexResponses = await Promise.all(DATA_SOURCES.map((source) => fetch(`${source.root}/index.json`)));
    if (indexResponses.some((response) => !response.ok)) throw new Error("machine index response failed");
    const indexes = await Promise.all(indexResponses.map((response) => response.json()));
    const entries = indexes.flatMap((index, indexPosition) => index.machines.map((machine) => ({
      ...machine,
      root: DATA_SOURCES[indexPosition].root
    })));
    const machineResponses = await Promise.all(entries.map(({ root, file }) => fetch(`${root}/${file}`)));
    if (machineResponses.some((response) => !response.ok)) throw new Error("machine data response failed");
    const machines = await Promise.all(machineResponses.map((response) => response.json()));
    state.machines = machines.sort((a, b) => b.releaseDate.localeCompare(a.releaseDate));
    renderCategoryFilters();
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

elements.categoryFilters.addEventListener("click", (event) => {
  const button = event.target.closest("[data-category]");
  if (!button) return;
  state.category = button.dataset.category;
  renderCategoryFilters();
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
