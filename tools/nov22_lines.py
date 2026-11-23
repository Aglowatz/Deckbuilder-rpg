"""Fable Nov 22 night: writes docs/dialogue/nov22_lines.csv, the new player-facing lines of this pass (for the owner's sheet), and
docs/dialogue/nov22_lines_ids.txt (the ids the dialogue importer could revert: none this pass - every new line lives in code, and no
existing dialogue line was changed).   python tools/nov22_lines.py"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
WHERE = "Primm's Castle, the Notarized Archives (room 11), after the fight: the Archivists' Kettle"
SRC = 'core/dungeon/primms_castle_dungeon.gd::rest_event'
ROWS = [
    (SRC + '::title', WHERE, '(title)', "The Archivists' Kettle"),
    (SRC + '::body', WHERE, '(narration)', 'Behind the last shelf of the Notarized Archives somebody keeps a kettle, a tin of biscuits and an honesty box. The kettle is still warm. A card on the tin says: "Tea and two biscuits, 60 gold. Receipts on request."'),
    (SRC + '::choice/0', WHERE, '(choice: heal 6, pay 60 gold)', 'Pay the honesty box and sit down'),
    (SRC + '::result/0', WHERE, '(narration)', 'Sixty coins rattle into the box. The tea is strong, the biscuits are plain, and for five minutes nobody stamps anything.'),
    (SRC + '::choice/1', WHERE, '(choice: heal 6; the next foe\'s units get +1 attack: "Two Biscuits Short")', 'Help yourself and skip the box'),
    (SRC + '::result/1', WHERE, '(narration)', 'The tea is just as good unpaid for. Somebody has counted these biscuits, though, and the count goes upstairs ahead of you.'),
    (SRC + '::choice/2', WHERE, '(choice: nothing)', 'Leave the kettle for the clerks'),
    (SRC + '::result/2', WHERE, '(narration)', 'You straighten the tin and walk on. The kettle goes on ticking as it cools.'),
    ('core/dungeon/castle_allies.gd::REST_LINE', "Primm's Castle map, the tooltip of room 11", '(tooltip)', "After the fight: the archivists' kettle (heal 6 for 60 gold or for a drawback)."),
    ('data/dungeons/dungeon_content.json::D-PC/blurbs/11', "Primm's Castle map, room 11", '(room blurb)', "A tougher fight against the clock: Percival Plume and his red tape. Afterwards, the archivists' kettle: heal 6 for a cost."),
    ('core/arena/arena_content.gd::gladiators_net', 'Equipment text', "Gladiator's Net", 'The first enemy unit to enter the field each turn gets -1/-1 permanently.'),
    ('core/data/progression_content.gd::siphons_lens', 'Equipment text', "Siphon's Lens", 'A glass lens from the draining chamber, ground to see all four Paths at once. You draw an extra card each turn. Max HP -2.'),
    ('core/data/expansion_gear.gd::glass_jaw_gauntlets', 'Equipment text', 'Glass Jaw Gauntlets', 'Your units get +2 attack. Max HP -6.'),
    ('core/data/progression_content.gd::dex_matching_pair', 'Equipment text', "Dex's Matching Pair", 'Once each turn, when you play your first non-Infrastructure card, if it costs 3 or less, draw a copy of that card from your deck (if there is one).'),
    ('core/data/progression_content.gd::hover_boots', 'Equipment text', 'Hover Boots', "A finger's width of clearance, always. Your units have Flying, and can block only units with Flying."),
    ('core/data/expansion_gear.gd::velvet_rope', 'Equipment text', 'Velvet Rope', 'Your Gourmand units get +1/+2. They have Wallflower (they cannot attack).'),
    ('core/dungeon/castle_allies.gd::HELP_NAMES/beefcake', "Primm's fight, a rule badge", '(rule name)', 'Grandmaster Flex Stands with You'),
    ('data/encounters/encounter_scripts.json::Betty Bones', "The Waiting Room's boss, a scripted event", '(event name)', 'Forms A through F'),
]


def main():
    out = io.StringIO()
    writer = csv.writer(out, quoting=csv.QUOTE_ALL, lineterminator='\n')
    writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
    for line_id, where, speaker, text in ROWS:
        writer.writerow([line_id, "Primm's Castle" if 'Castle' in where else 'Items and rules', speaker, where, '', text])
    folder = os.path.join(ROOT, 'docs', 'dialogue')
    io.open(os.path.join(folder, 'nov22_lines.csv'), 'w', encoding='utf-8', newline='').write(out.getvalue())
    io.open(os.path.join(folder, 'nov22_lines_ids.txt'), 'w', encoding='utf-8', newline='').write(
        '# Fable Nov 22 night: no line of the dialogue files was changed, so there is nothing for the importer to revert.\n'
        '# The new lines of docs/dialogue/nov22_lines.csv live in code and data (see their IDs); revert them with git.\n')
    print('%d lines' % len(ROWS))


if __name__ == '__main__':
    main()
