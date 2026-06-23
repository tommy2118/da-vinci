import {
  MESSAGE_GRAMMAR,
  PLAIN_GLOSSARY,
  STATION_GUIDES,
  TERM_LIBRARY,
  acceptanceArtifact,
  blankEntity,
  blankMessage,
  blankRefusal,
  blankRisk,
  blankSlice,
  buildExportGuide,
  buildDiagram,
  completionScore,
  createInitialState,
  evaluateChecklist,
  evaluateStations,
  loadState,
  renderSymbolLegend,
  resetState,
  saveState,
  serializeBodyPlan,
  serializeMission,
  serializeWorkshopBootstrap,
  starterFiles,
  termForId,
} from "./rockdrill.mjs";

let state = loadState();
let persistStatus = "Auto-saved in this browser";

const elements = {
  projectName: document.querySelector("#project-name"),
  projectSlug: document.querySelector("#project-slug"),
  acceptanceStyle: document.querySelector("#acceptance-style"),
  bootstrapNotes: document.querySelector("#bootstrap-notes"),
  missionName: document.querySelector("#mission-name"),
  workLevel: document.querySelector("#work-level"),
  missionStatement: document.querySelector("#mission-statement"),
  sliceNumber: document.querySelector("#slice-number"),
  sliceName: document.querySelector("#slice-name"),
  scopeReminder: document.querySelector("#scope-reminder"),
  acceptanceTitle: document.querySelector("#acceptance-title"),
  acceptanceAssertion: document.querySelector("#acceptance-assertion"),
  timerChecked: document.querySelector("#timer-checked"),
  sliceList: document.querySelector("#slice-list"),
  entityList: document.querySelector("#entity-list"),
  messageList: document.querySelector("#message-list"),
  refusalList: document.querySelector("#refusal-list"),
  happyPathList: document.querySelector("#happy-path-list"),
  failurePathList: document.querySelector("#failure-path-list"),
  risksList: document.querySelector("#risks-list"),
  stationRail: document.querySelector("#station-rail"),
  checklist: document.querySelector("#checklist"),
  readinessLabel: document.querySelector("#readiness-label"),
  readinessFill: document.querySelector("#readiness-fill"),
  readinessCopy: document.querySelector("#readiness-copy"),
  persistStatus: document.querySelector("#persist-status"),
  stateExportName: document.querySelector("#state-export-name"),
  bootstrapCommand: document.querySelector("#bootstrap-command"),
  plainGlossary: document.querySelector("#plain-glossary"),
  exportMap: document.querySelector("#export-map"),
  symbolLegend: document.querySelector("#symbol-legend"),
  coachPrompts: document.querySelector("#coach-prompts"),
  diagramPreview: document.querySelector("#diagram-preview"),
  missionPreview: document.querySelector("#mission-preview"),
  bodyPlanPreview: document.querySelector("#body-plan-preview"),
  acceptancePreview: document.querySelector("#acceptance-preview"),
  acceptanceArtifactName: document.querySelector("#acceptance-artifact-name"),
  bootstrapPreview: document.querySelector("#bootstrap-preview"),
  bundlePreview: document.querySelector("#bundle-preview"),
  copyMission: document.querySelector("#copy-mission"),
  copyBodyPlan: document.querySelector("#copy-body-plan"),
  copyAcceptance: document.querySelector("#copy-acceptance-spec"),
  copyBootstrap: document.querySelector("#copy-bootstrap"),
  copyBootstrapCommand: document.querySelector("#copy-bootstrap-command"),
  downloadState: document.querySelector("#download-state"),
  downloadBundle: document.querySelector("#download-bundle"),
  downloadBundleBanner: document.querySelector("#download-bundle-banner"),
  resetState: document.querySelector("#reset-state"),
};

hydrateStaticFields();
renderDynamicLists();
renderDerived();
wireEvents();

function hydrateStaticFields() {
  elements.projectName.value = state.projectName;
  elements.projectSlug.value = state.projectSlug;
  elements.acceptanceStyle.value = state.acceptanceStyle;
  elements.bootstrapNotes.value = state.bootstrapNotes;
  elements.missionName.value = state.missionName;
  elements.workLevel.value = state.workLevel;
  elements.missionStatement.value = state.missionStatement;
  elements.sliceNumber.value = state.sliceNumber;
  elements.sliceName.value = state.sliceName;
  elements.scopeReminder.value = state.scopeReminder;
  elements.acceptanceTitle.value = state.acceptanceTitle;
  elements.acceptanceAssertion.value = state.acceptanceAssertion;
  elements.timerChecked.checked = state.timerChecked;
}

