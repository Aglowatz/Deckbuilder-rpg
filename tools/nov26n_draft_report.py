#!/usr/bin/env python3
"""Nov 26 night (Part B): aggregates the draft audit's raw files (docs/design/sim/nov26n/raw/*.json, written by tools/draft_audit.gd)
into tables: per card (offered, pick rate, decks holding it, their win rate, the change against decks of the same configs without it),
per Path set and mode, per equipment piece and item (offered, taken, the change with it). Prints Markdown; the hand-written
docs/design/sim/nov26n/draft_balance.md quotes it.
    python tools/nov26n_draft_report.py [--raw=docs/design/sim/nov26n/raw] [--min_decks=8] [--out=docs/design/sim/nov26n/draft_tables.md]
"""
import collections
import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def arg(name, fallback):
    for raw in sys.argv[1:]:
        if raw.startswith('--%s=' % name):
            return raw.split('=', 1)[1]
    return fallback


def card_names():
    names = {}
    for path in glob.glob(os.path.join(ROOT, 'data', 'cards', '*.tres')):
        text = io.open(path, encoding='utf-8').read()
        cid = re.search(r'^id = "(.*)"', text, re.M)
        name = re.search(r'^display_name = "(.*)"', text, re.M)
        rarity = re.search(r'^rarity = (\d)', text, re.M)
        if cid and name:
            names[cid.group(1)] = (name.group(1), 'CUEL'[int(rarity.group(1))] if rarity else 'C')
    return names


def gear_names():
    names = {}
    for path in glob.glob(os.path.join(ROOT, 'data', 'equipment', '**', '*.tres'), recursive=True):
        text = io.open(path, encoding='utf-8').read()
        gid = re.search(r'^id = "(.*)"', text, re.M)
        name = re.search(r'^source_name = "(.*)"', text, re.M)
        if gid:
            names[gid.group(1)] = name.group(1) if name else gid.group(1)
    for path in glob.glob(os.path.join(ROOT, 'data', 'items', '**', '*.tres'), recursive=True):
        text = io.open(path, encoding='utf-8').read()
        gid = re.search(r'^id = "(.*)"', text, re.M)
        name = re.search(r'^display_name = "(.*)"', text, re.M)
        if gid:
            names[gid.group(1)] = name.group(1) if name else gid.group(1)
    return names


def pct(w, g):
    return 100.0 * w / g if g else 0.0


