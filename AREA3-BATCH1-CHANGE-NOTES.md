# Area 3 batch 1 change notes — 26 October 2026

## Business versus developer impact

- Business: prevents SDK automatic re-sends of ambiguous changing requests; not a
  server exactly-once guarantee. No changes to calls, prices, billing or dashboard.
- Developer: Python unknown-outcome exception, no mutation retries, canonical
  single-call variables, bounded Node page size and truthful MCP summaries.
- Privacy/docs: call prompt may be retained; deletion guard is not bypassed, no
  immediate erasure/SMS-erasure promise. Docs stay unpublished drafts.

## Compatibility

- Python `NixflexOutcomeUnknownError` subclasses the existing `NixflexServerError`.
  Catch it before general server errors. Existing tests/assertions are untouched.
- 429 remains the rate-limit exception; no changing request retries automatically.
- Python `variables` remains supported, translated to `dynamic_vars`; both aliases
  together are refused locally. CLI also refuses ambiguous alias/--var mixtures.
- Invalid call iterator sizes now raise RangeError instead of truncating silently;
  use 1–200 (200 for maximum throughput). List response and API endpoints unchanged.
- MCP still uses installed/pinned SDK 0.8.0; wrapper fix needs no SDK publication.
- No package version bumps/publication or rebuild of parked Desktop bundles.

## Existing large-file exceptions and future splits

- `nixflex-sdk/src/cli/index.ts`: import plus single-call hand-off only; all new
  body-normalisation logic is in focused `src/cli/call-create.ts` (under 300 lines).
  Future task: split CLI routing into focused modules, with its own locked-test
  review, regression gate and save point. Do not move code/tests in this run.
- `nixflex-docs/api-reference/openapi.json`: four description-only edits, no
  validation/endpoint change. Future task: split OpenAPI into referenced files,
  preserving generated contract and reference checks at a separate save point.
- `nixflex-docs/docs.json`: one navigation entry only. Future task: review a smaller
  maintained navigation source with an equivalent generated config/check/save point.

## Still outside this batch

History filters/detail models, recording availability, settled billing breakdown,
campaign controls/hours and webhook corrections follow the owner's later batches.
The remaining older create-outbound timing/carrier/fallback descriptions need that
broader outbound contract review. No pre-call, ringing or pickup changes here.
Safe-delete design and live control remain later work; tester expansion is NO.
Dashboard fixes belong to Chat B. Install run 3/Mac/directory/hands-on tests parked.
