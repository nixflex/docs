# Nixflex documentation

This repository contains the Business guide, Developer guide, API reference, SDKs & CLI, and AI tools pages for [docs.nixflex.com](https://docs.nixflex.com).

## Make a lasting edit

Read [DOCS-STYLE-GUIDE.md](DOCS-STYLE-GUIDE.md) before changing content. Update documentation in the same change as a shipped feature, using the reviewed engine, dashboard and client contracts as evidence.

- `docs.json` holds the published menu, branding and redirects.
- `spec-source/c15-pages.json` holds the final menu plan, metadata, audience pairs, retired duplicates and authoritative page-source paths.
- `spec-source/c15-pages/` holds C15 page sources. Change the source named by the plan; editing only generated MDX will be overwritten.
- Other page sources and API contract builders remain in the earlier `spec-source` plans and `scripts/build-*.mjs` files. The final C15 stage applies the current metadata and coordinated content.
- `api-reference/public.openapi.json` is generated. Public operation scope is declared in `spec-source/public-operations.json`; B57 deletion, B58 booking and B59 campaign detail are in `scripts/c15-contracts.mjs`.
- `COVERAGE.md` records test scope and unperformed successful writes. Documentation coverage is not evidence of a live mutation test.

Keep existing URLs. When consolidating a true duplicate, add one direct permanent redirect to the retained page. Add every public page to navigation, use a short sentence-case `sidebarTitle`, and provide a unique title and description. Keep Business and Developer counterparts linked in both directions.

## Build and check

From this repository, using the reviewed Node and Mintlify installations:

```bash
node scripts/build-docs.mjs
node scripts/check-c15-source.mjs
node --test
mint validate
mint broken-links
```

Use `scripts/validate-c9-examples.mjs --modules <Mintlify-node_modules> --out <private-artifact-directory>` to validate OpenAPI examples and executable code syntax. It requires the dependencies bundled with the installed Mintlify CLI, Git Bash for shell examples, Python and PowerShell.

Run the pinned contract checks with `node scripts/validate-c15-contracts.mjs --engine <reviewed-engine-checkout> --modules <Mintlify-node_modules> --out <result-json>`. The engine checkout must contain commit `9da04ec`; the script reads that Git object, not uncommitted engine files.

Run `scripts/validate-c15-campaign-detail.mjs` with the same arguments for B59's real read handler. It requires engine commit `dd95cfb` and verifies the published list-item schema, account filtering, confirmation evidence, errors and no-store response with fake dependencies. B59 must be released before its detail endpoint is available; the K9 clients use direct HTTP for that read.

The build is local and makes no customer API requests. `validate-c15-contracts.mjs` uses pinned source with fake dependencies. Do not run staging mutation runners against real account data as part of a routine docs check.

Historical tests and checkers are locked. C15 applies only the expressly approved D7 policy adjustment. The remaining old-count and old-deletion assertions are documented in the C15 handoff's `BEFORE-AFTER.md`; their proposed patch is not applied. Preserve failures honestly until the assertion changes are approved and rerun.

`scripts/C8-TEST.ps1` is a frozen artifact. The normal build intentionally does not regenerate it when public operation scope changes.

## Preview and release

Run `mint dev` locally, then review phone and desktop widths in light and dark themes. Check native navigation, code tabs, copy controls, page panels and tables. Create an actual Mintlify export and inspect rendered links and metadata as well as the source tree.

The native development runtime may return temporary redirect statuses to avoid browser caching; verify permanent redirects on the hosted site after publication. Hosted sitemap, robots, share images and raw public assets also require live release checks.

Mintlify was recorded as deploying `nixflex/docs` branch `main` to `docs.nixflex.com`. Confirm current hosting settings before release. A push to that branch can publish the site. Follow the reviewed release handoff; do not push as part of a content-only task.

The C15 handoff is in `D:\Nixflex Voice Engine\voice engine files\notes\codex\2026-11-11-chat-c-C15`, including the final menu, page inventory, test logs, old-URL map, Search Console steps, exact push command and rollback instructions.
