"""Offline DOC4 checks. Run against the composed docs root after applying the patches."""
import json
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
read = lambda path: (root / path).read_text(encoding='utf-8')
spec = json.loads(read('api-reference/public.openapi.json'))
nav = json.loads(read('docs.json'))['navigation']['tabs']
def slugs(node):
    if isinstance(node, str):
        yield node
    elif isinstance(node, list):
        for child in node:
            yield from slugs(child)
    elif isinstance(node, dict):
        for key in ('groups','pages'):
            yield from slugs(node.get(key, []))
pages = list(slugs(nav))
def page(slug):
    assert pages.count(slug) == 1, slug + ' must occur exactly once in published navigation'
    return read(slug + '.mdx')
def schema_ok(value, schema):
    if '$ref' in schema:
        return schema_ok(value, spec['components']['schemas'][schema['$ref'].split('/')[-1]])
    if 'anyOf' in schema or 'oneOf' in schema:
        matches = 0
        for alternative in schema.get('anyOf',schema.get('oneOf',[])):
            try:
                schema_ok(value, alternative)
                matches += 1
            except AssertionError:
                pass
        assert matches == 1 if 'oneOf' in schema else matches > 0
        return
    if 'const' in schema: assert value == schema['const']
    if 'enum' in schema: assert value in schema['enum']
    kind = schema.get('type')
    types = {'object':dict,'array':list,'string':str,'integer':int,'null':type(None),'boolean':bool}
    if kind: assert isinstance(value, types[kind]), (kind, value)
    if isinstance(value, dict):
        props = schema.get('properties', {})
        assert all(k in value for k in schema.get('required', []))
        if schema.get('additionalProperties') is False: assert value.keys() <= props.keys()
        for k in value.keys() & props.keys(): schema_ok(value[k], props[k])
    elif isinstance(value, list):
        for item in value: schema_ok(item, schema['items'])
    elif isinstance(value, str):
        assert schema.get('minLength',0) <= len(value) <= schema.get('maxLength',len(value))
        if 'pattern' in schema: assert re.fullmatch(schema['pattern'],value)
        if schema.get('format')=='uuid': assert re.fullmatch(r'[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}',value)
        if schema.get('format')=='date-time':
            from datetime import datetime
            assert datetime.fromisoformat(value.replace('Z','+00:00')).tzinfo
    elif isinstance(value, int):
        assert schema.get('minimum',value) <= value <= schema.get('maximum',value)
def bindings(slug):
    text=page(slug)
    method,path = re.search(r'^openapi: "/api-reference/public.openapi.json ([A-Z]+) ([^"]+)"',text,re.M).groups()
    return text,spec['paths'][path][method.lower()]
def zones():
    txt=page('actions/calcom')
    assert 'Use separate agents for independent Cal.com time zones' not in txt
    assert 'calcom_timezone_override' in txt and 'read-back' in txt
    _,op=bindings('api-reference/phone-numbers/update')
    assert 'calcom_timezone_override' in op['requestBody']['content']['application/json']['schema']['oneOf'][0]['properties']
    _,op=bindings('api-reference/integration-settings/get-integrations-calcom-number-phoneNumber')
    props=op['responses']['200']['content']['application/json']['schema']['properties']
    assert {'booking_available','calcom_timezone_override','effective_calcom_timezone','effective_calcom_timezone_source'} <= props.keys()
def campaigns():
    for slug in ['voice-campaigns/get-campaigns','sms/campaigns-list','contact-controls/get-contact-suppressions']:
        text,op=bindings('api-reference/'+slug)
        assert '%2B' in text and 'invalid_business_number' in text
        assert any(p['name']=='business_number' for p in op['parameters'])
    assert '50%' in page('guides/business/voice-campaigns/check-results')
    assert 'off by default' in page('guides/business/contact-controls')
    txt,op=bindings('api-reference/contact-controls/correct-ai-opt-out')
    body=json.loads(re.search(r"-d '(.+)'",txt)[1])
    schema_ok(body,op['requestBody']['content']['application/json']['schema'])
    for code in ['review_changed','suppression_locked','outcome_unknown','permission_denied']: assert code in txt
def support():
    for slug in ['create','list','get','reply','solve','receipt']:
        text,op=bindings('api-reference/support/'+slug)
        data=json.loads(re.findall(r'~~~json\n(.*?)\n~~~',text.replace(chr(96)*3,'~~~'),re.S)[0])
        schema_ok(data,op['responses']['201' if slug=='create' else '200']['content']['application/json']['schema'])
        if 'requestBody' in op:
            body=json.loads(re.search(r"-d '(.+)'",text)[1])
            schema_ok(body,op['requestBody']['content']['application/json']['schema'])
            assert 'Idempotency-Key' in text
        for forbidden in ['contact_email','contact_marker','staff_notes']: assert forbidden not in data
    assert 'X-Nixflex-Expected-Account' in page('api-reference/support/receipt')
    assert 'account_changed' in page('guides/developer/support-tickets')
    assert all(s in page('guides/business/support-tickets') for s in ['Increase my simultaneous call limit','Complaint or problem','Report abuse','Other','Account → Help'])
def navigation():
    assert len(set(pages))==len(pages)
    for slug in pages: assert (root/(slug+'.mdx')).is_file(),slug
    print('Visible navigation destinations:',len(pages))
checks={'DOC4-B-ZONE':zones,'DOC4-C-CONTACT':campaigns,'DOC4-S-RECEIPTS':support,'DOC4-NAV':navigation}
failed=[]
for name, fn in checks.items():
    try:
        fn()
        print('PASS',name)
    except (AssertionError, KeyError, IndexError, TypeError, FileNotFoundError) as error:
        print('FAIL',name,repr(error))
        failed.append(name)
if '--before' in sys.argv:
    assert failed==list(checks)[:3],failed
else:
    sys.exit(bool(failed))
