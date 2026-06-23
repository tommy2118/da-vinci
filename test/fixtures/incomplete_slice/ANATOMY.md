# Slice 1 — Incomplete drill

## Collaborators

```
CLI
  -> Service#call
```

## Joints

| Arrow | Real default | Test double |
|-------|--------------|-------------|
| `CLI -> Service#call` | real service | fixture service |

## Refusals

### `Service`
- Does NOT know terminal formatting

## Walk-through

### Happy path
1. CLI loads the slice.

### Failure path
1. Service fails.

## Bypass risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| CLI parses markdown directly | medium | Keep parsing inside service rules |

## Verification checklist

- [x] One-screen test — anatomy diagram fits one terminal screen
- [ ] One-sentence test — scope reminder is one sentence
- [x] Refusal-list completeness — every box ≥2 items
- [x] Joint completeness — every arrow has real default + test double
- [ ] Walk test — every walk step references only objects/messages in the drawing
- [ ] Red-shape test — acceptance test fails on assertions, not plumbing
- [x] Bypass-audit honesty — ≥3 named risks with mitigations
- [x] Timer test — drill stayed under ~30 minutes
