"""MUS-WAIT-EXP - Waiting Room of Eternity, exploration. 64 bars 3/4, 96 BPM, Ab major.
A pleasant waiting-room waltz: the D.N.A. theme turned bright (Ab major) on piano and flute, a clock on the wall and a discreet ghostly
organ. Every cadence is promised and then sidestepped - the phrase lands on Fm or Db instead of Ab, and the next phrase starts as if
nothing happened. A B section lets the clarinet ask the Crossroads motif over the celesta; the motif ends open (still waiting).
"""
from lib import Score, m, motif, motif_head, motif_tail, p
from lib.zones import DNA_THEME, to_mode, theme_in

THEME = theme_in(to_mode(DNA_THEME, {3: 1, 8: 1, 10: 1, 1: 1}), -4)        # C minor -> C major -> Ab major
PROG = ['Ab', 'Ab', 'Db', 'Db', 'Eb7', 'Eb7', 'Ab', 'Fm', 'Db', 'Bbm', 'Ab/Eb', 'Eb7', 'Ab', 'Fm', 'Eb7', 'Fm']   # last: sidestep
B_PROG = ['Fm', 'Db', 'Ab', 'Eb', 'Fm', 'Bbm7', 'Db', 'Eb7'] * 2
INTRO = ['Ab', 'Dbmaj7', 'Ab', 'Eb7sus4']


def build():
    s = Score('MUS-WAIT-EXP', bpm=96, bars=64, meter=(3, 4), key='Ab major', seed=312)
    s.seat('piano', 'fl', 'cl', 'bsn', 'pizz', 'vc', 'cb', 'pad', 'cel', 'perc')
    s.channel('organ', 'organ', pan=70, reverb=115, vol=60)
    for bar, nm in ((0, 'intro'), (4, 'A piano tune'), (20, "A' flute"), (36, 'B the question'), (52, "A'' and the sidestep"),
                    (60, 'outro')):
        s.section(bar, nm)

    def clock(bar, vel=30):
        for k in range(3):
            s.note('perc', bar * 3 + k, .2, 76 if k == 0 else 77, vel + (6 if k == 0 else 0), human=False)

    def oompah(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 3, 1.0, b, vel)
        v = s.voicing(sym, low='Ab3', n=3)[1]
        for beat in (1, 2):
            for n in v:
                s.note('piano', bar * 3 + beat, .45, p(n), vel - 16)

    def ghost(bar, sym, vel, beats=6):
        s.pad('organ', bar, sym, vel, beats=beats, low='Ab3', n=3)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            oompah(bar + i, sym, 56)
            clock(bar + i)
        ghost(bar, 'Ab', 40, beats=12)
        s.motif('cel', bar + 1, motif_head('Ab5', 'major', rhythm=(1, .5, 1.5)), 50, form='head (celesta)', lead=False)

    intro(0)
    for i in range(16):
        bar, sym = 4 + i, PROG[i]
        oompah(bar, sym, 62)
        clock(bar)
        s.pad('pad', bar, sym, 34, low='Ab3')
        if i % 4 == 0:
            ghost(bar, sym, 38)
    s.mel('piano', 4, THEME[:-1] + [('Ab4', 1), ('C5', 2)], 104, transpose=12)
    s.line('cl', 4, THEME[:20], 50)     # the last note sidesteps to C over Fm
    s.line('pizz', 12, THEME[20:30], 54)

    for i in range(16):
        bar, sym = 20 + i, PROG[i]
        oompah(bar, sym, 64)
        clock(bar)
        s.pad('pad', bar, sym, 40, low='Ab3')
    s.mel('fl', 20, THEME[:-1] + [('F4', 1), ('Ab4', 2)], 86, transpose=12)
    s.line('cl', 20, THEME[:20], 56)
    s.line('bsn', 28, THEME[20:], 54, transpose=-12)
    s.swell('organ', 28, 8, 60, 90, 'arch')
    ghost(28, 'Db', 42, beats=24)

    for i in range(16):
        bar, sym = 36 + i, B_PROG[i]
        s.note('cb', bar * 3, 2.8, p(s.voicing(sym)[0]), 54)
        v = sorted(p(n) for n in s.voicing(sym, low='F4', n=3)[1])
        for k in range(3):
            s.note('cel', bar * 3 + k, .9, v[k] + 12, 46)
        clock(bar, 28)
        if i % 2 == 0:
            ghost(bar, sym, 44)
    s.motif('cl', 36, motif('F4', 'minor') + m('r:2'), 84, form='stated (clarinet, F minor - still waiting)')
    s.mel('vc', 39, THEME[20:30], 74)
    s.motif('fl', 44, motif('Ab4', 'major') + m('r:2'), 82, form='stated (flute, Ab major, open on the fifth)')
    s.mel('piano', 47, THEME[30:], 74, transpose=12)

    for i in range(8):
        bar, sym = 52 + i, PROG[i + 8]
        oompah(bar, sym, 66)
        clock(bar)
        s.pad('pad', bar, sym, 42, low='Ab3')
    s.mel('piano', 52, THEME[20:-1] + [('Db5', 3)], 84, transpose=12)            # sidestep to Db
    s.line('fl', 52, THEME[20:-1] + [('F5', 3)], 64, transpose=12)

    s.expr('organ', 60, 100)        # back to bar 0's organ level for the seam
    intro(60)
    # into the loop point: strings swell under the last two bars and a pickup leads into bar 0's downbeat
    s.pad('pad', 62, 'Eb7sus4', 40, beats=6, low='Ab3')
    s.swell('pad', 62, 2, 40, 80)
    s.line('fl', 63, m('r:1 Eb5:1 F5:.5 G5:.5'), 52)
    s.note('cb', 63 * 3 + 2, 1, p('Bb1'), 60)
    return s
