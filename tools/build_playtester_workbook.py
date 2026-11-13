#!/usr/bin/env python3
"""Nov 13: rebuilds the playtesters' dialogue workbook from the game's current text, keeping the Nov 9 workbook's tabs, columns and styles.

    python tools/build_playtester_workbook.py [--template=docs/dialogue/playtesters_nov9.xlsx] [--out=docs/dialogue/playtesters_nov13.xlsx]
                                              [--voices=docs/writing/voices.md] [--export=<an export CSV; default: a fresh export>]

Standard library only (an .xlsx is a zip of XML). The "Dialogue" tab gets one row per line of a fresh `node tools/export_dialogue.js`
(same columns A-N, formulas and formats as the template's rows; the limit is 90 for barks and 240 otherwise; column L lists the line's
tokens and tags). The "Voice Guide (SPOILERS)" tab is rebuilt from docs/writing/voices.md, one line per row. The "How to use" tab keeps
its text with the line count and the export date updated. The "Speakers" tab is left as it was.
"""
import csv
import datetime
import os
import re
import subprocess
import sys
import tempfile
import zipfile
from xml.sax.saxutils import escape

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOKEN_RE = re.compile(r'\{[a-z_]+\}|^\[[a-z_]+\]|%[sd]')


def opt(argv, name, default):
    for a in argv:
        if a.startswith('--%s=' % name):
            return a.split('=', 1)[1]
    return default


def abspath(p):
    return p if os.path.isabs(p) else os.path.join(ROOT, p)


def inline(ref, style, text):
    if text == '':
        return '<c r="%s" s="%s"/>' % (ref, style)
    return '<c r="%s" s="%s" t="inlineStr"><is><t xml:space="preserve">%s</t></is></c>' % (ref, style, escape(text))


def dialogue_rows(rows):
    out = []
    for n, r in enumerate(rows, start=1):
        x = n + 1
        text = r['Current line']
        limit = 90 if 'npcs.json::' in r['ID'] else 240
        tokens = ' '.join(dict.fromkeys(TOKEN_RE.findall(text)))
        cells = [
            '<c r="A%d" s="9" t="n"><v>%d</v></c>' % (x, n),
            inline('B%d' % x, 10, r['ID']), inline('C%d' % x, 11, r['Zone/Area']), inline('D%d' % x, 11, r['Speaker']),
            inline('E%d' % x, 12, r["When it's heard"]), inline('F%d' % x, 12, text),
            '<c r="G%d" s="9" t="n"><f aca="false">LEN(F%d)</f><v>%d</v></c>' % (x, x, len(text)),
            '<c r="H%d" s="13"/>' % x,
            '<c r="I%d" s="11" t="str"><f aca="false">IF(H%d=&quot;&quot;,&quot;&quot;,LEN(H%d))</f><v></v></c>' % (x, x, x),
            '<c r="J%d" s="9" t="n"><v>%d</v></c>' % (x, limit),
            '<c r="K%d" s="11" t="str"><f aca="false">IF(I%d=&quot;&quot;,&quot;&quot;,IF(I%d&gt;J%d,&quot;TOO LONG&quot;,&quot;OK&quot;))</f><v></v></c>' % (x, x, x, x),
            inline('L%d' % x, 9, tokens), '<c r="M%d" s="12"/>' % x, '<c r="N%d" s="11"/>' % x,
        ]
        out.append('<row r="%d" customFormat="false" ht="15" hidden="false" customHeight="false" outlineLevel="0" collapsed="false">%s</row>' % (x, ''.join(cells)))
    return ''.join(out)


def voice_rows(lines):
    out = []
    for n, line in enumerate(lines, start=1):
        line = line.rstrip()
        style = 16 if n == 1 else 17 if line.startswith('#') else 18
        text = re.sub(r'^#+\s*', '', line).replace('**', '').replace('`', '')
        height = '18.55' if style == 17 else '15'
        out.append('<row r="%d" customFormat="false" ht="%s" hidden="false" customHeight="false" outlineLevel="0" collapsed="false">%s</row>' % (n, height, inline('A%d' % n, style, text)))
    return ''.join(out)


def main(argv):
    template = abspath(opt(argv, 'template', 'docs/dialogue/playtesters_nov9.xlsx'))
    out = abspath(opt(argv, 'out', 'docs/dialogue/playtesters_nov13.xlsx'))
    voices = abspath(opt(argv, 'voices', 'docs/writing/voices.md'))
    export = opt(argv, 'export', '')
    if not export:
        tmp = tempfile.mkdtemp(prefix='wp_workbook_')
        export = os.path.join(tmp, 'export.csv')
        subprocess.run(['node', os.path.join(ROOT, 'tools', 'export_dialogue.js'), '--out=' + export], check=True, stdout=subprocess.DEVNULL)
    with open(abspath(export), encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))
    with open(voices, encoding='utf-8') as f:
        guide = ['SPOILER WARNING: this guide explains the whole story and its twists. It is the writing reference for every character\'s voice (Nov 13 2026).'] + f.read().split('\n')
    last = len(rows) + 1
    today = datetime.date.today().strftime('%b %d, %Y').replace(' 0', ' ')
    zin = zipfile.ZipFile(template)
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename == 'xl/worksheets/sheet2.xml':
                x = data.decode('utf-8')
                x = re.sub(r'<sheetData>.*?</sheetData>', lambda m: '<sheetData>' + re.search(r'<row r="1".*?</row>', m.group(0), re.S).group(0) + dialogue_rows(rows) + '</sheetData>', x, flags=re.S)
                x = re.sub(r'(ref|sqref)="A(\d):N\d+"', lambda m: '%s="A%s:N%d"' % (m.group(1), m.group(2), last), x)
                data = x.encode('utf-8')
            elif item.filename == 'xl/worksheets/sheet4.xml':
                x = data.decode('utf-8')
                x = re.sub(r'<sheetData>.*?</sheetData>', lambda m: '<sheetData>' + voice_rows(guide) + '</sheetData>', x, flags=re.S)
                x = re.sub(r'<dimension ref="[^"]*"/>', '<dimension ref="A1:A%d"/>' % len(guide), x)
                data = x.encode('utf-8')
            elif item.filename == 'xl/sharedStrings.xml':
                x = data.decode('utf-8')
                x = re.sub(r'[\d,]+ lines of in-game dialogue', '{:,} lines of in-game dialogue'.format(len(rows)), x)
                x = re.sub(r'\(export of [^)]*\)', '(export of %s, after the Nov 13 rewrite)' % today, x)
                data = x.encode('utf-8')
            zout.writestr(item, data)
    print('build_playtester_workbook: %d dialogue rows, %d voice guide rows -> %s' % (len(rows), len(guide), os.path.relpath(out, ROOT).replace('\\', '/')))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
