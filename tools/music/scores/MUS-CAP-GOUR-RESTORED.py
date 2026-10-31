"""MUS-CAP-GOUR-RESTORED - Hungry Quarter, service returns. 56 bars 4/4, 112 BPM, F major (~120 s loop).
The same district theme as BROKEN, now full and in tune: the Buffet theme in F major on celesta and clarinet together (no detune), then
the strings, over a warm oom-pah and pizzicato - kitchens feeding people. The Capital's tension stays (Primm has not fallen): a stiff
snare on the grid and a B section on D minor where the horns keep a guarded line. The Crossroads motif returns RESOLVED in the horns in
the last A, the question answered for this district.
"""
from lib import Song, motif, motif_head, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_THEME_8, BUFFET_PROG, BUFFET_CHORDS, to_mode

TENSE = ['Dm', 'Bb', 'Gm', 'A7', 'Dm', 'Bb', 'Gm7', 'C7', 'Dm', 'Bb', 'Gm', 'A7sus4']


def build():
    s = Song('MUS-CAP-GOUR-RESTORED', bpm=112, bars=56, key='F major', seed=413, jitter=0.014)
    s.V = dict(BUFFET_CHORDS)
    s.channel('cel', 'celesta', 44, 100, 84)
    s.channel('cl', 'clarinet', 70, 85, 96)
    s.channel('vln', 'strings', 36, 100, 96)
    s.channel('pad', 'slow_strings', 64, 100, 66)
    s.channel('vc', 'cello', 82, 90, 82)
    s.channel('tuba', 'tuba', 88, 85, 80)
    s.channel('pizz', 'pizz', 74, 75, 74)
    s.channel('hn', 'horn', 78, 95, 88)
    s.channel('fl', 'flute', 52, 95, 78)
    s.channel('glass', 'bowed_glass', 64, 110, 50)
    s.channel('kit', 'standard_kit', 64, 70, 70)
    for bar, nm in ((0, 'intro'), (4, 'A theme in tune'), (20, 'B guarded'), (32, "A' full + resolved"), (52, 'intro again')):
        s.section(bar, nm)

    def oompah(bar, sym, vel):
        b = p(s.V[sym][0])
        s.note('tuba', bar * 4, .8, b, vel)
        s.note('tuba', bar * 4 + 2, .8, b + 7 if sym not in ('C7', 'D7') else b, vel - 8)
        for beat in (1, 3):
            s.chord('pizz', bar * 4 + beat, .35, s.V[sym][1], vel - 14)

    def stiff(bar, vel):
        for k in range(4):
            s.note('kit', bar * 4 + k, .15, 38 if k % 2 else 37, vel - (0 if k % 2 else 14), human=False)

    def intro(bar):
        for i, sym in enumerate(['F', 'Dm', 'Gm7', 'C7']):
            oompah(bar + i, sym, 80)
            s.pad('pad', bar + i, sym, 66, low='F3')
            s.pad('glass', bar + i, sym, 42, low='C4', n=3)
            stiff(bar + i, 54)
        s.motif('fl', bar + 1, motif_head('F5', 'major', rhythm=(1, .5, 2.5)) + [('r', 4)], 76, form='head (flute)')
        s.swell('pad', bar + 3, 1, 84, 100)

    intro(0)

    # A 4-19: the theme in tune - celesta and clarinet together
    for i in range(16):
        sym = BUFFET_PROG[i]
        oompah(4 + i, sym, 74)
        s.pad('pad', 4 + i, sym, 44, low='F3')
        stiff(4 + i, 50)
    s.mel('cl', 4, BUFFET_THEME, 92)
    s.line('cel', 4, BUFFET_THEME, 70, tr=12)

    # B 20-31: guarded - D minor, the horns' careful line, the Capital's snare
    for i, sym in enumerate(TENSE):
        bar = 20 + i
        s.pad('pad', bar, sym, 56, low='F3')
        s.note('tuba', bar * 4, 3.8, p(s.voicing(sym)[0]), 66)
        tn = s.chord_tones(sym, 'D4', 3)
        for beat in (0, 1, 2, 3):
            s.note('pizz', bar * 4 + beat, .3, tn[beat % 3], 54)
        stiff(bar, 58)
    s.mel('hn', 20, [('D4', 2), ('F4', 2), ('E4', 4), ('D4', 2), ('Bb3', 2), ('A3', 4), ('D4', 2), ('A4', 2), ('G4', 4), ('F4', 2),
                     ('E4', 2), ('E4', 4)], 86)
    s.mel('vln', 28, to_mode(transpose(BUFFET_THEME[:11], -3), {6: -1, 11: -1, 1: -1}) + [('r', 4)], 82)   # the welcome in D minor
    s.swell('pad', 20, 12, 70, 100, 'arch')

    # A' 32-51: full - strings sing the theme, the celesta glints, the motif RESOLVED in the horns
    for i in range(20):
        bar = 32 + i
        sym = BUFFET_PROG[i % 16]
        oompah(bar, sym, 82)
        s.pad('pad', bar, sym, 52, low='F3')
        stiff(bar, 54)
    s.mel('vln', 32, BUFFET_THEME, 98, tr=12)
    s.line('vln', 32, BUFFET_THEME, 80)
    s.line('cel', 32, BUFFET_THEME_8, 60, tr=12)
    s.motif('hn', 44, motif('F3', 'major', resolved=True) + [('r', 1)], 88, form='RESOLVED (horns, the district restored)', lead=False)
    s.mel('cl', 48, BUFFET_THEME[:21], 86)
    s.motif('vc', 48, motif('F3', 'major', resolved=True) + [('r', 9)], 70, form='RESOLVED (cello, under the clarinet)', lead=False)

    intro(52)
    s.fade_vel(54, 56, 1.2, ['tuba', 'pizz', 'pad', 'kit'])     # seam: lift into the loop point
    return s
