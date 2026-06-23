import { existsSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import assert from "node:assert/strict";

import {
  acceptanceArtifact,
  buildDiagram,
  completionScore,
  createInitialState,
  evaluateChecklist,
  evaluateStations,
  renderSymbolLegend,
  serializeAcceptanceSpec,
  serializeBodyPlan,
  serializeMission,
  serializeWorkshopBootstrap,
  starterFiles,
} from "../rockdrill.mjs";

function completeState() {
  const state = createInitialState();
  state.projectName = "Voucher Redemption";
  state.projectSlug = "voucher-redemption";
  state.acceptanceStyle = "rspec";
  state.bootstrapNotes = "Keep the first slice hard-coded and end to end.";
  state.missionName = "inventory_sync";
  state.workLevel = "task";
  state.missionStatement = "POST /cart/:id/redeem with {code} -> 200 {result: :applied}.";
  state.scopeReminder = "Hard-coded happy path through every layer.";
  state.sliceNumber = "01";
  state.sliceName = "walking skeleton";
  state.slices = [
    {
      name: "walking skeleton",
      risk: "prove the stack is wired",
      proof: "POST /cart/:id/redeem returns applied through real wiring",
    },
    {
      name: "reject unknown voucher",
      risk: "prove not_found flows across the same body",
      proof: "POST returns rejected:not_found",
    },
    {
      name: "reject expired voucher",
      risk: "force policy logic into the evaluator",
      proof: "POST returns rejected:expired",
    },
  ];
  state.entities = [
    {
      id: "entity-1",
      term: "caller",
      name: "RedeemController",
      responsibility: "Translate HTTP params into the domain call",
    },
    {
      id: "entity-2",
      term: "owned",
      name: "VoucherRedemption",
      responsibility: "Own the redemption decision and route collaborators",
    },
    {
      id: "entity-3",
      term: "port",
      name: "VoucherRepository",
      responsibility: "Owned lookup seam for vouchers",
    },
    {
      id: "entity-4",
      term: "adapter",
      name: "CartAdapter",
      responsibility: "Apply the voucher to the cart boundary",
    },
    {
      id: "entity-5",
      term: "result",
      name: "Result",
      responsibility: "Outcome contract across the boundary",
    },
  ];
  state.messages = [
    {
      fromId: "entity-1",
      kind: "call",
      toId: "entity-2",
      verb: "call",
      args: "code:, cart_id:",
      returnShape: "[R] Result",
      owned: "yes",
      realDefault: "VoucherRedemption.new",
      testDouble: "real object",
      notes: "Controller only translates and renders",
    },
    {
      fromId: "entity-2",
      kind: "handoff",
      toId: "entity-3",
      verb: "find",
      args: "code",
      returnShape: "[V] Voucher",
      owned: "yes",
      realDefault: "VoucherRepository.new",
      testDouble: "FakeVoucherRepo",
      notes: "Return a value object, not AR",
    },
    {
      fromId: "entity-2",
      kind: "publish",
      toId: "entity-4",
      verb: "apply",
      args: "cart_id, voucher",
      returnShape: ":ok",
      owned: "no",
      realDefault: "CartAdapter.new",
      testDouble: "FakeCartAdapter",
      notes: "Adapter wraps the external cart system",
    },
  ];
  state.refusals = [
    {
      entityId: "entity-1",
      items: [
        "Does NOT know voucher policy",
        "Does NOT know persistence details",
      ],
    },
    {
      entityId: "entity-2",
      items: [
        "Does NOT know HTTP transport",
        "Does NOT know vendor client details",
      ],
    },
    {
      entityId: "entity-3",
      items: [
        "Does NOT know policy rules",
        "Does NOT know controller rendering",
      ],
    },
    {
      entityId: "entity-4",
      items: [
        "Does NOT know voucher policy",
        "Does NOT know acceptance test details",
      ],
    },
    {
      entityId: "entity-5",
      items: [
        "Does NOT know HTTP status codes",
        "Does NOT know persistence details",
      ],
    },
  ];
  state.happyPath = [
    "? [C] RedeemController calls [O] VoucherRedemption.",
    "? [O] VoucherRedemption hands off to [P] VoucherRepository and gets [V] Voucher.",
    "? [O] VoucherRedemption returns [R] Result.applied.",
  ];
  state.failurePath = [
    "? [O] VoucherRedemption returns [R] Result.rejected(:not_found) when [P] VoucherRepository misses.",
  ];
  state.acceptanceTitle = "applies voucher end to end through real wiring";
  state.acceptanceAssertion = [
    "expect(response).to have_http_status(:ok)",
    'expect(json_body).to eq("result" => "applied")',
  ].join("\n");
  state.risks = [
    {
      risk: "Controller bypasses VoucherRedemption and reaches into persistence",
      likelihood: "high",
      mitigation: "Keep the controller translating only and hide persistence behind [P] VoucherRepository",
    },
    {
      risk: "Policy reaches for Time.now directly",
      likelihood: "medium",
      mitigation: "Route time through a [D] injected dependency",
    },
    {
      risk: "Acceptance tests mock vendors directly",
      likelihood: "medium",
      mitigation: "Swap only owned seams and adapters with fakes",
    },
  ];
  state.timerChecked = true;
  return state;
}

test("checklist passes for a coherent codified drill", () => {
  const checklist = evaluateChecklist(completeState());

  assert.equal(completionScore(checklist), 100);
  assert.ok(checklist.every((item) => item.passed));
});

test("station rail highlights slice ordering pressure", () => {
  const state = completeState();
  state.slices[0].name = "policy rules";

  const stations = evaluateStations(state, evaluateChecklist(state));
  const slicesStation = stations.find((station) => station.id === 2);

  assert.equal(slicesStation.ready, false);
  assert.match(slicesStation.detail, /walking skeleton/i);
});

test("body plan export includes the symbol grammar and generated notation", () => {
  const state = completeState();
  const bodyPlan = serializeBodyPlan(state);
  const diagram = buildDiagram(state);
  const legend = renderSymbolLegend(state);

  assert.match(bodyPlan, /## Codified grammar/);
  assert.match(bodyPlan, /\[C\] Caller/);
  assert.match(bodyPlan, /RedeemController -> \[O\] VoucherRedemption#call/);
  assert.doesNotMatch(diagram, /Caller — entry point/);
  assert.match(diagram, /returns \[R\] Result/);
  assert.match(legend, /\[P\] Port/);
  assert.match(diagram, /\[A\] CartAdapter/);
});

test("walk proof requires role symbols and exports into acceptance artifacts", () => {
  const state = completeState();
  const acceptance = serializeAcceptanceSpec(state);

  assert.match(acceptance, /Proof grammar/);
  assert.match(acceptance, /applies voucher end to end through real wiring/);
  assert.match(acceptance, /expect\(response\)\.to have_http_status\(:ok\)/);
});

test("plain prose walk steps do not satisfy the training grammar", () => {
  const state = completeState();
  state.happyPath = [
    "Controller calls service.",
    "Service returns applied.",
  ];
  state.failurePath = ["Service returns rejected."];

  const walkCheck = evaluateChecklist(state).find((item) => item.key === "walk-test");

  assert.equal(walkCheck.passed, false);
});

test("mission export carries work level and slice proofs", () => {
  const mission = serializeMission(completeState());

  assert.match(mission, /Work level: `task`/);
  assert.match(mission, /Risk first: prove the stack is wired/);
  assert.match(mission, /Proof: POST \/cart\/:id\/redeem returns applied through real wiring/);
});

test("starter files follow the workshop mission and slice layout", () => {
  const files = starterFiles(completeState());

  assert.deepEqual(
    files.map((file) => file.path),
    [
      "voucher-redemption/MISSION.md",
      "voucher-redemption/SLICE_01_walking_skeleton/BODY_PLAN.md",
      "voucher-redemption/SLICE_01_walking_skeleton/spec/acceptance_spec.rb",
      "voucher-redemption/WORKSHOP_START.md",
      "voucher-redemption/.workshop/voucher-redemption-rock-drill.json",
    ],
  );
});

test("workshop bootstrap export includes the local bootstrap and tmux commands", () => {
  const bootstrap = serializeWorkshopBootstrap(completeState());
  const acceptance = acceptanceArtifact(completeState());

  assert.match(bootstrap, /npm run bootstrap -- \/path\/to\/voucher-redemption-rock-drill\.json --launch-tmux/);
  assert.match(bootstrap, /\.\.\/bin\/drill-check voucher-redemption\/SLICE_01_walking_skeleton/);
  assert.match(bootstrap, /\.\.\/bin\/workshop voucher-redemption\/SLICE_01_walking_skeleton/);
  assert.match(bootstrap, new RegExp(acceptance.path.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
});

test("bootstrap CLI writes the workshop mission and slice files", () => {
  const workspace = mkdtempSync(path.join(tmpdir(), "visual-rockdrill-"));
  const statePath = path.join(workspace, "state.json");
  const cliPath = fileURLToPath(new URL("../tools/bootstrap-workshop.mjs", import.meta.url));

  writeFileSync(statePath, JSON.stringify(completeState(), null, 2));

  const result = spawnSync(
    process.execPath,
    [cliPath, statePath, "--workshop-root", workspace],
    { encoding: "utf8" },
  );
  const missionPath = path.join(workspace, "voucher-redemption", "MISSION.md");
  const bodyPlanPath = path.join(workspace, "voucher-redemption", "SLICE_01_walking_skeleton", "BODY_PLAN.md");
  const specPath = path.join(workspace, "voucher-redemption", "SLICE_01_walking_skeleton", "spec", "acceptance_spec.rb");
  const rcPath = path.join(workspace, "voucher-redemption", "SLICE_01_walking_skeleton", ".workshoprc");

  assert.equal(result.status, 0);
  assert.equal(existsSync(missionPath), true);
  assert.equal(existsSync(bodyPlanPath), true);
  assert.equal(existsSync(specPath), true);
  assert.equal(existsSync(rcPath), true);
  assert.match(readFileSync(missionPath, "utf8"), /# Mission — inventory_sync/);
  assert.match(readFileSync(bodyPlanPath, "utf8"), /# Slice 01 — Walking Skeleton: Body Plan/);
  assert.match(readFileSync(specPath, "utf8"), /RSpec\.describe "inventory_sync — slice 01: walking skeleton"/);
});
