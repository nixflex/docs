# Nixflex documentation style guide — v1

Locked by Fahim on 5 November 2026. Applies to every new page and every future page update. The visual reference is `docs-design-v1.html` in the shared `notes/docs-design` folder. This file is the permanent authoring standard; page templates are in `templates/`. The reference fixes the design, not the truth of its illustrative API examples, timings, prices or delivery promises.

## One feature, two audiences

| Audience | Start with | Include | Leave to the other audience |
| --- | --- | --- | --- |
| Business guide | What the person can do and the important limit | Plain steps using real dashboard labels; a short conversation or flow when useful; status meanings and what to do | HTTP fields, SDK setup, implementation history and internal test names |
| Developer guide | The app behavior to build | The same feature and limits, prerequisites, complete code, result handling, errors, retry rules and endpoint links | Repeating a dashboard walkthrough line by line |
| API reference | The exact action and object | Authentication, request/response contract, a minimal valid example, errors with recovery and write/replay limits | A full multi-feature tutorial |
| Webhook event | What causes this event and what it proves | Payload, timing, signature, duplicate identity, durable acceptance, examples and failure handling | Presenting the event as a callable API endpoint |

Every Business page links to its Developer counterpart; every Developer page links back. An API page links to the relevant Business and Developer guides. Several endpoints may share the same feature guide: do not turn a Business page into a list of every endpoint. Pair by task, not by matching filenames. Use the nearest existing guide until a planned counterpart is written; never publish a broken link or an empty future page. Maintain the pairing map with the source plan. C15 brings the complete docs tree under the coordinated maintenance pass. Update both audience pages and their contract references in the same feature round.

## The shared page shape

Use this order, adapting sections only when the topic warrants it. A short read endpoint does not need a fictional conversation, FAQ or four-step diagram.

1. **Title and answer.** One H1, followed by one sentence that directly answers the title's task or question. The description is a useful summary, not a sales slogan. Do not repeat the same sentence immediately below it.
2. **At a glance.** Two to four compact facts that help a decision: scope, permission, result, request method or timing boundary. Omit unsupported setup-time, cost and availability claims.
3. **The important part.** Two to four specific takeaways. Include the most consequential limitation here, before code or a destructive action.
4. **Understand and do it.** A brief flow or example conversation where helpful, followed by numbered steps or the endpoint's request fields and code tabs.
5. **Read the result.** Show a real schema-shaped example. Distinguish accepted, completed, confirmed empty, unavailable and unknown. A missing reply is not proof that nothing happened.
6. **Handle problems.** A compact table: status/code, what it means, what to do. Put the decision beside the error; a generic link to the error catalogue is not enough.
7. **Next.** Two or three useful task links, plus the audience switch when it is not already one of them. Link to the shared glossary where unfamiliar terms first occur. Include the review date only when the page was substantively checked.

Preserve useful deep-link anchors when rewriting headings. Keep endpoint sections named `Request fields`, `Response fields`, `Example request`, `Example response`, `Errors`, and `Retry and idempotency` where they already anchor external links. Add clearer subheadings within them rather than silently breaking an existing URL.

## Titles, sidebar labels and words

| Page | Title rule | Example |
| --- | --- | --- |
| Business | Verb + task | Take bookings with Google Calendar |
| Developer | Feature + API, or a task in code | Google Calendar bookings API |
| Endpoint | Action + object | Connect Google Calendar |
| Webhook | Receive + result, with the event name | Receive booking results: call.bookings |

Titles must be unique and at most 60 characters. Put the main task or feature early. Do not lead with a method, long URL, “How to”, “Everything about”, or “Nixflex” on every page. A sidebar label should be one to four words and at most 36 characters; retain enough context to distinguish siblings. HTTP method badges provide method context where supported. Use sentence case and British English in prose; never change wire names, code or product labels to match spelling preferences.

