"""Nov 25 night (Part G): the new encounter library, spread through the dungeons (postgame first, then the zone dungeons), as choices of
their existing event rooms (no map changes; every story beat stays). Each choice says in brackets what it checks and what is at stake
before the player commits (the outcome hints, `DungeonEvent.Outcome.describe`). Run-only changes (a shredded card, a curse) end with
the run; the save always keeps the real deck.
Library (the owner's examples first):
  L1 Brittle Troops      curse: your units get -2 defence for the run (a postgame puzzle)          S-GALLERY 3
  L2 Silent Glass        curse: no spells for the run                                               S-GALLERY 12
  L3 No Traps Allowed    curse: no traps for three fights, for +6 max HP as long                   D-PC 6
  L4 One Thing at a Time curse: one card a turn for two fights, with an extra draw                  D-PC 4
  L5 The Head Chef       check: enough Gourmand units, a boon; too few, 5 HP                       D-TTK 10
  L6 The Specimen Trial  check: a random unit revealed; strong enough, a boon; too weak, every copy shredded for the run   D-LAB 4
  L7 The Hedge-Wizard    boon NPC: the first Trap you set each turn is set twice                    D-LAB 7
  L8 The Reflected Patrol patrol: every Wonder you carry shredded for the run                       S-GALLERY 6
  L9 The Night Patrol    patrol: every Tool shredded for the run, for gold                          D-HFA 12
  L10 Path roll-calls    check: Beefcake / Necrocrat / Refusemancer units, a boon or HP             D-HOG 5, D-HFA 8, D-ROT 7
Writes data/dungeons/dungeon_content.json in place and docs/design/encounter_library.md. Idempotent.
    python tools/nov25n_encounter_library.py"""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
CONTENT = os.path.join(ROOT, 'data', 'dungeons', 'dungeon_content.json')
DOC = os.path.join(ROOT, 'docs', 'design', 'encounter_library.md')

# (library id, type, dungeon, event room, action, old label or None, new choice [label, result, tokens...])
PLACEMENTS = [
    ('L1', 'Brittle Troops (curse)', 'S-GALLERY', '3', 'replace', 'Leave it on the rack',
     ['Leave it on the rack', 'You walk past. For the rest of the gallery every reflection you pass is lifting it for you, and your own troops feel thinner for it.', 'curse:Brittle Glass|def=-2']),
    ('L8', 'The Reflected Patrol (patrol)', 'S-GALLERY', '6', 'replace', 'Refuse to sign',
     ['Refuse to sign', 'A patrol of reflected clerks marches out of the frame to process your refusal. They stamp every Wonder you carry VOID and feed it to the glass. The frame thanks you for your cooperation.', 'shred_type:wonder']),
    ('L2', 'Silent Glass (curse)', 'S-GALLERY', '12', 'replace', 'Look it in the eye',
     ['Look it in the eye', 'You hold its gaze until it blinks. You come away knowing yourself a little better, and the glass keeps your voice: no spell will leave your lips while you are in here.', 'boon:Know Yourself|atk=1,def=1', 'curse:Silent Glass|ban_spell=1', 'hint:your units +1/+1 for the gallery; no spells for the gallery']),
    ('L6', 'The Specimen Trial (check)', 'D-LAB', '4', 'replace', 'Read the notes on the Subject',
     ['Put a unit through the Specimen Trial', 'Behind the glass a very large, very old lizard opens one eye. The clipboard on the wall says SPECIMEN TRIAL: ONE SUBJECT, ONE ROUND. You send someone in.', 'reveal_unit:4|Passed the Trial|atk=1,def=1']),
    ('L7', 'The Hedge-Wizard (boon NPC)', 'D-LAB', '7', 'replace', 'Tear out the straps',
     ['Free the hedge-wizard strapped in beside it', 'You tear the straps loose and a small furious wizard in a hospital gown climbs out, rubbing his wrists. "Traps," he says. "I do traps. Set one and I will set it again." The straps bite you on the way.', 'boon:The Wizard\'s Echo|trap_copy=1', 'damage:3', 'hint:lose 3 HP; your first Trap each turn is set twice, for the dungeon']),
    ('L5', 'The Head Chef (check)', 'D-TTK', '10', 'replace', 'Pocket the recipe marked DO NOT SERVE',
     ['Cook for the head chef\'s tasting', 'The head chef appears from nowhere with a spoon and a very long face. "Show me your brigade," he says, and counts your cooks.', 'check_units:gourmand,6,5|Head Chef\'s Nod|atk=1']),
    ('L10', 'Roll-call: Beefcake (check)', 'D-HOG', '5', 'append', None,
     ['Show the coach your roster', 'A whistle blows. The ghost of a coach with a clipboard looks over your lifters one by one.', 'check_units:beefcake,7,4|Coach\'s Pick|def=1']),
    ('L10', 'Roll-call: Necrocrat (check)', 'D-HFA', '8', 'append', None,
     ['Submit your deck for audit', 'The clerk takes your deck, licks a thumb and counts the dead. "Staffing levels," he murmurs, "are being reviewed."', 'check_units:necrocrat,6,4|Clean Audit|max_hp=4']),
    ('L10', 'Roll-call: Refusemancer (check)', 'D-ROT', '7', 'append', None,
     ['Sort the pool\'s junk into bins', 'You roll up your sleeves and sort. The pool watches to see whether you know your own kind.', 'check_units:refusemancer,6,4|Sorted|draw=1']),
    ('L9', 'The Night Patrol (patrol)', 'D-HFA', '12', 'replace', 'Shred a spare appeal',
     ['Let the night patrol inspect your Tools', 'A patrol of clerks with torches confiscates every Tool you carry "for processing" and, in fairness, pays a filing fee for the trouble.', 'shred_type:tool', 'gold:120', 'hint:gain 120 gold; every Tool in your deck is shredded for this run']),
    ('L3', 'No Traps Allowed (curse)', 'D-PC', '6', 'append', None,
     ['Swear the Regime\'s oath of order', 'You put a hand on the portrait and swear to keep things tidy. You feel stronger and strangely unable to leave anything lying around for anyone.', 'boon:Oath of Order|max_hp=6,next=3', 'curse:No Traps Allowed|ban_trap=1,next=3', 'hint:next three fights: +6 max HP, but no traps']),
    ('L4', 'One Thing at a Time (curse)', 'D-PC', '4', 'append', None,
     ['Follow the Doppelganger\'s schedule', 'You find its timetable: one task at a time, very quickly, all day. For the next two fights you will be the same.', 'boon:On Schedule|draws=1,next=2', 'curse:One Thing at a Time|one_card=1,next=2', 'hint:next two fights: draw 1 more each turn, but play only one card a turn']),
]

