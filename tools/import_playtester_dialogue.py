#!/usr/bin/env python3
"""Overnight Nov 9-10: turns the playtesters' returned dialogue workbooks into one clean CSV for tools/apply_dialogue_pass.js.

The workbook is docs/dialogue/playtesters_nov9.xlsx. Each tester returns a copy with rewrites in the "Dialogue" tab:
the ID in column B, the New line in column H, Notes in M and the Reviewer in N (found by header name first, those letters as fallback).

    python tools/import_playtester_dialogue.py returned/alice.xlsx returned/bob.xlsx [--out=docs/dialogue/playtesters_nov9_merged.csv]

What it does, per returned file:
  - reads the "Dialogue" tab with the standard library only (an .xlsx is a zip of XML; no openpyxl needed);
  - ignores rows whose New line is empty (or the same as the game's line);
  - validates every rewrite against the game's CURRENT text (node tools/export_dialogue.js, run into a temp folder):
      * the ID exists in the game;
      * every {token}, [tag] and %s/%d of the current line is kept (as many times as it appears);
      * one line (no line breaks) and the length limit: 240 characters, or 90 for barks (data/npcs/npcs.json barks);
  - checks the sheet's structure against the original workbook (--template): rows added, removed or reordered are reported, and rows
    are always matched by ID, never by position (an added row is rejected: its ID is not in the game);
  - two testers rewriting the same line differently is a CONFLICT: both versions go in the report and neither is accepted (the owner decides).
    Identical rewrites from two testers count once.

Writes:
  - <out>.csv: ID, Zone/Area, Speaker, When it's heard, Current line, New line, Reviewer, Notes - the accepted rows only, in the format
    `node tools/apply_dialogue_pass.js --csv=<out>.csv` reads (Current line = the game's line now, so the importer matches it);
  - <out>/export_snapshot.json (id -> the game's line), which the importer uses when a spreadsheet re-encoded a cell;
  - <out>_report.md: accepted lines, rejected lines with the reason, conflicts with both versions, structure warnings.
Exit code 0 when it ran (even with rejections); 2 on a usage error or an unreadable file.

The three-command workflow (docs/HANDOFF.md, section 5):
    python tools/import_playtester_dialogue.py <returned .xlsx files>              # 1. convert + validate
    node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv            # 2. dry run (report only)
    node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv --apply    # 3. apply (--revert puts it back)
"""
import csv
import json
import os
import re
import subprocess
import sys
import tempfile
import zipfile
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_OUT = 'docs/dialogue/playtesters_nov9_merged.csv'
DEFAULT_TEMPLATE = 'docs/dialogue/playtesters_nov9.xlsx'
SHEET = 'Dialogue'
MAX_CHARS = 240
MAX_BARK = 90
NS_MAIN = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
NS_REL = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
NS_PKG = 'http://schemas.openxmlformats.org/package/2006/relationships'
# Header names in the workbook (lower case, prefix match) and the column letters they had when it was made.
COLUMNS = {
    'id': (('id',), 'B'),
    'zone': (('zone',), 'C'),
    'speaker': (('speaker',), 'D'),
    'when': (("when it",), 'E'),
    'current': (('current line',), 'F'),
    'new': (('new line',), 'H'),
    'limit': (('limit',), 'J'),
    'notes': (('notes',), 'M'),
    'reviewer': (('reviewer',), 'N'),
}
TOKEN_RE = re.compile(r'\{[a-z_]+\}|\[[A-Za-z_][A-Za-z0-9_ -]*\]|%[sd]')


# ---- reading an .xlsx with the standard library -------------------------------------------------------------------------------------


def _col_index(ref):
    letters = re.match(r'[A-Z]+', ref).group(0)
    n = 0
    for ch in letters:
        n = n * 26 + (ord(ch) - 64)
    return n - 1


def _letter_index(letter):
    return _col_index(letter + '1')


def _cell_text(cell, shared):
    kind = cell.get('t')
    value = cell.find('{%s}v' % NS_MAIN)
    if kind == 's':
        return shared[int(value.text)] if value is not None and value.text is not None else ''
    if kind == 'inlineStr':
        return ''.join(t.text or '' for t in cell.iter('{%s}t' % NS_MAIN))
    if value is None or value.text is None:
        return ''
    text = value.text
    if kind is None and re.fullmatch(r'-?\d+\.0', text):
        text = text[:-2]
    return text


