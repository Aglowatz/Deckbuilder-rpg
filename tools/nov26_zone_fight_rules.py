"""Nov 26 day (Part C): every zone dungeon fight gets its own rule set. The four zones' main dungeons and Primm's Castle; not the
postgame (it stays as it is). Before today only the elites and bosses had rules: the ordinary fights were a deck and nothing else, and
the House of Gains had the same archetype (beefcake_bruisers) three times. Each ordinary fight now has a rule that hurts and something
the player can use, chosen to question how the deck was built (walls against ground attackers, a cap on cards a turn against swarms, a
banned card type, a resource you cannot spend) while rewarding another plan (flyers, keywords, a Path, healing). The elites and bosses
keep their sets; a few get one deck-check twist. Two fights change deck to break up repeats.

Writes data/encounters/modifiers.json and encounter_scripts.json in place (entries it adds carry "nov26": true / an id "zf_..." and are
replaced on every run), the deck changes in data/dungeons/dungeon_content.json, and the rules part of docs/design/zone_fight_rules.md
(the win rates are filled in from docs/design/sim/nov26/).    python tools/nov26_zone_fight_rules.py"""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
MODS = os.path.join(ROOT, 'data', 'encounters', 'modifiers.json')
SCRIPTS = os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json')
CONTENT = os.path.join(ROOT, 'data', 'dungeons', 'dungeon_content.json')
RULES_JSON = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov26', 'zone_fight_rules.json')

WALL = 'T-23'  # a Wallflower token; token_stats sets its size


def wall(name, count, stats=(0, 4)):
    return {'kind': 'starting_tokens', 'token': WALL, 'token_name': name, 'token_stats': list(stats), 'count': count}


