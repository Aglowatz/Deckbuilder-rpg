"""Nov 25 night (Part E): the postgame dungeons' fights get real teeth and variety. The owner: postgame can be unfair, needing one of a
few strong strategies; the player has 5 pieces of equipment and 4 items. Every ordinary postgame foe that had no rule of its own gets a
set (extra draws, unit buffs, Infrastructure in play from the start, troops on a timer, specific units arriving on set turns, phases at
half health), and the three with rules get one more sharp beat. All of it shows on the "Before the fight" panel like every rule.
Writes data/encounters/modifiers.json and encounter_scripts.json in place (entries it added carry "nov25n": true / an id "pg_..." and are
replaced on every run) and docs/design/sim/nov25n/postgame_rules.md.    python tools/nov25n_postgame_rules.py"""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
MODS = os.path.join(ROOT, 'data', 'encounters', 'modifiers.json')
SCRIPTS = os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json')
REPORT = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov25n', 'postgame_rules.md')

# foe -> (dungeon, room, rules to add, scripted events to add)
FOES = {
    'Intake Orderly': ('D-LAB', 2, [
        {'name': 'Pre-Filed', 'text': 'The Orderly starts the fight with an Infrastructure already in play. The paperwork was done before you arrived.', 'icon': 'delapouite/full-folder', 'kind': 'starting_infrastructure', 'count': 1},
        {'name': 'Intake Forms', 'text': 'The first card you play each turn costs 1 more. Please fill in every box.', 'icon': 'delapouite/stamper', 'side': 'player', 'harmful': True, 'kind': 'first_card_cost', 'amount': 1},
    ], [
        {'id': 'pg_sedation', 'name': 'Sedation Round', 'icon': 'lorc/bubbling-flask', 'when': {'type': 'turn', 'turn': 3}, 'text': 'On its 3rd turn the Orderly does the sedation round: your two strongest ready units are exhausted and cannot block that turn.', 'effects': [{'kind': 'exhaust_foes', 'count': 2}], 'warn': 'Next turn: the sedation round (your two strongest units cannot block).', 'banner': 'Sedation round: your two strongest ready units are exhausted.'},
    ]),
    'Escaped Specimen': ('D-LAB', 3, [
        {'name': 'Feral Brood', 'text': 'Every third turn of its, a 1/1 Specimen Spawn crawls out of the vents.', 'icon': 'lorc/acid-blob', 'kind': 'timed_summon', 'token': 'T-22', 'token_name': 'Specimen Spawn', 'token_keywords': [], 'token_stats': [1, 1], 'every': 3},
    ], [
        {'id': 'pg_shed', 'name': 'Shed Skin', 'icon': 'lorc/acid-blob', 'when': {'type': 'hp_below', 'pct': 50}, 'text': 'At half health the Specimen sheds its skin: it heals 3.', 'effects': [{'kind': 'heal', 'amount': 3}], 'banner': 'The Specimen heals 3.'},
    ]),
    'Hybrid Specimen': ('D-LAB', 8, [
        {'name': 'Grafted Pantry', 'text': 'The Hybrid starts the fight with 3 Ingredients.', 'icon': 'delapouite/chef-toque', 'kind': 'starting_resources', 'resource': 'ingredient', 'count': 3},
    ], [
        {'id': 'pg_splice', 'name': 'Splice', 'icon': 'lorc/acid-blob', 'when': {'type': 'turn', 'turn': 5}, 'text': 'On its 5th turn the Hybrid splices in a Toro Toro (4/6, Bulldoze, Swat), straight onto the field.', 'effects': [{'kind': 'card', 'card': 'G-27', 'to': 'field'}], 'warn': 'Next turn: the Hybrid splices in a Toro Toro (4/6).', 'banner': 'A Toro Toro is spliced in.'},
    ]),
    "Siphon's Research Assistant": ('D-LAB', 10, [
        {'name': 'Field Notes', 'text': 'At the start of each of its turns the Assistant gets an Ingredient.', 'icon': 'delapouite/scroll-quill', 'kind': 'start_of_turn_resources', 'resource': 'ingredient', 'count': 1},
    ], [
        {'id': 'pg_samples', 'name': 'Lab Samples', 'icon': 'lorc/bubbling-flask', 'when': {'type': 'turn', 'turn': 3}, 'text': 'On its 3rd turn the Assistant opens the sample fridge: two 1/1 Sashimi Weenies join it.', 'effects': [{'kind': 'summon', 'token': 'T-03', 'count': 2}], 'warn': 'Next turn: the sample fridge opens (two 1/1 units).', 'banner': 'Two 1/1 Sashimi Weenies join the Assistant.'},
        {'id': 'pg_project', 'name': 'The Big Project', 'icon': 'lorc/bubbling-flask', 'when': {'type': 'turn', 'turn': 6}, 'text': "On its 6th turn the Assistant's big project wakes up: a Landfill Leviathan (7/7) arrives on its field.", 'effects': [{'kind': 'card', 'card': 'R-36', 'to': 'field'}], 'warn': 'Next turn: the big project wakes up (a 7/7 Landfill Leviathan).', 'banner': 'The big project wakes up: a 7/7 Landfill Leviathan.'},
    ]),
    'Antechamber Sentry': ('D-LAB', 15, [
        {'name': 'Last Line', 'text': 'The Sentry always takes the first turn.', 'icon': 'delapouite/temporary-shield', 'kind': 'always_first'},
        {'name': 'Blast Doors', 'text': 'The Sentry starts with two 0/4 Blast Doors on the field (Wallflower: they block, they never attack).', 'icon': 'delapouite/temporary-shield', 'kind': 'starting_tokens', 'token': 'T-23', 'token_name': 'Blast Door', 'count': 2},
    ], [
        {'id': 'pg_lockdown', 'name': 'Lockdown', 'icon': 'delapouite/temporary-shield', 'when': {'type': 'hp_below', 'pct': 50}, 'text': "At half health the antechamber goes into lockdown: the Sentry's units get +2/+0 for the rest of the fight.", 'effects': [{'kind': 'rule', 'rule': {'name': 'Lockdown', 'text': "Lockdown: the Sentry's units get +2/+0.", 'icon': 'delapouite/temporary-shield', 'kind': 'stat', 'atk': 2, 'def': 0}}], 'banner': "Lockdown: the Sentry's units get +2/+0."},
    ]),
    'The Failed Experiment': ('D-LAB', 5, [], [
        {'id': 'pg_spurt', 'name': 'Growth Spurt', 'icon': 'lorc/acid-blob', 'when': {'type': 'turn', 'turn': 4}, 'text': 'On its 4th turn the Experiment has a growth spurt: a 2/2 Patchwork Body splits off it.', 'effects': [{'kind': 'summon', 'token': 'T-21', 'count': 1}], 'warn': 'Next turn: a growth spurt (a 2/2 unit splits off).', 'banner': 'A 2/2 Patchwork Body splits off the Experiment.'},
    ]),
    'The Drain Warden': ('D-LAB', 13, [], [
        {'id': 'pg_overdrain', 'name': 'Overdrain', 'icon': 'lorc/bubbling-flask', 'when': {'type': 'hp_below', 'pct': 40}, 'text': 'Low on power the Warden overdrains: you take 2 damage and it heals 2.', 'effects': [{'kind': 'damage', 'amount': 2}, {'kind': 'heal', 'amount': 2}], 'banner': 'Overdrain: you take 2 damage; the Warden heals 2.'},
    ]),
    'Rival Lifter at Base Camp': ('S-BEEF', 1, [
        {'name': 'Pre-Workout', 'text': 'The Rival draws an extra card on its first turn.', 'icon': 'delapouite/strong-man', 'kind': 'first_turn_draw', 'count': 1},
    ], [
        {'id': 'pg_second_set', 'name': 'Second Set', 'icon': 'delapouite/strong-man', 'when': {'type': 'hp_below', 'pct': 50}, 'text': 'At half health the Rival goes for a second set: it heals 4.', 'effects': [{'kind': 'heal', 'amount': 4}], 'banner': 'Second set: the Rival heals 4.'},
    ]),
    'Squat Rack Sentinel': ('S-BEEF', 2, [
        {'name': 'Safety Bar', 'text': 'The Sentinel starts with a 0/4 Safety Bar on the field (Wallflower: it blocks, it never attacks).', 'icon': 'delapouite/weight-lifting-up', 'kind': 'starting_tokens', 'token': 'T-23', 'token_name': 'Safety Bar', 'count': 1},
        {'name': 'Gym Golems', 'text': 'Every fourth turn of its, a 2/2 Gym Golem steps off the rack.', 'icon': 'delapouite/weight-lifting-up', 'kind': 'timed_summon', 'token': 'T-21', 'token_name': 'Gym Golem', 'every': 4},
    ], [
        {'id': 'pg_rack_pull', 'name': 'Rack Pull', 'icon': 'delapouite/weight-lifting-up', 'when': {'type': 'turn', 'turn': 4}, 'text': 'On its 4th turn the Sentinel drops the bar: your strongest ready unit is exhausted and cannot block that turn.', 'effects': [{'kind': 'exhaust_foes', 'count': 1}], 'warn': 'Next turn: the Sentinel drops the bar (your strongest unit cannot block).', 'banner': 'Your strongest ready unit is pinned under the bar.'},
    ]),
    'The Ancient Spotter': ('S-BEEF', 3, [
        {'name': 'Base Camp Chalk', 'text': 'The Spotter starts the fight with an Infrastructure already in play.', 'icon': 'delapouite/mammoth', 'kind': 'starting_infrastructure', 'count': 1},
    ], []),
}

