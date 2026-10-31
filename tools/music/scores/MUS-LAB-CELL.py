"""MUS-LAB-CELL - Ten years of marks (the prince's old lab cell; postgame). One-shot, 18 bars 4/4, 66 BPM, E major. Orchestral, not techno.
Very sparse: a piano picking out small childlike intervals (seconds and thirds, like counting marks on a wall) with long pauses; a cello
answers with the Crossroads motif, open. The lullaby's first four notes appear once on the celesta, with space around them. Then the
warmth arrives - strings, harp, a soft horn - and the motif's head rises over an E major chord that opens toward recovery. Sadness
allowed, never sensational; it ends breathing on a held add9 chord.
"""
from lib import Score, motif, motif_head, m, p, LULLABY_HEAD


def build():
    s = Score('MUS-LAB-CELL', bpm=66, bars=18, key='E major', seed=904, kind='oneshot')
    s.lufs = -20
    s.seat('piano', 'vc', 'cb', 'pad', 'vln', 'harp', 'hn', 'cel', 'cl')
    for bar, nm in ((0, 'marks'), (4, 'cello'), (8, 'the lullaby, four notes'), (12, 'warmth'), (16, 'held')):
        s.section(bar, nm)

    # 0-3 piano alone: small intervals, pauses
    s.note('piano', 0, 1.5, p('E4'), 66, human=False)
    s.mel('piano', 0, m('E4:1 F#4:1 r:2 | G#4:1 F#4:1 r:2 | E4:.5 F#4:.5 G#4:1 r:2 | B3:2 r:2'), 78)
    s.pad('pad', 0, 'Eadd9', 30, beats=16, low='G#3')
    s.swell('pad', 0, 4, 40, 60)
    s.note('piano', 0, 3.8, p('E3'), 44)
    s.note('piano', 8, 3.8, p('C#3'), 42)
    s.note('piano', 12, 3.8, p('A2'), 42)

    # 4-7 the cello's open motif over a quiet pad
    for i, sym in enumerate(['E', 'C#m', 'A', 'B']):
        s.pad('pad', 4 + i, sym, 34, low='G#3')
        s.note('cb', (4 + i) * 4, 3.9, s.voicing(sym)[0], 36)
    s.swell('pad', 4, 4, 50, 80)
    s.motif('vc', 4, motif('E3', 'major') + [('r', 1)], 72, form='stated (cello, open)')
    s.mel('piano', 6, m('G#4:1 A4:1 r:2 | F#4:2 r:2'), 58)

    # 8-11 the lullaby's first four notes, once, with pauses (celesta), harp below
    for i, sym in enumerate(['E', 'G#m', 'A', 'B7sus4']):
        s.pad('pad', 8 + i, sym, 38, low='G#3')
        s.note('cb', (8 + i) * 4, 3.9, s.voicing(sym)[0], 38)
        s.harp(8 + i, sym, 40, ch='harp')
    lh = [(p(n) + 2, 1) for n, d in LULLABY_HEAD[:4]]               # E B G# F#
    s.mel('cel', 8, [lh[0], ('r', 1), lh[1], ('r', 1), lh[2], ('r', 1), (lh[3][0], 2)] + [('r', 4)], 70, transpose=12)
    s.notes.append('Lullaby: first four notes once (celesta, bar 8, E B G# F#), spaced by pauses - the whole melody is kept for after MEM-04.')
    s.line('vc', 10, m('A3:4 | B3:4'), 56)

    # 12-15 warmth: strings, harp, a soft horn, the motif's head rising; 16-17 held
    for i, sym in enumerate(['A', 'E/G#', 'F#m7', 'B']):
        s.pad('pad', 12 + i, sym, 52, low='G#3')
        s.note('cb', (12 + i) * 4, 3.9, s.voicing(sym)[0], 46)
        s.harp(12 + i, sym, 46, ch='harp')
    s.swell('pad', 12, 4, 70, 100)
    s.mel('vln', 12, m('C#5:3 B4:1 | B4:2 G#4:2 | A4:3 C#5:1 | B4:4'), 74)
    s.motif('hn', 13, motif_head('E3', 'major', rhythm=(2, 1, 5)), 62, form='head (horn, rising toward recovery)', lead=False)
    s.line('cl', 14, m('E4:2 F#4:2 | D#4:4'), 56)
    s.pad('pad', 16, 'Eadd9', 54, beats=8, low='G#3')
    s.pad('vln', 16, 'E', 50, beats=8, low='G#4', n=3)
    s.note('cb', 16 * 4, 7.9, p('E2'), 48)
    s.note('vc', 16 * 4, 7.9, p('E3'), 50)
    s.note('harp', 16 * 4, 6, p('E5'), 48)
    s.mel('piano', 16, m('G#4:1 F#4:1 E4:2 | r:4'), 58)
    return s
