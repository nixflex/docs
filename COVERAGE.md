# API operation coverage — C16

**Current C15, 12 November 2026:** the coordinated local draft contains 353 pages across five tabs, including 164 API pages and all **151 public operations**. The inventory contains 201 numbered rows: 151 public and 50 intentionally non-public. Row 200 adds `DELETE /v1/calls/batch/:id`; row 201 adds B59 `GET /v1/campaigns/:id`. All 149 prior operation IDs remain stable. C14 and exact D7 are merged; the approved B57/B58 source governs deletion and new voice bookings. This is documentation coverage, not a deployment or live-test result.

The public pages contain the final behaviour, without B57 waiting notes. Historical batch reports below preserve their original evidence; their old counts, old deletion contracts and old client inventories are superseded. The final source, native and client evidence is recorded in `notes/codex/2026-11-11-chat-c-C15` outside the published tree.

**Published kits, 12 November (C16):** Node/CLI `10b0e4e`, Python `1259fbd` and MCP `e3ffd7d` are pinned in `spec-source/c15-pages.json`. These K9 commits change documentation only. The directories cover 140 Node methods, 137 Python methods, 146 CLI entries and 97 MCP tools. Public setup uses npm and PyPI installs; Claude must confirm npm `nixflex` 0.11.0, npm `nixflex-mcp` 0.5.0 and PyPI `nixflex` 0.4.0 before pushing. This update makes no customer API requests. All successful-write checks below remain pending manual test. C15 synthetic client evidence remains in its original report; C16 gate evidence is in `notes/codex/2026-11-12-chat-c-C16`.

| Row | Current deletion route | Public page | Node / Python / CLI / MCP | Successful live write |
| --- | --- | --- | --- | --- |
| 86 | `DELETE /v1/calls/:id` | [Delete a call](/api-reference/calls/delete) | yes, published K9 versions | pending manual test |
| 177 | `DELETE /v1/sms/campaigns/:id` | [Delete an SMS campaign](/api-reference/sms/campaigns-delete) | yes, published K9 versions | pending manual test |
| 200 | `DELETE /v1/calls/batch/:id` | [Delete a voice campaign](/api-reference/voice-campaigns/delete) | yes, published K9 versions | pending manual test |
| 201 | `GET /v1/campaigns/:id` | [Get a voice campaign](/api-reference/voice-campaigns/get) | HTTP examples; no dedicated K9 method | 13 isolated real-handler cases PASS; not a hosted test |

| Row / case | Status | Remaining controlled check |
| --- | --- | --- |
| 200 / voice campaign delete | pending manual test | Approved disposable campaign: waiting work cancelled, running calls hung up, campaign/recipients hidden, prior call history and used charges retained. |
| B57 / single-call deletion | pending manual test | Approved disposable call: running and finished cases, 200 recording flags, 503 hangup_pending, automatic completion and same-account/same-ID resume. |
| B57 / SMS campaign deletion | pending manual test | Approved disposable campaign: waiting work cancelled, campaign/recipients hidden, sent SMS history and used charges retained; same-ID resume. |
| B57 / access and uncertainty | pending manual test | Owner/Admin allowed, Member refused, foreign/missing same 404, lost acknowledgement and unavailable deletion reconciled without a write polling loop. |
| B57 / recording cleanup | pending manual test | Controlled Nixflex-copy cleanup and carrier best-effort/queued outcomes; verify customer-managed storage is not deleted. |
| B58 / new voice booking | pending manual test | Approved test booking: full name spelled, email local part spelled, domain spoken as words, one combined read-back and one yes even with the old setting off. Correction re-asks only the wrong part. |
| B58 / existing flows | pending manual test | Controlled SMS booking and existing-booking lookup, move and cancel keep their established flow. |

The user's report says finished-call and waiting voice/SMS-campaign staging tests passed on 11 November. This run does not turn that report into independently executed successful-write evidence. All earlier account creation, key rotation, number import/removal/routing and other successful writes remain **pending manual test**. Never rotate the staging key, create real accounts, or import/remove/re-route either protected staging number. No credentials or live API writes are needed for this docs review.

## Historical C11 handover

**Current C11:** D2 and D3 (cae52b1) joined. The five tabs contain 274 pages: Business 37, Developer 66, API 159, SDKs & CLI 7, AI tools 5. API coverage remains 147 endpoint templates and 12 shared pages. All 66 repository tests pass; OpenAPI validates 1,083 schemas, 315 examples and 25 accepted/refused cases. K6 supplied candidates (Node/CLI 0.11.0, Python 0.4.0, MCP 0.5.0 / 94 tools) are documented in SDKs & CLI. Six artifact hashes and five packaged operations per kit were checked. No live staging requests or writes were run in C11. The earlier C10 GET-only result (1 PASS, 0 FAIL, 150 PENDING without a staging key) is historical. Successful writes remain individually pending manual test below. Generated-site proof and D-owned content issues are listed in the C11 SEO-CHECK and AI-TOOLS-REVIEW; this is not publication approval.

## Historical C9 handover

**Current C9:** 155 API pages, 142 endpoint templates, MCP 89 tools with 19 registered Knowledge examples. All source/build checks pass. The current run has no staging key: authenticated reads and successful writes remain pending manual test. The current evidence and each pending write are listed in the final C9 section below. Earlier results remain here as history.

## Historical C8 handover (superseded by the final C9 section)

Updated 2 November 2026. Engine `038de73355e642f1946ead9eb781ac1c99b3985d` (origin/staging, B49f). Docs branch `codex/c8-knowledge-final`, from accepted C7 `2da2612`. Local draft; not published, merged or pushed.

**Ready to publish on swap day: NO.** K5 MCP approval/registration, the owner’s real-key C8 run and controlled manual checks remain. Page completion is separate from staging-test completion.

| Measure | Count |
| --- | --- |
| operations | 192 |
| public | 142 |
| historicalPublic | 141 |
| nonPublic | 50 |
| done | 132 |
| currentOk | 10 |
| toBuild | 0 |
| openapi | 142 |
| currentPageAbsent | 0 |

The historical 191 rows keep their numbers and classification: 141 public, 50 non-public. Row 192 adds the automatic-keyterms read explicitly requested in C8. There are now 142 documented public operations, including all 141 originally requested. No missing pages.

K4 uses unpublished Node/CLI 0.10.0, Python 0.3.0 and MCP 0.4.0. MCP now has 70 tools (C6 baseline: 44 tools; C7 baseline: 59). All 44 eligible C6 operations have Node/CLI/Python examples. MCP covers 26; 18 credential-setting/disconnect operations have an explicit exclusion. Signing-secret retrieval is dashboard only, no kit. No kit repository was edited.

K5 arrived during C8. All 40 knowledge pages now use its Node/CLI/Python methods, checked against the current candidate source. MCP stays at 70 registered tools: 20 proposed knowledge additions await approval and registration; 20 operations are intentionally excluded. MISSING-PAGES.md lists only the 20 remaining MCP swaps. Row 128’s handover heading incorrectly added /download; the actual engine and kits correctly use /knowledge/exports/:id. Its Python download method takes a query dictionary. Both points are corrected in the pages.

Fahim reports C7 **41 PASS / 0 FAIL / 19 PENDING**: 18 successful writes and one missing read fixture. He also reports the corrected row 55 diagnostic **PASS, HTTP 200, enabled boolean**; that correction remains in C8. These are user-reported results, not C8 live evidence.

C8 has one self-contained PS5.1 runner. It checks 40 new-page invalid-key refusals, 57 eligible read/calculation examples and six keyterm refusals when the credential and fixtures exist. Both protected numbers, signing-secret retrieval and the legacy draft read are blocked. All 83 successful writes remain pending; draft reading and private signing-secret retrieval add two manual checks. No pickup-delay changes. No account creation or key rotation. HTTP=0 GETs retry once after 500 ms and print retried; no writes or POST calculations retry. The 20-term, 50-character and 450-byte refusal payloads include an independent invalid name object to prevent a save even if the term string is grandfathered.

