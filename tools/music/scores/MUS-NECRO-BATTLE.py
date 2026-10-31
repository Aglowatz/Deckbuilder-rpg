"""MUS-NECRO-BATTLE - The Department of Necrotic Affairs, combat. 96 bars 3/4, 138 BPM, C minor.
The D.N.A. waltz driven into a fast scherzo: a string ostinato of eighths and the woodblock clock ticking in eighths, the zone theme in the
low brass (A), the Crossroads motif in the horns over harpsichord (B), a quiet paperwork section where bassoon and clarinet pass the
theme's answer from desk to desk (C), the organ and choir taking the whole theme (D), and the motif augmented in the trombones against
theme fragments in the violins (E). Dry and methodical - people doing a job - never horror. The intro bed returns as the outro.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p
from lib.zones import DNA_THEME, DNA_THEME_A, DNA_THEME_B, DNA_PROG, DNA_CHORDS

B_PROG = ['Ab', 'Fm', 'Db', 'Gs', 'Ab', 'Fm', 'Db', 'G7'] * 2
C_PROG = ['Cm', 'Ab', 'Fm', 'G7', 'Cm', 'Db', 'Bdim', 'G7']
E_PROG = ['Cm', 'Cm', 'Ab', 'Ab', 'Fm', 'Fm', 'G7', 'G7', 'Cm', 'Cm', 'Db', 'Db', 'Ab', 'Fm', 'G7', 'G7']
INTRO = ['Cm', 'Cm', 'Ab', 'G7']


def build():
    s = Score('MUS-NECRO-BATTLE', bpm=138, bars=96, meter=(3, 4), key='C minor', seed=301)
    s.V.update(DNA_CHORDS)
    s.seat('vln', 'spic', 'trem', 'vc', 'cb', 'pizz', 'hn', 'tbn', 'tuba', 'bsn', 'cl', 'timp', 'choir', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=84)
    s.channel('hpsd', 'harpsichord', pan=30, reverb=80, vol=70)
    for bar, nm in ((0, 'intro'), (4, 'A brass theme'), (20, 'B motif'), (36, 'C paperwork'), (44, 'D organ tutti'),
                    (60, 'E augmented'), (76, 'F theme again'), (92, 'outro')):
        s.section(bar, nm)

    def ost(bar, sym, vel):
        """Eighth-note string drive: root, fifth, octave, fifth, third, fifth (accent on 1 and the and of 2)."""
        b, v = s.voicing(sym)
        tn = sorted(p(x) for x in v)
        r = tn[0]
        cell = [r, tn[1], tn[2], tn[1], tn[3] - 12 if tn[3] - 12 > r else tn[1], tn[2]]
        acc = [10, -6, 2, -6, 6, -4]
        for k, (n, a) in enumerate(zip(cell, acc)):
            s.note('spic', bar * 3 + k * .5, .35, n, vel + a)

    def clock(bar, vel=40, eighths=True):
        for k in range(6 if eighths else 3):
            t = bar * 3 + k * (.5 if eighths else 1)
            down = k == 0
            s.note('perc', t, .2, 76 if down else 77, vel + (10 if down else (-8 if k % 2 else 0)), human=False)

    def low(bar, sym, vel, timp=True, tuba=False):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 3, 1.2, b, vel)
        s.note('cb', bar * 3 + 2, .5, b + 7 if b + 7 < 48 else b, vel - 12)
        s.note('vc', bar * 3, 1.2, b + 12, vel - 8)
        if tuba:
            s.note('tuba', bar * 3, 1.0, b + 12, vel - 6)
        if timp:
            s.timp_hit(bar * 3, b + 12 if b + 12 <= p('A2') else b, vel + 2)

    def pizz2(bar, sym, vel):
        v = s.voicing(sym)[1]
        for beat in (1, 2):
            for n in v[1:]:
                s.note('pizz', bar * 3 + beat, .35, p(n) + 12, vel)

    def bed(bar, sym, vel):
        s.pad('organ', bar, sym, vel - 8, beats=3)
        s.pad('trem', bar, sym, vel - 6)

    def intro(bar, outro=False):
        for i, sym in enumerate(INTRO):
            ost(bar + i, sym, 70)
            clock(bar + i, 42)
            low(bar + i, sym, 74, timp=(i % 2 == 0))
            bed(bar + i, sym, 66)
            s.pad('tbn', bar + i, sym, 52, beats=1, beat=2, low='C3', n=2)
        s.motif('hn', bar + 1, motif_head('C4', 'minor', rhythm=(1, .5, 3.5)), 74, form='head (horns, the call)')
        s.timp_roll((bar + 3) * 3 + 1, 2, 'G2', 44, 84)

    intro(0)

    # A 4-19: the D.N.A. theme in trombones + horns (low, formal), ostinato and clock under it
    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        ost(bar, sym, 66)
        clock(bar, 36)
        low(bar, sym, 76, timp=(i % 4 == 0), tuba=True)
        pizz2(bar, sym, 52)
        if i >= 8:
            s.pad('trem', bar, sym, 54)
    s.mel('hn', 4, DNA_THEME, 96, transpose=-12)
    s.line('tbn', 4, DNA_THEME_A, 72, transpose=-12)
    s.line('tbn', 12, DNA_THEME_B, 76, transpose=-12)
    s.swell('hn', 4, 16, 92, 112, 'arch')
    s.timp_roll(19 * 3, 3, 'G2', 50, 96)

    # B 20-35: the Crossroads motif in the horns, harpsichord ostinato, the theme's head answered by bassoon
    for i in range(16):
        bar, sym = 20 + i, B_PROG[i]
        ost(bar, sym, 70)
        clock(bar, 40)
        low(bar, sym, 80, timp=(i % 2 == 0))
        s.pad('trem', bar, sym, 60)
        tn = sorted(p(n) for n in s.voicing(sym)[1])
        for k in range(6):
            s.note('hpsd', bar * 3 + k * .5, .3, tn[[1, 2, 3, 2, 3, 1][k]] + 12, 50 + (8 if k == 0 else 0))
    s.motif('hn', 20, motif('C4', 'minor') + m('r:2'), 98, form='stated (horns)')
    s.motif('hn', 23, motif('Eb4', 'minor') + m('r:2'), 98, form='stated (horns, sequenced up a third)')
    s.mel('tbn', 26, m('Ab3:2 G3:1 | F3:3 | Db3:2 F3:1 | G3:3'), 90)
    s.motif('hn', 28, motif('C4', 'minor') + m('r:2'), 102, form='stated (horns + violins 8va)')
    s.line('vln', 28, motif('C4', 'minor') + m('r:2'), 84, transpose=12)
    s.mel('tbn', 31, m('Db4:2 C4:1 | B3:3 | C4:2 D4:1 | Eb4:2 D4:1 | B3:3'), 92)
    s.line('bsn', 24, DNA_THEME[:5], 70, transpose=-12)
    s.timp_roll(35 * 3, 3, 'G2', 50, 100)
    s.hit('crash', 36 * 3, 70, dur=2)

    # C 36-43: paperwork - the theme's answer passed desk to desk (bassoon, clarinet, harpsichord), pizz and clock only
    for i in range(8):
        bar, sym = 36 + i, C_PROG[i]
        clock(bar, 46)
        pizz2(bar, sym, 58)
        s.note('cb', bar * 3, 1, p(s.voicing(sym)[0]), 66)
        s.pad('organ', bar, sym, 44, beats=3)
    s.mel('bsn', 36, DNA_THEME_B[:10], 90, transpose=-12)
    s.mel('cl', 38, DNA_THEME_B[5:14], 86)
    s.mel('hpsd', 40, DNA_THEME_B[10:], 80)
    s.motif('cl', 42, motif_tail('C5', 'minor', rhythm=(1.5, .5, 4)), 80, form='tail (clarinet, left unfinished)')
    s.timp_roll(43 * 3, 3, 'G2', 40, 104)

    # D 44-59: organ + choir take the whole theme, brass chords, timpani on every downbeat
    for i in range(16):
        bar, sym = 44 + i, DNA_PROG[i]
        ost(bar, sym, 74)
        clock(bar, 44)
        low(bar, sym, 88, timp=True, tuba=True)
        s.pad('choir', bar, sym, 64, low='G3')
        s.pad('trem', bar, sym, 62)
        v = s.voicing(sym)[1]
        for beat in (1, 2):
            s.note('tbn', bar * 3 + beat, .6, p(v[1]), 60)
            s.note('tbn', bar * 3 + beat, .6, p(v[2]), 60)
        if i % 4 == 0:
            s.hit('crash', bar * 3, 76, dur=2)
    s.mel('organ', 44, DNA_THEME, 104)
    s.line('vln', 44, DNA_THEME, 96)
    s.line('hn', 52, DNA_THEME_B, 86, transpose=-12)
    s.swell('choir', 44, 16, 70, 110, 'arch')

    # E 60-75: the Crossroads motif augmented in the trombones against theme fragments in the violins; quieter, then building
    for i in range(16):
        bar, sym = 60 + i, E_PROG[i]
        ost(bar, sym, 62 + i)
        clock(bar, 38)
        low(bar, sym, 72 + i, timp=(i % 2 == 0))
        s.pad('trem', bar, sym, 50 + i)
    s.motif('tbn', 60, augment(motif('C3', 'minor'), 2) + m('r:2'), 92, form='augmented (trombones)')
    s.mel('vln', 61, DNA_THEME[:5], 92, transpose=12)
    s.mel('vln', 65, DNA_THEME[5:10], 92, transpose=12)
    s.mel('vln', 69, DNA_THEME[10:15], 96, transpose=12)
    s.mel('vln', 72, DNA_THEME[15:20], 100, transpose=12)
    s.motif('hn', 74, motif_head('G4', 'minor', rhythm=(1, .5, 1.5)), 92, form='head (horns, pushing on)', lead=False)
    s.snare_roll(75 * 3, 3, 30, 96, inst='bd2', rate=6)

    # F 76-91: the theme once more in the horns, the motif's head echoing in the organ
    for i in range(16):
        bar, sym = 76 + i, DNA_PROG[i]
        ost(bar, sym, 70)
        clock(bar, 40)
        low(bar, sym, 82, timp=(i % 2 == 0), tuba=(i < 12))
        s.pad('trem', bar, sym, 58)
        pizz2(bar, sym, 50)
    s.mel('hn', 76, DNA_THEME_A, 98)
    s.line('tbn', 76, DNA_THEME_A, 80, transpose=-12)
    s.mel('vln', 84, DNA_THEME_B, 96)
    s.line('hn', 84, DNA_THEME_B, 84, transpose=-12)
    s.motif('organ', 82, motif_head('C5', 'minor', rhythm=(1, .5, 1.5)), 70, form='head (organ echo)', lead=False)
    s.hit('crash', 76 * 3, 72, dur=2)
    s.timp_roll(91 * 3, 3, 'G2', 50, 80)

    # OUTRO 92-95 = the intro, so the loop lands
    intro(92)
    return s
