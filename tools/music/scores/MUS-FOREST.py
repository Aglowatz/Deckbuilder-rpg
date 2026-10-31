"""MUS-FOREST - A stranger in the trees. 56 bars 6/8 (dotted quarter 52; quarter 78 BPM), A minor (Aeolian).
The opening at night: open fifths, a hesitant harp pulse that sometimes skips a beat, celesta fireflies, a breath of halo pad. Woodwinds
try the Crossroads motif in pieces (lost, curious), find a brief warmth in C/F (the oboe states it whole, softly), then a walking section
that suggests the road beyond the trees with a distant drum, a cello section in the dark, the warmth again in the strings, and the night.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p

R68 = [1, .5, 1, .5, 1.5, 4.5]            # the motif's rhythm in 6/8 (q e q e | dq dq~ | dq.)
NIGHT = ['Am', 'Am', 'Fmaj7/A', 'Am', 'Em/A', 'Am', 'Fmaj7/A', 'Esus4']
WARM = ['F', 'C/E', 'Dm7', 'Am', 'F', 'C/E', 'G', 'Esus4 E']
WALK = ['Am', 'G', 'F', 'E', 'Am', 'G', 'F', 'Esus4 E']
ARP = [(0, 0, .9, 6), (.5, 1, .9, 0), (1, 2, .9, -2), (1.5, 3, .9, 3), (2, 2, .9, -2), (2.5, 1, .9, -4)]


def build():
    s = Score('MUS-FOREST', bpm=78, bars=56, meter=(6, 8), key='A minor', seed=202)
    s.seat('fl', 'cl', 'ob', 'hn', 'harp', 'pizz', 'pad', 'vln', 'vc', 'cb', 'cel', 'trem', 'timp')
    s.channel('halo', 'halo_pad', pan=64, reverb=110, vol=46)
    for bar, nm in ((0, 'night'), (8, 'fragments'), (16, 'warmth'), (24, 'the road'), (32, 'dark cello'), (40, "warmth'"), (48, 'night again')):
        s.section(bar, nm)
    q = s.bar_q

    def fifths(bar, root, vel, bars=1):
        r = p(root)
        for t in (r, r + 7):
            s.note('pad', bar * q, bars * q + 0.05, t, vel)

    def hesitant(bar, sym, vel, skip=False):
        b = p(s.voicing(sym)[0]) + 24
        s.note('harp', bar * q, 1.4, b, vel + 4)
        if not skip:
            s.note('harp', bar * q + 1.5, 1.4, b + 7, vel - 6)

    def fireflies(bar, bars, vel, density=2):
        pent = [p(n) for n in ('A5', 'C6', 'D6', 'E6', 'G6', 'A6')]
        for k in range(bars):
            for _ in range(density):
                if s.rng.random() < 0.7:
                    s.note('cel', (bar + k) * q + s.rng.randrange(6) * 0.5, 0.4, s.rng.choice(pent), vel + s.rng.randint(-6, 6))

    def night(bar, n=8, high=False):
        for i in range(n):
            spec = NIGHT[i % 8]
            fifths(bar + i, ('A3' if i % 4 != 3 else 'E3') if high else ('A2' if i % 4 != 3 else 'E3'), 50)
            s.note('cb', (bar + i) * q, q + 0.05, p('A1') if i % 4 != 3 else p('E2'), 44)
            hesitant(bar + i, spec, 48, skip=(i % 4 == 2))
        s.note('halo', bar * q, n * q, p('E4'), 40)
        s.note('halo', bar * q, n * q, p('A4'), 36)
        s.note('trem', bar * q, n * q, p('E5'), 30)
        s.note('trem', bar * q, n * q, p('B5'), 26)
        s.swell('trem', bar, n, 50, 82, 'arch')
        fireflies(bar, n, 38)

    # NIGHT 0-7: open fifths, hesitant harp, fireflies; the flute tries the first notes and stops
    night(0)
    s.motif('fl', 2, motif_head('A4', rhythm=(1, .5, 4.5)), 64, form='head, alone (flute)')
    s.line('fl', 5, m('E5:1 D5:.5 C5:1.5 r:3'), 56)
    s.line('cl', 6, m('r:1.5 C4:1.5 | B3:3'), 52)

    # FRAGMENTS 8-15: clarinet answers with the tail, pizzicato firms the pulse
    for i in range(8):
        bar = 8 + i
        spec = NIGHT[i]
        fifths(bar, 'A2' if i % 4 != 3 else 'E3', 54)
        s.note('cb', bar * q, q + 0.05, p('A1') if i % 4 != 3 else p('E2'), 48)
        hesitant(bar, spec, 46, skip=(i % 4 == 2))
        s.figure('pizz', bar, spec, [(0, 'b', .4, 4), (1.5, 1, .4, -4), (2.5, 2, .4, -8)], 54, low='A3')
    fireflies(8, 8, 34, density=1)
    s.motif('cl', 8, motif_tail('A4', rhythm=(1.5, 1.5, 3)), 72, form='tail (clarinet)')
    s.motif('fl', 10, motif_head('A4', rhythm=(1, .5, 1.5)), 62, form='head (flute) answered')
    s.line('cl', 11, m('C5:1 B4:.5 A4:1.5 | E4:3'), 66)
    s.mel('ob', 13, m('A4:1 B4:.5 C5:1 D5:.5 | E5:3 | D5:1.5 B4:1.5'), 66)
    s.swell('pad', 8, 8, 70, 90)

    # WARMTH 16-23: brief warmth - the oboe states the motif whole, horn underneath, harp arpeggios
    for i, spec in enumerate(WARM):
        bar = 16 + i
        for off, beats, sym in s.parts(spec):
            s.pad('pad', bar, sym, 52, beats=beats, beat=off)
            s.bass_at(bar * q + off, beats, sym, 54)
        s.figure('harp', bar, spec.split()[0], ARP, 50, low='C4')
    s.motif('ob', 16, motif('A4', 'minor', R68), 82, form='stated whole, softly (oboe)')
    s.mel('ob', 19, m('C5:1 D5:.5 E5:1.5 | F5:1.5 E5:1 D5:.5 | C5:1.5 B4:1.5 | G#4:3'), 78)
    s.line('hn', 16, m('C4:3 | C4:3 | D4:3 | C4:3 | A3:3 | G3:3 | B3:3 | B3:1.5 G#3:1.5'), 60, legato=1.0, shape=False)
    s.line('fl', 21, m('r:1.5 G5:1.5 | D6:3 | r:3'), 42)
    s.swell('pad', 16, 8, 74, 100, 'arch')
    s.swell('hn', 16, 8, 70, 100, 'arch')

    # THE ROAD 24-31: a walking 6/8 - harp ostinato, cello line, flute and clarinet in thirds, a distant drum
    for i, spec in enumerate(WALK):
        bar = 24 + i
        for off, beats, sym in s.parts(spec):
            s.bass_at(bar * q + off, beats, sym, 60, chs=('cb', None))
        s.figure('harp', bar, spec.split()[0], ARP, 56, low='A3')
        s.figure('pizz', bar, spec.split()[0], [(0, 'b', .4, 6), (1.5, 'b', .4, -2)], 58, low='A3')
        s.timp_hit(bar * q, p('A2') if spec.startswith('A') else (p('E2') if spec.startswith('E') else p('G2') if spec[0] == 'G' else p('F2')), 52 if i % 2 == 0 else 40)
    s.line('vc', 24, m('A3:1.5 C4:1.5 | B3:1.5 D4:1.5 | C4:1.5 A3:1.5 | G#3:3 | A3:1.5 E4:1.5 | D4:1.5 B3:1.5 | C4:1.5 A3:1.5 | B3:1.5 G#3:1.5'), 66)
    road = m('E5:1 A5:.5 G5:1 F5:.5 | E5:1.5 D5:1.5 | C5:1 D5:.5 E5:1 F5:.5 | E5:3 | E5:1 A5:.5 G5:1 F5:.5 | G5:1.5 B5:1.5 | A5:1 G5:.5 F5:1 E5:.5 | E5:3')
    s.motif('fl', 24, road[:4] + [('E5', 1.5)], 76, form='head on the 5th, walking (flute + clarinet in thirds)')
    s.mel('fl', 25, road[5:], 76, beat=1.5)
    s.line('cl', 24, road, 62, transpose=-3)
    s.swell('pad', 24, 8, 60, 90)
    for i in range(8):
        s.pad('pad', 24 + i, WALK[i].split()[0], 40)

    # DARK CELLO 32-39: back under the trees - the cello sings the motif low, tremolo rustle, a lullaby glimmer in the celesta
    night(32, high=True)
    s.motif('vc', 32, motif('A2', 'minor', R68), 80, form='stated low (solo cello)')
    s.mel('vc', 35, m('C3:1.5 D3:1.5 | E3:3 | F3:1.5 E3:1 D3:.5 | E3:3 | r:3'), 74)
    s.line('cel', 37, m('A5:1 E6:1 C6:1'), 36)
    s.motifs.append((37, 'lullaby glimmer (A E C, three notes, far away) - story theme', 'cel'))

    # WARMTH' 40-47: the strings take the warmth, horn counter, harp
    for i, spec in enumerate(WARM):
        bar = 40 + i
        for off, beats, sym in s.parts(spec):
            s.pad('pad', bar, sym, 58, beats=beats, beat=off)
            s.bass_at(bar * q + off, beats, sym, 62)
        s.figure('harp', bar, spec.split()[0], ARP, 54, low='C4')
    s.motif('vln', 40, motif('A4', 'minor', R68), 84, form='stated (strings)')
    s.mel('vln', 43, m('C5:1 D5:.5 E5:1.5 | F5:1.5 E5:1 D5:.5 | C5:1.5 B4:1.5 | G#4:3'), 80)
    s.line('vln', 40, motif('A4', 'minor', R68) + m('C5:1 D5:.5 E5:1.5 | F5:1.5 E5:1 D5:.5 | C5:1.5 B4:1.5 | G#4:3'), 64, transpose=-12)
    s.line('hn', 40, m('F3:3 | E3:3 | F3:3 | E3:3 | A3:3 | G3:3 | B3:3 | B3:1.5 G#3:1.5'), 64, legato=1.0, shape=False)
    s.swell('vln', 40, 8, 80, 110, 'arch')
    s.timp_roll(47 * q, 3, 'E2', 30, 50)

    # NIGHT AGAIN 48-55: the same night as bar 0 so the loop lands; the flute's question hangs
    night(48)
    s.mel('fl', 50, m('A4:1 E5:.5 D5:4.5'), 60)
    s.line('cl', 53, m('C4:3 | B3:3 | r:3'), 52)
    s.line('fl', 55, m('r:1.5 E5:1.5'), 46)
    s.swell('pad', 55, 1, 84, 98)
    return s
