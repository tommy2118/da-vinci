export const STORAGE_KEY = "workshop.visual-rockdrill.state";

export const TERM_LIBRARY = [
  {
    id: "caller",
    symbol: "[C]",
    label: "Caller",
    role: "entry point",
    teaching: "The entry point. It receives the request and hands it into your design.",
  },
  {
    id: "owned",
    symbol: "[O]",
    label: "Core object",
    role: "decision owner",
    teaching: "A role in your code that owns a decision or coordinates other parts.",
  },
  {
    id: "port",
    symbol: "[P]",
    label: "Port",
    role: "owned seam",
    teaching: "An interface you own at a boundary. Fakes usually plug in here.",
  },
  {
    id: "adapter",
    symbol: "[A]",
    label: "Adapter",
    role: "wrapper",
    teaching: "A wrapper around an outside system such as HTTP, a queue, or a database client.",
  },
  {
    id: "external",
    symbol: "[E]",
    label: "External",
    role: "unowned system",
    teaching: "A framework, vendor, or system you do not control.",
  },
  {
    id: "value",
    symbol: "[V]",
    label: "Value object",
    role: "data shape",
    teaching: "A small data shape that should not know transport or workflow details.",
  },
  {
    id: "result",
    symbol: "[R]",
    label: "Result",
    role: "outcome contract",
    teaching: "The outcome contract the outside world sees.",
  },
  {
    id: "dependency",
    symbol: "[D]",
    label: "Injected dependency",
    role: "explicit dependency",
    teaching: "A clock, config, ID generator, logger, or queue made explicit instead of hidden as a global.",
  },
];

export const MESSAGE_GRAMMAR = [
  {
    id: "call",
    symbol: "->",
    label: "Direct call",
    teaching: "One part of your design calling another part you own.",
  },
  {
    id: "handoff",
    symbol: "=>",
    label: "Boundary handoff",
    teaching: "Crossing a seam into a port, adapter, or outside system.",
  },
  {
    id: "publish",
    symbol: "~>",
    label: "Publish / notify",
    teaching: "Sending an event or notification to another collaborator.",
  },
];

export const PLAIN_GLOSSARY = [
  {
    term: "Rock drill",
    plain: "A guided rehearsal before coding.",
  },
  {
    term: "Body plan",
    plain: "The shape of the system: roles, seams, and message flow.",
  },
  {
    term: "Slice",
    plain: "The smallest end-to-end increment worth proving.",
  },
  {
    term: "Walking skeleton",
    plain: "The thinnest end-to-end slice that proves the stack is wired.",
  },
  {
    term: "Seam",
    plain: "A boundary where you can swap one collaborator for another.",
  },
  {
    term: "Joints",
    plain: "The specific message links between roles at those boundaries.",
  },
  {
    term: "Refusal list",
    plain: "A list of what a role must not know.",
  },
];

export const EXPORT_GUIDE = [
  {
    artifact: "MISSION.md",
    stations: "Stations 1-2",
    meaning: "Defines the behavior and the slice order.",
  },
  {
    artifact: "BODY_PLAN.md",
    stations: "Stations 3-7",
    meaning: "Captures roles, seams, proof steps, and bypass risks.",
  },
  {
    artifact: "spec/acceptance_spec.rb",
    stations: "Station 6",
    meaning: "Turns the proof step into the first real end-to-end test.",
  },
];

export const ACCEPTANCE_STYLES = [
  {
    id: "rspec",
    label: "Ruby / RSpec",
    artifact: "spec/acceptance/%SLICE%_spec.rb",
  },
  {
    id: "node_test",
    label: "Node / node:test",
    artifact: "test/%SLICE%.test.mjs",
  },
  {
    id: "pytest",
    label: "Python / pytest",
    artifact: "tests/test_%SLICE%.py",
  },
  {
    id: "plain_text",
    label: "Plain-text proof",
    artifact: "acceptance/%SLICE%.md",
  },
];

export const STATIONS = [
  { id: 1, title: "Mission" },
  { id: 2, title: "Slices" },
  { id: 3, title: "Draw" },
  { id: 4, title: "Joints" },
  { id: 5, title: "Refusal Lists" },
  { id: 6, title: "Walk" },
  { id: 7, title: "Bypass Audit" },
];

