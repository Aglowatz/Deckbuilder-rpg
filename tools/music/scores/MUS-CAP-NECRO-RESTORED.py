"""MUS-CAP-NECRO-RESTORED - Grave Row, service returns. Loop, 60 bars 3/4, 96 BPM, C major.
The same D.N.A. theme as the broken district, now full and in tune: the waltz in C major on strings and organ, the celesta that was
detuned now doubling the violins cleanly, the choir breathing under it. Calm graves and humane resolution - the Crossroads motif
RESOLVED once in the horns - but the wider Capital's tension is kept until Primm falls: a stiff orchestra-kit snare tick and a
recurring borrowed F minor chord (and an Ab) that keep a shadow at the edge of the square.
"""
from lib import Score, m, motif, motif_head, p
from lib.zones import DNA_THEME, to_mode

THEME = to_mode(DNA_THEME, {3: 1, 8: 1, 10: 1, 1: 1})
PROG = ['C', 'C', 'F', 'Fm', 'G7', 'G7', 'C', 'Am', 'F', 'Dm', 'C/G', 'G7', 'C', 'Ab', 'G7', 'C']
B_PROG = ['Am', 'F', 'C', 'G', 'Am', 'Fm', 'C/G', 'G7']
INTRO = ['C', 'Fm', 'C/G', 'G7']


def build():
    s = Score('MUS-CAP-NECRO-RESTORED', bpm=96, bars=60, meter=(3, 4), key='C major', seed=318)
    s.seat('vln', 'pad', 'vc', 'cb', 'pizz', 'hn', 'cl', 'bsn', 'cel', 'choir', 'timp', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=74)
    for bar, nm in ((0, 'intro'), (4, 'A clarinet + celesta'), (20, "A' strings + organ"), (36, 'B resolved motif'),
                    (44, "A'' tutti"), (56, 'outro')):
        s.section(bar, nm)
    s.notes.append('Restored district: the same D.N.A. theme in C major, in tune; resolved motif once; snare tick + Fm keep the Capital tension.')

    def tick(bar, vel=30):
        s.hit('snare2', bar * 3, vel + 6)
        s.hit('rim', bar * 3 + 2, vel - 6)

    def waltz(bar, sym, vel):
        s.bass(bar, sym, vel, 'waltz')
        v = s.voicing(sym, low='G3', n=3)[1]
        for beat in (1, 2):
            for n in v:
                s.note('pizz', bar * 3 + beat, .4, p(n), vel - 14)

    def organ(bar, sym, vel, beats=3):
        s.pad('organ', bar, sym, vel, beats=beats, low='E3')

    def intro(bar):
        for i, sym in enumerate(INTRO):
            waltz(bar + i, sym, 58)
            organ(bar + i, sym, 50)
            tick(bar + i)
        s.motif('cel', bar + 1, motif_head('C5', 'major', rhythm=(1, .5, 1.5)), 52, form='head (celesta, in tune)', lead=False)

    intro(0)
    for i in range(16):
        bar, sym = 4 + i, PROG[i]
        waltz(bar, sym, 64)
        tick(bar)
        if i % 2 == 0:
            organ(bar, sym, 44, beats=6)
    s.mel('cl', 4, THEME, 86)
    s.line('cel', 4, THEME, 56, transpose=12)
    s.line('bsn', 12, THEME[20:], 56, transpose=-12)

    for i in range(16):
        bar, sym = 20 + i, PROG[i]
        waltz(bar, sym, 70)
        organ(bar, sym, 54)
        s.pad('pad', bar, sym, 46, low='G3')
        tick(bar, 28)
    s.mel('vln', 20, THEME, 96)
    s.line('cel', 20, THEME, 56, transpose=12)
    s.swell('vln', 20, 16, 90, 108, 'arch')

    for i in range(8):
        bar, sym = 36 + i, B_PROG[i]
        organ(bar, sym, 48)
        s.pad('choir', bar, sym, 46, low='G3')
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), 54)
        tick(bar, 24)
    s.motif('hn', 36, motif('C4', 'major', resolved=True) + m('r:2'), 86, form='RESOLVED (horns)')
    s.mel('vc', 39, THEME[20:30], 80, transpose=-12)
    s.motif('cl', 41, motif_head('A4', 'minor', rhythm=(1, .5, 1.5)) + m('r:3'), 70, form='head (clarinet, the Capital shadow)', lead=False)

    for i in range(12):
        bar, sym = 44 + i, PROG[i + 4]
        waltz(bar, sym, 76)
        organ(bar, sym, 56)
        s.pad('choir', bar, sym, 54, low='G3')
        s.pad('pad', bar, sym, 50, low='G3')
        tick(bar, 32)
        if i % 4 == 0:
            s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 64)
    s.mel('vln', 44, THEME[10:], 100)
    s.line('organ', 44, THEME[10:], 66, transpose=-12)
    s.line('hn', 48, THEME[20:30], 74, transpose=-12)

    s.expr('organ', 56, 100)
    intro(56)
    return s