def read_sheet(path, sheet_name=SHEET):
    """The rows of `sheet_name` as lists of strings (missing cells are '')."""
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        shared = []
        if 'xl/sharedStrings.xml' in names:
            for si in ET.fromstring(z.read('xl/sharedStrings.xml')).findall('{%s}si' % NS_MAIN):
                # rich text runs (<r><t>) and plain <t>, but not phonetic hints (<rPh>)
                parts = []
                for child in si:
                    if child.tag == '{%s}t' % NS_MAIN:
                        parts.append(child.text or '')
                    elif child.tag == '{%s}r' % NS_MAIN:
                        parts.extend(t.text or '' for t in child.iter('{%s}t' % NS_MAIN))
                shared.append(''.join(parts))
        workbook = ET.fromstring(z.read('xl/workbook.xml'))
        rels = ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))
        targets = {r.get('Id'): r.get('Target') for r in rels.findall('{%s}Relationship' % NS_PKG)}
        target = None
        for sheet in workbook.iter('{%s}sheet' % NS_MAIN):
            if (sheet.get('name') or '').strip().lower() == sheet_name.lower():
                target = targets.get(sheet.get('{%s}id' % NS_REL))
        if target is None:
            raise ValueError('no "%s" tab' % sheet_name)
        target = target.lstrip('/')
        part = target if target.startswith('xl/') else 'xl/' + target
        root = ET.fromstring(z.read(part))
    rows = []
    for row in root.iter('{%s}row' % NS_MAIN):
        values = []
        for cell in row.findall('{%s}c' % NS_MAIN):
            ref = cell.get('r')
            index = _col_index(ref) if ref else len(values)
            while len(values) < index:
                values.append('')
            values.append(_cell_text(cell, shared))
        rows.append(values)
    return rows


def column_map(header):
    """Field -> column index, by header name (prefix, any case), falling back to the workbook's original letters."""
    lowered = [str(h).strip().lower() for h in header]
    result = {}
    for field, (prefixes, letter) in COLUMNS.items():
        found = None
        for i, name in enumerate(lowered):
            if any(name.startswith(p) for p in prefixes):
                found = i
                break
        result[field] = found if found is not None else _letter_index(letter)
    return result


def sheet_records(path):
    rows = read_sheet(path)
    if not rows:
        raise ValueError('the Dialogue tab is empty')
    cols = column_map(rows[0])
    records = []
    for number, row in enumerate(rows[1:], start=2):
        get = lambda f: (row[cols[f]] if cols[f] < len(row) else '') or ''
        rec = {f: get(f) for f in COLUMNS}
        rec['row'] = number
        if not rec['id'].strip() and not rec['new'].strip():
            continue
        records.append(rec)
    return records


# ---- the game's current lines --------------------------------------------------------------------------------------------------------


def current_lines(export_csv=None):
    """id -> {text, zone, speaker, when} from tools/export_dialogue.js (run into a temp folder unless a CSV is given)."""
    temp = None
    if export_csv is None:
        temp = tempfile.mkdtemp(prefix='playtester_dialogue_')
        export_csv = os.path.join(temp, 'current.csv')
        subprocess.run(['node', os.path.join(ROOT, 'tools', 'export_dialogue.js'), '--out=' + export_csv], cwd=ROOT, check=True,
                       stdout=subprocess.DEVNULL)
    result = {}
    with open(export_csv, encoding='utf-8-sig', newline='') as f:
        for r in csv.DictReader(f):
            result[r['ID']] = {'text': r.get('Current line', ''), 'zone': r.get('Zone/Area', ''), 'speaker': r.get('Speaker', ''),
                               'when': r.get("When it's heard", '')}
    return result


# ---- validation ------------------------------------------------------------------------------------------------------------------------


def is_bark(row_id):
    return row_id.startswith('data/npcs/npcs.json::')


def limit_for(row_id, sheet_limit=''):
    if is_bark(row_id):
        return MAX_BARK
    try:
        value = int(float(sheet_limit))
        if value in (MAX_BARK, MAX_CHARS):
            return value
    except (TypeError, ValueError):
        pass
    return MAX_CHARS


def tokens_of(text):
    counts = {}
    for t in TOKEN_RE.findall(text or ''):
        counts[t] = counts.get(t, 0) + 1
    return counts


