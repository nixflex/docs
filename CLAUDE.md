# Nixflex rules for AI

Reviewed 2026-11-22 against production engine `0fd3f79bbc9acac787e5e3b31182e7987f3353e1`. Refresh project copies from https://docs.nixflex.com/ai-rules.md. Append the rules to your project instructions or attach the file to a chat that cannot read your workspace.

A developer can run many customers on one shared agent. Give each customer its own number and number prompt. Separate agents are needed only when knowledge or agent settings must differ.

Agents are unlimited. There is no fee per agent. Customers pay only for usage (minutes and texts).

Always pass the customer’s verified from_number on a shared agent. If omitted the engine selects the oldest eligible number for the owning account and agent, ordered by created_at then id.

An inbound STOP suppresses that recipient across the owning account, for both voice and SMS. The business number that received it is evidence only.

There is no per-number concurrent-call reservation. Queue or pace each tenant in your application. Use separate accounts if the budgets must be independent.

## Find a feature

[Accounts, API keys and environments](#account-access) · [Organisations and team roles](#organisations) · [Agent settings, languages and voices](#agents-voices) · [Phone numbers and bringing your own number](#phone-numbers) · [Inbound phone calls and greetings](#inbound-calls) · [Single outbound calls and request receipts](#outbound-calls) · [Action tags and outbound variables](#outbound-actions-variables) · [Transfer, voicemail and phone menus](#transfer-voicemail-keypad) · [Voice and SMS campaigns](#campaigns) · [Contact hours, consent and opt-outs](#contact-controls) · [SMS, automatic replies and in-call texting](#sms) · [Website chat, voice and installation](#website-agent) · [Inbox, history and tenant-scoped reads](#inbox-history) · [Knowledge bases](#knowledge) · [Caller records and memory](#caller-context) · [Bookings and calendars](#bookings-calendars) · [Automation, CRM and notifications](#integrations) · [Custom functions and visitor access](#custom-functions) · [Webhook verification and tenant routing](#webhooks) · [Recordings, retention and deletion](#recordings-retention) · [Agent pricing and usage](#billing-usage) · [Limits, errors and safe retries](#limits-errors) · [Testing and live status](#testing-live-status)

<a id="account-access"></a>

## Accounts, API keys and environments

**FIXED** Use https://api.nixflex.com/v1 for customer integrations. Keep the API credential on your server.

**NOT OFFERED → do this instead** There is no self-service public sandbox. Use local fixtures or an owned test number for deliberate real traffic. Another environment requires access from Nixflex.

**YOU CAN CHANGE** Rotate the secret during a coordinated cutover. Update callers holding the old secret immediately.

**SCOPE · account** Use your server to identify the customer and authorise each operation before calling Nixflex. A shared account credential can see multiple customers.

The default allowance is 300 requests per minute. Observe the effective limit returned by the API.

<a id="organisations"></a>

## Organisations and team roles

**FIXED** Owner manages keys, transfer and closure. Admin can manage ordinary resources, billing and Activity. Member can read ordinary resources.

**NOT OFFERED → do this instead** An Admin cannot manage another Admin or take ownership by editing a role. Use the Owner’s personal session and the ownership transfer workflow.

**YOU CAN CHANGE** Choose the permitted role when inviting a colleague. The recipient claims the invitation.

**SCOPE · organisation** Use invitations to grant access to the same business resources. Review team activity under the relevant organisation.

<a id="agents-voices"></a>

## Agent settings, languages and voices

**FIXED** Language, general call timezone, pickup delay and fixed welcome_message belong to the agent. Numbers share those settings.

**NOT OFFERED → do this instead** A number cannot set a separate fixed welcome_message, language, general timezone or pickup delay. Use another agent for distinct settings. For a different business opening on the same agent use Dynamic greeting and the number prompt.

**YOU CAN CHANGE** Choose the supported catalogue voice and an eligible route. Select manual speech terms or configure structured values to extract from transcripts.

**SCOPE · number** A configured primary/backup number voice pair wins as a whole. Inherit to use the agent pair. On legacy paths a number voice_id can clear an agent catalogue key. An incompatible partial pair can be unavailable.

A changed manual list accepts up to 20 keyterms. Existing over-limit text can remain untouched on an unrelated edit.

<a id="phone-numbers"></a>

## Phone numbers and bringing your own number

**FIXED** A number belongs to the account and is assigned to an agent. An explicit outbound number must be eligible for that account and agent. On a shared agent always pass the intended customer’s from_number.

**NOT OFFERED → do this instead** A number cannot set its own fixed welcome_message, language, general call timezone or pickup delay. Use Dynamic greeting with that number’s custom_prompt for its business opening. Select a separate agent for different agent settings.

**YOU CAN CHANGE** Import server-side with `POST /v1/phone-numbers`. Supply phone_number and agent_id. Pair twilio_sid with twilio_token or telnyx_api_key with telnyx_connection_id. telnyx_public_key is optional for the latter. custom_prompt is optional. `phone_number`, `agent_id`, `twilio_sid`, `twilio_token`, `telnyx_api_key`, `telnyx_connection_id`, `telnyx_public_key`, `custom_prompt`. These ordinary number settings are writable by PATCH. Text fields have individual clearing rules. Nullable recording and booking controls can inherit agent settings. Voicemail for an API-imported number uses the number’s controls. `custom_prompt`, `voice_id`, `sms_reply_enabled`, `sms_prompt`, `web_prompt`, `speaking_rate`, `dtmf_enabled`, `require_booking_confirmation`, `record_call`, `recording_source`, `voicemail_leave_enabled`, `voicemail_message`. Select a complete catalogue voice pair on the number or request inheritance with voice_pair_inherit. A configured number pair overrides the whole agent pair. Legacy number aliases and partially migrated pairs follow separate compatibility rules. `voice_key`, `voice_route_key`, `backup_voice_key`, `backup_voice_route_key`.

**SCOPE · number** Import an existing supported carrier number, assign it to an owned agent, inspect it, change its channel controls and remove its Nixflex connection.

Write limits in characters for the inbound business profile, SMS prompt, website prompt and number voicemail message. `custom_prompt` 8,000 · `sms_prompt` 20,000 · `web_prompt` 16,000 · `voicemail_message` 2,000.

400 custom_prompt_too_long means the number profile exceeded its character limit. Shorten it to the custom_prompt limit shown above.

<a id="inbound-calls"></a>

## Inbound phone calls and greetings

**FIXED** Shared call mechanics and action permissions still apply when a number supplies business instructions.

**NOT OFFERED → do this instead** There is no separate fixed welcome_message per number. A dynamic opener is generated and can incorporate the known caller’s name. Keep a common fixed message on the agent, or use separate agents when different verbatim messages are essential.

**YOU CAN CHANGE** For a different greeting per business, keep Dynamic greeting on (the default) and put the opening line in that number’s custom_prompt. For example, “Start every call with: Thank you for calling Oak and Stone”.

**SCOPE · number** Put common rules in the agent system_prompt and business details in the dialled number’s custom_prompt. The number profile takes precedence on conflicting business details. It cannot grant new permissions.

Available inbound action forms depend on the agent’s enabled capabilities. Outbound menu controls do not apply. `[SEND_SMS: message]`, `[TRANSFER: phone_number]`, `[WAIT]`, `[END_CALL]`.

<a id="outbound-calls"></a>

## Single outbound calls and request receipts

**FIXED** Always pass the customer’s verified from_number on a shared agent. If omitted the engine selects the oldest eligible number for the owning account and agent, ordered by created_at then id.

**NOT OFFERED → do this instead** Outbound developer instructions do not inherit the agent’s inbound system_prompt or the number’s custom_prompt. Include the business and purpose in prompt or the recipient’s prompt_override. Fixed call rules and enabled knowledge and tools can still apply.

**YOU CAN CHANGE** Send agent_id, from_number, to_number and a meaningful prompt. Choose dynamic_vars for this call.

**SCOPE · call** Track an outbound request using its receipt. Preserve the request ID across an uncertain response and check its status before another dial.

The route rejects a blank prompt. A nonblank string shorter than 10 trimmed characters may reach the no-purpose apology and end instruction.

Create the call and look up the durable request status when an ID is returned. `POST /v1/calls/outbound`, `GET /v1/calls/outbound/requests/{request_id}`.

from_number_not_found means the supplied sender is ineligible. Check account ownership, assignment and the number’s outbound controls.

<a id="outbound-actions-variables"></a>

## Action tags and outbound variables

**FIXED** Use the listed developer-facing outbound tag forms exactly. The IVR and keypad navigation forms are outbound only. `[SEND_SMS: message]`, `[TRANSFER: phone_number]`, `[WAIT]`, `[END_CALL]`, `[IVR]`, `[PRESS: digits]`, `[IVR_END]`. The engine fills these outbound variables. Use their exact names inside double braces. The engine writes these values after merging recipient variables. `caller_phone`, `business_phone`, `current_date`, `current_time`, `tomorrow_date`, `call_id`, `agent_id`, `call_direction`, `current_iso_date`, `current_iso_time`, `tomorrow_iso_date`, `current_day_of_week`, `current_timezone`, `upcoming_days`.

**NOT OFFERED → do this instead** Developers cannot add or rename an action tag. Use the supported tag. For a custom integration, configure a custom function on the number and have the agent use the tool. caller_history is not automatically populated on outbound. caller_name and business_name are not engine-filled outbound variables either. Supply the recipient facts you actually need in dynamic_vars or the batch row’s variables.

**YOU CAN CHANGE** Choose case-sensitive ASCII letters, digits and underscores, for example `{{appointment_time}}`. Use dynamic_vars on a single call and map CSV columns to recipients[].variables for each campaign row. Supply caller_name and business_name yourself when referenced. Validate every row before submitting.

**SCOPE · call** Outbound uses its call purpose for developer instructions. Inbound combines the shared agent instructions with the dialled number’s profile. Engine rules and eligible knowledge can also apply.

Provide a meaningful call purpose meeting the minimum trimmed character count below. The HTTP route rejects blank input. Shorter nonblank input can trigger the no-purpose apology and ending instruction. 10.

With required voice-detail validation enabled, absent, null or blank custom values produce 409 missing_voice_details before dispatch. Read details.missing, fill the named fields and submit the corrected request.

With that validation enabled, spaces or punctuation in a placeholder produce 409 unsupported_voice_placeholder. Rename it in the template and the recipient data.

<a id="transfer-voicemail-keypad"></a>

## Transfer, voicemail and phone menus

**FIXED** An explicit valid destination in [TRANSFER: phone_number] wins. A bare or empty transfer uses the agent’s transfer_number.

**NOT OFFERED → do this instead** There is no number-level transfer_number setter or enforced tenant destination in the phone profile. Give the correct explicit target in the inbound profile or outbound purpose. Leave the shared fallback unset or use separate agents if a wrong fallback is unacceptable.

**YOU CAN CHANGE** Set number voicemail controls and the message on an API-imported number. Review the effective settings before placing a voicemail-enabled call.

**SCOPE · call** Outbound menu navigation can send keypad digits. Caller-entered digits on inbound are a separate input capability.

<a id="campaigns"></a>

## Voice and SMS campaigns

**FIXED** reuse_campaign_id replaces settings and recipients atomically only on an owned, never-launched voice draft or scheduled campaign. A launch claim prevents replacement. SMS creation always generates a fresh ID, even if the request forwards this field. Omit it for SMS.

**NOT OFFERED → do this instead** A finished campaign cannot be replayed or resumed. For Use again create a new campaign with a fresh ID, intended recipients and reviewed settings. There is no scheduled_at promise of dispatch at an exact second. Choose a date and a local window and track actual recipient status.

**YOU CAN CHANGE** Use schedule_type=schedule and scheduled_date (YYYY-MM-DD), timezone, optional paired window_start_minutes and window_end_minutes, and window_days. The date check uses UTC. Local recipient rules, time windows and capacity still apply.

**SCOPE · campaign** Cancel stops eligible future work. In-progress work may finish. Resume handles unattempted rows of the existing running launch. Deletion can wait for confirmed hang-up.

Voice deletion, cancellation and resume are separate operations. SMS has its own cancel and resume routes. `DELETE /v1/calls/batch/{id}`, `POST /v1/calls/batch/{id}/cancel`, `POST /v1/calls/batch/{id}/resume`, `POST /v1/sms/campaigns/{id}/cancel`, `POST /v1/sms/campaigns/{id}/resume`.

<a id="contact-controls"></a>

## Contact hours, consent and opt-outs

**FIXED** An inbound STOP suppresses that recipient across the owning account, for both voice and SMS. The business number that received it is evidence only.

**NOT OFFERED → do this instead** A number or a separate agent does not create its own STOP boundary. Use separate accounts when independent consent domains are required. Never route around a suppression.

**YOU CAN CHANGE** Add a do-not-contact entry for all channels, voice or SMS. Check the selected owner and recipient before any change.

**SCOPE · recipient** Preview local contact rules before outreach. Report the reason when a recipient is held and resolve the underlying policy or missing data. `needs_timezone`, `timezone_policy_paused`, `contact_policy_paused`, `consent_required`, `consent_withdrawn`, `do_not_contact`, `outside_hours`, `not_due_local`, `policy_migration_required`, `country_policy_review`, `holiday_data_unavailable`, `public_holiday`.

<a id="sms"></a>

## SMS, automatic replies and in-call texting

**FIXED** With incall_sms_enabled on the agent, an SMS-capable imported number with valid credentials can send during a call. Inbound uses the dialled business number as sender. Outbound uses the originating business number. The other party receives the text.

**NOT OFFERED → do this instead** SMS does not automatically inherit the inbound phone profile. Put this business’s SMS instructions in sms_prompt and configure automatic replies for its number.

**YOU CAN CHANGE** Choose sms_reply_enabled and sms_prompt for this number. Keep business-specific details separate when numbers share an agent.

**SCOPE · message** A single text, an automatic conversation reply and a call-triggered text are separate sends. Keep each message’s sender, receipt and consent together.

sms_outcome_unknown means delivery could not be confirmed. Check the receipt and history before another send.

<a id="website-agent"></a>

## Website chat, voice and installation

**FIXED** Website chat and website voice offer eligible custom functions only. Built-in calendar booking and availability are excluded. Phone and eligible SMS can use a configured calendar.

**NOT OFFERED → do this instead** The public API does not return ready-to-paste install HTML. Use the dashboard Install action for each customer’s number. The settings read includes install_id. An install receipt only reports that a widget was seen.

**YOU CAN CHANGE** Enable website custom functions only when every enabled function on that number is safe for public visitors. To offer booking, share the business’s booking link or hand off to phone or SMS.

**SCOPE · number** Web chat and web voice use the number’s web_prompt. Configure sms_prompt separately for SMS. A phone profile alone does not configure either channel.

Read widget settings and installation metadata for the owned number. `GET /v1/agent-web/{number}`.

<a id="inbox-history"></a>

## Inbox, history and tenant-scoped reads

**FIXED** Inbox number discovery is account-wide. Address threads by channel and number. Use the number filter on call history. Validate each tenant’s number before returning records.

**NOT OFFERED → do this instead** Voice and SMS campaign lists and the suppression list do not provide a general tenant from_number filter. Keep a server-side mapping of customer, number and campaign IDs. Filter authorised results before displaying them.

**YOU CAN CHANGE** Choose direction, source, outcome and period when supported. The number narrows a history read only. `direction` `all`, `inbound`, `outbound`, `web` · `source` `all`, `campaign`, `web`, `test`, `other` · `outcome` `all`, `successful`, `unsuccessful`, `unknown`, `failed` · `period` `all`, `today`, `week`, `month`.

**SCOPE · account** Use stable filters with the server’s next cursor when following history. Preserve the intended number through pagination.

For tenant deletion use `DELETE /v1/calls/{id}` for a verified call ID. `DELETE /v1/calls` is account-wide and accepts no number filter.

<a id="knowledge"></a>

## Knowledge bases

**FIXED** One live knowledge base belongs to an agent. Its attached numbers use that base on enabled channels. Only the active revision and eligible, unsuppressed pieces enter live retrieval. A small eligible base is supplied whole. Larger bases use question matches. Seeing all small-base pieces does not mean that they answer a particular question. Use the configured not-found response for missing information.

**NOT OFFERED → do this instead** A separate base or knowledge opt-out for one attached number is unavailable. Use separate agents for different knowledge bases or for a customer who needs no knowledge. Choose knowledge channels on each agent. Knowledge Test accepts knowledge mode. It does not simulate the number’s whole call prompt or take a call purpose. Use Knowledge Test for source-backed answers. Use an actual test call to check the complete call instructions.

**YOU CAN CHANGE** Use pasted text, PDF, DOCX or plain UTF-8 text, or discover a website and import selected pages. API submissions can request review. Choose the enabled channels. The initial default is inbound only. `inbound`, `outbound`, `web_voice`, `web_chat`, `sms`. Choose the match setting from the supported options below. The default is Strict. Set not_found to nonblank wording within the indicated character limit. `match` `Strict`, `Normal` · `defaultMatch` Strict · `notFoundMaxChars` 500.

**SCOPE · agent** Prepare knowledge from text, a supported file or selected website pages. Review drafts, edit topics and publish approved material.

Maximum sources, original-text tokens and topics per base are shown below. `sources` 50 · `kbTokens` 100,000 · `topics` 1,000.

The limit is 20 nondeleted knowledge bases per account. Agent count is independent.

410 number_knowledge_removed means a retired number-knowledge operation was requested. Resolve the attached agent instead.

<a id="caller-context"></a>

## Caller records and memory

**FIXED** A caller record belongs to the combination of business number and caller number. Resolve and authorise both before a lookup.

**NOT OFFERED → do this instead** Engine-managed history fields cannot be supplied as caller attributes. Use the supported contact fields for your own data. Keep application-only fields in your own records.

**YOU CAN CHANGE** Import caller data under the intended business number or update an individual record. Verify ownership before presenting it to a tenant.

**SCOPE · recipient** Use caller context for known callers on eligible inbound paths. Outbound names still need explicit variables.

<a id="bookings-calendars"></a>

## Bookings and calendars

**FIXED** For a new Google Calendar or Cal.com voice booking, collect and spell contact details separately, finish the combined read-back, then obtain a later clear yes for that proposal. Confirm the booking only after a successful write. This applies even with require_booking_confirmation=false.

**NOT OFFERED → do this instead** Cal.com does not offer an independent general call timezone for each number. It checks the agent timezone, its integration fallback, then Europe/London. Use separate agents for different Cal.com agent timezones. Google Calendar honours an explicit number-calendar timezone first, then uses the agent resolution.

**YOU CAN CHANGE** Supported Google Calendar settings include availability hours, timezone and invitation behaviour. These configure that number’s booking calendar. `timezone`, `hours`, `slot_minutes`, `calendar_id`, `send_invites`.

**SCOPE · number** For an owned number assigned to an agent, send only return_url to start Google Calendar consent. Open the returned url for the calendar owner. A competing calendar is refused. Read the number’s status after consent to confirm connection.

Start consent and read back that number’s integration status. For call-related changes read the call’s bookings. `POST /v1/integrations/google-calendar/number/{phoneNumber}/connect`, `GET /v1/integrations/google-calendar/number/{phoneNumber}`, `GET /v1/calls/{id}/bookings`.

<a id="integrations"></a>

## Automation, CRM and notifications

**FIXED** Use a number-owned connection for the intended customer. A Slack connection for one number does not configure another number.

**NOT OFFERED → do this instead** The Slack settings read cannot recover a saved incoming webhook URL. Read webhook_url_set to check configuration. Enter the replacement secret on your server when rotating it.

**YOU CAN CHANGE** Supply the supported endpoint and settings for the chosen adapter. Verify the number and destination before making a change.

**SCOPE · number** Connect Slack notifications, GoHighLevel or a supported automation through Zapier or Make. Use the matching integration resource for that business number.

<a id="custom-functions"></a>

## Custom functions and visitor access

**FIXED** When website functions are enabled, eligible enabled functions on that number can be offered to visitors. A visitor ID groups a conversation and cannot authorise access to your own customer records.

**NOT OFFERED → do this instead** Putting a new action tag like [BOOK_NOW] in a prompt does not create a function. Configure a number-scoped function with its argument schema, or use a supported phone booking integration.

**YOU CAN CHANGE** Choose a supported name, HTTPS destination and HTTP method. Keep credentials in trusted configuration and return only the response fields the agent needs.

**SCOPE · operation** A configured function can call your service with validated arguments. Make each public function safe for its intended audience.

On duplicate_function choose a unique name or update the intended existing function by ID.

<a id="webhooks"></a>

## Webhook verification and tenant routing

**FIXED** With organisations enabled the signing secret belongs to the organisation. The organisation API credential or a personal Owner can retrieve it. Human Admin and Member cannot. Keep the secret server-side.

**NOT OFFERED → do this instead** call.bookings carries no account field or number-specific signing secret. Verify first. Map number to the customer in your server-side directory. For an inbound call use the business to number, for outbound use from.

**YOU CAN CHANGE** Set delivery destinations per number. Pre-call settings can be scoped to an agent or number. Keep the delivery destination and your signature-verification secret separate.

**SCOPE · operation** Verify X-Nixflex-Signature (`t=<timestamp>,v1=<hex>`) with HMAC-SHA256 over timestamp + "." + the original raw request body. Compare the digest in constant time and enforce a freshness policy before trusting the payload.

These are the top-level call.bookings keys. Use call_id to correlate processing and design for redelivery. `event`, `call_id`, `agent_id`, `from`, `to`, `number`, `ended_at`, `timeline`, `final`.

Authorised server access can retrieve the signing secret. For kit users direct the human Owner to the dashboard. Never paste the secret into an AI conversation. `GET /v1/organisation/signing-secret`.

<a id="recordings-retention"></a>

## Recordings, retention and deletion

**FIXED** `DELETE /v1/calls` covers the owning account’s calls and related recordings. It takes no number or campaign filter. Its result reports sms_deleted=0.

**NOT OFFERED → do this instead** There is no bulk erase for just one customer’s number in a shared account. Resolve and verify each tenant-owned call ID, then use single-call deletion.

**YOU CAN CHANGE** New agents inherit account retention on creation. Use the agent update to change its saved call-retention policy.

**SCOPE · call** Check recording availability first. A stored link can expire. Pending, expired, unavailable and customer-bucket states have different meanings.

<a id="billing-usage"></a>

## Agent pricing and usage

**FIXED** Agents are unlimited. There is no fee per agent. Customers pay only for usage (minutes and texts).

**NOT OFFERED → do this instead** A separate agent does not create a separate account capacity budget. Pace customers’ work in your application. Use independent accounts for independent budgets.

**YOU CAN CHANGE** For usage attribution save the intended customer and its verified business number when making a request.

**SCOPE · agent** A developer can run many customers on one shared agent. Give each customer its own number and number prompt. Separate agents are needed only when knowledge or agent settings must differ.

<a id="limits-errors"></a>

## Limits, errors and safe retries

**FIXED** Inbound and outbound share the account/API-key concurrency budget. Read max_concurrent for the effective limit.

**NOT OFFERED → do this instead** There is no per-number concurrent-call reservation. Queue or pace each tenant in your application. Use separate accounts if the budgets must be independent.

**YOU CAN CHANGE** Adjust the rate at which your application submits work. An accepted queue entry can still wait for capacity.

**SCOPE · operation** Distinguish a rejected request, an accepted operation and an unknown outcome. Inspect the error code and details before deciding whether to retry.

The default is 10 simultaneous calls when the account has no positive override.

<a id="testing-live-status"></a>

## Testing and live status

**FIXED** The phone tester places a real call to the selected number. Reserve real numbers for deliberate tests.

**NOT OFFERED → do this instead** The public API does not provide a simulated phone network or a general live-monitor control endpoint. Test request construction with fixtures. Use the dashboard to observe an authorised real call.

**YOU CAN CHANGE** Choose a suitable test scenario and check the result before repeating a test.

**SCOPE · call** Use the monitor to inspect authorised live calls. Media connection and final call outcome are distinct observations.

A monitor connection loss does not prove that the call ended. Recheck live status and inspect the final record.
