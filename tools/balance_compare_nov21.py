"""Fable Nov 21 review (Part 3.1): the sims of Nov 21 beside the last pass, encounter by encounter.
   python tools/balance_compare_nov21.py            -> prints a markdown table per group (and writes docs/design/sim/nov21r/compare.md)
New numbers: docs/design/sim/nov21r/<group>.md (tools/sims_nov21r.sh). Last pass: the newest older table that holds the same encounter
(Nov 11 for the three later dungeons and their side dungeons, Nov 7 for the gatekeepers, Oct 30 for the House of Gains, Nov 1 for
the bosses that were not simulated again since). A fair deck is flagged when it wins more than 95 % or fewer than 35 %."""
import os, re, glob

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SIM = os.path.join(ROOT, 'docs', 'design', 'sim')
NEW = os.path.join(SIM, 'nov21r')
# group file -> older tables to look the same encounter up in, newest first
BASE = {
    'town': ['nov7/gatekeepers_after.md', 'bosses_nov1.md'],
    'dungeon_D-HOG': ['nov4b_cell_block_after.md', 'oct30_D-HOG.md', 'bosses_nov1.md'],
    'dungeon_D-HFA': ['nov11/after2_dungeon_D-HFA.md', 'bosses_nov1.md'],
    'dungeon_D-TTK': ['nov11/after2_dungeon_D-TTK.md', 'bosses_nov1.md'],
    'dungeon_D-ROT': ['nov11/after2_dungeon_D-ROT.md', 'bosses_nov1.md'],
    'dungeon_D-PC': ['bosses_nov1/tune3_s7100_D-PC.md', 'oct30_D-PC.md', 'bosses_nov1.md'],
    'postgame_D-LAB': ['bosses_nov1/tune3_s7100_D-LAB.md', 'oct30_lab.md', 'bosses_nov1.md'],
    'side_S-BEEF': ['oct29_S-BEEF.md', 'bosses_nov1.md'],
    'side_S-NECRO': ['nov11/after2_side_S-NECRO.md', 'bosses_nov1.md'],
    'side_S-GOUR': ['nov11/after2_side_S-GOUR.md', 'bosses_nov1.md'],
    'side_S-REF': ['nov11/after2_side_S-REF.md', 'bosses_nov1.md'],
    'arena': ['bosses_nov1/tune3_s7100_arena.md'],
}


def table(path):
    """title -> dict(kind, level, target, paths[4], all, turns, hp)"""
    rows = {}
    if not os.path.exists(path):
        return rows
    for line in open(path, encoding='utf-8'):
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if len(cells) >= 11 and re.fullmatch(r'\*\*\d+%\*\*', cells[8]):
            rows[cells[0]] = {'kind': cells[1], 'level': cells[2], 'target': cells[3], 'paths': cells[4:8], 'all': int(cells[8].strip('*%')),
                              'turns': cells[9], 'hp': cells[10], 'file': os.path.relpath(path, SIM).replace('\\', '/')}
        elif len(cells) == 7 and re.match(r'\*\*\d+%\*\*', cells[4]):  # bosses_nov1.md: Boss | L | Before | Setup | After | Turns | Change
            rows[cells[0]] = {'kind': 'Boss', 'level': cells[1], 'target': '', 'paths': ['-'] * 4, 'all': int(re.match(r'\*\*(\d+)%', cells[4]).group(1)),
                              'turns': cells[5], 'hp': '-', 'file': os.path.relpath(path, SIM).replace('\\', '/')}
    return rows


def key(title):
    return re.sub(r'[^a-z0-9]+', ' ', title.lower()).strip()


out = ['# The sims of Nov 21 beside the last pass', '',
       'Made by `python tools/balance_compare_nov21.py` from `docs/design/sim/nov21r/` (seed 7100, 8 games per Path and encounter; the Arena 20). '
       '"Last" is the newest older table that holds the same encounter. One game in 32 is 3 points, so read +/- 10 as noise. '
       '**Flag:** a fair deck above 95 % or below 35 %.', '']
flags = []
for group in ['town', 'dungeon_D-HOG', 'dungeon_D-HFA', 'dungeon_D-TTK', 'dungeon_D-ROT', 'dungeon_D-PC', 'postgame_D-LAB', 'side_S-BEEF', 'side_S-NECRO',
              'side_S-GOUR', 'side_S-REF', 'arena']:
    new = table(os.path.join(NEW, group + '.md'))
    if not new:
        continue
    olds = [table(os.path.join(SIM, f)) for f in BASE.get(group, [])]
    out.append('## %s' % group.replace('_', ': ', 1))
    out.append('')
    out.append('| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |')
    out.append('|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|')
    for title, row in new.items():
        last = None
        for old in olds:
            for old_title, old_row in old.items():
                if key(old_title) == key(title) or key(old_title).endswith(key(title)) or key(title).endswith(key(old_title)):
                    last = old_row
                    break
            if last:
                break
        flag = ''
        lows = [int(p.strip('%')) for p in row['paths'] if p.strip('%').isdigit()]
        if row['all'] > 95:
            flag = 'above 95 %'
        elif row['all'] < 35:
            flag = 'below 35 %'
        elif lows and min(lows) < 35:
            flag = 'one Path below 35 %'
        if flag:
            flags.append('%s: %s (%d%%; %s)' % (group, title, row['all'], ' / '.join(row['paths'])))
        out.append('| %s | %s | %s | %s | %s | **%d%%** | %s | %s | %s | %s | %s |' % (
            title, row['kind'], row['level'], row['target'], ' | '.join(row['paths']), row['all'],
            ('%d%% (%s)' % (last['all'], last['file'].split('/')[-1].replace('.md', ''))) if last else '-',
            ('%+d' % (row['all'] - last['all'])) if last else '-', row['turns'], row['hp'], flag))
    out.append('')
out.append('## Flagged (%d)' % len(flags))
out.append('')
out.extend('- ' + f for f in flags)
text = '\n'.join(out) + '\n'
os.makedirs(NEW, exist_ok=True)
open(os.path.join(NEW, 'compare.md'), 'w', encoding='utf-8', newline='\n').write(text)
print(text)
