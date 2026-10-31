"""MUS-WAIT-BATTLE - Waiting Room of Eternity, combat. 96 bars 3/4, 136 BPM, G minor.
The waiting-room waltz in a hurry. Phrase one: the D.N.A. theme in G minor on the piano doubled by the clarinet, over a string-and-pizz
eighth ostinato, the clock and a walking bass. Phrase two (contrast): sustained tremolo and ghostly organ, the Crossroads motif in the
horns, the bassoon trying to finish the theme's answer. Then the theme returns brighter on flute and violins, a second motif statement,
and the intro bed carries the loop. Crisp percussion: woodblocks, concert bass drum, timpani; never frantic.
"""
from lib import Score, m, motif, motif_head, motif_tail, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS, theme_in

UP = 7                                      # C minor -> G minor
THEME = theme_in(DNA_THEME, UP - 12)
THEME_A, THEME_B = THEME[:20], THEME[20:]
INTRO = ['Cm', 'Cm', 'Ab', 'G7']
TENSE = ['Ab', 'Fm', 'Db', 'Gs', 'Ab', 'Fm', 'Db', 'G7'] * 2


def shifted(chords, k):
    out = {}
    for sym, (b, v) in chords.items():
        bb = p(b) + k
        while bb > p('F#2'):
            bb -= 12
        vv = [p(x) + k for x in v]
        while vv[0] > p('Bb3'):
            vv = [x - 12 for x in vv]
        out[sym] = (bb, vv)
    return out


def build():
    s = Score('MUS-WAIT-BATTLE', bpm=136, bars=96, meter=(3, 4), key='G minor', seed=313)
    s.V.update(shifted(DNA_CHORDS, UP))
    s.seat('piano', 'spic', 'trem', 'vln', 'vc', 'cb', 'pizz', 'hn', 'tbn', 'fl', 'cl', 'bsn', 'timp', 'perc')
    s.channel('organ', 'organ', pan=70, reverb=110, vol=70)
    for bar, nm in ((0, 'intro'), (4, 'A piano theme'), (20, 'B held, the motif'), (36, "A' flute + violins"),
                    (52, "B' motif again"), (68, 'C theme in the brass'), (84, 'D wind-down'), (92, 'outro')):
        s.section(bar, nm)

    def clock(bar, vel=38, eighths=True):
        for k in range(6 if eighths else 3):
            t = bar * 3 + k * (.5 if eighths else 1)
            s.note('perc', t, .2, 76 if k == 0 else 77, vel + (8 if k == 0 else (-10 if k % 2 else 0)), human=False)

    def ost(bar, sym, vel):
        tn = sorted(p(x) for x in s.voicing(sym)[1])
        for k in range(6):
            s.note('spic', bar * 3 + k * .5, .35, tn[[0, 2, 1, 3, 2, 1][k]], vel + (8 if k in (0, 3) else -4))

    def walk(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 3, .9, b, vel + 6)
        s.note('cb', bar * 3 + 1, .9, b + 7 if b + 7 < 48 else b - 5, vel - 4)
        s.note('cb', bar * 3 + 2, .9, b + 12 if b + 12 < 48 else b, vel - 6)
        s.note('vc', bar * 3, 1.0, b + 12, vel - 10)

    def pz(bar, sym, vel):
        v = s.voicing(sym)[1]
        for beat in (1, 2):
            for n in v[1:]:
                s.note('pizz', bar * 3 + beat, .3, p(n) + 12, vel)

    def drums(bar, vel):
        s.hit('bd', bar * 3, vel)
        s.hit('snare2', bar * 3 + 2, vel - 16)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            ost(bar + i, sym, 68)
            clock(bar + i, 40)
            walk(bar + i, sym, 70)
            s.pad('trem', bar + i, sym, 58)
            s.pad('organ', bar + i, sym, 50, beats=3)
            drums(bar + i, 62)
        s.motif('hn', bar + 1, motif_head('G3', 'minor', rhythm=(1, .5, 3.5)), 72, form='head (horns)')
        s.timp_roll((bar + 3) * 3 + 1, 2, 'D2', 44, 84)

    intro(0)
    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        ost(bar, sym, 62)
        clock(bar, 36)
        walk(bar, sym, 74)
        pz(bar, sym, 50)
        drums(bar, 60)
        if i % 4 == 0:
            s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 78)
    s.mel('piano', 4, THEME, 96, transpose=12)
    s.line('cl', 4, THEME, 66, transpose=12)
    s.timp_roll(19 * 3, 3, 'D2', 50, 94)

    def held(bar0, n):
        for i in range(n):
            bar, sym = bar0 + i, TENSE[i]
            s.pad('trem', bar, sym, 62)
            if i % 2 == 0:
                s.pad('organ', bar, sym, 56, beats=6)
            walk(bar, sym, 64)
            clock(bar, 34, eighths=False)
            if i % 4 == 3:
                s.timp_roll(bar * 3, 3, p(s.voicing(sym)[0]) + 12, 36, 76)
    held(20, 16)
    s.motif('hn', 20, motif('G3', 'minor') + m('r:2'), 94, form='stated (horns)')
    s.motif('hn', 23, motif('Bb3', 'minor') + m('r:2'), 94, form='stated (horns, up a third)')
    s.mel('bsn', 26, THEME_B[:10], 86)
    s.mel('hn', 30, THEME_B[10:], 92)

    for i in range(16):
        bar, sym = 36 + i, DNA_PROG[i]
        ost(bar, sym, 66)
        clock(bar, 38)
        walk(bar, sym, 78)
        pz(bar, sym, 54)
        drums(bar, 66)
        s.pad('organ', bar, sym, 42, beats=3)
        if i % 2 == 0:
            s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 80)
    s.mel('fl', 36, THEME, 92, transpose=24)
    s.line('vln', 36, THEME, 88, transpose=12)
    s.hit('crash', 36 * 3, 70, dur=2)

    held(52, 16)
    s.motif('cl', 52, motif('D4', 'minor') + m('r:2'), 88, form='stated (clarinet, on the fifth)')
    s.mel('piano', 55, THEME_A[:10], 84, transpose=12)
    s.motif('hn', 60, motif('G3', 'minor') + m('r:2'), 96, form='stated (horns + violins)')
    s.line('vln', 60, motif('G4', 'minor') + m('r:2'), 80)
    s.mel('bsn', 63, THEME_A[10:], 88)

    for i in range(16):
        bar, sym = 68 + i, DNA_PROG[i]
        ost(bar, sym, 72)
        clock(bar, 42)
        walk(bar, sym, 84)
        drums(bar, 72)
        s.pad('trem', bar, sym, 60)
        s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 84 if i % 2 == 0 else 68)
        if i % 4 == 0:
            s.hit('crash', bar * 3, 76, dur=2)
    s.mel('hn', 68, THEME, 102, transpose=12)
    s.line('tbn', 68, THEME, 84)
    s.line('piano', 68, THEME, 70, transpose=24)

    for i, sym in enumerate(['Cm', 'Ab', 'Fm', 'G7', 'Cm', 'Db', 'Gs', 'G7']):
        bar = 84 + i
        ost(bar, sym, 66)
        clock(bar, 38)
        walk(bar, sym, 72)
        pz(bar, sym, 50)
        s.pad('organ', bar, sym, 46, beats=3)
    s.mel('piano', 84, THEME_A[:15], 90, transpose=12)

    intro(92)
    return s