Local C8 run: **40 PASS / 0 FAIL / 148 PENDING**. All 40 passes are documented invalid-key 401 refusals. `NXF_STAGING_KEY` is absent locally; 57 reads/calculations and six keyterm refusals await an authenticated run, plus 85 manual checks. No authenticated staging request was sent.

Final offline checks: **55/55 repository tests**, 1,043 schemas, 277 examples and 767 code blocks PASS. Mint build, OpenAPI validation and broken links PASS. Visual review is pending: the browser controls could not attach; no screenshots were captured.

**Pending B49g:** end fetch at 16:40:50 UTC still points to `038de73`; no later knowledge contract changes are on origin/staging. Recheck automatic-term refresh once B49g lands.

## Pending manual tests

Each successful write stays **pending manual test**. No success is inferred from a validation refusal. Read checks that require unavailable fixtures are also reported pending by the runner. Never use real staging accounts, keys or protected numbers for destructive fixtures.

| Row | Status | Successful check still required |
| --- | --- | --- |
| 1 | pending manual test | POST /v1/keys using a disposable approved fixture and cleanup |
| 2 | pending manual test | POST /v1/keys/rotate using a disposable approved fixture and cleanup |
| 12 | pending manual test | PUT /v1/integrations/calcom/number/:phoneNumber using a disposable approved fixture and cleanup |
| 14 | pending manual test | DELETE /v1/integrations/calcom/number/:phoneNumber using a disposable approved fixture and cleanup |
| 15 | pending manual test | PUT /v1/integrations/slack/number/:phoneNumber using a disposable approved fixture and cleanup |
| 17 | pending manual test | DELETE /v1/integrations/slack/number/:phoneNumber using a disposable approved fixture and cleanup |
| 18 | pending manual test | PUT /v1/integrations/zapier/number/:phoneNumber using a disposable approved fixture and cleanup |
| 20 | pending manual test | DELETE /v1/integrations/zapier/number/:phoneNumber using a disposable approved fixture and cleanup |
| 21 | pending manual test | PUT /v1/integrations/make/number/:phoneNumber using a disposable approved fixture and cleanup |
| 23 | pending manual test | DELETE /v1/integrations/make/number/:phoneNumber using a disposable approved fixture and cleanup |
| 24 | pending manual test | PUT /v1/integrations/gohighlevel/number/:phoneNumber using a disposable approved fixture and cleanup |
| 26 | pending manual test | DELETE /v1/integrations/gohighlevel/number/:phoneNumber using a disposable approved fixture and cleanup |
| 27 | pending manual test | PUT /v1/integrations/webhook/number/:phoneNumber using a disposable approved fixture and cleanup |
| 29 | pending manual test | DELETE /v1/integrations/webhook/number/:phoneNumber using a disposable approved fixture and cleanup |
| 30 | pending manual test | PUT /v1/integrations/webhook2/number/:phoneNumber using a disposable approved fixture and cleanup |
| 36 | pending manual test | PUT /v1/integrations/web-calls/number/:phoneNumber using a disposable approved fixture and cleanup |
| 38 | pending manual test | DELETE /v1/integrations/web-calls/number/:phoneNumber using a disposable approved fixture and cleanup |
| 39 | pending manual test | DELETE /v1/integrations/webhook2/number/:phoneNumber using a disposable approved fixture and cleanup |
| 40 | pending manual test | PUT /v1/integrations/precall/number/:phoneNumber using a disposable approved fixture and cleanup |
| 42 | pending manual test | DELETE /v1/integrations/precall/number/:phoneNumber using a disposable approved fixture and cleanup |
| 43 | pending manual test | PUT /v1/integrations/precall/agent/:agentId using a disposable approved fixture and cleanup |
| 45 | pending manual test | DELETE /v1/integrations/precall/agent/:agentId using a disposable approved fixture and cleanup |
| 46 | pending manual test | POST /v1/integrations/custom-functions/number/:phoneNumber using a disposable approved fixture and cleanup |
| 48 | pending manual test | DELETE /v1/integrations/custom-functions/number/:phoneNumber/:id using a disposable approved fixture and cleanup |
| 49 | pending manual test | PATCH /v1/integrations/custom-functions/number/:phoneNumber/:id using a disposable approved fixture and cleanup |
| 54 | pending manual test | PATCH /v1/agent-inbox/:channel/:number/thread/:thread using a disposable approved fixture and cleanup |
| 59 | pending manual test | PATCH /v1/agent-web/:number using a disposable approved fixture and cleanup |
| 61 | pending manual test | POST /v1/agents using a disposable approved fixture and cleanup |
| 62 | pending manual test | DELETE /v1/agents/:id using a disposable approved fixture and cleanup |
| 64 | pending manual test | PUT /v1/agents/:id using a disposable approved fixture and cleanup |
| 65 | excluded: outside approved MCP permissions | DELETE /v1/agents/:target/knowledge-base using a disposable approved fixture and cleanup |
| 67 | excluded: outside approved MCP permissions | PUT /v1/agents/:target/knowledge-base using a disposable approved fixture and cleanup |
| 70 | yes (K5 registered) | POST /v1/agents/:target/knowledge-base/test-sessions using a disposable approved fixture and cleanup |
| 83 | pending manual test | DELETE /v1/calls using a disposable approved fixture and cleanup |
| 86 | pending manual test | DELETE /v1/calls/:id using a disposable approved fixture and cleanup |
| 90 | pending manual test | POST /v1/calls/batch using a disposable approved fixture and cleanup |
| 91 | pending manual test | POST /v1/calls/batch/:id/cancel using a disposable approved fixture and cleanup |
| 92 | pending manual test | POST /v1/calls/batch/:id/consent using a disposable approved fixture and cleanup |
| 93 | pending manual test | POST /v1/calls/batch/:id/launch using a disposable approved fixture and cleanup |
| 94 | pending manual test | POST /v1/calls/batch/:id/resume using a disposable approved fixture and cleanup |
| 96 | pending manual test | POST /v1/calls/outbound using a disposable approved fixture and cleanup |
| 99 | pending manual test | DELETE /v1/contact-suppressions using a disposable approved fixture and cleanup |
| 101 | pending manual test | POST /v1/contact-suppressions using a disposable approved fixture and cleanup |
| 104 | excluded: outside approved MCP permissions | DELETE /v1/knowledge-bases/:kb/drafts/:id using a disposable approved fixture and cleanup |
| 105 | excluded: draft GET can save repairs | Legacy draft read and any resulting repair in a controlled fixture |
| 106 | excluded: outside approved MCP permissions | PATCH /v1/knowledge-bases/:kb/drafts/:id using a disposable approved fixture and cleanup |
| 107 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/drafts/:id/accept using a disposable approved fixture and cleanup |
| 108 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/exports using a disposable approved fixture and cleanup |
| 110 | excluded: outside approved MCP permissions | PATCH /v1/knowledge-bases/:kb/settings using a disposable approved fixture and cleanup |
| 112 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/sources using a disposable approved fixture and cleanup |
| 113 | excluded: outside approved MCP permissions | DELETE /v1/knowledge-bases/:kb/sources/:id using a disposable approved fixture and cleanup |
| 114 | excluded: outside approved MCP permissions | PATCH /v1/knowledge-bases/:kb/sources/:id using a disposable approved fixture and cleanup |
| 115 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/sources/:id/replacements using a disposable approved fixture and cleanup |
| 116 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/sources/refresh using a disposable approved fixture and cleanup |
| 119 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/topics using a disposable approved fixture and cleanup |
| 120 | excluded: outside approved MCP permissions | DELETE /v1/knowledge-bases/:kb/topics/:id using a disposable approved fixture and cleanup |
| 122 | excluded: outside approved MCP permissions | PATCH /v1/knowledge-bases/:kb/topics/:id using a disposable approved fixture and cleanup |
| 124 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/website-discoveries using a disposable approved fixture and cleanup |
| 125 | excluded: outside approved MCP permissions | POST /v1/knowledge-bases/:kb/website-imports using a disposable approved fixture and cleanup |
| 130 | excluded: outside approved MCP permissions | POST /v1/knowledge/jobs/:id/cancel using a disposable approved fixture and cleanup |
| 131 | excluded: outside approved MCP permissions | POST /v1/knowledge/jobs/:id/retry using a disposable approved fixture and cleanup |
| 134 | yes (K5 registered) | POST /v1/knowledge/test-sessions/:id/cancel using a disposable approved fixture and cleanup |
| 135 | yes (K5 registered) | POST /v1/knowledge/test-sessions/:id/messages using a disposable approved fixture and cleanup |
| 146 | pending manual test | POST /v1/organisation/claim-invite using a disposable approved fixture and cleanup |
| 148 | pending manual test | POST /v1/organisation/invites using a disposable approved fixture and cleanup |
| 149 | pending manual test | DELETE /v1/organisation/invites/:id using a disposable approved fixture and cleanup |
| 150 | pending manual test | POST /v1/organisation/invites/:id/resend using a disposable approved fixture and cleanup |
| 153 | pending manual test | DELETE /v1/organisation/members/:id using a disposable approved fixture and cleanup |
| 154 | pending manual test | PATCH /v1/organisation/members/:id using a disposable approved fixture and cleanup |
| 155 | pending manual test | PATCH /v1/organisation/name using a disposable approved fixture and cleanup |
| 158 | pending manual test | Private Owner dashboard signing-secret workflow |
| 165 | pending manual test | POST /v1/phone-numbers using a disposable approved fixture and cleanup |
| 166 | pending manual test | DELETE /v1/phone-numbers/:phoneNumber using a disposable approved fixture and cleanup |
| 168 | pending manual test | PATCH /v1/phone-numbers/:phoneNumber using a disposable approved fixture and cleanup |
| 169 | pending manual test | DELETE /v1/phone-numbers/:phoneNumber/callers/:callerNumber using a disposable approved fixture and cleanup |
| 171 | pending manual test | PUT /v1/phone-numbers/:phoneNumber/callers/:callerNumber using a disposable approved fixture and cleanup |
| 172 | pending manual test | POST /v1/phone-numbers/:phoneNumber/callers/import using a disposable approved fixture and cleanup |
| 174 | pending manual test | POST /v1/sms using a disposable approved fixture and cleanup |
| 176 | pending manual test | POST /v1/sms/campaigns using a disposable approved fixture and cleanup |
| 177 | pending manual test | DELETE /v1/sms/campaigns/:id using a disposable approved fixture and cleanup |
| 179 | pending manual test | PATCH /v1/sms/campaigns/:id using a disposable approved fixture and cleanup |
| 180 | pending manual test | POST /v1/sms/campaigns/:id/cancel using a disposable approved fixture and cleanup |
| 181 | pending manual test | POST /v1/sms/campaigns/:id/consent using a disposable approved fixture and cleanup |
| 182 | pending manual test | POST /v1/sms/campaigns/:id/launch using a disposable approved fixture and cleanup |
| 183 | pending manual test | POST /v1/sms/campaigns/:id/resume using a disposable approved fixture and cleanup |

