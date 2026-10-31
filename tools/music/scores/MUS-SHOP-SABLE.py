"""MUS-SHOP-SABLE - Sable's velvet salon (Crosspath, VS-SABLE). Loop, 32 bars 4/4 swung, 92 BPM, D minor (83.5 s).
Sly velvet: relaxed piano and a plucked walking bass under soft brushes, a low clarinet tune that slides chromatically like a raised
eyebrow, small questioning flute flourishes, a harp glissando when something glamorous is shown and celesta glints. The Crossroads motif
in its home key (it is a Crosspath shop) on the piano, and a wink of the Crosspath tune. Mystic and fun, calm enough to browse.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, shop_bass, brushes, gliss

TUNE = m('A3:1 D4:.5 E4:.5 F4:1 E4:.5 Eb4:.5 | D4:2 r:1 A3:1 | Bb3:1 D4:.5 F4:.5 A4:1 G#4:.5 G4:.5 | F4:3 r:1 '
         '| G4:1 F4:.5 E4:.5 F4:1 D4:1 | E4:1.5 C#4:.5 A3:2 | D4:.5 E4:.5 F4:.5 G4:.5 A4:1 C#4:1 | D4:3 r:1')
H = ['Dm', 'Dm6', 'Bbmaj7', 'Bbmaj7', 'Gm7', 'A7', 'Dm Bb', 'A7']
B_H = ['Gm7', 'C7', 'Fmaj7', 'Bbmaj7', 'Em7b5', 'A7', 'Dm', 'A7']


def build():
    s = Score('MUS-SHOP-SABLE', bpm=92, bars=32, key='D minor', seed=711)
    s.swing = 0.12
    s.seat('piano', 'cl', 'fl', 'harp', 'cel', 'pad', 'vc')
    s.channel('pbass', 'ac_bass', pan=70, reverb=60, vol=94)
    s.channel('perc', 'brush_kit', pan=64, reverb=70, vol=74)
    for bar, nm in ((0, 'A clarinet'), (8, 'B piano and flute'), (16, "A' clarinet, celesta"), (24, 'C the motif')):
        s.section(bar, nm)
    s.notes.append('Sly velvet: swing 0.12, walking acoustic bass, brushes; mystic colours (harp glissandi, celesta).')

    def comp(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            for k in s.chord_tones(sym, p('F3'), 3):
                s.note('piano', t + .5, .4, k, vel)
                if d >= 3:
                    s.note('piano', t + 2.5, .4, k, vel - 6)

    for k in range(4):
        prog = H if k != 1 else B_H
        for i, spec in enumerate(prog):
            bar = 8 * k + i
            shop_bass(s, bar, spec, 70, style='walk')
            brushes(s, bar, 58)
            comp(bar, spec, 48)
            bed(s, bar, spec, 30, ch='pad', low='A3', n=3)
    s.mel('cl', 0, TUNE, 80)
    gliss(s, 'harp', 3, 'Bbmaj7', 56, low='D4', beats=1, beat=3)
    s.mel('piano', 8, m('D5:1 F5:.5 A5:.5 G5:1 E5:1 | C5:2 r:2 | A4:1 C5:.5 E5:.5 G5:1 F5:1 | D5:3 r:1 '
                        '| Bb4:1 D5:.5 E5:.5 F5:1 G5:1 | E5:1.5 C#5:.5 A4:2 | F5:1 E5:1 D5:1 C#5:1 | E5:3 r:1'), 92)
    s.line('fl', 9, m('r:2 E6:.25 F6:.25 E6:.25 D6:.25 C6:1'), 56)                  # a questioning flourish
    s.line('fl', 13, m('r:2 A5:.25 Bb5:.25 A5:.25 G#5:.25 A5:1'), 56)
    s.mel('cl', 16, TUNE, 80)
    s.line('cel', 16, [(n, d) for n, d in TUNE[:6]], 46, transpose=24)
    gliss(s, 'harp', 19, 'Bbmaj7', 58, low='D4', beats=1, beat=3)
    s.motif('piano', 24, motif('D5', 'minor') + m('r:1'), 78, form='stated (piano, home key)')
    s.mel('cl', 26, m('F4:1 G4:.5 A4:.5 C5:1 Bb4:.5 A4:.5 | G4:2 r:2'), 74)          # the Crosspath tune, a wink
    s.motif('fl', 28, motif_head('A5', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 62, form='head (flute)')
    s.mel('cl', 29, m('E4:2 F4:1 E4:1 | D4:1 E4:1 F4:1 G4:1 | A4:2 C#4:2'), 70)
    gliss(s, 'harp', 31, 'A7', 40, low='C#4', beats=1.5, beat=2.5)
    return s
