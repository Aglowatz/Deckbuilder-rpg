"""Nov 26 day: writes docs/dialogue/nov26_lines.csv, the new player-facing lines of this pass (for the owner's sheet): the zone fight
rules and scripted beats of Part C (names, texts, the foes' spoken lines), the Extra Pocket's new text and the item button's reason
(Part B). And docs/dialogue/nov26_lines_ids.txt: the ids the dialogue importer could revert - none this pass (every line is new, or
lives in code/data the importer does not own).   python tools/nov26_lines.py"""
import csv
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
RULES = os.path.join(ROOT, 'docs', 'design', 'sim', 'nov26', 'zone_fight_rules.json')
MODS = os.path.join(ROOT, 'data', 'encounters', 'modifiers.json')
SCRIPTS = os.path.join(ROOT, 'data', 'encounters', 'encounter_scripts.json')
OUT = os.path.join(ROOT, 'docs', 'dialogue', 'nov26_lines.csv')
IDS = os.path.join(ROOT, 'docs', 'dialogue', 'nov26_lines_ids.txt')
NAMES = {'D-HOG': 'The House of Gains', 'D-TTK': 'The Test Kitchen', 'D-HFA': 'The Hall of Final Approvals', 'D-ROT': 'The Rotheart', 'D-PC': "Primm's Castle"}


def main():
    rules = json.load(io.open(RULES, encoding='utf-8'))
    mods = json.load(io.open(MODS, encoding='utf-8'))
    scripts = json.load(io.open(SCRIPTS, encoding='utf-8'))
    rows = []
    for row in rules:
        foe = row['foe']
        where = '%s, room %d' % (NAMES[row['dungeon']], row['room'])
        for index, rule in enumerate(mods.get(foe, [])):
            if not rule.get('nov26'):
                continue
            rows.append(('data/encounters/modifiers.json::%s/%d/name' % (foe, index), where, '(rule badge)', 'Before the fight vs %s: rule name' % foe, '', rule['name']))
            rows.append(('data/encounters/modifiers.json::%s/%d/text' % (foe, index), where, '(rule badge)', 'Before the fight vs %s: rule text' % foe, '', rule['text']))
        for index, event in enumerate(scripts.get(foe, [])):
            if not str(event.get('id', '')).startswith('zf_'):
                continue
            base = 'data/encounters/encounter_scripts.json::%s/%d' % (foe, index)
            rows.append((base + '/name', where, '(battle UI)', 'Mid-fight event vs %s: event name' % foe, '', event['name']))
            rows.append((base + '/text', where, '(battle UI)', 'Mid-fight event "%s" vs %s: what can happen (rule text)' % (event['name'], foe), '', event['text']))
            if event.get('warn'):
                rows.append((base + '/warn', where, '(battle UI)', 'Mid-fight event "%s": the warning the turn before' % event['name'], '', event['warn']))
            rows.append((base + '/banner', where, '(battle UI)', 'Mid-fight event "%s": the banner when it fires' % event['name'], '', event['banner']))
            rows.append((base + '/line', where, foe, 'Mid-fight event "%s" vs %s: the foe says it when the event fires' % (event['name'], foe), '', event['line']))
    rows.append(('data/equipment/extra_pocket.tres::description', 'Equipment text', 'Extra Pocket',
                 'The Extra Pocket\'s description (Character page, shops, drafts)', 'You can use each equipped item twice per battle (each use spends a charge).',
                 'You can use each equipped item twice per battle. The first use spends one copy; the second is free, even if it was your last copy.'))
    rows.append(('ui/battle/battle_screen.gd::why_item_spent', 'Battle', '(battle UI)', 'Pressing an item already used up this fight, with the Extra Pocket', '',
                 'Each item works twice per battle (Extra Pocket): this one is used up for this fight'))
    rows.append(('ui/battle/item_bar.gd::uses_left_tooltip', 'Battle', '(tooltip)', 'An item\'s tooltip in a fight, with the Extra Pocket', '',
                 'Uses left this fight: N (the Extra Pocket: the first use spends a copy, the second is free).'))
    with io.open(OUT, 'w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        writer.writerows(rows)
    io.open(IDS, 'w', encoding='utf-8', newline='\n').write(
        '# Nov 26 day: the lines of docs/dialogue/nov26_lines.csv that existed before the pass and were changed through the dialogue importer: none\n'
        '# (the new rules and beats are new; the Extra Pocket text lives in data/equipment/extra_pocket.tres - revert it with git if wanted)\n')
    print('rows:', len(rows))


if __name__ == '__main__':
    main()
