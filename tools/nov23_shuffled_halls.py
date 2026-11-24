"""Fable big pass Nov 23 (Part 4): writes the Shuffled Halls (D-SHUFFLE, the Shuffle House's own draft dungeon) into
data/dungeons/postgame_dungeons.json and its fitted room spots into data/dungeons/map_layout.json. 18 rooms in six columns
(2, 3, 4, 4, 3, 2) behind a hidden entrance, every link leading right (docs/design/draft_dungeon_plan.md), on the painted MAP-DRAFT. Idempotent.
    python tools/nov23_shuffled_halls.py"""
import io
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
DUNGEON_ID = 'D-SHUFFLE'
# Room 1 is the way in (not drawn: the two gates are the first choice). The Counting Room is the house's takings, one door before the boss.
# n: (name, type, x, y as fractions of MAP-DRAFT (the pale landing disc under each room), next)
ROOMS = {
    1: ('The Stage Door', 'start', 0.030, 0.500, [2, 3]),
    2: ('The Velvet Gate', 'battle', 0.077, 0.337, [4, 5]),
    3: ('The Tinsel Gate', 'battle', 0.077, 0.663, [5, 6]),
    4: ('The Trade Counter', 'event', 0.234, 0.231, [7, 8]),
    5: ('The Tea Garden', 'battle', 0.232, 0.488, [8, 9]),
    6: ('The House Kettle', 'event', 0.232, 0.750, [9, 10]),
    7: ('The Back-Room Table', 'battle', 0.405, 0.178, [11, 12]),
    8: ('The Auction Ring', 'elite', 0.397, 0.370, [11, 12, 13]),
    9: ('The Lucky Stall', 'event', 0.403, 0.606, [12, 13, 14]),
    10: ('The Carousel', 'battle', 0.396, 0.827, [13, 14]),
    11: ('The Chained Vault', 'event', 0.567, 0.178, [15]),
    12: ('The Rules Library', 'battle', 0.580, 0.370, [15, 16]),
    13: ('The Prize Tent', 'event', 0.576, 0.606, [16, 17]),
    14: ('The Roulette Pit', 'elite', 0.580, 0.827, [17]),
    15: ('The Card Shop', 'battle', 0.740, 0.231, [19]),
    16: ('The Quiet Lounge', 'event', 0.746, 0.490, [19, 18]),
    17: ('The Dessert Cart', 'event', 0.744, 0.750, [18]),
    18: ('The Counting Room', 'treasure', 0.913, 0.683, [19]),
    19: ('The Big Wheel', 'boss', 0.920, 0.400, []),
}


def main():
    path = os.path.join(ROOT, 'data', 'dungeons', 'postgame_dungeons.json')
    text = io.open(path, encoding='utf-8', newline='').read()
    rows = json.loads(text)
    rows = [row for row in rows if row.get('id') != DUNGEON_ID]
    rows.append({
        'id': DUNGEON_ID,
        'name': 'The Shuffled Halls',
        'type': 'Draft Dungeon',
        'zone': 'town',
        'zone_text': 'Crosspath (under the Shuffle House)',
        'zone_side': False,
        'theme': "The halls behind the Shuffle House's stage: a carnival-casino on a card table the size of a town, red carpets between little show tents, marquee bulbs, velvet and gold.",
        'story': "Octavia Eightfold's own dungeon, played only with a drafted deck. Eighteen rooms in six columns; you walk one room of each. Rivals at the tables, her nephew Trey Pickett in the Auction Ring, and Octavia herself at the end, whichever door you take.",
        'boss': 'Octavia Eightfold (the house always deals)',
        'buffs': 'One HP pool for the whole run. After each fight you win: pick one of three cards (add it, swap it for a card of your deck, or pass).',
        'reward_first': 'A piece of draft equipment, a Gilded Pack, gold and XP, and you keep one card of your drafted deck.',
        'reward_repeat': 'Gold, a General Pack and an extra pack, and you keep one card of your drafted deck.',
        'hook': 'Octavia Eightfold: "Everyone who is anyone has been lost in my halls at least once, darling."',
        'map_id': 'MAP-DRAFT',
        'battleboard_id': 'BB-SHUFFLE',
        '_note': 'Fable big pass Nov 23 (docs/design/draft_dungeon_plan.md; the owner\'s decisions of Nov 23): hand-made, no sheet row. Played only as a draft (DraftArena.HALLS_DUNGEON). Room 1 (the Stage Door) is the hidden way in; rooms 1 to 18 of the plan are rooms 2 to 19 here. The Counting Room (18) is a treasure room with a door to the boss (19, the Big Wheel).',
        'nodes': [{'n': n, 'name': room[0], 'type': room[1], 'note': 'hidden' if room[1] == 'start' else '', 'x': int(round(room[2] * 100)), 'y': int(round(room[3] * 100)), 'next': room[4], 'side': False, 'return_to': 0}
            for n, room in sorted(ROOMS.items())],
    })
    io.open(path, 'w', encoding='utf-8', newline='').write(json.dumps(rows, indent='\t', ensure_ascii=False) + '\n')
    layout_path = os.path.join(ROOT, 'data', 'dungeons', 'map_layout.json')
    layout = io.open(layout_path, encoding='utf-8', newline='').read()
    newline = '\r\n' if '\r\n' in layout else '\n'
    # the layout file as data (tools/map_curves.py keeps its compact look); the traced curves of the Halls are left alone, so
    # run `python tools/map_curves.py --only=D-SHUFFLE` after moving a room
    from map_curves import compact
    data = json.loads(layout)
    known = data.get(DUNGEON_ID, {}) if isinstance(data.get(DUNGEON_ID), dict) else {}
    data[DUNGEON_ID] = {str(n): (known[str(n)] if str(n) in known and n != 1 else [round(room[2], 3), round(room[3], 3)]) for n, room in sorted(ROOMS.items())}
    data.setdefault('paths', {})[DUNGEON_ID] = data.get('paths', {}).get(DUNGEON_ID, 'highlight')
    out = compact(json.dumps(data, indent='	', ensure_ascii=False))
    lf = chr(10)
    io.open(layout_path, 'w', encoding='utf-8', newline='').write(out.replace(lf, newline) + (newline if layout.endswith(lf) else ''))
    print('D-SHUFFLE: %d rooms written' % len(ROOMS))


if __name__ == '__main__':
    main()
