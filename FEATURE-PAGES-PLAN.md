# Feature pages plan — completed C14 Developer coverage

Apply the feature-size rule in DOCS-STYLE-GUIDE.md. Every route listed as delivered below is a complete page in the five-tab navigation. Chat C owns API, Developer and client pages; Chat D owns Business and AI pages. The accepted D6 commit is `14f94cab31154ddd0cfe9bb435747241095f1bd7`, merged unchanged. Its five written additions and exact navigation proposal are included.

## Delivered feature clusters

| Feature | Accepted Business coverage | Completed Developer coverage | API and result boundary |
| --- | --- | --- | --- |
| Getting started | `/business` | `/guides`, `/quickstart`, `/authentication` plus errors, paging, limits and idempotency | Start with one safe read; preserve uncertain writes. |
| Knowledge | `/guides/business/knowledge` plus D6 `knowledge/add-facts`, `knowledge/keyterms`, `knowledge/test-and-fix` | `/guides/developer/knowledge` plus `knowledge/ingest-sources`, `knowledge/review-and-publish`, `knowledge/test-and-troubleshoot`, `knowledge/refresh-and-export`, `knowledge/keyterms` | Preparation, review, publication, testing and export remain separate jobs and decisions. |
| Bookings | Existing calendar, receptionist and SMS booking pages; D6 `/guides/business/booking-results` | `/actions/booking-confirmation`, `/actions/google-calendar`, `/actions/calcom`, `/guides/developer/bookings/google-calendar-settings`, `/guides/developer/bookings/troubleshooting`, call-result and webhook guides | Separate contact approvals, provider result, notification request and post-call evidence. |
| Webhooks | `/guides/business/integrations` | `/guides/developer/webhooks/event-types`, `/advanced/webhooks`, `/guides/developer/webhooks/delivery-and-recovery` | Raw-body verification, atomic deduplication, durable acceptance and read-based recovery. |
| Team | Existing seven-page Business cluster, with the D6 overview | `/guides/developer/organisations`, `/guides/developer/team/invitations-and-roles`, `/guides/developer/team/ownership-and-closure` | Personal ownership/closure stays in its authenticated flow; no invented public endpoint. |
| Voice campaigns | Existing campaign/contact-control pages plus D6 `/guides/business/call-one-number` | `/guides/developer/campaigns`, `campaigns/prepare-and-launch`, `campaigns/results-and-controls`, contact controls | Creation can launch; cancellation stops future dispatch. Deletion release remains pending B57. |
| SMS campaigns | Existing SMS campaign, SMS agent and inbox pages | `/sms/sms-campaigns`, `/guides/developer/sms-campaigns/prepare-and-send`, `sms-campaigns/delivery-and-controls` | Acceptance, delivery and replies stay distinct; no automatic replacement campaign. |
| Phone numbers | `/guides/business/phone-numbers` | `/guides/developer/phone-numbers`, `phone-numbers/import-and-connect`, `phone-numbers/credentials-and-removal`, `phone-numbers/routing-and-overrides`, `/integrations/number-connection` | Initial setup, credential replacement, moves and removal have distinct effects. |
| Single outbound call | D6 `/guides/business/call-one-number` | `/guides/developer/call-requests`, outbound concepts, lead qualification and client examples | Persist the UUID before dispatch; reads never authorise automatic redial. |
| Call and booking review | Call history, live help and D6 booking results | Call history, recording, analysis, live-access and retention pages | Ready, none, processing, deleted and unavailable remain distinct. |
| SMS and inbox | Existing SMS-agent and inbox pages | `/sms/send-sms`, `/sms/sms-agent`, `/sms/post-call-sms`, `/guides/developer/agent-inbox` | Channel-scoped threads; archive is not deletion; sent is not delivered. |
| Website agent | `/guides/voice-widget`, Business inbox | `/web-assistant/overview`, `/guides/developer/website/install-and-verify`, `website/troubleshooting`, website concepts | Generated snippet, revisions, unverified visitors and public-function permissions. |
| Actions and integrations | Existing Business action/integration and provider tasks | All action, integration, pre-call and custom-function pages follow the common structure | Configuration is not completion; exact callback and action contracts stay linked. |
| Billing and privacy | Existing billing, pricing, privacy and own-storage pages | Billing, recording, retention and own-storage guides rewritten | Preserve current charges, storage scope and pending cleanup evidence. |
| Client tools | AI client setup remains D-owned | All eight SDK/CLI/MCP pages rewritten, including new `/sdks/mcp` | Exact unpublished candidate identity; 96-tool candidate distinguished from earlier 94-tool builds. |

The publication set is **306 pages**: 44 Business, 87 Developer, 162 API, eight SDK/CLI/MCP and five AI pages. The API still has **149 HTTP operations**. C14 adds 22 complete pages after the five D6 additions; a page count is not a substitute for rendered validation.

## D6 Business plan folded into this site plan

D6's remaining Business proposals belong to Chat D and are not unfinished C-owned Developer pages. Their corresponding Developer tasks are complete above. None of the proposed Business routes below is published or linked as an existing page. Keep the nearest accepted Business counterpart until its owner supplies a complete reviewed page.

| Business feature | D6 proposal retained for its owner | Current Developer counterpart |
| --- | --- | --- |
| Google Calendar | Consider change-settings and fix-bookings tasks after source review. | Calendar hours/invitations and shared booking troubleshooting. |
| Cal.com | Polish setup and consider fix-bookings; share booking results. | Cal.com setup and shared booking troubleshooting. |
| Voice campaigns | Consider recipient review and result checking under the current feature. | Voice prepare/launch and results/controls. |
| SMS campaigns | Polish current tasks first; consider recipient review and delivery checks. | SMS prepare/send and delivery/controls. |
| Phone numbers | Consider carrier-details and routing recovery; preserve anchors. | Import/connect, credentials/removal and routing/overrides. |
| Call review | Keep live help, history and booking results distinct; split recordings only if justified. | Call history, live access and recording. |
| Team | Apply the design to existing tasks; add no duplicate pages. | Invitations/roles and ownership/closure. |
| Billing | Consider add-credit, charge review and payment recovery after source verification. | Billing and error/limit guides. |
| Privacy and storage | Consider retention and call-data deletion tasks; keep own storage. | Retention, recording, own storage and marked deletion references. |
| Website | Polish setup/inbox; consider conversation review after source review. | Installation, troubleshooting and channel-scoped inbox. |
| Integrations/actions | Keep the index and tasks; split shared result recovery only when substantial. | Action/integration pages and webhook delivery recovery. |

All proposed Business splits require the feature-size rule and their owner's source review. They do not authorise empty routes or C edits to D-owned text. Reciprocal links in accepted D6 pages remain unchanged; new Developer pages link to the nearest real Business task. The original full D6 proposal is retained in its accepted handoff; this table records every proposed feature and its site counterpart.

## Pending release contract

The B57 call/campaign DELETE change has not been supplied as a final reviewed contract. `spec-source/c14-pages.json` lists every page carrying the generated **DOCS-PENDING** warning. Preserve the B56 API schema until Claude supplies that result before publication. Do not guess new response fields, codes, routes or settlement behaviour.

## Source and review record

`spec-source/c14-pages.json` maps all 95 Developer/client pages to immutable authored source and records the pinned client candidates. `spec-source/c13-pages.json` continues to map all 162 API pages. `spec-source/c10-site.json` is regenerated from the complete navigation and retains the exact D6 ownership baseline. The source and generated gates must verify page-set equality, preserved routes, metadata, examples, audience links and all expanded groups.
