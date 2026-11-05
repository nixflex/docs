# Nixflex documentation style guide — v1

Locked by Fahim on 5 November 2026. Applies to every new page and every future page update. The visual reference is `docs-design-v1.html` in the shared `notes/docs-design` folder. This file is the permanent authoring standard; page templates are in `templates/`. The reference fixes the design, not the truth of its illustrative API examples, timings, prices or delivery promises.

## One feature, two audiences

| Audience | Start with | Include | Leave to the other audience |
| --- | --- | --- | --- |
| Business guide | What the person can do and the important limit | Plain steps using real dashboard labels; a short conversation or flow when useful; status meanings and what to do | HTTP fields, SDK setup, implementation history and internal test names |
| Developer guide | The app behavior to build | The same feature and limits, prerequisites, complete code, result handling, errors, retry rules and endpoint links | Repeating a dashboard walkthrough line by line |
| API reference | The exact action and object | Authentication, request/response contract, a minimal valid example, errors with recovery and write/replay limits | A full multi-feature tutorial |
| Webhook event | What causes this event and what it proves | Payload, timing, signature, duplicate identity, durable acceptance, examples and failure handling | Presenting the event as a callable API endpoint |

Every Business page links to its Developer counterpart; every Developer page links back. An API page links to the relevant Business and Developer guides. Several endpoints may share the same feature guide: do not turn a Business page into a list of every endpoint. Pair by task, not by matching filenames. Use the nearest existing guide until a planned counterpart is written; never publish a broken link or an empty future page. Maintain the pairing map with the source plan. Chat D owns Business and AI pages; Chat C owns API, Developer and client pages.

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

Titles must be unique and at most 60 characters. Put the main task or feature early. Do not lead with a method, long URL, “How to”, “Everything about”, or “Nixflex” on every page. A sidebar label should normally be two to five words and at most 36 characters; retain enough context to distinguish siblings. HTTP method badges provide method context where supported. Use sentence case and British English in prose; never change wire names, code or product labels to match spelling preferences.

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

**Navigation must look full.** Keep all five tabs in the locked order. Top-level groups are visible; set `expanded: true` on every nested group. Prefer shallow groups with short labels. All entries must be available without opening collapsed topic groups. A long tab naturally scrolls; do not shrink text to force 162 links into one viewport. On phones, the menu may use a drawer, but its topic groups still start expanded. Mintlify documents this behavior in [Navigation](https://www.mintlify.com/docs/organize/navigation).

## Examples and accurate claims

Use a short conversation, flow boxes, a status table or code tabs before considering a screenshot. A screenshot is essential only when a person needs to recognise an otherwise confusing control or visual state. Crop to that decision, add useful alt text and record its source/version. No decorative screenshots, placeholder product captures or text baked into images. Existing unrelated screenshots are not permission to add more.

A conversation must show each required approval. For bookings, a name confirmation and email confirmation are separate; do not skip the customer's “yes” and then claim a successful booking. Claim a booking or notification request only after a confirmed result, and never promise inbox delivery. Use fictional contacts and reserved example domains. Do not put real credentials, live customer data, internal fixtures or protected numbers in examples.

Examples must match the merged contract and actual client version. Prefer complete, minimal HTTP examples when client support is not verified. Identify candidate client packages honestly. Never copy a constructor or method from the visual mockup as proof that an SDK exposes it. A read example should be safe and useful; a write example must name its effect, ownership requirement and uncertainty/retry boundary. Never retry an unknown call launch with a new request ID automatically.

Every error row must answer “what should my app or user do next?” Match status and machine code to source. Differentiate read retry, correcting input, permission changes, reconciliation, waiting, and contacting support. Do not suggest an account-key workaround for a role restriction. Do not document voice cloning while it is being removed.

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

Mintlify generates page metadata, social images and structured data from configuration/frontmatter; inspect the installed and hosted output rather than assuming a new hosted feature exists in an older local CLI. Prefer its native page-specific share image and unique description; do not replace every page with one generic image. Check JSON-LD against visible facts and avoid duplicate custom markup or invented FAQ/review/rating data. [Mintlify SEO](https://www.mintlify.com/docs/optimize/seo) and [Markdown export](https://www.mintlify.com/docs/ai/markdown-export) describe these facilities.

`llms.txt` and Markdown copies help tools consume the docs; they do not guarantee inclusion in Google or an AI answer. Google's AI search guidance requires the same useful, crawlable content as ordinary search and no special AI schema. Keep technical access, textual content and honest claims as the priority. [Google AI features](https://developers.google.com/search/docs/appearance/ai-features) and [title guidance](https://developers.google.com/search/docs/appearance/title-link).

## Authoring and review workflow

1. Identify the audience, task, source commit, page pair and feature cluster. Read this guide and the matching template.
2. Edit authoritative source data/builders for generated pages, then regenerate; do not rely on hand edits that the next build overwrites.
3. Check contract accuracy, examples, code syntax, unique bounded metadata, links, glossary wording, all expanded groups and a phone view.
4. Run the full local gate. Preserve failed and pending evidence. Existing locked tests need explicit approval for any further change; adding a feature does not silently waive this rule.
5. Open a reviewed private preview through the operator workflow. A preview URL is public unless authentication or password protection is actually enabled; never call an unlisted URL private. No main merge or production publication is part of C13.

C13 applies this standard to the whole API tab and exactly five Developer samples: `/quickstart`, `/actions/booking-confirmation`, `/actions/google-calendar`, `/guides/developer/call-history`, `/advanced/webhooks`. Those four booking-related guides demonstrate a feature across overview/approval, setup, result reads and webhook processing. Other Developer pages are round 2. Chat D applies the same guide to its owned pages; Chat C does not overwrite their content.

## Where to edit the C13 sources

| Change | Authoritative source |
| --- | --- |
| API title, sidebar label, description, lead, key points or audience pair | `spec-source/c13-pages.json`; keep the navigation/title plan in `spec-source/c9-pages.json` aligned |
| Existing endpoint fields, limits, examples and errors | The relevant C4/C5/C6/C8 source JSON or `spec-source/c9-manual-pages.json`; the established contract builders run first |
| B56 schema and request-state semantics | `scripts/c13-contracts.mjs`, checked against the pinned engine commit |
| API concept/event prose | The matching `.mdx.txt` file in `spec-source/c13-concepts/`; `scripts/build-c13-pages.mjs` supplies the shared layout and B56 cross-links |
| One of the five Developer samples | The matching `.mdx.txt` file in `spec-source/c13-developer/` |
| Shared visual style | `styles.css`; check both light and dark themes and a phone viewport |

Run `node scripts/build-docs.mjs` after edits. It rebuilds endpoint contracts, then the C13 editorial layer and the whole-site manifest. Do not edit generated MDX alone or rerun one-time migration helpers from a handoff folder. Keep verified legacy client examples when adding a newer HTTP capability; label their actual support and version clearly. The permanent source check is `scripts/check-c13-source.mjs`; the old locked gates still run separately and their failures remain visible.
