"""MUS-SHOP-MIREPOIX - Under the silver cloche. 36 bars 4/4, 100 BPM, Bb major (~86 s loop).
An intimate Buffet arrangement: formal at first - the theme on the piano, crisp and correct over delicate pizzicato and a clarinet
holding the harmony - then unexpectedly welcoming: the strings warm the theme's second phrase, a cello sings under it and the clarinet
offers the Crossroads motif's head like a taste from the spoon. Back to the formal piano for the loop. Low busyness for browsing.
"""
from lib import Song, motif_head, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_PROG, BUFFET_CHORDS

SEMIS = 5


def cmap(semis):
    out = {}
    for k, (b, v) in BUFFET_CHORDS.items():
        bb = p(b) + semis
        while bb > 42:
            bb -= 12
        while bb < 30:
            bb += 12
        vv = [p(n) + semis for n in v]
        while max(vv) > 66:
            vv = [x - 12 for x in vv]
        out[k] = (bb, vv)
    return out


def build():
    s = Song('MUS-SHOP-MIREPOIX', bpm=100, bars=36, key='Bb major', seed=410, jitter=0.012)
    s.V = cmap(SEMIS)
    s.channel('piano', 'piano', 58, 85, 96)
    s.channel('pizz', 'pizz', 74, 70, 74)
    s.channel('cl', 'clarinet', 60, 85, 80)
    s.channel('vln', 'strings', 36, 100, 92)
    s.channel('pad', 'slow_strings', 64, 100, 68)
    s.channel('vc', 'cello', 82, 90, 84)
    s.channel('cb', 'contrabass', 92, 90, 76)
    s.channel('glock', 'glock', 44, 100, 50)
    for bar, nm in ((0, 'formal'), (16, 'welcoming'), (28, 'formal again')):
        s.section(bar, nm)

    def formal(bar, sym, vel):
        b, v = s.V[sym]
        s.note('cb', bar * 4, 1.5, p(b), vel - 8)
        s.note('cb', bar * 4 + 2, 1.5, p(b) + 7 if sym not in ('C7', 'D7') else p(b), vel - 12)
        for beat in (1, 3):
            s.chord('pizz', bar * 4 + beat, .3, v, vel - 12)
        s.chord('cl', bar * 4, 3.8, v[:2], vel - 22)

    # 0-15: formal - the theme on the piano, crisp
    for i in range(16):
        formal(i, BUFFET_PROG[i], 64)
    s.mel('piano', 0, BUFFET_THEME, 84, tr=SEMIS - 12, legato=.7)
    s.note('glock', 0, 2, p('F6'), 46)

    # 16-27: welcoming - strings warm the second phrase, cello under, the clarinet offers the motif's head
    for i in range(12):
        bar = 16 + i
        sym = BUFFET_PROG[(i + 4) % 16]
        s.pad('pad', bar, sym, 50, low='F3')
        s.note('cb', bar * 4, 4, p(s.V[sym][0]), 54)
        tn = s.chord_tones(sym, 'D4', 4)
        for k in range(4):
            s.note('piano', bar * 4 + k, 1.4, tn[(0, 2, 1, 3)[k]], 44)
    s.mel('vln', 16, BUFFET_THEME[21:] + [('r', 0)], 86, tr=SEMIS - 12)
    s.line('vc', 16, [(p(s.V[BUFFET_PROG[(i + 4) % 16]][0]) + 12, 4) for i in range(12)], 56)
    s.motif('cl', 19, motif_head('Bb4', 'major', rhythm=(1, .5, 2.5)), 72, form='head (clarinet, a taste)', lead=False)
    s.motif('cl', 25, motif_head('F4', 'major', rhythm=(1, .5, 2.5)), 68, form='head, lower (clarinet)', lead=False)
    s.swell('pad', 16, 12, 70, 100, 'arch')

    # 28-35: formal again, leading back to bar 0
    for i in range(8):
        formal(28 + i, BUFFET_PROG[8 + i], 64)
    s.mel('piano', 28, BUFFET_THEME[40:], 82, tr=SEMIS - 12, legato=.7)
    # the theme's closing rest bar: the piano turns back toward bar 0 (seam)
    s.mel('piano', 35, [(n, .5) for n in ('F3', 'Bb3', 'D4', 'F4', 'A4', 'C5', 'Eb5', 'E5')], 72, arc=False)
    s.fade_vel(34, 36, 1.25, ['cb', 'pizz', 'cl'])
    return s
