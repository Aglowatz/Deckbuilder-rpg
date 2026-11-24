"""Fable big pass Nov 23: the record of the lines this pass wrote or rewrote (Trey Pickett, Octavia Eightfold, the arena and main
quest lines), in the dialogue workbook's format, with the ids file `--revert` reads.
    python tools/nov23_dialogue_record.py <lines_before.json>
`lines_before.json`: {key: [old lines]} as the keys stood before the pass (absent key = a new line, reverted to nothing).
Writes docs/dialogue/nov23_lines.csv and docs/dialogue/nov23_lines_ids.txt."""
import csv
import io
import json
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SOURCE = 'data/dungeons/dungeon_content.json'
PREFIXES = ('drafthost.', 'drafthouse.', 'quest.main_shuffle_house.', 'quest.arena_', 'quest.draft_')


def speaker(key):
    if key.startswith('drafthost.'):
        return 'Trey Pickett', 'Every Path zone'
    return 'Octavia Eightfold', 'Crosspath (the Shuffle House)'


def as_lines(value):
    if isinstance(value, list):
        return [str(v) for v in value]
    return [str(value)]


def main():
    before = json.load(io.open(sys.argv[1], encoding='utf-8')) if len(sys.argv) > 1 else {}
    data = json.load(io.open(os.path.join(ROOT, SOURCE), encoding='utf-8'))
    text = data.get('text', {})
    rows = []
    ids = []
    for key in sorted(text.keys()):
        if not key.startswith(PREFIXES):
            continue
        new = as_lines(text[key])
        old = as_lines(before[key]) if key in before else []
        if new == old:
            continue
        who, where = speaker(key)
        for i, line in enumerate(new):
            row_id = '%s::%s::%d' % (SOURCE, key, i)
            rows.append([row_id, where, who, key, old[i] if i < len(old) else '', line])
            ids.append(row_id)
    out = os.path.join(ROOT, 'docs', 'dialogue', 'nov23_lines.csv')
    with io.open(out, 'w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        writer.writerows(rows)
    with io.open(os.path.join(ROOT, 'docs', 'dialogue', 'nov23_lines_ids.txt'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('# Fable big pass Nov 23: the lines of docs/dialogue/nov23_lines.csv (node tools/apply_dialogue_pass.js --revert=docs/dialogue/nov23_lines_ids.txt)\n')
        handle.write('\n'.join(ids) + '\n')
    print('%d lines recorded' % len(rows))


if __name__ == '__main__':
    main()
