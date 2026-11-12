// Public documentation has one API service. Internal fixtures are not inputs.
export function productionOnly(text) {
 return !/staging|railway\.app|NXF_STAGING|\bNXF_API_KEY\b/i.test(text);
}
