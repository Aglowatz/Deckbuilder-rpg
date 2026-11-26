"""Nov 25 night (Part D.1): the Shattered Gallery's Echoes bring their originals' special rules with them. The fight is harder than the original
(the Echo's own twisted rule on top, more HP, a full opening hand: Part C), never softer. Each Echo keeps its own twisted rule and gains:
  - the rules of the main-game fight it echoes (data/encounters/modifiers.json), at the original's strength (a first version with
    raised numbers left no simulated run alive past the fourth room: docs/design/sim/nov25n/postgame_runs.md);
  - the original's scripted mid-fight events (data/encounters/encounter_scripts.json) that make the fight harder; the original's late "faltering" beats (its units get -1/-0 near the end) are left out: an Echo does not falter;
  - their own lines, said through the glass (the originals' lines are theirs): `ECHO_LINES`.
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
        {'name': 'Stopwatch, Reflected', 'text': "Quota's Echo's units get +1 attack, as hers did. Every second counts, and the glass is counting.", 'icon': 'delapouite/alarm-clock', 'kind': 'stat', 'atk': 1, 'def': 0},
    ],
    'Echo of Chancellor Clench': [
        {'name': 'Reinforcements, Reflected', 'text': "Every fifth turn of his, a 2/2 Patchwork Body marches in, as it did for him.", 'icon': 'delapouite/strong-man', 'kind': 'timed_summon', 'token': 'T-21', 'every': 5},
    ],
    'Echo of Percival Plume': [
        {'name': 'Positive Spin, Reflected', 'text': "Plume's Echo's units get +1/+1, as his did. Everything hits harder in a press release.", 'icon': 'delapouite/scroll-quill', 'kind': 'stat', 'atk': 1, 'def': 1},
    ],
    'Echo of Mortimer Grimsby': [
        {'name': 'Temp Agency, Reflected', 'text': "Every second turn of his, a 1/1 Zombie Temp clocks in; his units get +1/+0, as Mortimer's did.", 'icon': 'delapouite/shambling-zombie', 'kind': 'timed_summon', 'token': 'T-10', 'every': 2},
        {'name': 'Temp Agency, Reflected', 'text': "Every second turn of his, a 1/1 Zombie Temp clocks in; his units get +1/+0, as Mortimer's did.", 'icon': 'delapouite/shambling-zombie', 'kind': 'stat', 'atk': 1, 'def': 0},
    ],
    'Echo of the Doppelganger': [
        {'name': 'Mise en Place, Reflected', 'text': 'Starts the duel with an Ingredient, on top of its two Sashimi Weenies.', 'icon': 'delapouite/chef-toque', 'kind': 'starting_resources', 'resource': 'ingredient', 'count': 1},
        {'name': 'Plated Just So, Reflected', 'text': "The Echo's units get +1/+1. Every reflected dish is plated just so.", 'icon': 'delapouite/fork-knife-spoon', 'kind': 'stat', 'atk': 1, 'def': 1},
    ],
    'Echo of Hortensia Clipwell': [
        {'name': 'Royal Groundskeeper, Reflected', 'text': "Clipwell's Echo's units get +1/+1 (her Topiaries do not: they stay 1/2).", 'icon': 'lorc/leaf-swirl', 'kind': 'stat', 'atk': 1, 'def': 1, 'non_tokens': True},
    ],
    'Echo of the Rotheart': [
        {'name': 'Rot Takes Root, Reflected', 'text': "The Echo's units get +2/+2 more, as Compostella's did. The rot in the glass is still feeding.", 'icon': 'cathelineau/tree-face', 'kind': 'stat', 'atk': 2, 'def': 2},
    ],
}

# The originals' scripted events to carry over (by id) and how the postgame version differs
SCRIPT_KEEP = {
    'Echo of Vivienne Quota': {'review': {'text': "At half health Quota's Echo reviews her numbers: she draws a card.", 'banner': "Quota's Echo draws a card."}},
    'Echo of Chancellor Clench': {
        'brownout': {'text': "On his 5th turn Clench's Echo cuts the wheel power: your two strongest ready units are exhausted and cannot block that turn.", 'warn': "Next turn: Clench's Echo cuts the power (your two strongest units cannot block)."},
        'forms': {'text': "At half health Clench's Echo pulls the emergency reserve: he gains 2 Iron.", 'banner': "Clench's Echo gains 2 Iron."},
    },
    'Echo of Percival Plume': {
        'spin': {'text': "At half health Plume's Echo announces that he is fine: he heals 2.", 'banner': "Plume's Echo heals 2."},
        'deadline': {'text': "When the Echo's 12th turn begins the office in the glass closes and you lose the duel. Win before then.", 'warn': "Next turn: the filing deadline in the glass. Win now, or the duel is lost."},
    },
    'Echo of Mortimer Grimsby': {'form': {'text': "On his 4th turn Mortimer's Echo files Form 27-B: a 1/1 Filing Clerk is hired to process it.", 'warn': "Next turn: Mortimer's Echo files Form 27-B (a clerk is hired)."}},
    'Echo of the Doppelganger': {'mask': {'effects': [{'kind': 'summon', 'token': 'T-03', 'count': 2}], 'text': "At half health the Echo's mask slips, and nothing changes underneath: two 1/1 Sashimi Weenies are rushed out.", 'banner': 'Two 1/1 Sashimi Weenies are rushed out.'}},
    'Echo of Hortensia Clipwell': {'topiary': {'text': "At half health Clipwell's Echo trims two topiaries into guards: two 1/2 Topiaries join her.", 'banner': "Two Topiaries join Clipwell's Echo."}},
    'Echo of the Rotheart': {'roots': {'text': "At half health the roots spread: two 1/1 Sporelings sprout and the Echo's units get +0/+1.", 'banner': "Two Sporelings sprout; the Echo's units get +0/+1."}},
}

# What each Echo says when a carried beat fires: the original's habit, warped by the glass (every shipped scripted event has a line)
ECHO_LINES = {
    'echo_review': "Efficiency... efficiency... the numbers in here only ever go up.",
    'echo_brownout': "Power to the glass. Only to the glass.",
    'echo_forms': "Reserve funds, reflected. There is always more on this side.",
    'echo_spin': "I'm fine. I'm fine. I'm fine. That's the message.",
    'echo_deadline': "The office in the glass never opens late. It only ever closes.",
    'echo_form': "Form 27-B, mirrored. Please sign it backwards.",
    'echo_mask': "Under the mask there's another mask. Under that, dinner.",
    'echo_topiary': "Trim, trim, trim. Even the hedges in here are reflections.",
    'echo_roots': "The roots go deeper on this side of the glass.",
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
            copy_event['line'] = ECHO_LINES[copy_event['id']]
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
