"""MUS-CAP-OUT-BATTLE - The wasteland road (Capital outskirts). Loop, 64 bars 4/4, 132 BPM, E minor, quantised.
The outskirts' hesitant pulse turned into a grounded battle ostinato: dry orchestra-kit drums, low strings driving 8ths, unsettled chord
changes (E minor to a tritone-away Bb, a sliding C to F#dim). Determination under the bleakness: the Crossroads motif in the horns fights
for the tune; the Capital theme comes after it in hard minor trumpets like a patrol; in the breakdown the city's music box broadcast
drifts in over the wind, then the climax sets the hero's motif against the theme.
"""
from lib import Score, m, motif, motif_head, augment, p
from lib.capital import QUANTISED
from scores._fork_a import cap, bed, root

A_H = ['Em', 'Em', 'C', 'B7', 'Em', 'Bb', 'C', 'B7']
B_H = ['Em', 'C', 'Am', 'B7', 'Em', 'C', 'F#dim', 'B7']


def build():
    s = Score('MUS-CAP-OUT-BATTLE', bpm=132, bars=64, key='E minor', seed=603, human=QUANTISED)
    s.seat('spic', 'vc', 'cb', 'pad', 'hn', 'tpt', 'tbn', 'timp', 'perc', 'vln', 'fl')
    s.channel('bcast', 'music_box', pan=30, reverb=127, vol=96)
    s.channel('wind', 'sweep_pad', pan=64, reverb=110, vol=54)
    s.detune('bcast', -20)
    for bar, nm in ((0, 'intro drive'), (4, 'A the motif fights'), (20, 'B the patrol (Capital theme)'), (36, 'C broadcast breakdown'),
                    (48, 'D climax'), (60, 'outro drive')):
        s.section(bar, nm)
    s.notes.append('Capital theme in E harmonic minor (trumpets) as the pursuing patrol; outskirts pulse as ostinato; quantised.')

    def drive(bar, sym, vel, full=True):
        r = root(s, sym, 'E3')
        cell = [0, 0, 7, 0, 12, 0, 7, 3 if 'm' in sym else 4]
        for k in range(8):
            s.note('spic', bar * 4 + k * .5, .4, r + cell[k], vel + (10 if k % 4 == 0 else -2))
        b = root(s, sym, 'E1')
        if b > p('D2'):
            b -= 12
        for k in (0, 1.5, 2, 3.5):
            s.note('cb', bar * 4 + k, .45, b, vel + (6 if k == 0 else -4))
        if full:
            s.drum(bar, [(0, 'bd', 6), (1, 'snare', -2), (1.5, 'bd', -10), (2, 'bd', 0), (3, 'snare', 2), (3.75, 'snare2', -16)], vel - 6)

    def intro(bar):
        for i, sym in enumerate(['Em', 'Em', 'C', 'B7']):
            drive(bar + i, sym, 74)
            bed(s, bar + i, sym, 62, ch='pad', low='E3', n=4)
            s.timp_hit((bar + i) * 4, 'E2' if i < 3 else 'B1', 80)
        s.motif('tbn', bar + 1, motif_head('E3', 'minor', rhythm=(1, .5, 2.5)), 74, form='head (trombones, low)')
        s.mel('hn', bar, m('E4:4 | G4:3 A4:1 | G4:2 E4:2 | F#4:4'), 84)

    intro(0)

    for i in range(16):
        sym = A_H[i % 8]
        drive(4 + i, sym, 76)
        bed(s, 4 + i, sym, 54, ch='pad', low='E3', n=4)
        if i % 2 == 0:
            s.timp_hit((4 + i) * 4, 'E2' if sym.startswith('E') else 'B1', 78)
    s.motif('hn', 4, motif('E4', 'minor') + m('r:1') + motif('E4', 'minor', degrees=[0, 4, 3, 2, 1, 6]) + m('r:1'), 94,
            form='stated, then turned up (horns)')
    s.motif('hn', 12, motif('G4', 'major') + m('r:1') + motif('E4', 'minor') + m('r:1'), 96, form='stated in G then E (horns + violins)')
    s.line('vln', 12, motif('G4', 'major') + m('r:1') + motif('E4', 'minor') + m('r:1'), 80, transpose=12)
    s.hit('crash', 12 * 4, 80, dur=2)
    s.mel('hn', 8, m('B4:2 A4:1 G4:1 | F#4:2 E4:2 | G4:1 A4:1 B4:1 C5:1 | B4:4'), 90)
    s.mel('tpt', 16, m('E5:2 D5:1 B4:1 | D5:2 Bb4:2 | C5:1 D5:1 E5:1 D5:1 | D#5:4'), 92)

    for i in range(16):
        sym = B_H[i % 8]
        drive(20 + i, sym, 78)
        bed(s, 20 + i, sym, 58, ch='pad', low='E3', n=4)
        s.brass('tbn', 20 + i, sym, 52, low='E3', n=2, beats=1)
        s.timp_hit((20 + i) * 4, 'E2' if i % 2 == 0 else 'B1', 74)
    s.mel('tpt', 20, cap(0, 8, semis=-8, minor=True), 96)
    s.mel('tpt', 28, cap(8, 16, semis=-8, minor=True), 98)
    s.line('hn', 28, cap(8, 16, semis=-20, minor=True), 78)
    s.motif('fl', 26, motif_head('B5', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 70, form='head (flute, cuts through the patrol)', lead=False)

    # C 36-47: breakdown - wind, a low pulse, the far-off music box broadcast; snare and timpani build back
    for i in range(12):
        sym = ['Em', 'C', 'Em', 'B7'][i % 4]
        drive(36 + i, sym, 54 + i * 2, full=i >= 8)
        s.note('wind', (36 + i) * 4, 4.05, p('E4'), 50)
        bed(s, 36 + i, sym, 44 + i * 2, ch='pad', low='E3', n=4)
    s.mel('bcast', 36, cap(0, 8), 82)
    s.motif('vc', 40, augment(motif('E3', 'minor')[:4], 2) + m('r:1'), 70, form='augmented head (cello)', lead=False)
    s.snare_roll(46 * 4, 8, 30, 100)
    s.timp_roll(47 * 4, 4, 'B1', 50, 104)

    # D 48-59: climax - motif in horns + violins against the minor Capital theme in the trombones
    for i in range(12):
        sym = A_H[i % 8]
        drive(48 + i, sym, 86)
        bed(s, 48 + i, sym, 66, ch='pad', low='E3', n=4)
        s.timp_hit((48 + i) * 4, 'E2' if sym.startswith('E') else 'B1', 90)
        if i % 4 == 0:
            s.hit('crash', (48 + i) * 4, 92, dur=2)
    hero = motif('E4', 'minor') + m('r:1') + motif('B4', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1')
    s.motif('hn', 48, hero, 104, form='stated + sequenced (horns, violins 8va)')
    s.line('vln', 48, hero, 96, transpose=12)
    s.line('tbn', 48, cap(0, 8, semis=-20, minor=True), 84)
    s.mel('hn', 52, m('G4:1 A4:1 B4:2 | C5:2 B4:1 A4:1 | G4:2 F#4:2 | B4:4'), 100)
    s.mel('tpt', 56, m('E5:1 G5:1 B5:1 E6:1 | D#6:2 B5:2 | C6:2 A5:2 | B5:4'), 110)

    intro(60)
    return s
