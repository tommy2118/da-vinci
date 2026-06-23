---
title: "LedgerEntry validates source presence"
type: gotcha
realm: professional
mission: workshop
target: storefront
status: "n/a"
created: "2026-06-05"
---

# LedgerEntry validates source presence

> gotcha · professional · workshop · target:storefront · 2026-06-05

## What
LedgerEntry validates that source_reference_id is present (ledger_entry.rb:24).

## Why it matters
A legacy import path can still produce nil-source rows; the column is nullable.
