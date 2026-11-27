# DOC4 release drafts

These three patches target the combined Release A draft and published Help base, `7abf4337cf282be8e8a21b2f0a7d497accb0e4fa`. This directory is excluded by the site's existing `.mintignore`. Each patch includes the MDX, any new menu entries and the public OpenAPI changes for its own release.

| Folder | Contents | Release evidence |
| --- | --- | --- |
| B | Number-specific Cal.com booking times and renewed appointment approval | Engine 8ce7190, dashboard ce5cb21 |
| C | Campaign number filters, pickup rate, attributed opt-outs, SMS recognition and Owner correction | Engine 56a162b, dashboard 2634e55 |
| S | Help chats, app Help, ticket API and personal receipt recovery | Engine 16046688, dashboard 668be49f |

## Review a candidate

Start with clean generated docs on a local review branch. Apply only the groups in the release. On the combined candidate, use B, C, S in that order. Run each command from the docs root and continue only after exit 0.

```powershell
git apply --check spec-source/doc4-drafts/B/publish.patch
git apply spec-source/doc4-drafts/B/publish.patch
git apply --check spec-source/doc4-drafts/C/publish.patch
git apply spec-source/doc4-drafts/C/publish.patch
git apply --check spec-source/doc4-drafts/S/publish.patch
git apply spec-source/doc4-drafts/S/publish.patch
python spec-source/doc4-drafts/sync-directory.py --write
python spec-source/doc4-drafts/sync-directory.py --check
python spec-source/doc4-drafts/verify.py
```

The verifier above checks the combined preview. B and C leave the native app controls undescribed. The S phone guide requires the released app shell with ticket support. If web and app releases split, hold its phone-page hunk and the app-specific sentences until the app is available.

Apply these release overlays **after** the existing generators. For ongoing publication, fold reviewed content into the current authored sources and operation inventory before dropping the overlay step. Rebuild on a clean candidate, reapply selected overlays, regenerate the directory, and compare the resulting MDX, menu and public schema to the reviewed preview. The DOC5 rules map the ten additional operations across A, C and Help and describe the effective Cal.com zone. Publish those rules with the joined release after two independent 30/30 runs. Existing Release A patches remain a distinct release. Round 2 supersedes the earlier Help form and the email-only description in the older SC2 app draft.

## Publication checks

1. Confirm the exact customer-facing engine, schema and dashboard candidates. On disposable staging fixtures, confirm Help permission boundaries and the personal receipt/account-change behavior. Confirm that customer controls and recognition/review rollout match the draft.
2. For each business task, capture the shipped staging screen with synthetic data. The reports include local fixture screenshots for comparison. App screenshots must come from the actual app build.
3. Run the standard docs tests, the DOC4 verifier, Mintlify navigation validation and broken-link checking. Include the refreshed directory in the syntax/link checks. Publish the corresponding group when the feature reaches customers.

`STAGING-READS.ps1` is a read-only helper for the person running staging checks. Use a fixture number with an active Cal.com connection and a scoped staging credential in `NIXFLEX_STAGING_API_KEY`. A personal receipt check additionally uses `NIXFLEX_STAGING_PERSONAL_TOKEN` and `NIXFLEX_STAGING_ORIGINAL_ACCOUNT_ID`. Supply those only in the local test process. The script prints check names and status. It never contacts the production origin.

```powershell
.\spec-source\doc4-drafts\STAGING-READS.ps1 -BusinessNumber $StageFixtureNumber -TicketId $StageFixtureTicket -PersonalRequestKey $StageFixtureRequest
```
