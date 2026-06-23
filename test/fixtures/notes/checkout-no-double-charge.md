---
title: "Do not call PaymentReceiptService for free checkouts"
type: decision
realm: professional
mission: checkout
target: storefront
status: "accepted"
tags: [fulfillment, boundary]
created: "2026-06-05"
---

# Do not call PaymentReceiptService for free checkouts

> decision · professional · checkout · target:storefront · 2026-06-05

## What
FreeCheckoutService never calls PaymentReceiptService.

## Why it matters
PaymentReceiptService carries gateway-receipt assumptions; reusing it drags the payment
gateway into a checkout that never touched it.