function wireEvents() {
  const fieldMap = new Map([
    [elements.projectName, "projectName"],
    [elements.projectSlug, "projectSlug"],
    [elements.acceptanceStyle, "acceptanceStyle"],
    [elements.bootstrapNotes, "bootstrapNotes"],
    [elements.missionName, "missionName"],
    [elements.workLevel, "workLevel"],
    [elements.missionStatement, "missionStatement"],
    [elements.sliceNumber, "sliceNumber"],
    [elements.sliceName, "sliceName"],
    [elements.scopeReminder, "scopeReminder"],
    [elements.acceptanceTitle, "acceptanceTitle"],
    [elements.acceptanceAssertion, "acceptanceAssertion"],
  ]);

  fieldMap.forEach((key, element) => {
    element.addEventListener("input", () => {
      state[key] = element.value;
      commit();
    });
  });

  elements.timerChecked.addEventListener("change", () => {
    state.timerChecked = elements.timerChecked.checked;
    commit();
  });

  document.addEventListener("input", handleDelegatedInput);
  document.addEventListener("change", handleDelegatedInput);
  document.addEventListener("click", handleClick);

  elements.copyMission.addEventListener("click", () => copyText(serializeMission(state)));
  elements.copyBodyPlan.addEventListener("click", () => copyText(serializeBodyPlan(state)));
  elements.copyAcceptance.addEventListener("click", () => copyText(acceptanceArtifact(state).content));
  elements.copyBootstrap.addEventListener("click", () => copyText(serializeWorkshopBootstrap(state)));
  elements.copyBootstrapCommand.addEventListener("click", () => copyText(bootstrapCommand(state)));
  elements.downloadState.addEventListener("click", () => downloadFile(stateExportFile(state)));
  elements.downloadBundle.addEventListener("click", () => downloadBundle(starterFiles(state)));
  elements.downloadBundleBanner.addEventListener("click", () => downloadBundle(starterFiles(state)));
  elements.resetState.addEventListener("click", () => {
    state = resetState();
    persistStatus = "Browser draft cleared";
    hydrateStaticFields();
    renderDynamicLists();
    commit({ persist: false });
  });
}

function handleDelegatedInput(event) {
  const { target } = event;
  if (!(target instanceof HTMLElement)) return;

  if (target.matches("[data-slice-field]")) {
    const slice = state.slices[Number(target.dataset.sliceIndex)];
    slice[target.dataset.sliceField] = target.value;
    return commit();
  }

  if (target.matches("[data-entity-field]")) {
    const entity = state.entities.find((item) => item.id === target.dataset.entityId);
    if (!entity) return;
    entity[target.dataset.entityField] = target.value;
    if (entityFieldRequiresRerender(target.dataset.entityField)) {
      return rerenderDynamic({ preserveFocus: true });
    }
    return commit();
  }

  if (target.matches("[data-message-field]")) {
    const message = state.messages[Number(target.dataset.messageIndex)];
    message[target.dataset.messageField] = target.value;
    return commit();
  }

  if (target.matches("[data-refusal-field]")) {
    const refusal = state.refusals[Number(target.dataset.refusalIndex)];
    if (target.dataset.refusalField === "entityId") {
      refusal.entityId = target.value;
    } else {
      refusal.items[Number(target.dataset.itemIndex)] = target.value;
    }
    return commit();
  }

  if (target.matches("[data-step-kind]")) {
    const list = target.dataset.stepKind === "happy" ? state.happyPath : state.failurePath;
    list[Number(target.dataset.stepIndex)] = target.value;
    return commit();
  }

  if (target.matches("[data-risk-field]")) {
    const risk = state.risks[Number(target.dataset.riskIndex)];
    risk[target.dataset.riskField] = target.value;
    return commit();
  }
}

