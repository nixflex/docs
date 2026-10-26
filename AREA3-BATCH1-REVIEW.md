# Chat A — CLAUDE SUMMARY

- Prompt 202, 26 October 2026: D1 and D2 built locally; draft docs updated.
- Python sync/async never automatically repeat changing requests, including DELETE.
- Lost replies/unproved failures return outcome unknown: check before retrying.
- CLI, Python and MCP single-call variables now reach `dynamic_vars` correctly.
- Node iteration works beyond 200; page size must be a whole number 1–200.
- MCP summaries use the real direction fields, not a missing field or guessed inbound.
- No engine, SQL, dashboard, prices, pickup delay or ringing change; no real paid calls.
- Four feature branches only. Nothing pushed, published, installed or deployed.
- Install work remains parked. D3/D4/D8 and other later batches are not built here.

## Scope and base commits

All four working trees were clean before work; origin was fetched read-only.
Created branches from their latest local completed heads, retaining prior work:

| Repo under `D:/Nixflex Voice Engine/` | Base | New feature branch |
|---|---|---|
| nixflex-python | 8f5fd80b3f2b6280f7b9adda82e340b4ed0e5e86 | codex/area3-batch1-python |
| nixflex-sdk | 513a8101f21f243de5dabb2f77ec8309ded6468e | codex/area3-batch1-node |
| nixflex-mcp | fd4792cee0e65e671cb57f724f0717f676fd1a85 | codex/area3-batch1-mcp |
| nixflex-docs | e5f20f110b01dab2838f939206b74d09744b2ccc | codex/area3-batch1-docs |

Engine inspected read-only: `D:/nixflex-worktrees/chatb-engine`, HEAD
`11772086806492aea932523ea8fc15a02423f325`. `api/routes.js:1006,1047` already reads
and forwards dynamic_vars, so no engine change is needed. No forbidden SDK folder,
credentials, production queries, real carrier/AI/payment requests or SQL execution.

## Exact implementation

Python `_http.py`: GET-only retry checks in both network and response paths;
redirects disabled, malformed successful mutation replies become unknown.
`errors.py`: exported typed unknown error preserves status/request ID/original
code/details, subclasses ServerError for compatibility. Strict whole-operation
not-sent proof remains distinct, with no automatic retry. 429 remains RateLimitError.
`resources/calls.py`: variables -> dynamic_vars; canonical kwargs accepted, both
aliases refused before HTTP. Shared resource code covers sync and async clients.

Node `src/resources/calls.ts`: validate page size 1–200 before HTTP; exact full
final pages read once more, short/empty pages stop. Rejecting oversize instead of
clamping matches the existing agent iterator and the owner's explicit 1–200 rule.
`src/cli/call-create.ts`: a focused normaliser; CLI index gets only import/hand-off.
Existing --var interface works; --body/--set canonical or legacy aliases work;
conflicting sources fail locally. Batch recipient variables are untouched.

MCP `call-tools.js`: canonical create body and small explicit summary projection;
call_direction -> call_type -> legacy direction, valid inbound/outbound/web only;
unknown=null. Preserve false/zero/null; no transcript/prompt/recording URL in lists.
Index remains a thin hand-off. Helper included in npm package files and the existing
bundle runtime-file list (one-line dependency maintenance, no bundle build). No pinned dependency
change: the actual installed SDK 0.8.0 forwards canonical dynamic_vars unchanged.

Docs: new client-safety page, outbound variables/privacy, retry guides, truthful
delete hold/counters and no SMS/account-erasure promise. OpenAPI descriptions only;
no wire schema change. Updated the single Calls API ledger entry, split into
Business and Developer impact. See AREA3-BATCH1-CHANGE-NOTES.md for compatibility
and separate future file splits.

## Evidence and checks

OBSERVED: full local gates: Python 102 PASS, Node/CLI 80 PASS plus ESM/CJS/types/CLI
build, MCP 54 PASS, docs 21 PASS. No old test file, assertion, name or location changed.
New tests cover accepted-then-timeout, 429/500/no-response, malformed/redirect replies,
all four mutation verbs, sync/async, strict proof handling and bounded GET retries.
Exact body tests cover CLI/Node/Python/MCP, absent/empty values and conflicting aliases.
Paging tests cover >200, full final page, empty, 1 and 200, invalid sizes and cancellation.

OBSERVED: `npm run check:calls-packed` packs/extracts the actual MCP tarball and
resolves installed pinned SDK 0.8.0 (not the sibling Node checkout). Two loopback
fake requests prove canonical call body and web summary direction. No external API
request. Dependency installation/publication and Desktop bundle rebuild are not run.

OBSERVED: the first unqualified Python test command imported an older separately
installed checkout and failed collection. Corrected the test invocation, not the
tests: `python -m pytest -q -o pythonpath=src` explicitly loads this candidate.
The repeatable PowerShell helper uses that exact source binding.

UNKNOWN: published packages/client-installed versions and real staging outcomes
were not retested. No real calls are required for this client-boundary batch.
No rendered Mintlify preview available; docs checks are source/JSON/reference checks,
not proof of a rendered/published website. No engine/dashboard gate claimed.

## Fahim's test (no API key and no real paid calls)

Prerequisites: existing local Node dependencies and Python pytest/httpx dependencies.
The helper does not install dependencies or read a real API key. It uses only
in-memory/loopback fakes with synthetic credentials, and stops if a repo is on the
wrong feature branch. Generated test artifacts are local ignored files.

```powershell
pwsh -NoProfile -File "D:\Nixflex Voice Engine\nixflex-docs\scripts\test-area3-batch1.ps1"
```

Expected: all gates PASS, ending `PASS: Area 3 batch 1. No real paid calls needed.`

## Push lines (Fahim runs; not executed here)

```powershell
git -C "D:\Nixflex Voice Engine\nixflex-python" push -u origin codex/area3-batch1-python
git -C "D:\Nixflex Voice Engine\nixflex-sdk" push -u origin codex/area3-batch1-node
git -C "D:\Nixflex Voice Engine\nixflex-mcp" push -u origin codex/area3-batch1-mcp
git -C "D:\Nixflex Voice Engine\nixflex-docs" push -u origin codex/area3-batch1-docs
```

No engine push/SQL applies. Docs feature branch only; merging the publishing
branch/package releases is a separate owner act. No zip required for this handoff.