export const STATION_GUIDES = [
  {
    id: 1,
    title: "Mission",
    question: "What behavior are we designing?",
    artifact: "One sentence: behavior in -> behavior out.",
    prompts: [
      "State the work level: problem, initiative, epic, or task.",
      "Avoid implementation words. Name behavior only.",
    ],
  },
  {
    id: 2,
    title: "Slices",
    question: "What should we prove first?",
    artifact: "3–5 slices ordered by risk. Slice 1 is the walking skeleton.",
    prompts: [
      "Capture what each slice proves end to end.",
      "Risk first, not polish first.",
    ],
  },
  {
    id: 3,
    title: "Draw",
    question: "Can we name the parts clearly?",
    artifact: "Named roles using the codified symbol grammar.",
    prompts: [
      "Every role gets a term: [C], [O], [P], [A], [E], [V], [R], or [D].",
      "Name the decision owner. Name the data carrier. Keep it one screen.",
    ],
  },
  {
    id: 4,
    title: "Joints",
    question: "Where are the seams?",
    artifact: "Messages with operator, return shape, real default, and test double.",
    prompts: [
      "Use -> for owned calls, => for handoffs, and ~> for publication.",
      "Every seam names the real default and the test double.",
    ],
  },
  {
    id: 5,
    title: "Refusal Lists",
    question: "What must each role stay ignorant of?",
    artifact: "At least 2 refusal bullets per named role.",
    prompts: [
      "Write the refusal in negative form: Does NOT know ...",
      "If a role has no refusal list, it is only named, not designed.",
    ],
  },
  {
    id: 6,
    title: "Walk",
    question: "Can the design run end to end?",
    artifact: "Happy path + failure path proof using the role symbols.",
    prompts: [
      "Start each proof step with a symbol tag like [C] or [O].",
      "End with an assertion that would make a real acceptance test fail honestly.",
    ],
  },
  {
    id: 7,
    title: "Bypass Audit",
    question: "Where might someone bypass the design later?",
    artifact: "At least 3 named risks with mitigations.",
    prompts: [
      "Audit where a tired developer might add a second path around the design.",
      "Record the timer truthfully before you export.",
    ],
  },
];

export function createInitialState() {
  return {
    projectName: "",
    projectSlug: "",
    acceptanceStyle: "rspec",
    bootstrapNotes: "",
    missionName: "",
    workLevel: "task",
    missionStatement: "",
    sliceNumber: "01",
    sliceName: "walking skeleton",
    scopeReminder: "",
    slices: [
      blankSlice({ name: "walking skeleton" }),
      blankSlice(),
      blankSlice(),
    ],
    nextEntityId: 3,
    entities: [
      blankEntity("entity-1", "caller"),
      blankEntity("entity-2", "owned"),
    ],
    messages: [blankMessage()],
    refusals: [blankRefusal()],
    happyPath: [""],
    failurePath: [""],
    acceptanceTitle: "",
    acceptanceAssertion: "",
    risks: [blankRisk(), blankRisk(), blankRisk()],
    timerChecked: false,
  };
}

export function blankSlice(overrides = {}) {
  return {
    name: "",
    risk: "",
    proof: "",
    ...overrides,
  };
}

export function blankEntity(id, term = "owned") {
  return {
    id,
    term,
    name: "",
    responsibility: "",
  };
}

export function blankMessage(overrides = {}) {
  return {
    fromId: "",
    kind: "call",
    toId: "",
    verb: "",
    args: "",
    returnShape: "",
    owned: "yes",
    realDefault: "",
    testDouble: "",
    notes: "",
    ...overrides,
  };
}

export function blankRefusal(overrides = {}) {
  return {
    entityId: "",
    items: ["", ""],
    ...overrides,
  };
}

export function blankRisk(overrides = {}) {
  return {
    risk: "",
    likelihood: "medium",
    mitigation: "",
    ...overrides,
  };
}

export function loadState(storage = globalThis.localStorage) {
  const raw = storage?.getItem?.(STORAGE_KEY);
  if (!raw) return createInitialState();

  try {
    return hydrateState(JSON.parse(raw));
  } catch {
    return createInitialState();
  }
}

export function saveState(state, storage = globalThis.localStorage) {
  storage?.setItem?.(STORAGE_KEY, JSON.stringify(state));
}

export function resetState(storage = globalThis.localStorage) {
  storage?.removeItem?.(STORAGE_KEY);
  return createInitialState();
}

export function hydrateState(candidate = {}) {
  const initial = createInitialState();
  const entities = normalizeEntities(candidate.entities, initial.entities);

  return {
    ...initial,
    ...candidate,
    projectName: String(candidate.projectName ?? ""),
    projectSlug: String(candidate.projectSlug ?? ""),
    acceptanceStyle: normalizeAcceptanceStyle(candidate.acceptanceStyle),
    bootstrapNotes: String(candidate.bootstrapNotes ?? ""),
    workLevel: normalizeWorkLevel(candidate.workLevel),
    slices: normalizeSlices(candidate.slices, initial.slices),
    nextEntityId: normalizeNextEntityId(candidate.nextEntityId, entities),
    entities,
    messages: normalizeMessages(candidate.messages),
    refusals: normalizeRefusals(candidate.refusals, entities),
    happyPath: normalizeStringList(candidate.happyPath, initial.happyPath),
    failurePath: normalizeStringList(candidate.failurePath, initial.failurePath),
    risks: normalizeRisks(candidate.risks),
    timerChecked: Boolean(candidate.timerChecked),
  };
}