function handleClick(event) {
  const button = event.target.closest("[data-action]");
  if (!button) return;

  const { action } = button.dataset;
  switch (action) {
    case "add-slice":
      state.slices.push(blankSlice());
      return rerenderDynamic();
    case "remove-slice":
      if (state.slices.length > 1) state.slices.splice(Number(button.dataset.sliceIndex), 1);
      return rerenderDynamic();
    case "add-entity":
      state.entities.push(blankEntity(nextEntityId(), "owned"));
      return rerenderDynamic();
    case "remove-entity":
      if (state.entities.length > 1) removeEntity(button.dataset.entityId);
      return rerenderDynamic();
    case "add-message":
      state.messages.push(blankMessage());
      return rerenderDynamic();
    case "remove-message":
      if (state.messages.length > 1) state.messages.splice(Number(button.dataset.messageIndex), 1);
      return rerenderDynamic();
    case "add-refusal":
      state.refusals.push(blankRefusal());
      return rerenderDynamic();
    case "remove-refusal":
      if (state.refusals.length > 1) state.refusals.splice(Number(button.dataset.refusalIndex), 1);
      return rerenderDynamic();
    case "add-refusal-item":
      state.refusals[Number(button.dataset.refusalIndex)].items.push("");
      return rerenderDynamic();
    case "remove-refusal-item": {
      const refusal = state.refusals[Number(button.dataset.refusalIndex)];
      if (refusal.items.length > 2) refusal.items.splice(Number(button.dataset.itemIndex), 1);
      return rerenderDynamic();
    }
    case "add-happy-step":
      state.happyPath.push("");
      return rerenderDynamic();
    case "remove-happy-step":
      if (state.happyPath.length > 1) state.happyPath.splice(Number(button.dataset.stepIndex), 1);
      return rerenderDynamic();
    case "add-failure-step":
      state.failurePath.push("");
      return rerenderDynamic();
    case "remove-failure-step":
      if (state.failurePath.length > 1) state.failurePath.splice(Number(button.dataset.stepIndex), 1);
      return rerenderDynamic();
    case "add-risk":
      state.risks.push(blankRisk());
      return rerenderDynamic();
    case "remove-risk":
      if (state.risks.length > 1) state.risks.splice(Number(button.dataset.riskIndex), 1);
      return rerenderDynamic();
    default:
      return;
  }
}

function removeEntity(entityId) {
  state.entities = state.entities.filter((entity) => entity.id !== entityId);
  state.messages = state.messages.map((message) => ({
    ...message,
    fromId: message.fromId === entityId ? "" : message.fromId,
    toId: message.toId === entityId ? "" : message.toId,
  }));
  state.refusals = state.refusals.map((refusal) => ({
    ...refusal,
    entityId: refusal.entityId === entityId ? "" : refusal.entityId,
  }));
}

function nextEntityId() {
  const id = `entity-${state.nextEntityId}`;
  state.nextEntityId += 1;
  return id;
}

function rerenderDynamic(options = {}) {
  const focusState = options.preserveFocus ? captureFocusState() : null;
  renderDynamicLists();
  restoreFocusState(focusState);
  commit();
}

function commit(options = { persist: true }) {
  if (options.persist !== false) {
    saveState(state);
    persistStatus = `Saved in browser at ${timestampLabel()}`;
  }
  renderDerived();
}

function renderDynamicLists() {
  renderSlices();
  renderEntities();
  renderMessages();
  renderRefusals();
  elements.happyPathList.innerHTML = renderSteps(state.happyPath, "happy");
  elements.failurePathList.innerHTML = renderSteps(state.failurePath, "failure");
  renderRisks();
}

function renderSlices() {
  elements.sliceList.innerHTML = state.slices
    .map(
      (slice, index) => `
        <div class="slice-row slice-grid">
          ${textField("Slice name", slice.name, { sliceIndex: index, sliceField: "name" }, "walking skeleton")}
          ${textField("Risk first", slice.risk, { sliceIndex: index, sliceField: "risk" }, "What risk does this slice retire?")}
          ${textField("Proof", slice.proof, { sliceIndex: index, sliceField: "proof" }, "What end-to-end proof stays green?")}
          <button class="remove-button" data-action="remove-slice" data-slice-index="${index}">Remove</button>
        </div>
      `,
    )
    .join("");
}

function renderEntities() {
  elements.entityList.innerHTML = state.entities
    .map((entity) => {
      const term = termForId(entity.term);
      return `
        <div class="entity-card">
          <div class="entity-head">
            <span class="term-badge">${term.symbol} ${term.label}</span>
            <button class="remove-button" data-action="remove-entity" data-entity-id="${entity.id}">Remove role</button>
          </div>
          <p class="microcopy">${escapeHtml(term.teaching)}</p>
          <div class="entity-grid">
            ${selectField("Role term", entity.term, TERM_LIBRARY.map((item) => ({ value: item.id, label: `${item.symbol} ${item.label}` })), { entityId: entity.id, entityField: "term" })}
            ${textField("Role name", entity.name, { entityId: entity.id, entityField: "name" }, "VoucherRedemption")}
          </div>
          ${textAreaField("Responsibility", entity.responsibility, { entityId: entity.id, entityField: "responsibility" }, "Own the redemption decision and route the seams.")}
        </div>
      `;
    })
    .join("");
}