def main():
    raw = os.path.join(ROOT, arg('raw', 'docs/design/sim/nov26n/raw'))
    min_decks = int(arg('min_decks', '8'))
    drafts = []
    for path in sorted(glob.glob(os.path.join(raw, '*.json'))):
        data = json.load(io.open(path, encoding='utf-8'))
        if data.get('override'):
            continue  # proposals are reported on their own
        for d in data['drafts']:
            d['_file'] = os.path.basename(path)
            drafts.append(d)
    cards = card_names()
    gear = gear_names()
    out = []
    total_games = sum(d['games'] for d in drafts)
    out.append('# Draft audit tables (Nov 26 night)')
    out.append('')
    out.append('%d drafts, %d fights (Mystery Mini: runs), from %d raw files. A "change" compares decks of the same configs with and without the card (or piece), weighted by games; a positive change means decks holding it won more often.' % (len(drafts), total_games, len(set(d['_file'] for d in drafts))))
    out.append('')
    # ---- by mode and Path set
    by_config = collections.OrderedDict()
    for d in drafts:
        key = (d['mode'], d['paths'])
        c = by_config.setdefault(key, [0, 0, 0, 0.0])
        c[0] += d['wins']
        c[1] += d['games']
        c[2] += 1
        c[3] += d.get('seconds', 0.0)
    out.append('## Win rates by mode and Path set')
    out.append('')
    out.append('| Mode | Paths | Drafts | Fights won | Win rate |')
    out.append('|---|---|---:|---:|---:|')
    for (mode, paths), c in sorted(by_config.items()):
        out.append('| %s | %s | %d | %d/%d | **%.0f %%** |' % (mode, paths.replace('+', ' + '), c[2], c[0], c[1], pct(c[0], c[1])))
    out.append('')
    # config-level win rate, for the with/without comparison
    config_rate = {k: (v[0], v[1]) for k, v in by_config.items()}

    def change(holding):
        """holding: a list of drafts that hold the thing. Weighted (by games) mean of (its win rate - the config's rate without it)."""
        per = collections.defaultdict(lambda: [0, 0])
        for d in holding:
            per[(d['mode'], d['paths'])][0] += d['wins']
            per[(d['mode'], d['paths'])][1] += d['games']
        total = 0.0
        weight = 0
        for key, (w, g) in per.items():
            cw, cg = config_rate[key]
            ow, og = cw - w, cg - g
            if og <= 0 or g <= 0:
                continue
            total += (pct(w, g) - pct(ow, og)) * g
            weight += g
        return total / weight if weight else 0.0

    # ---- cards
    offered = collections.Counter()
    picked = collections.Counter()
    holders = collections.defaultdict(list)
    for d in drafts:
        for p in d['picks']:
            if p['kind'] != 'card':
                continue
            for o in p['options']:
                offered[o] += 1
            if p['picked']:
                picked[p['picked']] += 1
        for cid in set(d['deck']):
            holders[cid].append(d)
    rows = []
    for cid in set(list(offered.keys()) + list(holders.keys())):
        h = holders.get(cid, [])
        w = sum(d['wins'] for d in h)
        g = sum(d['games'] for d in h)
        rows.append({'id': cid, 'name': cards.get(cid, (cid, '?'))[0], 'rarity': cards.get(cid, (cid, '?'))[1], 'offered': offered[cid], 'picked': picked[cid],
                     'pick_rate': pct(picked[cid], offered[cid]), 'decks': len(h), 'wins': w, 'games': g, 'rate': pct(w, g), 'change': change(h) if h else 0.0})
    big = [r for r in rows if r['decks'] >= min_decks]
    out.append('## Cards: the top 10 overperformers (held by %d+ decks)' % min_decks)
    out.append('')
    out.append('| Card | Rarity | Offered | Pick rate | Decks | Win rate with it | Change |')
    out.append('|---|---|---:|---:|---:|---:|---:|')
    for r in sorted(big, key=lambda r: -r['change'])[:15]:
        out.append('| %s (`%s`) | %s | %d | %.0f %% | %d | %.0f %% | **%+.1f** |' % (r['name'], r['id'], r['rarity'], r['offered'], r['pick_rate'], r['decks'], r['rate'], r['change']))
    out.append('')
    out.append('## Cards: the weakest (held by %d+ decks)' % min_decks)
    out.append('')
    out.append('| Card | Rarity | Offered | Pick rate | Decks | Win rate with it | Change |')
    out.append('|---|---|---:|---:|---:|---:|---:|')
    for r in sorted(big, key=lambda r: r['change'])[:15]:
        out.append('| %s (`%s`) | %s | %d | %.0f %% | %d | %.0f %% | **%+.1f** |' % (r['name'], r['id'], r['rarity'], r['offered'], r['pick_rate'], r['decks'], r['rate'], r['change']))
    out.append('')
    dead = [r for r in rows if r['offered'] >= 12]
    out.append('## Cards nobody takes (offered 12+ times, lowest pick rate)')
    out.append('')
    out.append('| Card | Rarity | Offered | Picked | Pick rate |')
    out.append('|---|---|---:|---:|---:|')
    for r in sorted(dead, key=lambda r: (r['pick_rate'], -r['offered']))[:15]:
        out.append('| %s (`%s`) | %s | %d | %d | %.0f %% |' % (r['name'], r['id'], r['rarity'], r['offered'], r['picked'], r['pick_rate']))
    out.append('')
    # ---- gear and items
    for kind, label in (('equipment', 'Equipment'), ('item', 'Items')):
        offered = collections.Counter()
        taken = collections.Counter()
        holders = collections.defaultdict(list)
        modes = collections.defaultdict(collections.Counter)
        for d in drafts:
            for p in d['picks']:
                if p['kind'] != kind:
                    continue
                for o in p['options']:
                    offered[o] += 1
                    modes[o][d['mode']] += 1
                if p['picked']:
                    taken[p['picked']] += 1
            for gid in set(d['equipment'] if kind == 'equipment' else d['items']):
                holders[gid].append(d)
        out.append('## %s in the draft pool' % label)
        out.append('')
        out.append('| Piece | Offered | Taken | Take rate | Drafts with it | Win rate with it | Change | Offered in |')
        out.append('|---|---:|---:|---:|---:|---:|---:|---|')
        for gid in sorted(offered, key=lambda g: -change(holders[g]) if len(holders[g]) >= 4 else 0):
            h = holders[gid]
            w = sum(d['wins'] for d in h)
            g = sum(d['games'] for d in h)
            where = ', '.join('%s %d' % (m, n) for m, n in modes[gid].most_common())
            out.append('| %s (`%s`) | %d | %d | %.0f %% | %d | %s | %s | %s |' % (gear.get(gid, gid), gid, offered[gid], taken[gid], pct(taken[gid], offered[gid]), len(h),
                                                                         '%.0f %%' % pct(w, g) if g else '-', '**%+.1f**' % change(h) if len(h) >= 4 else '(few)', where))
        out.append('')
    text = '\n'.join(out) + '\n'
    target = os.path.join(ROOT, arg('out', 'docs/design/sim/nov26n/draft_tables.md'))
    io.open(target, 'w', encoding='utf-8', newline='\n').write(text)
    print(text[:3000])


if __name__ == '__main__':
    main()