export function evaluateChecklist(state) {
  const diagram = buildDiagram(state);
  const oneScreen = evaluateOneScreen(diagram);
  const scopeSentence = isSingleSentence(state.scopeReminder);
  const missionSentence = isSingleSentence(state.missionStatement);
  const namedEntities = state.entities.filter((entity) => entity.name.trim());
  const completeMessages = state.messages.filter(isMessageComplete);
  const fullRefusals = namedEntities.filter((entity) => entityHasRefusal(state, entity.id));
  const happySteps = filledStrings(state.happyPath);
  const failureSteps = filledStrings(state.failurePath);
  const symbolProof = happySteps.every(hasSymbolLead) && failureSteps.every(hasSymbolLead);
  const completeRisks = state.risks.filter(isRiskComplete);
  const redShape = hasRealAssertion(state.acceptanceAssertion);

  return [
    {
      key: "one-screen",
      label: "One-screen test",
      passed: oneScreen.passed,
      detail: oneScreen.detail,
    },
    {
      key: "one-sentence",
      label: "One-sentence test",
      passed: missionSentence && scopeSentence,
      detail: missionSentence && scopeSentence
        ? "Mission statement and scope reminder both read as one sentence."
        : "Mission statement and scope reminder both need to read as one sentence.",
    },
    {
      key: "refusal-list",
      label: "Refusal-list completeness",
      passed: namedEntities.length > 0 && namedEntities.length === fullRefusals.length,
      detail: namedEntities.length === 0
        ? "Name at least one role before writing refusal lists."
        : `${fullRefusals.length}/${namedEntities.length} named roles have 2+ refusal bullets.`,
    },
    {
      key: "joint-completeness",
      label: "Joint completeness",
      passed: completeMessages.length > 0 && completeMessages.length === state.messages.length,
      detail: `${completeMessages.length}/${state.messages.length} messages name the seam, real default, and test double.`,
    },
    {
      key: "walk-test",
      label: "Walk test",
      passed: happySteps.length >= 2 && failureSteps.length >= 1 && symbolProof,
      detail: `Happy path: ${happySteps.length} steps. Failure path: ${failureSteps.length} steps. Prefix proof lines with [symbol] tags.`,
    },
    {
      key: "red-shape",
      label: "Red-shape test",
      passed: redShape,
      detail: redShape
        ? "Acceptance assertion includes expect(...) and no template placeholder."
        : "Draft a real expect(...) assertion and remove placeholder text.",
    },
    {
      key: "bypass-audit",
      label: "Bypass-audit honesty",
      passed: completeRisks.length >= 3,
      detail: `${completeRisks.length} complete risks captured; target at least 3.`,
    },
    {
      key: "timer",
      label: "Timer test",
      passed: state.timerChecked,
      detail: state.timerChecked
        ? "Timer check marked."
        : "Confirm the drill stayed under about 30 minutes.",
    },
  ];
}

export function completionScore(checklist) {
  const passed = checklist.filter((item) => item.passed).length;
  return Math.round((passed / checklist.length) * 100);
}

export function evaluateStations(state, checklist) {
  const byKey = Object.fromEntries(checklist.map((item) => [item.key, item]));
  const completeSlices = state.slices.filter(isSliceComplete);
  const namedEntities = state.entities.filter((entity) => entity.name.trim());
  const completeMessages = state.messages.filter(isMessageComplete);
  const firstSlice = state.slices[0]?.name.toLowerCase() ?? "";

  return [
    {
      id: 1,
      title: "Mission",
      ready: Boolean(state.missionStatement.trim()) && byKey["one-sentence"].passed,
      detail: `Work level: ${titleize(state.workLevel)}. ${state.missionStatement.trim() || "One sentence: behavior in -> behavior out."}`,
    },
    {
      id: 2,
      title: "Slices",
      ready: completeSlices.length >= 3 && completeSlices.length <= 5 && /skeleton/i.test(firstSlice),
      detail: completeSlices.length
        ? `${pluralize(completeSlices.length, "complete slice", "complete slices")}. Put the walking skeleton first.`
        : "Write 3–5 complete slices with risk and proof.",
    },
    {
      id: 3,
      title: "Draw",
      ready: namedEntities.length >= 3 && byKey["one-screen"].passed,
      detail: `${namedEntities.length} named roles. ${byKey["one-screen"].detail}`,
    },
    {
      id: 4,
      title: "Joints",
      ready: completeMessages.length >= 2 && byKey["joint-completeness"].passed,
      detail: `${pluralize(completeMessages.length, "complete message", "complete messages")}. ${byKey["joint-completeness"].detail}`,
    },
    {
      id: 5,
      title: "Refusal Lists",
      ready: byKey["refusal-list"].passed,
      detail: byKey["refusal-list"].detail,
    },
    {
      id: 6,
      title: "Walk",
      ready: byKey["walk-test"].passed && byKey["red-shape"].passed,
      detail: `${byKey["walk-test"].detail} ${byKey["red-shape"].detail}`,
    },
    {
      id: 7,
      title: "Bypass Audit",
      ready: byKey["bypass-audit"].passed && byKey["timer"].passed,
      detail: `${byKey["bypass-audit"].detail} ${byKey["timer"].detail}`,
    },
  ];
}

