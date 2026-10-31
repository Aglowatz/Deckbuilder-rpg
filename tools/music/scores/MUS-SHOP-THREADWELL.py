"""MUS-SHOP-THREADWELL - Pip's tiny runway (Crosspath, VS-THREADWELL). Loop, 36 bars 4/4, 112 BPM, A minor (77.1 s).
A tiny runway strut: a warm plucked bass walking with attitude, brushes and castanet flicks, a strutting oboe tune with sweeping flute
ornaments and harp glissandi for each theatrical entrance - then a calm browsing section (clarinet and harp only, the bass in halves) before
the next walk. The Crossroads motif struts by on the oboe. Flamboyant, still easy to browse under.
"""
from lib import Score, m, motif, motif_head, p, Scale
from scores._fork_a import bed, each, shop_bass, brushes, gliss

STRUT = m('A4:.75 C5:.25 E5:1 D5:.5 C5:.5 B4:1 | A4:.5 B4:.5 C5:.5 E5:.5 A5:2 | G5:.75 F5:.25 E5:1 D5:.5 C5:.5 B4:1 '
          '| E5:4 | A4:.75 C5:.25 E5:1 D5:.5 C5:.5 B4:1 | F5:.5 E5:.5 D5:.5 C5:.5 D5:2 | C5:.5 B4:.5 A4:.5 G#4:.5 B4:1 E4:1 | A4:4')
H = ['Am', 'Am7', 'Dm7', 'E7', 'Am', 'Dm7', 'Bm7b5 E7', 'Am']
CALM = ['Fmaj7', 'Em7', 'Dm7', 'E7sus4 E7', 'Fmaj7', 'Em7', 'Dm7', 'E7']


def build():
    s = Score('MUS-SHOP-THREADWELL', bpm=112, bars=36, key='A minor', seed=714)
    s.swing = 0.08
    s.seat('ob', 'fl', 'cl', 'harp', 'pad', 'pizz')
    s.channel('pbass', 'ac_bass', pan=70, reverb=60, vol=96)
    s.channel('perc', 'brush_kit', pan=64, reverb=70, vol=76)
    s.channel('cast', 'castanets', pan=40, reverb=70, vol=60)
    for bar, nm in ((0, 'intro walk'), (4, 'A the strut'), (12, 'B browsing'), (20, "A' the strut, flute ornaments"),
                    (28, 'C the motif walks'), (32, 'intro walk')):
        s.section(bar, nm)
    s.notes.append('Runway strut: walking acoustic bass, brushes, castanet flicks, harp glissandi on entrances; calm B section.')

    def walk(bar, spec, vel, style='walk'):
        shop_bass(s, bar, spec, vel, style=style)
        brushes(s, bar, vel - 10)
        s.note('cast', bar * 4 + 1.5, .1, p('C5'), vel - 10)
        s.note('cast', bar * 4 + 3.5, .1, p('C5'), vel - 16)
        for t, d, sym in each(s, bar, spec):
            for n in s.chord_tones(sym, p('E3'), 3):
                s.note('pizz', t + 1, .3, n, vel - 24)

    def run_up(bar, beat, top, vel):
        sc = Scale('A4', 'harmonic')
        s.run('fl', bar, sc.deg(sc.degree_of(top) - 7), top, sc, vel, step=.125, beat=beat, crescendo=14)

    def intro(bar):
        for i, spec in enumerate(['Am', 'Dm7', 'Am', 'E7']):
            walk(bar + i, spec, 70)
            bed(s, bar + i, spec, 32, ch='pad', low='A3', n=3)
        s.mel('ob', bar, m('E5:1 r:.5 A4:.5 C5:1 E5:1 | D5:1 r:.5 F5:.5 A5:2 | E5:1 r:.5 C5:.5 A4:1 C5:1 | B4:2 G#4:1 B4:1'), 78)
        gliss(s, 'harp', bar + 3, 'E7', 46, low='E4', beats=1, beat=3)

    intro(0)
    for i, spec in enumerate(H):
        walk(4 + i, spec, 72)
        bed(s, 4 + i, spec, 34, ch='pad', low='A3', n=3)
    gliss(s, 'harp', 4, 'Am', 56, low='A3', beats=1)
    s.mel('ob', 4, STRUT, 86)
    run_up(5, 3, 'A6', 56)
    for i, spec in enumerate(CALM):
        shop_bass(s, 12 + i, spec, 62, style='two')
        s.harp(12 + i, spec.split()[0], 44, density=8)
        bed(s, 12 + i, spec, 38, ch='pad', low='A3', n=3)
        s.drum(12 + i, [(0, 'bd', -8), (2, 'snare', -18)], 60)
    s.mel('cl', 12, m('A4:2 C5:1 E5:1 | G5:2 E5:2 | F5:1 E5:1 D5:1 C5:1 | B4:4 | A4:2 C5:1 E5:1 | G5:2 B5:2 | A5:1 G5:1 F5:1 D5:1 | E5:4'), 76)
    for i, spec in enumerate(H):
        walk(20 + i, spec, 74)
        bed(s, 20 + i, spec, 36, ch='pad', low='A3', n=3)
    gliss(s, 'harp', 20, 'Am', 58, low='A3', beats=1)
    s.mel('ob', 20, STRUT, 88)
    run_up(21, 3, 'A6', 60)
    run_up(25, 3, 'F6', 60)
    s.line('fl', 23, m('G#6:.25 A6:.25 G#6:.25 E6:.25 B5:1 r:2'), 58)
    for i, spec in enumerate(['Am', 'F', 'Dm7', 'E7']):
        walk(28 + i, spec, 70)
        bed(s, 28 + i, spec, 36, ch='pad', low='A3', n=3)
    s.motif('ob', 28, motif('A4', 'minor', rhythm=[.75, .25, 1, 1.5, .5, 4]) + m('r:0'), 86, form='stated (oboe, strutting rhythm)')
    s.motif('cl', 30, motif_head('E4', 'minor', rhythm=(1, .5, .5)) + m('G#4:2 | B4:4'), 74, form='head (clarinet answers)')
    intro(32)
    return s
