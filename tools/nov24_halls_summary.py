"""Fable Nov 24: one table of the Shuffled Halls from the batched sims of docs/design/sim/nov24 (halls_rooms_*<tag>.md of two
draft seeds, halls_runs_*<tag>.md): each room's dealer, Paths, HP, win rate by the player's Paths and overall, and the routes.
    python tools/nov24_halls_summary.py [tag=_v4] [second tag=_v4s1]     -> docs/design/sim/nov24/halls_summary.md"""
import io
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SIM = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov24')
GROUPS = ['tables_a', 'tables_b', 'trey', 'dex', 'octavia']
ROUTES = ['careful', 'middle', 'champions', 'greedy']
SETS = ['Beefcake', 'Gourmand', 'Necrocrat', 'Refusemancer', 'Beefcake + Necrocrat', 'Gourmand + Refusemancer']


def rows(path):
    if not os.path.exists(path):
        return []
    with io.open(path, encoding='utf-8') as handle:
        return [[cell.strip() for cell in line.strip().strip('|').split('|')] for line in handle if re.match(r'^\| (\d+|\*\*)', line)]


def main():
    tags = sys.argv[1:] or ['_v4', '_v4s1']
    rooms = {}
    games_each = 0
    for tag in tags:
        for group in GROUPS:
            for row in rows(os.path.join(SIM, 'halls_rooms_%s%s.md' % (group, tag))):
                number = int(row[0])
                entry = rooms.setdefault(number, {'dealer': row[1], 'paths': row[2], 'hp': row[3], 'play': row[4], 'rates': [[] for _ in SETS], 'left': []})
                for index in range(len(SETS)):
                    entry['rates'][index].append(int(row[5 + index].rstrip('%')))
                games = int(re.search(r'\((\d+)\)', row[11]).group(1))
                games_each = games // len(SETS)
                entry['left'].append(float(row[12].split(' ')[0]))
    lines = ['# The Shuffled Halls: every room and every route (Fable Nov 24)', '',
        'From the batched sims of this folder (`bash tools/run_halls_sims.sh`, tags %s): a sensible drafter at level 16 (base HP 23), %d drafts for each of six Path sets, %d games a draft and room. '
        'A room is measured **at full HP**; a run carries its HP from room to room, which is why the routes below are far harder than their rooms.' % (', '.join('`%s`' % tag for tag in tags), len(tags), games_each), '',
        '| Room | Dealer | Dealer\'s Paths | HP | Plays | ' + ' | '.join(SETS) + ' | All | HP left after a win |', '|---|---|---|---:|---|' + '---:|' * (len(SETS) + 2)]
    for number in sorted(rooms):
        entry = rooms[number]
        rates = [sum(values) / float(len(values)) for values in entry['rates']]
        total = sum(rates) / len(rates)
        lines.append('| %d | %s | %s | %s | %s | %s | **%d%%** | %.0f of 23 |' % (number, entry['dealer'], entry['paths'], entry['hp'], entry['play'], ' | '.join('%d%%' % round(rate) for rate in rates), round(total), sum(entry['left']) / len(entry['left'])))
    lines += ['', '## Whole runs', '', '| Route | ' + ' | '.join(SETS) + ' | All | Where the runs ended |', '|---|' + '---:|' * (len(SETS) + 1) + '---|']
    for route in ROUTES:
        for row in rows(os.path.join(SIM, 'halls_runs_%s%s.md' % (route, tags[0]))):
            lines.append('| %s |' % ' | '.join(row))
    lines += ['', 'The pick of three after each fight is not modelled, so a real run is a little easier than its number here. Cashing out at the Counting Halls is open to every run that reaches room 18.']
    with io.open(os.path.join(SIM, 'halls_summary.md'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('\n'.join(lines) + '\n')
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