export function buildDiagram(state) {
  const entityLines = state.entities
    .filter((entity) => entity.name.trim() || entity.responsibility.trim())
    .map((entity) => `${termSymbol(entity.term)} ${entity.name.trim() || "Unnamed role"} :: ${entity.responsibility.trim() || "[responsibility]"}`);

  const messageLines = state.messages
    .filter((message) => hasAnyMessageShape(message))
    .map((message) => {
      const from = entityToken(state, message.fromId);
      const to = entityToken(state, message.toId);
      const operator = messageSymbol(message.kind);
      const verb = message.verb.trim() || "[message]";
      const args = message.args.trim();
      const returnShape = message.returnShape.trim() || "[return]";
      return `${from} ${operator} ${to}#${verb}${args ? `(${args})` : ""} returns ${returnShape}`;
    });

  return [...entityLines, "", ...messageLines].filter(Boolean).join("\n");
}

export function buildExportGuide(state) {
  const paths = workshopPaths(state);
  return [
    {
      artifact: paths.missionPath,
      stations: "Stations 1-2",
      meaning: "Defines the mission and the shipping order for slices.",
    },
    {
      artifact: paths.bodyPlanPath,
      stations: "Stations 3-7",
      meaning: "Captures the slice body plan in the exact workshop slice directory.",
    },
    {
      artifact: paths.acceptancePath,
      stations: "Station 6",
      meaning: "Ends the drill with the acceptance spec that `bin/drill-check` expects.",
    },
    {
      artifact: paths.bootstrapPath,
      stations: "Whole drill",
      meaning: "Tells you how to create the mission, the first slice, and the tmux session.",
    },
  ];
}

export function renderSymbolLegend(state) {
  const terms = usedTermDefinitions(state)
    .map((term) => `${term.symbol} ${term.label} — ${term.teaching}`)
    .join("\n");
  const grammar = MESSAGE_GRAMMAR
    .map((message) => `${message.symbol} ${message.label} — ${message.teaching}`)
    .join("\n");

  return `${terms}\n\n${grammar}\n! refusal bullet — what a role refuses to know\n? proof step — a line that can become a test`;
}

export function serializeMission(state) {
  const name = state.missionName.trim() || "unnamed_mission";
  const statement = state.missionStatement.trim() || "[one sentence mission statement]";
  const slices = state.slices.filter(hasAnySliceShape);
  const numbered = slices.length
    ? slices.map((slice, index) => {
      const title = slice.name.trim() || `[slice ${index + 1}]`;
      const risk = slice.risk.trim() || "[risk first]";
      const proof = slice.proof.trim() || "[end-to-end proof]";
      return `${index + 1}. ${title}\n   Risk first: ${risk}\n   Proof: ${proof}`;
    }).join("\n")
    : "1. walking skeleton\n   Risk first: [wiring]\n   Proof: [real app path goes end to end]";

  return `# Mission — ${name}

> Work level: \`${state.workLevel}\`

## Station 1 — Mission

${statement}

## Station 2 — Slice list

${numbered}
`;
}

export function serializeBodyPlan(state) {
  const checklist = evaluateChecklist(state);
  const missionName = state.missionName.trim() || "mission_name";
  const sliceNumber = state.sliceNumber.trim() || "01";
  const sliceName = state.sliceName.trim() || "slice_name";
  const scopeReminder = state.scopeReminder.trim() || "[scope reminder]";
  const grammar = usedTermDefinitions(state)
    .map((term) => `- ${term.symbol} ${term.label} — ${term.role}`)
    .join("\n");
  const joints = serializeJoints(state);
  const refusals = serializeRefusals(state);
  const happyPath = serializeSteps(state.happyPath);
  const failurePath = serializeSteps(state.failurePath);
  const risks = serializeRisks(state.risks);
  const checklistText = checklist
    .map((item) => `- [${item.passed ? "x" : " "}] ${item.label} — ${item.detail}`)
    .join("\n");

  return `# Slice ${sliceNumber} — ${titleize(sliceName)}: Body Plan

> Mission: \`${missionName}\` (see \`../MISSION.md\`).
> Work level: \`${state.workLevel}\`.
> Drilled per \`ROCK_DRILL_PROTOCOL.md\`, stations 3–7.

**Scope reminder**: ${scopeReminder}

---

## Codified grammar

${grammar}
- -> owned call
- => handoff across a seam
- ~> publication / notification
- returns outcome shape
- ! refusal bullet
- ? proof step

## Station 3 — Draw

\`\`\`
${buildDiagram(state) || "[body plan generated from role terms and message grammar]"}
\`\`\`

## Station 4 — Joints

| Arrow | Owned? | Real default | Test double | Notes |
|-------|--------|--------------|-------------|-------|
${joints}

## Station 5 — Refusal lists

${refusals}

## Station 6 — Walk

### Happy path
${happyPath}

### One failure path
${failurePath}

## Station 7 — Bypass audit

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
${risks}

---

## Verification checklist

${checklistText}
`;
}

