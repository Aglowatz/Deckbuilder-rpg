"""MUS-CASTLE-EXP - Behind the white and gold (Primm's Castle, D-PC node map, mirror halls, Path wings). Loop, 72 bars 3/4, 96 BPM,
G major, quantised. An elegant Baroque court minuet: strings, harpsichord continuo, choir, a flute and oboe trio. No organ (organ is
D.N.A.'s). The minuet tune is the Capital theme's two Primm cells (G B D G / G C E G) dressed for court. Behind the gilded harmony the
four Path themes appear distorted (a detuned celesta D.N.A. waltz, a far Dump jig, a muted Buffet welcome, a horn call); then the Capital
theme itself in the horns in 4/4 against the 3/4 dance (the symmetry cracks), and an exposed E minor passage where the oboe asks the
Crossroads question before the court snaps back to its cadence.
"""
from lib import Score, m, motif, motif_head, transpose, p
from lib.capital import QUANTISED
from lib.zones import DNA_THEME, DUMP_JIG_HEAD, BUFFET_THEME
from scores._fork_a import cap, bed, root

MIN_A = m('G4:1 B4:1 D5:1 | G5:1.5 F#5:.5 E5:1 | D5:.5 E5:.5 D5:.5 C5:.5 B4:.5 A4:.5 | B4:1 G4:1 D4:1 '
          '| G4:1 C5:1 E5:1 | G5:1.5 A5:.5 F#5:1 | G5:.5 F#5:.5 E5:.5 D5:.5 C5:.5 A4:.5 | G4:3')
MIN_B = m('B4:1 E5:1 G5:1 | B5:1.5 A5:.5 G5:1 | F#5:.5 G5:.5 A5:.5 G5:.5 F#5:.5 E5:.5 | D#5:3 '
          '| E5:1 G5:1 B5:1 | C6:1.5 B5:.5 A5:1 | G5:.5 F#5:.5 E5:.5 D5:.5 C5:.5 A4:.5 | D5:3')
H_A = ['G', 'Em', 'D7', 'G', 'C', 'Am D', 'D7', 'G']
H_B = ['Em', 'Em', 'B7', 'B7', 'Em', 'Am', 'D7', 'D7']
DNA_G = transpose(DNA_THEME[:10], -5)          # the waltz head in G minor-ish (G C Eb ...) -> sour against G major
JIG_G = transpose(DUMP_JIG_HEAD, 3)
BUF_G = transpose(BUFFET_THEME[:6], 2)


