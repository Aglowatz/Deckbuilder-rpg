"""MUS-SHOP-FIGSLY - Off the books (the Crease, VS-FIGSLY). Loop, 32 bars 4/4 swung, 96 BPM, B minor (80.0 s).
Sly but quietly loyal: a hushed pizzicato bass tiptoeing, soft brushes, a low clarinet tune in the chalumeau that glances over its
shoulder, soft piano chords, a celesta wink when a deal is struck. Underneath the wink, warmth: the B section turns to D major for a phrase
of the Crease's own tune (MUS-CREASE) and the Crossroads motif comes in cautiously - the resistance phrase.
"""
from lib import Score, m, motif, motif_head, transpose, p
from scores._fork_a import bed, each, shop_bass, brushes

TUNE = m('F#3:1 B3:.5 C#4:.5 D4:1 C#4:.5 C4:.5 | B3:2 r:1 F#3:1 | G3:1 B3:.5 D4:.5 F#4:1 F4:.5 E4:.5 | D4:3 r:1 '
         '| E4:1 D4:.5 C#4:.5 D4:1 B3:1 | C#4:1.5 A#3:.5 F#3:2 | B3:.5 C#4:.5 D4:.5 E4:.5 F#4:1 A#3:1 | B3:3 r:1')
CREASE_D = transpose(m('C5:1.5 A4:.5 F4:1 G4:1 | A4:1 Bb4:.5 A4:.5 G4:2 | F4:1 A4:1 D5:1.5 C5:.5 | C5:3 r:1'), -3 - 12)
H = ['Bm', 'Bm', 'Gmaj7', 'Gmaj7', 'Em7', 'F#7', 'Bm G', 'F#7']
B_H = ['D', 'Em7 A7', 'Bm7', 'A7sus4 A7', 'Gmaj7', 'F#7', 'Em7', 'F#7']


def build():
    s = Score('MUS-SHOP-FIGSLY', bpm=96, bars=32, key='B minor', seed=718)
    s.swing = 0.14
    s.seat('cl', 'piano', 'cel', 'pad', 'vc')
    s.channel('pbass', 'pizz', pan=80, reverb=60, vol=92)
    s.channel('perc', 'brush_kit', pan=64, reverb=70, vol=66)
    for bar, nm in ((0, 'A low clarinet'), (8, 'B the Crease tune, warmth'), (16, "A' with piano answers"), (24, 'C the resistance phrase')):
        s.section(bar, nm)
    s.notes.append('Back-alley swing 0.14, hushed pizz bass + brushes; the Crease tune (MUS-CREASE) in D in B; motif cautious.')

    def comp(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            for k in s.chord_tones(sym, p('D3'), 3):
                s.note('piano', t + 1.5, .5, k, vel)

    for k in range(4):
        prog = B_H if k == 1 else H
        for i, spec in enumerate(prog):
            bar = 8 * k + i
            shop_bass(s, bar, spec, 62, style='walk')
            brushes(s, bar, 50, hat=False)
            s.drum(bar, [(1, 'hihat', -16), (3, 'hihat', -16)], 50)
            comp(bar, spec, 42)
            bed(s, bar, spec, 26, ch='pad', low='F#3', n=3)
    s.mel('cl', 0, TUNE, 82)
    s.line('cel', 3, m('r:3 F#6:.25 B6:.75'), 46)
    s.mel('cl', 8, CREASE_D + m('r:0'), 80, transpose=12)
    s.line('vc', 8, m('D3:4 | E3:2 A2:2 | B2:4 | A2:4'), 50)
    s.mel('cl', 12, m('B4:2 A4:1 G4:1 | F#4:2 A#4:2 | G4:1 F#4:1 E4:1 D4:1 | C#4:4'), 78)
    s.mel('cl', 16, TUNE[:12], 80)
    s.mel('piano', 19, m('r:2 A5:.5 B5:.5 D6:1'), 60)
    s.mel('cl', 20, TUNE[12:], 80)
    s.line('piano', 23, m('r:2 C#6:.5 D6:.5 F#6:1'), 56)
    s.motif('cl', 24, motif('B3', 'minor') + m('r:1'), 80, form='stated (low clarinet, cautious - the resistance phrase)')
    s.motif('piano', 26, motif_head('D5', 'major', rhythm=(1, .5, .5)) + m('F#5:2'), 64, form='head (piano, in D, warmer)')
    s.mel('cl', 28, m('E4:1.5 D4:.5 C#4:1 B3:1 | A#3:2 C#4:2 | D4:1 C#4:1 B3:1 A#3:1 | F#3:2 A#3:.5 B3:.5 C#4:.5 A#3:.5'), 80)
    s.line('cel', 30, m('r:2 B5:.25 D6:.25 F#6:.5 r:1'), 44)
    return s
