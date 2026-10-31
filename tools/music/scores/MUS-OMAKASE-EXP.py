"""MUS-OMAKASE-EXP - Omakase, exploration. 48 bars 4/4, 84 BPM, D minor.
A chef preparing one exquisite dish: space, exactness, a Japanese colour inside the Buffet palette. Koto (GM 107) places single notes and
open fifths; a shakuhachi (GM 77) breathes long tones; a woodblock marks time sparingly. The Buffet theme, in D minor, is laid out on the
koto note by note like a plated course, then sung by the strings over a precise koto ostinato. The Crossroads motif is the shakuhachi's
song in the quiet B section. Tension grows only through exactness (the ostinato tightens from 8ths to 16ths).
"""
from lib import Song, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, to_mode

THEME = to_mode(transpose(BUFFET_THEME, -3), {6: -1, 11: -1, 1: -1})
PROG = ['Dm', 'Bbmaj7', 'Gm7', 'Asus4', 'Dm', 'Bb', 'Gm', 'A7', 'Bbmaj7', 'Gm6', 'Dm/A', 'A7sus4', 'Gm7', 'Asus4', 'Dm', 'Asus4']
SPACE = ['Dm', 'Gm7', 'Bbmaj7', 'Asus4']


def build():
    s = Song('MUS-OMAKASE-EXP', bpm=84, bars=48, key='D minor', seed=407, jitter=0.004)
    s.channel('koto', 107, 46, 85, 98)
    s.channel('shaku', 77, 58, 100, 96)
    s.channel('vln', 'strings', 36, 100, 94)
    s.channel('pad', 'slow_strings', 64, 100, 70)
    s.channel('pizz', 'pizz', 74, 70, 76)
    s.channel('cb', 'contrabass', 92, 90, 80)
    s.channel('harp', 'harp', 50, 85, 70)
    s.channel('glock', 'glock', 40, 100, 54)
    s.channel('cl', 'clarinet', 60, 85, 74)
    s.channel('kit', 'standard_kit', 64, 80, 74)
    for bar, nm in ((0, 'space'), (8, 'A koto course'), (24, 'B shakuhachi'), (32, "A' strings"), (44, 'space again')):
        s.section(bar, nm)

    def block(bar, vel):
        s.note('kit', bar * 4, .1, 76, vel, human=False)
        s.note('kit', bar * 4 + 2.5, .1, 77, vel - 10, human=False)

    def space(bar, bars):
        for i in range(bars):
            sym = SPACE[i % 4]
            r = p(s.voicing(sym)[0]) + 24
            s.note('koto', (bar + i) * 4, 2, r, 70)
            s.note('koto', (bar + i) * 4 + 1.5, 2, r + 7, 60)
            s.pad('pad', bar + i, sym, 52, low='A3')
            s.note('cb', (bar + i) * 4, 4, p(s.voicing(sym)[0]), 50)
            block(bar + i, 58)
        s.motif('shaku', bar + 1, motif_head('D5', 'minor', rhythm=(2, 1, 3)) + [('r', 2)], 80, form='head (shakuhachi, a breath)')
        s.swell('pad', bar, bars, 76, 92)

    space(0, 8)

    # A 8-23: the theme laid out on the koto like a plated course; pizz and harp keep exact time
    for i in range(16):
        bar = 8 + i
        sym = PROG[i]
        s.pad('pad', bar, sym, 44, low='A3')
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 54)
        s.figure('pizz', bar, sym, [(0, 'b', .4, 4), (1, 1, .3, -6), (2, 2, .3, -4), (3, 1, .3, -8)], 52, low='D4')
        block(bar, 52)
    s.mel('koto', 8, THEME, 96, legato=.9)
    s.line('glock', 16, THEME[21:40], 50, tr=12)
    s.line('shaku', 20, [('A4', 4), ('F4', 4)], 62)

    # B 24-31: the shakuhachi sings the Crossroads motif; space returns
    for i in range(8):
        bar = 24 + i
        sym = SPACE[i % 4]
        s.pad('pad', bar, sym, 50, low='A3')
        s.harp(bar, sym, 42)
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 48)
    s.motif('shaku', 24, motif('D5', 'minor') + [('r', 1)], 80, form='stated (shakuhachi)')
    s.motif('shaku', 28, motif('A4', 'minor') + [('r', 1)], 76, form='stated a fifth down (shakuhachi)')
    s.line('koto', 26, [('D6', 1), ('A5', 1), ('r', 2)], 58)
    s.line('koto', 30, [('E6', 1), ('A5', 1), ('r', 2)], 58)
    s.swell('pad', 24, 8, 70, 96, 'arch')

    # A' 32-43: the strings sing the theme over a precise koto ostinato that tightens to 16ths
    for i in range(12):
        bar = 32 + i
        sym = PROG[i]
        tn = s.chord_tones(sym, 'D4', 4)
        rate = 2 if i < 6 else 4
        for k in range(4 * rate):
            s.note('koto', bar * 4 + k / rate, .3, tn[(0, 2, 1, 3)[k % 4]], 58 + (8 if k % rate == 0 else 0))
        s.pad('pad', bar, sym, 50, low='A3')
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 58)
        block(bar, 60)
    s.mel('vln', 32, THEME[:40], 92)
    s.line('cl', 40, THEME[21:28], 60, tr=-12)

    space(44, 4)
    s.fade_vel(46, 48, 1.25, ['koto', 'pad', 'cb', 'kit'])    # seam: lift the last bars to bar 0's level
    return s
