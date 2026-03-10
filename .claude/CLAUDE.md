# Astra DLT Pipeline — Claude Code Guide

You are working in an Astra Insights Databricks DLT pipeline repository. This file tells you everything you need to help the analyst get set up and productive.

## First-Time Setup

When an analyst clones this repo and opens Claude Code for the first time, walk them through these steps:

### 1. Prerequisites

The analyst needs these installed before starting:
- **VS Code** with the Databricks extension (`databricks.databricks`)
- **Claude Code** VS Code extension
- **Databricks CLI** — install via `pip install databricks-cli` or `winget install Databricks.DatabricksCLI`
- **Git** — for version control and bundle deployments
- **GitHub CLI** (`gh`) — for PR workflows: `winget install GitHub.cli`

### 2. Databricks Authentication

The analyst needs an access token for their Databricks workspace. Walk them through creating one:

**Ask the analyst for their workspace URL first.** It will look like `https://adb-XXXX.XX.azuredatabricks.net`.

1. Log into their workspace URL
2. Click your profile icon (top-right) → Settings → Developer → Access tokens
3. Click "Generate new token", name it `claude-code`, set expiration (90 days recommended)
4. Copy the token immediately (it won't be shown again)

**Configure the Databricks CLI profile:**
```bash
# Create or edit ~/.databrickscfg
cat <<EOF >> ~/.databrickscfg
[dev]
host = <WORKSPACE_URL_HERE>
token = <TOKEN_HERE>
EOF
```

If the analyst has separate dev and prod workspaces, add a `[prod]` profile the same way.

**Verify connection:**
```bash
databricks auth profiles
databricks clusters list --profile dev
```

### 3. GitHub Authentication

The analyst needs GitHub access to the `astra-insights` org:
1. Ensure they have been added to the `astra-insights` GitHub organization
2. Run `gh auth login` and follow the prompts (use HTTPS, authenticate via browser)
3. Verify: `gh repo list astra-insights --limit 5`

### 4. Repository Setup

After creating a repo from this template:
1. **Rename the bundle** — update `bundle.name` in `databricks.yml` to match your repo name
2. **Set workspace URLs** — update the `host` values in `databricks.yml` targets to match your workspace(s)
3. **Update pipeline config** — edit `databricks.yml` with your pipeline name, catalog, and schema
4. **Deploy to dev** — run `databricks bundle deploy --target dev` to verify the connection works
5. **Set up GitHub secrets** — in the repo's GitHub Settings → Secrets → Actions:
   - `DATABRICKS_TOKEN_DEV` — your workspace token
   - If you have a separate prod workspace, add `DATABRICKS_TOKEN_PROD` too
   - Create GitHub Environments (`dev`, and `prod` if applicable), assign the secrets to each

### 5. VS Code Databricks Extension

1. Open VS Code, go to the Databricks sidebar panel
2. Click "Configure Databricks" and select the `dev` profile
3. The extension will connect and allow you to browse catalogs, run notebooks, etc.

## Repository Conventions

### Branch Strategy
- **`prod`** is the primary branch (not `main`)
- Create **feature branches** off `prod` for all work
- Open PRs to merge back into `prod`
- Branch protection requires PRs — no direct pushes to `prod`
- `databricks bundle deploy --target dev` is safe to run anytime from any branch

### SQL File Conventions
- All DLT SQL files go in `Transformations/{SystemName}/`
- File naming: `{system}_{domain}_{table_type}.sql` (e.g., `intacct_ar_invoice.sql`)
- Column aliases: Title Case wrapped in backticks (`` `Invoice Amount` ``)
- Internal CTEs: snake_case
- Catalog variables: `${catalog_silver_opco}`, `${catalog_silver_astra}` (resolved by databricks.yml)
- Always include DLT constraints, comments, and tblproperties

### Documentation
- Business-level docs go in `Documentation/Transformations/{System}_README.md`
- No SQL code in documentation — plain English only
- Exploration notebooks go in `Explorations/`

### Deployment
- **Never deploy to prod manually** — prod deployments happen via PR merge + GitHub Actions
- `databricks bundle deploy --target dev` is safe for local development
- Dev deploy locks can be force-overridden (`--force-lock`) since dev is a shared sandbox

## Architecture

Astra pipelines follow a two-tier architecture:

```
Bronze Layer (Source Systems)    →    Silver OpCo Layer              →    Silver Astra Layer
================================     ====================                ==================
bronze_opco.{system}.{table}         {system}_{domain}_{type}            astra_{domain}_{type}
                                     (per-system standardized)           (UNION ALL unified)
```

- **Bronze** — raw ingested data from each source system (read-only)
- **Silver OpCo** (`silver_opco` / `silver_opco_dev`) — standardized tables per source system
- **Silver Astra** (`silver_astra` / `silver_astra_dev`) — unified tables combining all systems

## Catalogs

| Environment | OpCo Catalog | Astra Catalog | Dimensions |
|-------------|-------------|---------------|------------|
| Dev | `silver_opco_dev` | `silver_astra_dev` | `dimensions` |
| Prod | `silver_opco` | `silver_astra` | `dimensions` |

Bronze catalogs are accessed via `bronze_opco.{system}.*` (shared across environments).

## MCP Tools

If Databricks MCP is configured (see `.claude/settings.json`), you can query Databricks directly:
- **Always use `mcp__databricks-prod__execute_sql`** for reconciliation work
- `silver_astra` tables use Title Case with backticks: `` `Company Name` ``
- `silver_opco` tables use snake_case: `company_name`

## Skill System

This repo includes a skill template at `.claude/skills/pipeline-etl/SKILL.md`. As you work with the analyst:
- **Update the SKILL.md** with domain-specific schema, source system mappings, and patterns you discover
- **Add reference docs** in the `references/` subdirectories as you learn the data
- The skill grows organically as the pipeline is built — it becomes the technical memory for this domain

## Key Resources

| Resource | Description |
|----------|-------------|
| `databricks.yml` | Bundle configuration — pipeline, catalogs, schedules |
| `.github/workflows/deploy.yml` | CI/CD — deploys on push to dev/prod |
| `Transformations/` | All DLT SQL files (synced to Databricks) |
| `Documentation/Transformations/` | Business-level docs per source system |
| `Explorations/` | Validation and analysis notebooks |
| `.claude/skills/pipeline-etl/SKILL.md` | Technical reference (grows as you build) |
