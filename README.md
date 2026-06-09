# Astra DLT Pipeline Template

A starter template for building Databricks DLT pipelines at Astra Insights. Clone this repo, follow the setup guide, and let Claude Code walk you through the rest.

## Quick Start

1. **Create your repo** — click the green **"Use this template"** button above → **"Create a new repository"** under `astra-insights`
2. **Clone it locally** and open in VS Code
3. **Open Claude Code** and say: _"Help me set up this repo for my new pipeline"_

Claude will walk you through everything. Here's what to have ready:
- Your **Databricks workspace URL** (ask Ryan or Marcus if you don't know it)
- Your **Databricks access token** (Claude will show you how to create one)
- Access to the **astra-insights** GitHub org (ask Ryan if you haven't been invited)

## What's Included

```
Astra-DLT-Template/
├── .claude/
│   ├── CLAUDE.md                          # Claude's onboarding guide (reads this automatically)
│   ├── settings.json                      # MCP tools and permissions
│   └── skills/
│       └── pipeline-etl/                  # Technical skill (grows as you build)
│           ├── SKILL.md                   # Schema, patterns, source system reference
│           └── references/
│               ├── patterns/              # Reusable SQL patterns
│               ├── source-systems/        # Bronze-to-silver column mappings
│               └── conversions/           # Per-system implementation guides
├── .databricks/
│   ├── .gitignore                         # Ignores all bundle artifacts
│   └── .databricks.env.example            # Example env file
├── .github/
│   ├── CODEOWNERS                         # Auto-assigns PR reviewers
│   └── workflows/
│       └── deploy.yml                     # CI/CD: deploys on push to dev/prod
├── Transformations/
│   ├── Astra/                             # Unified tables (UNION ALL across systems)
│   │   └── _example_append.sql            # Example append table
│   └── Example/                           # Example source system transformation
│       └── _example_invoice.sql           # Example invoice table
├── Documentation/
│   └── Transformations/                   # Business-level docs (no SQL)
├── Explorations/                          # Validation notebooks
├── .gitignore                             # Standard ignores
├── databricks.yml                         # Databricks bundle configuration
└── README.md                              # This file (replace with your own)
```

## Architecture

```
Bronze Layer (Source Systems)    →    Silver OpCo Layer              →    Silver Astra Layer
================================     ====================                ==================
bronze_opco.{system}.{table}         {system}_{domain}_{type}            astra_{domain}_{type}
(raw ingested data)                  (standardized per system)           (UNION ALL unified)
```

Each source system gets its own folder under `Transformations/` with 4 standard SQL files:
- **Invoice** — header-level invoice records
- **Payment** — payment applications
- **Adjustment** — credit memos, write-offs, discounts
- **Customer/Vendor** — entity master data

The `Transformations/Astra/` folder contains append tables that UNION ALL the per-system tables into a single unified view.

## Environments

| Environment | Workspace | Catalog | Deployed Via |
|-------------|-----------|---------|-------------|
| Dev | Set in `databricks.yml` | Set in `databricks.yml` | `databricks bundle deploy -t dev` |
| Prod | Set in `databricks.yml` | Set in `databricks.yml` | PR merge to `prod` (GitHub Actions) |

### Two supported dev/prod layouts

The template ships a configuration that assumes **separate workspaces** for dev and prod (different `host` values per target). Many Astra OpCos have only a **single workspace**, with dev and prod distinguished by schema in the same catalog.

For a single-workspace setup, edit both targets in `databricks.yml` to use the same `host` and `profile`, and change only the pipeline's `schema` (e.g., `foo_dev` for dev, `foo` for prod). Astra-Accounts-Payable uses the two-workspace pattern (`silver_astra_dev` vs `silver_astra`); Helios-HVACR uses the single-workspace pattern (`domo_migrations_dev` vs `domo_migrations` in the same catalog).

## Branch Strategy

- **`prod`** is the primary branch (not `main`)
- Create **feature branches** off `prod` for all work
- Open PRs to merge back into `prod` — branch protection requires this
- Deploy to dev freely from any branch: `databricks bundle deploy -t dev`

## Customization Checklist

After cloning, update these files with your domain-specific values:

- [ ] `databricks.yml` — pipeline name, schema, email recipients (see `<-- UPDATE` comments)
- [ ] `.github/workflows/deploy.yml` — pipeline key in run commands (see `<-- UPDATE` comments)
- [ ] `README.md` — replace this file with your domain's portfolio and architecture docs
- [ ] `.claude/skills/pipeline-etl/SKILL.md` — update schemas if your domain differs from AR/AP pattern

## Migrating Existing Tables Into DLT

If you're adopting this template to replace ad-hoc `CREATE OR REPLACE TABLE` statements that already produced tables in your target schema, there are a few rewrites to do before your first DLT run:

1. **Drop the catalog/schema prefix from the CREATE.** `CREATE OR REPLACE TABLE <catalog>.<schema>.<name>` becomes `CREATE OR REFRESH LIVE TABLE <name>` — DLT injects the target catalog/schema from `databricks.yml` automatically.
2. **Rewrite within-pipeline cross-refs to `LIVE.<name>`.** If `foo.sql` reads from `bar` (also in this pipeline), use `FROM LIVE.bar`. The fully-qualified path works but DLT won't enforce DAG ordering, which causes stale reads.
3. **Leave external refs fully-qualified.** Reference tables that are NOT produced by this pipeline (manual uploads, reference data, tables from another pipeline) should keep their full `<catalog>.<schema>.<table>` path.
4. **DROP the existing tables before the first deploy.** DLT rejects any non-DLT-managed table already in its target schema with the error `Could not materialize <table> because a MANAGED table already exists with that name`. Run `DROP TABLE IF EXISTS <catalog>.<schema>.<table>` for each table your new pipeline will own, then trigger the pipeline.
5. **Watch the library glob.** `libraries.glob.include: "./Transformations/**"` (with `**`) is the tested pattern. Narrower globs with `*.sql` are rejected by the bundle validator with `Special characters *?\ are reserved`. If you need to exclude files, move them out of `Transformations/` (e.g., into `Documentation/Deferred/`) rather than narrowing the glob.

## Example README

See [Documentation/EXAMPLE_README.md](Documentation/EXAMPLE_README.md) for an example of what a completed pipeline README looks like (modeled after the AR and AP repos).

---

*Template maintained by: Astra Insights Data Engineering*
