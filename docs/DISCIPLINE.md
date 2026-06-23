# Discipline — the craft the workshop drills

The workshop is *structure* around a *discipline*. This document is the discipline: the
object-design frame, the testing rules, and the standards every drill and pairing session is
practicing. [CONCEPTS.md](CONCEPTS.md) and [WORKFLOWS.md](WORKFLOWS.md) reference the rules by
number (§1–§6) and name (Sandi's rules, the registry seam) — this is where they're defined.

If you keep a personal `~/.claude/CLAUDE.md`, it still applies on top of this; where the two
agree, this document is the shared baseline a colleague can rely on.

Further reading, in order of relevance: *Growing Object-Oriented Software, Guided by Tests*
(Freeman & Pryce — "GOOS"), *Practical Object-Oriented Design in Ruby* (Sandi Metz — "POODR"),
*Refactoring* and *Test-Driven Development by Example* (Kent Beck).

---

## 1. The frame: anatomy vs. cellular

Software has **anatomy** and **cellular detail**.

- **Cellular detail** is the implementation *inside* a part: method bodies, data structures,
  conditionals, queries, names. It answers *how does this work?*
- **Anatomy** is the organism-level design: what objects exist, what messages move between
  them, where the joints are, what each part refuses to know, what can be substituted without
  surgery. It answers *where does this part belong and what does it connect to?*

Both matter; they're different levels of work. The trap is that **you can write excellent
cellular code for the wrong creature** — clean, tested, idiomatic, and still belonging to a
bad anatomy. Good code inside the wrong relationships still produces a system that's hard to
change.

### The drawing test

When you review a design, don't start with "is this class clean?" Start with **"can I draw
this system?"**

- If you can't draw it, the anatomy is hidden.
- If you can draw it but arrows go everywhere, the anatomy is tangled.
- If one box has all the arrows, you found a god object.
- If you can swap one box for another without changing the rest of the drawing, you have a
  good joint.

### Refusal is design

A good object has a job *and some principled ignorance*. When you propose an object, name what
it **refuses to know** — that refusal list is half the anatomy. An object without a refusal
list isn't designed yet; it's only named. (This is why the rock drill's station 5 is a refusal
list per box.)

### Anatomical vs. cellular moves

Before any non-trivial change, label its level:

- **Cellular move** — changes implementation without changing message flow (rename a local,
  simplify a conditional, extract a private method called from one place).
- **Local anatomical move** — changes object boundaries, collaborators, ownership of a
  decision, or what an object refuses to know (extract a class, inject a collaborator,
  introduce a value object).
- **Architectural move** — changes a load-bearing seam (persistence model, service boundary,
  auth model, integration strategy, a long-lived public API).

Don't smuggle anatomical moves inside cellular work. "While I was here I just cleaned it up" is
the phrase that usually precedes a quiet change to ownership or boundaries. When unsure which
label a change deserves, label it up and surface it.

> **Prove architecture. Draw design. Iterate implementation.** Architecture has no best
> practices, only tradeoffs you choose deliberately — so architectural moves get surfaced, not
> made unilaterally.

---

## 2. Standards

### Sandi Metz's rules

1. Classes under 100 lines.
2. Methods under 5 lines.
3. Pass no more than 4 parameters (a hash of options counts as 1).
4. Controllers instantiate one object.

These are **training constraints**, not universal laws. The value isn't that 101 lines is bad
— it's that the limits force design pressure to surface *early*, while it's still cheap to
respond. Treat them as the pressure rules of a drill: when a rule pushes back, that push is
information about the design.

Break them when you must — but know that you're breaking them. When the 4-parameter rule
pushes back, the move is usually not to break it but to group related collaborators into a
small struct (`Adapters = Data.define(:payments, :inventory, :repo, :queue)`). Group by what
changes together.

### Kent Beck's simple design (priority order)

1. Passes the tests.
2. Reveals intention.
3. No duplication.
4. Fewest elements.

### Core principles

- **Composition over inheritance.** Inheritance is for sharing implementation. If you only
  need substitutability, you don't need it.
- **Duck typing over inheritance.** Substitutability comes from a shared *message protocol*,
  not a shared parent class.
- **Tell, don't ask** — push behavior to where the data lives.
- **Law of Demeter** — talk only to immediate collaborators (`a.b.c.d` is a violation).
- **DRY**, but duplication is cheaper than the *wrong* abstraction.
- **YAGNI** — solve the problem, not the hypothetical.

### When not to extract

This discipline is extraction-heavy by nature, which makes object *explosion* the easy
over-correction. A new object is justified when it creates a **better joint** — a seam where
substitution or refusal now lives — not merely when it makes a method shorter. If an
extraction doesn't give something a clearer job and a refusal list, you added an element
without adding design: Beck's *fewest elements* pulling against Sandi's *small units*. A
premature object is just the wrong abstraction with a constructor, and those are more
expensive to undo than the duplication they replaced. Extract for a joint, not for a line
count.

---

## 3. Outside-in TDD (GOOS), and why the loops matter

The shape of the loops is in [CONCEPTS → the two loops](CONCEPTS.md#the-two-loops-outside-in).
The discipline beneath them:

- The **outer (acceptance) loop** pins *behavior* against the real stack and stays red until
  the slice actually works. It's what catches a mock that lies.
- The **inner (unit) loop** drives *design* — fast, one test per object, mocks allowed
  *because the outer loop catches their lies*.

Writing tests *after* the code is not TDD — it's certification of whatever you built, smells
and all. The design conversation is gone. The cycle is the conversation: **Red** proposes an
anatomy, **Green** is the dumbest thing that passes, **Refactor** is where design happens. The
shape that survives Refactor is the anatomy the tests demanded — don't skip from Red to "the
good design," that silences the conversation.

Mocks are a **speed** tool, not a **correctness** tool. The outer loop is what proves
correctness.

---

## 4. The §1–§6 hardening rules

GOOS works, but its known failure modes all show up when teams run *only* the inner loop.
These six rules keep the practice honest. Each is the anatomical move applied at a specific
surface.

### §1 — Only mock types you own

The boundary rule; makes the boundary visible.

- ✅ Mock your own service objects, repositories, gateways, ports, adapters.
- ❌ Don't mock ActiveRecord, HTTP clients, AWS/Redis SDKs, third-party gems, stdlib.
- For an external dependency: **wrap it in a thin adapter you own**, then fake or mock the
  adapter. The adapter gets a real integration test (§3).

The deeper rule: **mocks should pin contracts, not implementations.** A contract changes
rarely; an implementation changes often. If renaming one method breaks 15 specs, those specs
reached in and named the implementation. Write mocks that say "given this input, return this
output, by this protocol" — not "I expect exactly this internal call sequence."

**Mock smells:** mocking the object under test; `allow(...).to receive(...)` chains 3+ deep;
tests pass but the feature is broken in dev; refactoring requires changing 5+ mocks.

### §2 — Run the outer loop (the part teams skip)

Makes the substitution mechanism visible.

1. Every feature starts with a failing acceptance test.
2. Acceptance tests use the **real** DB, router, and application wiring. External HTTP may be
   recorded/simulated at the network boundary, but never mocked *inside* the application
   boundary.
3. Inner-loop unit tests may use fakes/mocks (per §1, §5), but the acceptance test must go
   green using real wiring before the work is done.

**The cheat to never make:** adding `allow(Stripe::X).to receive(...)` inside an acceptance
test. That's an inner-loop technique at the wrong layer. The acceptance test fakes at the
**registry seam** (see [The adapter registry](#the-adapter-registry)), not at the SDK.

### §3 — Contract tests for adapters

Makes the contract visible. For every adapter wrapping an external system:

- One `shared_examples` block defines the contract.
- The real adapter **and** its fake both include the shared examples; CI is red if they
  diverge.
- Cover the failure modes you care about, not just the happy path: success, common domain
  failures (decline, out-of-stock), infrastructure failures (timeout), and any
  idempotency/sequencing requirement. Pin the errors whose silent occurrence would page
  someone.

The fake is what your inner specs use; the real is what production wires; the contract holds
them together. Two limbs, one socket.

### §4 — Inject collaborators, don't reach for them

Makes the joints visible. Every collaborator is a constructor or method parameter **with a
real default**, so production calls `Thing.new` with no args and works, while tests pass fakes.

```ruby
def initialize(repo: UserRepository.new, clock: Time, id_gen: SecureRandom)
  @repo = repo; @clock = clock; @id_gen = id_gen
end
```

The rule: if a test would need `allow_any_instance_of`, `stub_const`, `travel_to`, or
`Timecop` inside domain code, the collaborator should have been injected. Those tools are
smells, not solutions. No DI container required — defaults stay real.

### §5 — Test doubles: Real > Fake > Stub > Mock

Makes the test-double choice visible. Prefer, in order:

1. **Real object** — if it's fast and owned, use it.
2. **Fake** — an in-memory working implementation, shared across tests.
3. **Stub** — a canned return value for one call.
4. **Mock** — a verified interaction (last resort).

**Fakes are first-class code**, living in `spec/support/fakes/` as `Fake<Thing>`, implementing
the real interface, with their own contract spec (§3), reused across the suite. Write a fake
when you'd otherwise mock the same collaborator in 5+ specs, or use 2+ `allow(...)` calls in
one spec. Mocks are acceptable for verifying a side effect with no observable state ("did we
publish to SNS?"), or pinning behavior at a boundary you can't cheaply fake.

### §6 — Ban implicit globals in domain code

Makes the nerves visible. These are dependencies, not language features — inject them:

| Global | Inject as | Test default |
|--------|-----------|--------------|
| `Time.now` / `Date.today` | `clock:` | frozen fake clock |
| `SecureRandom` | `id_gen:` | sequential fake |
| `ENV[...]` | `config:` | explicit hash |
| `Rails.logger` | `logger:` | array-backed fake |
| `Sidekiq` / job enqueue | `job_queue:` | array-backed fake |

**Forbidden in domain specs:** `Timecop.freeze` / `travel_to`, `stub_const` for your own
constants, `ENV["X"] = ...`, `allow(Time).to receive(:now)`. (`travel_to` is fine in
*acceptance* tests exercising the real Rails stack, where threading a clock through every layer
isn't worth it.)

---

## The adapter registry

§2 says acceptance tests fake "at the registry seam." That seam is a small lookup the
application asks for its adapters, instead of constructing vendor objects inline:

```ruby
# production wiring
Adapters.register(:payments, StripePaymentGateway.new)

# acceptance test — swap fakes for the whole feature, at the boundary you own
with_adapters(payments: FakePaymentGateway.new) do
  post "/orders", params: cart
  expect(response).to have_http_status(:created)
end
```

`with_adapters(...)` (a test helper defined in your `spec_helper`) overrides the registry for
the block, then restores it. The application code never sees a mock — it asks the registry and
gets a fake that honors the same contract (§3). This is what keeps the acceptance test honest
*and* free of SDK-level stubbing.

### Bad → better → best (§1–§3 in one example)

The same Stripe charge, three ways:

```ruby
# BAD — mock the vendor SDK directly. Brittle (breaks when Stripe's shape changes) and it
# pins the SDK's implementation, not your contract. Violates §1.
allow(Stripe::Charge).to receive(:create).and_return(double(id: "ch_1"))

# BETTER — wrap the vendor in an adapter you own; mock *that* in unit tests (§1).
class StripePaymentGateway
  def charge(amount_cents:, token:)            # the contract your app depends on
    res = Stripe::Charge.create(amount: amount_cents, source: token)
    Payment.new(id: res.id, status: :captured)
  end
end
allow(payments).to receive(:charge).and_return(Payment.new(id: "ch_1", status: :captured))

# BEST — in acceptance, fake at the registry seam so the *real* app wiring runs (§2),
# and hold the fake to the real adapter's contract with shared specs (§3).
with_adapters(payments: FakePaymentGateway.new) do
  post "/orders", params: cart
  expect(response).to have_http_status(:created)
end
```

The contract (§3) is what stops the fake and the real adapter from drifting apart:

```ruby
RSpec.shared_examples "a payment gateway" do
  it "captures a valid charge" do
    payment = subject.charge(amount_cents: 1000, token: "tok_valid")
    expect(payment.status).to eq(:captured)
  end

  it "surfaces a decline as a domain failure, not a raw vendor error" do
    expect { subject.charge(amount_cents: 1000, token: "tok_declined") }
      .to raise_error(PaymentDeclined)
  end
end

RSpec.describe StripePaymentGateway do   # the real adapter — integration (VCR / sandbox)
  it_behaves_like "a payment gateway"
end

RSpec.describe FakePaymentGateway do     # the in-memory fake your specs use
  it_behaves_like "a payment gateway"
end
```

If the fake and the real adapter ever drift, that shared example goes red — §3 doing its job.

---

## Rails notes

This discipline targets a Rails codebase, so be explicit about where Rails conventions stay
Railsy — overcorrecting is its own smell:

- **Controllers instantiate one object** (§4 above / Sandi rule 4), but **views, components,
  and form objects** may use framework objects freely. That's presentation, not domain
  orchestration.
- **ActiveRecord models may hold behavior**, but **domain orchestration should not accrete on
  them by default.** When a model starts coordinating other objects, jobs, or external calls,
  that orchestration wants its own service object.
- **`travel_to` / `Timecop` are fine in request and system specs** exercising the real Rails
  stack — but **not in domain specs**, where you inject a `clock:` (§6).
- **The registry seam is for *external* edges** (payments, mail, SMS, object storage), not for
  wrapping every Rails collaborator. Wrapping ActiveRecord in a repository is a real choice
  with a cost; make it when you need the seam, not reflexively.

---

## Reviewing with this discipline

The discipline is only as good as the review behavior it produces. Six questions, in order —
the first two decide how hard to look:

1. **Can I draw the design?** If not, ask for the anatomy before reviewing the cells.
2. **What level changed — cellular, local anatomy, or architecture?** Cellular gets a light
   touch; anatomical and architectural moves get scrutiny, and should have been surfaced, not
   smuggled into a "refactor."
3. **What does each new object refuse to know?** No refusal list means it isn't designed yet.
4. **Are external dependencies behind owned adapters?** No direct vendor SDK calls in domain
   code (§1).
5. **Is there an outer-loop test proving the real wiring?** Not just unit tests that might be
   mocking a lie (§2).
6. **Do the mocks pin contracts or implementations?** Implementation-pinned mocks are the ones
   that make every later refactor hurt (§1).

Approve at **good enough**, not perfect. Ask questions, don't demand. The smell tables below
are the deeper reference when one of these questions turns something up.

---

## 5. Code smells

| Smell | Symptom | Remedy |
|-------|---------|--------|
| God class | does everything | extract classes by responsibility |
| Feature envy | a method leans on another object's data | move it to that object |
| Shotgun surgery | one change → many small edits | extract to a single location |
| Primitive obsession | primitives where a small object belongs | extract a value object |
| Long method | > 5 lines | extract method |
| Long parameter list | > 4 params | introduce a parameter object |
| Refused bequest | subclass ignores inherited methods | prefer composition |

## Test smells — listen to the tests

A test that's hard to write is the anatomy diagnosing itself.

| Test pain | Diagnosis | Refactor toward |
|-----------|-----------|-----------------|
| `allow(SomeClass).to receive(:new)` | A constructs B instead of receiving it | inject B (§4) |
| `stub_const("Stripe::X", …)` | mocking a type you don't own | wrap in an owned adapter (§1) |
| 6+ `allow(...)` in one spec | the object sends too many messages | extract a collaborator |
| `receive_message_chain(:b,:c,:d)` | Demeter violation | A sends one message to B; B sends the rest |
| `travel_to` in a domain spec | hidden nerve to the clock | inject `clock:` (§6) |
| `allow(Time).to receive(:now)` | hidden nerve to the clock | inject `clock:` (§6) |
| `send(:private_method, …)` to test behavior | behavior in the wrong scope | extract a class; private becomes its public API |
| changing one method breaks 15 mock-heavy specs | mocks froze implementation | redesign via the failures, don't just update mocks |
| passes but the feature is broken in dev | mocks lied; no outer-loop coverage | add an acceptance test with real wiring (§2) |

**Honest exceptions:** a payment-flow test is scary to change because payments are scary —
that's the domain, not the design. Some test pain is tooling pain (RSpec quirks, factory
setup), not anatomical pain. Spend a few minutes deciding which it is. But the default
assumption is: the pain is signal.

---

## Working in existing codebases — how much to apply

**Apply the discipline to the object or seam you're changing, not the whole file.** For a
normal PR, bring the code you touch up to standard and leave untouched legacy alone — don't let
this document become a rewrite mandate. The regime is asymmetric:

- **New code** follows these rules from line one.
- **Touched code** improves a little when you touch it (Boy Scout rule: one method extracted,
  one global injected — not a rewrite).
- **Untouched working code** stays as-is. It works; a defensive rewrite costs more than leaving
  it until someone needs to change it.

> A PR that "also cleaned up" five files you didn't need to touch is harder to review and
> riskier to ship than the change it was supposed to be. Scope the discipline to the change.

Two techniques worth knowing by name:

- **Sprout class** — when legacy code needs new behavior, extract a new clean class and call it
  from the legacy code in one tested place, rather than growing the legacy class.
- **Characterization tests** — before changing legacy code deeply, pin its current behavior
  (bugs included) with tests, then refactor green.

Prefer **consistency over local perfection**: two ways to do one thing is worse than one
consistent way. Match the patterns a codebase already uses; introduce a "better" way only if
you'll refactor all existing usages to it (or the existing one has a correctness/security
flaw).