function renderMessages() {
  const entityOptions = [{ value: "", label: "Select role" }, ...state.entities.map((entity) => ({
    value: entity.id,
    label: `${termForId(entity.term).symbol} ${entity.name || "Unnamed role"}`,
  }))];

  elements.messageList.innerHTML = state.messages
    .map(
      (message, index) => `
        <div class="joint-row">
          <div class="joint-grid triple-grid">
            ${selectField("From", message.fromId, entityOptions, { messageIndex: index, messageField: "fromId" })}
            ${selectField("Operator", message.kind, MESSAGE_GRAMMAR.map((item) => ({ value: item.id, label: `${item.symbol} ${item.label}` })), { messageIndex: index, messageField: "kind" })}
            ${selectField("To", message.toId, entityOptions, { messageIndex: index, messageField: "toId" })}
            ${textField("Verb", message.verb, { messageIndex: index, messageField: "verb" }, "call")}
            ${textField("Args", message.args, { messageIndex: index, messageField: "args" }, "code:, cart_id:")}
            ${textField("Return shape", message.returnShape, { messageIndex: index, messageField: "returnShape" }, "[R] Result")}
            ${selectField("Owned?", message.owned, [
              { value: "yes", label: "yes" },
              { value: "no", label: "no" },
              { value: "dependency", label: "dependency" },
            ], { messageIndex: index, messageField: "owned" })}
            ${textField("Real default", message.realDefault, { messageIndex: index, messageField: "realDefault" }, "VoucherRepository.new")}
            ${textField("Test double", message.testDouble, { messageIndex: index, messageField: "testDouble" }, "FakeVoucherRepo")}
          </div>
          ${textAreaField("Notes", message.notes, { messageIndex: index, messageField: "notes" }, "What contract matters here?")}
          <button class="remove-button" data-action="remove-message" data-message-index="${index}">Remove message</button>
        </div>
      `,
    )
    .join("");
}

function renderRefusals() {
  const entityOptions = [{ value: "", label: "Select role" }, ...state.entities.map((entity) => ({
    value: entity.id,
    label: `${termForId(entity.term).symbol} ${entity.name || "Unnamed role"}`,
  }))];

  elements.refusalList.innerHTML = state.refusals
    .map(
      (refusal, refusalIndex) => `
        <div class="refusal-block">
          ${selectField("Role", refusal.entityId, entityOptions, { refusalIndex, refusalField: "entityId" })}
          <div class="stack">
            ${refusal.items
              .map(
                (item, itemIndex) => `
                  <div class="refusal-item-row">
                    <input
                      data-refusal-field="item"
                      data-refusal-index="${refusalIndex}"
                      data-item-index="${itemIndex}"
                      type="text"
                      value="${escapeHtml(item)}"
                      placeholder="Does NOT know persistence internals"
                    />
                    <button class="remove-button" data-action="remove-refusal-item" data-refusal-index="${refusalIndex}" data-item-index="${itemIndex}">Remove</button>
                  </div>
                `,
              )
              .join("")}
          </div>
          <div class="subhead">
            <button class="small-button" data-action="add-refusal-item" data-refusal-index="${refusalIndex}">Add refusal</button>
            <button class="remove-button" data-action="remove-refusal" data-refusal-index="${refusalIndex}">Remove role list</button>
          </div>
        </div>
      `,
    )
    .join("");
}

function renderRisks() {
  elements.risksList.innerHTML = state.risks
    .map(
      (risk, index) => `
        <div class="risk-row">
          <div class="risk-grid">
            ${textField("Risk", risk.risk, { riskIndex: index, riskField: "risk" }, "Controller bypasses the service")}
            ${selectField("Likelihood", risk.likelihood, [
              { value: "high", label: "high" },
              { value: "medium", label: "medium" },
              { value: "low", label: "low" },
            ], { riskIndex: index, riskField: "likelihood" })}
          </div>
          ${textAreaField("Mitigation", risk.mitigation, { riskIndex: index, riskField: "mitigation" }, "Hide persistence behind a port and keep acceptance tests honest.")}
          <button class="remove-button" data-action="remove-risk" data-risk-index="${index}">Remove risk</button>
        </div>
      `,
    )
    .join("");
}

