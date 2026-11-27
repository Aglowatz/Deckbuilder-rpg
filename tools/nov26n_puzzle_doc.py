#!/usr/bin/env python3
"""Nov 26 night (Part A2): writes docs/design/arena_deck_puzzles.md from data/arena/deck_puzzles.json (the puzzles and their sim
decks), data/encounters/modifiers.json + encounter_scripts.json (the rules), docs/design/sim/nov26n/puzzles_final_<id>.md (the win
rates) and data/arena/deck_puzzle_lines.json (one recorded winning line each).
    python tools/nov26n_puzzle_doc.py [--label=final]
"""
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
        if cid and name:
            names[cid.group(1)] = name.group(1)
    for letter, path in (('B', 'Beefcake'), ('G', 'Gourmand'), ('R', 'Refusemancer'), ('N', 'Necrocrat'), ('C', 'Pathless')):
        names['BAS-%s' % letter] = 'basic %s Infrastructure' % path
    return names


def main():
    label = arg('label', 'final')
    puzzles = json.load(io.open(os.path.join(ROOT, 'data', 'arena', 'deck_puzzles.json'), encoding='utf-8'))['puzzles']
    mods = json.load(io.open(os.path.join(ROOT, 'data', 'encounters', 'modifiers.json'), encoding='utf-8'))
    scripts = json.load(io.open(os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json'), encoding='utf-8'))
    lines_path = os.path.join(ROOT, 'data', 'arena', 'deck_puzzle_lines.json')
    lines = json.load(io.open(lines_path, encoding='utf-8'))['lines'] if os.path.exists(lines_path) else {}
    names = card_names()
    out = []
    out.append('# Octavia\'s deck-building puzzles (the Shuffle House\'s Puzzle Tables)')
    out.append('')
    out.append('Nov 26 night, Part A2 (brief `docs/prompts/opus_nov26_night_v2.md`). Five harder puzzles, one in each level of the arena quest line, '
               'presented by Octavia Eightfold at a new door of the Shuffle House\'s menu, **Puzzle Tables**. Code: `core/arena/deck_puzzles.gd`; data: '
               '`data/arena/deck_puzzles.json` (written by `tools/nov26n_deck_puzzles.py`, which also writes each puzzle\'s rules to '
               '`data/encounters/modifiers.json` and `encounter_scripts.json` under `arena:<id>`); sims: `tools/deck_puzzle_sim.gd` '
               '(`bash tools/run_deck_puzzle_sims.sh`); test: `tests/test_nov26n_deck_puzzles.gd`.')
    out.append('')
    out.append('## The rules of every puzzle')
    out.append('')
    out.append('- **The opponent plays no cards.** Its deck is 60 basic Infrastructure, so its draws never matter; everything it does comes from its '
               'house rules and timed moments, listed in full in its "Before the fight" panel. Its search has no time cut-off and makes no mistakes '
               '(Boss skill, deterministic), so the same board gets the same answer every time. Three puzzles add a new house rule, **Always Block** '
               '(`Modifier.Kind.ALWAYS_BLOCK`): its units block every attacker they legally can, strongest attacker first (a blocker that survives, '
               'else the sturdiest), so a wall is a wall and the same wall every attempt.')
    out.append('- **The player always goes first**, so a bout depends only on the player\'s own deck order. The same rules are in effect every attempt.')
    out.append('- **The player brings their own deck, gear and items**, as in any main-game fight (the deck check runs before the bout).')
    out.append('- **Unlimited retries, no entry fee.** The first win pays the prize; a replay pays nothing (a deterministic bout would be a farm).')
    out.append('- **Order:** each table opens when the one before it is won (the first with the Shuffle House; the fifth also waits for Primm). '
               'Winning a table is the last step of its arena quest, so a save that finished a quest before tonight keeps it finished and can still play the table.')
    out.append('')
    out.append('## The five tables')
    out.append('')
    out.append('| # | Table | Opponent | Arena quest (level) | Player level | The weakness to find | Prize |')
    out.append('|---:|---|---|---|---:|---|---|')
    for pid, p in sorted(puzzles.items(), key=lambda kv: kv[1]['order']):
        r = p['reward']
        prize = '%d gold, %d XP, %s' % (r.get('gold', 0), r.get('xp', 0), {'primary': 'your Path\'s Pack', 'general_1': 'a General Pack', 'gilded_general': 'a Gilded Pack', 'prismatic': 'a Prismatic Pack'}.get(r.get('pack', ''), r.get('pack', '')))
        out.append('| %d | **%s** | %s | %s | %d | %s | %s |' % (p['order'], p['title'], p['enemy_name'], p['quest'], p['level'], p['weakness'], prize))
    out.append('')
    for pid, p in sorted(puzzles.items(), key=lambda kv: kv[1]['order']):
        key = 'arena:%s' % pid
        out.append('## %d. %s (%s)' % (p['order'], p['title'], p['enemy_name']))
        out.append('')
        out.append('*%s*  Octavia\'s hint: "%s"' % (p['pitch'], p['hint']))
        out.append('')
        out.append('**HP %d.** House rules:' % p['enemy_hp'])
        out.append('')
        for rule in mods.get(key, []):
            out.append('- **%s** (%s): %s' % (rule['name'], 'yours' if rule.get('side') == 'player' else 'hers' if True else '', rule['text']))
        for beat in scripts.get(key, []):
            out.append('- **%s** (timed, shown from the start): %s' % (beat['name'], beat['text']))
        out.append('')
        out.append('**The weakness:** %s.' % p['weakness'])
        out.append('')
        table = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov26n', 'puzzles_%s_%s.md' % (label, pid))
        if os.path.exists(table):
            rows = [l for l in io.open(table, encoding='utf-8').read().splitlines() if l.startswith('|')]
            out.append('**Simulated** (`%s`, 12 games a deck (table 2: 8), seeds 8100+; the sim\'s player is the planning AI at Elite skill with its level\'s gear, or the gear listed):' % os.path.relpath(table, ROOT).replace('\\', '/'))
            out.append('')
            out.extend(rows)
            out.append('')
        out.append('**The decks** (every list is 45+ cards within the copy caps of its level):')
        out.append('')
        for deck in p['sim_decks']:
            parts = ['%dx %s' % (n, names.get(cid, cid)) for cid, n in deck['cards'].items()]
            gear = (' Gear: %s.' % ', '.join(deck['equipment'])) if deck.get('equipment') else ''
            out.append('- **%s** (L%d): %s.%s' % (deck['label'], deck['level'], ', '.join(parts), gear))
        out.append('- **Reference decks**: each Path\'s `ProgressionModel.reference_deck` at L%d with `equipment_for` / `items_for` of that level.' % p['level'])
        out.append('')
        if pid in lines:
            line = lines[pid]
            out.append('**A recorded winning line** (%s, the player\'s shuffle seed %d, won on turn %d; the test replays it):' % (line['deck'], line['seed'], line['turns']))
            out.append('')
            out.append('```')
            out.extend(line['moves'])
            out.append('```')
            out.append('')
    io.open(os.path.join(ROOT, 'docs', 'design', 'arena_deck_puzzles.md'), 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
    print('wrote docs/design/arena_deck_puzzles.md')


if __name__ == '__main__':
    main()