# foe -> (dungeon, room, rules to add, scripted events to add, the idea in one line)
FOES = {
    # ---- The House of Gains (Beefcake): a gym run by the regime --------------------------------------------------------------------
    'Treadmill Sprinter': ('D-HOG', 2, [
        {'name': 'Treadmill', 'text': "The Sprinter's units have Hustle: they can attack the turn they arrive.", 'icon': 'darkzaitzev/running-ninja', 'kind': 'keyword', 'keyword': 'hustle'},
        {'name': 'Interval Training', 'text': 'Your units with Hustle get +1 attack. Keep up!', 'icon': 'darkzaitzev/running-ninja', 'side': 'player', 'kind': 'keyword_stat', 'keyword': 'hustle', 'atk': 1},
    ], [], 'a race: slow decks get run over, fast (Hustle) decks hit harder'),
    'Courtyard Lifter': ('D-HOG', 3, [
        {'name': 'Heavy Plates', 'text': "The Lifter's units get +0/+2.", 'icon': 'delapouite/weight-lifting-up', 'kind': 'stat', 'atk': 0, 'def': 2},
        {'name': 'Free Weights', 'text': 'Your Beefcake cards cost 1 less. The courtyard is open to all.', 'icon': 'delapouite/weight-lifting-up', 'side': 'player', 'kind': 'cost_change', 'path': 'beefcake', 'amount': -1},
    ], [], 'tough blockers; Beefcake cards come cheaper'),
    'Cell Block Brawler': ('D-HOG', 8, [
        {'name': 'Lights Out', 'text': 'You may play at most 2 cards a turn (Infrastructure does not count). The guards count heads.', 'icon': 'delapouite/prisoner', 'side': 'player', 'harmful': True, 'kind': 'max_plays', 'count': 2},
        {'name': 'Care Package', 'text': 'You start with one more card in your opening hand.', 'icon': 'delapouite/scroll-quill', 'side': 'player', 'kind': 'opening_hand', 'count': 1},
    ], [], 'swarms of cheap cards are capped; big single plays are not (and a deck change: necrocrat_beefcake, the prison guards)'),
    'Trophy Hall Honor Guard': ('D-HOG', 11, [
        wall('Trophy Case', 1) | {'name': 'Display Case', 'text': 'The Guard starts with a 0/4 Trophy Case on the field (Wallflower: it blocks, it never attacks).', 'icon': 'delapouite/temporary-shield'},
        {'name': 'Hall of Fame', 'text': 'Your units with Flying get +1 attack. Champions fly over the cases.', 'icon': 'lorc/feathered-wing', 'side': 'player', 'kind': 'keyword_stat', 'keyword': 'flying', 'atk': 1},
    ], [], 'a wall for ground attackers; flyers go over it'),
    # ---- The Test Kitchen (Gourmand) -------------------------------------------------------------------------------------------------
    'Prep Station Sous-Chef': ('D-TTK', 2, [
        {'name': 'Prepped', 'text': 'The Sous-Chef starts the fight with 2 Ingredients.', 'icon': 'delapouite/chef-toque', 'kind': 'starting_resources', 'resource': 'ingredient', 'count': 2},
        {'name': 'Staff Meal', 'text': 'You start the fight with 2 Ingredients as well. Help yourself.', 'icon': 'delapouite/chef-toque', 'side': 'player', 'kind': 'starting_resources', 'resource': 'ingredient', 'count': 2},
    ], [], 'both sides start with Ingredients: a Gourmand deck makes better use of them'),
    'Frozen Line Cook': ('D-TTK', 3, [
        wall('Ice Block', 2) | {'name': 'Walk-In Cooler', 'text': 'The Cook starts with two 0/4 Ice Blocks on the field (Wallflower: they block, they never attack).', 'icon': 'delapouite/ice-golem'},
        {'name': 'Defrost', 'text': 'You start with one more card in your opening hand.', 'icon': 'delapouite/ice-golem', 'side': 'player', 'kind': 'opening_hand', 'count': 1},
    ], [], 'walls for ground attackers; flyers, Elusive units and direct damage go round them'),
    'Assembly Line Golem': ('D-TTK', 8, [
        {'name': 'Quality Control', 'text': 'Each unit that attacks the Golem takes 1 damage. Every unit is inspected.', 'icon': 'delapouite/stamper', 'kind': 'retaliate', 'amount': 1},
        {'name': 'Overtime Shift', 'text': 'You draw an extra card on your first turn.', 'icon': 'delapouite/coffee-cup', 'side': 'player', 'kind': 'first_turn_draw', 'count': 1},
    ], [], 'swarms of 1-defence units pay for attacking; big units shrug it off'),
    'Expediter of the Pass': ('D-TTK', 12, [
        {'name': 'Plate Up', 'text': "The Expediter's units get +1/+0. Hot plates, coming through.", 'icon': 'delapouite/fork-knife-spoon', 'kind': 'stat', 'atk': 1, 'def': 0},
        {'name': 'Tasting Spoon', 'text': 'Whenever you gain HP, you gain 1 more.', 'icon': 'delapouite/fork-knife-spoon', 'side': 'player', 'kind': 'hp_gain_bonus', 'amount': 1},
    ], [
        {'id': 'zf_staff_meal', 'name': 'Staff Meal', 'icon': 'delapouite/fork-knife-spoon', 'when': {'type': 'turn', 'turn': 4},
         'text': 'On its 4th turn the pass sends out staff meal: you heal 3.', 'effects': [{'kind': 'foe_heal', 'amount': 3}],
         'warn': 'Next turn: staff meal comes out of the pass (you heal 3).', 'banner': 'Staff meal: you heal 3.'},
    ], 'it hits harder; decks that heal gain more (and a staff meal on its 4th turn)'),
    # ---- The Hall of Final Approvals (Necrocrat) -------------------------------------------------------------------------------------
    'Intake Clerk': ('D-HFA', 3, [
        {'name': 'Forms Only', 'text': 'You cannot play Tools in this fight. The form has no box for them.', 'icon': 'delapouite/stamper', 'side': 'player', 'harmful': True, 'kind': 'ban_type', 'type': 'tool'},
        {'name': 'Expedited', 'text': 'Your units get +1/+0.', 'icon': 'delapouite/stamper', 'side': 'player', 'kind': 'stat', 'atk': 1, 'def': 0},
    ], [], 'Tool decks are refused at the desk; unit decks are waved through faster'),
    'Returns Clerk': ('D-HFA', 4, [
        {'name': 'Refund Policy', 'text': 'At the start of its turn the Clerk heals 1.', 'icon': 'delapouite/scroll-quill', 'kind': 'start_of_turn_heal', 'amount': 1},
        {'name': 'Receipt Kept', 'text': 'You start the fight with a Contract (pay 1, use it: exhaust target unit).', 'icon': 'delapouite/scroll-quill', 'side': 'player', 'kind': 'starting_resources', 'resource': 'contract', 'count': 1},
    ], [], 'a slow grind punishes slow decks; a Contract to stop its best blocker'),
    'Resurrection Permits Zombie': ('D-HFA', 9, [
        {'name': 'Burial Fees Waived', 'text': 'Your Necrocrat cards cost 1 less.', 'icon': 'lorc/tombstone', 'side': 'player', 'kind': 'cost_change', 'path': 'necrocrat', 'amount': -1},
    ], [
        {'id': 'zf_permit', 'name': 'Permit Granted', 'icon': 'lorc/tombstone', 'when': {'type': 'units_died', 'count': 2, 'side': 'own'},
         'text': 'When two of its units have died, a permit is granted: two 1/1 Zombie Temps climb back up.',
         'effects': [{'kind': 'summon', 'token': 'T-10', 'count': 2}], 'banner': 'Permit granted: two 1/1 Zombie Temps climb back up.'},
    ], 'trading units feeds it more; a Necrocrat deck pays less'),
    'Executive Elevator Operator': ('D-HFA', 13, [
        {'name': 'Express Lift', 'text': 'Your units with Flying get +1 attack. The shaft goes all the way up.', 'icon': 'delapouite/elevator', 'side': 'player', 'kind': 'keyword_stat', 'keyword': 'flying', 'atk': 1},
    ], [
        {'id': 'zf_floor_four', 'name': 'Going Up', 'icon': 'delapouite/elevator', 'when': {'type': 'turn', 'turn': 4},
         'text': "On its 4th turn the lift reaches the executive floors: the Operator's units get +1/+1.", 'effects': [{'kind': 'buff', 'atk': 1, 'def': 1}],
         'warn': 'Next turn: the lift reaches the executive floors (its units +1/+1).', 'banner': "Executive floors: the Operator's units get +1/+1."},
    ], 'win before the lift reaches the top; flyers get there first'),
    # ---- The Rotheart (Refusemancer) -------------------------------------------------------------------------------------------------
    'Overgrown Scarecrow': ('D-ROT', 2, [
        {'name': 'Crows', 'text': 'Every third turn of its, a 1/1 Crow with Flying flaps in.', 'icon': 'lorc/feathered-wing', 'kind': 'timed_summon', 'token': 'T-22', 'token_name': 'Crow', 'token_keywords': ['FLYING'], 'every': 3},
        {'name': 'Shoo!', 'text': 'Your units with Swat get +1 attack. Swatters can block flyers.', 'icon': 'lorc/feathered-wing', 'side': 'player', 'kind': 'keyword_stat', 'keyword': 'swat', 'atk': 1},
    ], [], 'flyers come in over a slow deck; units that can swat them get stronger'),
    'Mutant Mushroom Troop': ('D-ROT', 3, [
        {'name': 'Spore Cloud', 'text': 'At the start of its turn, you take 1 damage.', 'icon': 'delapouite/mushrooms-cluster', 'kind': 'start_of_turn_damage', 'amount': 1},
        {'name': 'Fungal Feast', 'text': 'Your tokens get +1/+1.', 'icon': 'delapouite/mushrooms-cluster', 'side': 'player', 'kind': 'token_stats', 'atk': 1, 'def': 1},
    ], [], 'a clock against slow decks; token decks grow faster'),
    'Thorn Maze Stalker': ('D-ROT', 8, [
        {'name': 'Thorns', 'text': 'Each unit that attacks the Stalker takes 1 damage.', 'icon': 'delapouite/tree-roots', 'kind': 'retaliate', 'amount': 1},
        {'name': 'Hedge Cutter', 'text': 'Your units with Bulldoze get +1 attack.', 'icon': 'delapouite/tree-roots', 'side': 'player', 'kind': 'keyword_stat', 'keyword': 'bulldoze', 'atk': 1},
    ], [
        {'id': 'zf_clearing', 'name': 'A Clearing', 'icon': 'delapouite/tree-roots', 'when': {'type': 'turn', 'turn': 5},
         'text': 'On its 5th turn you find a clearing in the maze: you heal 3.', 'effects': [{'kind': 'foe_heal', 'amount': 3}],
         'warn': 'Next turn: the thorns thin out ahead (a clearing: you heal 3).', 'banner': 'A clearing in the maze: you heal 3.'},
    ], 'small attackers bleed on the thorns; big tramplers cut through'),
    'Rot Tunnel Horror': ('D-ROT', 11, [
        {'name': 'Bad Air', 'text': 'No one can use Garbage in this fight. The tunnel air spoils it.', 'icon': 'lorc/skull-crack', 'side': 'player', 'harmful': True, 'kind': 'block_resource', 'resource': 'garbage'},
        {'name': 'Fresh Draught', 'text': 'At the start of your turn you heal 1.', 'icon': 'lorc/leaf-swirl', 'side': 'player', 'kind': 'start_of_turn_heal', 'amount': 1},
    ], [], 'a Garbage plan stalls; any deck heals a little each turn'),
    # ---- Primm's Castle (the ordinary fights; the castle was tuned on Nov 21-25, so these are mild) ---------------------------------
    'Hedge Trimmer Guard': ('D-PC', 3, [
        {'name': 'Pruning Shears', 'text': "The Guard's units have Sucker Punch: they deal combat damage first.", 'icon': 'lorc/leaf-swirl', 'kind': 'keyword', 'keyword': 'sucker_punch'},
        {'name': 'Overgrowth', 'text': 'Your units get +0/+1.', 'icon': 'lorc/leaf-swirl', 'side': 'player', 'kind': 'stat', 'atk': 0, 'def': 1},
    ], [], 'its units strike first; sturdier units survive it'),
    'Gallery Curator': ('D-PC', 5, [
        {'name': 'Do Not Touch', 'text': 'You cannot play Wonders in this fight. Please do not touch the exhibits.', 'icon': 'delapouite/portrait', 'side': 'player', 'harmful': True, 'kind': 'ban_type', 'type': 'wonder'},
        {'name': 'Audio Guide', 'text': 'You draw an extra card on your first turn.', 'icon': 'delapouite/portrait', 'side': 'player', 'kind': 'first_turn_draw', 'count': 1},
    ], [
        {'id': 'zf_restoration', 'name': 'Restoration', 'icon': 'delapouite/portrait', 'when': {'type': 'hp_below', 'pct': 50},
         'text': 'At half health the Curator restores a portrait: it heals 3.', 'effects': [{'kind': 'heal', 'amount': 3}],
         'banner': 'The Curator heals 3.'},
    ], 'Wonder decks are turned away at the rope; everyone gets the audio guide (and a deck change: gourmand_refusemancer)'),
    'Ministry Clerk': ('D-PC', 12, [
        {'name': 'Correction Quota', 'text': 'You may play at most 3 cards a turn (Infrastructure does not count).', 'icon': 'delapouite/stamper', 'side': 'player', 'harmful': True, 'kind': 'max_plays', 'count': 3},
        {'name': 'Approved Stamp', 'text': 'Your Pathless cards cost 1 less.', 'icon': 'delapouite/stamper', 'side': 'player', 'kind': 'cost_change', 'path': 'neutral', 'amount': -1},
    ], [], 'a cap on very wide turns; Pathless cards come cheaper'),
}

