"""Nov 25 night (Part D.1): the Shattered Gallery's Echoes bring their originals' special rules with them, in a postgame version (harder,
never softer). Each Echo keeps its own twisted rule and gains:
  - the rules of the main-game fight it echoes (data/encounters/modifiers.json), with the numbers raised (written out here by hand so
    the text and the numbers agree);
  - the original's scripted mid-fight events (data/encounters/encounter_scripts.json) that make the fight harder, sharper (earlier,
    bigger); the original's late "faltering" beats (its units get -1/-0 near the end) are left out: an Echo does not falter;
  - no spoken lines: the originals' lines are theirs (the banner still says what happened).
Writes both files in place and docs/design/sim/nov25n/gallery_echo_rules.md (the list for the report). Idempotent: rules it added are
marked "postgame": true and replaced on every run.
    python tools/nov25n_gallery_echoes.py"""
import copy
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
MODS = os.path.join(ROOT, 'data', 'encounters', 'modifiers.json')
SCRIPTS = os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json')
REPORT = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov25n', 'gallery_echo_rules.md')

ORIGINAL = {
    'Echo of Vivienne Quota': 'Vivienne Quota, Minister of Efficiency',
    'Echo of Chancellor Clench': 'Chancellor Clench, Iron Regent',
    'Echo of Percival Plume': 'Percival Plume, Deputy Minister of Good News',
    'Echo of Mortimer Grimsby': 'Mortimer Grimsby, CE-No',
    'Echo of the Doppelganger': 'The Doppelganger',
    'Echo of Hortensia Clipwell': 'Hortensia Clipwell, Royal Groundskeeper',
    'Echo of the Rotheart': 'Compostella, the Rotheart',
}

# The originals' rules, postgame: what each Echo gains (on top of its own twisted rule)
RULES = {
    'Echo of Vivienne Quota': [
        {'name': 'Stopwatch, Silvered', 'text': "Quota's Echo's units get +2 attack. The stopwatch in the glass runs fast.", 'icon': 'delapouite/alarm-clock', 'kind': 'stat', 'atk': 2, 'def': 0},
    ],
    'Echo of Chancellor Clench': [
        {'name': 'Reinforcements, Silvered', 'text': "Every fourth turn of his, a 2/2 Patchwork Body marches in (the original waited for every fifth).", 'icon': 'delapouite/strong-man', 'kind': 'timed_summon', 'token': 'T-21', 'every': 4},
    ],
    'Echo of Percival Plume': [
        {'name': 'Positive Spin, Silvered', 'text': "Plume's Echo's units get +1/+2. The press release has been polished.", 'icon': 'delapouite/scroll-quill', 'kind': 'stat', 'atk': 1, 'def': 2},
    ],
    'Echo of Mortimer Grimsby': [
        {'name': 'Temp Agency, Silvered', 'text': "Every second turn of his, a 1/1 Zombie Temp clocks in; his units get +1/+1.", 'icon': 'delapouite/shambling-zombie', 'kind': 'timed_summon', 'token': 'T-10', 'every': 2},
        {'name': 'Temp Agency, Silvered', 'text': "Every second turn of his, a 1/1 Zombie Temp clocks in; his units get +1/+1.", 'icon': 'delapouite/shambling-zombie', 'kind': 'stat', 'atk': 1, 'def': 1},
    ],
    'Echo of the Doppelganger': [
        {'name': 'Mise en Place, Silvered', 'text': 'Starts the duel with 2 Ingredients, on top of its two Sashimi Weenies.', 'icon': 'delapouite/chef-toque', 'kind': 'starting_resources', 'resource': 'ingredient', 'count': 2},
        {'name': 'Plated Just So, Silvered', 'text': "The Echo's units get +2/+1. Every reflected dish is plated just so.", 'icon': 'delapouite/fork-knife-spoon', 'kind': 'stat', 'atk': 2, 'def': 1},
    ],
    'Echo of Hortensia Clipwell': [
        {'name': 'Royal Groundskeeper, Silvered', 'text': "Clipwell's Echo's units get +2/+1 (her Topiaries do not: they stay 1/2).", 'icon': 'lorc/leaf-swirl', 'kind': 'stat', 'atk': 2, 'def': 1, 'non_tokens': True},
    ],
    'Echo of the Rotheart': [
        {'name': 'Rot Takes Root, Silvered', 'text': "The Echo's units get +2/+2 more. The rot in the glass is still feeding.", 'icon': 'cathelineau/tree-face', 'kind': 'stat', 'atk': 2, 'def': 2},
    ],
}

