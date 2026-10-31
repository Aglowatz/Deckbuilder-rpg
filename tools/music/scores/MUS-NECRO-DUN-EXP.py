"""MUS-NECRO-DUN-EXP - Hall of Final Approvals, exploration. 64 bars 3/4, 88 BPM, F minor.
Unresolved phrases pass from desk to desk: the D.N.A. theme (moved to F minor) starts in the clarinet, is taken over by the bassoon an
octave down and stamped short before its cadence, then splinters into two-bar fragments handed between celesta, cello, harpsichord and
horn while the pizzicato and harpsichord pile up layer by layer under a slowly swelling organ. A quiet middle lets a humane line (the
Crossroads motif in the cello, then the clarinet) try to finish - it stays open. The paperwork peak puts the theme's answer in the organ
and choir; the clock and a single organ chord return for the loop.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p
from lib.zones import DNA_THEME, DNA_THEME_A, DNA_THEME_B, DNA_PROG, DNA_CHORDS, theme_in

UP = 5          # C minor -> F minor (chords up a fourth, tunes down a fifth)
THEME = theme_in(DNA_THEME, UP - 12)
THEME_A, THEME_B = THEME[:20], THEME[20:]
INTRO = ['Cm', 'Cm', 'Ab', 'G7']
B_PROG = ['Cm', 'Fm', 'Ab', 'G7', 'Cm', 'Db', 'Fm', 'G7'] * 2
C_PROG = ['Ab', 'Fm', 'Db', 'Gs', 'Ab', 'Fm', 'Db', 'Gs', 'Ab', 'Db', 'Fm', 'G7']


def shifted(chords, k):
    out = {}
    for sym, (b, v) in chords.items():
        bb = p(b) + k
        while bb > p('F#2'):
            bb -= 12
        out[sym] = (bb, [p(x) + k for x in v])
    return out


def build():
    s = Score('MUS-NECRO-DUN-EXP', bpm=88, bars=64, meter=(3, 4), key='F minor', seed=302)
    s.V.update(shifted(DNA_CHORDS, UP))
    s.seat('vln', 'trem', 'vc', 'cb', 'pizz', 'hn', 'tbn', 'bsn', 'cl', 'timp', 'choir', 'cel', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=84)
    s.channel('hpsd', 'harpsichord', pan=30, reverb=80, vol=68)
    s.channel('pz2', 'pizz', pan=52, reverb=75, vol=74)
    for bar, nm in ((0, 'intro clock'), (4, 'A desk to desk'), (20, 'B fragments pile up'), (36, 'C humane line'),
                    (48, 'D paperwork peak'), (60, 'outro clock')):
        s.section(bar, nm)

    def clock(bar, vel=38):
        for k in range(3):
            s.note('perc', bar * 3 + k, .2, 76 if k == 0 else 77, vel + (8 if k == 0 else 0), human=False)

    def organ(bar, sym, vel, bars=1, pedal=True):
        s.pad('organ', bar, sym, vel, beats=3 * bars)
        if pedal:
            b = p(s.voicing(sym)[0])
            s.note('organ', bar * 3, 3 * bars + .05, b + (12 if b < p('C2') else 0), vel - 6)

    def pz(bar, sym, vel, ch='pizz', pattern=(0, 1, 2), up=12):
        v = sorted(p(x) for x in s.voicing(sym)[1])
        for i, beat in enumerate(pattern):
            s.note(ch, bar * 3 + beat, .35, v[(i + 1) % len(v)] + up, vel + (6 if beat == 0 else 0))

    def hpsd8(bar, sym, vel):
        v = sorted(p(x) for x in s.voicing(sym)[1])
        for k in range(6):
            s.note('hpsd', bar * 3 + k * .5, .3, v[[0, 2, 1, 3, 2, 1][k]] + 12, vel + (6 if k == 0 else 0))

    def intro(bar):
        for i, sym in enumerate(INTRO):
            organ(bar + i, sym, 52)
            clock(bar + i, 40)
            pz(bar + i, sym, 50, pattern=(0,))
            s.note('cb', (bar + i) * 3, 2.9, p(s.voicing(sym)[0]), 54)
        s.line('cel', bar + 1, m('B5:1 F5:2'), 44)
        s.motif('bsn', bar + 2, motif_head('F2', 'minor', rhythm=(1, .5, 1.5)) + m('r:3'), 60, form='head (bassoon, low)', lead=False)

    intro(0)

    # A 4-19: the theme starts in the clarinet; the bassoon takes it over an octave down and is stamped short before the cadence
    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        clock(bar, 34)
        pz(bar, sym, 56)
        s.bass(bar, sym, 58, 'waltz')
        if i % 2 == 0:
            organ(bar, sym, 40, bars=2, pedal=False)
    s.mel('cl', 4, THEME_A, 86, transpose=12)
    s.mel('bsn', 12, THEME_A[:16], 88)
    s.hit('rim', 19 * 3 + 1, 66)           # the stamp
    s.mel('hpsd', 18, m('C5:1 Bb4:1 Ab4:1 | G4:3'), 66)
    s.swell('organ', 4, 16, 70, 92, 'arch')

    # B 20-35: fragments in altered registers, overlapping; the pizzicato and harpsichord pile up layer by layer
    for i in range(16):
        bar, sym = 20 + i, B_PROG[i]
        clock(bar, 36 + i)
        pz(bar, sym, 56 + i)
        s.bass(bar, sym, 60 + i, 'waltz')
        if i >= 4:
            pz(bar, sym, 50 + i, ch='pz2', pattern=(.5, 1.5, 2.5), up=24)
        if i >= 8:
            hpsd8(bar, sym, 44 + i)
        organ(bar, sym, 42 + i, pedal=(i % 4 == 0))
    frags = [('cel', 20, THEME_A[:5], 24), ('vc', 22, THEME_A[5:10], 0), ('cl', 24, THEME_A[10:15], 12),
             ('hn', 26, THEME_A[:5], 0), ('cel', 28, THEME_B[:5], 24), ('vc', 30, THEME_B[5:10], -12),
             ('cl', 32, THEME_B[10:15], 12), ('hn', 34, THEME_B[15:], 0)]
    for ch, bar, mel, tr in frags:
        s.mel(ch, bar, mel, 88 if ch != 'cel' else 76, transpose=tr)
    s.motif('hn', 33, motif_tail('F4', 'minor', rhythm=(1.5, .5, 1)), 76, form='tail (horn, between desks)', lead=False)
    s.timp_roll(35 * 3, 3, 'C2', 40, 86)

    # C 36-47: the humane line - the Crossroads motif in the cello, then the clarinet, over organ and choir; it never finishes
    for i in range(12):
        bar, sym = 36 + i, C_PROG[i]
        organ(bar, sym, 46)
        s.pad('choir', bar, sym, 44, low='F3')
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), 50)
        if i % 2 == 0:
            clock(bar, 28)
    s.motif('vc', 36, augment(motif('F3', 'minor'), 1.5) + m('r:1.5'), 82, form='stated, slow (cello)')
    s.motif('cl', 41, motif('C5', 'minor') + m('r:2'), 80, form='stated (clarinet, an answer that stops short)')
    s.mel('cl', 44, m('Ab4:2 G4:1 | F4:3 | Db5:2 C5:1 | B4:3'), 76)
    s.line('trem', 40, m('Ab5:6 | G5:6'), 40)
    s.timp_roll(47 * 3, 3, 'C2', 36, 92)

    # D 48-59: the paperwork peak - organ and choir sing the theme's answer, every layer running, low brass
    for i in range(12):
        bar, sym = 48 + i, DNA_PROG[i + 4] if i < 8 else ['Cm', 'Ab', 'G7', 'G7'][i - 8]
        clock(bar, 46)
        pz(bar, sym, 66)
        pz(bar, sym, 60, ch='pz2', pattern=(.5, 1.5, 2.5), up=24)
        hpsd8(bar, sym, 56)
        s.bass(bar, sym, 74, 'waltz')
        s.pad('choir', bar, sym, 60, low='G3')
        s.pad('trem', bar, sym, 56)
        s.brass('tbn', bar, sym, 56, low='C3', n=2, beats=1)
        if i % 4 == 0:
            s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 82)
    s.mel('organ', 48, THEME_B, 100, transpose=12)
    s.line('vln', 48, THEME_B, 84, transpose=12)
    s.line('hn', 52, THEME_B[10:], 80)
    s.swell('choir', 48, 12, 70, 108, 'arch')
    s.hit('crash', 48 * 3, 62, dur=2)
    s.mel('cel', 58, m('F5:1 C6:2 | B5:3'), 60)

    s.expr('organ', 60, 100)        # the intro's organ level (bar 0 starts at CC11 100), so the loop seam matches
    intro(60)
    return s
