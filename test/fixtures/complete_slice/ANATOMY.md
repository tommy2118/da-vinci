# Slice 1 — Complete drill

## Collaborators

```
CLI
  -> Service#call
  -> Reporter#render
```

## Joints

| Arrow | Real default | Test double |
|-------|--------------|-------------|
| `CLI -> Service#call` | real service | fixture service |
| `Service -> Reporter#render` | terminal output | fake reporter |

## Refusals

### `CLI`
- Does NOT know markdown parsing
- Does NOT know validation rules

### `Service`
- Does NOT know terminal formatting
- Does NOT know argument parsing

## Walk-through

### Happy path
1. CLI loads the slice.
2. Service validates the slice.

### Failure path
1. Service finds a missing checklist item.
2. CLI exits non-zero.

## Bypass risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| CLI parses markdown directly | medium | Keep parsing inside service rules |
| Rules read files themselves | medium | Slice owns file loading |
| Tests bypass the CLI contract | low | Keep one CLI integration test |

## Verification checklist

- [x] One-screen test — anatomy diagram fits one terminal screen
- [x] One-sentence test — scope reminder is one sentence
- [x] Refusal-list completeness — every box ≥2 items
- [x] Joint completeness — every arrow has real default + test double
- [x] Walk test — every walk step references only objects/messages in the drawing
- [x] Red-shape test — acceptance test fails on assertions, not plumbing
- [x] Bypass-audit honesty — ≥3 named risks with mitigations
- [x] Timer test — drill stayed under ~30 minutes
