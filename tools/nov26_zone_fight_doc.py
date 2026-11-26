"""Nov 26 day (Part C): writes docs/design/zone_fight_rules.md - every zone dungeon fight with its rules and its win rate before and
after today, from docs/design/sim/nov26/zone_fight_rules.json (tools/nov26_zone_fight_rules.py), zone_runs.md (tools/zone_runs_nov26_tool.gd)
and castle_runs_<label>.md (tools/castle_runs_nov21_tool.gd).    python tools/nov26_zone_fight_doc.py [after-label]"""
import io
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SIM = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov26')
OUT = os.path.join(ROOT, 'docs', 'design', 'zone_fight_rules.md')
NAMES = {'D-HOG': 'The House of Gains', 'D-TTK': 'The Test Kitchen', 'D-HFA': 'The Hall of Final Approvals', 'D-ROT': 'The Rotheart', 'D-PC': "Primm's Castle"}


def load(path):
    return json.load(io.open(path, encoding='utf-8'))


def zone_rows(label):
    """dungeon -> {'runs','cleared','fights': {foe: [won, reached]}} summed over the routes run under `label`."""
    result = {}
    path = os.path.join(SIM, 'zone_runs.md')
    if not os.path.exists(path):
        return result
    for line in io.open(path, encoding='utf-8'):
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if len(cells) < 10 or cells[3] != label or not cells[0].startswith('D-'):
            continue
        entry = result.setdefault(cells[0], {'runs': 0, 'cleared': 0.0, 'fights': {}, 'routes': {}})
        runs = int(cells[4])
        pct = float(cells[5].strip('*').rstrip('%'))
        entry['runs'] += runs
        entry['cleared'] += pct * runs / 100.0
        entry['routes'][cells[1]] = pct
        for part in cells[8].split(';'):
            m = re.match(r'\s*(.+?) (\d+)/(\d+)\s*$', part)
            if m:
                won, seen = entry['fights'].setdefault(m.group(1), [0, 0])
                entry['fights'][m.group(1)] = [won + int(m.group(2)), seen + int(m.group(3))]
    return result


def castle_rows(label):
    path = os.path.join(SIM, 'castle_runs_%s.md' % label)
    rows = {}
    if not os.path.exists(path):
        return rows
    for line in io.open(path, encoding='utf-8'):
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if len(cells) >= 8 and re.match(r'^[A-E]:', cells[0]):
            rows[cells[0][0]] = (cells[4], cells[5].strip('*'))
    return rows


def pct(pair):
    return '%d %%' % round(100.0 * pair[0] / pair[1]) if pair and pair[1] else '-'


def main():
    after = sys.argv[1] if len(sys.argv) > 1 else 'after'
    rules = load(os.path.join(SIM, 'zone_fight_rules.json'))
    before_z = zone_rows('before')
    after_z = zone_rows(after)
    out = ['# Zone dungeon fights: a rule set for every fight (Nov 26 day, Part C)', '',
           'Every fight of the four zones\' main dungeons and Primm\'s Castle now has rules of its own; the postgame is unchanged (the owner). '
           'Before today only the elites and bosses had rules. Each ordinary fight got a rule that questions how the deck was built and '
           'something the player can use; the elites and bosses keep their sets. Written by `tools/nov26_zone_fight_rules.py` (data) and '
           '`tools/nov26_zone_fight_doc.py` (this page). Test: `tests/test_nov26_zone_fight_rules.gd`.', '',
           '**Win rates** are the sims\' whole runs (`tools/zone_runs_nov26_tool.gd`, `tools/run_nov26_zone_sims.sh`): one HP pool along '
           'each route, each Path\'s reference deck, gear and items at the boss\'s level, played by the planning AI, 25 runs per Path and '
           'route. Per fight: won of the times it was reached, both routes together. The sim\'s player is weaker than a careful human '
           '(it plays its items plainly and takes no event boons), so the absolute numbers are low; the comparison is what matters.', '']
    out += ['## Whole runs', '', '| Dungeon | Route | Cleared before | Cleared after |', '|---|---|---:|---:|']
    for dungeon in ['D-HOG', 'D-TTK', 'D-HFA', 'D-ROT']:
        b = before_z.get(dungeon, {}).get('routes', {})
        a = after_z.get(dungeon, {}).get('routes', {})
        for route in sorted(set(b) | set(a)):
            out.append('| %s | %s | %s | %s |' % (NAMES[dungeon], route, ('%d %%' % b[route]) if route in b else '-', ('%d %%' % a[route]) if route in a else '-'))
    cb = castle_rows('before')
    ca = castle_rows(after)
    for route in sorted(set(cb) | set(ca)):
        out.append('| %s | %s (beat Primm) | %s | %s |' % (NAMES['D-PC'], route, cb.get(route, ('', '-'))[1], ca.get(route, ('', '-'))[1]))
    out.append('')
    for dungeon in ['D-HOG', 'D-TTK', 'D-HFA', 'D-ROT', 'D-PC']:
        out += ['## %s' % NAMES[dungeon], '', '| Room | Foe | Rules (new in bold) | Scripted beats (new in bold) | The idea | Won before | Won after |', '|---:|---|---|---|---|---:|---:|']
        for row in sorted([r for r in rules if r['dungeon'] == dungeon], key=lambda r: r['room']):
            short = row['foe'].split(',')[0]
            fb = before_z.get(dungeon, {}).get('fights', {}).get(short)
            fa = after_z.get(dungeon, {}).get('fights', {}).get(short)
            rules_text = '<br>'.join(row['rules_before'] + ['**%s**' % r for r in row['rules_added']])
            events_text = '<br>'.join(row['events_before'] + ['**%s**' % e for e in row['events_added']]) or '-'
            out.append('| %d | %s | %s | %s | %s | %s | %s |' % (row['room'], row['foe'], rules_text, events_text, row['idea'], pct(fb), pct(fa)))
        unchanged = [(foe, v) for foe, v in after_z.get(dungeon, {}).get('fights', {}).items() if foe not in [r['foe'].split(',')[0] for r in rules if r['dungeon'] == dungeon]]
        if unchanged:
            out += ['', 'Elites and bosses whose sets are unchanged (win rates move with the HP the run brings them): ' + '; '.join(
                '%s %s -> %s' % (foe, pct(before_z.get(dungeon, {}).get('fights', {}).get(foe)), pct(v)) for foe, v in unchanged)]
        out.append('')
    io.open(OUT, 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
    print('wrote', OUT)


if __name__ == '__main__':
    main()
