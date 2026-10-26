# Chat A — CLAUDE SUMMARY

- Prompt 200, 26 October 2026: Area 2 batch 3 is complete as local draft documentation.
- No engine, dashboard, SDK, CLI, Python, MCP, SQL, pickup delay or runtime changes.
- Two new pages explain the four channels and privacy/action inheritance.
- Corrected concept/reference pages; retained API defaults true / 300s / 10s and DELETE = switch off.
- Docs branch: `codex/area2-batch3-docs`; nothing pushed or published.
- Area 3 is a separate READ-AND-REPORT file in Downloads, not a build approval.
- AI-tools installation work remains parked.

## Evidence boundary

Owner reports Area 2 batches 1+2 PASS on staging and install runs 1+2 CI green.
Those results were not rerun against cloud services here. Documentation describes
local committed code, not every deployed provider/configuration.

Engine reference: `D:/nixflex-worktrees/chatb-engine`, commit
`e818b03d51a3decaa96593aa2a1aa8d237b0a375` (read-only).
It includes prior Area 2 batch 2 engine commit `7d15d465aa0a0260a38925588a95b6b540e1d54c`.
Docs starting commit: `b927732a38b4bd682f54eaa941c587c195c96b52`.
Dashboard review uses committed `d6ec89f51d325e875d37adc133f8d0202e232068`,
not the other chat's unfinished working files. No other chat's changes were staged.

## What changed

- `concepts/agent-channels.mdx`: inbound / outbound / public website chat / public website voice;
  owner test distinction, effective controls and compatibility-only fields.
- `concepts/agent-inheritance.mdx`: memory/name independence, recording precedence,
  source-aware SMS/voicemail, new-agent retention, per-number website custom functions.
- `concepts/agents.mdx`: prompt precedence, inactive fields, inheritance and truthful disable/read-back.
- `concepts/web-calls.mdx`: website prompt/context, prerequisites, no built-in phone actions.
- `concepts/languages.mdx`: product registry versus primary/fallback recognition and TTS coverage.
- `concepts/voices.mdx`: catalog key, nullable alias, outbound hand-off and route limitations.
- `concepts/data-retention.mdx`, `advanced/call-recording.mdx`: configurable cleanup, overrides,
  pending outcomes and customer-owned copies; removed blanket storage/compliance promises.
- `actions/end-call.mdx`: voicemail/AMD precedence, timer gate versus model END_CALL.
- `api-reference/agents/contract.mdx`, `delete.mdx`: links and switch-off semantics.
- `api-reference/schemas/agent-request.json`: descriptive annotations only, no wire-schema changes.
- `docs.json`: two navigation entries only; no restructuring of this existing large file.
- `tests/agent-channels.test.mjs`: six additional checks; all older tests unchanged.
- Updated the single Agents entry in the external `notes/docs-to-update/DOCS-LEDGER.md`.

## Source anchors (relative to engine reference)

- `shared/data/agentLoader.js:92,198,205,482`: outbound purpose, timer gate, WAIT, recording overrides.
- `web/voiceConfig.js:3`, `web/prompt.js:5`, `shared/features/widgetChat.js:24`:
  public website policy differs from phone instructions and text chat has its own request.
- `shared/features/websiteChatTools.js:7`: per-number website-function permission.
- `shared/features/languagePolicy.js:25,99,137`: actual registry, initial language and route intersection.
- `shared/features/callerMemoryPolicy.js:2`: memory and greeting are independent.
- `shared/features/voicemailPolicy.js:31`, `inbound/features/postCallSms.js:78`: import-source rules.
- `api/agents/createDefaults.js:3`, `api/agents/input.js:21`: defaults and create retention refusal.
- `sql/security-auth/080_01_retention_policies.sql:48`, `095_01_web_retention.sql:17`:
  new-agent default and per-message policy capture; no SQL executed.
- `shared/retention/worker.js:36`, `api/retention.js:10`: cleanup/destination and processing status.
- `outbound/call/callManager.js:334`: catalog voice key now forwarded; no reopening the fixed F8 bug.
- `shared/tts/dispatcher.js:106–110`: catalog mode prioritizes agent voice_key over a
  number's legacy alias. Docs explicitly preserve this limitation; no runtime override fix.

## Area 2 report section 5 disposition

The earlier batch 1+2 drafts already replaced create/update/get/list, shared OpenAPI
agent schemas, default values and validation descriptions. They are preserved.
This batch corrects the remaining concept-page claims, disable explanation and
channel descriptions. Agent schema edits in this batch are descriptions only.
Old SDK channel comments and MCP's over-broad “webhooks are per number, not agent”
description remain kit follow-ups, not authority to change/install/publish kits here.
New defaults do not migrate old agents. No inert setting was activated to match prose.

## Verification

`node --test tests/*.test.mjs`: 18 PASS, 0 failed, 0 skipped (12 existing + 6 new).
`git diff --check`: PASS. Existing test files/assertions unchanged.
Base-versus-draft schema comparison: PASS; only descriptions changed, not validation or wire types.
New files are under 300 lines. The existing large navigation file gets only two entries.
No Mintlify CLI/rendered-site check was available locally; do not call this a published
or browser-verified documentation site. No provider, payment, carrier, Supabase or live-call test.

Area 3 report: `C:/Users/youns/Downloads/Programming Langhuage/API-AREA3-CALLS.md`.
It records source findings, uncertainties, decisions and proposed tests; no fixes built.

## Handoff

Feature branch push only (Fahim runs it; not executed here):

```powershell
git -C "D:\Nixflex Voice Engine\nixflex-docs" push -u origin codex/area2-batch3-docs
```

Do not merge to the publishing branch as part of this run. No zip is required for
these local draft pages plus the directly readable Area 3 report.
