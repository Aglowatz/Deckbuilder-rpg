"""Fable Nov 24: the record of the lines this pass wrote or rewrote, for the owner's review and for --revert.
It exports every dialogue line of the game as it stood at the start tag and as it stands now (tools/export_dialogue.js, in a
temporary git worktree for the tag) and keeps the rows that differ. Writes:
  docs/dialogue/nov24_lines.csv                 ID, Zone/Area, Speaker, When it's heard, Current line (before the pass), New line
  docs/dialogue/nov24_lines_ids.txt             the ids of the lines that EXISTED before and were changed (the revertible ones)
  docs/dialogue/nov24_lines/applied_ledger.json the importer's ledger for those ids, so this works:
      node tools/apply_dialogue_pass.js --revert=docs/dialogue/nov24_lines_ids.txt
Brand-new lines (a new dealer's mid-fight lines, the Counting Halls' room) are in the CSV with an empty "Current line"; they are
not in the ids file: taking the words out of a new encounter would break it, and the encounter itself is undone with git.
    python tools/nov24_dialogue_record.py [--tag=pre-nov24-shuffle]"""
import csv
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
OUT = os.path.join(ROOT, 'docs', 'dialogue')
NAME = 'nov24_lines'


def export(tree, out_csv):
    subprocess.run(['node', 'tools/export_dialogue.js', '--out=%s' % out_csv], cwd=tree, check=True, stdout=subprocess.DEVNULL)
    with io.open(out_csv, encoding='utf-8-sig', newline='') as handle:
        rows = list(csv.reader(handle))
    return {row[0]: row for row in rows[1:] if row}


def main():
    tag = 'pre-nov24-shuffle'
    for raw in sys.argv[1:]:
        if raw.startswith('--tag='):
            tag = raw.split('=', 1)[1]
    scratch = tempfile.mkdtemp(prefix='nov24_dialogue_')
    tree = os.path.join(scratch, 'pre')
    subprocess.run(['git', 'worktree', 'add', '--detach', tree, tag], cwd=ROOT, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        # the exporter of the tag does not know the Halls' dealers; they had no lines then, so its own table is enough
        before = export(tree, os.path.join(scratch, 'before.csv'))
    finally:
        subprocess.run(['git', 'worktree', 'remove', '--force', tree], cwd=ROOT, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    now = export(ROOT, os.path.join(scratch, 'now.csv'))
    shutil.rmtree(scratch, ignore_errors=True)
    rows = []
    ids = []
    ledger = []
    for row_id, row in now.items():
        old = before.get(row_id)
        if old is not None and old[4] == row[4]:
            continue
        rows.append([row_id, row[1], row[2], row[3], old[4] if old is not None else '', row[4]])
        if old is not None:
            ids.append(row_id)
            ledger.append({'id': row_id, 'file': row_id.split('::', 1)[0], 'speaker': row[2], 'before': old[4], 'after': row[4]})
    removed = [row_id for row_id in before if row_id not in now]
    with io.open(os.path.join(OUT, NAME + '.csv'), 'w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.writer(handle, quoting=csv.QUOTE_ALL)
        writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
        writer.writerows(rows)
    with io.open(os.path.join(OUT, NAME + '_ids.txt'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('# Fable Nov 24: the lines of docs/dialogue/nov24_lines.csv that existed before the pass and were changed '
            '(node tools/apply_dialogue_pass.js --revert=docs/dialogue/nov24_lines_ids.txt)\n')
        handle.write('\n'.join(ids) + ('\n' if ids else ''))
    os.makedirs(os.path.join(OUT, NAME), exist_ok=True)
    with io.open(os.path.join(OUT, NAME, 'applied_ledger.json'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write(json.dumps(ledger, indent='\t', ensure_ascii=False) + '\n')
    print('%d lines recorded: %d changed (revertible), %d new; %d ids of the start tag are gone' % (len(rows), len(ids), len(rows) - len(ids), len(removed)))
    for row_id in removed[:40]:
        print('  gone: %s' % row_id)


if __name__ == '__main__':
    main()
