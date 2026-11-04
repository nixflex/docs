// Narrow reviewed exceptions: client documentation URLs are not backend suppliers.
const clientDocs = new Map([
 ['ai-tools/chatgpt', [
  'https://developers.openai.com/api/docs/guides/secure-mcp-tunnels',
  'https://developers.openai.com/api/docs/guides/custom-mcp-server',
 ]],
]);
const carrierSetup = new Map([
 ['reference/faq', ['Twilio and Telnyx have supported setup paths. Use the instructions for your chosen carrier and number; do not assume every number has identical calling, messaging or verification requirements. See [phone number concepts](/concepts/phone-numbers).']],
 // D4: exact wire values/private variable names reviewed against K6 k6-private.js.
 ['ai-tools/overview', [
  '| `twilio` | `NIXFLEX_TWILIO_SID` and `NIXFLEX_TWILIO_TOKEN` |',
  '| `telnyx` | `NIXFLEX_TELNYX_API_KEY` and `NIXFLEX_TELNYX_CONNECTION_ID` |',
 ]],
 ['ai-tools/codex', [
  '```toml Current provider is twilio\nenv_vars = ["NIXFLEX_API_KEY", "NIXFLEX_BASE_URL", "NIXFLEX_TWILIO_SID", "NIXFLEX_TWILIO_TOKEN"]\n```',
  '```toml Current provider is telnyx\nenv_vars = ["NIXFLEX_API_KEY", "NIXFLEX_BASE_URL", "NIXFLEX_TELNYX_API_KEY", "NIXFLEX_TELNYX_CONNECTION_ID"]\n```',
 ]],
]);
export function supplierLeak(slug, text) {
 for (const url of clientDocs.get(slug) || []) text = text.replaceAll(']('+url+')', '](reviewed-client-documentation)');
 return /\b(?:openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq)\b/i.test(text);
}
export function unreviewedCarrierCopy(slug, text) {
 text = text.replaceAll('\r\n', '\n');
 for (const reviewed of carrierSetup.get(slug) || []) text = text.replace(reviewed, '');
 return /twilio|telnyx/i.test(text);
}
export function productionCanonical(slug, href) {
 const origin = 'https://docs.nixflex.com';
 return href === origin+'/'+slug || (slug === 'index' && [origin, origin+'/'].includes(href));
}
