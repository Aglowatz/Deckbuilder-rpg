"""MUS-CAP-FACADE-BATTLE - Approved disagreement (Showcase Quarter). Loop, 72 bars 4/4, 144 BPM, C major, quantised.
The facade's muzak under strain: insistently measured repeated-note strings, clipped snare rudiments and rim clicks, the Capital theme on
harpsichord + music box + glock, polished on top while the dread pedal and a flat glass pad gather underneath. Minor slips come faster;
the horns break through with the Crossroads motif and are pushed back by block brass; two frantic bursts snap straight back to the grid.
"""
from lib import Score, m, motif, motif_head, p
from lib.capital import QUANTISED, rudiment, stumble
from scores._fork_a import cap, prog, bed, arp, each, block, root

PROG = prog()


def build():
    s = Score('MUS-CAP-FACADE-BATTLE', bpm=144, bars=72, key='C major', seed=604, human=QUANTISED)
    s.seat('spic', 'pad', 'cb', 'vc', 'hn', 'brass', 'tpt', 'glock', 'vln', 'timp', 'perc')
    s.channel('mbox', 'music_box', pan=40, reverb=90, vol=100)
    s.channel('hpsd', 'harpsichord', pan=84, reverb=80, vol=86)
    s.channel('glass', 'bowed_glass', pan=64, reverb=110, vol=50)
    s.detune('glass', -15)
    for bar, nm in ((0, 'intro strain'), (4, 'A measured theme'), (20, 'B slips'), (36, 'C the motif breaks through'),
                    (52, 'D full strain'), (68, 'outro strain')):
        s.section(bar, nm)
    s.notes.append('Facade theme under strain: Capital theme on harpsichord/music box, repeated-note strings, rudiments, flat glass pad.')

    def strain(bar, spec, vel, rud='flam'):
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'G3')
            for k in range(int(d * 2)):
                s.note('spic', t + k * .5, .3, r + (12 if k % 4 == 3 else 0), vel + (10 if k % 2 == 0 else -4))
            b = root(s, sym, 'E1')
            if b > p('D2'):
                b -= 12
            for k in range(int(d)):
                s.note('cb', t + k, .5, b, vel + (4 if k == 0 else -4))
        s.note('vc', bar * 4, 4.02, p('C3'), vel - 22)               # the dread pedal never leaves C
        rudiment(s, 'perc', bar, rud, vel - 16)
        s.hit('rim', bar * 4 + 1, vel - 10)
        s.hit('rim', bar * 4 + 3, vel - 10)

    def intro(bar):
        for i, spec in enumerate(['C', 'C', 'Ab', 'G7']):
            strain(bar + i, spec, 72)
            bed(s, bar + i, spec, 58, ch='pad', low='E3', n=4)
            s.note('glass', (bar + i) * 4, 4.05, p('C4'), 46)
        s.mel('hpsd', bar, m('C5:.5 C5:.5 E5:.5 E5:.5 G5:.5 G5:.5 C6:1 | B5:2 G5:2 | Ab5:.5 Ab5:.5 G5:.5 G5:.5 Eb5:2 | D5:2 G4:2'), 88)
        s.motif('hn', bar + 2, motif_head('C4', 'minor', rhythm=(1, .5, 2.5)), 64, form='head (horns, under the strain)', lead=False)

    intro(0)

    for i in range(16):
        spec = PROG[i]
        strain(4 + i, spec, 74, rud='flam' if i % 2 else 'march')
        bed(s, 4 + i, spec, 50, ch='pad', low='E3', n=4)
        arp(s, 'hpsd', 4 + i, spec, 50, low='C4', step=.5, pattern=(0, 2, 1, 2))
    s.mel('mbox', 4, cap(0, 16), 92)
    s.line('glock', 4, cap(0, 8), 54, transpose=12)

    slips = ['C', 'Cm', 'F', 'Fm', 'C', 'Ab', 'G7', 'Db', 'C', 'Cm', 'Ab', 'G7', 'F', 'Fm', 'Ab', 'G7']
    for i, spec in enumerate(slips):
        strain(20 + i, spec, 76, rud='paradiddle' if i % 4 == 3 else 'flam')
        bed(s, 20 + i, spec, 54, ch='pad', low='E3', n=4)
        s.note('glass', (20 + i) * 4, 4.05, p('B3') if i % 2 else p('C4'), 44 + i)
        block(s, 'brass', 20 + i, spec, 56, low='E3', rhythm=((0, .3), (1.5, .3)))
    s.mel('hpsd', 20, cap(0, 4) + cap(0, 4, minor=True) + cap(4, 8) + cap(4, 8, minor=True), 92)
    stumble(s, 'vln', 27, m('G5:.25 A5:.25 B5:.25 C6:.25 Db6:.25 Eb6:.25 F6:.25 G6:.5 F6:.25 Eb6:.25 D6:.25'), 80, rush=.8)

    # C 36-51: the horns break through with the motif; block brass slams the anthem back
    for i in range(16):
        spec = PROG[i]
        strain(36 + i, spec, 78)
        bed(s, 36 + i, spec, 58, ch='pad', low='E3', n=4)
        if i % 4 == 0:
            s.timp_hit((36 + i) * 4, 'C2', 86)
    s.motif('hn', 36, motif('D4', 'minor') + m('r:1'), 98, form='stated (horns, in D minor against the C major grid)')
    s.mel('brass', 38, cap(0, 2), 94)
    s.motif('hn', 40, motif('E4', 'minor') + m('r:1'), 100, form='stated higher (horns + violins)')
    s.line('vln', 40, motif('E4', 'minor') + m('r:1'), 84, transpose=12)
    s.mel('brass', 42, cap(4, 6), 96)
    s.mel('mbox', 44, cap(8, 16), 94)
    s.line('tpt', 44, cap(8, 16), 76, transpose=-12)
    stumble(s, 'spic', 50, m('C6:.25 B5:.25 Bb5:.25 A5:.25 Ab5:.25 G5:.25 F#5:.25 F5:.25 E5:.5 Eb5:.5'), 84, rush=.78)

    # D 52-67: full strain - theme in brass and strings 8va, glass louder, motif fragments in the cracks
    for i in range(16):
        spec = PROG[i] if i % 8 != 5 else 'Fm'
        strain(52 + i, spec, 84, rud='paradiddle' if i % 2 else 'flam')
        bed(s, 52 + i, spec, 64, ch='pad', low='E3', n=4)
        s.note('glass', (52 + i) * 4, 4.05, p('Db4'), 50)
        block(s, 'brass', 52 + i, spec, 60, low='E3', rhythm=((0, .3), (2, .3)))
        if i % 4 == 0:
            s.hit('crash', (52 + i) * 4, 84, dur=2)
            s.timp_hit((52 + i) * 4, 'C2', 92)
    s.mel('tpt', 52, cap(0, 16), 100)
    s.line('vln', 52, cap(0, 16), 88, transpose=0)
    s.motif('hn', 58, motif_head('D4', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 92, form='head (horns, in the cracks)', lead=False)
    s.motif('hn', 66, motif_head('D4', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 92, form='head (horns)', lead=False)

    intro(68)
    s.snare_roll(71 * 4 + 2, 2, 40, 84)
    s.timp_roll(71 * 4, 4, 'G2', 40, 80)
    return s
