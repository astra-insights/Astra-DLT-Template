# Conversion Guides

This directory contains per-system implementation guides that document the full conversion from bronze to silver for each source system.

## File Naming

`{system}_{domain}_conversion.md` — e.g., `intacct_ar_conversion.md`

## Purpose

While source-system mapping files (in `../source-systems/`) document the column-level mappings, conversion guides document the full end-to-end implementation story:
- Business context and data model overview
- Step-by-step SQL logic walkthrough
- Edge cases encountered and how they were resolved
- Validation results and reconciliation notes

These guides are written as the system is onboarded and serve as the authoritative reference for future maintenance.
