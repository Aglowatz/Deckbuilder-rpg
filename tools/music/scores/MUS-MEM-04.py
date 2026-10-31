"""MUS-MEM-04 - His name (Maren's fourth memory or Primm's early identity reveal). One-shot, 20 bars 4/4, 66 BPM, D major, ~80 s
with the ring-out.
Recognition of the lost prince. It starts in neutral uncertainty - open fifths, a suspended chord, a single harp note - so either reveal
route works. Then the lullaby comes into clear focus on piano and flute over warm strings: its head, then most of its answer - and it stops
before its last three notes (still incomplete until the throne, as the row asks). The Crossroads motif follows in the cello and violins,
held open on its fifth.
"""
from lib import Score, p, voice, motif, LULLABY_HEAD, LULLABY_ANSWER
from scores._fork_b import held

PART = LULLABY_HEAD + LULLABY_ANSWER[:7]            # head + answer up to C5 G4 (17 beats of 19): stops before B A E


def build():
    s = Score('MUS-MEM-04', bpm=66, bars=20, key='D major', seed=1814, kind='oneshot')
    s.lufs = -20.0
    s.seat('piano', 'fl', 'vln', 'pad', 'vc', 'cb', 'harp', 'hn', piano={'vol': 86}, pad={'vol': 66})
    for bar, nm in ((0, 'uncertain'), (4, 'the lullaby in focus'), (10, 'held'), (12, 'crossroads, open'), (17, 'held fifth')):
        s.section(bar, nm)
    s.notes.append('The lullaby clearest yet but incomplete (stops before its last three notes) - the whole statement waits for THRONE.')

    # 0-3: neutral - open fifths and a suspended chord, starts instantly
    s.note('harp', 0, 4, p('A4'), 60, human=False)
    for bar, ch in ((0, ['D3', 'A3']), (1, ['D3', 'A3', 'E4']), (2, ['G3', 'D4']), (3, ['A3', 'E4'])):
        for t in ch:
            s.note('pad', bar * 4, 4.1, p(t), 46)
    s.note('cb', 0, 16, p('D2'), 40)
    s.mel('piano', 1, [('A4', 2), ('E5', 2), ('D5', 4), ('A4', 4)], 52)

    # 4-9: the lullaby in focus - piano + flute, warm strings and harp (stops early)
    CH = [(0, 4, 'Dm'), (4, 3, 'A'), (7, 2, 'Em7'), (9, 4, 'Dm'), (13, 2, 'C'), (15, 3, 'Gsus2')]
    for b, d, sym in CH:
        st = 16 + b
        s.pad('pad', 0, sym, 50, beats=d, beat=st)
        s.harp(0, sym, 44, beats=d, beat=st)
        s.bass_at(st, d, sym, 46, chs=('cb', None))
    s.mel('fl', 4, PART, 78, transpose=12)
    s.line('piano', 4, PART, 60)
    s.line('vc', 5, [('F3', 4), ('E3', 3), ('G3', 2), ('F3', 4), ('E3', 3)], 50)

    # 10-11: held - where the rest of the tune should go
    for t in voice('Gsus2', 'G3', 4):
        s.note('pad', 40, 8, t, 44)
    s.note('cb', 40, 8, p('G2'), 40)
    s.note('piano', 41, 6, p('D5'), 40)

    # 12-16: the Crossroads motif in the cello and violins, open
    for i, sym in enumerate(['Bm', 'G', 'Em7', 'A7sus4', 'A']):
        s.pad('pad', 12 + i, sym, 50)
        s.harp(12 + i, sym, 42)
        s.note('cb', (12 + i) * 4, 4.02, p(s.voicing(sym)[0]), 44)
    s.motif('vc', 12, motif('D3', 'major', rhythm=[2, 1, 1, 3, 1, 6]), 70, form='stated (cello)')
    s.motif('vln', 14, motif('D5', 'major', rhythm=[1, .5, .5, 1.5, .5, 4]), 72, form='stated (violins), open')
    s.line('hn', 14, [('F#4', 4), ('E4', 4)], 52)

    # 17-19: the held fifth (A), unresolved
    held(s, 17, 'Asus4', 12, 46, ['pad'], low='A3')
    held(s, 17, 'A', 12, 40, ['hn'], low='E3', n=3)
    s.note('cb', 68, 12, p('A1'), 42)
    s.mel('fl', 17, [('E6', 4), ('A5', 8)], 54)
    return s
