# Pattern Library

This directory contains reusable SQL patterns discovered during pipeline development. Add new pattern files as you encounter common transformation scenarios.

## Suggested Pattern Files

As you build the pipeline, consider documenting these patterns:
- `invoice_patterns.md` — invoice extraction, deduplication, deleted/voided handling
- `payment_patterns.md` — payment application, unapplied payments, credit memos
- `adjustment_patterns.md` — write-offs, discounts, credit notes
- `customer_vendor_patterns.md` — entity resolution, active/inactive logic

## File Format

Each pattern file should include:
1. **When to use** — what scenario triggers this pattern
2. **SQL example** — working SQL snippet
3. **Gotchas** — edge cases and known issues
4. **Systems using this pattern** — which source systems apply it
