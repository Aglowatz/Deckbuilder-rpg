"""MUS-SHOP-LEDGERBONE - A correctly completed form. Shop loop, 36 bars 3/4, 84 BPM, C minor.
A miniature of the D.N.A. waltz: harpsichord and pizzicato, a dry tick on every beat, a gentle organ and two woodwinds. Here order is
comforting - the theme's phrases are allowed to finish, and the end of the loop is a surprisingly pleasing completed cadence
(Fm - G7 - C minor, the clarinet landing on the tonic, a little harpsichord flourish like a signature). The Crossroads motif guests
once, as a polite bassoon question in the middle.
"""
from lib import Score, m, motif, motif_head, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS

INTRO = ['Cm', 'Ab', 'Fm', 'G7']
MID = ['Ab', 'Fm', 'Db', 'G7', 'Ab', 'Fm', 'Cm/G', 'G7']
END = ['Fm', 'G7', 'Cm', 'G7']


def build():
    s = Score('MUS-SHOP-LEDGERBONE', bpm=84, bars=36, meter=(3, 4), key='C minor', seed=315)
    s.V.update(DNA_CHORDS)
    s.seat('pizz', 'vc', 'cb', 'cl', 'bsn', 'perc')
    s.channel('hpsd', 'harpsichord', pan=34, reverb=80, vol=76)
    s.channel('organ', 'organ', pan=64, reverb=100, vol=62)
    for bar, nm in ((0, 'intro'), (4, 'A harpsichord theme'), (20, 'B bassoon question'), (28, 'A answer'), (32, 'cadence')):
        s.section(bar, nm)

    def tick(bar, vel=34):
        for k in range(3):
            s.note('perc', bar * 3 + k, .15, 77 if k else 76, vel + (6 if k == 0 else 0), human=False)

    def waltz(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 3, 1.0, b, vel)
        s.note('vc', bar * 3, 1.0, b + 12, vel - 10)
        for beat in (1, 2):
            for n in s.voicing(sym)[1][1:]:
                s.note('pizz', bar * 3 + beat, .3, p(n) + 12, vel - 14)

    def organ(bar, sym, vel, beats=3):
        s.pad('organ', bar, sym, vel, beats=beats)

    for i, sym in enumerate(INTRO):
        waltz(i, sym, 58)
        tick(i)
        organ(i, sym, 42)
    s.line('hpsd', 0, m('G4:.5 C5:.5 Eb5:.5 G5:.5 Eb5:.5 C5:.5 | Ab4:.5 C5:.5 Eb5:.5 Ab5:.5 Eb5:.5 C5:.5 '
                        '| F4:.5 Ab4:.5 C5:.5 F5:.5 C5:.5 Ab4:.5 | G4:.5 B4:.5 D5:.5 F5:.5 D5:.5 B4:.5'), 60, shape=False)
    s.tag_melody('hpsd', 0, 4)

    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        waltz(bar, sym, 62)
        tick(bar)
        if i % 2 == 0:
            organ(bar, sym, 40, beats=6)
    s.mel('hpsd', 4, DNA_THEME, 82)
    s.line('cl', 12, DNA_THEME[20:], 54, transpose=-12)

    for i in range(8):
        bar, sym = 20 + i, MID[i]
        waltz(bar, sym, 56)
        tick(bar, 30)
        organ(bar, sym, 44)
    s.motif('bsn', 20, motif('C3', 'minor') + m('r:2'), 82, form='stated (bassoon, a polite question)')
    s.mel('cl', 23, m('Ab4:2 G4:1 | F4:3 | Eb4:2 D4:1 | Eb4:1 F4:1 G4:1 | B3:3'), 80)

    for i in range(4):
        bar, sym = 28 + i, DNA_PROG[12 + i]
        waltz(bar, sym, 60)
        tick(bar)
        organ(bar, sym, 44)
    s.mel('hpsd', 28, DNA_THEME[30:], 80)
    s.line('cl', 28, DNA_THEME[30:], 60, transpose=-12)

    # the completed cadence: Fm - G7 - Cm, the clarinet lands home; a harpsichord signature; G7 leads back to the start
    for i, sym in enumerate(END):
        waltz(32 + i, sym, 62)
        tick(32 + i)
        organ(32 + i, sym, 48)
    s.mel('cl', 32, m('Ab4:1 G4:1 F4:1 | D4:2 B3:1 | C4:3 | r:3'), 84)
    s.mel('hpsd', 34, m('C5:.25 D5:.25 Eb5:.5 G4:.5 C5:1.5 | r:1 B4:1 D5:1'), 74)
    s.line('bsn', 32, m('F3:3 | G2:3 | C3:3 | G2:3'), 64)
    return s