# The originals' scripted events to carry over (by id) and how the postgame version differs
SCRIPT_KEEP = {
    'Echo of Vivienne Quota': {'review': {'effects': [{'kind': 'draw', 'count': 2}], 'text': "At half health Quota's Echo reviews her numbers: she draws two cards.", 'banner': "Quota's Echo draws two cards."}},
    'Echo of Chancellor Clench': {
        'brownout': {'when': {'type': 'turn', 'turn': 4}, 'text': "On his 4th turn Clench's Echo cuts the wheel power: your two strongest ready units are exhausted and cannot block that turn.", 'warn': "Next turn: Clench's Echo cuts the power (your two strongest units cannot block)."},
        'forms': {'effects': [{'kind': 'resources', 'resource': 'iron', 'count': 3}], 'text': "At half health Clench's Echo pulls the emergency reserve: he gains 3 Iron.", 'banner': "Clench's Echo gains 3 Iron."},
    },
    'Echo of Percival Plume': {
        'spin': {'effects': [{'kind': 'heal', 'amount': 5}], 'text': "At half health Plume's Echo announces that he is fine: he heals 5.", 'banner': "Plume's Echo heals 5."},
        'deadline': {},
    },
    'Echo of Mortimer Grimsby': {'form': {'when': {'type': 'turn', 'turn': 3}, 'effects': [{'kind': 'summon', 'token': 'T-10', 'count': 2, 'token_name': 'Filing Clerk'}], 'text': "On his 3rd turn Mortimer's Echo files Form 27-B twice: two 1/1 Filing Clerks are hired to process it.", 'warn': "Next turn: Mortimer's Echo files Form 27-B (two clerks are hired).", 'banner': 'Two 1/1 Filing Clerks are hired.'}},
    'Echo of the Doppelganger': {'mask': {'effects': [{'kind': 'summon', 'token': 'T-03', 'count': 3}], 'text': "At half health the Echo's mask slips, and nothing changes underneath: three 1/1 Sashimi Weenies are rushed out.", 'banner': 'Three 1/1 Sashimi Weenies are rushed out.'}},
    'Echo of Hortensia Clipwell': {'topiary': {'text': "At half health Clipwell's Echo trims three topiaries into guards: three 1/2 Topiaries join her.", 'banner': "Three Topiaries join Clipwell's Echo.", 'count': 3}},
    'Echo of the Rotheart': {'roots': {'text': "At half health the roots spread: three 1/1 Sporelings sprout and the Echo's units get +0/+1.", 'banner': "Three Sporelings sprout; the Echo's units get +0/+1.", 'count': 3}},
}


def load(path):
    return json.load(io.open(path, encoding='utf-8'))


def save(path, data):
    text = json.dumps(data, indent='\t', ensure_ascii=False) + '\n'
    io.open(path, 'w', encoding='utf-8', newline='\n').write(text)


def main():
    mods = load(MODS)
    scripts = load(SCRIPTS)
    lines = ['# The Shattered Gallery\'s Echoes, postgame (Nov 25 night, Part D.1)', '',
             'Generated by `tools/nov25n_gallery_echoes.py`. Each Echo keeps its own twisted rule and gains its original\'s rules and scripted '
             'events, harder. The originals\' late "faltering" beats (their units get -1/-0 near the end) are left out. Win rates: '
             '`gallery_runs.md`.', '', '| Echo (room) | Its own rule | From the original, postgame | Scripted events |', '|---|---|---|---|']
    for echo, original in ORIGINAL.items():
        own = [r for r in mods.get(echo, []) if not r.get('postgame')]
        added = []
        for rule in RULES[echo]:
            entry = dict(rule)
            entry['postgame'] = True
            added.append(entry)
        mods[echo] = own + added
        carried = []
        for event in scripts.get(original, []):
            change = SCRIPT_KEEP[echo].get(event['id'])
            if change is None:
                continue
            copy_event = copy.deepcopy(event)
            copy_event.pop('line', None)
            count = change.get('count')
            for key, value in change.items():
                if key != 'count':
                    copy_event[key] = copy.deepcopy(value)
            if count is not None:
                for effect in copy_event['effects']:
                    if effect.get('kind') == 'summon':
                        effect['count'] = count
            copy_event['id'] = 'echo_' + event['id']
            carried.append(copy_event)
        scripts[echo] = carried
        names = sorted({r['name'] for r in own})
        lines.append('| %s | %s | %s | %s |' % (echo, ', '.join(names), '; '.join(sorted({r['text'] for r in added})),
                                                  '; '.join(e['text'] for e in carried) or '-'))
    save(MODS, mods)
    save(SCRIPTS, scripts)
    os.makedirs(os.path.dirname(REPORT), exist_ok=True)
    io.open(REPORT, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
    print('echoes updated: %d' % len(ORIGINAL))


if __name__ == '__main__':
    main()
