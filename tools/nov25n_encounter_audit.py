"""Nov 25 night (Part G): an audit of every dungeon's encounters - how many fights, which share a deck archetype, how many have a rule or
a scripted event of their own, which events are the builder's default "look around / rest" filler - for docs/design/encounter_upgrades.md.
Prints Markdown tables to stdout.    python tools/nov25n_encounter_audit.py > _tmp_tools/encounter_audit.md"""
import collections
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')


def load(*parts):
    return json.load(io.open(os.path.join(ROOT, *parts), encoding='utf-8'))


def main():
    plans = load('data', 'dungeons', 'dungeons.json')
    plans = plans if isinstance(plans, list) else list(plans.get('dungeons', plans).values())
    plans += load('data', 'dungeons', 'postgame_dungeons.json')
    content = load('data', 'dungeons', 'dungeon_content.json')['dungeons']
    mods = load('data', 'encounters', 'modifiers.json')
    scripts = load('data', 'encounters', 'encounter_scripts.json')
    print('| Dungeon | Type | Fights | Fights with own rules | Fights with scripts | Decks used (fights) | Events | Default (filler) events |')
    print('|---|---|---:|---:|---:|---|---:|---:|')
    for plan in plans:
        if not isinstance(plan, dict) or plan.get('id') in (None, 'D-TUT'):
            continue
        key = plan['id']
        block = content.get(key, {})
        foes = block.get('foes', {})
        events = block.get('events', {})
        fights = [n for n in plan.get('nodes', []) if n.get('type') in ('battle', 'elite', 'boss')]
        decks = collections.Counter()
        ruled = 0
        scripted = 0
        for node in fights:
            foe = foes.get(str(node.get('n')))
            name = foe if isinstance(foe, str) else (foe or {}).get('name', '')
            deck = (foe or {}).get('deck', 'boss' if node.get('type') == 'boss' else '?') if isinstance(foe, dict) else 'named'
            decks[deck] += 1
            if mods.get(name):
                ruled += 1
            if scripts.get(name):
                scripted += 1
        event_nodes = [n for n in plan.get('nodes', []) if n.get('type') == 'event']
        filler = sum(1 for n in event_nodes if str(n.get('n')) not in events)
        print('| %s %s | %s | %d | %d | %d | %s | %d | %d |' % (key, plan.get('name', ''), plan.get('type', ''), len(fights), ruled, scripted,
              ', '.join('%s %d' % (d, c) for d, c in decks.most_common()), len(event_nodes), filler))


if __name__ == '__main__':
    main()
