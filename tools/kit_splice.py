"""Splice new zone-kit items into HEAD's registry text (the importer rewrites the whole JSON with float churn).
Usage: python tools/kit_splice.py <zone> ID [ID ...]
Takes the named items from the working-tree data/art/zone_kits/<zone>.json (as the importer just wrote them) and writes HEAD's text with
only those items added or replaced, in HEAD's tab-indented style. Import Nov 8."""
import json
import subprocess
import sys

zone, ids = sys.argv[1], sys.argv[2:]
path = 'data/art/zone_kits/%s.json' % zone
new = json.load(open(path, encoding='utf-8'))
head_text = subprocess.run(['git', 'show', 'HEAD:' + path], capture_output=True, check=True).stdout.decode('utf-8')
head = json.loads(head_text)
for item_id in ids:
    if item_id not in new['items']:
        sys.exit('kit_splice: %s not in the new registry' % item_id)
    head['items'][item_id] = new['items'][item_id]
head['items'] = dict(sorted(head['items'].items()))
text = json.dumps(head, indent='\t', ensure_ascii=False, sort_keys=False)
open(path, 'w', encoding='utf-8', newline='\n').write(text + ('\n' if head_text.endswith('\n') else ''))
print('kit_splice: %s + %s' % (path, ', '.join(ids)))
