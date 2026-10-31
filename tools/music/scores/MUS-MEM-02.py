"""MUS-MEM-02 - The cells (second freed-zone memory). One-shot, 20 bars 4/4, 60 BPM, D minor -> F major, ~84 s with the ring-out.
White rooms, glass and the Subject. Cold glass tones (bowed glass, crystal) on a high, still cluster; the lullaby's first four notes ONLY,
each separated by a clinical gap (D ... A ... F ... E), on a thin celesta. Under everything a human cello line that never stops - someone
still there. No embellishment. In the last third the cello's line becomes the Crossroads motif, the glass thaws into strings and harp, and
the memory ends on a warm F major chord with the flute: hope, quietly.
"""
from lib import Score, p, voice, motif
from scores._fork_b import first_four_lullaby


def build():
    s = Score('MUS-MEM-02', bpm=60, bars=20, key='D minor -> F major', seed=1812, kind='oneshot')
    s.lufs = -20.0
    s.seat('vc', 'cb', 'pad', 'harp', 'fl', 'cel', vc={'vol': 94}, pad={'vol': 66})
    s.channel('glass', 'bowed_glass', pan=50, reverb=115, vol=66)
    s.channel('crys', 'crystal', pan=78, reverb=110, vol=50)
    for bar, nm in ((0, 'white room'), (2, 'separated notes'), (12, 'the cello remembers'), (16, 'F major')):
        s.section(bar, nm)
    s.notes.append('Lullaby: first four notes only, each separated by a gap (bars 2, 4, 6, 8). Ends with hope (F major).')

    # 0-11: glass cluster, separated notes, the cello's human line underneath
    for bar in (0, 4, 8):
        for t in (p('A5'), p('D6'), p('E6')):
            s.note('glass', bar * 4, 16.2, t, 56)
    s.note('crys', 0, 2, p('A6'), 46)
    notes = first_four_lullaby(12, durs=(2, 2, 2, 3))
    for k, (n, d) in enumerate(notes):
        s.mel('cel', 2 + 2 * k, [(n, d)], 62)
        s.note('crys', (3 + 2 * k) * 4 + 2, 1.5, n + 12, 36)
    s.mel('vc', 0, [('D3', 4), ('E3', 4), ('F3', 6), ('E3', 2), ('D3', 4), ('C3', 4), ('Bb2', 8), ('A2', 4), ('C3', 4),
                    ('D3', 8), ('E3', 4)], 64)
    s.note('cb', 0, 48, p('D2'), 36)

    # 12-15: the cello's line becomes the Crossroads motif; the glass thaws into strings + harp
    for i, sym in enumerate(['Dm', 'Bbmaj7', 'Gm7', 'C7sus4']):
        s.pad('pad', 12 + i, sym, 40 + i * 3)
        s.harp(12 + i, sym, 38 + i * 2)
        s.note('cb', (12 + i) * 4, 4.02, p(s.voicing(sym)[0]), 42)
    s.motif('vc', 12, motif('D3', 'minor', rhythm=[2, 1, 1, 3, 1, 8]), 72, form='stated (cello), slow')
    s.note('glass', 48, 8, p('A5'), 40)

    # 16-19: F major, the flute's small rising answer, held
    for t in voice('Fmaj7', 'F3', 4):
        s.note('pad', 64, 16, t, 52)
    s.harp(16, 'Fmaj7', 46, density=16)
    s.harp(18, 'F', 40)
    s.note('cb', 64, 16, p('F2'), 46)
    s.mel('fl', 16, [('C5', 1), ('F5', 1), ('G5', 2), ('A5', 8)], 66)
    s.line('vc', 16, [('A3', 4), ('C4', 12)], 54)
    return s