def check_row(row_id, new_text, game, sheet_limit=''):
    """The reason a rewrite is rejected, or '' when it is fine."""
    if row_id not in game:
        return 'unknown ID (not a line in the game)'
    if '\n' in new_text or '\r' in new_text:
        return 'more than one line (a line break in the cell)'
    limit = limit_for(row_id, sheet_limit)
    if len(new_text) > limit:
        return 'too long: %d characters, the limit is %d%s' % (len(new_text), limit, ' (bark)' if limit == MAX_BARK else '')
    old = tokens_of(game[row_id]['text'])
    new = tokens_of(new_text)
    missing = []
    for token, count in old.items():
        if new.get(token, 0) < count:
            missing.append(token if count == 1 else '%s x%d' % (token, count))
    if missing:
        return 'dropped token/tag: ' + ', '.join(missing)
    added = [t for t in new if t not in old]
    if added:
        return 'new token/tag the line did not have: ' + ', '.join(added)
    return ''


def structure_notes(name, records, template_ids):
    """Rows added, removed or reordered against the original workbook (matching stays by ID)."""
    notes = []
    ids = [r['id'].strip() for r in records if r['id'].strip()]
    seen = set()
    dupes = sorted({i for i in ids if i in seen or seen.add(i)})
    if dupes:
        notes.append('%s: %d ID(s) appear twice: %s' % (name, len(dupes), ', '.join(dupes[:5])))
    if template_ids is None:
        return notes
    template_set = set(template_ids)
    added = [i for i in ids if i not in template_set]
    removed = [i for i in template_ids if i not in set(ids)]
    if added:
        notes.append('%s: %d row(s) added that the workbook did not have (rejected if they carry a New line): %s' % (name, len(added), ', '.join(added[:5])))
    if removed:
        notes.append('%s: %d row(s) of the workbook are missing (deleted rows; nothing to import from them)' % (name, len(removed)))
    common = [i for i in ids if i in template_set]
    order = {i: n for n, i in enumerate(template_ids)}
    moved = sum(1 for a, b in zip(common, common[1:]) if order[a] > order[b])
    if moved:
        notes.append('%s: rows were sorted or reordered (%d places out of order); matched by ID, so nothing is lost' % (name, moved))
    blank_ids = [r['row'] for r in records if not r['id'].strip() and r['new'].strip()]
    if blank_ids:
        notes.append('%s: New line typed on row(s) with no ID: %s (rejected)' % (name, ', '.join(map(str, blank_ids[:8]))))
    return notes


# ---- main ------------------------------------------------------------------------------------------------------------------------------


def md(text):
    return (text or '').replace('|', '\\|').replace('\n', ' ')