# What each foe says when its new beat fires (every shipped scripted event has a line: tests/core/dungeon/test_encounter_scripts.gd)
LINES = {
    'pg_sedation': "Lights out, everyone. Doctor's orders. Well, the doctor's assistant's orders.",
    'pg_shed': "*The Specimen wriggles out of its old skin, looking very pleased with itself.*",
    'pg_splice': "One part bull, one part sushi, all parts experiment. Hold still!",
    'pg_samples': "Oh, the samples are out of the fridge again. They do that.",
    'pg_project': "Professor said never to wake it. The professor isn't here.",
    'pg_lockdown': "LOCKDOWN. NO ONE PASSES. NOT EVEN ME, AND I WORK HERE.",
    'pg_spurt': "*Blorp.* There are two of it now. It looks surprised too.",
    'pg_overdrain': "The meter says empty. The meter is about to say full.",
    'pg_second_set': "That was the warm-up. Now for the real set!",
    'pg_rack_pull': "Spotter's away! Mind your toes!",
}


def load(path):
    return json.load(io.open(path, encoding='utf-8'))


def save(path, data):
    io.open(path, 'w', encoding='utf-8', newline='\n').write(json.dumps(data, indent='\t', ensure_ascii=False) + '\n')


def main():
    mods = load(MODS)
    scripts = load(SCRIPTS)
    lines = ['# Postgame fights: their rules after Nov 25 night (Part E)', '',
             'Generated by `tools/nov25n_postgame_rules.py`. New rules and events are in **bold**; the Shattered Gallery\'s Echoes are in '
             '`gallery_echo_rules.md`. Win rates: `postgame_runs.md`.', '', '| Dungeon, room | Foe | Rules | Scripted events |', '|---|---|---|---|']
    for foe, (dungeon, room, rules, events) in FOES.items():
        kept = [r for r in mods.get(foe, []) if not r.get('nov25n')]
        added = [dict(r, nov25n=True) for r in rules]
        mods[foe] = kept + added
        old_events = [e for e in scripts.get(foe, []) if not str(e.get('id', '')).startswith('pg_')]
        for event in events:
            if event['id'] in LINES:
                event['line'] = LINES[event['id']]
        scripts[foe] = old_events + events
        rule_text = ['%s: %s' % (r['name'], r['text']) for r in kept] + ['**%s: %s**' % (r['name'], r['text']) for r in added]
        event_text = [e.get('text', '') for e in old_events] + ['**%s**' % e['text'] for e in events]
        lines.append('| %s %d | %s | %s | %s |' % (dungeon, room, foe, '<br>'.join(dict.fromkeys(rule_text)), '<br>'.join(event_text) or '-'))
    save(MODS, mods)
    save(SCRIPTS, scripts)
    os.makedirs(os.path.dirname(REPORT), exist_ok=True)
    io.open(REPORT, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
    print('postgame foes updated: %d' % len(FOES))


if __name__ == '__main__':
    main()
