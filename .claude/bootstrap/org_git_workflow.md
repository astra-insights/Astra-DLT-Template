---
name: Astra git workflow
description: Branch strategy, PR rules, and deployment conventions for all Astra pipeline repos
type: feedback
---

## Branch Strategy

- **Primary branch is `prod`**, not `main`
- Create **short-lived feature branches** off `prod` for all work
- Open PRs to merge back into `prod`, then delete the feature branch
- Branch protection requires PRs — no direct pushes to `prod`

**Why:** Consistent across all Astra repos. `main` branches were removed org-wide in Feb 2026.

**How to apply:** Always branch from `prod`, always PR to `prod`. Never push directly to `prod`.

## Deployment Rules

- `databricks bundle deploy --target dev` is safe to run anytime from any branch
- **NEVER deploy to prod manually** — prod deployments happen via PR merge + GitHub Actions
- Dev deploy locks can be force-overridden (`--force-lock`) since dev is a shared sandbox

## PR Conventions

- Keep PRs focused — one feature or fix per PR
- Pipeline SQL changes should include validation results (dev vs prod comparison) in the PR description
