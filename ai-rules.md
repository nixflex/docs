# Nixflex rules for AI

Reviewed 2026-11-27 against release engine `16046688ec2ddc33999a9f5561748e32b4449424`. Refresh from https://docs.nixflex.com/ai-rules.md. Add to project instructions or attach to your chat.

Agents are unlimited. There is no fee per agent. Customers pay only for usage (minutes and texts). Many customers can use one shared agent, each with its own number and number prompt. Use separate agents only for different knowledge or agent settings. List page size, knowledge-base quotas and simultaneous-call limits do not cap agent count.

## Find a feature

[Accounts, API keys and environments](#account-access) · [Organisations and team roles](#organisations) · [Agent settings, languages and voices](#agents-voices) · [Phone numbers and bringing your own number](#phone-numbers) · [Inbound phone calls and greetings](#inbound-calls) · [Single outbound calls and request receipts](#outbound-calls) · [Action tags and outbound variables](#outbound-actions-variables) · [Transfer, voicemail and phone menus](#transfer-voicemail-keypad) · [Voice and SMS campaigns](#campaigns) · [Contact hours, consent and opt-outs](#contact-controls) · [SMS, automatic replies and in-call texting](#sms) · [Website chat, voice and installation](#website-agent) · [Inbox, history and tenant-scoped reads](#inbox-history) · [Knowledge bases](#knowledge) · [Caller records and memory](#caller-context) · [Bookings and calendars](#bookings-calendars) · [Automation, CRM and notifications](#integrations) · [Custom functions and visitor access](#custom-functions) · [Webhook verification and tenant routing](#webhooks) · [Recordings, retention and deletion](#recordings-retention) · [Agent pricing and usage](#billing-usage) · [Limits, errors and safe retries](#limits-errors) · [Testing and live status](#testing-live-status)

<a id="account-access"></a>

## Accounts, API keys and environments

**FIXED** Use https://api.nixflex.com/v1 for customer integrations. Keep the API credential on your server.

**NOT OFFERED** No self-service sandbox account or URL exists. Use fixtures locally or an owned test number for real traffic. Use another environment only when Nixflex provisions it. Staging exists for internal testing only.

**YOU CAN CHANGE** Rotate the credential and update its callers together.

In Help choose New request for a capacity review, complaint or problem, abuse report, or other issue. Follow Your open chats. Owners and Admins see organisation tickets. Members see their own while authorised. Close chat removes it from the open list. A staff-closed chat can surface until its final reply is read. `POST /v1/support/tickets/chat-summary` is a read. Use watch_ticket to check a displayed ticket outside the current page.

Use /v1/support/tickets. A personal session sends X-Nixflex-Expected-Account with the original workspace’s public key_id for list, detail, chat-summary, writes and receipt lookup. Organisation keys select their own account. On 409 account_changed, discard the stale draft and refresh Help in the intended workspace.

Create, reply and solve each need an Idempotency-Key. Reply uses X-Expected-Revision. Solve sends version in JSON. Lost response? The original person can `GET /v1/support/tickets/requests/{request_key}` with the original account header. A 200 returns the current ticket and original receipt. 404 means missing or inaccessible. Never resend in a different workspace. Organisation keys can replay only the identical write with its key, body and revision.

**SCOPE · account** Authorise each customer on your server. A shared credential sees multiple tenants.

The default allowance is 300 requests per minute. Observe the effective limit returned by the API.

<a id="organisations"></a>

## Organisations and team roles

**FIXED** Owner manages keys, transfer and closure. Admin can manage ordinary resources, billing and Activity. Member can read ordinary resources.

**NOT OFFERED** An Admin cannot manage another Admin or take ownership by editing a role. Use the Owner’s personal session and the ownership transfer workflow.

**YOU CAN CHANGE** Invite a colleague with a permitted role. The recipient claims the invitation.

**SCOPE · organisation** Use invitations to grant access to the same business resources. Review team activity under the relevant organisation.

<a id="agents-voices"></a>

## Agent settings, languages and voices

**FIXED** For a different inbound opening on each number, use Dynamic greeting and put the opening in that number’s custom_prompt. Fixed welcome_message text, spoken language, pickup delay and general call timezone are shared agent settings. Use separate agents when those must differ. A booking timezone changes calendar times only.

**NOT OFFERED** A number cannot override fixed agent settings. Use its dynamic opening for business-specific wording. Use different agents for different fixed settings.

**YOU CAN CHANGE** Choose the supported catalogue voice and an eligible route. Select manual speech terms or configure structured values to extract from transcripts.

**SCOPE · number** Choose a complete primary and backup voice pair on the number. It overrides the agent pair as a whole. To use the saved agent pair, set voice_pair_inherit to true. A legacy voice_id can clear the agent’s catalogue key, and a partially migrated pair can be unavailable. Never choose by alias precedence.

A changed manual list accepts up to 20 keyterms. Existing over-limit text can remain untouched on an unrelated edit.

<a id="phone-numbers"></a>

## Phone numbers and bringing your own number

**FIXED** A number belongs to an account and agent. On a shared agent always pass that customer’s eligible from_number.

**NOT OFFERED** Fixed welcome_message, language, general timezone and pickup delay belong to the agent. Use Dynamic greeting and the number’s custom_prompt for its opening. Split agents for different fixed settings.

**YOU CAN CHANGE** Use `POST /v1/phone-numbers` on your server with the customer’s own `phone_number` and an active, owned `agent_id`. Send one complete pair. Twilio needs `twilio_sid` and `twilio_token`. Telnyx needs `telnyx_api_key` and `telnyx_connection_id` with optional `telnyx_public_key`. Keep secrets out of browsers and AI prompts. `custom_prompt` is optional.

PATCH fields below. Clearing depends on the field. Null record_call or require_booking_confirmation inherits. Use the number’s voicemail controls. `calcom_timezone_override`, `custom_prompt`, `voice_id`, `sms_reply_enabled`, `sms_prompt`, `web_prompt`, `speaking_rate`, `dtmf_enabled`, `require_booking_confirmation`, `record_call`, `recording_source`, `voicemail_leave_enabled`, `voicemail_message`.

Set the complete number pair, or set voice_pair_inherit for the agent pair. `voice_key`, `voice_route_key`, `backup_voice_key`, `backup_voice_route_key`.

**SCOPE · number** Import an owned carrier number, assign an agent, edit its channels or remove its Nixflex connection.

Number text limits in characters. `custom_prompt` 8,000 · `sms_prompt` 20,000 · `web_prompt` 16,000 · `voicemail_message` 2,000.

On import and PATCH, custom_prompt accepts up to 8,000 characters. A 12,000-character profile fails with 400 custom_prompt_too_long. Keep the number’s instructions short and put extra facts in agent knowledge. If those facts are private to one business, give it a separate agent.

<a id="inbound-calls"></a>

## Inbound phone calls and greetings

**FIXED** Shared call mechanics and action permissions still apply when a number supplies business instructions.

**NOT OFFERED** A number’s Dynamic greeting is generated and may include a known caller’s name. For a verbatim greeting use the agent’s fixed welcome_message. Use separate agents for different fixed greetings.

**YOU CAN CHANGE** For a different greeting per business, keep Dynamic greeting on (the default) and put the opening line in that number’s custom_prompt. For example, “Start every call with: Thank you for calling Oak and Stone”.

**SCOPE · number** Put common rules in the agent system_prompt and business details in the dialled number’s custom_prompt. The number profile takes precedence on conflicting business details. It cannot grant new permissions.

Available inbound action forms depend on the agent’s enabled capabilities. Outbound menu controls do not apply. `[SEND_SMS: message]`, `[TRANSFER: phone_number]`, `[WAIT]`, `[END_CALL]`.

<a id="outbound-calls"></a>

## Single outbound calls and request receipts

**FIXED** Pass the customer’s verified from_number. With require_from_number_for_shared_agent off (default), omission selects the oldest eligible number by created_at then id. With it on, two or more settled attachments, even disabled ones, require an explicit sender (400 from_number_required). A sole eligible number works. Pending imports do not count.

**NOT OFFERED** Outbound developer instructions do not inherit the agent’s inbound system_prompt or the number’s custom_prompt. Include the business and purpose in prompt or the recipient’s prompt_override. Fixed call rules and enabled knowledge and tools can still apply.

**YOU CAN CHANGE** Send agent_id, from_number, to_number and a meaningful prompt. Choose dynamic_vars for this call.

Read `GET /v1/organisation/outbound-settings`. Where available, the Owner or organisation API key can PATCH the same path with require_from_number_for_shared_agent. Campaigns need a reviewed sender. If it changes, choose and confirm again.

**SCOPE · call** Track an outbound request using its receipt. Preserve the request ID across an uncertain response and check its status before another dial.

Blank purposes are rejected. With prompt_validation=strict, a nonblank purpose under 10 trimmed characters gets 400 prompt_too_short before dialling. Without strict validation it can reach the apology and hang-up.

Create the call and look up the durable request status when an ID is returned. `POST /v1/calls/outbound`, `GET /v1/calls/outbound/requests/{request_id}`.

from_number_not_found means the supplied sender is ineligible. Check account ownership, assignment and the number’s outbound controls.

<a id="outbound-actions-variables"></a>

## Action tags and outbound variables

**MUST** Use `[SEND_SMS: message]` only when the agent’s `incall_sms_enabled` is on. For transfer use `[TRANSFER: phone_number]`.\
The other actions are `[WAIT]`, `[END_CALL]` and the outbound-only menu controls `[IVR]`, `[PRESS: digits]`, `[IVR_END]`. For another action configure a booking integration or custom function.

The engine fills these double-brace variables after merging recipient data, so its values win. `caller_phone`, `business_phone`, `current_date`, `current_time`, `tomorrow_date`, `call_id`, `agent_id`, `call_direction`, `current_iso_date`, `current_iso_time`, `tomorrow_iso_date`, `current_day_of_week`, `current_timezone`, `upcoming_days`.

**NOT OFFERED** You cannot register a new action tag in a prompt. For your own workflow, configure a number-level custom function with defined arguments.

Outbound does not fill caller_history, caller_name or business_name. Supply needed facts in dynamic_vars or recipients[].variables.

**YOU CAN CHANGE** Use case-sensitive ASCII letters, digits and underscores for names such as `{{pickup_time}}`. Send dynamic_vars for one call. Map CSV columns to recipients[].variables for each campaign row. Supply caller_name and business_name when referenced.

**SCOPE · call** Outbound uses its call purpose for developer instructions. Inbound combines the shared agent instructions with the dialled number’s profile. Engine rules and eligible knowledge can also apply.

Validate every row before sending. The required voice-details flag can be off. Reject absent, null or blank non-system values and malformed names yourself. When on, the engine refuses before dispatch with 409 missing_voice_details (see details.missing) or 409 unsupported_voice_placeholder. Rename a bad key in both template and row. Never rely on a literal placeholder being spoken.

<a id="transfer-voicemail-keypad"></a>

## Transfer, voicemail and phone menus

**FIXED** An explicit valid destination in [TRANSFER: phone_number] wins. A bare or empty transfer uses the agent’s transfer_number.

**NOT OFFERED** There is no number-level transfer_number setter or enforced tenant destination in the phone profile. Give the correct explicit target in the inbound profile or outbound purpose. Leave the shared fallback unset or use separate agents if a wrong fallback is unacceptable.

**YOU CAN CHANGE** Set number voicemail controls and the message on an API-imported number. Review the effective settings before placing a voicemail-enabled call.

**SCOPE · call** Outbound menu navigation can send keypad digits. Caller-entered digits on inbound are a separate input capability.

<a id="campaigns"></a>

## Voice and SMS campaigns

**MUST** Resume covers only unattempted work in the existing running launch, and neither resume nor reuse replays completed work.\
reuse_campaign_id replaces settings and recipients atomically only on an owned, never-launched voice draft or scheduled campaign. A launch claim prevents replacement. SMS creation always generates a fresh ID, even if the request forwards this field. Omit it for SMS.

**NOT OFFERED** Resume covers only unattempted work in the existing running launch, and neither resume nor reuse replays completed work. For another run create a campaign with a fresh ID, selected recipients and reviewed settings.

There is no scheduled_at promise of dispatch at an exact second. Choose a date and a local window and track actual recipient status.

**YOU CAN CHANGE** Use schedule_type=schedule, scheduled_date (YYYY-MM-DD), timezone, window_days and optional paired window_start_minutes/window_end_minutes. UTC date checks, local windows and capacity apply.

For one owned sender, send business_number (encode + as %2B) on `GET /v1/campaigns` or `GET /v1/sms/campaigns`. Omit for account scope. Keep the same number and status through SMS cursors. Restart paging if either changes. Voice include_totals=true covers returned campaigns only (default 50, max 200).

Pickup rate = answered attempts / all attempts, including failed starts. Answered means over five seconds with no detected voicemail. Sum counts before dividing. Zero attempts means no rate. SMS delivery rate = delivered / (delivered + failed).

**SCOPE · campaign** `DELETE /v1/calls/batch/{id}` deletes a voice campaign. Voice and SMS have separate cancel routes. Cancel stops future work. Running attempts may finish.

<a id="contact-controls"></a>

## Contact hours, consent and opt-outs

**FIXED** An incoming STOP blocks voice and SMS across the owning account. The receiving business number is evidence only.

**NOT OFFERED** A number or a separate agent does not create its own STOP boundary. Use separate accounts when independent consent domains are required. Never route around a suppression.

**YOU CAN CHANGE** Add a do-not-contact entry for all channels, voice or SMS. Check the selected owner and recipient before any change.

Keyword STOP works independently. AI recognition of a sender’s clear objection in a verified incoming SMS is off by default. Customers have no switch for it. Where enabled on eligible automatic replies, it blocks calls and texts account-wide and may send one goodbye.

On `GET /v1/contact-suppressions`, business_number alone selects keyword evidence. Add source=attributed for keyword and AI entries. To correct an eligible AI mistake, the Owner or account key sends phone_number, channel=all, current review_version and a reason to `POST /v1/contact-suppressions/ai-corrections`. Reload on review_changed. Keyword STOP and independent restrictions stay locked. Correction never supplies consent.

**SCOPE · recipient** Preview local contact rules before outreach. Report the reason when a recipient is held and resolve the underlying policy or missing data. `needs_timezone`, `timezone_policy_paused`, `contact_policy_paused`, `consent_required`, `consent_withdrawn`, `do_not_contact`, `outside_hours`, `not_due_local`, `policy_migration_required`, `country_policy_review`, `holiday_data_unavailable`, `public_holiday`.

<a id="sms"></a>

## SMS, automatic replies and in-call texting

**FIXED** In-call texting requires incall_sms_enabled on the agent, an SMS-capable business number and valid carrier credentials. Inbound sends from the dialled number to its caller. Outbound sends from the originating number to the person called. Respect opt-outs on both paths. Never substitute another tenant’s sender.

**NOT OFFERED** SMS does not automatically inherit the inbound phone profile. Put this business’s SMS instructions in sms_prompt and configure automatic replies for its number.

**YOU CAN CHANGE** Choose sms_reply_enabled and sms_prompt for this number. Keep business-specific details separate when numbers share an agent.

**SCOPE · message** A single text, an automatic conversation reply and a call-triggered text are separate sends. Keep each message’s sender, receipt and consent together.

sms_outcome_unknown means delivery could not be confirmed. Check the receipt and history before another send.

<a id="website-agent"></a>

## Website chat, voice and installation

**FIXED** Website chat and website voice offer eligible custom functions only. Built-in calendar booking and availability are excluded. Phone and eligible SMS can use a configured calendar.

**NOT OFFERED** The public API does not return ready-to-paste install HTML. Use the dashboard Install action for each customer’s number. The settings read includes install_id. An install receipt only reports that a widget was seen.

**YOU CAN CHANGE** Enable website custom functions only when every enabled function on that number is safe for public visitors. To offer booking, share the business’s booking link or hand off to phone or SMS.

**SCOPE · number** Configure each number’s sms_prompt for SMS and web_prompt for website chat and voice. Neither channel inherits its phone custom_prompt. Both still use the agent knowledge enabled for that channel and follow their own channel rules.

Read the number’s widget settings and install ID. `GET /v1/agent-web/{number}`.

<a id="inbox-history"></a>

## Inbox, history and tenant-scoped reads

**FIXED** Inbox number discovery is account-wide. Filter threads by channel and number, and call history by number. `DELETE /v1/calls` purges calls and related recordings account-wide and reports sms_deleted=0. For one customer verify each call ID, then use `DELETE /v1/calls/{id}`.

**NOT OFFERED** A business_number filter on campaign and opt-out reads does not establish tenant identity. Authorise the tenant and its number on your server. Keep that filter through SMS pagination. Bulk call deletion stays account-wide.

**YOU CAN CHANGE** Choose direction, source, outcome and period when supported. The number narrows a history read only. `direction` `all`, `inbound`, `outbound`, `web` · `source` `all`, `campaign`, `web`, `test`, `other` · `outcome` `all`, `successful`, `unsuccessful`, `unknown`, `failed` · `period` `all`, `today`, `week`, `month`.

**SCOPE · account** Keep the same filters with each server-issued cursor.

<a id="knowledge"></a>

## Knowledge bases

**FIXED** One live knowledge base belongs to an agent. Its attached numbers use that base on enabled channels. Only the active revision and eligible, unsuppressed pieces enter live retrieval.

A small eligible base is supplied whole. Larger bases use question matches. Seeing all small-base pieces does not mean that they answer a particular question. Use the configured not-found response for missing information.

**NOT OFFERED** Knowledge and its enabled channels belong to the agent. Retired per-number knowledge operations return 410 number_knowledge_removed. Use separate agents when a number needs different knowledge or none.

Knowledge Test accepts knowledge mode. It does not simulate the number’s whole call prompt or take a call purpose. Use Knowledge Test for source-backed answers. Use an actual test call to check the complete call instructions.

**YOU CAN CHANGE** Use pasted text, PDF, DOCX or plain UTF-8 text, or discover a website and import selected pages. API submissions can request review.

Choose the enabled channels. The initial default is inbound only. `inbound`, `outbound`, `web_voice`, `web_chat`, `sms`.

Choose the match setting from the supported options below. The default is Strict. Set not_found to nonblank wording within the indicated character limit. `match` `Strict`, `Normal` · `defaultMatch` Strict · `notFoundMaxChars` 500.

**SCOPE · agent** Review knowledge drafts and publish approved material. Limits per base: `sources` 50 · `kbTokens` 100,000 · `topics` 1,000.

The limit is 20 nondeleted knowledge bases per account. Agent count is independent.

<a id="caller-context"></a>

## Caller records and memory

**FIXED** A caller record is keyed by business number and caller number. Authorise both.

**NOT OFFERED** History fields are engine-managed. Store supported caller attributes in Nixflex and app-only fields locally.

**YOU CAN CHANGE** Import or update caller data under the tenant’s verified business number.

**SCOPE · recipient** Use caller context for known callers on eligible inbound paths. Outbound names still need explicit variables.

<a id="bookings-calendars"></a>

## Bookings and calendars

**FIXED** For new Google Calendar or Cal.com voice bookings, collect spelled name and email separately. Finish the combined read-back and get a later clear yes before the write, even with require_booking_confirmation=false. To reschedule or cancel an existing Cal.com appointment that changed across lookups, read back the current target in full and get a fresh yes. Confirm success only after the calendar write succeeds. SMS uses its own flow.

**NOT OFFERED** The booking zone cannot change general call time. Set calcom_timezone_override on the number to an IANA zone, or null to inherit. Cal.com uses number → agent → saved connection → Europe/London. With a booking context, read effective_calcom_timezone and effective_calcom_timezone_source. Google Calendar keeps its own number-calendar setting.

**YOU CAN CHANGE** Supported Google Calendar settings include availability hours, timezone and invitation behaviour. These configure that number’s booking calendar. `timezone`, `hours`, `slot_minutes`, `calendar_id`, `send_invites`.

**SCOPE · number** For an owned number assigned to an agent, send only return_url to start Google Calendar consent. Open the returned url for the calendar owner. A competing calendar is refused. Read the number’s status after consent to confirm connection.

<a id="integrations"></a>

## Automation, CRM and notifications

**FIXED** Scope each connection to its business number, including Slack.

**NOT OFFERED** The Slack settings read cannot recover a saved incoming webhook URL. Read webhook_url_set to check configuration. Enter the replacement secret on your server when rotating it.

**YOU CAN CHANGE** Verify the business number, endpoint and settings before changing an integration.

**SCOPE · number** Use that number’s integration for Slack, GoHighLevel, Zapier or Make.

<a id="custom-functions"></a>

## Custom functions and visitor access

**FIXED** When website functions are enabled, eligible enabled functions on that number can be offered to visitors. A visitor ID groups a conversation and cannot authorise access to your own customer records.

**NOT OFFERED** Putting a new action tag like [BOOK_NOW] in a prompt does not create a function. Configure a number-scoped function with its argument schema, or use a supported phone booking integration.

**YOU CAN CHANGE** Choose a supported name, HTTPS destination and HTTP method. Keep credentials in trusted configuration and return only the response fields the agent needs.

**SCOPE · operation** A configured function can call your service with validated arguments. Make each public function safe for its intended audience.

On duplicate_function choose a unique name or update the intended existing function by ID.

<a id="webhooks"></a>

## Webhook verification and tenant routing

**MUST** With organisations enabled, each organisation has one signing secret. Send the human Owner to the dashboard. Never ask for it in chat or expose it to AI tools.\
An authorised server can use an Owner session or the organisation API credential. Admin and Member sessions cannot retrieve it. Store it on the receiving server.

**NOT OFFERED** call.bookings has no account field or per-number secret. After signature verification, look up number in your own tenant table. It is the business to number inbound and from number outbound.

**YOU CAN CHANGE** Set delivery destinations per number. Pre-call settings can be scoped to an agent or number. Keep the delivery destination and your signature-verification secret separate.

**SCOPE · operation** Verify X-Nixflex-Signature (`t=<timestamp>,v1=<hex>`) with HMAC-SHA256 over timestamp + "." + the original raw request body. Compare the digest in constant time and enforce a freshness policy before trusting the payload.

These are the top-level call.bookings keys. Use call_id to correlate processing and design for redelivery. `event`, `call_id`, `agent_id`, `from`, `to`, `number`, `ended_at`, `timeline`, `final`.

With organisations enabled, only an Owner session or the organisation API credential can retrieve the secret on a server. The kits omit this secret read. `GET /v1/organisation/signing-secret`.

<a id="recordings-retention"></a>

## Recordings, retention and deletion

**FIXED** `DELETE /v1/calls` covers the owning account’s calls and related recordings. It takes no number or campaign filter. Its result reports sms_deleted=0.

**NOT OFFERED** There is no bulk erase for just one customer’s number in a shared account. Resolve and verify each tenant-owned call ID, then use single-call deletion.

**YOU CAN CHANGE** New agents inherit account retention on creation. Use the agent update to change its saved call-retention policy.

**SCOPE · call** Read availability first. Stored links expire. Distinguish pending, expired, unavailable and customer storage.

<a id="billing-usage"></a>

## Agent pricing and usage

**FIXED** Agents are unlimited. There is no fee per agent. Customers pay only for usage (minutes and texts). Many customers can use one shared agent, each with its own number and number prompt. Use separate agents only for different knowledge or agent settings. List page size, knowledge-base quotas and simultaneous-call limits do not cap agent count.

**NOT OFFERED** A separate agent does not create a separate account capacity budget. Pace customers’ work in your application. Use independent accounts for independent budgets.

**YOU CAN CHANGE** Save the customer and verified business number with each request.

**SCOPE · agent** Group numbers by the knowledge and agent settings their customers need. Attribute each customer’s usage to its verified business number.

<a id="limits-errors"></a>

## Limits, errors and safe retries

**FIXED** Inbound and outbound share the account/API-key concurrency budget. Read max_concurrent for the effective limit.

**NOT OFFERED** No per-number concurrency reservation exists. Pace tenants in your app or use separate accounts for independent budgets.

**YOU CAN CHANGE** Pace submissions. Accepted work may wait for capacity.

**SCOPE · operation** Check the code and details to distinguish refusal, acceptance and unknown outcome before retrying.

The default is 10 simultaneous calls when the account has no positive override.

<a id="testing-live-status"></a>

## Testing and live status

**FIXED** The phone tester places a real call to the selected number.

**NOT OFFERED** The public API does not provide a simulated phone network or a general live-monitor control endpoint. Test request construction with fixtures. Use the dashboard to observe an authorised real call.

**YOU CAN CHANGE** Choose a test scenario and check its result before retrying.

**SCOPE · call** An authorised monitor connection shows live media. Check the final call record for its outcome.

A monitor connection loss does not prove that the call ended. Recheck live status and inspect the final record.