function renderSteps(steps, kind) {
  return steps
    .map(
      (step, index) => `
        <div class="step-row">
          <input
            data-step-kind="${kind}"
            data-step-index="${index}"
            type="text"
            value="${escapeHtml(step)}"
            placeholder="? [C] Controller calls [O] Service"
          />
          <button class="remove-button" data-action="remove-${kind}-step" data-step-index="${index}">Remove</button>
        </div>
      `,
    )
    .join("");
}

function renderDerived() {
  const checklist = evaluateChecklist(state);
  const score = completionScore(checklist);
  const stations = evaluateStations(state, checklist);
  const firstIncomplete = checklist.find((item) => !item.passed);
  const acceptance = acceptanceArtifact(state);
  const bundle = starterFiles(state);
  const stateFile = stateExportFile(state);

  elements.readinessLabel.textContent = `${score}%`;
  elements.readinessFill.style.width = `${score}%`;
  elements.persistStatus.textContent = persistStatus;
  elements.stateExportName.textContent = stateFile.name;
  elements.bootstrapCommand.textContent = bootstrapCommand(stateFile.name);
  elements.readinessCopy.textContent = firstIncomplete
    ? `Live status: ${firstIncomplete.label}. ${firstIncomplete.detail}`
    : "Live status: the drill is coherent enough to export and turn the proof into a real acceptance test.";

  elements.plainGlossary.innerHTML = PLAIN_GLOSSARY
    .map(
      (item) => `
        <div class="glossary-item">
          <span class="glossary-term">${escapeHtml(item.term)}</span>
          <span class="glossary-plain">${escapeHtml(item.plain)}</span>
        </div>
      `,
    )
    .join("");

  elements.exportMap.innerHTML = buildExportGuide(state)
    .map(
      (item) => `
        <div class="export-item">
          <span class="export-name">${escapeHtml(item.artifact)}</span>
          <span class="export-meta">${escapeHtml(item.stations)}</span>
          <span class="export-meaning">${escapeHtml(item.meaning)}</span>
        </div>
      `,
    )
    .join("");

  elements.stationRail.innerHTML = stations
    .map(
      (station) => `
        <article class="station-chip ${station.ready ? "is-ready" : ""} ${firstIncomplete && station.id === stationForChecklist(firstIncomplete.key) ? "is-active" : ""}">
          <span class="chip-index">${station.id}</span>
          <strong class="chip-title">${station.title}</strong>
          <span class="chip-detail">${escapeHtml(station.detail)}</span>
        </article>
      `,
    )
    .join("");

  elements.checklist.innerHTML = checklist
    .map(
      (item) => `
        <div class="check-item ${item.passed ? "is-pass" : ""}">
          <span class="check-label">${item.passed ? "PASS" : "HOLD"} · ${item.label}</span>
          <span class="check-detail">Live check: ${escapeHtml(item.detail)}</span>
        </div>
      `,
    )
    .join("");

  elements.symbolLegend.textContent = renderSymbolLegend(state);
  elements.coachPrompts.innerHTML = STATION_GUIDES
    .map(
      (guide) => `
        <article class="coach-card">
          <p class="coach-index">Station ${guide.id} · ${guide.title}</p>
          <p class="coach-question">${escapeHtml(guide.question)}</p>
          <p class="coach-artifact">${escapeHtml(guide.artifact)}</p>
          <p class="coach-prompt">${escapeHtml(guide.prompts.join(" "))}</p>
        </article>
      `,
    )
    .join("");

  elements.diagramPreview.textContent = buildDiagram(state);
  elements.missionPreview.textContent = serializeMission(state);
  elements.bodyPlanPreview.textContent = serializeBodyPlan(state);
  elements.acceptanceArtifactName.textContent = acceptance.path;
  elements.acceptancePreview.textContent = acceptance.content;
  elements.bootstrapPreview.textContent = serializeWorkshopBootstrap(state);
  elements.bundlePreview.textContent = bundle
    .map((file) => `${file.path}\n`)
    .join("\n");
}

function stationForChecklist(key) {
  const map = {
    "one-screen": 3,
    "one-sentence": 1,
    "refusal-list": 5,
    "joint-completeness": 4,
    "walk-test": 6,
    "red-shape": 6,
    "bypass-audit": 7,
    "timer": 7,
  };
  return map[key];
}

