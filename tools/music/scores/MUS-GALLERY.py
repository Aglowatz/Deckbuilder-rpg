"""MUS-GALLERY - Kept for reference (Primm's private gallery, the painted-over royal portrait). One-shot, 24 bars 3/4, 70 BPM,
G minor -> Bb major, ~66 s with the ring-out.
Absence and remembered love. Soft piano alone; the lullaby's first four notes ONLY, once (G D Bb A, the lullaby rule), and then the
silence where its answering voice should be - two bars of nothing but a held cello note. The Crossroads motif's head (the lullaby's child)
in the piano, twice, quietly; one restrained cello line. No crescendo: the last phrase turns gently to Bb major and holds, as if someone
in the portrait were still smiling under the paint.
"""
from lib import Score, p, voice, motif_head
from scores._fork_b import first_four_lullaby

H = ['Gm', 'Gm/F', 'Ebmaj7', 'D7sus4', 'Gm', 'Cm7', 'Ebmaj7', 'Dsus4']


def build():
    s = Score('MUS-GALLERY', bpm=70, bars=24, meter=(3, 4), key='G minor -> Bb major', seed=1670, kind='oneshot')
    s.lufs = -20.0
    s.seat('piano', 'vc', 'cb', 'pad', piano={'vol': 88}, vc={'vol': 90}, pad={'vol': 60})
    for bar, nm in ((0, 'piano alone'), (4, 'four notes'), (8, 'the missing answer'), (10, 'cello'), (18, 'Bb, held')):
        s.section(bar, nm)
    s.notes.append('Lullaby: its first four notes only, once (bar 4). Silence where the answer should be (bars 8-9).')

    def arp(bar, sym, vel):
        tn = voice(sym, 'G3', 3)
        s.note('piano', bar * 3, 3.0, p(s.voicing(sym)[0]) + 12, vel)
        for k, t in enumerate(tn):
            s.note('piano', bar * 3 + 1 + k * .5, 1.9 - k * .5, t, vel - 8)

    # 0-3: starts instantly
    for i, sym in enumerate(['Gm', 'Gm/F', 'Ebmaj7', 'D7sus4']):
        arp(i, sym, 50)
    s.mel('piano', 0, [('D5', 2), ('Bb4', 1), ('C5', 3), ('Bb4', 2), ('A4', 1), ('A4', 3)], 60)

    # 4-7: the lullaby's first four notes, once
    for i, sym in enumerate(['Gm', 'Gm', 'Ebmaj7', 'Dsus4']):
        arp(4 + i, sym, 44)
    s.mel('piano', 4, first_four_lullaby(5, durs=(2, 1, 3, 3)) + [('r', 3)], 66)

    # 8-9: silence where the answer should be - a held cello G only
    s.mel('vc', 8, [('G3', 6)], 50)

    # 10-17: the restrained cello line; the motif's head in the piano twice
    for i, sym in enumerate(H):
        arp(10 + i, sym, 42)
        s.pad('pad', 10 + i, sym, 34)
    s.mel('vc', 10, [('Bb3', 3), ('A3', 3), ('G3', 3), ('F#3', 3), ('G3', 2), ('Bb3', 1), ('C4', 3), ('Bb3', 3), ('A3', 3)], 64)
    s.motif('piano', 12, motif_head('G4', 'minor', rhythm=(1, .5, 1.5)), 52, form='head (piano), quiet', lead=False)
    s.motif('piano', 15, motif_head('G4', 'minor', rhythm=(1, .5, 1.5)), 48, form='head (piano), quieter', lead=False)

    # 18-23: the turn to Bb major, held
    for i, sym in enumerate(['Ebmaj7', 'F', 'Bb', 'Bb']):
        arp(18 + i, sym, 44)
        s.pad('pad', 18 + i, sym, 38)
        s.note('cb', (18 + i) * 3, 3.02, p(s.voicing(sym)[0]), 36)
    s.mel('piano', 18, [('G5', 2), ('F5', 1), ('Eb5', 3), ('D5', 3), ('D5', 3)], 58)
    s.line('vc', 18, [('Eb3', 3), ('F3', 3), ('D3', 6)], 54)
    for t in voice('Bb', 'D3', 4):
        s.note('pad', 22 * 3, 6, t, 40)
    s.note('piano', 22 * 3, 6, p('Bb2'), 44)
    s.note('piano', 22 * 3 + .5, 5.5, p('F4'), 40)
    s.note('piano', 22 * 3 + 1, 5, p('D5'), 46)
    return s
