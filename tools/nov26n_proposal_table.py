#!/usr/bin/env python3
"""Nov 26 night (Part B): the proposal sims side by side (docs/design/sim/nov26n/proposals/<name>_base.json and _proposal.json)."""
import glob, io, json, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
P = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov26n', 'proposals')
rows = ['| Proposal | Configs | Before (same seeds) | After | Change | Decks holding the card, before -> after |', '|---|---|---:|---:|---:|---|']
CARD = {'raccoon': 'R-27', 'mmz': 'N-23', 'escoffina': 'G-33', 'engarde': 'G-23'}
for base in sorted(glob.glob(os.path.join(P, '*_base.json'))):
    name = os.path.basename(base)[:-10]
    prop = base.replace('_base.json', '_proposal.json')
    if not os.path.exists(prop):
        continue
    a = json.load(io.open(base, encoding='utf-8'))['drafts']
    b = json.load(io.open(prop, encoding='utf-8'))['drafts']
    wa, ga = sum(d['wins'] for d in a), sum(d['games'] for d in a)
    wb, gb = sum(d['wins'] for d in b), sum(d['games'] for d in b)
    cid = CARD.get(name, '')
    ha = sum(1 for d in a if cid in d['deck'])
    hb = sum(1 for d in b if cid in d['deck'])
    configs = ', '.join(sorted(set(d['config'] for d in a)))
    rows.append('| %s | %s | %.0f %% (%d/%d) | %.0f %% (%d/%d) | **%+.0f** | %d -> %d of %d |' % (name, configs, 100.0 * wa / ga, wa, ga, 100.0 * wb / gb, wb, gb, 100.0 * (wb / gb - wa / ga), ha, hb, len(a)))
text = '\n'.join(rows) + '\n'
io.open(os.path.join(P, 'proposals.md'), 'w', encoding='utf-8', newline='\n').write('# Part B proposals, simulated (same configs and draft seeds, with and without the change; sim only)\n\n' + text)
print(text)
