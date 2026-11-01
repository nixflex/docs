# Pages still to build or replace — after C4

C4 completes 19 core endpoint pages at engine `f19628449139fe7696d2d51c80d1d92fa46d209b`. The API menu now contains 55 pages, including the six basics pages. Three replaced aggregate URLs redirect to the completed operation pages. There are **111 public operations still to build or correct**. Knowledge is outside C4.

| Group | Operations still to build/correct | Without a current page |
| --- | --- | --- |
| Integration settings | 34 | 0 |
| Agent inbox | 6 | 6 |
| Web agent | 2 | 2 |
| Knowledge | 39 | 39 |
| Voice campaigns | 6 | 4 |
| Contact controls | 4 | 4 |
| Organisation | 11 | 0 |
| SMS campaigns | 9 | 4 |

Contact controls, Web agent, Agent inbox and Knowledge remain absent from the menu until real pages are built. Preserve existing operation numbers and redirect old aggregate URLs as they are replaced. All successful-write checks deferred by C4 are listed as **pending manual test** in COVERAGE.md; they are test work, not missing pages.

| # | Operation | Current page retained | Planned page | Required work |
| --- | --- | --- | --- | --- |
| 12 | `PUT /v1/integrations/calcom/number/:phoneNumber` | `api-reference/integrations/calcom` | `api-reference/integration-settings/put-integrations-calcom-number-phoneNumber` | Document the current request, response, limits and errors. |
| 13 | `GET /v1/integrations/calcom/number/:phoneNumber` | `api-reference/integrations/calcom` | `api-reference/integration-settings/get-integrations-calcom-number-phoneNumber` | Document the current request, response, limits and errors. |
| 14 | `DELETE /v1/integrations/calcom/number/:phoneNumber` | `api-reference/integrations/calcom` | `api-reference/integration-settings/delete-integrations-calcom-number-phoneNumber` | Document the current request, response, limits and errors. |
| 15 | `PUT /v1/integrations/slack/number/:phoneNumber` | `api-reference/integrations/slack` | `api-reference/integration-settings/put-integrations-slack-number-phoneNumber` | Document the current request, response, limits and errors. |
| 16 | `GET /v1/integrations/slack/number/:phoneNumber` | `api-reference/integrations/slack` | `api-reference/integration-settings/get-integrations-slack-number-phoneNumber` | Document the current request, response, limits and errors. |
| 17 | `DELETE /v1/integrations/slack/number/:phoneNumber` | `api-reference/integrations/slack` | `api-reference/integration-settings/delete-integrations-slack-number-phoneNumber` | Document the current request, response, limits and errors. |
| 18 | `PUT /v1/integrations/zapier/number/:phoneNumber` | `api-reference/integrations/zapier` | `api-reference/integration-settings/put-integrations-zapier-number-phoneNumber` | Document the current request, response, limits and errors. |
| 19 | `GET /v1/integrations/zapier/number/:phoneNumber` | `api-reference/integrations/zapier` | `api-reference/integration-settings/get-integrations-zapier-number-phoneNumber` | Document the current request, response, limits and errors. |
| 20 | `DELETE /v1/integrations/zapier/number/:phoneNumber` | `api-reference/integrations/zapier` | `api-reference/integration-settings/delete-integrations-zapier-number-phoneNumber` | Document the current request, response, limits and errors. |
| 21 | `PUT /v1/integrations/make/number/:phoneNumber` | `api-reference/integrations/make` | `api-reference/integration-settings/put-integrations-make-number-phoneNumber` | Document the current request, response, limits and errors. |
| 22 | `GET /v1/integrations/make/number/:phoneNumber` | `api-reference/integrations/make` | `api-reference/integration-settings/get-integrations-make-number-phoneNumber` | Document the current request, response, limits and errors. |
| 23 | `DELETE /v1/integrations/make/number/:phoneNumber` | `api-reference/integrations/make` | `api-reference/integration-settings/delete-integrations-make-number-phoneNumber` | Document the current request, response, limits and errors. |
| 24 | `PUT /v1/integrations/gohighlevel/number/:phoneNumber` | `api-reference/integrations/gohighlevel` | `api-reference/integration-settings/put-integrations-gohighlevel-number-phoneNumber` | Document the current request, response, limits and errors. |
| 25 | `GET /v1/integrations/gohighlevel/number/:phoneNumber` | `api-reference/integrations/gohighlevel` | `api-reference/integration-settings/get-integrations-gohighlevel-number-phoneNumber` | Document the current request, response, limits and errors. |
| 26 | `DELETE /v1/integrations/gohighlevel/number/:phoneNumber` | `api-reference/integrations/gohighlevel` | `api-reference/integration-settings/delete-integrations-gohighlevel-number-phoneNumber` | Document the current request, response, limits and errors. |
| 27 | `PUT /v1/integrations/webhook/number/:phoneNumber` | `api-reference/integrations/webhook` | `api-reference/integration-settings/put-integrations-webhook-number-phoneNumber` | Document the current request, response, limits and errors. |
| 28 | `GET /v1/integrations/webhook/number/:phoneNumber` | `api-reference/integrations/webhook` | `api-reference/integration-settings/get-integrations-webhook-number-phoneNumber` | Document the current request, response, limits and errors. |
| 29 | `DELETE /v1/integrations/webhook/number/:phoneNumber` | `api-reference/integrations/webhook` | `api-reference/integration-settings/delete-integrations-webhook-number-phoneNumber` | Document the current request, response, limits and errors. |
| 30 | `PUT /v1/integrations/webhook2/number/:phoneNumber` | `api-reference/integrations/webhook` | `api-reference/integration-settings/put-integrations-webhook2-number-phoneNumber` | Document the current request, response, limits and errors. |
| 31 | `GET /v1/integrations/webhook2/number/:phoneNumber` | `api-reference/integrations/webhook` | `api-reference/integration-settings/get-integrations-webhook2-number-phoneNumber` | Document the current request, response, limits and errors. |
| 36 | `PUT /v1/integrations/web-calls/number/:phoneNumber` | `api-reference/phone-numbers/web-calls` | `api-reference/integration-settings/put-integrations-web-calls-number-phoneNumber` | Document the current request, response, limits and errors. |
| 37 | `GET /v1/integrations/web-calls/number/:phoneNumber` | `api-reference/phone-numbers/web-calls` | `api-reference/integration-settings/get-integrations-web-calls-number-phoneNumber` | Document the current request, response, limits and errors. |
| 38 | `DELETE /v1/integrations/web-calls/number/:phoneNumber` | `api-reference/phone-numbers/web-calls` | `api-reference/integration-settings/delete-integrations-web-calls-number-phoneNumber` | Document the current request, response, limits and errors. |
| 39 | `DELETE /v1/integrations/webhook2/number/:phoneNumber` | `api-reference/integrations/webhook` | `api-reference/integration-settings/delete-integrations-webhook2-number-phoneNumber` | Document the current request, response, limits and errors. |
| 40 | `PUT /v1/integrations/precall/number/:phoneNumber` | `api-reference/integrations/precall` | `api-reference/integration-settings/put-integrations-precall-number-phoneNumber` | Document the current request, response, limits and errors. |
| 41 | `GET /v1/integrations/precall/number/:phoneNumber` | `api-reference/integrations/precall` | `api-reference/integration-settings/get-integrations-precall-number-phoneNumber` | Document the current request, response, limits and errors. |
| 42 | `DELETE /v1/integrations/precall/number/:phoneNumber` | `api-reference/integrations/precall` | `api-reference/integration-settings/delete-integrations-precall-number-phoneNumber` | Document the current request, response, limits and errors. |
| 43 | `PUT /v1/integrations/precall/agent/:agentId` | `api-reference/integrations/precall` | `api-reference/integration-settings/put-integrations-precall-agent-agentId` | Document the current request, response, limits and errors. |
| 44 | `GET /v1/integrations/precall/agent/:agentId` | `api-reference/integrations/precall` | `api-reference/integration-settings/get-integrations-precall-agent-agentId` | Document the current request, response, limits and errors. |
| 45 | `DELETE /v1/integrations/precall/agent/:agentId` | `api-reference/integrations/precall` | `api-reference/integration-settings/delete-integrations-precall-agent-agentId` | Document the current request, response, limits and errors. |
| 46 | `POST /v1/integrations/custom-functions/number/:phoneNumber` | `api-reference/integrations/custom-functions` | `api-reference/integration-settings/post-integrations-custom-functions-number-phoneNumber` | Document the current request, response, limits and errors. |
| 47 | `GET /v1/integrations/custom-functions/number/:phoneNumber` | `api-reference/integrations/custom-functions` | `api-reference/integration-settings/get-integrations-custom-functions-number-phoneNumber` | Document the current request, response, limits and errors. |
| 48 | `DELETE /v1/integrations/custom-functions/number/:phoneNumber/:id` | `api-reference/integrations/custom-functions` | `api-reference/integration-settings/delete-integrations-custom-functions-number-phoneNumber-id` | Document the current request, response, limits and errors. |
| 49 | `PATCH /v1/integrations/custom-functions/number/:phoneNumber/:id` | `api-reference/integrations/custom-functions` | `api-reference/integration-settings/patch-integrations-custom-functions-number-phoneNumber-id` | Document the current request, response, limits and errors. |
| 52 | `GET /v1/agent-inbox/:channel/:number` | — | `api-reference/agent-inbox/get-agent-inbox-channel-number` | Document the current request, response, limits and errors. |
| 53 | `GET /v1/agent-inbox/:channel/:number/thread/:thread` | — | `api-reference/agent-inbox/get-agent-inbox-channel-number-thread-thread` | Document the current request, response, limits and errors. |
| 54 | `PATCH /v1/agent-inbox/:channel/:number/thread/:thread` | — | `api-reference/agent-inbox/patch-agent-inbox-channel-number-thread-thread` | Document the current request, response, limits and errors. |
| 55 | `GET /v1/agent-inbox/features` | — | `api-reference/agent-inbox/get-agent-inbox-features` | Document the current request, response, limits and errors. |
| 56 | `GET /v1/agent-inbox/numbers` | — | `api-reference/agent-inbox/get-agent-inbox-numbers` | Document the current request, response, limits and errors. |
| 57 | `GET /v1/agent-inbox/retention` | — | `api-reference/agent-inbox/get-agent-inbox-retention` | Document the current request, response, limits and errors. |
| 58 | `GET /v1/agent-web/:number` | — | `api-reference/web-agent/get-agent-web-number` | Document the current request, response, limits and errors. |
| 59 | `PATCH /v1/agent-web/:number` | — | `api-reference/web-agent/patch-agent-web-number` | Document the current request, response, limits and errors. |
| 65 | `DELETE /v1/agents/:target/knowledge-base` | — | `api-reference/knowledge/delete-agents-target-knowledge-base` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 66 | `GET /v1/agents/:target/knowledge-base` | — | `api-reference/knowledge/get-agents-target-knowledge-base` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 67 | `PUT /v1/agents/:target/knowledge-base` | — | `api-reference/knowledge/put-agents-target-knowledge-base` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 69 | `POST /v1/agents/:target/knowledge-base/source-measure` | — | `api-reference/knowledge/post-agents-target-knowledge-base-source-measure` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 70 | `POST /v1/agents/:target/knowledge-base/test-sessions` | — | `api-reference/knowledge/post-agents-target-knowledge-base-test-sessions` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 90 | `POST /v1/calls/batch` | `api-reference/calls/batch-create` | `api-reference/calls/batch-create` | Recipient-local time windows, consent and duplicate decisions need documentation. No immediate-delivery guarantee. Both supported number carriers work; inherited business timezone is not universal recipient timezone. |
| 91 | `POST /v1/calls/batch/:id/cancel` | — | `api-reference/voice-campaigns/post-calls-batch-id-cancel` | Document the current request, response, limits and errors. |
| 92 | `POST /v1/calls/batch/:id/consent` | — | `api-reference/voice-campaigns/post-calls-batch-id-consent` | Document the current request, response, limits and errors. |
| 93 | `POST /v1/calls/batch/:id/launch` | `api-reference/calls/batch-launch` | `api-reference/calls/batch-launch` | Use actual launcher response (enqueued/failed_to_enqueue), describe recipient gates, paused 503 and unknown 500. Launch is not delivery and does not bypass hours. |
| 94 | `POST /v1/calls/batch/:id/resume` | — | `api-reference/voice-campaigns/post-calls-batch-id-resume` | Document the current request, response, limits and errors. |
| 97 | `GET /v1/campaigns` | — | `api-reference/voice-campaigns/get-campaigns` | Document the current request, response, limits and errors. |
| 98 | `POST /v1/contact-hours/preview` | — | `api-reference/contact-controls/post-contact-hours-preview` | Document the current request, response, limits and errors. |
| 99 | `DELETE /v1/contact-suppressions` | — | `api-reference/contact-controls/delete-contact-suppressions` | Document the current request, response, limits and errors. |
| 100 | `GET /v1/contact-suppressions` | — | `api-reference/contact-controls/get-contact-suppressions` | Document the current request, response, limits and errors. |
| 101 | `POST /v1/contact-suppressions` | — | `api-reference/contact-controls/post-contact-suppressions` | Document the current request, response, limits and errors. |
| 103 | `GET /v1/knowledge-bases/:kb` | — | `api-reference/knowledge/get-knowledge-bases-kb` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 104 | `DELETE /v1/knowledge-bases/:kb/drafts/:id` | — | `api-reference/knowledge/delete-knowledge-bases-kb-drafts-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 105 | `GET /v1/knowledge-bases/:kb/drafts/:id` | — | `api-reference/knowledge/get-knowledge-bases-kb-drafts-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 106 | `PATCH /v1/knowledge-bases/:kb/drafts/:id` | — | `api-reference/knowledge/patch-knowledge-bases-kb-drafts-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 107 | `POST /v1/knowledge-bases/:kb/drafts/:id/accept` | — | `api-reference/knowledge/post-knowledge-bases-kb-drafts-id-accept` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 108 | `POST /v1/knowledge-bases/:kb/exports` | — | `api-reference/knowledge/post-knowledge-bases-kb-exports` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 109 | `GET /v1/knowledge-bases/:kb/overview` | — | `api-reference/knowledge/get-knowledge-bases-kb-overview` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 110 | `PATCH /v1/knowledge-bases/:kb/settings` | — | `api-reference/knowledge/patch-knowledge-bases-kb-settings` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 111 | `GET /v1/knowledge-bases/:kb/sources` | — | `api-reference/knowledge/get-knowledge-bases-kb-sources` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 112 | `POST /v1/knowledge-bases/:kb/sources` | — | `api-reference/knowledge/post-knowledge-bases-kb-sources` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 113 | `DELETE /v1/knowledge-bases/:kb/sources/:id` | — | `api-reference/knowledge/delete-knowledge-bases-kb-sources-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 114 | `PATCH /v1/knowledge-bases/:kb/sources/:id` | — | `api-reference/knowledge/patch-knowledge-bases-kb-sources-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 115 | `POST /v1/knowledge-bases/:kb/sources/:id/replacements` | — | `api-reference/knowledge/post-knowledge-bases-kb-sources-id-replacements` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 116 | `POST /v1/knowledge-bases/:kb/sources/refresh` | — | `api-reference/knowledge/post-knowledge-bases-kb-sources-refresh` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 117 | `POST /v1/knowledge-bases/:kb/topic-search` | — | `api-reference/knowledge/post-knowledge-bases-kb-topic-search` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 118 | `GET /v1/knowledge-bases/:kb/topics` | — | `api-reference/knowledge/get-knowledge-bases-kb-topics` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 119 | `POST /v1/knowledge-bases/:kb/topics` | — | `api-reference/knowledge/post-knowledge-bases-kb-topics` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 120 | `DELETE /v1/knowledge-bases/:kb/topics/:id` | — | `api-reference/knowledge/delete-knowledge-bases-kb-topics-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 121 | `GET /v1/knowledge-bases/:kb/topics/:id` | — | `api-reference/knowledge/get-knowledge-bases-kb-topics-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 122 | `PATCH /v1/knowledge-bases/:kb/topics/:id` | — | `api-reference/knowledge/patch-knowledge-bases-kb-topics-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 123 | `GET /v1/knowledge-bases/:kb/unanswered` | — | `api-reference/knowledge/get-knowledge-bases-kb-unanswered` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 124 | `POST /v1/knowledge-bases/:kb/website-discoveries` | — | `api-reference/knowledge/post-knowledge-bases-kb-website-discoveries` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 125 | `POST /v1/knowledge-bases/:kb/website-imports` | — | `api-reference/knowledge/post-knowledge-bases-kb-website-imports` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 126 | `GET /v1/knowledge/capabilities` | — | `api-reference/knowledge/get-knowledge-capabilities` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 127 | `GET /v1/knowledge/events` | — | `api-reference/knowledge/get-knowledge-events` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 128 | `GET /v1/knowledge/exports/:id` | — | `api-reference/knowledge/get-knowledge-exports-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 129 | `GET /v1/knowledge/jobs/:id` | — | `api-reference/knowledge/get-knowledge-jobs-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 130 | `POST /v1/knowledge/jobs/:id/cancel` | — | `api-reference/knowledge/post-knowledge-jobs-id-cancel` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 131 | `POST /v1/knowledge/jobs/:id/retry` | — | `api-reference/knowledge/post-knowledge-jobs-id-retry` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 132 | `GET /v1/knowledge/targets` | — | `api-reference/knowledge/get-knowledge-targets` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 133 | `GET /v1/knowledge/test-sessions/:id` | — | `api-reference/knowledge/get-knowledge-test-sessions-id` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 134 | `POST /v1/knowledge/test-sessions/:id/cancel` | — | `api-reference/knowledge/post-knowledge-test-sessions-id-cancel` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 135 | `POST /v1/knowledge/test-sessions/:id/messages` | — | `api-reference/knowledge/post-knowledge-test-sessions-id-messages` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 136 | `GET /v1/knowledge/usage` | — | `api-reference/knowledge/get-knowledge-usage` | Agent-only knowledge contract; document revisions, jobs, errors and B49 behavior. Recheck B49b. |
| 143 | `GET /v1/organisation` | `api-reference/organisations/overview` | `api-reference/organisation/get-organisation` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 145 | `GET /v1/organisation/activity` | `api-reference/organisations/overview` | `api-reference/organisation/get-organisation-activity` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 146 | `POST /v1/organisation/claim-invite` | `api-reference/organisations/overview` | `api-reference/organisation/post-organisation-claim-invite` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 148 | `POST /v1/organisation/invites` | `api-reference/organisations/overview` | `api-reference/organisation/post-organisation-invites` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 149 | `DELETE /v1/organisation/invites/:id` | `api-reference/organisations/overview` | `api-reference/organisation/delete-organisation-invites-id` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 150 | `POST /v1/organisation/invites/:id/resend` | `api-reference/organisations/overview` | `api-reference/organisation/post-organisation-invites-id-resend` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 152 | `GET /v1/organisation/members` | `api-reference/organisations/overview` | `api-reference/organisation/get-organisation-members` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 153 | `DELETE /v1/organisation/members/:id` | `api-reference/organisations/overview` | `api-reference/organisation/delete-organisation-members-id` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 154 | `PATCH /v1/organisation/members/:id` | `api-reference/organisations/overview` | `api-reference/organisation/patch-organisation-members-id` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 155 | `PATCH /v1/organisation/name` | `api-reference/organisations/overview` | `api-reference/organisation/patch-organisation-name` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 158 | `GET /v1/organisation/signing-secret` | `api-reference/organisations/overview` | `api-reference/organisation/get-organisation-signing-secret` | Document API-key authority, roles, safe outcomes and Activity; recheck 225. |
| 175 | `GET /v1/sms/campaigns` | `api-reference/sms/campaigns-list` | `api-reference/sms/campaigns-list` | List default/cap 1000 and next_cursor; actual scheduled_date, full totals, sent distinct, expanded states. |
| 176 | `POST /v1/sms/campaigns` | `api-reference/sms/campaigns-create` | `api-reference/sms/campaigns-create` | scheduled_date, not scheduled_at; consent/location/duplicates/hours fields absent; missing details may refuse rather than render blank; no delivery-now guarantee. |
| 177 | `DELETE /v1/sms/campaigns/:id` | `api-reference/sms/campaigns-delete` | `api-reference/sms/campaigns-delete` | Does not cancel running sends. Running/paused/launching 400; completed may delete;200 is message:Campaign deleted (including missing), not deleted/cancelled_count. Existing OLD-doc bug. |
| 178 | `GET /v1/sms/campaigns/:id` | `api-reference/sms/campaigns-get` | `api-reference/sms/campaigns-get` | Actual envelope campaign/recipients/messages/pagination; recipient phone_number; sent is separate from failed; paging and full totals need correction. |
| 179 | `PATCH /v1/sms/campaigns/:id` | — | `api-reference/sms-campaigns/patch-sms-campaigns-id` | Document the current request, response, limits and errors. |
| 180 | `POST /v1/sms/campaigns/:id/cancel` | — | `api-reference/sms-campaigns/post-sms-campaigns-id-cancel` | Document the current request, response, limits and errors. |
| 181 | `POST /v1/sms/campaigns/:id/consent` | — | `api-reference/sms-campaigns/post-sms-campaigns-id-consent` | Document the current request, response, limits and errors. |
| 182 | `POST /v1/sms/campaigns/:id/launch` | `api-reference/sms/campaigns-launch` | `api-reference/sms/campaigns-launch` | Launch respects recipient gates; document actual errors 400/503/500 and unknown outcome, not unconditional immediate send. |
| 183 | `POST /v1/sms/campaigns/:id/resume` | — | `api-reference/sms-campaigns/post-sms-campaigns-id-resume` | Document the current request, response, limits and errors. |
