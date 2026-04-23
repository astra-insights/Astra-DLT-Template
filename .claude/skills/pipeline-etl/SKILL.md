---
name: pipeline-etl
description: Develop and maintain this Databricks DLT pipeline
---

# Pipeline ETL Skill

## Skill Overview

This skill provides technical guidance for developing and maintaining this Databricks DLT pipeline. Update this document as you build out the pipeline — it serves as the living technical reference for your domain.

**Primary Use Cases:**
- Adding new source systems to the pipeline
- Adding new companies to existing source systems
- Modifying existing transformations
- Validating financial calculations
- Debugging pipeline issues

**Key Principles:**
- All source systems must map to the standardized output schema (defined below)
- Financial calculations require precision validation against source system reports
- Source system quirks are documented in the references/ directory for reuse
- Two-tier architecture: OpCo layer (`silver_opco`) feeds Astra layer (`silver_astra`)

## Architecture Overview

```
Source Systems (Bronze)              OpCo Transformations (Silver)         Astra Unified (Silver)
─────────────────────────           ──────────────────────────────         ──────────────────────
bronze_opco.{system}.{table}        silver_opco.{domain}.                  silver_astra.{domain}.
                                     ├── {system}_{domain}_invoice          ├── astra_{domain}_invoice
                                     ├── {system}_{domain}_payment          ├── astra_{domain}_payment
                                     ├── {system}_{domain}_adjustment       ├── astra_{domain}_adjustment
                                     └── {system}_{domain}_customer         ├── astra_{domain}_customer
                                                                            └── astra_{domain}
                                    (one set of tables per system)             (joined summary)
```

## Standardized Output Schema

<!-- UPDATE THESE SCHEMAS for your domain. The examples below follow the AR/AP pattern.
     Column order is critical — it must match exactly for UNION ALL in the Astra append tables. -->

All source system transformations MUST produce tables conforming to these schemas.

### Invoice Table Schema (`{system}_{domain}_invoice`)

| # | Column Name | Data Type | Description |
|---|-------------|-----------|-------------|
| 1 | `Invoice Id` | STRING | Unique invoice identifier (system-prefixed if needed) |
| 2 | `Invoice Number` | STRING | Human-readable invoice number |
| 3 | `Customer Id` | STRING | Customer/vendor identifier |
| 4 | `Company Name` | STRING | Operating company/entity name |
| 5 | `Work Scope` | STRING | Work classification (update categories for your domain) |
| 6 | `Invoice Date` | DATE | Date invoice was issued |
| 7 | `Due Date` | DATE | Payment due date |
| 8 | `Payment Terms` | INT | Payment terms in days |
| 9 | `Invoice Amount` | DECIMAL(18,2) | Total invoice amount |
| 10 | `Total Due Validation` | DECIMAL(18,2) | Source system balance for validation (nullable) |
| 11 | `System` | STRING | Source system name |

### Payment Table Schema (`{system}_{domain}_payment`)

| # | Column Name | Data Type | Description |
|---|-------------|-----------|-------------|
| 1 | `Invoice Id` | STRING | Related invoice identifier |
| 2 | `Payment Id` | STRING | Unique payment identifier |
| 3 | `Customer Id` | STRING | Customer/vendor identifier |
| 4 | `Company Name` | STRING | Operating company/entity name |
| 5 | `Payment Date` | DATE | Date payment was made |
| 6 | `Payment Amount` | DECIMAL(18,2) | Payment amount (positive) |

### Adjustment Table Schema (`{system}_{domain}_adjustment`)

| # | Column Name | Data Type | Description |
|---|-------------|-----------|-------------|
| 1 | `Invoice Id` | STRING | Related invoice identifier |
| 2 | `Adjustment Id` | STRING | Unique adjustment identifier |
| 3 | `Customer Id` | STRING | Customer/vendor identifier |
| 4 | `Company Name` | STRING | Operating company/entity name |
| 5 | `Adjustment Date` | DATE | Date adjustment was made |
| 6 | `Adjustment Amount` | DECIMAL(18,2) | Adjustment amount |

### Customer/Vendor Table Schema (`{system}_{domain}_customer`)