## Operation matrix

| Row | Method | Path | Scope | Page status | Page | OpenAPI | Node | CLI | Python | MCP | Test status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | POST | `/v1/keys` | public | done | [api-reference/account/create-key](/api-reference/account/create-key) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 2 | POST | `/v1/keys/rotate` | public | done | [api-reference/account/rotate-key](/api-reference/account/rotate-key) | yes | yes | yes | yes | yes | pending manual test |
| 3 | PUT | `/v1/account/tts` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 4 | GET | `/v1/account/tts` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 5 | DELETE | `/v1/account/tts` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 6 | PUT | `/v1/account/llm` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 7 | GET | `/v1/account/llm` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 8 | DELETE | `/v1/account/llm` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 9 | PUT | `/v1/account/storage` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 10 | GET | `/v1/account/storage` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 11 | DELETE | `/v1/account/storage` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 12 | PUT | `/v1/integrations/calcom/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-calcom-number-phoneNumber](/api-reference/integration-settings/put-integrations-calcom-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 13 | GET | `/v1/integrations/calcom/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-calcom-number-phoneNumber](/api-reference/integration-settings/get-integrations-calcom-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 14 | DELETE | `/v1/integrations/calcom/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-calcom-number-phoneNumber](/api-reference/integration-settings/delete-integrations-calcom-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 15 | PUT | `/v1/integrations/slack/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-slack-number-phoneNumber](/api-reference/integration-settings/put-integrations-slack-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 16 | GET | `/v1/integrations/slack/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-slack-number-phoneNumber](/api-reference/integration-settings/get-integrations-slack-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 17 | DELETE | `/v1/integrations/slack/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-slack-number-phoneNumber](/api-reference/integration-settings/delete-integrations-slack-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 18 | PUT | `/v1/integrations/zapier/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-zapier-number-phoneNumber](/api-reference/integration-settings/put-integrations-zapier-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 19 | GET | `/v1/integrations/zapier/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-zapier-number-phoneNumber](/api-reference/integration-settings/get-integrations-zapier-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 20 | DELETE | `/v1/integrations/zapier/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-zapier-number-phoneNumber](/api-reference/integration-settings/delete-integrations-zapier-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 21 | PUT | `/v1/integrations/make/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-make-number-phoneNumber](/api-reference/integration-settings/put-integrations-make-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 22 | GET | `/v1/integrations/make/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-make-number-phoneNumber](/api-reference/integration-settings/get-integrations-make-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 23 | DELETE | `/v1/integrations/make/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-make-number-phoneNumber](/api-reference/integration-settings/delete-integrations-make-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 24 | PUT | `/v1/integrations/gohighlevel/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-gohighlevel-number-phoneNumber](/api-reference/integration-settings/put-integrations-gohighlevel-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 25 | GET | `/v1/integrations/gohighlevel/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-gohighlevel-number-phoneNumber](/api-reference/integration-settings/get-integrations-gohighlevel-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 26 | DELETE | `/v1/integrations/gohighlevel/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-gohighlevel-number-phoneNumber](/api-reference/integration-settings/delete-integrations-gohighlevel-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 27 | PUT | `/v1/integrations/webhook/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-webhook-number-phoneNumber](/api-reference/integration-settings/put-integrations-webhook-number-phoneNumber) | yes | yes | yes | yes | yes | pending manual test |
| 28 | GET | `/v1/integrations/webhook/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-webhook-number-phoneNumber](/api-reference/integration-settings/get-integrations-webhook-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 29 | DELETE | `/v1/integrations/webhook/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-webhook-number-phoneNumber](/api-reference/integration-settings/delete-integrations-webhook-number-phoneNumber) | yes | yes | yes | yes | yes | pending manual test |
| 30 | PUT | `/v1/integrations/webhook2/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-webhook2-number-phoneNumber](/api-reference/integration-settings/put-integrations-webhook2-number-phoneNumber) | yes | yes | yes | yes | yes | pending manual test |
| 31 | GET | `/v1/integrations/webhook2/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-webhook2-number-phoneNumber](/api-reference/integration-settings/get-integrations-webhook2-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 32 | GET | `/v1/monitor/calls` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 33 | PUT | `/v1/integrations/monitor/number/:phoneNumber` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 34 | GET | `/v1/integrations/monitor/number/:phoneNumber` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 35 | DELETE | `/v1/integrations/monitor/number/:phoneNumber` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 36 | PUT | `/v1/integrations/web-calls/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-web-calls-number-phoneNumber](/api-reference/integration-settings/put-integrations-web-calls-number-phoneNumber) | yes | yes | yes | yes | yes | pending manual test |
| 37 | GET | `/v1/integrations/web-calls/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-web-calls-number-phoneNumber](/api-reference/integration-settings/get-integrations-web-calls-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 38 | DELETE | `/v1/integrations/web-calls/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-web-calls-number-phoneNumber](/api-reference/integration-settings/delete-integrations-web-calls-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 39 | DELETE | `/v1/integrations/webhook2/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-webhook2-number-phoneNumber](/api-reference/integration-settings/delete-integrations-webhook2-number-phoneNumber) | yes | yes | yes | yes | yes | pending manual test |
| 40 | PUT | `/v1/integrations/precall/number/:phoneNumber` | public | done | [api-reference/integration-settings/put-integrations-precall-number-phoneNumber](/api-reference/integration-settings/put-integrations-precall-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 41 | GET | `/v1/integrations/precall/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-precall-number-phoneNumber](/api-reference/integration-settings/get-integrations-precall-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 42 | DELETE | `/v1/integrations/precall/number/:phoneNumber` | public | done | [api-reference/integration-settings/delete-integrations-precall-number-phoneNumber](/api-reference/integration-settings/delete-integrations-precall-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 43 | PUT | `/v1/integrations/precall/agent/:agentId` | public | done | [api-reference/integration-settings/put-integrations-precall-agent-agentId](/api-reference/integration-settings/put-integrations-precall-agent-agentId) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 44 | GET | `/v1/integrations/precall/agent/:agentId` | public | done | [api-reference/integration-settings/get-integrations-precall-agent-agentId](/api-reference/integration-settings/get-integrations-precall-agent-agentId) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 45 | DELETE | `/v1/integrations/precall/agent/:agentId` | public | done | [api-reference/integration-settings/delete-integrations-precall-agent-agentId](/api-reference/integration-settings/delete-integrations-precall-agent-agentId) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 46 | POST | `/v1/integrations/custom-functions/number/:phoneNumber` | public | done | [api-reference/integration-settings/post-integrations-custom-functions-number-phoneNumber](/api-reference/integration-settings/post-integrations-custom-functions-number-phoneNumber) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 47 | GET | `/v1/integrations/custom-functions/number/:phoneNumber` | public | done | [api-reference/integration-settings/get-integrations-custom-functions-number-phoneNumber](/api-reference/integration-settings/get-integrations-custom-functions-number-phoneNumber) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 48 | DELETE | `/v1/integrations/custom-functions/number/:phoneNumber/:id` | public | done | [api-reference/integration-settings/delete-integrations-custom-functions-number-phoneNumber-id](/api-reference/integration-settings/delete-integrations-custom-functions-number-phoneNumber-id) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 49 | PATCH | `/v1/integrations/custom-functions/number/:phoneNumber/:id` | public | done | [api-reference/integration-settings/patch-integrations-custom-functions-number-phoneNumber-id](/api-reference/integration-settings/patch-integrations-custom-functions-number-phoneNumber-id) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 50 | POST | `/v1/account/delete` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 51 | GET | `/v1/account/retention` | public | done | [api-reference/account-and-keys/get-account-retention](/api-reference/account-and-keys/get-account-retention) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 52 | GET | `/v1/agent-inbox/:channel/:number` | public | done | [api-reference/agent-inbox/get-agent-inbox-channel-number](/api-reference/agent-inbox/get-agent-inbox-channel-number) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 53 | GET | `/v1/agent-inbox/:channel/:number/thread/:thread` | public | done | [api-reference/agent-inbox/get-agent-inbox-channel-number-thread-thread](/api-reference/agent-inbox/get-agent-inbox-channel-number-thread-thread) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 54 | PATCH | `/v1/agent-inbox/:channel/:number/thread/:thread` | public | done | [api-reference/agent-inbox/patch-agent-inbox-channel-number-thread-thread](/api-reference/agent-inbox/patch-agent-inbox-channel-number-thread-thread) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 55 | GET | `/v1/agent-inbox/features` | public | done | [api-reference/agent-inbox/get-agent-inbox-features](/api-reference/agent-inbox/get-agent-inbox-features) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 56 | GET | `/v1/agent-inbox/numbers` | public | done | [api-reference/agent-inbox/get-agent-inbox-numbers](/api-reference/agent-inbox/get-agent-inbox-numbers) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 57 | GET | `/v1/agent-inbox/retention` | public | done | [api-reference/agent-inbox/get-agent-inbox-retention](/api-reference/agent-inbox/get-agent-inbox-retention) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 58 | GET | `/v1/agent-web/:number` | public | done | [api-reference/web-agent/get-agent-web-number](/api-reference/web-agent/get-agent-web-number) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 59 | PATCH | `/v1/agent-web/:number` | public | done | [api-reference/web-agent/patch-agent-web-number](/api-reference/web-agent/patch-agent-web-number) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 60 | GET | `/v1/agents` | public | current-ok | [api-reference/agents/list](/api-reference/agents/list) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 61 | POST | `/v1/agents` | public | done | [api-reference/agents/create](/api-reference/agents/create) | yes | yes | yes | yes | yes | pending manual test |
| 62 | DELETE | `/v1/agents/:id` | public | current-ok | [api-reference/agents/delete](/api-reference/agents/delete) | yes | yes | yes | yes | yes | pending manual test |
| 63 | GET | `/v1/agents/:id` | public | current-ok | [api-reference/agents/get](/api-reference/agents/get) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 64 | PUT | `/v1/agents/:id` | public | done | [api-reference/agents/update](/api-reference/agents/update) | yes | yes | yes | yes | yes | pending manual test |
| 65 | DELETE | `/v1/agents/:target/knowledge-base` | public | done | [api-reference/knowledge/delete-agents-target-knowledge-base](/api-reference/knowledge/delete-agents-target-knowledge-base) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 66 | GET | `/v1/agents/:target/knowledge-base` | public | done | [api-reference/knowledge/get-agents-target-knowledge-base](/api-reference/knowledge/get-agents-target-knowledge-base) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 67 | PUT | `/v1/agents/:target/knowledge-base` | public | done | [api-reference/knowledge/put-agents-target-knowledge-base](/api-reference/knowledge/put-agents-target-knowledge-base) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 68 | POST | `/v1/agents/:target/knowledge-base/prompt-measure` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 69 | POST | `/v1/agents/:target/knowledge-base/source-measure` | public | done | [api-reference/knowledge/post-agents-target-knowledge-base-source-measure](/api-reference/knowledge/post-agents-target-knowledge-base-source-measure) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 70 | POST | `/v1/agents/:target/knowledge-base/test-sessions` | public | done | [api-reference/knowledge/post-agents-target-knowledge-base-test-sessions](/api-reference/knowledge/post-agents-target-knowledge-base-test-sessions) | yes | yes | yes | yes | yes (K5 registered) | pending manual test |
| 71 | GET | `/v1/agents/:target/knowledge-numbers` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 72 | POST | `/v1/agents/prompt-admission` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 73 | POST | `/v1/agents/prompt-measure` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 74 | POST | `/v1/billing/auto-topup-card` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 75 | POST | `/v1/billing/auto-topup-settings` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 76 | POST | `/v1/billing/checkout` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 77 | POST | `/v1/billing/dismiss-failure` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 78 | POST | `/v1/billing/invoice-details` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 79 | GET | `/v1/billing/payments/:id` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 80 | POST | `/v1/billing/portal` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 81 | GET | `/v1/billing/status` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 82 | POST | `/v1/billing/webhook` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 83 | DELETE | `/v1/calls` | public | current-ok | [api-reference/calls/delete-all](/api-reference/calls/delete-all) | yes | yes | yes | yes | excluded by decision | pending manual test |
| 84 | GET | `/v1/calls` | public | done | [api-reference/calls/list](/api-reference/calls/list) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 85 | POST | `/v1/calls/:call_id/end` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 86 | DELETE | `/v1/calls/:id` | public | current-ok | [api-reference/calls/delete](/api-reference/calls/delete) | yes | yes | yes | yes | yes | pending manual test |
| 87 | GET | `/v1/calls/:id` | public | done | [api-reference/calls/get](/api-reference/calls/get) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 88 | GET | `/v1/calls/:id/billing` | non-public | excluded | — | no | yes | yes | yes | yes | excluded |
| 89 | GET | `/v1/calls/:id/recording` | public | done | [api-reference/calls/get-calls-id-recording](/api-reference/calls/get-calls-id-recording) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 90 | POST | `/v1/calls/batch` | public | done | [api-reference/calls/batch-create](/api-reference/calls/batch-create) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 91 | POST | `/v1/calls/batch/:id/cancel` | public | done | [api-reference/voice-campaigns/post-calls-batch-id-cancel](/api-reference/voice-campaigns/post-calls-batch-id-cancel) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 92 | POST | `/v1/calls/batch/:id/consent` | public | done | [api-reference/voice-campaigns/post-calls-batch-id-consent](/api-reference/voice-campaigns/post-calls-batch-id-consent) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | excluded: can enable outreach | pending manual test |
| 93 | POST | `/v1/calls/batch/:id/launch` | public | done | [api-reference/calls/batch-launch](/api-reference/calls/batch-launch) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 94 | POST | `/v1/calls/batch/:id/resume` | public | done | [api-reference/voice-campaigns/post-calls-batch-id-resume](/api-reference/voice-campaigns/post-calls-batch-id-resume) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | excluded: can enable outreach | pending manual test |
| 95 | GET | `/v1/calls/history` | public | done | [api-reference/calls/get-calls-history](/api-reference/calls/get-calls-history) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 96 | POST | `/v1/calls/outbound` | public | done | [api-reference/calls/create-outbound](/api-reference/calls/create-outbound) | yes | yes | yes | yes | yes | pending manual test |
| 97 | GET | `/v1/campaigns` | public | done | [api-reference/voice-campaigns/get-campaigns](/api-reference/voice-campaigns/get-campaigns) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 98 | POST | `/v1/contact-hours/preview` | public | done | [api-reference/contact-controls/post-contact-hours-preview](/api-reference/contact-controls/post-contact-hours-preview) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 99 | DELETE | `/v1/contact-suppressions` | public | done | [api-reference/contact-controls/delete-contact-suppressions](/api-reference/contact-controls/delete-contact-suppressions) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | excluded: can enable outreach | pending manual test |
| 100 | GET | `/v1/contact-suppressions` | public | done | [api-reference/contact-controls/get-contact-suppressions](/api-reference/contact-controls/get-contact-suppressions) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 101 | POST | `/v1/contact-suppressions` | public | done | [api-reference/contact-controls/post-contact-suppressions](/api-reference/contact-controls/post-contact-suppressions) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 102 | GET | `/v1/keys/activity` | public | done | [api-reference/account-and-keys/get-keys-activity](/api-reference/account-and-keys/get-keys-activity) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 103 | GET | `/v1/knowledge-bases/:kb` | public | done | [api-reference/knowledge/get-knowledge-bases-kb](/api-reference/knowledge/get-knowledge-bases-kb) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 104 | DELETE | `/v1/knowledge-bases/:kb/drafts/:id` | public | done | [api-reference/knowledge/delete-knowledge-bases-kb-drafts-id](/api-reference/knowledge/delete-knowledge-bases-kb-drafts-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 105 | GET | `/v1/knowledge-bases/:kb/drafts/:id` | public | done | [api-reference/knowledge/get-knowledge-bases-kb-drafts-id](/api-reference/knowledge/get-knowledge-bases-kb-drafts-id) | yes | yes | yes | yes | excluded: draft GET can save repairs | pending manual test |
| 106 | PATCH | `/v1/knowledge-bases/:kb/drafts/:id` | public | done | [api-reference/knowledge/patch-knowledge-bases-kb-drafts-id](/api-reference/knowledge/patch-knowledge-bases-kb-drafts-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 107 | POST | `/v1/knowledge-bases/:kb/drafts/:id/accept` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-drafts-id-accept](/api-reference/knowledge/post-knowledge-bases-kb-drafts-id-accept) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 108 | POST | `/v1/knowledge-bases/:kb/exports` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-exports](/api-reference/knowledge/post-knowledge-bases-kb-exports) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 109 | GET | `/v1/knowledge-bases/:kb/overview` | public | done | [api-reference/knowledge/get-knowledge-bases-kb-overview](/api-reference/knowledge/get-knowledge-bases-kb-overview) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 110 | PATCH | `/v1/knowledge-bases/:kb/settings` | public | done | [api-reference/knowledge/patch-knowledge-bases-kb-settings](/api-reference/knowledge/patch-knowledge-bases-kb-settings) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 111 | GET | `/v1/knowledge-bases/:kb/sources` | public | done | [api-reference/knowledge/get-knowledge-bases-kb-sources](/api-reference/knowledge/get-knowledge-bases-kb-sources) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 112 | POST | `/v1/knowledge-bases/:kb/sources` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-sources](/api-reference/knowledge/post-knowledge-bases-kb-sources) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 113 | DELETE | `/v1/knowledge-bases/:kb/sources/:id` | public | done | [api-reference/knowledge/delete-knowledge-bases-kb-sources-id](/api-reference/knowledge/delete-knowledge-bases-kb-sources-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 114 | PATCH | `/v1/knowledge-bases/:kb/sources/:id` | public | done | [api-reference/knowledge/patch-knowledge-bases-kb-sources-id](/api-reference/knowledge/patch-knowledge-bases-kb-sources-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 115 | POST | `/v1/knowledge-bases/:kb/sources/:id/replacements` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-sources-id-replacements](/api-reference/knowledge/post-knowledge-bases-kb-sources-id-replacements) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 116 | POST | `/v1/knowledge-bases/:kb/sources/refresh` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-sources-refresh](/api-reference/knowledge/post-knowledge-bases-kb-sources-refresh) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 117 | POST | `/v1/knowledge-bases/:kb/topic-search` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-topic-search](/api-reference/knowledge/post-knowledge-bases-kb-topic-search) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 118 | GET | `/v1/knowledge-bases/:kb/topics` | public | done | [api-reference/knowledge/get-knowledge-bases-kb-topics](/api-reference/knowledge/get-knowledge-bases-kb-topics) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 119 | POST | `/v1/knowledge-bases/:kb/topics` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-topics](/api-reference/knowledge/post-knowledge-bases-kb-topics) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 120 | DELETE | `/v1/knowledge-bases/:kb/topics/:id` | public | done | [api-reference/knowledge/delete-knowledge-bases-kb-topics-id](/api-reference/knowledge/delete-knowledge-bases-kb-topics-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 121 | GET | `/v1/knowledge-bases/:kb/topics/:id` | public | done | [api-reference/knowledge/get-knowledge-bases-kb-topics-id](/api-reference/knowledge/get-knowledge-bases-kb-topics-id) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 122 | PATCH | `/v1/knowledge-bases/:kb/topics/:id` | public | done | [api-reference/knowledge/patch-knowledge-bases-kb-topics-id](/api-reference/knowledge/patch-knowledge-bases-kb-topics-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 123 | GET | `/v1/knowledge-bases/:kb/unanswered` | public | done | [api-reference/knowledge/get-knowledge-bases-kb-unanswered](/api-reference/knowledge/get-knowledge-bases-kb-unanswered) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 124 | POST | `/v1/knowledge-bases/:kb/website-discoveries` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-website-discoveries](/api-reference/knowledge/post-knowledge-bases-kb-website-discoveries) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 125 | POST | `/v1/knowledge-bases/:kb/website-imports` | public | done | [api-reference/knowledge/post-knowledge-bases-kb-website-imports](/api-reference/knowledge/post-knowledge-bases-kb-website-imports) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 126 | GET | `/v1/knowledge/capabilities` | public | done | [api-reference/knowledge/get-knowledge-capabilities](/api-reference/knowledge/get-knowledge-capabilities) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 127 | GET | `/v1/knowledge/events` | public | done | [api-reference/knowledge/get-knowledge-events](/api-reference/knowledge/get-knowledge-events) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 128 | GET | `/v1/knowledge/exports/:id` | public | done | [api-reference/knowledge/get-knowledge-exports-id](/api-reference/knowledge/get-knowledge-exports-id) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending staging run; fixture-dependent reads may remain pending manual test |
| 129 | GET | `/v1/knowledge/jobs/:id` | public | done | [api-reference/knowledge/get-knowledge-jobs-id](/api-reference/knowledge/get-knowledge-jobs-id) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 130 | POST | `/v1/knowledge/jobs/:id/cancel` | public | done | [api-reference/knowledge/post-knowledge-jobs-id-cancel](/api-reference/knowledge/post-knowledge-jobs-id-cancel) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 131 | POST | `/v1/knowledge/jobs/:id/retry` | public | done | [api-reference/knowledge/post-knowledge-jobs-id-retry](/api-reference/knowledge/post-knowledge-jobs-id-retry) | yes | yes | yes | yes | excluded: outside approved MCP permissions | pending manual test |
| 132 | GET | `/v1/knowledge/targets` | public | done | [api-reference/knowledge/get-knowledge-targets](/api-reference/knowledge/get-knowledge-targets) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 133 | GET | `/v1/knowledge/test-sessions/:id` | public | done | [api-reference/knowledge/get-knowledge-test-sessions-id](/api-reference/knowledge/get-knowledge-test-sessions-id) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 134 | POST | `/v1/knowledge/test-sessions/:id/cancel` | public | done | [api-reference/knowledge/post-knowledge-test-sessions-id-cancel](/api-reference/knowledge/post-knowledge-test-sessions-id-cancel) | yes | yes | yes | yes | yes (K5 registered) | pending manual test |
| 135 | POST | `/v1/knowledge/test-sessions/:id/messages` | public | done | [api-reference/knowledge/post-knowledge-test-sessions-id-messages](/api-reference/knowledge/post-knowledge-test-sessions-id-messages) | yes | yes | yes | yes | yes (K5 registered) | pending manual test |
| 136 | GET | `/v1/knowledge/usage` | public | done | [api-reference/knowledge/get-knowledge-usage](/api-reference/knowledge/get-knowledge-usage) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |
| 137 | DELETE | `/v1/numbers/:target/knowledge-base` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 138 | GET | `/v1/numbers/:target/knowledge-base` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 139 | PUT | `/v1/numbers/:target/knowledge-base` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 140 | POST | `/v1/numbers/:target/knowledge-base/source-measure` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 141 | POST | `/v1/numbers/:target/knowledge-base/test-sessions` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 142 | PATCH | `/v1/numbers/:target/knowledge-policy` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 143 | GET | `/v1/organisation` | public | done | [api-reference/organisation/get-organisation](/api-reference/organisation/get-organisation) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 144 | POST | `/v1/organisation/accept` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 145 | GET | `/v1/organisation/activity` | public | done | [api-reference/organisation/get-organisation-activity](/api-reference/organisation/get-organisation-activity) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 146 | POST | `/v1/organisation/claim-invite` | public | done | [api-reference/organisation/post-organisation-claim-invite](/api-reference/organisation/post-organisation-claim-invite) | yes | yes | yes | yes | yes | pending manual test |
| 147 | POST | `/v1/organisation/invite-preview` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 148 | POST | `/v1/organisation/invites` | public | done | [api-reference/organisation/post-organisation-invites](/api-reference/organisation/post-organisation-invites) | yes | yes | yes | yes | yes | pending manual test |
| 149 | DELETE | `/v1/organisation/invites/:id` | public | done | [api-reference/organisation/delete-organisation-invites-id](/api-reference/organisation/delete-organisation-invites-id) | yes | yes | yes | yes | yes | pending manual test |
| 150 | POST | `/v1/organisation/invites/:id/resend` | public | done | [api-reference/organisation/post-organisation-invites-id-resend](/api-reference/organisation/post-organisation-invites-id-resend) | yes | yes | yes | yes | yes | pending manual test |
| 151 | POST | `/v1/organisation/join` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 152 | GET | `/v1/organisation/members` | public | done | [api-reference/organisation/get-organisation-members](/api-reference/organisation/get-organisation-members) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 153 | DELETE | `/v1/organisation/members/:id` | public | done | [api-reference/organisation/delete-organisation-members-id](/api-reference/organisation/delete-organisation-members-id) | yes | yes | yes | yes | yes | pending manual test |
| 154 | PATCH | `/v1/organisation/members/:id` | public | done | [api-reference/organisation/patch-organisation-members-id](/api-reference/organisation/patch-organisation-members-id) | yes | yes | yes | yes | yes | pending manual test |
| 155 | PATCH | `/v1/organisation/name` | public | done | [api-reference/organisation/patch-organisation-name](/api-reference/organisation/patch-organisation-name) | yes | yes | yes | yes | yes | pending manual test |
| 156 | GET | `/v1/organisation/pending-invite` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 157 | POST | `/v1/organisation/review-invite` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 158 | GET | `/v1/organisation/signing-secret` | public | done | [api-reference/organisation/get-organisation-signing-secret](/api-reference/organisation/get-organisation-signing-secret) | yes | excluded by decision | excluded by decision | excluded by decision | excluded by decision | pending manual test |
| 159 | POST | `/v1/organisation/transfer/accept` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 160 | POST | `/v1/organisation/transfer/cancel` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 161 | POST | `/v1/organisation/transfer/decline` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 162 | GET | `/v1/organisation/transfer/pending` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 163 | POST | `/v1/organisation/transfer/request` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 164 | GET | `/v1/phone-numbers` | public | current-ok | [api-reference/phone-numbers/list](/api-reference/phone-numbers/list) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 165 | POST | `/v1/phone-numbers` | public | done | [api-reference/phone-numbers/import](/api-reference/phone-numbers/import) | yes | yes | yes | yes | yes | pending manual test |
| 166 | DELETE | `/v1/phone-numbers/:phoneNumber` | public | done | [api-reference/phone-numbers/delete](/api-reference/phone-numbers/delete) | yes | yes | yes | yes | yes | pending manual test |
| 167 | GET | `/v1/phone-numbers/:phoneNumber` | public | current-ok | [api-reference/phone-numbers/get](/api-reference/phone-numbers/get) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 168 | PATCH | `/v1/phone-numbers/:phoneNumber` | public | done | [api-reference/phone-numbers/update](/api-reference/phone-numbers/update) | yes | yes | yes | yes | yes | pending manual test |
| 169 | DELETE | `/v1/phone-numbers/:phoneNumber/callers/:callerNumber` | public | done | [api-reference/caller-context/delete](/api-reference/caller-context/delete) | yes | yes | yes | yes | yes | pending manual test |
| 170 | GET | `/v1/phone-numbers/:phoneNumber/callers/:callerNumber` | public | current-ok | [api-reference/caller-context/get](/api-reference/caller-context/get) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 171 | PUT | `/v1/phone-numbers/:phoneNumber/callers/:callerNumber` | public | current-ok | [api-reference/caller-context/set](/api-reference/caller-context/set) | yes | yes | yes | yes | yes | pending manual test |
| 172 | POST | `/v1/phone-numbers/:phoneNumber/callers/import` | public | done | [api-reference/caller-context/import](/api-reference/caller-context/import) | yes | yes | yes | yes | yes | pending manual test |
| 173 | GET | `/v1/phone-numbers/:phoneNumber/usage` | public | current-ok | [api-reference/phone-numbers/usage](/api-reference/phone-numbers/usage) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 174 | POST | `/v1/sms` | public | done | [api-reference/sms/send](/api-reference/sms/send) | yes | yes | yes | yes | yes | pending manual test |
| 175 | GET | `/v1/sms/campaigns` | public | done | [api-reference/sms/campaigns-list](/api-reference/sms/campaigns-list) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 176 | POST | `/v1/sms/campaigns` | public | done | [api-reference/sms/campaigns-create](/api-reference/sms/campaigns-create) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 177 | DELETE | `/v1/sms/campaigns/:id` | public | done | [api-reference/sms/campaigns-delete](/api-reference/sms/campaigns-delete) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 178 | GET | `/v1/sms/campaigns/:id` | public | done | [api-reference/sms/campaigns-get](/api-reference/sms/campaigns-get) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending staging run; fixture-dependent reads may remain pending manual test |
| 179 | PATCH | `/v1/sms/campaigns/:id` | public | done | [api-reference/sms-campaigns/patch-sms-campaigns-id](/api-reference/sms-campaigns/patch-sms-campaigns-id) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 180 | POST | `/v1/sms/campaigns/:id/cancel` | public | done | [api-reference/sms-campaigns/post-sms-campaigns-id-cancel](/api-reference/sms-campaigns/post-sms-campaigns-id-cancel) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 181 | POST | `/v1/sms/campaigns/:id/consent` | public | done | [api-reference/sms-campaigns/post-sms-campaigns-id-consent](/api-reference/sms-campaigns/post-sms-campaigns-id-consent) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | excluded: can enable outreach | pending manual test |
| 182 | POST | `/v1/sms/campaigns/:id/launch` | public | done | [api-reference/sms/campaigns-launch](/api-reference/sms/campaigns-launch) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | yes (K3) | pending manual test |
| 183 | POST | `/v1/sms/campaigns/:id/resume` | public | done | [api-reference/sms-campaigns/post-sms-campaigns-id-resume](/api-reference/sms-campaigns/post-sms-campaigns-id-resume) | yes | yes (K3) | yes (K3) | yes (K3 sync/async) | excluded: can enable outreach | pending manual test |
| 184 | POST | `/v1/tester/start` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 185 | GET | `/v1/tester/status` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 186 | GET | `/v1/usage` | public | done | [api-reference/account/usage](/api-reference/account/usage) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 187 | GET | `/v1/voices` | public | done | [api-reference/voices/get-voices](/api-reference/voices/get-voices) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 188 | GET | `/v1/voices/:voice_key` | public | done | [api-reference/voices/get-voices-voice_key](/api-reference/voices/get-voices-voice_key) | yes | yes | yes | yes | yes | pending staging run; fixture-dependent reads may remain pending manual test |
| 189 | POST | `/v1/widget/installed` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 190 | POST | `/v1/widget/message` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 191 | GET | `/v1/agents/:target/knowledge-base/test-options` | non-public | excluded | — | no | missing | missing | missing | missing | excluded |
| 192 | GET | `/v1/agents/:target/knowledge-keyterms` | public | done | [api-reference/knowledge/get-agents-target-knowledge-keyterms](/api-reference/knowledge/get-agents-target-knowledge-keyterms) | yes | yes | yes | yes | yes (K5 registered) | pending staging run; fixture-dependent reads may remain pending manual test |

## 3 November 2026 — C9 final API reference checks

Current documentation: 155 navigation pages, 142 public operations, 19 registered Knowledge MCP examples; MCP total 89. Existing slugs and non-API tabs are preserved.

| Check | Current result |
| --- | --- |
| Row 84 GET calls | PASS offline: wire empty/one/multiple arrays accepted; wrong root types rejected. Authenticated staging rerun pending manual test. |
| Row 187 GET voices | PASS offline: null accent language/locale/label accepted; numeric accent metadata rejected. Authenticated staging rerun pending manual test. |
| Row 55 inbox features | Earlier real staging PASS reported by Fahim; C9 offline boolean regression PASS. Current authenticated rerun pending manual test. |
| Caller absence | Exact 404 caller_not_found required on a verified owned number. Wrong 404 code is rejected offline. Live check pending manual test. |
| Keyterms read | All six fields required; counts match arrays and manual limit is 20. Offline PASS; live read pending manual test. |
| C8-TEST.ps1 live run here | PASS=1 FAIL=0 PENDING=145. Only unauthenticated retired account GET ran; NXF_STAGING_KEY is absent. No authenticated success is claimed. |
| C8-TEST.ps1 offline complete fixture | 54 read shapes and four GET tombstones PASS; 88 manual exclusions. Synthetic fixtures, not live acceptance. |

The runner is strictly GET-only, including diagnostics. It makes no key rotation, account creation, number import/removal/rerouting, call or SMS. Both protected staging numbers are blocked in targeted requests. All authenticated read checks not exercised here remain pending manual test.

### Successful writes and calculation checks

| Row | Method | Path | Result |
| --- | --- | --- | --- |
| 1 | POST | `/v1/keys` | pending manual test |
| 2 | POST | `/v1/keys/rotate` | pending manual test |
| 12 | PUT | `/v1/integrations/calcom/number/:phoneNumber` | pending manual test |
| 14 | DELETE | `/v1/integrations/calcom/number/:phoneNumber` | pending manual test |
| 15 | PUT | `/v1/integrations/slack/number/:phoneNumber` | pending manual test |
| 17 | DELETE | `/v1/integrations/slack/number/:phoneNumber` | pending manual test |
| 18 | PUT | `/v1/integrations/zapier/number/:phoneNumber` | pending manual test |
| 20 | DELETE | `/v1/integrations/zapier/number/:phoneNumber` | pending manual test |
| 21 | PUT | `/v1/integrations/make/number/:phoneNumber` | pending manual test |
| 23 | DELETE | `/v1/integrations/make/number/:phoneNumber` | pending manual test |
| 24 | PUT | `/v1/integrations/gohighlevel/number/:phoneNumber` | pending manual test |
| 26 | DELETE | `/v1/integrations/gohighlevel/number/:phoneNumber` | pending manual test |
| 27 | PUT | `/v1/integrations/webhook/number/:phoneNumber` | pending manual test |
| 29 | DELETE | `/v1/integrations/webhook/number/:phoneNumber` | pending manual test |
| 30 | PUT | `/v1/integrations/webhook2/number/:phoneNumber` | pending manual test |
| 36 | PUT | `/v1/integrations/web-calls/number/:phoneNumber` | pending manual test |
| 38 | DELETE | `/v1/integrations/web-calls/number/:phoneNumber` | pending manual test |
| 39 | DELETE | `/v1/integrations/webhook2/number/:phoneNumber` | pending manual test |
| 40 | PUT | `/v1/integrations/precall/number/:phoneNumber` | pending manual test |
| 42 | DELETE | `/v1/integrations/precall/number/:phoneNumber` | pending manual test |
| 43 | PUT | `/v1/integrations/precall/agent/:agentId` | pending manual test |
| 45 | DELETE | `/v1/integrations/precall/agent/:agentId` | pending manual test |
| 46 | POST | `/v1/integrations/custom-functions/number/:phoneNumber` | pending manual test |
| 48 | DELETE | `/v1/integrations/custom-functions/number/:phoneNumber/:id` | pending manual test |
| 49 | PATCH | `/v1/integrations/custom-functions/number/:phoneNumber/:id` | pending manual test |
| 54 | PATCH | `/v1/agent-inbox/:channel/:number/thread/:thread` | pending manual test |
| 59 | PATCH | `/v1/agent-web/:number` | pending manual test |
| 61 | POST | `/v1/agents` | pending manual test |
| 62 | DELETE | `/v1/agents/:id` | pending manual test |
| 64 | PUT | `/v1/agents/:id` | pending manual test |
| 65 | DELETE | `/v1/agents/:target/knowledge-base` | pending manual test |
| 67 | PUT | `/v1/agents/:target/knowledge-base` | pending manual test |
| 69 | POST | `/v1/agents/:target/knowledge-base/source-measure` | pending manual test |
| 70 | POST | `/v1/agents/:target/knowledge-base/test-sessions` | pending manual test |
| 83 | DELETE | `/v1/calls` | pending manual test |
| 86 | DELETE | `/v1/calls/:id` | pending manual test |
| 90 | POST | `/v1/calls/batch` | pending manual test |
| 91 | POST | `/v1/calls/batch/:id/cancel` | pending manual test |
| 92 | POST | `/v1/calls/batch/:id/consent` | pending manual test |
| 93 | POST | `/v1/calls/batch/:id/launch` | pending manual test |
| 94 | POST | `/v1/calls/batch/:id/resume` | pending manual test |
| 96 | POST | `/v1/calls/outbound` | pending manual test |
| 98 | POST | `/v1/contact-hours/preview` | pending manual test |
| 99 | DELETE | `/v1/contact-suppressions` | pending manual test |
| 101 | POST | `/v1/contact-suppressions` | pending manual test |
| 104 | DELETE | `/v1/knowledge-bases/:kb/drafts/:id` | pending manual test |
| 106 | PATCH | `/v1/knowledge-bases/:kb/drafts/:id` | pending manual test |
| 107 | POST | `/v1/knowledge-bases/:kb/drafts/:id/accept` | pending manual test |
| 108 | POST | `/v1/knowledge-bases/:kb/exports` | pending manual test |
| 110 | PATCH | `/v1/knowledge-bases/:kb/settings` | pending manual test |
| 112 | POST | `/v1/knowledge-bases/:kb/sources` | pending manual test |
| 113 | DELETE | `/v1/knowledge-bases/:kb/sources/:id` | pending manual test |
| 114 | PATCH | `/v1/knowledge-bases/:kb/sources/:id` | pending manual test |
| 115 | POST | `/v1/knowledge-bases/:kb/sources/:id/replacements` | pending manual test |
| 116 | POST | `/v1/knowledge-bases/:kb/sources/refresh` | pending manual test |
| 117 | POST | `/v1/knowledge-bases/:kb/topic-search` | pending manual test |
| 119 | POST | `/v1/knowledge-bases/:kb/topics` | pending manual test |
| 120 | DELETE | `/v1/knowledge-bases/:kb/topics/:id` | pending manual test |
| 122 | PATCH | `/v1/knowledge-bases/:kb/topics/:id` | pending manual test |
| 124 | POST | `/v1/knowledge-bases/:kb/website-discoveries` | pending manual test |
| 125 | POST | `/v1/knowledge-bases/:kb/website-imports` | pending manual test |
| 130 | POST | `/v1/knowledge/jobs/:id/cancel` | pending manual test |
| 131 | POST | `/v1/knowledge/jobs/:id/retry` | pending manual test |
| 134 | POST | `/v1/knowledge/test-sessions/:id/cancel` | pending manual test |
| 135 | POST | `/v1/knowledge/test-sessions/:id/messages` | pending manual test |
| 146 | POST | `/v1/organisation/claim-invite` | pending manual test |
| 148 | POST | `/v1/organisation/invites` | pending manual test |
| 149 | DELETE | `/v1/organisation/invites/:id` | pending manual test |
| 150 | POST | `/v1/organisation/invites/:id/resend` | pending manual test |
| 153 | DELETE | `/v1/organisation/members/:id` | pending manual test |
| 154 | PATCH | `/v1/organisation/members/:id` | pending manual test |
| 155 | PATCH | `/v1/organisation/name` | pending manual test |
| 165 | POST | `/v1/phone-numbers` | pending manual test |
| 166 | DELETE | `/v1/phone-numbers/:phoneNumber` | pending manual test |
| 168 | PATCH | `/v1/phone-numbers/:phoneNumber` | pending manual test |
| 169 | DELETE | `/v1/phone-numbers/:phoneNumber/callers/:callerNumber` | pending manual test |
| 171 | PUT | `/v1/phone-numbers/:phoneNumber/callers/:callerNumber` | pending manual test |
| 172 | POST | `/v1/phone-numbers/:phoneNumber/callers/import` | pending manual test |
| 174 | POST | `/v1/sms` | pending manual test |
| 176 | POST | `/v1/sms/campaigns` | pending manual test |
| 177 | DELETE | `/v1/sms/campaigns/:id` | pending manual test |
| 179 | PATCH | `/v1/sms/campaigns/:id` | pending manual test |
| 180 | POST | `/v1/sms/campaigns/:id/cancel` | pending manual test |
| 181 | POST | `/v1/sms/campaigns/:id/consent` | pending manual test |
| 182 | POST | `/v1/sms/campaigns/:id/launch` | pending manual test |
| 183 | POST | `/v1/sms/campaigns/:id/resume` | pending manual test |
| 105 | GET | `/v1/knowledge-bases/:kb/drafts/:id` | pending manual test — can save legacy repairs |
| 158 | GET | `/v1/organisation/signing-secret` | pending manual test — private Owner workflow, excluded from automated retrieval |

Google Calendar remains a coming slot. No new Calendar route is claimed. Generated sitemap/live hosting settings remain pending post-publication. Four desktop visual spot checks passed; evidence is in SEO-CHECK.md and FINAL-REPORT.md.

## C10 additions — engine deb63749, 4 November 2026

147 supported public operations. No successful write below was executed. C8 remains GET-only and rejects protected numbers, signing-secret reads and repair-capable draft reads.

| Row | Status | Operation and remaining proof |
| --- | --- | --- |
| 193 | pending manual test | POST Google Calendar connect: approved disposable number and controlled browser consent/redirect flow. |
| 194 | pending manual test | GET Google Calendar status with a real authorised unprotected staging fixture; offline nullable fields and boolean shape are covered. |
| 195 | pending manual test | DELETE Google Calendar disconnect: controlled fixture, verify local access removed and other connections unaffected. |
| 196 | pending manual test | PATCH Google Calendar settings: each setting, send_invites true/false, omitted-field preservation and invalid types. |
| 197 | pending manual test | POST phone-number credentials: Twilio and Telnyx successful in-place updates, preservation, pending/unknown recovery. Never use either protected staging number. |
| SMS B51 | pending manual test | Controlled suppressed recipient returns 409 do_not_contact and no dispatch; successful unsuppressed send/delivery separately. |
| Booking B52 | pending manual test | Real consent, separate name/email approvals, create/move/cancel, signed booking payload, Google invite on/off and actual inbox delivery. |

Existing account creation, key rotation, number import/removal/routing and other successful-write checks remain individually pending manual test in the prior tables. Never rotate the staging key, create real accounts, or import/remove/re-route +447861926140 or +447457401554. No credentials were read, copied or printed.

## C13 additions — engine f6ff94d, 5 November 2026

The current public contract has **149 operations** and **162 API pages**. Earlier counts and the old Google Calendar coming-slot statement above are historical batch records; Google Calendar now has the four documented C10 operations. C13 makes no live API request. Pinned-engine functions, fake dependencies and schema-shaped examples provide offline proof only.

| Row / case | Status | Remaining controlled check |
| --- | --- | --- |
| 198 | pending manual test | GET `/v1/calls/{id}/bookings` using approved retained fixtures for ready, none, processing, deleted and unavailable; confirm no-store and account ownership. |
| 199 | pending manual test | GET `/v1/calls/outbound/requests/{request_id}` using approved fixtures for pending, accepted, rejected and unknown; verify invalid/missing/foreign UUIDs share 404. |
| 96 / first UUID acceptance | pending manual test | One approved outbound intent with a durably saved UUID returns 201 and the known call ID. |
| 96 / accepted replay | pending manual test | Reuse the identical accepted UUID and payload; verify 200 replayed:true, the same call ID and no second dispatch. |
| 96 / changed payload | pending manual test | Reuse the UUID with changed input; verify 409 request_id_conflict and no second dispatch. |
| 96 / pending or unknown | pending manual test | Controlled journal fixtures return 409 outbound_request_pending or outbound_request_unknown without redispatch. |
| 96 / lost acknowledgement | pending manual test | Controlled failure injection preserves 201 call_id with request_status:unconfirmed and safe_to_retry:false, or a documented 503 unknown response. Do not inject failures into shared live staging. |
| 96 / existing client launch | pending manual test | Confirm installed client-version behaviour separately; reviewed legacy Node/Python/CLI examples omit request_id. |
| B56 / signed result reconciliation | pending manual test | Compare a genuinely signed call.bookings event with the retained GET result for an approved call. Verify create/move/cancel and duplicate processing without repeating business actions. |

All earlier successful-write checks remain pending manual test. C13 does not rotate a key, create an account, contact a recipient, modify a number, reconnect a calendar or retrieve a signing secret. The historical C8 runner is unchanged and does not cover rows 198/199; use the C13 supplemental offline proof and this explicit live-test list rather than presenting C8 as complete B56 coverage.