# What each foe says when its new beat fires (every shipped scripted event has a line: tests/core/dungeon/test_encounter_scripts.gd)
LINES = {
    'zf_staff_meal': "Staff meal's up! Eat it before it gets cold. Even you. Especially you.",
    'zf_permit': "Permit approved. They're allowed back up now. Rules are rules.",
    'zf_floor_four': "Executive floors. Mind the doors. Mind the executives.",
    'zf_clearing': "*The thorns part for a moment. There's a patch of sun and a clean puddle.*",
    'zf_restoration': "A dab here, a dab there... good as new. Better, even.",
}

# Deck changes that break up repeated archetypes (room -> deck)
DECKS = {
    ('D-HOG', 8): 'necrocrat_beefcake',
    ('D-PC', 5): 'gourmand_refusemancer',
}


def load(path):
    return json.load(io.open(path, encoding='utf-8'))


def save(path, data):
    io.open(path, 'w', encoding='utf-8', newline='\n').write(json.dumps(data, indent='\t', ensure_ascii=False) + '\n')


def main():
    mods = load(MODS)
    scripts = load(SCRIPTS)
    content = load(CONTENT)
    rows = []
    for foe, (dungeon, room, rules, events, idea) in FOES.items():
        kept = [r for r in mods.get(foe, []) if not r.get('nov26')]
        added = [dict(r, nov26=True) for r in rules]
        mods[foe] = kept + added
        old_events = [e for e in scripts.get(foe, []) if not str(e.get('id', '')).startswith('zf_')]
        for event in events:
            if event['id'] in LINES:
                event['line'] = LINES[event['id']]
        if old_events or events:
            scripts[foe] = old_events + events
        rows.append({'dungeon': dungeon, 'room': room, 'foe': foe, 'idea': idea,
                     'rules_before': ['%s: %s' % (r['name'], r['text']) for r in kept],
                     'rules_added': ['%s: %s' % (r['name'], r['text']) for r in added],
                     'events_before': [e.get('text', '') for e in old_events], 'events_added': [e['text'] for e in events]})
    foes = content['dungeons']
    for (dungeon, room), deck in DECKS.items():
        entry = foes[dungeon]['foes'][str(room)]
        if isinstance(entry, dict):
            entry['deck'] = deck
    save(MODS, mods)
    save(SCRIPTS, scripts)
    save(CONTENT, content)
    os.makedirs(os.path.dirname(RULES_JSON), exist_ok=True)
    save(RULES_JSON, rows)
    print('zone fights updated: %d' % len(FOES))


if __name__ == '__main__':
    main()
