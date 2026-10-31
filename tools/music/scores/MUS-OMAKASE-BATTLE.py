"""MUS-OMAKASE-BATTLE - Omakase, combat. 72 bars 4/4, 140 BPM, D minor.
Precision at battle tempo. A koto ostinato in exact 8ths, taiko and claves on the grid with a light kick, a moving contrabass, strings
and brass. Two contrasting battle phrases: A - the Buffet theme in D minor in the brass, clipped and exact; B - the "knife" phrase,
staccato string stabs answering the shakuhachi's Crossroads motif. C drops to half time (koto tremolo, the shakuhachi on the theme's
second phrase), D is the tutti. Intro and outro are a pad + horn bed over the ostinato, never the ostinato alone.
"""
from lib import Song, m, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, to_mode

THEME = to_mode(transpose(BUFFET_THEME, -3), {6: -1, 11: -1, 1: -1})
PROG = ['Dm', 'Bbmaj7', 'Gm7', 'A7', 'Dm', 'Bb', 'Gm', 'A7', 'Bbmaj7', 'Bbm6', 'Dm/A', 'E7', 'Gm7', 'A7', 'Dm', 'A7']
KNIFE = ['Dm', 'Dm', 'C', 'Bb', 'Gm', 'Gm', 'A7sus4', 'A7']
STAB = m('D5:.25 D5:.25 r:.5 F5:.25 E5:.25 r:.5 D5:.5 A4:.5 r:1')


def build():
    s = Song('MUS-OMAKASE-BATTLE', bpm=140, bars=72, key='D minor', seed=408, jitter=0.004)
    s.channel('koto', 107, 46, 85, 86)
    s.channel('shaku', 77, 58, 100, 98)
    s.channel('vln', 'strings', 36, 95, 96)
    s.channel('spic', 'strings', 30, 85, 82)
    s.channel('pad', 'slow_strings', 64, 100, 74)
    s.channel('brass', 'brass', 70, 90, 96)
    s.channel('hn', 'horn', 78, 95, 88)
    s.channel('cb', 'contrabass', 92, 90, 90)
    s.channel('taiko', 116, 64, 75, 96)
    s.channel('timp', 'timpani', 64, 80, 88)
    s.channel('glock', 'glock', 40, 95, 56)
    s.channel('kit', 'standard_kit', 64, 60, 86)
    for bar, nm in ((0, 'intro bed'), (4, 'A theme'), (20, 'B knife'), (36, 'C half time'), (52, 'D tutti'), (68, 'outro bed')):
        s.section(bar, nm)

    def grid(bar, vel, half=False):
        for k in range(8):
            s.note('kit', bar * 4 + k * .5, .1, 75, vel - 24 + (10 if k % 4 == 0 else 0), human=False)
        hits = (0, 2) if half else (0, 1.5, 2, 3.5)
        for b in hits:
            s.note('taiko', bar * 4 + b, .5, 'C3' if b in (0, 2) else 'G3', vel + (6 if b == 0 else -6))
        if not half:
            s.note('kit', bar * 4, .25, 36, vel - 10, human=False)
            s.note('kit', bar * 4 + 2, .25, 36, vel - 14, human=False)

    def ost(bar, sym, vel):
        tn = s.chord_tones(sym, 'D4', 4)
        for k in range(8):
            s.note('koto', bar * 4 + k * .5, .35, tn[(0, 2, 1, 3, 0, 2, 3, 1)[k]], vel + (8 if k % 4 == 0 else -4))

    def bass(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        for k, off in enumerate((0, 0, 7, 12 if b + 12 < 48 else 7)):
            s.note('cb', bar * 4 + k, .8, b + off, vel + (8 if k == 0 else 0))

    def bed(bar):
        for i, sym in enumerate(['Dm', 'Dm', 'Bb', 'A7']):
            ost(bar + i, sym, 78)
            bass(bar + i, sym, 76)
            grid(bar + i, 82)
            s.pad('pad', bar + i, sym, 72, low='A3')
            s.chord('hn', (bar + i) * 4, 3.9, s.chord_tones(sym, 'D4', 3), 62)
        s.motif('shaku', bar + 1, motif_head('D5', 'minor', rhythm=(1, .5, 2.5)) + [('r', 4)], 86, form='head (shakuhachi, over the bed)')
        s.swell('pad', bar + 3, 1, 84, 100)

    bed(0)

    # A 4-19: the theme in the brass, clipped and exact
    for i in range(16):
        sym = PROG[i]
        ost(4 + i, sym, 66)
        bass(4 + i, sym, 80)
        grid(4 + i, 82)
        s.pad('pad', 4 + i, sym, 48, low='A3')
        if i % 4 == 0:
            s.timp_hit((4 + i) * 4, p(s.voicing(sym)[0]) + 12, 84)
    s.mel('brass', 4, THEME, 96, legato=.7)
    s.line('glock', 12, THEME[21:40], 50, tr=12)

    # B 20-35: the knife - staccato stabs answering the shakuhachi's motif
    for i in range(16):
        bar = 20 + i
        sym = KNIFE[i % 8]
        bass(bar, sym, 78)
        grid(bar, 80)
        s.pad('pad', bar, sym, 56, low='A3')
        if i % 2 == 1:
            s.line('spic', bar, STAB, 84, tr=(0 if i % 4 == 1 else -2))
    for k in (20, 28):
        s.motif('shaku', k, motif('D5', 'minor') + [('r', 1)], 96, form='stated (shakuhachi, the knife phrase)')
    s.motif('hn', 24, motif('A3', 'minor') + [('r', 1)], 80, form='stated (horns, answering)', lead=False)
    for k in range(16):
        s.note('kit', 35 * 4 + k * .25, .2, 38, 40 + k * 4, human=False)

    # C 36-51: half time - koto tremolo, the shakuhachi on the theme's second phrase
    for i in range(16):
        bar = 36 + i
        sym = PROG[i]
        tn = s.chord_tones(sym, 'D5', 2)
        for k in range(16):
            s.note('koto', bar * 4 + k * .25, .2, tn[k % 2], 50 + (6 if k % 4 == 0 else 0))
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 66)
        s.pad('pad', bar, sym, 60, low='A3')
        grid(bar, 72, half=True)
    s.mel('shaku', 36, THEME[21:], 92)
    s.line('vln', 44, THEME[40:], 74, tr=-12)
    s.swell('pad', 36, 16, 70, 108)
    s.timp_roll(51 * 4, 4, 'A1', 40, 100)

    # D 52-67: tutti
    for i in range(16):
        bar = 52 + i
        sym = PROG[i]
        ost(bar, sym, 70)
        bass(bar, sym, 86)
        grid(bar, 90)
        s.pad('pad', bar, sym, 56, low='A3')
        s.chord('brass', bar * 4 + 1.5, .3, s.chord_tones(sym, 'F3', 3), 72)
        if i % 4 == 0:
            s.timp_hit(bar * 4, p(s.voicing(sym)[0]) + 12, 92)
            s.note('kit', bar * 4, 2, 49, 84)
    s.mel('vln', 52, THEME, 102)
    s.line('brass', 52, THEME, 80, tr=-12, legato=.7)
    s.motif('hn', 60, motif('D4', 'minor') + [('r', 1)], 92, form='stated (horns, tutti)', lead=False)
    s.timp_roll(67 * 4, 4, 'A1', 50, 92)

    bed(68)
    s.fade_vel(70, 72, 1.3, ['koto', 'cb', 'kit', 'taiko', 'hn', 'pad'])     # seam: lift into the loop point
    return s
