# Chat A — Calls API batch 2 — 26 October 2026

READY FOR STAGING READ TEST: YES. Local checks only; nothing pushed or applied remotely.
History filters/totals, explicit recording states and temporary links, and settled
AI/free-human billing proof are built in engine and Node/CLI, Python and MCP candidates.
Default call list remains an array. Calls, billing rules and delete permissions unchanged.
Full implementation/approval evidence: engine `notes/area3-batch2/REVIEW.md`.

## Order

1. Claude applies `101_01_call_reads.sql` and runs `101_01_call_reads_CHECK.sql`.
2. Claude applies `101_02_call_billing_read.sql` and runs `101_02_call_billing_read_CHECK.sql`.
3. Both checks require all boot checks and `call_reads_ready=true`. No new setting/secret.
4. Fahim pushes engine to staging; kits/docs to their feature branches below.
5. After the staging deployment, run the GET-only helper and compare the dashboard.
   Kit pushes do not publish npm/PyPI, rebuild a Desktop bundle or publish docs.

```powershell
git -C "D:\nixflex-worktrees\nixflex-r5g-engine" push origin codex/area3-batch2-engine:staging
git -C "D:\Nixflex Voice Engine\nixflex-sdk" push -u origin codex/area3-batch2-node
git -C "D:\Nixflex Voice Engine\nixflex-python" push -u origin codex/area3-batch2-python
git -C "D:\Nixflex Voice Engine\nixflex-mcp" push -u origin codex/area3-batch2-mcp
git -C "D:\Nixflex Voice Engine\nixflex-docs" push -u origin codex/area3-batch2-docs
```

No force push. If staging has moved, stop and rebase/recheck this candidate first.

## Fahim's read-only staging test

Replace the three example values with existing staging data. Pick a recording still
in Nixflex managed storage and a settled call that used takeover. No new paid call.
Use `-ExpectedTotal 12` if the dashboard shows 12 matching rows. For local-day parity,
also pass its exact ISO `-Since` and `-Until` boundaries (otherwise today is UTC and
month is rolling 30 days). The helper prints the effective boundaries for comparison.

```powershell
pwsh -NoProfile -File "D:\Nixflex Voice Engine\nixflex-docs\scripts\test-area3-batch2-staging.ps1" -Number "+YOUR_BUSINESS_NUMBER" -Outcome failed -Period month -RecordingCallId "EXISTING_RECORDED_CALL_ID" -TakeoverCallId "EXISTING_SETTLED_TAKEOVER_CALL_ID"
```

The key is requested securely on this computer, never as a command argument. The
script makes only staging call GETs and a bounded managed-recording GET. It sends no
API key to storage, prints no signed URL, saves no audio, and makes no charge request.
Confirm IDs/totals against dashboard, the link succeeds, and AI/free-human split/cost
match existing proof. Conservative split means a billing cap, not exact handover time.

Local gates: engine 2,312; Node/CLI 82 + build; Python 104; MCP 57 + packed artifact
checks; docs 23. Local PostgreSQL replay, new reverses/reapply, CRLF and all boot checks
pass. Public buckets/signing failure return 503; old calls without proof can correctly
return unknown. No live staging or rendered/published docs result is claimed.

## Only approved locked expectation

MCP `scripts/tool-contract.mjs`, owner approval 26 October 2026:
`52159bbf5ae63f80fc7e96a04f59c41d095384de1e29d5fd15dc70ee363c9201`
-> `93749b2175d263812ce9b494ab2e6d2dd6bf7a8b6654f04bb2c6a52287d38a2c`.
Only optional list_calls/get_call read schemas changed. Other 33 complete descriptor
bytes and handlers, all 35 permission-hint bytes, confirmation and origin helpers
remain pinned to the accepted parent. No other locked test changed.

Rollback: restore prior engine code first, then optional `101_02..._REVERSE.sql` and
`101_01..._REVERSE.sql`. They remove only new readers, never stored evidence/content.
One existing Calls API DOCS-LEDGER entry updated (Business/Developer); drafts unpublished.
