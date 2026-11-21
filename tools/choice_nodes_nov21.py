"""Fable Nov 21 (Part 4): the table of every dungeon choice room, read from data/dungeons/dungeon_content.json.
   python tools/choice_nodes_nov21.py   -> docs/design/choice_nodes_nov21.md"""
import json, os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
content = json.load(open(os.path.join(ROOT, 'data', 'dungeons', 'dungeon_content.json'), encoding='utf-8'))['dungeons']
names = {d['id']: d['name'] for d in json.load(open(os.path.join(ROOT, 'data', 'dungeons', 'dungeons.json'), encoding='utf-8'))}
names.setdefault('S-GALLERY', 'The Shattered Gallery')
heal_rooms = {('D-HOG', '10'), ('D-TTK', '9'), ('D-HFA', '10'), ('D-ROT', '9')}
STAT = {
    'max_hp': '{v} max HP', 'start_hp': '{v} HP at the start of each fight', 'draw': '{v} card in the opening hand',
    'exhausted': 'your units enter exhausted', 'slow': 'your first unit enters exhausted', 'first': 'you take the first turn',
    'iron': 'start with {n} Iron', 'foe_hp': 'the enemy starts with {v} HP', 'foe_draw': 'the enemy starts with {v} card in hand',
    'foe_first_unit': "the enemy's first unit gets {v}/{v}", 'first_unit_atk': 'the first unit you play gets {v} attack',
    'first_unit_def': 'the first unit you play gets {v} defense', 'first_draw': 'you skip your first card draw',
    'first_cost': 'the first card you play each turn costs {n} more', 'first_infra': 'your first Infrastructure enters exhausted',
    'foe_unit': 'the enemy starts with a unit on the field',
}
BAD = {'exhausted', 'slow', 'first_draw', 'first_cost', 'first_infra', 'foe_hp', 'foe_draw', 'foe_first_unit', 'foe_unit', 'foe_atk', 'foe_def'}


def boon(spec):
    name, _, rest = spec.partition('|')
    stats = dict(pair.split('=') for pair in rest.split(',') if '=' in pair)
    words = []
    if 'atk' in stats or 'def' in stats:
        parts = ['%+d %s' % (int(stats[k]), w) for k, w in (('atk', 'attack'), ('def', 'defense')) if k in stats]
        words.append('your units get ' + ' and '.join(parts))
    if 'foe_atk' in stats or 'foe_def' in stats:
        parts = ['%+d %s' % (int(stats[k]), w) for k, w in (('foe_atk', 'attack'), ('foe_def', 'defense')) if k in stats]
        words.append("the enemy's units get " + ' and '.join(parts))
    for key, value in stats.items():
        if key in STAT:
            words.append(STAT[key].format(v='%+d' % int(value), n=abs(int(value))))
    lasts = 'next fight' if stats.get('next') == '1' else 'rest of the dungeon'
    bad = any(k in BAD for k in stats) or any(int(v) < 0 for k, v in stats.items() if k not in ('next', 'foe_units'))
    return "'%s': %s" % (name, ', '.join(words) or 'a mark'), lasts, bad


rows = []
for dungeon_id, block in content.items():
    for number, event in sorted(block.get('events', {}).items(), key=lambda kv: int(kv[0])):
        room = '%s: %s' % (number, event.get('title', '(story event, built in code)'))
        if (dungeon_id, number) in heal_rooms:
            room += ' **(was a full heal)**'
        if 'ref' in event:
            rows.append((names.get(dungeon_id, dungeon_id), '%s (story event "%s", built in code)' % (number, event['ref']), '', '', '', ''))
            continue
        for choice in event.get('choices', []):
            gains, costs, lasts = [], [], 'at once'
            for token in choice[2:]:
                kind, _, arg = token.partition(':')
                if kind == 'heal':
                    gains.append('heal %s' % arg)
                elif kind == 'gold':
                    gains.append('+%s gold' % arg)
                elif kind == 'card':
                    gains.append('a card (%s)' % arg)
                elif kind == 'damage':
                    costs.append('lose %s HP' % arg)
                elif kind == 'pay':
                    costs.append('pay %s gold' % arg)
                elif kind == 'lose':
                    costs.append('a random card leaves your deck for this run')
                    lasts = 'rest of the dungeon'
                elif kind in ('boon', 'curse'):
                    text, how_long, bad = boon(arg)
                    (costs if bad or kind == 'curse' else gains).append(text)
                    lasts = how_long
                elif kind == 'hint':
                    gains.append('(' + arg + ')')
                elif kind == 'rescue':
                    gains.append('the rescued leader fights beside you')
                elif kind == 'sever':
                    gains.append('the boss starts with less HP')
            rows.append((names.get(dungeon_id, dungeon_id), room, choice[0], '; '.join(gains) or 'nothing', '; '.join(costs) or 'nothing', lasts))

out = os.path.join(ROOT, 'docs', 'design', 'choice_nodes_nov21.md')
with open(out, 'w', encoding='utf-8', newline='\n') as handle:
    handle.write('# Dungeon choice rooms (Fable Nov 21, Part 4)\n\n')
    handle.write('Every option of every choice room, read from `data/dungeons/dungeon_content.json` by `python tools/choice_nodes_nov21.py`. '
                 'Since Nov 21 the four main-zone dungeons have **no full heal**: each heal room is a choice room, "heal 5 HP for a cost" or '
                 '"do nothing". A do-nothing option is the only one with no cost. This replaces `choice_nodes_nov19.md`.\n\n')
    handle.write('| Dungeon | Room | Option | You get | It costs | Lasts |\n|---|---|---|---|---|---|\n')
    for row in rows:
        handle.write('| ' + ' | '.join(row) + ' |\n')
    handle.write('\n**Full heals that stay** (not changed; the castle rooms are untouched by the owner\'s rule): the Forgotten Cave\'s Whispering '
                 'Shrine (the tutorial) and Primm\'s Castle\'s Resistance Safe Room. Since Nov 20 (the owner\'s answer) the Path-ology Lab\'s '
                 'Night Shift Break Room is a "heal 5 for a cost" room like the four zone dungeons\': 80 gold, or the first card you play '
                 'each turn costs 1 more in the next fight.\n')
print('%d rows -> %s' % (len(rows), os.path.relpath(out, ROOT)))