export function serializeAcceptanceSpec(state) {
  const style = normalizeAcceptanceStyle(state.acceptanceStyle);
  switch (style) {
    case "node_test":
      return serializeNodeAcceptanceSpec(state);
    case "pytest":
      return serializePytestAcceptanceSpec(state);
    case "plain_text":
      return serializePlainAcceptanceSpec(state);
    case "rspec":
    default:
      return serializeRSpecAcceptanceSpec(state);
  }
}

export function acceptanceArtifact(state) {
  const style = acceptanceStyleForId(state.acceptanceStyle);
  const workshop = workshopPaths(state);
  return {
    style: style.id,
    label: style.label,
    path: style.id === "rspec"
      ? workshop.acceptancePath
      : style.artifact.replace("%SLICE%", acceptanceFileStem(state)),
    content: serializeAcceptanceSpec(state),
  };
}

export function starterFiles(state) {
  const slug = projectSlugFor(state);
  const baseFiles = starterBaseFiles(state);
  const paths = workshopPaths(state);
  return [
    ...baseFiles,
    {
      path: paths.bootstrapPath,
      content: serializeWorkshopBootstrap(state),
    },
    {
      path: `${paths.missionDir}/.workshop/${slug}-rock-drill.json`,
      content: JSON.stringify(exportableState(state), null, 2),
    },
  ];
}

export function serializeWorkshopBootstrap(state) {
  const projectName = projectNameFor(state);
  const projectSlug = projectSlugFor(state);
  const paths = workshopPaths(state);
  const baseFiles = starterBaseFiles(state);
  const sliceLabel = `${state.sliceNumber.trim() || "01"} ${state.sliceName.trim() || "walking skeleton"}`;
  const completeSlices = state.slices.filter(hasAnySliceShape);
  const happyPath = serializeSteps(state.happyPath);
  const risks = state.risks.filter((risk) => risk.risk.trim() || risk.mitigation.trim());
  const notes = state.bootstrapNotes.trim();
  const files = [...baseFiles, { path: paths.bootstrapPath }]
    .map((file) => `- \`${file.path}\``)
    .join("\n");
  const firstDirectories = directoryListFor([...baseFiles, { path: paths.bootstrapPath }])
    .map((directory) => `- \`${directory}\``)
    .join("\n");
  const sliceChecklist = completeSlices.length
    ? completeSlices.map((slice, index) => `${index + 1}. ${slice.name.trim() || `[slice ${index + 1}]`} — ${slice.proof.trim() || "[proof]"}`).join("\n")
    : "1. walking skeleton — [end-to-end proof]";
  const riskLines = risks.length
    ? risks.map((risk) => `- ${risk.risk.trim() || "[risk]"} -> ${risk.mitigation.trim() || "[mitigation]"}`).join("\n")
    : "- [risk] -> [mitigation]";

  return `# Workshop Start — ${projectName}

> Repo slug: \`${projectSlug}\`
> Workshop slice dir: \`${paths.sliceDir}\`
> First slice: \`${sliceLabel}\`

## Bootstrap intent

${state.missionStatement.trim() || "[one sentence mission statement]"}

## Create these directories first

${firstDirectories}

## Create these starter files

${files}

## Suggested startup order

1. Download the starter bundle so you have the drill JSON export.
2. Run \`npm run bootstrap -- /path/to/${projectSlug}-rock-drill.json --launch-tmux\`.
3. If you skip the CLI, create \`${paths.missionDir}\` and \`${paths.sliceDir}\` manually, then write the files listed below.
4. Run \`../bin/drill-check ${paths.sliceDir}\`.
5. Make the acceptance file fail honestly before adding implementation.
6. Build only the walking skeleton named in this drill.

## Slice order

${sliceChecklist}

## Walking skeleton proof

${happyPath}

## Risk watchlist

${riskLines}

## Acceptance artifact

\`${paths.acceptancePath}\`

## Workshop commands

\`\`\`bash
npm run bootstrap -- /path/to/${projectSlug}-rock-drill.json --launch-tmux
../bin/drill-check ${paths.sliceDir}
\`\`\`

## Manual fallback

\`\`\`bash
mkdir -p ${paths.sliceDir}/spec
\$EDITOR ${paths.missionPath} ${paths.bodyPlanPath} ${paths.acceptancePath}
../bin/workshop ${paths.sliceDir}
\`\`\`

## Bootstrap notes

${notes || "No extra bootstrap notes captured."}
`;
}

