# Example: Completed Pipeline README

Below is an example of what your README.md should look like once your pipeline is built out. Copy this structure and fill in your domain-specific details.

---

# Astra {Domain Name} Pipeline

A unified Databricks DLT pipeline that consolidates {Domain} data from {N} different ERP systems into a single, standardized data model for enterprise-wide reporting and analytics.

## Overview

This repository contains the ETL transformations that power the Astra {Domain} application. Data flows from each operating company's ERP system through a standardized transformation layer, producing unified tables that enable cross-company reporting.

## Current Portfolio

| System | Companies | Notes |
|--------|-----------|-------|
| Intacct | Company A, Company B | Multi-entity instance |
| Jonas | Company C | Canadian companies |
| COINS | Company D (3 sub-companies) | |

**{N} source systems, {N}+ operating companies, ~{N}M records, ~${N}B total**

## Architecture

```
Bronze Layer (Source Systems)              Silver OpCo Layer                    Silver Astra Layer
================================          ====================                 ==================

bronze_snowflake_intacct.*       -->      intacct_{domain}_invoice
                                          intacct_{domain}_payment
                                          intacct_{domain}_adjustment
                                          intacct_{domain}_customer    -->     astra_{domain}_invoice
                                                                               (UNION ALL)
bronze_opco.jonas.*              -->      jonas_{domain}_invoice               astra_{domain}_payment
                                          jonas_{domain}_payment               (UNION ALL)
                                          jonas_{domain}_adjustment            astra_{domain}_adjustment
                                          jonas_{domain}_customer      -->     (UNION ALL)
                                                                               astra_{domain}_customer
                                                                               (UNION ALL)
                                                                               |
                                                                               v
                                                                              astra_{domain}
                                                                              (Joined Summary)
```

## Standardized Data Model

### Invoice

| Column | Description |
|--------|-------------|
| Invoice Id | Unique invoice identifier |
| Invoice Number | Human-readable invoice number |
| Customer Id | Customer/vendor identifier |
| Company Name | Operating company name |
| Work Scope | Work classification |
| Invoice Date | Date issued |
| Due Date | Payment due date |
| Payment Terms | Payment terms in days |
| Invoice Amount | Invoice total |
| Total Due Validation | Source system balance for cross-check |
| System | Source system name |

## Repository Structure

```
Astra-{Domain}/
├── Transformations/
│   ├── Astra/           # Unified tables (UNION ALL)
│   ├── Intacct/         # Sage Intacct transformations
│   ├── Jonas/           # Jonas transformations
│   └── ...
├── Documentation/
│   └── Transformations/ # Business-level docs per system
├── Explorations/        # Validation notebooks
└── README.md            # This file
```

## Adding a New Source System

1. Create a new folder under `Transformations/{SystemName}/`
2. Implement the 4 standard tables following the schemas above
3. Update `Transformations/Astra/` append tables to include the new system
4. Add documentation in `Documentation/Transformations/{System}_README.md`
5. Validate against a source system report
6. Update this README's portfolio table

## Documentation

| Resource | Description |
|----------|-------------|
| [Pipeline Skill](.claude/skills/pipeline-etl/SKILL.md) | Technical reference for development |
| [Docs/Transformations/](Documentation/Transformations/) | Business-level docs per source system |

---

*Maintained by: Data Engineering Team*
