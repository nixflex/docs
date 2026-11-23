"""Refresh the API directory from the selected release pages, after the normal docs build."""
from pathlib import Path
import json
import re
import sys

root = Path(__file__).resolve().parents[2]
def slugs(group):
    if isinstance(group, str):
        yield group
    elif isinstance(group, list):
        for child in group:
            yield from slugs(child)
    else:
        for key in ('groups', 'pages'):
            yield from slugs(group.get(key, []))

site=json.loads((root/'docs.json').read_text(encoding='utf-8'))
groups=next(tab['groups'] for tab in site['navigation']['tabs'] if tab['tab']=='API reference')
dest=root/'api-reference/introduction.mdx'
original=dest.read_text(encoding='utf-8')
heading='## Find an API operation'
assert original.count(heading)==1 and original.rstrip().endswith('</AccordionGroup>')
sections=[]
count=0
for group in groups:
    rows=[]
    for slug in slugs(group):
        md=(root/(slug+'.mdx')).read_text(encoding='utf-8')
        match=re.search(r'^openapi: "/api-reference/public\.openapi\.json ([^"]+)"$',md,re.M)
        if match:
            title=json.loads(re.search(r'^title: (".*")$',md,re.M)[1])
            rows.append('| ['+title+'](/'+slug+') | '+chr(96)+match[1]+chr(96)+' |')
    if rows:
        count+=len(rows)
        sections.append('<Accordion title='+json.dumps(group['group']+' ('+str(len(rows))+')',ensure_ascii=False)+'>\n\n| Task | Method and path |\n| --- | --- |\n'+'\n'.join(rows)+'\n\n</Accordion>')
new=original.split(heading)[0]+heading+'\n\nChoose a resource below for its request fields, responses and recovery steps.\n\n<AccordionGroup>\n\n'+'\n\n'.join(sections)+'\n\n</AccordionGroup>\n'
if sys.argv[1:]==['--write']:
    if new!=original: dest.write_bytes(new.encode('utf-8'))
elif sys.argv[1:]==['--check']:
    if new!=original: sys.exit('Directory needs refreshing')
else:
    sys.exit('Choose --write or --check')
print('Directory bindings:',count)
