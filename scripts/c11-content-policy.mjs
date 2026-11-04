// Narrow reviewed exceptions: client documentation URLs are not backend suppliers.
const clientDocs = new Map([
 ['ai-tools/chatgpt', [
  'https://developers.openai.com/api/docs/guides/secure-mcp-tunnels',
  'https://developers.openai.com/api/docs/guides/custom-mcp-server',
 ]],
]);
const carrierSetup = new Map([
 ['reference/faq', 'Twilio and Telnyx have supported setup paths. Use the instructions for your chosen carrier and number; do not assume every number has identical calling, messaging or verification requirements. See [phone number concepts](/concepts/phone-numbers).'],
]);
export function supplierLeak(slug, text) {
 for (const url of clientDocs.get(slug) || []) text = text.replaceAll(']('+url+')', '](reviewed-client-documentation)');
 return /\b(?:openai|anthropic|deepgram|inworld|elevenlabs|supabase|groq)\b/i.test(text);
}
export function unreviewedCarrierCopy(slug, text) {
 const reviewed = carrierSetup.get(slug);
 return /twilio|telnyx/i.test(reviewed ? text.replace(reviewed, '') : text);
}
export function productionCanonical(slug, href) {
 const origin = 'https://docs.nixflex.com';
 return href === origin+'/'+slug || (slug === 'index' && [origin, origin+'/'].includes(href));
}