Use the existing **single glossary at `/guides/glossary`**. Prefer *phone number*, *agent*, *organisation*, *booking*, *knowledge*, *topic*, *source*, *draft*, *campaign* and *channel* consistently. Explain a required technical term once near its first use; do not invent synonyms for variety. An account key and a person's session are different credentials. A call ID, request ID, booking UID and webhook event name are different identifiers. Keep their code spelling exact. Propose missing glossary terms to its owner rather than creating a second glossary.

Write one idea per short paragraph, usually two or three sentences. Lead with the action. Use lists for steps or comparable choices and tables for mappings. Bold the important decision, not entire paragraphs. Avoid hype, claims of guaranteed delivery, unproved “instant” or “always”, and implementation diary language. Explain boundaries in the context where they matter.

## Locked visual language

| Element | Standard |
| --- | --- |
| Page | White background; dark ink `#0F1720`; secondary text `#4B5563`; ample space |
| Accent | Green `#25D366`; readable text green `#0F7A40`; pale green `#E8FBF0` for key points |
| Surfaces | Soft grey `#F7F8FA`, border `#E6E8EC`, 12–14 px corner radius |
| Type | Inter with a system sans fallback; code uses JetBrains Mono or a legible monospace fallback |
| Scale | Body about 15.5–16 px, line height about 1.65; H1 34 px desktop / 27 px phone; H2 about 23 px |
| Facts | Two to four small cards; four columns only when space permits, then two or one |
| Key points | One pale-green panel near the top, titled “The important part” |
| Code | Dark code surface, readable contrast, named language tabs, real copy behavior from Mintlify |
| Layout | Five tabs; expanded sidebar; main reading column; a page contents rail on wide screens |
| Phone | One readable content column; accessible navigation drawer; code/tables scroll within their own container |

Use the shared `nxf-facts`, `nxf-important`, `nxf-flow`, `nxf-conversation` and `nxf-audience` classes from `styles.css` with semantic text/HTML. Use native Mintlify code tabs, callouts, cards and steps where they fit. Do not recreate fake “Copy”, feedback, search, or AI buttons. Keep the existing real contextual menu. Never require colour alone to explain status. Ensure keyboard focus, meaningful link text, readable contrast and no page-wide horizontal overflow.

Set `styling.codeblocks` to `dark` in `docs.json` so code stays on the locked dark surface in both site themes. Use Mintlify's supported setting rather than overriding syntax colours with CSS; see [Appearance and branding](https://www.mintlify.com/docs/organize/settings-appearance#styling). Keep blank lines around Markdown inside HTML panels so both page rendering and Markdown export retain the intended structure.

The small-text green is a contrast correction to the reference's `#128C4A`: it gives 5.03:1 on the pale-green panel and 5.42:1 on white, compared with 4.00:1 and 4.31:1. The brand accent stays `#25D366`. Use the darker colour for small meaningful text; bright green is an accent, not a small-text colour. Dark-mode text green `#75EAA2` gives 10.01:1 on `#102C20`.

The shared CSS also applies the readable light-theme green to native selected sidebar links, active contents links and the small page-category label. Keep these rules scoped to navigation and the header: dark code blocks have their own text colours. Brand backgrounds and accents remain unchanged. Check these native labels when upgrading Mintlify because its rendered structure can change.