def main(argv):
    opts = {}
    files = []
    for a in argv:
        m = re.match(r'^--([a-z_-]+)(?:=(.*))?$', a)
        if m:
            opts[m.group(1)] = m.group(2) if m.group(2) is not None else True
        else:
            files.append(a)
    if not files:
        print(__doc__)
        return 2
    out = os.path.join(ROOT, opts.get('out', DEFAULT_OUT)) if not os.path.isabs(opts.get('out', DEFAULT_OUT)) else opts['out']
    template = opts.get('template', DEFAULT_TEMPLATE)
    template = template if os.path.isabs(template) else os.path.join(ROOT, template)
    game = current_lines(opts.get('current'))
    template_ids = None
    if os.path.exists(template):
        template_ids = [r['id'].strip() for r in sheet_records(template) if r['id'].strip()]
    notes = []
    proposals = {}  # id -> list of {reviewer, text, notes, file}
    rejected = []
    unchanged = 0
    for path in files:
        name = os.path.basename(path)
        try:
            records = sheet_records(path)
        except (OSError, ValueError, KeyError, zipfile.BadZipFile, ET.ParseError) as error:
            print('cannot read %s: %s' % (path, error))
            return 2
        notes.extend(structure_notes(name, records, template_ids))
        default_reviewer = os.path.splitext(name)[0]
        for r in records:
            new_text = r['new']
            if not new_text.strip():
                continue
            new_text = new_text.strip()
            row_id = r['id'].strip()
            reviewer = r['reviewer'].strip() or default_reviewer
            if not row_id:
                rejected.append({'id': '(row %d, no ID)' % r['row'], 'reviewer': reviewer, 'file': name, 'text': new_text, 'why': 'no ID on the row'})
                continue
            if row_id in game and new_text == game[row_id]['text'].strip():
                unchanged += 1
                continue
            why = check_row(row_id, new_text, game, r['limit'])
            if why:
                rejected.append({'id': row_id, 'reviewer': reviewer, 'file': name, 'text': new_text, 'why': why})
                continue
            proposals.setdefault(row_id, []).append({'reviewer': reviewer, 'text': new_text, 'notes': r['notes'].strip(), 'file': name})
    accepted = []
    conflicts = []
    for row_id, items in proposals.items():
        texts = []
        for item in items:
            if item['text'] not in texts:
                texts.append(item['text'])
        if len(texts) == 1:
            reviewers = ', '.join(sorted({i['reviewer'] for i in items}))
            notes_text = ' / '.join(i['notes'] for i in items if i['notes'])
            accepted.append({'id': row_id, 'text': texts[0], 'reviewer': reviewers, 'notes': notes_text})
        else:
            conflicts.append({'id': row_id, 'items': items})
    order = {i: n for n, i in enumerate(game)}
    accepted.sort(key=lambda a: order.get(a['id'], 10 ** 9))
    conflicts.sort(key=lambda c: order.get(c['id'], 10 ** 9))
    # the CSV the importer reads (BOM + CRLF, every field quoted, like tools/export_dialogue.js)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    header = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line', 'Reviewer', 'Notes']
    with open(out, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_ALL, lineterminator='\r\n')
        writer.writerow(header)
        for a in accepted:
            g = game[a['id']]
            writer.writerow([a['id'], g['zone'], g['speaker'], g['when'], g['text'], a['text'], a['reviewer'], a['notes']])
    snapshot_dir = out[:-4] if out.lower().endswith('.csv') else out + '_dir'
    os.makedirs(snapshot_dir, exist_ok=True)
    with open(os.path.join(snapshot_dir, 'export_snapshot.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({a['id']: game[a['id']]['text'] for a in accepted}, f, indent='\t', ensure_ascii=False)
        f.write('\n')
    report_path = (out[:-4] if out.lower().endswith('.csv') else out) + '_report.md'
    rel = lambda p: os.path.relpath(p, ROOT).replace('\\', '/')
    lines = ['# Playtester dialogue import - report', '',
             'Files: ' + ', '.join('`%s`' % os.path.basename(p) for p in files) + '  ',
             'CSV for the importer: `%s` (%d rows)  ' % (rel(out), len(accepted)),
             '**Accepted: %d. Rejected: %d. Conflicts: %d** (lines two testers rewrote differently; none of them is in the CSV). Unchanged rewrites ignored: %d.'
             % (len(accepted), len(rejected), len(conflicts), unchanged), '',
             'Next: `node tools/apply_dialogue_pass.js --csv=%s` (dry run), then `--apply`; `--revert` puts the lines back.' % rel(out), '']
    if notes:
        lines += ['## Sheet structure', ''] + ['- ' + n for n in notes] + ['']
    lines += ['## Conflicts (%d) - the owner picks one (copy it into the CSV, or into a merges CSV for `--merge`)' % len(conflicts), '']
    if conflicts:
        lines += ['| ID | Current line | Reviewer | Their line |', '|---|---|---|---|']
        for c in conflicts:
            for n, item in enumerate(c['items']):
                lines.append('| %s | %s | %s | %s |' % (md(c['id']) if n == 0 else '', md(game[c['id']]['text']) if n == 0 else '', md(item['reviewer']), md(item['text'])))
    else:
        lines.append('None.')
    lines += ['', '## Rejected (%d)' % len(rejected), '']
    if rejected:
        lines += ['| ID | Reviewer | Why | Their line |', '|---|---|---|---|']
        for r in rejected:
            lines.append('| %s | %s | %s | %s |' % (md(r['id']), md(r['reviewer']), md(r['why']), md(r['text'])))
    else:
        lines.append('None.')
    lines += ['', '## Accepted (%d)' % len(accepted), '']
    if accepted:
        lines += ['| ID | Reviewer | Current line | New line |', '|---|---|---|---|']
        for a in accepted:
            lines.append('| %s | %s | %s | %s |' % (md(a['id']), md(a['reviewer']), md(game[a['id']]['text']), md(a['text'])))
    else:
        lines.append('None.')
    with open(report_path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')
    print('import_playtester_dialogue: %d accepted, %d rejected, %d conflicts, %d unchanged' % (len(accepted), len(rejected), len(conflicts), unchanged))
    print('  CSV    %s' % rel(out))
    print('  report %s' % rel(report_path))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
