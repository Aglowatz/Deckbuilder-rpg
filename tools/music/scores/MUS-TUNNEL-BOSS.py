"""MUS-TUNNEL-BOSS - Captain Spotless (Old Service Tunnels boss, BB-S-CAP). Loop, 68 bars 4/4, 132 BPM, C major, quantised.
Spotless brings the rigid Capital march down into the old tunnels: drag and flam rudiments, Primm's even quarters on the timpani, block
brass, the Capital theme in C. His fussy inspection flourish (the same idea as MUS-CAP-ENFORCER, now in C and faster) on trumpets and
piccolo. The tunnels answer: a warm contrasting section where the Crossroads motif sings in full in the cello and horns, which Spotless
keeps interrupting with clipped brass; then the climax sets the hero's motif against the Capital theme turned to C minor in the trombones.
"""
from lib import Score, m, motif, motif_head, p
from lib.capital import QUANTISED, rudiment, stumble
from scores._fork_a import cap, prog, bed, each, block, root

SPOTLESS = m('C5:.5 C5:.25 C5:.25 C5:.5 r:.5 E5:.5 G5:.5 C6:1 | B5:.25 C6:.25 B5:.25 A5:.25 G5:1 C5:1 r:1')
SP_H = ['C', 'G7', 'C', 'G7']
PROG = prog()
PROG_M = prog(minor=True)