**Navigation must look full.** Keep all five tabs in the locked order. Top-level groups are visible; set `expanded: true` on every nested group. Prefer shallow groups with short labels. All entries must be available without opening collapsed topic groups. A long tab naturally scrolls; do not shrink text to force 162 links into one viewport. On phones, the menu may use a drawer, but its topic groups still start expanded. Mintlify documents this behavior in [Navigation](https://www.mintlify.com/docs/organize/navigation).

## Examples and accurate claims

Use a short conversation, flow boxes, a status table or code tabs before considering a screenshot. A screenshot is essential only when a person needs to recognise an otherwise confusing control or visual state. Crop to that decision, add useful alt text and record its source/version. No decorative screenshots, placeholder product captures or text baked into images. Existing unrelated screenshots are not permission to add more.

A conversation must show each required approval. For a new voice booking, the caller spells the full name letter by letter, spells the email local part letter by letter and says the domain as words. Then show one combined read-back of the booking, name and email and one clear yes before the write. This is required on every number even when the old optional final-confirmation setting is off. Correct only the wrong part. SMS and existing-booking lookup, move and cancel keep their own contact flow. Claim a booking or notification request only after a confirmed result, and never promise inbox delivery. Use fictional contacts and reserved example domains. Do not put real credentials, live customer data, internal fixtures or protected numbers in examples.

Examples must match the merged contract and actual client version. Prefer complete, minimal HTTP examples when client support is not verified. Use normal registry installation commands for published packages and state the minimum version needed by each feature. Never copy a constructor or method from the visual mockup as proof that an SDK exposes it. A read example should be safe and useful; a write example must name its effect, ownership requirement and uncertainty/retry boundary. Never retry an unknown call launch with a new request ID automatically.

Every error row must answer “what should my app or user do next?” Match status and machine code to source. Differentiate read retry, correcting input, permission changes, reconciliation, waiting, and contacting support. Do not suggest an account-key workaround for a role restriction. Do not document voice cloning while it is being removed.

Put literal command flags and complete commands in Markdown code spans. Otherwise Markdown typography can turn `--output` into a different dash. Raw HTML code tags do not reliably protect their text in Mintlify. Use plain-language facts such as “JSON for scripts”, and give the literal flag in a Markdown code span in the instructions. Check the actual rendered code text, not only the source Markdown.

## Feature-size rule

Start with one useful overview per audience. Split a feature when **two or more** of these are true:

- It has three or more independent user tasks or materially different setup paths.
- Setup, runtime handling and recovery have different permissions, prerequisites or failure decisions.
- A reader must cross more than roughly 1,200 words or six substantial sections to finish one task.
- A meaningful troubleshooting workflow would interrupt the normal setup path.
- A subtask has its own clear search intent and enough unique, tested content to stand alone.

Use an overview, task/how-to pages and a troubleshooting page as needed. The overview explains choices and links out; it does not duplicate the entire how-to. Each new page must have a useful independent outcome, valid audience links and an owner. Never split only to increase page count, chase keywords or mirror every backend module. Endpoint references stay one operation per page; lifecycle concepts belong in guides. `FEATURE-PAGES-PLAN.md` records current coverage, proposed pages, owners and delivery round. A planned page is not published until written and validated.

## Google, AI readers and sharing

| Proposed rule | Decision and reason |
| --- | --- |
| First sentence answers the question | **Keep.** It helps a reader decide whether this is the right page and gives retrieval a precise summary. |
| Search-shaped headings | **Keep with restraint.** Use the words customers use for the actual task; avoid repetitive keyword stuffing or turning every heading into a question. |
| Two or three related links plus audience links | **Keep.** Choose the next useful tasks and the other audience's version; allow more only when a reference index requires it. |
| One glossary, same words | **Keep and enforce.** `/guides/glossary` is the authority; exact API identifiers remain unchanged. |
| Share image and description per page | **Keep, with generated images by default.** Give every page a unique description and inspect its generated share metadata/image. Do not create hundreds of decorative bitmap files. |

Descriptions should be complete, unique sentences, generally 80–160 characters and never over 160 in this repository. They explain the result and an important constraint; they are not a string of keywords. Keep established slugs and redirects. Use production `https://docs.nixflex.com` canonicals, one H1, a logical heading order and descriptive internal links. Preserve useful index pages and avoid orphan pages.

Check real generated HTML, readable `.md` routes, `llms.txt`, sitemap page-set equality and canonical URLs. Do not equate equal counts with equal sets. Keep public API schemas downloadable and matching the reviewed source. A local export without a sitemap is not proof of hosted indexing. Keep authoring templates and reports out of the public page/index set.

Keep source backups matching `*.backup*` and `*.bak_*` in `.mintignore`. Check the entire exported file inventory as well as the HTML page set: an old source copy must not become a public static download.

Mintlify generates page metadata, social images and structured data from configuration/frontmatter; inspect the installed and hosted output rather than assuming a new hosted feature exists in an older local CLI. Prefer its native page-specific share image and unique description; do not replace every page with one generic image. Check JSON-LD against visible facts and avoid duplicate custom markup or invented FAQ/review/rating data. [Mintlify SEO](https://www.mintlify.com/docs/optimize/seo) and [Markdown export](https://www.mintlify.com/docs/ai/markdown-export) describe these facilities.

`llms.txt` and Markdown copies help tools consume the docs; they do not guarantee inclusion in Google or an AI answer. Google's AI search guidance requires the same useful, crawlable content as ordinary search and no special AI schema. Keep technical access, textual content and honest claims as the priority. [Google AI features](https://developers.google.com/search/docs/appearance/ai-features) and [title guidance](https://developers.google.com/search/docs/appearance/title-link).

## Authoring and review workflow

1. Identify the audience, task, source commit, page pair and feature cluster. Read this guide and the matching template.
2. Edit authoritative source data/builders for generated pages, then regenerate; do not rely on hand edits that the next build overwrites.
3. Check contract accuracy, examples, code syntax, unique bounded metadata, links, glossary wording, all expanded groups and a phone view.
4. Run the full local gate. Preserve failed and pending evidence. Existing locked tests need explicit approval for any further change; adding a feature does not silently waive this rule.
5. Open a reviewed private preview through the operator workflow. A preview URL is public unless authentication or password protection is actually enabled; never call an unlisted URL private. No main merge or production publication is part of this authoring workflow.

C15 applies this standard to the complete merged Business, Developer, API, SDK/CLI and AI-tools site. The accepted earlier samples and D7 task pages are part of that same tree. Coordinate both audiences, API contracts and client examples in each feature round; no separate ownership boundary should leave contradictory public guidance.

## Where to edit the authoritative sources

| Change | Authoritative source |
| --- | --- |
| API title, sidebar label, description, lead, key points or audience pair | `spec-source/c13-pages.json`; keep the navigation/title plan in `spec-source/c9-pages.json` aligned |
| Existing endpoint fields, limits, examples and errors | The relevant C4/C5/C6/C8 source JSON or `spec-source/c9-manual-pages.json`; the established contract builders run first |
| B56 schema and request-state semantics | `scripts/c13-contracts.mjs`, checked against the pinned engine commit |
| API concept/event prose | The matching `.mdx.txt` file in `spec-source/c13-concepts/`; `scripts/build-c13-pages.mjs` supplies the shared layout and B56 cross-links |
| Hand-authored agent-creation endpoint | `spec-source/c13-standalone/agents--create.mdx.txt` holds its contract tables and examples; the C13 plan supplies its lead and layout. Never use the generated page as its own input. |
| Any Developer or SDK/CLI/MCP page | The matching `.mdx.txt` file named by `spec-source/c14-pages.json`, under `spec-source/c14-pages/`. This includes the five earlier samples; C14 is now their final authoring layer. |
| New feature route, page pairing or review state | `spec-source/c14-pages.json`, `docs.json` and `FEATURE-PAGES-PLAN.md`; publish only after the complete page exists. |
| Final single-call and campaign deletion | `scripts/c15-contracts.mjs` and the matching C15 authored pages, checked against engine 9da04ec and dashboard e79c6d3. Keep bulk/account deletion separate. |
| Literal CLI formatting in the generated organisation CSV note | `scripts/build-c14-pages.mjs` applies the code spans after the established contract builders. Keep the reviewed OpenAPI description unchanged. |
| Shared visual style | `styles.css`; check both light and dark themes and a phone viewport |

Run `node scripts/build-docs.mjs` after edits. It rebuilds endpoint contracts, the C13 and C14 layers, the final C15 sources/navigation/metadata and the whole-site manifest. The frozen C8 test runner is not regenerated without test-change approval. Do not edit generated MDX alone or rerun one-time migration helpers from a handoff folder. Keep verified client examples when adding a newer HTTP capability; state the minimum supported client version clearly. Remove old command examples when the reviewed client no longer exposes them.

The current complete source check is `scripts/check-c15-source.mjs`. Historical tests and validators remain locked at live C16 `c271451`, with only the exact approved C17 tab-name edits recorded in `spec-source/c15-pages.json`. Earlier scope snapshots intentionally describe smaller page sets. Run historical checks separately and preserve their exact results; a new scope check does not silently rewrite or waive an old assertion. Any proposed locked-check change belongs in BEFORE-AFTER.md for approval.


## C15 maintenance precedence

`spec-source/c15-pages.json` owns the final five-tab navigation, short sidebar labels, metadata, permanent redirects and merged topic map. Its `sources` map identifies the final authored MDX for changed and new pages in `spec-source/c15-pages/` or `spec-source/c16-pages/` or `spec-source/c17-pages/`. Edit those sources first when present; otherwise use the earlier source table. `scripts/build-c15-pages.mjs` runs after earlier builders and removes the four consolidated duplicate files from publication. Preserve their redirected URLs and section anchors.

The final menu follows the approved feature groups, with an overview before task pages. Existing page URLs stay stable unless a true duplicate is consolidated. All old live URLs must either retain their useful page or redirect directly to its replacement. Do not create self-redirects or redirect chains.

The final logo is the green voice ring on its dark tile, with a lowercase Inter 600 wordmark and the flat small-size favicon. Keep both light and dark variants. Public copy may name Inworld, Cartesia and Deepgram when useful. Do not name internal model or backend providers. Customer-owned connection guides may identify services the customer connects.

C15’s independent current-scope gate is `scripts/check-c15-source.mjs`. Historical scope and contract assertions remain frozen at live C16 `c271451`, except for the six explicitly approved C17 tab-name assertion edits. Their normalized hashes are in the final source plan. Record any incompatible assertion and its proposed replacement in BEFORE-AFTER.md; never change a test simply to turn a result green.

## Published client setup

Use `npm install nixflex` for Node, `npm install -g nixflex` for the CLI, `pip install nixflex` for Python and `npx -y nixflex-mcp` for MCP. The documented minimum versions are Node/CLI 0.11.0, Python 0.4.0 and MCP 0.5.0. Keep keys in private client environment settings. Claude Desktop uses the npx configuration; do not promise a hosted desktop bundle. Preserve old fragment anchors while removing obsolete release-status prose. MCP 0.5.0 exposes 97 tools.


## C17 production-only publication

Every public example uses `https://api.nixflex.com` (`wss://api.nixflex.com` for WebSockets) and the single account credential variable `NIXFLEX_API_KEY`. Customers have one API environment. Keep test hosts, internal keys and deployment-choice wording out of published pages, snippets, OpenAPI and generated Markdown. MCP uses the fixed production address in its private configuration. Internal offline fixtures and historical evidence stay outside publication; never retarget a test runner to production.

The fifth tab is **Build with AI**. Its first page is **Build your app or SaaS with AI**, shared by Business and Developer readers, followed by connection guides and Tasks. The former Business build page redirects directly to the retained Developer URL. The two audience menus link to the shared guide instead of carrying bottom Build with AI groups.

C17 uses the live `c271451` locked baseline. Only the exact tab-name assertion changes recorded in `approvedC17LockedHashes` are authorised. All other locked checks remain byte-for-byte equivalent to that baseline. The full source gate rejects staging wording, Railway hosts and old account-key aliases in published pages and assets. Run it after the complete rebuild.