| # | Column Name | Data Type | Description |
|---|-------------|-----------|-------------|
| 1 | `Customer Id` | STRING | Unique customer/vendor identifier |
| 2 | `Company Name` | STRING | Operating company/entity name |
| 3 | `Customer Name` | STRING | Customer/vendor display name |
| 4 | `Address` | STRING | Address |
| 5 | `Payment Terms` | INT | Default payment terms in days |
| 6 | `Is Active` | STRING | Active flag ('True'/'False') |

## Databricks DLT Requirements

### Table Creation Syntax

All tables use Delta Live Tables (DLT) syntax:

```sql
create or refresh live table ${catalog_silver_opco}.{domain}.{table_name}

(
  CONSTRAINT pk_not_null EXPECT (invoice_id IS NOT NULL),
  CONSTRAINT amount_valid EXPECT (invoice_amount IS NOT NULL)
)
comment 'Description of what this table contains'
tblproperties (
  'delta.columnMapping.mode' = 'name',
  'quality' = 'silver',
  'domain' = '{domain}',
  'source_system' = '{system}',
  'companies' = 'Company 1, Company 2'
) as

with source_data as (
    select ...
    from bronze_opco.{system}.{table}
),

final as (
    select
        col1 as `Invoice Id`,
        col2 as `Invoice Amount`,
        ...
    from source_data
)

select * from final
;
```

### Key Rules
- **Column aliases**: Title Case, wrapped in backticks (`` `Invoice Id` ``, `` `Payment Amount` ``)
- **CTE names**: snake_case (e.g., `source_data`, `payment_applied`)
- **Catalog variables**: Use `${catalog_silver_opco}` and `${catalog_silver_astra}` — never hardcode catalog names
- **Constraints**: Include data quality checks inline in the table definition
- **tblproperties**: Always include quality, domain, source_system, and companies
- **Amounts**: Always DECIMAL(18,2) — never FLOAT or DOUBLE for financial data
- **Within-pipeline refs use `LIVE.<name>`**: When a table in this pipeline reads another table in the same pipeline, use `FROM LIVE.<table_name>` — DLT uses this to build the dependency DAG and orders the refresh correctly. A fully-qualified `FROM <catalog>.<schema>.<table>` technically works but DLT won't enforce ordering, which can cause a downstream table to read stale upstream data.
- **External refs stay fully-qualified**: Tables NOT produced by this pipeline (manual uploads, reference/dimension tables, tables from another pipeline) must use their full `<catalog>.<schema>.<table>` path. Do NOT wrap them in `LIVE.*`.

## Source System Reference

<!-- As you onboard source systems, add mapping files in references/source-systems/
     Example: references/source-systems/intacct_mapping.md -->

| System | Bronze Catalog Pattern | Companies | Status |
|--------|----------------------|-----------|--------|
| _Example_ | `bronze_opco.{system}.{table}` | _Company A, Company B_ | Not started |

## Pattern Library

<!-- As you discover reusable patterns, document them in references/patterns/
     Example: references/patterns/multi_stream_invoice_pattern.md -->

Common patterns will be documented here as the pipeline is built. Examples:
- Multi-entity invoice handling
- Payment decomposition from single transaction tables
- Credit memo / adjustment extraction
- Work scope classification logic

## Adding a New Source System

1. **Explore bronze data** — query `bronze_opco.{system}.*` to understand available tables
2. **Map to schema** — identify which source columns map to each output column
3. **Create SQL files** — one per table type in `Transformations/{SystemName}/`
4. **Add to append tables** — update `Transformations/Astra/` UNION ALL queries
5. **Document** — add a source system mapping in `references/source-systems/`
6. **Validate** — reconcile against a source system report
7. **Update this SKILL.md** — add the system to the reference table above

## Common Issues and Solutions

<!-- Document issues you encounter and how you resolved them here.
     This section grows organically as you work. -->

| Issue | Solution |
|-------|----------|
| _Example: Column type mismatch in UNION ALL_ | _Ensure all systems cast amounts to DECIMAL(18,2)_ |
| _Example: Duplicate records after join_ | _Use DISTINCT or check for 1:many relationship_ |
