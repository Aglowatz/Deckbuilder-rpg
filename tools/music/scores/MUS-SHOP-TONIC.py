"""MUS-SHOP-TONIC - Tilly's bubbling apothecary (Crosspath, VS-TONIC). Loop, 40 bars 4/4, 128 BPM, G major (75.0 s).
Bubbly chaos: marimba and xylophone tunes over syncopated pizzicato, flute and clarinet answering each other, celesta bubbles rising out
of nowhere, and the occasional surprising chord (Eb, Bb, E7) as if a potion changed colour. The Crossroads motif bubbles up on the
marimba. Cheerful, not childlike; light enough to browse.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, shop_bass

TUNE = m('D5:.5 G5:.5 B5:.5 G5:.5 A5:1 F#5:.5 D5:.5 | E5:.5 G5:.5 C6:1 B5:1 r:1 | A5:.5 F#5:.5 D5:.5 F#5:.5 G5:1 Eb5:1 '
         '| D5:3 r:1 | B4:.5 D5:.5 G5:.5 D5:.5 E5:1 C5:1 | A4:.5 C5:.5 F#5:1 E5:1 D5:1 | G5:.5 F#5:.5 E5:.5 D5:.5 Bb4:1 C5:1 | D5:3 r:1')
H = ['G', 'C', 'D Eb', 'D', 'G', 'D7', 'C Bb', 'D']
B_H = ['Em', 'C', 'Am', 'E7', 'Am', 'D', 'G', 'D7']


def build():
    s = Score('MUS-SHOP-TONIC', bpm=128, bars=40, key='G major', seed=712)
    s.seat('pizz', 'fl', 'cl', 'cel', 'xylo', 'pad', 'perc', 'harp')
    s.channel('mar', 'marimba', pan=40, reverb=80, vol=92)
    s.channel('pbass', 'pizz', pan=86, reverb=70, vol=90)
    for bar, nm in ((0, 'intro bubbles'), (4, 'A marimba'), (12, 'B flute and clarinet argue'), (20, "A' xylophone"),
                    (28, 'C the motif bubbles up'), (36, 'intro bubbles')):
        s.section(bar, nm)
    s.notes.append('Bubbly chaos: syncopated pizz, marimba/xylophone, celesta bubbles, surprise chords; light kit (tambourine, clicks).')

    def fizz(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            tn = s.chord_tones(sym, p('G3'), 4)
            for b in (0, .75, 1.5, 2.5, 3):
                if b < d - 1e-6:
                    s.note('pizz', t + b, .3, tn[int(b * 4) % 4], vel + (6 if b == 0 else -4))
        s.drum(bar, [(0, 'tamb', -10), (1.5, 'click', -6), (2, 'tamb', -14), (3.5, 'click', -10)], vel)

    def bubbles(bar, vel, beat=2.0):
        base = p('G5') + (bar % 3) * 2
        for k in range(6):
            s.note('cel', bar * 4 + beat + k * .125, .2, base + k * 3, vel - k * 2)

    def intro(bar):
        for i, spec in enumerate(['G', 'C', 'Eb', 'D']):
            fizz(bar + i, spec, 62)
            shop_bass(s, bar + i, spec, 66, style='skip')
            bed(s, bar + i, spec, 32, ch='pad', low='B3', n=3)
            bubbles(bar + i, 56, beat=2.5)
        s.mel('mar', bar, m('G5:.5 D5:.5 G5:.5 B5:.5 A5:.5 G5:.5 D5:1 | C6:.5 G5:.5 E5:.5 C5:.5 D5:.5 E5:.5 G5:1 | Eb5:.5 G5:.5 Bb5:1 G5:.5 Eb5:.5 D5:1 | A5:.5 F#5:.5 D5:.5 E5:.5 F#5:.5 A5:.5 C6:.5 A5:.5'), 76)

    intro(0)
    for k, (bar0, prog) in enumerate(((4, H), (12, B_H), (20, H), (28, B_H))):
        for i, spec in enumerate(prog):
            fizz(bar0 + i, spec, 64)
            shop_bass(s, bar0 + i, spec, 68, style='skip' if k % 2 == 0 else 'two')
            bed(s, bar0 + i, spec, 34, ch='pad', low='B3', n=3)
            if i % 2:
                bubbles(bar0 + i, 54)
    s.mel('mar', 4, TUNE, 86)
    s.mel('fl', 12, m('B5:.5 A5:.5 G5:1 E5:2 | r:4 | C6:.5 B5:.5 A5:1 E5:2 | r:4'), 76)
    s.mel('cl', 13, m('G4:.5 A4:.5 B4:1 G4:2'), 78)
    s.mel('cl', 15, m('G#4:.5 A4:.5 B4:.5 D5:.5 E5:2'), 78)
    s.mel('fl', 16, m('C6:1 B5:.5 A5:.5 F#5:2 | A5:1 G5:.5 F#5:.5 D5:2 | B5:1 A5:1 G5:1 F#5:1 | A5:4'), 78)
    s.line('cl', 16, m('E4:2 F#4:2 | F#4:2 D4:2 | D4:4 | C4:4'), 60)
    s.mel('xylo', 20, TUNE, 82)
    s.line('fl', 20, TUNE, 52, transpose=-12)
    s.motif('mar', 28, motif('E5', 'minor') + m('r:1') + motif('G5', 'major') + m('r:1'), 86, form='stated twice (marimba, E minor then G)')
    s.motif('cl', 32, motif_head('A4', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 74, form='head (clarinet)')
    s.mel('fl', 33, m('B5:.5 C6:.5 D6:1 B5:2 | C6:.5 B5:.5 A5:1 F#5:2 | A5:4'), 76)
    intro(36)
    return s