function serializeRSpecAcceptanceSpec(state) {
  const missionName = state.missionName.trim() || "mission_name";
  const sliceNumber = state.sliceNumber.trim() || "01";
  const sliceName = state.sliceName.trim() || "slice_name";
  const title = state.acceptanceTitle.trim() || filledStrings(state.happyPath)[0] || "pins the happy path from the rock drill";
  const assertion = state.acceptanceAssertion.trim() || "expect(response).to have_http_status(:ok)";

  return `# frozen_string_literal: true

require "spec_helper"

# Proof grammar:
# ? [C]/[O]/[P] lines in BODY_PLAN.md become real assertions here.

RSpec.describe "${missionName} — slice ${sliceNumber}: ${sliceName}" do
  it "${escapeDoubleQuotes(title)}" do
${indent(assertion, 4)}
  end
end
`;
}

function serializeNodeAcceptanceSpec(state) {
  const title = state.acceptanceTitle.trim() || filledStrings(state.happyPath)[0] || "pins the happy path from the rock drill";
  const proofSteps = filledStrings(state.happyPath).map((step) => `// ${step}`).join("\n");
  const fallback = [
    'const response = { status: 200, body: { result: "applied" } };',
    "assert.equal(response.status, 200);",
    'assert.deepEqual(response.body, { result: "applied" });',
  ].join("\n");
  const assertion = state.acceptanceAssertion.trim() || fallback;

  return `import test from "node:test";
import assert from "node:assert/strict";

test("${escapeSingleQuotes(title)}", async () => {
${proofSteps ? `${indent(proofSteps, 2)}\n` : ""}${indent(assertion, 2)}
});
`;
}

function serializePytestAcceptanceSpec(state) {
  const title = state.acceptanceTitle.trim() || filledStrings(state.happyPath)[0] || "pins the happy path from the rock drill";
  const testName = pythonTestName(title);
  const proofSteps = filledStrings(state.happyPath).map((step) => `    # ${step}`).join("\n");
  const fallback = [
    "response = {\"status\": 200, \"body\": {\"result\": \"applied\"}}",
    "assert response[\"status\"] == 200",
    "assert response[\"body\"] == {\"result\": \"applied\"}",
  ].join("\n");
  const assertion = state.acceptanceAssertion.trim() || fallback;

  return `def ${testName}():
${proofSteps ? `${proofSteps}\n` : ""}${indent(assertion, 4)}
`;
}

function serializePlainAcceptanceSpec(state) {
  const missionName = state.missionName.trim() || "mission_name";
  const title = state.acceptanceTitle.trim() || filledStrings(state.happyPath)[0] || "pins the happy path from the rock drill";
  const happyPath = serializeSteps(state.happyPath);
  const failurePath = serializeSteps(state.failurePath);
  const assertion = state.acceptanceAssertion.trim() || "expect(response).to have_http_status(:ok)";

  return `# Acceptance Proof — ${missionName}

## Scenario

${title}

## Happy path

${happyPath}

## Failure path

${failurePath}

## Assertion shape

\`\`\`
${assertion}
\`\`\`
`;
}

export function termForId(id) {
  return TERM_LIBRARY.find((term) => term.id === id) || TERM_LIBRARY[1];
}

export function messageForId(id) {
  return MESSAGE_GRAMMAR.find((message) => message.id === id) || MESSAGE_GRAMMAR[0];
}

export function usedTermDefinitions(state) {
  const ids = new Set(state.entities.map((entity) => entity.term));
  ids.add("result");
  return TERM_LIBRARY.filter((term) => ids.has(term.id));
}

function normalizeWorkLevel(level) {
  return ["problem", "initiative", "epic", "task"].includes(level) ? level : "task";
}

function normalizeSlices(candidate, fallback) {
  if (!Array.isArray(candidate) || candidate.length === 0) return fallback.map((slice) => ({ ...slice }));
  return candidate.map((slice) => {
    if (typeof slice === "string") return blankSlice({ name: slice });
    return blankSlice(slice ?? {});
  });
}

function normalizeEntities(candidate, fallback) {
  if (!Array.isArray(candidate) || candidate.length === 0) return fallback.map((entity) => ({ ...entity }));
  return candidate.map((entity, index) => ({
    id: String(entity?.id ?? `entity-${index + 1}`),
    term: normalizeTermId(entity?.term),
    name: String(entity?.name ?? ""),
    responsibility: String(entity?.responsibility ?? ""),
  }));
}

function normalizeMessages(candidate) {
  if (!Array.isArray(candidate) || candidate.length === 0) return [blankMessage()];
  return candidate.map((message) => {
    if (typeof message?.arrow === "string") {
      return blankMessage({
        verb: message.arrow,
        owned: message.owned ?? "yes",
        realDefault: message.realDefault,
        testDouble: message.testDouble,
        notes: message.notes,
      });
    }

    return blankMessage({
      fromId: String(message?.fromId ?? ""),
      kind: messageForId(message?.kind ?? "call").id,
      toId: String(message?.toId ?? ""),
      verb: String(message?.verb ?? ""),
      args: String(message?.args ?? ""),
      returnShape: String(message?.returnShape ?? ""),
      owned: normalizeOwnedValue(message?.owned),
      realDefault: String(message?.realDefault ?? ""),
      testDouble: String(message?.testDouble ?? ""),
      notes: String(message?.notes ?? ""),
    });
  });
}

