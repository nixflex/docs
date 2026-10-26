# MCP install run 1 documentation draft

26 October 2026; branch `codex/mcp-install-foundation-docs`. Not published.
Updated MCP overview and CLI setup/storage descriptions only. API schemas and
tool contracts are unchanged. Drafts identify versions 0.3.1 / 0.9.1 as local
candidates, remove the misleading “key stays local” and env-block-storage claims,
document destination binding and safe config refusal, retire VS Code and retain
ChatGPT “coming soon” until hosted OAuth after launch.

Claude Desktop bundle remains run 2. Secure key setup, Cursor button and per-tool
installs remain run 3. Chat B owns dashboard buttons; no dashboard files changed.
Both Windows and Mac are first-class launch targets. Automated Mac workflow and
manual Mac results are not claimed complete merely because tests were authored.

Validation: `node --test tests/*.test.mjs` — existing docs/API checks plus the new
MCP installation-truthfulness check. The full implementation report is FOUNDATION.md
in the nixflex-mcp feature branch. Do not publish these drafts as a released npm
installation flow until the publication and cross-platform gates are met.
