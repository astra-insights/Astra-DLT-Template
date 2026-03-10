# Source System Mappings

This directory contains one mapping file per source system, documenting how that system's bronze tables map to the standardized output schema.

## File Naming

`{system}_mapping.md` — e.g., `intacct_mapping.md`, `jonas_mapping.md`

## File Template

Each mapping file should include:

```markdown
# {System Name} Mapping

## Bronze Tables
| Table | Description |
|-------|-------------|
| `bronze_opco.{system}.{table}` | Description |

## Companies
| Company Name | Bronze Prefix | Notes |
|-------------|---------------|-------|
| Company A | `{prefix}` | |

## Column Mapping — Invoice
| Output Column | Source Column | Transform |
|---------------|---------------|-----------|
| `Invoice Id` | `{source_col}` | CAST / CONCAT / etc. |

## Column Mapping — Payment
(same format)

## Column Mapping — Adjustment
(same format)

## Column Mapping — Customer/Vendor
(same format)

## Known Quirks
- List any data quality issues, tax handling, duplicate logic, etc.
```
