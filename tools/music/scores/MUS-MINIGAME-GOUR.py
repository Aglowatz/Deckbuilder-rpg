"""MUS-MINIGAME-GOUR - Flambe's cooking show. 44 bars 4/4, 138 BPM, C major (~76 s loop).
A TV cooking show in the Buffet palette: brass "and now!" stabs, the Buffet theme on xylophone and muted trumpet over a bouncing tuba
and piano comp, a kitchen-timer woodblock, a triangle "ding" at each phrase. The B section is a quick exchange - clarinet and piano trade
two-bar phrases (the clarinet's is the Crossroads motif) - before the whole studio band takes the theme. Energetic, theatrical, clear.
"""
from lib import Song, motif, motif_head, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_PROG, BUFFET_CHORDS

SEMIS = -5      # F -> C


def cmap(semis):
    out = {}
    for k, (b, v) in BUFFET_CHORDS.items():
        bb = p(b) + semis
        while bb > 42:
            bb -= 12
        while bb < 30:
            bb += 12
        vv = [p(n) + semis for n in v]
        while min(vv) < 55:
            vv = [x + 12 for x in vv]
        out[k] = (bb, vv)
    return out


def build():
    s = Song('MUS-MINIGAME-GOUR', bpm=138, bars=44, key='C major', seed=411, jitter=0.01)
    s.V = cmap(SEMIS)
    s.channel('xylo', 'xylophone', 52, 80, 96)
    s.channel('mtpt', 'muted_tpt', 56, 85, 88)
    s.channel('brass', 'brass', 70, 90, 92)
    s.channel('tuba', 'tuba', 88, 85, 84)
    s.channel('piano', 'piano', 58, 80, 80)
    s.channel('cl', 'clarinet', 60, 80, 94)
    s.channel('vln', 'strings', 36, 95, 94)
    s.channel('pizz', 'pizz', 74, 75, 72)
    s.channel('glock', 'glock', 44, 95, 60)
    s.channel('kit', 'standard_kit', 64, 60, 86)
    for bar, nm in ((0, 'studio intro'), (4, 'A theme'), (20, 'B exchange'), (28, "A' studio band"), (40, 'studio intro again')):
        s.section(bar, nm)

    def bounce(bar, sym, vel):
        b, v = s.V[sym]
        s.note('tuba', bar * 4, .7, p(b), vel)
        s.note('tuba', bar * 4 + 2, .7, p(b) + 7 if sym not in ('C7', 'D7') else p(b), vel - 8)
        for beat in (1, 3):
            s.chord('piano', bar * 4 + beat, .3, v, vel - 18)
            s.chord('piano', bar * 4 + beat + .5, .2, v, vel - 26)

    def timer(bar, vel):
        for k in range(4):
            s.note('kit', bar * 4 + k, .1, 76 if k % 2 == 0 else 77, vel, human=False)
        s.note('kit', bar * 4, .25, 36, vel + 10, human=False)
        s.note('kit', bar * 4 + 2, .25, 38, vel, human=False)

    def studio(bar):
        for i, sym in enumerate(['F', 'Dm', 'Gm7', 'C7']):
            bounce(bar + i, sym, 76)
            timer(bar + i, 62)
            s.chord('brass', (bar + i) * 4, .4, s.V[sym][1], 88)
            s.chord('brass', (bar + i) * 4 + 2.5, .4, s.V[sym][1], 80)
        s.motif('mtpt', bar, motif_head('C5', 'major', rhythm=(.5, .5, 1)) + [('r', 2)], 84, form='head (muted trumpet, "and now!")')
        s.mel('xylo', bar + 2, [(n, .5) for n in ('C5', 'E5', 'G5', 'C6', 'G5', 'E5', 'G5', 'Bb5')] + [('A5', 2), ('B5', 1), ('C6', 1)], 82, arc=False)
        s.note('kit', (bar + 3) * 4 + 3, 1, 81, 76)

    studio(0)

    # A 4-19: the theme on xylophone, muted trumpet doubling the second half
    for i in range(16):
        sym = BUFFET_PROG[i]
        bounce(4 + i, sym, 80)
        timer(4 + i, 58)
        if i % 4 == 3:
            s.note('kit', (4 + i) * 4 + 3, 1, 81, 70)
        s.chord('brass', (4 + i) * 4 + 1.5, .3, s.V[sym][1], 62)
        s.chord('brass', (4 + i) * 4 + 3.5, .3, s.V[sym][1], 58)
    s.mel('xylo', 4, BUFFET_THEME, 96, tr=SEMIS)
    s.line('mtpt', 12, BUFFET_THEME[40:], 76, tr=SEMIS)
    s.chord('brass', 19 * 4 + 2, .8, ['G3', 'B3', 'D4', 'F4'], 90)

    # B 20-27: the exchange - clarinet (the motif) and piano trade two-bar phrases
    ex = ['Am', 'D7', 'G', 'C', 'F', 'D7', 'G', 'G7']
    for i, sym in enumerate(ex):
        bar = 20 + i
        b = p(s.voicing(sym)[0])
        s.note('tuba', bar * 4, .7, b, 72)
        s.note('tuba', bar * 4 + 2, .7, b + 7, 64)
        s.chord('pizz', bar * 4 + 1, .3, s.chord_tones(sym, 'G3', 3), 58)
        s.chord('pizz', bar * 4 + 3, .3, s.chord_tones(sym, 'G3', 3), 58)
        timer(bar, 54)
    s.motif('cl', 20, motif('A4', 'minor'), 84, form='stated (clarinet, the exchange)')
    s.mel('piano', 22, [('G5', .5), ('F#5', .5), ('G5', .5), ('B5', 1), ('A5', .5), ('G5', 1), ('C6', 2), ('r', 2)], 80)
    s.motif('cl', 24, motif('C5', 'major'), 84, form='stated (clarinet, in C)')
    s.mel('piano', 26, [('A5', .5), ('G5', .5), ('F5', .5), ('E5', 1), ('D5', .5), ('C5', 1), ('D5', 2), ('G4', 2)], 80)

    # A' 28-39: the studio band takes the theme - strings, brass punches
    for i in range(12):
        bar = 28 + i
        sym = BUFFET_PROG[i]
        bounce(bar, sym, 86)
        timer(bar, 66)
        s.chord('brass', bar * 4 + 1.5, .3, s.V[sym][1], 74)
        s.chord('brass', bar * 4 + 3.5, .3, s.V[sym][1], 70)
    s.mel('vln', 28, BUFFET_THEME[:59], 100, tr=SEMIS + 12)
    s.line('xylo', 28, BUFFET_THEME[:40], 76, tr=SEMIS)
    s.line('glock', 28, BUFFET_THEME[:21], 54, tr=SEMIS + 12)

    studio(40)
    # seam: the last bar drives into the loop point (a held brass chord and a snare fill) so it meets bar 0's level
    s.chord('brass', 43 * 4 + 2.5, 1.5, s.V['C7'][1], 86)
    s.chord('vln', 43 * 4, 4, [x + 12 for x in s.V['C7'][1]], 70)
    for k in range(8):
        s.note('kit', 43 * 4 + 2 + k * .25, .2, 38, 50 + k * 6, human=False)
    return s