function normalizeRefusals(candidate, entities) {
  if (!Array.isArray(candidate) || candidate.length === 0) return [blankRefusal()];
  return candidate.map((refusal) => {
    const legacyEntity = entities.find((entity) => entity.name === refusal?.name);
    return blankRefusal({
      entityId: String(refusal?.entityId ?? legacyEntity?.id ?? ""),
      items: normalizeStringList(refusal?.items, ["", ""]),
    });
  });
}

function normalizeRisks(candidate) {
  if (!Array.isArray(candidate) || candidate.length === 0) return [blankRisk(), blankRisk(), blankRisk()];
  return candidate.map((risk) => blankRisk(risk ?? {}));
}

function normalizeStringList(candidate, fallback) {
  if (!Array.isArray(candidate) || candidate.length === 0) return [...fallback];
  return candidate.map((item) => String(item ?? ""));
}

function normalizeNextEntityId(candidate, entities) {
  const numeric = Number(candidate);
  if (Number.isInteger(numeric) && numeric > 0) return numeric;
  const maxId = entities.reduce((max, entity) => {
    const numericId = Number(String(entity.id).split("-").pop());
    return Number.isFinite(numericId) ? Math.max(max, numericId) : max;
  }, 0);
  return maxId + 1;
}

function normalizeOwnedValue(value) {
  if (value === "nerve") return "dependency";
  return ["yes", "no", "dependency"].includes(value) ? value : "yes";
}

function normalizeAcceptanceStyle(value) {
  return acceptanceStyleForId(value).id;
}

function evaluateOneScreen(diagram) {
  const trimmed = diagram.trim();
  if (!trimmed) return { passed: false, detail: "Add enough roles and messages to generate the body plan." };

  const lines = trimmed.split("\n");
  const maxWidth = Math.max(...lines.map((line) => line.length), 0);
  const passed = lines.length <= 20 && maxWidth <= 88;
  return {
    passed,
    detail: passed
      ? `Draw notation fits on one screen: ${lines.length} lines, widest line ${maxWidth} chars.`
      : `Draw notation is currently ${lines.length} lines, widest line ${maxWidth} chars. Aim for about 20 lines and 88 chars max.`,
  };
}

function isSingleSentence(text) {
  const trimmed = text.trim();
  if (!trimmed) return false;
  const normalized = trimmed.replace(/\n+/g, " ");
  const sentenceBreaks = normalized.match(/[.!?](\s|$)/g) || [];
  return sentenceBreaks.length <= 1;
}

function filledStrings(items) {
  return items.map((item) => item.trim()).filter(Boolean);
}

function entityHasRefusal(state, entityId) {
  const refusal = state.refusals.find((item) => item.entityId === entityId);
  if (!refusal) return false;
  return refusal.items.filter((item) => item.trim()).length >= 2;
}

function hasSymbolLead(step) {
  return /^\?\s*\[[A-Z]\]/.test(step.trim()) || /^\[[A-Z]\]/.test(step.trim());
}

function isMessageComplete(message) {
  return [
    message.fromId,
    message.toId,
    message.verb,
    message.returnShape,
    message.realDefault,
    message.testDouble,
  ].every((value) => String(value).trim().length > 0);
}

function hasAnyMessageShape(message) {
  return [
    message.fromId,
    message.toId,
    message.verb,
    message.returnShape,
    message.realDefault,
    message.testDouble,
    message.notes,
  ].some((value) => String(value).trim().length > 0);
}

function isRiskComplete(risk) {
  return [risk.risk, risk.mitigation].every((value) => String(value).trim().length > 0);
}

