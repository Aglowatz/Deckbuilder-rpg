"""MUS-CAP-OUT-EXP - Outside the approved walls (Capital outskirts). Loop, 44 bars 4/4, 72 BPM, A minor, quantised.
Depleted outskirts: a wind pad, a low cello, isolated piano notes and sparse, wind-worn strings over a hesitant pulse. From far off, like a
broadcast from the city, a music box plays the Capital theme in bright C major - a few cents flat, drowned in reverb - a cold distant
promise. The Crossroads motif is asked by a lone cello and answered by a distant flute; the strings gather once and thin out again.
"""
from lib import Score, m, motif, motif_head, p
from lib.capital import QUANTISED
from scores._fork_a import cap, bed

H = ['Am', 'Am', 'F', 'E', 'Am', 'Dm', 'F', 'E', 'Am', 'G', 'F', 'E']


def build():
    s = Score('MUS-CAP-OUT-EXP', bpm=72, bars=44, key='A minor', seed=602, human=QUANTISED)
    s.seat('pad', 'vc', 'cb', 'piano', 'fl', 'vln', 'harp')
    s.channel('wind', 'sweep_pad', pan=64, reverb=110, vol=56)
    s.channel('bcast', 'music_box', pan=30, reverb=127, vol=58)
    s.channel('glass', 'bowed_glass', pan=96, reverb=120, vol=40)
    s.detune('bcast', -20)
    s.detune('glass', 18)
    for bar, nm in ((0, 'wind'), (4, 'A cello and piano'), (16, 'B the broadcast'), (28, 'C strings gather'), (40, 'wind')):
        s.section(bar, nm)
    s.notes.append('Capital theme in C on a far-off music box 20 cents flat (the broadcast) over A minor outskirts; quantised.')

    def pulse(bar, sym, vel):
        r = p(s.voicing(sym)[0])
        if r < p('A1'):
            r += 12
        s.note('cb', bar * 4, 1.5, r, vel)
        s.note('cb', bar * 4 + 2.5, 1, r, vel - 12)      # the hesitant pulse: long, late, short

    def wind(bar, bars):
        for k in range(bars):
            s.note('wind', (bar + k) * 4, 4.05, p('A3'), 52)
            s.note('wind', (bar + k) * 4, 4.05, p('E4'), 46)

    def intro(bar):
        wind(bar, 4)
        for i, sym in enumerate(['Am', 'Am', 'F', 'E']):
            pulse(bar + i, sym, 46)
            bed(s, bar + i, sym, 34, ch='pad', low='A3', n=3)
        s.mel('vc', bar, m('A3:4 | C4:2 B3:2 | A3:3 E3:1 | G#3:4'), 54)
        s.note('piano', bar * 4 + 6, 2, p('E5'), 44)

    intro(0)

    # A 4-15: cello melody, piano drops single notes, the motif asked by the cello at 12
    cello = m('E3:1 A3:1 B3:1 C4:3 B3:1 A3:1 | D4:3 C4:1 A3:4 | C4:1 B3:1 A3:1 F3:1 E3:4 | E3:2 G#3:2 B3:4 '
              '| A3:1 C4:1 E4:2 D4:2 C4:2 | F4:2 E4:1 D4:1 A3:4')
    for i in range(12):
        sym = H[i]
        pulse(4 + i, sym, 50)
        bed(s, 4 + i, sym, 38, ch='pad', low='A3', n=3)
        if i % 3 == 1:
            s.note('piano', (4 + i) * 4 + 1, 2.5, p(s.voicing(sym)[1][-1]) + 12, 48)
    wind(4, 2)
    s.mel('vc', 4, cello, 74)
    s.motif('vc', 12, motif('A3', 'minor') + m('r:1'), 76, form='stated (lone cello, the question)')

    # B 16-27: the broadcast - the Capital theme in C major, far off; the flute answers with the motif head
    for i in range(12):
        sym = (['Am', 'F', 'C', 'G'] * 3)[i]
        pulse(16 + i, sym, 48)
        bed(s, 16 + i, sym, 40, ch='pad', low='A3', n=3)
        s.note('glass', (16 + i) * 4, 4.05, p('B4'), 34 + (i % 4) * 3)
    s.mel('bcast', 16, cap(0, 8), 80)
    s.line('harp', 16, [(n, d) for n, d in cap(0, 2)], 34, transpose=-12)
    s.motif('fl', 24, motif_head('A4', 'minor', rhythm=(2, 1, 1)) + m('C5:2 B4:2 | A4:4'), 66, form='head (distant flute, answers)')
    s.tag_melody('fl', 24, 28)

    # C 28-39: wind-worn strings gather - the motif in the violins, the Capital head in minor on the cello, then thinning
    for i in range(12):
        sym = H[i]
        v = 48 + (i if i < 8 else 16 - i) * 4
        pulse(28 + i, sym, v)
        bed(s, 28 + i, sym, v - 4, ch='pad', low='A3', n=4)
        s.harp(28 + i, sym, v - 14, density=8, octave=1)
    s.swell('pad', 28, 8, 70, 112)
    s.swell('pad', 36, 4, 112, 80)
    s.motif('vln', 28, motif('A4', 'minor') + m('r:1') + motif('C5', 'major') + m('r:1'), 84, form='stated twice (violins, A minor then C)')
    s.line('vc', 28, cap(0, 4, semis=-12 - 3, minor=True), 58)
    s.mel('vln', 36, m('E5:2 D5:2 | C5:2 B4:2 | A4:4 | G#4:4'), 74)
    wind(36, 4)

    intro(40)
    return s