def build():
    s = Score('MUS-TUNNEL-BOSS', bpm=132, bars=68, key='C major', seed=611, human=QUANTISED)
    s.seat('spic', 'vc', 'cb', 'pad', 'hn', 'tpt', 'tbn', 'tuba', 'picc', 'glock', 'vln', 'timp', 'perc')
    s.channel('echo', 'harp', pan=98, reverb=120, vol=58)
    for bar, nm in ((0, 'intro march'), (4, 'A Spotless inspects the tunnels'), (20, 'B the anthem'), (36, 'C the tunnels answer'),
                    (48, 'D climax'), (64, 'outro march')):
        s.section(bar, nm)
    s.notes.append('Own idea SPOTLESS (as MUS-CAP-ENFORCER, in C); Capital theme in C and C harmonic minor; quantised; the tunnels\' '
                   'warm motif section as contrast.')

    def march(bar, spec, vel, rud):
        rudiment(s, 'perc', bar, rud, vel - 8)
        s.hit('bd', bar * 4, vel)
        s.hit('bd', bar * 4 + 2, vel - 6)
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'G3')
            for k in range(int(d)):
                s.note('spic', t + k, .22, r, vel + (8 if k == 0 else 0))
                s.note('spic', t + k + .5, .18, r + 12, vel - 12)
            b = root(s, sym, 'E1')
            if b >= p('F2'):
                b -= 12
            for k in range(int(d)):
                s.note('cb', t + k, .5, b if k % 2 == 0 else b + 7, vel - 2)
                if k % 2 == 0:
                    s.note('tuba', t + k, .4, b + 12, vel - 14)

    def primm_timp(bar, vel):
        for k, n in enumerate(('C2', 'G2', 'C2', 'G2')):
            s.timp_hit(bar * 4 + k, n, vel)

    def intro(bar):
        for i, spec in enumerate(['C', 'C', 'F', 'G7']):
            march(bar + i, spec, 78, 'drag' if i % 2 == 0 else 'flam')
            bed(s, bar + i, spec, 60, ch='pad', low='E3', n=4)
            block(s, 'tbn', bar + i, spec, 58, low='E3', n=3, rhythm=((0, .5), (2, .5)))
            if i < 2:
                primm_timp(bar + i, 72)
        s.timp_roll((bar + 3) * 4, 4, 'G2', 40, 76)
        s.mel('tpt', bar, cap(0, 2) + SPOTLESS, 86)
        s.motif('hn', bar + 2, motif_head('A3', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 66, form='head (horn, the tunnel stirs)', lead=False)

    intro(0)

    for i in range(16):
        spec = SP_H[i % 4]
        march(4 + i, spec, 78, ['flam', 'drag', 'flam', 'paradiddle'][i % 4])
        bed(s, 4 + i, spec, 54, ch='pad', low='E3', n=4)
        if i % 2 == 0:
            primm_timp(4 + i, 70)
    for k in range(4):
        s.mel('tpt' if k % 2 == 0 else 'picc', 4 + 4 * k, SPOTLESS * 2, 94, transpose=0 if k % 2 == 0 else 12)
        s.line('echo', 4 + 4 * k + 1, m('B5:.25 C6:.25 B5:.25 A5:.25 G5:1 r:2'), 50)
    s.motif('hn', 13, motif('A3', 'minor')[:4] + m('r:1'), 64, form='head + falling third (horns, under the inspection)', lead=False)

    for i in range(16):
        spec = PROG[i]
        march(20 + i, spec, 82, 'march' if i % 2 == 0 else 'flam')
        block(s, 'tbn', 20 + i, spec, 64, low='E3', n=3, rhythm=((0, .5), (1, .5), (2, .5), (3, .5)))
        bed(s, 20 + i, spec, 56, ch='pad', low='E3', n=4)
        if i % 4 == 0:
            s.hit('crash', (20 + i) * 4, 84, dur=2)
    s.mel('tpt', 20, cap(0, 16), 100)
    s.line('glock', 20, cap(0, 8), 56, transpose=12)
    s.line('hn', 28, cap(8, 16, -12), 80)

    # C 36-47: the tunnels answer - warm strings, the motif in full; Spotless cuts in with clipped brass and a stumble
    tun = ['Am', 'F', 'C', 'G', 'Am', 'F', 'Dm', 'E']
    for i in range(12):
        sym = tun[i % 8]
        bed(s, 36 + i, sym, 62, ch='pad', low='E3', n=4, bass=('cb', 'vc'), bvel=60)
        s.harp(36 + i, sym, 50, density=8, ch='echo')
        s.hit('bd', (36 + i) * 4, 60)
        if i % 4 == 3:
            block(s, 'tbn', 36 + i, 'C', 80, low='E3', n=3, rhythm=((2, .3), (3, .3)))
            rudiment(s, 'perc', 36 + i, 'drag', 70, beats=2)
    s.swell('pad', 36, 8, 80, 116)
    s.motif('vc', 36, motif('A3', 'minor') + m('r:1') + motif('C4', 'major') + m('r:1'), 88, form='stated twice (cello, the tunnels answer)')
    s.motif('hn', 40, motif('A4', 'minor') + m('r:1') + motif('E4', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1'), 94,
            form='stated + sequenced (horns, violins)')
    s.line('vln', 40, motif('A4', 'minor') + m('r:1') + motif('E4', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1'), 80, transpose=12)
    stumble(s, 'tpt', 44, SPOTLESS, 90, rush=.8)
    s.mel('hn', 46, m('G4:2 F4:2 | E4:4'), 90)
    s.snare_roll(47 * 4, 4, 50, 104)

    # D 48-63: climax - the hero's motif against the Capital theme in C minor
    for i in range(16):
        spec = PROG_M[i]
        march(48 + i, spec, 86, 'flam' if i % 2 else 'paradiddle')
        bed(s, 48 + i, spec, 66, ch='pad', low='E3', n=4)
        if i % 4 == 0:
            s.hit('crash', (48 + i) * 4, 92, dur=2)
    s.line('tbn', 48, cap(0, 16, -12, minor=True), 88)
    hero = motif('C5', 'minor') + m('r:1') + motif('Eb5', 'major') + m('r:1')
    s.motif('hn', 48, hero, 104, form='stated in C minor then Eb (horns + violins 8va, against the theme)')
    s.line('vln', 48, hero, 96)
    s.motif('tpt', 52, motif('G4', 'minor') + m('r:1') + motif('C5', 'minor') + m('r:1'), 104, form='stated (trumpets)')
    s.mel('hn', 56, m('Ab4:2 G4:2 | F4:2 Eb4:2 | D4:2 F4:2 | G4:4 | C5:2 B4:2 | Ab4:2 G4:2 | F4:2 D4:2 | G4:4'), 100)

    intro(64)
    s.snare_roll(67 * 4 + 2, 2, 50, 90)
    return s