function hasRealAssertion(text) {
  const trimmed = text.trim();
  if (!trimmed) return false;
  if (/(pending|TODO:|remove this when)/i.test(trimmed)) return false;
  return /expect\(|assert(\.|\s)|assert\b/.test(trimmed);
}

function isSliceComplete(slice) {
  return [slice.name, slice.risk, slice.proof].every((value) => String(value).trim().length > 0);
}

function hasAnySliceShape(slice) {
  return [slice.name, slice.risk, slice.proof].some((value) => String(value).trim().length > 0);
}

function serializeJoints(state) {
  const complete = state.messages.filter(hasAnyMessageShape);
  if (complete.length === 0) return "| ... | yes/no | ... | ... | ... |";

  return complete
    .map((message) => {
      const from = entityToken(state, message.fromId);
      const to = entityToken(state, message.toId);
      const operator = messageSymbol(message.kind);
      const verb = message.verb.trim() || "...";
      const args = message.args.trim();
      return `| ${from} ${operator} ${to}#${verb}${args ? `(${args})` : ""} | ${message.owned} | ${orPlaceholder(message.realDefault)} | ${orPlaceholder(message.testDouble)} | ${orPlaceholder(message.notes)} |`;
    })
    .join("\n");
}

function serializeRefusals(state) {
  const complete = state.refusals.filter((refusal) => refusal.entityId || refusal.items.some((item) => item.trim()));
  if (complete.length === 0) {
    return "### [O] ObjectA\n- Does NOT know ...\n- Does NOT know ...";
  }

  return complete
    .map((refusal) => {
      const heading = entityToken(state, refusal.entityId) || "[O] Unnamed role";
      const items = refusal.items
        .filter((item) => item.trim())
        .map((item) => `- ${normalizeRefusalText(item)}`)
        .join("\n");

      return `### ${heading}\n${items || "- Does NOT know ...\n- Does NOT know ..."}`;
    })
    .join("\n\n");
}

function serializeSteps(steps) {
  const complete = filledStrings(steps);
  if (complete.length === 0) return "1. ? [C] Caller begins the proof.";
  return complete.map((step, index) => `${index + 1}. ${step}`).join("\n");
}

function serializeRisks(risks) {
  const complete = risks.filter((risk) => risk.risk.trim() || risk.mitigation.trim());
  if (complete.length === 0) return "| ... | medium | ... |";
  return complete
    .map((risk) => `| ${orPlaceholder(risk.risk)} | ${orPlaceholder(risk.likelihood)} | ${orPlaceholder(risk.mitigation)} |`)
    .join("\n");
}

function entityToken(state, entityId) {
  const entity = state.entities.find((item) => item.id === entityId);
  if (!entity) return "[?] Unnamed";
  return `${termSymbol(entity.term)} ${entity.name.trim() || "Unnamed"}`;
}

function termSymbol(termId) {
  return termForId(termId).symbol;
}

function messageSymbol(messageId) {
  return messageForId(messageId).symbol;
}

function normalizeRefusalText(text) {
  const trimmed = text.trim();
  if (!trimmed) return "Does NOT know ...";
  return /^Does NOT\b/i.test(trimmed) ? trimmed : `Does NOT know ${trimmed}`;
}

function normalizeTermId(value) {
  if (value === "nerve") return "dependency";
  return termForId(value ?? "owned").id;
}

function pluralize(count, singular, plural) {
  return `${count} ${count === 1 ? singular : plural}`;
}

function orPlaceholder(value) {
  const trimmed = String(value ?? "").trim();
  return trimmed || "...";
}

function titleize(text) {
  return text
    .split(/[\s_-]+/)
    .filter(Boolean)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

function escapeDoubleQuotes(text) {
  return text.replace(/"/g, '\\"');
}

function escapeSingleQuotes(text) {
  return text.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

function indent(text, spaces) {
  const prefix = " ".repeat(spaces);
  return text
    .split("\n")
    .map((line) => `${prefix}${line}`)
    .join("\n");
}

function acceptanceStyleForId(id) {
  return ACCEPTANCE_STYLES.find((style) => style.id === id) || ACCEPTANCE_STYLES[0];
}

function projectNameFor(state) {
  const explicit = state.projectName.trim();
  if (explicit) return explicit;
  const mission = state.missionName.trim();
  if (mission) return titleize(mission);
  return "Workshop Project";
}

function projectSlugFor(state) {
  return slugify(state.projectSlug.trim() || state.projectName.trim() || state.missionName.trim(), "workshop-project");
}

function acceptanceFileStem(state) {
  const number = state.sliceNumber.trim() || "01";
  const slice = slugify(state.sliceName.trim(), "walking-skeleton");
  return `${number}-${slice}`;
}

function slugify(text, fallback) {
  const normalized = String(text ?? "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return normalized || fallback;
}

function exportableState(state) {
  return hydrateState(state);
}

function starterBaseFiles(state) {
  const paths = workshopPaths(state);
  return [
    {
      path: paths.missionPath,
      content: serializeMission(state),
    },
    {
      path: paths.bodyPlanPath,
      content: serializeBodyPlan(state),
    },
    {
      path: paths.acceptancePath,
      content: serializeAcceptanceSpec(state),
    },
  ];
}

function workshopPaths(state) {
  const missionDir = projectSlugFor(state);
  const sliceDir = `${missionDir}/SLICE_${state.sliceNumber.trim() || "01"}_${sliceDirectoryName(state)}`;
  return {
    missionDir,
    sliceDir,
    missionPath: `${missionDir}/MISSION.md`,
    bodyPlanPath: `${sliceDir}/BODY_PLAN.md`,
    acceptancePath: `${sliceDir}/spec/acceptance_spec.rb`,
    bootstrapPath: `${missionDir}/WORKSHOP_START.md`,
  };
}

function sliceDirectoryName(state) {
  return slugify(state.sliceName.trim(), "walking-skeleton").replace(/-/g, "_");
}

function directoryListFor(files) {
  const directories = new Set(
    files
      .map((file) => file.path.split("/").slice(0, -1).join("/"))
      .filter(Boolean),
  );
  return [...directories].sort();
}

function pythonTestName(title) {
  const stem = slugify(title, "walking-skeleton").replace(/-/g, "_");
  return `test_${stem}`;
}
