"""MUS-CAP-FACADE-EXP - Everything is perfectly fine (Showcase Quarter). Loop, 64 bars 4/4, 120 BPM, C major, quantised.
Music-box muzak for the Perfect Plaza: the Capital theme on a music box over an even harpsichord and pizzicato, every phrase identical and
on the grid. Underneath, a low dread pedal (contrabass C + a glass pad a few cents flat) never moves. Minor slips: a C major chord turns
C minor for one bar and nobody mentions it. The B section's cadence goes missing; a clarinet tries the Crossroads head and the music box
talks over it. One frantic burst (rushed strings, a wrong note) snaps straight back to perfect. Human feel OFF.
"""
from lib import Score, m, motif_head, p
from lib.capital import QUANTISED, rudiment, stumble
from scores._fork_a import cap, prog, bed, arp, each, block, root

PROG = prog()


def build():
    s = Score('MUS-CAP-FACADE-EXP', bpm=120, bars=64, key='C major', seed=601, human=QUANTISED)
    s.seat('pad', 'cb', 'vc', 'pizz', 'glock', 'fl', 'cl', 'vln', 'brass', 'perc')
    s.channel('mbox', 'music_box', pan=40, reverb=95, vol=96)
    s.channel('hpsd', 'harpsichord', pan=84, reverb=80, vol=74)
    s.channel('glass', 'bowed_glass', pan=64, reverb=110, vol=44)
    s.detune('glass', -12)
    for bar, nm in ((0, 'intro muzak'), (4, 'A music box theme'), (20, 'B harpsichord + glock, missing cadence'),
                    (36, 'C minor slips, the burst'), (48, "A' the smile widens"), (60, 'outro muzak')):
        s.section(bar, nm)
    s.notes.append('Capital theme (lib/capital.py) on music box; quantised; dread pedal C2 + glass pad 12 cents flat; minor slips; '
                   'one stumble burst at bar 44.')

    def dread(bar, bars=1, vel=46):
        s.note('cb', bar * 4, bars * 4 + .02, p('C2'), vel)

    def muzak(bar, spec, vel=52, hp=True):
        if hp:
            arp(s, 'hpsd', bar, spec, vel, low='C4', step=.5, pattern=(0, 2, 1, 2))
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'C3')
            s.note('pizz', t, .4, r, vel + 4)
            if d >= 2:
                s.note('pizz', t + 2, .4, r + 7, vel - 4)

    def intro(bar):
        for i, sym in enumerate(['C', 'Am', 'F', 'G7']):
            muzak(bar + i, sym, 54)
            dread(bar + i, vel=48)
            bed(s, bar + i, sym, 40, ch='pad', low='E3', n=3)
            s.note('glass', (bar + i) * 4, 4.05, p('C4'), 42)
        s.line('mbox', bar, m('G5:1 E5:1 C5:2 | A5:1 E5:1 C5:2 | A5:1 F5:1 C5:2 | B5:1 G5:1 D5:2'), 66)
        s.tag_melody('mbox', bar, bar + 4)

    intro(0)

    # A 4-19: the theme on the music box, glock doubling the cadences; everything identical
    for i in range(16):
        spec = PROG[i]
        muzak(4 + i, spec, 54)
        dread(4 + i)
        bed(s, 4 + i, spec, 38, ch='pad', low='E3', n=3)
        if i in (3, 7, 11, 15):
            s.note('glock', (4 + i) * 4, 1.5, p('C6'), 58)
    s.mel('mbox', 4, cap(0, 16, 0), 84)
    s.motif('fl', 12, motif_head('C5', 'major', rhythm=(1, .5, .5)) + m('r:2'), 46, form='head (flute, far back, swallowed)', lead=False)

    # B 20-35: harpsichord takes the tune, glock 8va; the cadence at bar 27 goes missing; a minor slip at 25
    for i in range(16):
        spec = PROG[i % 8] if i < 8 else PROG[8 + (i - 8)]
        if i == 5:
            spec = 'Cm'          # minor slip - one bar only
        muzak(20 + i, spec, 50, hp=False)
        arp(s, 'pizz', 20 + i, spec, 40, low='G3', step=1, pattern=(0, 1, 2, 1))
        dread(20 + i, vel=50)
        bed(s, 20 + i, spec, 40, ch='pad', low='E3', n=3)
    a = cap(0, 7)
    s.mel('hpsd', 20, a + m('r:4'), 82)              # the 8th bar never comes: no cadence
    s.line('glock', 20, a, 56, transpose=12)
    s.motif('cl', 27, motif_head('C4', 'major', rhythm=(1, .5, .5)) + m('A4:1 r:1'), 64, form='head (clarinet, breaks through the gap)')
    s.mel('mbox', 28, cap(8, 16), 82)
    s.line('fl', 28, cap(8, 16), 50)

    # C 36-47: slips multiply, the pedal swells, the burst at 44 and the snap back at 46
    cspec = ['C', 'Cm', 'F', 'Fm', 'C', 'Ab', 'G7', 'G7', 'C', 'Cm', 'G7', 'G7']
    for i, spec in enumerate(cspec):
        muzak(36 + i, spec, 50)
        dread(36 + i, vel=52 + i)
        bed(s, 36 + i, spec, 42 + i, ch='pad', low='E3', n=3)
        s.note('glass', (36 + i) * 4, 4.05, p('C4'), 40 + i * 2)
    s.mel('mbox', 36, cap(0, 4) + cap(0, 4, minor=True), 82)
    burst = m('G5:.25 A5:.25 B5:.25 C6:.25 D6:.25 Eb6:.25 F6:.25 G6:.25 Ab6:.5 G6:.25 F6:.25 Eb6:.25 D6:.25 C6:.5')
    stumble(s, 'vln', 44, burst, 84, rush=.8, wrong=1)
    s.events['vln'] = [(t, d, n, v, 'mel' if 44 * 4 <= t < 46 * 4 else r) for t, d, n, v, r in s.events['vln']]
    s.note('brass', 45 * 4 + 2, .5, p('Db4'), 70)          # a wrong chord (a cluster)
    s.note('brass', 45 * 4 + 2, .5, p('D4'), 70)
    s.note('brass', 45 * 4 + 2, .5, p('Ab4'), 70)
    s.mel('mbox', 46, m('E5:1 D5:1 C5:2 | G4:1 B4:1 C5:2'), 84)   # snap back: perfect cadence, as if nothing happened

    # A' 48-59: the smile widens - block brass on the beat, snare rudiments, theme on music box + glock
    for i in range(12):
        spec = PROG[i] if i < 8 else PROG[12 + (i - 8)]
        muzak(48 + i, spec, 54)
        dread(48 + i)
        block(s, 'brass', 48 + i, spec, 48, low='E3', rhythm=((0, .4), (2, .4)))
        rudiment(s, 'perc', 48 + i, 'flam' if i % 2 == 0 else 'march', 46)
        bed(s, 48 + i, spec, 38, ch='pad', low='E3', n=3)
    s.mel('mbox', 48, cap(0, 8) + cap(12, 16), 86)
    s.line('glock', 48, cap(0, 8) + cap(12, 16), 50, transpose=12)

    intro(60)
    return s
