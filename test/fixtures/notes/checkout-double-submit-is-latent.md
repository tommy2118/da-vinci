---
title: "The double-submit is latent, not live"
type: finding
realm: professional
mission: checkout
target: storefront
slice: "02"
status: "open"
tags: [billing, idempotency]
created: "2026-06-05"
links: [checkout-no-double-charge]
---

# The double-submit is latent, not live

> finding · professional · checkout/02 · target:storefront · 2026-06-05

## What
The double-charge path is reachable only via legacy nil-source rows. LedgerEntry validates
source presence, so it is a latent idempotency risk, not a live bug.

## Why it matters
Slice 2 is defensive hardening, not a live fix.
