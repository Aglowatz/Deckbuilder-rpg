"""MUS-CAP-ENFORCER - Every smudge is treason (Captain Spotless at the Approved Gate; enforcer encounters). Loop, 64 bars 4/4, 120 BPM,
G major, quantised. A fussy snare-rudiment march (flams, drags, paradiddles) with Primm's even rhythm hammered in the timpani and clipped
string/brass phrases. Spotless's own idea: a pompous little inspection flourish (G G G G - a fussy turn - G) on piccolo + trumpet, then the
Capital theme in G as block brass. The pressure is real: the march turns G minor, the theme hardens, the Crossroads motif is inverted,
then the hero's motif fights back in the horns over the drill.
"""
from lib import Score, m, motif, motif_head, p
from lib.capital import QUANTISED, rudiment
from scores._fork_a import cap, prog, bed, each, block, root

SPOTLESS = m('G4:.5 G4:.25 G4:.25 G4:.5 r:.5 B4:.5 D5:.5 G5:1 | F#5:.25 G5:.25 F#5:.25 E5:.25 D5:1 G4:1 r:1')
SP_H = ['G', 'D7', 'G', 'D7']
PROG_G = prog(-5)
PROG_GM = prog(-5, minor=True)


def build():
    s = Score('MUS-CAP-ENFORCER', bpm=120, bars=64, key='G major', seed=605, human=QUANTISED)
    s.seat('spic', 'vc', 'cb', 'pad', 'hn', 'tpt', 'tbn', 'tuba', 'picc', 'xylo', 'vln', 'timp', 'perc')
    for bar, nm in ((0, 'intro drill'), (4, 'A Spotless inspects'), (20, 'B the anthem in block brass'), (36, 'C pressure (G minor)'),
                    (48, 'D the hero fights back'), (60, 'outro drill')):
        s.section(bar, nm)
    s.notes.append('Own idea SPOTLESS (fussy inspection flourish); Capital theme in G (block brass); rudiment snare (lib/capital.rudiment).')

    def drill(bar, spec, vel, rud):
        rudiment(s, 'perc', bar, rud, vel - 6)
        s.hit('bd', bar * 4, vel)
        s.hit('bd', bar * 4 + 2, vel - 8)
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'G3')
            for k in range(int(d)):
                s.note('spic', t + k, .22, r, vel + (8 if k == 0 else 0))              # clipped
                s.note('spic', t + k + .5, .18, r + 7, vel - 12)
            b = root(s, sym, 'E1')
            if b >= p('F2'):
                b -= 12
            for k in range(int(d)):
                s.note('cb', t + k, .5, b if k % 2 == 0 else b + 7, vel - 2)
                s.note('tuba', t + k, .4, b + 12 if k % 2 == 0 else b + 7, vel - 16) if k % 2 == 0 else None

    def primm_timp(bar, vel, notes=('G2', 'D2', 'G2', 'D2')):
        for k, n in enumerate(notes):
            s.timp_hit(bar * 4 + k, n, vel)

    def intro(bar):
        for i, spec in enumerate(['G', 'G', 'C', 'D7']):
            drill(bar + i, spec, 78, 'drag' if i % 2 == 0 else 'paradiddle')
            bed(s, bar + i, spec, 60, ch='pad', low='D3', n=4)
            block(s, 'tbn', bar + i, spec, 56, low='D3', n=3, rhythm=((0, 3.5),))
            primm_timp(bar + i, 72)
        s.mel('tpt', bar + 2, SPOTLESS, 82)
        s.motif('hn', bar, motif_head('G3', 'major', rhythm=(1, .5, .5)) + m('r:2'), 70, form='head (horn, before the drill)')

    intro(0)

    for i in range(16):
        spec = SP_H[i % 4]
        drill(4 + i, spec, 76, ['flam', 'drag', 'flam', 'paradiddle'][i % 4])
        bed(s, 4 + i, spec, 52, ch='pad', low='D3', n=4)
        if i % 2 == 0:
            primm_timp(4 + i, 68)
    for k in range(4):
        s.mel('tpt' if k % 2 == 0 else 'picc', 4 + 4 * k, SPOTLESS * 2, 92, transpose=0 if k % 2 == 0 else 12)
        s.line('xylo', 4 + 4 * k + 1, m('F#6:.25 G6:.25 F#6:.25 E6:.25 D6:1 r:2'), 66)
    s.motif('hn', 13, m('G3:1 D4:.5 C4:.5 B3:1.5 A3:.5 D4:2'), 66, form='stated, short (horns, under the inspection)', lead=False)

    for i in range(16):
        spec = PROG_G[i]
        drill(20 + i, spec, 80, 'march' if i % 2 == 0 else 'flam')
        block(s, 'tbn', 20 + i, spec, 64, low='D3', n=3, rhythm=((0, .5), (1, .5), (2, .5), (3, .5)))
        bed(s, 20 + i, spec, 54, ch='pad', low='D3', n=4)
        if i % 4 == 0:
            s.hit('crash', (20 + i) * 4, 82, dur=2)
    s.mel('tpt', 20, cap(0, 16, -5), 98)
    s.line('hn', 20, cap(0, 16, -17), 78)

    # C 36-47: pressure - G minor, the theme hardens, the motif inverted, a rising string ostinato
    for i in range(12):
        spec = PROG_GM[i]
        drill(36 + i, spec, 82 + i, 'paradiddle')
        bed(s, 36 + i, spec, 60 + i, ch='pad', low='D3', n=4)
    s.mel('tbn', 36, cap(0, 8, -17, minor=True), 96)
    s.motif('hn', 44, motif('G4', 'minor', inverted=True) + m('r:1'), 96, form='inverted (horns: the question turned upside down)')
    s.line('vln', 44, motif('G4', 'minor', inverted=True) + m('r:1'), 84, transpose=12)
    s.snare_roll(46 * 4, 8, 50, 110)
    s.timp_roll(47 * 4, 4, 'D2', 60, 110)

    # D 48-59: the hero fights back - the motif in horns + violins over the drill, Spotless in the trombones
    for i in range(12):
        spec = SP_H[i % 4] if i < 8 else ['C', 'D7', 'Em', 'D7'][i - 8]
        drill(48 + i, spec, 86, 'flam')
        bed(s, 48 + i, spec, 66, ch='pad', low='D3', n=4)
        primm_timp(48 + i, 84)
        if i % 4 == 0:
            s.hit('crash', (48 + i) * 4, 92, dur=2)
    hero = motif('G4', 'major') + m('r:1') + motif('D5', 'major', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1')
    s.motif('hn', 48, hero, 104, form='stated + sequenced (horns, violins 8va)')
    s.line('vln', 48, hero, 96, transpose=12)
    s.line('tbn', 48, SPOTLESS * 4, 84, transpose=-12)
    s.mel('tpt', 56, cap(12, 16, -5), 104)

    intro(60)
    s.snare_roll(63 * 4 + 2, 2, 50, 90)
    return s