def build():
    s = Score('MUS-CASTLE-EXP', bpm=96, bars=72, meter=(3, 4), key='G major', seed=612, human=QUANTISED)
    s.seat('vln', 'vla', 'vc', 'cb', 'pad', 'choir', 'fl', 'ob', 'hn', 'cel', 'pizz', 'timp')
    s.channel('hpsd', 'harpsichord', pan=84, reverb=85, vol=82)
    s.channel('mhn', 'muted_tpt', pan=66, reverb=110, vol=56)
    s.detune('cel', -18)
    for bar, nm in ((0, 'intro court'), (4, 'A minuet'), (20, 'B trio, Path ghosts'), (36, "A' the symmetry cracks"),
                    (52, 'C exposed (E minor)'), (68, 'outro court')):
        s.section(bar, nm)
    s.notes.append('Minuet built from the Capital theme\'s Primm cells; the Capital theme in 4/4 across the 3/4 dance in the horns '
                   '(A\'); no organ; quantised.')

    def continuo(bar, spec, vel):
        for t, d, sym in [(bar * 3 + b, dd, sy) for b, dd, sy in s.parts(spec)]:
            tn = s.chord_tones(sym, p('G3'), 6)
            r = root(s, sym, 'G2')
            s.note('vc', t, d - .02, r, vel)
            b = root(s, sym, 'E1')
            if b >= p('F2'):
                b -= 12
            s.note('cb', t, min(1, d) - .02, b, vel - 4)
            for k in range(int(d * 2)):
                if k % 2 == 1 or k == 0:
                    s.note('hpsd', t + k * .5, .4, tn[(k % 3) + 1], vel - 6 + (6 if k == 0 else 0))

    def strings_acc(bar, spec, vel):
        for t, d, sym in [(bar * 3 + b, dd, sy) for b, dd, sy in s.parts(spec)]:
            for k in (1, 2):
                if k < d + (t - bar * 3) + 1e-6 and t + k - bar * 3 < 3:
                    for n in s.chord_tones(sym, p('B3'), 3):
                        s.note('vla', bar * 3 + k, .45, n, vel)

    def intro(bar):
        spec = ['G', 'C D', 'G', 'D7']
        for i, sy in enumerate(spec):
            continuo(bar + i, sy, 62)
            strings_acc(bar + i, sy, 50)
            bed(s, bar + i, sy, 34, ch='pad', low='B3', n=3)
        s.mel('hpsd', bar, m('D5:1 G5:1 B5:1 | A5:1 G5:1 F#5:1 | G5:.5 A5:.5 B5:.5 A5:.5 G5:.5 F#5:.5 | F#5:.5 G5:.5 A5:.5 B5:.5 C6:.5 A5:.5'), 84)

    intro(0)

    for k in range(2):
        for i, sy in enumerate(H_A):
            bar = 4 + 8 * k + i
            continuo(bar, sy, 62)
            strings_acc(bar, sy, 48)
            bed(s, bar, sy, 38, ch='pad', low='B3', n=3)
    s.mel('vln', 4, MIN_A, 86)
    s.mel('vln', 12, MIN_A, 88)
    s.line('fl', 12, MIN_A, 58, transpose=12)
    s.motif('ob', 9, motif_head('G4', 'major', rhythm=(1, .5, .5)) + m('r:1'), 54, form='head (oboe, half hidden in the continuo)', lead=False)

    for k in range(2):
        for i, sy in enumerate(H_B):
            bar = 20 + 8 * k + i
            continuo(bar, sy, 58)
            bed(s, bar, sy, 46, ch='choir', low='B3', n=3)
    s.mel('fl', 20, MIN_B, 84)
    s.line('ob', 20, MIN_B, 60, transpose=-12)
    s.line('cel', 21, DNA_G, 48, transpose=12)                   # D.N.A., detuned, behind the gilt
    s.line('fl', 27, JIG_G[:6], 44, transpose=0)
    s.mel('ob', 28, MIN_B, 84)
    s.line('mhn', 30, BUF_G, 50)                                 # Buffet welcome, muted, far
    s.line('hn', 33, m('G3:1 D4:.5 C4:.5 B3:1.5 A3:.5 | D4:3'), 48)   # Gainlands call, far

    for k in range(2):
        for i, sy in enumerate(H_A):
            bar = 36 + 8 * k + i
            continuo(bar, sy, 64)
            strings_acc(bar, sy, 52)
            bed(s, bar, sy, 52, ch='choir', low='B3', n=3)
    s.mel('vln', 36, MIN_A + MIN_A, 90)
    s.line('choir', 36, MIN_A, 50, transpose=-12)
    s.line('hn', 40, cap(0, 8, -5 - 12), 74)                      # the Capital theme in 4/4 against the minuet: the cracks
    s.motif('ob', 50, motif_head('E5', 'minor', rhythm=(1, .5, .5)) + m('r:1'), 62, form='head (oboe)', lead=False)

    cspec = ['Em', 'Am', 'B7', 'Em', 'C', 'Am', 'F#dim', 'B7', 'Em', 'Am', 'D7', 'G', 'C', 'Am', 'D7', 'D7']
    for i, sy in enumerate(cspec):
        bar = 52 + i
        s.note('cb', bar * 3, 2.98, root(s, sy, 'E1') - (12 if root(s, sy, 'E1') >= p('F2') else 0), 52)
        bed(s, bar, sy, 46 + (i if i < 8 else 16 - i) * 2, ch='pad', low='B3', n=3)
        if i % 2 == 0:
            s.note('hpsd', bar * 3, .5, root(s, sy, 'E4'), 60)
    s.motif('ob', 52, motif('E4', 'minor', rhythm=[1.5, .75, .75, 2.25, .75, 3]) + m('r:3'), 84, form='stated (oboe, exposed, in 3/4)')
    s.motif('vln', 55, motif('B4', 'minor', rhythm=[1.5, .75, .75, 2.25, .75, 3]) + m('r:3'), 80, form='stated (violins answer)')
    s.mel('fl', 58, m('E5:3 | F#5:3 | D#5:3 | r:3'), 70)
    s.mel('vln', 62, MIN_A[-6:] + m('D5:3 | B4:1 C5:1 A4:1 | D5:3'), 84)
    s.swell('pad', 52, 8, 70, 112, back='arch')

    intro(68)
    s.swell('pad', 70, 2, 100, 127)
    s.timp_roll(71 * 3, 3, 'D2', 30, 62)
    return s
