"""Fable big pass Nov 23 (Part 4.7): the draft feats, appended to data/feats/feats.json (group Challenges). Idempotent.
    python tools/nov23_draft_feats.py"""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'data', 'feats', 'feats.json')
PATHS = [1, 2, 3, 4]
PAIRS = ['draft_won:pair:%d+%d' % (a, b) for i, a in enumerate(PATHS) for b in PATHS[i + 1:]]
TRIOS = ['draft_won:trio:%s' % '+'.join(str(p) for p in PATHS if p != out) for out in reversed(PATHS)]
ZONES = ['draft_won:zone:%s' % zone for zone in ['beefcake', 'gourmand', 'necrocrat', 'refusemancer']]
HIGHS = ['draft_won:high:%d' % count for count in [1, 2, 4]]

FEATS = [
    ('draft_first', 'Pick It, Pick It, PICK IT!', False, "Finish a draft at Trey Pickett's cart or the Shuffle House.", 25, {'kind': 'counter', 'counter': 'draft_runs_finished', 'at_least': 1}),
    ('draft_flawless', 'Three and Oh', False, 'Win three draft fights in a row without a loss.', 50, {'kind': 'counter', 'counter': 'draft_flawless', 'at_least': 1}),
    ('draft_four_carts', 'Four Carts, Four Paths', False, "Win Trey Pickett's draft in all four zones.", 100, {'kind': 'flags', 'flags': ZONES, 'any_of': []}),
    ('draft_all_pairs', 'Six of One', False, 'Win all six two-Path tables at the Shuffle House.', 100, {'kind': 'flags', 'flags': PAIRS, 'any_of': []}),
    ('draft_high_roller', 'High Roller', False, "Win one of the Shuffle House's win-three tables.", 75, {'kind': 'flags', 'flags': [], 'any_of': HIGHS}),
    ('draft_halls', 'The House Always Deals', False, 'Clear the Shuffled Halls.', 100, {'kind': 'flags', 'flags': ['draft_won:halls'], 'any_of': []}),
    ('draft_dungeon', 'Borrowed Deck, Real Dungeon', False, 'Clear a dungeon with a drafted deck.', 50, {'kind': 'counter', 'counter': 'draft_dungeons_cleared', 'at_least': 1}),
    ('draft_daily', "Today's Special", False, 'Win the Draft of the Day.', 50, {'kind': 'counter', 'counter': 'draft_won_kind:daily', 'at_least': 1}),
    ('draft_every_table', 'Every Table in the House', True, 'Win every two-, three- and four-Path table at the Shuffle House.', 200, {'kind': 'flags', 'flags': PAIRS + TRIOS + ['draft_won:quad'], 'any_of': []}),
]


def main():
    text = io.open(PATH, encoding='utf-8', newline='').read()
    data = json.loads(text)
    have = {feat['id'] for feat in data['feats']}
    rows = []
    for feat_id, name, hidden, earned_by, gold, trigger in FEATS:
        if feat_id in have:
            continue
        rows.append(json.dumps({'id': feat_id, 'name': name, 'group': 'Challenges', 'hidden': hidden, 'earned_by': earned_by, 'reward': {'gold': gold}, 'trigger': trigger}, ensure_ascii=False))
    if rows:
        newline = '\r\n' if '\r\n' in text else '\n'
        end = text.rindex(']')
        head = text[:end].rstrip()
        text = head + ',' + newline + newline.join('\t\t' + row + (',' if i < len(rows) - 1 else '') for i, row in enumerate(rows)) + newline + '\t' + text[end:]
        json.loads(text)
        io.open(PATH, 'w', encoding='utf-8', newline='').write(text)
    print('draft feats added: %d' % len(rows))


if __name__ == '__main__':
    main()