function textField(label, value, dataset, placeholder = "") {
  const attributes = dataAttributes(dataset);
  return `
    <label>
      ${label}
      <input ${attributes} type="text" value="${escapeHtml(value)}" placeholder="${escapeHtml(placeholder)}" />
    </label>
  `;
}

function textAreaField(label, value, dataset, placeholder = "") {
  const attributes = dataAttributes(dataset);
  return `
    <label>
      ${label}
      <textarea ${attributes} rows="3" placeholder="${escapeHtml(placeholder)}">${escapeHtml(value)}</textarea>
    </label>
  `;
}

function selectField(label, value, options, dataset) {
  const attributes = dataAttributes(dataset);
  const optionMarkup = options
    .map((option) => {
      const normalized = typeof option === "string" ? { value: option, label: option } : option;
      return `<option value="${escapeHtml(normalized.value)}" ${normalized.value === value ? "selected" : ""}>${escapeHtml(normalized.label)}</option>`;
    })
    .join("");

  return `
    <label>
      ${label}
      <select ${attributes}>${optionMarkup}</select>
    </label>
  `;
}

function dataAttributes(dataset) {
  return Object.entries(dataset)
    .map(([key, entry]) => `data-${kebabCase(key)}="${escapeHtml(String(entry))}"`)
    .join(" ");
}

function kebabCase(text) {
  return text.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`);
}

function escapeHtml(text) {
  return String(text)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

async function copyText(text) {
  try {
    await navigator.clipboard.writeText(text);
  } catch {
    const fallback = document.createElement("textarea");
    fallback.value = text;
    document.body.appendChild(fallback);
    fallback.select();
    document.execCommand("copy");
    fallback.remove();
  }
}

function downloadBundle(files) {
  files.forEach((file, index) => {
    window.setTimeout(() => {
      downloadFile({
        name: downloadNameFor(file.path),
        content: file.content,
      });
    }, index * 120);
  });
}

function downloadNameFor(path) {
  return path.split("/").pop() || path;
}

function entityFieldRequiresRerender(field) {
  return field === "term" || field === "name";
}

function downloadFile(file) {
  const blob = new Blob([file.content], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = file.name;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function stateExportFile(currentState) {
  const bundle = starterFiles(currentState);
  const stateArtifact = bundle.find((file) => file.path.endsWith(".json"));
  return {
    name: downloadNameFor(stateArtifact?.path || "workshop-project-rock-drill.json"),
    content: stateArtifact?.content || "{}",
  };
}

function bootstrapCommand(fileOrName) {
  const fileName = typeof fileOrName === "string" ? fileOrName : stateExportFile(state).name;
  return `npm run bootstrap -- /path/to/${fileName} --launch-tmux`;
}

function timestampLabel() {
  return new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
}

if (!state) {
  state = createInitialState();
}

function captureFocusState() {
  const active = document.activeElement;
  if (!(active instanceof HTMLElement)) return null;

  const selector = elementSelector(active);
  if (!selector) return null;

  const focusState = { selector };
  if (active instanceof HTMLInputElement || active instanceof HTMLTextAreaElement) {
    focusState.selectionStart = active.selectionStart;
    focusState.selectionEnd = active.selectionEnd;
  }

  return focusState;
}

function restoreFocusState(focusState) {
  if (!focusState) return;

  const element = document.querySelector(focusState.selector);
  if (!(element instanceof HTMLElement)) return;

  element.focus();
  if (
    typeof focusState.selectionStart === "number" &&
    typeof focusState.selectionEnd === "number" &&
    (element instanceof HTMLInputElement || element instanceof HTMLTextAreaElement)
  ) {
    element.setSelectionRange(focusState.selectionStart, focusState.selectionEnd);
  }
}

function elementSelector(element) {
  if (element.id) return `#${element.id}`;

  const dataKeys = [
    "sliceIndex",
    "sliceField",
    "entityId",
    "entityField",
    "messageIndex",
    "messageField",
    "refusalIndex",
    "refusalField",
    "itemIndex",
    "stepKind",
    "stepIndex",
    "riskIndex",
    "riskField",
  ];

  const parts = dataKeys
    .filter((key) => element.dataset[key] !== undefined)
    .map((key) => `[data-${kebabCase(key)}="${CSS.escape(element.dataset[key])}"]`);

  return parts.length > 0 ? parts.join("") : null;
}
