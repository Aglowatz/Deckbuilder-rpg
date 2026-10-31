"""MUS-MAREN - Maren, pie and secrets. 32 bars 3/4, 66 BPM, G minor.
Guarded kindness: a warm low clarinet and the cello over a gentle piano figure; the Crossroads motif asked in G minor, and questions
that do not resolve quickly (phrases end on the dominant or slip to E-flat). A bare middle - open fifths, single piano notes, where
the clarinet almost remembers the lullaby (three notes) - for when her research history is admitted. Then the duet again, still open.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p

A_H = ['Gm', 'Eb', 'Cm', 'D7sus4', 'Gm', 'Bb/F', 'Ebmaj7', 'Dsus4']
B_H = ['Ebmaj7', 'Bb/D', 'Cm7', 'D', 'Ebmaj7', 'Bb/D', 'Cm7', 'Dsus4']
BARE = ['G5', 'G5', 'Eb5', 'D5', 'G5', 'C5', 'Eb5', 'D5']
R34 = [1, .5, .5, 1, 2, 4]          # the motif in 3/4: q e e q | h. ... held into the next bar
FIG = [(0, 0, 2.8, 2), (1, 2, 1.8, -8), (2, 3, .9, -10)]


def build():
    s = Score('MUS-MAREN', bpm=66, bars=32, meter=(3, 4), key='G minor', seed=808)
    s.seat('cl', 'bsn', 'vc', 'cb', 'piano', 'pad', 'ehn', piano={'vol': 78}, cl={'vol': 90}, vc={'vol': 92})
    for bar, nm in ((0, 'A clarinet'), (8, 'B cello'), (16, 'C bare'), (24, "A' duet")):
        s.section(bar, nm)
    q = s.bar_q

    def bed(bar, spec, vel, pad_v=44):
        for off, beats, sym in s.parts(spec):
            s.figure('piano', bar, sym, FIG, vel, low='G3')
            s.pad('pad', bar, sym, pad_v, beats=beats, beat=off, low='Bb3', n=3)
            s.bass_at(bar * q + off, beats, sym, 48, chs=('cb', None))

    # A 0-7: the clarinet asks the motif in G minor; phrase ends hang on D
    for i, spec in enumerate(A_H):
        bed(i, spec, 52)
    s.motif('cl', 0, motif('G4', 'minor', R34), 76, form='stated (low clarinet), a question')
    s.mel('cl', 3, m('r:1 | Bb4:1 C5:.5 Bb4:.5 A4:1 | G4:2 Bb4:1 | C5:1.5 Bb4:.5 A4:1 | A4:3'), 72)
    s.line('bsn', 0, m('G3:3 | G3:3 | Eb3:3 | F#3:3 | G3:3 | F3:3 | Eb3:3 | D3:3'), 50, legato=1.0, shape=False)
    s.swell('pad', 0, 8, 70, 90, 'arch')

    # B 8-15: the cello answers, warmer; still no full close
    for i, spec in enumerate(B_H):
        bed(8 + i, spec, 50)
    s.mel('vc', 8, m('G3:2 Bb3:1 | D4:2 C4:1 | Eb4:1.5 D4:.5 C4:1 | A3:3 | G3:2 Bb3:1 | F4:2 D4:1 | Eb4:1 D4:1 C4:1 | A3:3'), 80)
    s.motif('ehn', 9, motif_tail('G4', 'minor', rhythm=(1, .5, 1.5)), 56, form='tail (english horn, answering)', lead=False)
    s.motif('ehn', 13, motif_tail('G4', 'minor', rhythm=(1, .5, 1.5)), 58, form='tail (english horn, answering)', lead=False)
    s.swell('vc', 8, 8, 84, 104, 'arch')

    # C 16-23: bare - open fifths in the strings, single piano notes, the clarinet almost remembers
    for i in range(8):
        bar = 16 + i
        root = ['G2', 'G2', 'Eb2', 'D2', 'G2', 'C2', 'Eb2', 'D2'][i]
        for t in (p(root) + 12, p(root) + 19):
            s.note('pad', bar * q, q + .05, t, 46)
        s.note('cb', bar * q, q + .05, p(root), 44)
        s.note('piano', bar * q + (1 if i % 2 else 0), 2, p(BARE[i]), 46)
    s.line('cl', 18, m('G4:1 D5:1 Bb4:1 | r:3'), 62)
    s.motifs.append((18, 'lullaby (G D Bb, three notes) - story theme', 'cl'))
    s.motif('vc', 20, augment(motif_head('G3', rhythm=(1, .5, .5)), 2) + m('r:2'), 66, form='head augmented (cello), bare')
    s.mel('cl', 22, m('A4:3 | F#4:3'), 58)
    s.swell('pad', 16, 8, 60, 84, 'arch')

    # A' 24-31: clarinet and cello in duet; the last bar opens back into bar 0
    for i, spec in enumerate(A_H):
        bed(24 + i, spec, 54, pad_v=48)
    s.motif('cl', 24, motif('G4', 'minor', R34), 76, form='stated (clarinet) with cello counter')
    s.mel('cl', 27, m('r:1 | Bb4:1 C5:.5 Bb4:.5 A4:1 | G4:2 Bb4:1 | C5:1.5 Bb4:.5 A4:1 | A4:5'), 74)
    s.line('vc', 24, m('D3:3 | Eb3:2 F3:1 | G3:3 | F#3:3 | G3:2 A3:1 | Bb3:3 | G3:3 | F#3:1.5 r:1.5'), 66, legato=1.0)
    s.line('bsn', 31, m('r:2 D3:1'), 48)
    s.swell('pad', 24, 8, 72, 90, 'arch')
    s.expr('pad', 0, 70)
    return s
