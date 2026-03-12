---
name: Astra Databricks conventions
description: Column naming, catalog patterns, and MCP tool usage across all Astra DLT pipelines
type: reference
---

## Column Naming by Layer

- **silver_astra tables**: Title Case with backticks — `` `Company Name` ``, `` `Invoice Amount` ``
- **silver_opco tables**: snake_case — `company_name`, `invoice_amount`
- **Bronze tables**: Use whatever the source system provides (varies)

## Catalog Access Patterns

- Bronze catalogs follow the pattern `bronze_opco.{system}.*` (e.g., `bronze_opco.jonas.*`, `bronze_opco.intacct.*`)
- Company names differ between layers: OpCo uses short aliases (e.g., 'Lowe'), Astra uses full legal names (e.g., 'Lowe Mechanical Services Ltd')
- The company map table (`dimensions.core.astra_company_map`) resolves aliases to full names

## MCP Tool Usage

- Use `mcp__databricks-prod__execute_sql` for reconciliation and validation queries
- Use `mcp__databricks-dev__execute_sql` for exploring dev tables during development

## Financial Data Rules

- Always use `DECIMAL(18,2)` for monetary amounts — never FLOAT or DOUBLE
- Validate calculated balances against source system reports (DOMO or ERP exports)
