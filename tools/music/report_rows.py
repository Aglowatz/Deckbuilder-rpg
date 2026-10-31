"""Markdown table rows for the music pass reports (docs/audio/music_pass*_oct31.md), from tools/music/reports/<ID>.json.

    python tools/music/report_rows.py --batch "Batch 03" MUS-NECRO-EXP MUS-NECRO-BATTLE ...
Loops: ID | Key | Tempo | Length | Motif (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam | Preview
One-shots: the Seam column holds the onset (first sound) instead.
"""
import argparse
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def mmss(sec):
    return f'{int(sec // 60)}:{sec % 60:04.1f}'


def row(id, batch):
    with open(os.path.join(HERE, 'reports', f'{id}.json'), encoding='utf-8') as f:
        r = json.load(f)
    motifs = '; '.join(f"{m['bar']:g}: {m['form']}" for m in r.get('motifs', [])) or '-'
    secs = '; '.join(f"{s['bar']} {s['section']}: {s['lufs']}" for s in r.get('sections', []))
    if r['kind'] == 'loop':
        length = f"{mmss(r['loop_seconds'])} ({r['bars']} bars)"
        seam = r['seam']
        tail = f"{seam['jump_db']:+.2f} dB, {'CLICK' if seam['click'] else 'no click'}"
    else:
        length = f"{r['seconds']:.1f} s (one-shot)"
        tail = f"onset {r.get('onset_ms')} ms"
    tempo = f"{r['bpm']:g} BPM {r['meter']}"
    return (f"| {id} | {r['key']} | {tempo} | {length} | {motifs} | {secs} | {r['lufs']} / {r['true_peak']} dB | {tail} | "
            f"`Music Review/{batch}/{id}.mp3` |")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('ids', nargs='+')
    ap.add_argument('--batch', required=True)
    a = ap.parse_args()
    print('| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |')
    print('|---|---|---|---|---|---|---|---|---|')
    for id in a.ids:
        print(row(id, a.batch))


if __name__ == '__main__':
    main()