# Choices an earlier run of this tool placed that were taken out again (the zone heal rooms keep their Nov 21 template: heal 5 for a
# cost, or nothing; an event room has at most 4 choices): (dungeon, room, label)
REMOVED = [
    ('D-TTK', '9', "Cook for the head chef's tasting"),
    ('D-TTK', '10', 'Feed a unit to the Taste-Test Rex'),
    ('D-HOG', '10', 'Take the vow of the quiet mat'),
]


def main():
    data = json.load(io.open(CONTENT, encoding='utf-8'))
    dungeons = data['dungeons']
    rows = ['# The encounter library (Nov 25 night, Part G)', '',
            'Written by `tools/nov25n_encounter_library.py`, which also places them. Each is a choice of an existing event room (no map '
            'changes); the button says in brackets what it checks and what is at stake. Run-only changes end with the run. Audit and plan: '
            '`encounter_upgrades.md`.', '', '| Id | Type | Where | The choice | What it does |', '|---|---|---|---|---|']
    for dungeon, room, label in REMOVED:
        choices = dungeons[dungeon]['events'][room]['choices']
        dungeons[dungeon]['events'][room]['choices'] = [c for c in choices if c[0] != label]
    for lib, kind, dungeon, room, action, old_label, choice in PLACEMENTS:
        event = dungeons[dungeon]['events'][room]
        choices = event['choices']
        labels = [c[0] for c in choices]
        if action == 'replace':
            index = labels.index(old_label) if old_label in labels else labels.index(choice[0])
            choices[index] = choice
        elif choice[0] in labels:
            choices[labels.index(choice[0])] = choice
        else:
            choices.append(choice)
        rows.append('| %s | %s | %s %s "%s" | %s | `%s` |' % (lib, kind, dungeon, room, event.get('title', ''), choice[0], ', '.join(choice[2:])))
    io.open(CONTENT, 'w', encoding='utf-8', newline='\n').write(json.dumps(data, indent='\t', ensure_ascii=False) + '\n')
    io.open(DOC, 'w', encoding='utf-8', newline='\n').write('\n'.join(rows) + '\n')
    print('placed %d' % len(PLACEMENTS))


if __name__ == '__main__':
    main()
